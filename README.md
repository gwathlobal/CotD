# City of the Damned

[![CI](https://github.com/gwathlobal/CotD/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/gwathlobal/CotD/actions/workflows/ci.yml?query=branch%3Amaster)
[![Latest release](https://img.shields.io/github/v/release/gwathlobal/CotD)](https://github.com/gwathlobal/CotD/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue)](https://github.com/gwathlobal/CotD/blob/master/LICENSE)

A traditional roguelike about angels and demons fighting over a human city,
written in Common Lisp. Turn-based, permadeath, an ASCII map, and a faction
war that goes on whether or not you take part in it.

## Status

**City of the Damned is complete at version 2.1.x and is no longer being
developed.** It stays here, under the GPL, and the releases stay downloadable.

The game continues under a new name, **Malgorod**, as a closed-source
commercial project aimed at Steam. Everything that has been built since
October 2026 - a resizable and fullscreen window, mouse support, tutorials,
a reworked interface - is there and not here. If you like what you find in
City of the Damned, that is the name to look for.

Bug reports against 2.1.x are welcome as issues, but expect fixes to land in
Malgorod rather than in a 2.1.2.

## What it is

You play one unit in someone else's apocalypse. A city is being fought over
by angels, demons, the human military and the cults in between, and the war
does not wait for you.

- **13 playable characters** that play nothing alike: an angel blessing
  civilians, a demon possessing them, a military chaplain leading a squad, a
  thief, a satanist in disguise, a lost soul with one hit point.
- **12 mission types** with different win conditions, from a demonic raid for
  flesh to a satanist hunt through the streets.
- **A campaign layer** over the missions: a map of sectors, each with its own
  fight, and a war whose front moves between them.
- Small, dense levels and short runs. A mission is a coffee break; a campaign
  is an evening.

It began as a continuation of the 7DRL entry
[City of the Condemned](http://www.roguebasin.com/index.php?title=City_of_the_Condemned)
by Tapio, and grew from there over nine years.

## Downloads

Grab the archive for your platform from the
[Releases](https://github.com/gwathlobal/CotD/releases) page: Windows and
macOS downloads carry SDL2 with them; on Linux install your distribution's
SDL2 package first. Unpack anywhere and run `cotd`. Saves and options are
written to your user directory, not next to the game.

The Windows and macOS executables are not code-signed, so SmartScreen and
Gatekeeper may object the first time. On Windows choose *More info* and
*Run anyway*. On macOS allow it under *System Settings > Privacy & Security*,
or clear the quarantine flag: `xattr -d com.apple.quarantine cotd`.

## Known limits

These are the things people ask about first. None of them will change in
this repository.

- The window is a fixed size and there is **no fullscreen** mode. The game
  draws at a single scale.
- **Keyboard only.** There is no mouse support; `?` in the game lists the
  keys, as do the files in `help/` next to the game (`src/help/` in this
  repository).
- There is no tutorial. Start as the military chaplain or the chrome angel
  and read `overview.txt` in that same directory first.

## Compiling

Refer to [COMPILE-DEPENDECIES.txt](COMPILE-DEPENDECIES.txt) for the Common
Lisp library dependencies (all available through Quicklisp) and to
[COMPILING.txt](COMPILING.txt) for setting up SBCL and building the game.
SDL2 is needed to run the game, not to build it: the game declares the library
to CFFI itself and opens it on startup.

`build.sh` (Linux, macOS) and `build.bat` (Windows) produce the standalone
executable the releases ship.

## Changelog

See [CHANGELOG.txt](CHANGELOG.txt). The newest entries, 2.1.0 and 2.1.1,
are the SDL2 port and the standalone executables; nothing about how the game
plays changed in them.

## Licence

GNU General Public License v3. See [LICENSE](LICENSE).
