# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

City of the Damned (CotD) is a roguelike written in Common Lisp (SBCL) using lispbuilder-sdl 1.2. Dependencies: `lispbuilder-sdl`, `bordeaux-threads`, `cffi`, `defenum`, `cl-store`, `uiop`, `log4cl` (via Quicklisp). ASDF system defined in `src/cotd.asd`.

## Commands

Load and run from an SBCL/SLIME REPL (cwd inside `src/`, or with CL_SOURCE_REGISTRY pointing at the libraries tree):

```lisp
(asdf:load-system :cotd)
(cotd:cotd-main)
```

Force-rebuild only this system when checking for warnings (avoid `:force t`, which also rebuilds `uiop` and floods output):

```lisp
(asdf:load-system :cotd :force '(:cotd))
```

Build must stay at **zero warnings**.

### Headless regression harness (`src/headless-test.lisp`)

There is no SDL-free unit test suite; the regression oracle is deterministic, seeded level generation. Compiling proves almost nothing here — always run this before/after a change:

```lisp
(run-headless-regression)                      ; baseline, before your change
;; ... make the change, reload ...
(run-headless-regression)                      ; after
(headless-regression-diff before after)        ; non-nil => behavior changed
```

`generate-headless-level` runs `init-game` with no SDL window (via its injectable `:screen-update-func`) and `*cotd-release*` set to skip per-mob debug invariants. Same seed -> identical `level-checksum` (terrain checksum + mob/item/feature counts) across runs and builds.

Pick the right check for what you touched — see the project's `verification-recipes` memory for the full table, but in short:
- level gen / terrain / connectivity -> checksum terrain + every `(x y z move-mode)` via `get-level-connect-map-value`, several seeds
- type tables / initargs / id spaces -> dump every trait/ability/AI-package/armor of all type instances **with `type-of`**, plus all id constants, diff
- memo / FOV / gameplay logic -> checksum memo fields via public readers after N seeded AI turns
- rendering -> render old vs new into two surfaces, compare every pixel (`sdl:read-pixel-*`)
- a predicate's definition -> exhaustively compare old vs new over its full input space
- anything timed -> run 4x and report a band; same-build variance is ~5%

Always verify through the **public accessor**, not the underlying structure, so the test survives representation changes.

## Line endings (CRLF)

Several files in the repo are **CRLF**, not LF, mixed in with an otherwise-LF codebase: `src/mobs.lisp`, `src/lvl-features.lisp`, `src/init-ability-types.lisp`, `src/init-terrain-types.lisp`, `src/windows/window-methods.lisp`, `src/windows/window-map-select.lisp`, and the top-level `.txt` docs (`README.txt`, `TODO.txt`, `CHANGELOG.txt`, etc.).

Any tool that reads a file as text and rewrites it (not a normal editor save) will silently normalize it to LF on write, turning the entire file into a diff and burying the actual change inside noise. This has happened twice.

- Before committing, check whether a file you touched with a script/non-editor tool changed line endings: `file src/*.lisp src/windows/*.lisp`.
- If a diff for one of these files looks far larger than the intended change, suspect an LF/CRLF flip first.
- Prefer `Edit`/an editor (which preserves existing line endings) over shell text-processing (`sed`, Python read/write, etc.) on these specific files.

## Architecture

### Load order and id-space generation

`src/cotd.asd` is the map of module dependencies — read it before guessing where something lives. Rough layers, in dependency order:

