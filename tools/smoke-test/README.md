# Real-game smoke test

The headless oracles in `src/headless-test.lisp` run on SDL's `dummy` video
driver, which never executes the window system's code. Bugs that live there -
SDL2 float traps on X11, text input events - only show up in the real game on
a real display. This plays a fixed route through the actual game, with real X
key events, in a nested X server so nothing touches your own desktop session.

Needs: Linux with X11, `Xephyr` (package `xserver-xephyr`), libX11 and libXtst,
and a host X display in `DISPLAY` for Xephyr's window to appear on.

```lisp
(push #p"/path/to/CotD/tools/smoke-test/" asdf:*central-registry*)
(asdf:load-system :cotd-smoke-test)
(cotd-smoke-test:run-smoke-test :game :release)  ; src/cotd, after ./build.sh
(cotd-smoke-test:run-smoke-test :game :source)   ; the source tree
```

The route: main menu -> quick scenario (arrow keys) -> a faction (letter key)
-> type a name (Backspace, Shift, minus) -> the level -> 3 moves -> help (`?`)
-> journal -> inventory -> Ctrl+d -> save & quit -> load the save -> one move
-> quit without saving -> exit.

Checked automatically: the game exits with code 0, the save is written, nothing
is logged at ERROR level, no screenshot is blank. Every step's screenshot is
saved under `/tmp/cotd-smoke-test/screens/` (PPM) - look at them: whether each
screen shows the right thing is not checked. The game's saves, options and log
go to `/tmp/cotd-smoke-test/data/cotd/`, never to your real user data.

If the menu seems to start on the wrong item, a key may be held on the host:
Xephyr inherits the host keyboard state. The test releases every key the
nested server reports as held before starting the game, and prints which.

The route hard-codes menu positions (e.g. `e` is "Load scenario" once a save
exists); if the menus change, the route has to follow.
