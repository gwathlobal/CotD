;;;; Play a fixed route through the real game in a nested X server and check
;;;; what can be checked automatically. See README.md.

(defpackage :cotd-smoke-test
  (:use :cl :cotd-xdrive)
  (:export #:run-smoke-test))

(in-package :cotd-smoke-test)

(defparameter *repository* (asdf:system-relative-pathname :cotd-smoke-test "../../"))

(defun wait-until (timeout-seconds fn &key (interval 0.5))
  "Call FN every INTERVAL seconds until it returns true; return that value, or
NIL once TIMEOUT-SECONDS have passed."
  (loop with deadline = (+ (get-internal-real-time) (* timeout-seconds internal-time-units-per-second))
        for value = (funcall fn)
        when value return value
        while (< (get-internal-real-time) deadline)
        do (sleep interval)))

(defun start-xephyr (display)
  (when (let ((d (open-display display))) (when d (close-display d) t))
    (error "X display ~A is already in use; stop whatever runs there first" display))
  (let ((process (uiop:launch-program (list "Xephyr" display "-screen" "1000x600" "-ac" "-br" "-noreset")
                                      :output nil :error-output nil)))
    (unless (wait-until 15 (lambda () (let ((d (open-display display))) (when d (close-display d) t))))
      (uiop:terminate-process process)
      (error "Xephyr did not come up on ~A (it needs a host display in DISPLAY)" display))
    process))

(defun source-game-script (data-dir)
  "A script that runs the game from the source tree with its user data in
DATA-DIR/cotd/ - the same place the release executable puts it when
XDG_DATA_HOME is DATA-DIR."
  (let ((path (merge-pathnames "run-game.lisp" data-dir)))
    (with-open-file (s path :direction :output :if-exists :supersede)
      (with-standard-io-syntax
        (let ((*print-readably* nil))
          (format s "(require :asdf)~%(push ~S asdf:*central-registry*)~%(asdf:load-system :cotd)~%~
                     (setf cotd::*user-dir* ~S)~%(ensure-directories-exist cotd::*user-dir*)~%~
                     (cotd:cotd-main)~%(uiop:quit 0)~%"
                  (merge-pathnames "src/" *repository*)
                  (merge-pathnames "cotd/" data-dir)))))
    path))

(defun start-game (game display data-dir)
  "Launch the game on DISPLAY. GAME is :RELEASE (src/cotd, as built by
build.sh, started from another directory so its asset lookup is exercised) or
:SOURCE (the source tree, loaded by a fresh SBCL)."
  (let ((env (list "env" (format nil "DISPLAY=~A" display) (format nil "XDG_DATA_HOME=~A" (uiop:native-namestring data-dir)))))
    (ecase game
      (:release
       (let ((executable (merge-pathnames "src/cotd" *repository*)))
         (unless (probe-file executable)
           (error "~A does not exist - run build.sh first" executable))
         (uiop:launch-program (append env (list (uiop:native-namestring executable)))
                              :directory data-dir
                              :output (merge-pathnames "game-output.txt" data-dir) :if-output-exists :supersede
                              :error-output :output)))
      (:source
       (uiop:launch-program (append env (list "sbcl" "--non-interactive" "--load"
                                              (uiop:native-namestring (source-game-script data-dir))))
                            :output (merge-pathnames "game-output.txt" data-dir) :if-output-exists :supersede
                            :error-output :output)))))

(defun run-smoke-test (&key (game :release) (display ":5")
                            (out-dir #p"/tmp/cotd-smoke-test/") (level-wait 12) (start-timeout 180))
  "Start Xephyr on DISPLAY, run GAME (:RELEASE or :SOURCE) in it, and play:
main menu -> quick scenario (arrow keys) -> a faction (letter) -> type a name
(Backspace, Shift, minus) -> the level -> 3 moves -> help (?) -> journal ->
inventory -> Ctrl+d -> save & quit -> load the save -> one move -> quit without
saving -> exit. Screenshots of every step go to OUT-DIR/screens/ as PPM files;
the game's user data goes to OUT-DIR/data/cotd/ and its console output to
OUT-DIR/data/game-output.txt.

Checked automatically: the game exits with code 0, the save file is written,
nothing is logged at ERROR level, and no screenshot is blank. Whether each
screen shows the right thing is for a person (or Claude) to look at.

Returns (values PASSED FAILURES SCREENSHOT-DIR)."
  (let* ((out-dir (uiop:ensure-directory-pathname out-dir))
         (screens (merge-pathnames "screens/" out-dir))
         (data-dir (merge-pathnames "data/" out-dir))
         (user-dir (merge-pathnames "cotd/" data-dir))
         (failures ())
         (step 0)
         xephyr game-process)
    (uiop:delete-directory-tree out-dir :validate t :if-does-not-exist :ignore)
    (ensure-directories-exist screens)
    (ensure-directories-exist user-dir)
    (flet ((fail (format-control &rest args)
             (push (apply #'format nil format-control args) failures)))
      (unwind-protect
           (handler-case
            (progn
             (setf xephyr (start-xephyr display))
             (with-display (x display)
               (let ((stuck (release-all-keys x)))
                 (when stuck
                   (format t "~&Released keys the X server reported as held: ~A~%" stuck)))
               (setf game-process (start-game game display data-dir))
               (unless (wait-until start-timeout (lambda () (or (> (screen-colour-count x) 1)
                                                                (not (uiop:process-alive-p game-process)))))
                 (error "nothing appeared on ~A within ~A s" display start-timeout))
               (unless (uiop:process-alive-p game-process)
                 (error "the game exited with code ~A before showing anything; its output is in ~A"
                        (uiop:wait-process game-process) (merge-pathnames "game-output.txt" data-dir)))
               (sleep 2)
               (labels ((shot (name)
                          (let ((path (merge-pathnames (format nil "~2,'0D-~A.ppm" (incf step) name) screens)))
                            (screenshot x path)
                            (when (= 1 (screen-colour-count x))
                              (fail "screen ~A is blank" (pathname-name path)))))
                        (press (keysym &rest args) (apply #'key x keysym args)))
                 (shot "main-menu")
                 (press "Down" :wait 0.5) (shot "quick-scenario-selected")
                 (press "Return" :wait 1.5) (press "g" :wait 1.0) (shot "faction-selected")
                 (press "Return" :wait 2.0) (shot "name-prompt")
                 (dotimes (i 6) (press "BackSpace" :wait 0.15))
                 (type-text x "Smoke-Test") (sleep 0.5) (shot "name-typed")
                 (press "Return" :wait 1.0) (sleep level-wait) (shot "level")
                 (dotimes (i 3) (press "Left" :wait 1.0))
                 (sleep 1) (shot "after-3-moves")
                 (press "slash" :shift t :wait 1.0) (shot "help")
                 (press "Escape" :wait 1.0) (press "j" :wait 1.0) (shot "journal")
                 (press "Escape" :wait 1.0) (press "i" :wait 1.0) (shot "inventory")
                 (press "d" :ctrl t :wait 1.0) (shot "ctrl-d-drop-prompt")
                 (press "Escape" :wait 1.0) (press "Escape" :wait 1.0)
                 (press "Escape" :wait 1.0) (shot "scenario-menu")
                 (press "Return" :wait 3.0) (shot "saved-back-at-main-menu")
                 (unless (probe-file (merge-pathnames "saves/scenario/save0/game" user-dir))
                   (fail "no save file written to ~A" (merge-pathnames "saves/scenario/save0/" user-dir)))
                 (press "e" :wait 0.7) (press "Return" :wait 1.5) (shot "load-list")
                 (press "Return" :wait 8.0) (shot "loaded-message")
                 (press "space" :wait 3.0) (shot "restored")
                 (press "Left" :wait 1.5) (shot "moved-after-load")
                 (press "Escape" :wait 1.0) (press "Down" :wait 0.5) (press "Return" :wait 2.0)
                 (shot "quit-to-main-menu")
                 (press "Escape" :wait 1.0)))
             (if (wait-until 30 (lambda () (not (uiop:process-alive-p game-process))))
                 (let ((code (uiop:wait-process game-process)))
                   (unless (eql code 0)
                     (fail "the game exited with code ~A" code)))
                 (fail "the game did not exit after Escape on the main menu"))
             (let ((log (merge-pathnames "log.txt" user-dir)))
               (when (probe-file log)
                 (let ((errors (remove-if-not (lambda (line) (search " ERROR " line))
                                              (uiop:read-file-lines log))))
                   (when errors
                     (fail "~D ERROR line~:P in ~A, the first: ~A" (length errors) log (first errors)))))))
            (error (c) (fail "the run stopped early: ~A" c)))
        (when (and game-process (uiop:process-alive-p game-process))
          (uiop:terminate-process game-process))
        (when xephyr
          (uiop:terminate-process xephyr)
          (uiop:wait-process xephyr))))
    (setf failures (nreverse failures))
    (format t "~&Smoke test (~(~A~)): ~:[FAILED~;passed~], ~D screenshots in ~A~%~{  - ~A~%~}"
            game (null failures) step screens failures)
    (values (null failures) failures screens)))
