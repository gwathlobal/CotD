@echo off
rem Builds the cotd release executable via SBCL, without needing a manual REPL.
rem Output: src\cotd.exe (next to data\ and help\, which the release build
rem locates relative to the executable's own path).
rem
rem SBCL must be on PATH, or set the SBCL variable to the full path of
rem sbcl.exe first, e.g.:
rem     set "SBCL=C:\Lisp\SBCL\2.4.10\sbcl.exe"
rem SDL.dll has to be findable too - see COMPILING.txt.
rem
rem Run this from a cmd.exe prompt rather than by double-clicking it, so the
rem output stays on screen when it finishes.
setlocal

if not defined SBCL set "SBCL=sbcl"

cd /d "%~dp0src" || exit /b 1

"%SBCL%" --non-interactive --load ../build.lisp
if errorlevel 1 (
  echo Build failed. 1>&2
  exit /b 1
)

echo Built: %~dp0src\cotd.exe
