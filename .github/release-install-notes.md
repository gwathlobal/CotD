### Installing

**Windows** - unzip it and run cotd.exe. SDL2.dll is in the zip; nothing else to install.

**Linux** - install your distribution's SDL2 runtime (`libsdl2-2.0-0` on Debian and Ubuntu), then run ./cotd.

**macOS (Apple silicon)** - SDL2.framework is in the archive, so there is nothing to install either. In particular do not `brew install sdl2`: that is an alias for sdl2-compat, SDL2's API reimplemented on top of SDL3, which is a different library. The build is unsigned, so Gatekeeper quarantines it until you clear the flag: `xattr -dr com.apple.quarantine cotd`. The game is built and started automatically on macOS, but nobody has played it through there.

Keep `data/` and `help/` next to the executable; `cotd --check` verifies an installation and names anything missing. Saves, options and the log go to a per-user directory rather than into the install, so installing somewhere read-only works.