1. **Id spaces and globals** (`globals.lisp`, `glyph-globals.lisp`, `world-globals.lisp`): terrain traits, feature traits, mob abilities, and AI packages are each defined by *one spec list* (`*terrain-trait-specs*`, `*feature-trait-specs*`, `*mob-abil-specs*`, `*ai-package-specs*`) consumed by the `define-trait-ids` / `define-trait-initializer` macros. These generate the id constants (e.g. `+terrain-trait-blocks-move+`), a `+..-count+`, and the class's whole `initialize-instance :after`. **Adding a new trait/ability/package is appending one entry to the relevant list** — never insert or reorder; position is the id, and mob-ability ids are hash keys inside saved games (`cl-store`).
2. **Domain model**: `world.lisp`, `mobs.lisp`, `factions.lisp`, `abilities.lisp`, `effects.lisp`, `terrain.lisp`, `lvl-features.lisp`, `items.lisp`, `cards.lisp`, `gods.lisp`, `buildings/` (building types by district corruption level: common/normal/ruined/corrupted/hell).
3. **Vision/sound**: `los-fov.lisp`, `hearing.lisp` depend on `world` + `mobs`.
4. **`base-methods.lisp`** is the largest file (~177k) and the core game-logic hub (combat, movement, item use, ability resolution) — most gameplay behavior lives here or gets dispatched from here.
5. **Level/world generation**: `level-city.lisp`, `generate-level.lisp`, `random-scenario.lisp`, `world-map.lisp`, `world-sector.lisp`, `level-modifiers/` (composable per-level modifiers: controlled-by, sector-feature, sector-item, time-of-day, weather, player-placement, misc).
6. **Missions/campaign**: `mission.lisp`, `mission-type.lisp`, `win-condition.lisp`, `campaign-command.lisp`, `campaign-effects.lisp`, plus their `init-*-types.lisp` counterparts that populate the actual content tables (terrain, features, mobs, items, cards, gods, missions, campaign effects/commands) using the macros from step 1/4.
7. **`windows/`**: UI screens, all depending on `window-methods.lisp` (the base window class/dispatch) and `key-bindings.lisp`.
8. **`ai/`**: `ai-common.lisp` (shared utilities — A* pathing cost functions, etc.), `ai-npc.lisp` / `ai-player.lisp` (behavior), `ai-packages.lisp` + `init-ai-packages.lisp` (the AI-package id space from step 1 wired to actual behavior).
9. **`game-events/`**: one file per mission/campaign event family (demonic attack/raid/steal/conquest, military conquest/raid/sabotage, angelic steal/sabotage, satanist elimination, campaign win/campaign), all built on `game-events.lisp`'s generic event struct (`on-check` / `on-trigger` closures).
10. **`cotd.lisp`**: entry point, `game-loop` (the real-time turn loop: check win conditions, run game events, then iterate `mob-id-list`, calling `ai-function` per mob with available AP), init/exec glue.
11. **`headless-test.lisp`**: the regression harness described above, depends on everything (`cotd`).

### Turn loop shape

`game-loop` (`cotd.lisp`) is a `loop` that: checks the player's win condition, runs all non-disabled `game-events` `on-check`/`on-trigger` pairs, processes animations, then iterates `mob-id-list` — any mob with `cur-ap > 0` and not dead/merged gets `ai-function` called, followed by `update-visible-mobs`/`update-visible-area` for the player. When every mob is out of AP for the turn, APs refill by `max-ap` and the player's `game-time` increments. `*player*` is reassigned mid-loop for trinity mimics / split-soul mechanics — the "current mob being controlled" is not a fixed object.

### Directories/paths at runtime

`*asset-dir*` (read-only: `data/`, `help/`) and `*user-dir*` (writes: saves, morgue, highscores, `options.cfg`, `log.txt`) are separate globals in `globals.lisp`. In dev both default to the ASDF system source directory. In the `#+sbcl` release build, `*asset-dir*` resolves from the executable's own path (`determine-release-asset-dir`) and `*user-dir*` is `(uiop:xdg-data-home "cotd/")`.

### Serialization

`save-load-game.lisp` uses `cl-store` to serialize `*world*`, `*mobs*`, `*items*`, `*lvl-features*`, `*effects*` slot-for-slot. **Bump `*save-version*`** whenever a serialized class's shape changes — the load screen already refuses a version mismatch cleanly, so this is the only required step.

### Logging

`(log:info (format nil "..." args))` sites (there are ~144) are intentionally fine, not a latent bug: log4cl treats a non-literal first argument as data to log rather than as a format control, and logging is lazy (no eval when the level is off). Don't "fix" these as a safety issue; it's a cosmetic/log-size cleanup at most.

### Performance notes

Level generation and gameplay-turn profiling must be done headlessly (see the harness above) with `sb-sprof`, with results checked against a noise band (~5% same-build variance) rather than a single run. The profile is flat after prior optimization passes — PCL generic-slot-accessor dispatch is a large recurring chunk; untyped accessors and bad representations (not algorithms) have been the repeated culprit. Don't assume an "obvious" optimization (manual CSE, micro-restructuring a hot closure) is a win without measuring — several plausible ones measured as pure noise.
