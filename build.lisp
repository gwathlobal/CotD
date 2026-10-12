;;;; Release build payload, shared by build.sh (Linux/macOS) and build.bat
;;;; (Windows) so the two stay in lockstep. Both chdir into src/ first and
;;;; then run:  sbcl --non-interactive --load ../build.lisp
;;;;
;;;; Kept as a file rather than a chain of --eval arguments because quoting
;;;; Lisp strings on a cmd.exe command line is its own adventure.
;;;;
;;;; MAKE-EXEC is conditionalized per platform in src/cotd.lisp: it writes
;;;; cotd.exe (:application-type :gui) on Windows and cotd everywhere else,
;;;; into the current directory - i.e. src/, next to data/ and help/, which is
;;;; where DETERMINE-RELEASE-ASSET-DIR expects them relative to the executable.

(require :asdf)

;; src/ holds cotd.asd; the libraries tree itself is expected to come from
;; CL_SOURCE_REGISTRY or the quicklisp setup in the SBCL init file.
(push (uiop:getcwd) asdf:*central-registry*)

(asdf:load-system :cotd)

(cotd:make-exec)
