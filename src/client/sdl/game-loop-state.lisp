;;;; game-loop-state.lisp

(in-package #:cotd-sdl)

(defconstant +game-loop-init+ 0)
(defconstant +game-loop-player-turn+ 1)
(defconstant +game-loop-other-turn+ 2)
(defconstant +game-loop-finalize-turn+ 3)

(defparameter *game-loop-state* (bt2:make-atomic-integer :value +game-loop-init+))

(defun reset-game-loop-state (&optional (value +game-loop-init+))
  (setf *game-loop-state* (bt2:make-atomic-integer :value value)))

(defun get-game-loop-state ()
  (bt2:atomic-integer-value *game-loop-state*))

(defun set-game-loop-state (old-value new-value)
  (bt2:atomic-integer-compare-and-swap *game-loop-state*
                                       old-value
                                       new-value))
