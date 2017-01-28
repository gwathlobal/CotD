(in-package :cotd)

(defparameter *game-events* (make-hash-table))

(defconstant +game-event-win-for-angels+ 0)
(defconstant +game-event-win-for-demons+ 1)
(defconstant +game-event-win-for-humans+ 2)
(defconstant +game-event-lose-game+ 3)
(defconstant +game-event-military-arrive+ 4)
(defconstant +game-event-snow-falls+ 5)

(defclass game-event ()
  ((id :initarg :id :accessor id)
   (disabled :initform nil :initarg :disabled :accessor disabled)
   (on-check :initarg :on-check :accessor on-check)
   (on-trigger :initarg :on-trigger :accessor on-trigger)))

(defun set-game-event (game-event)
  (setf (gethash (id game-event) *game-events*) game-event))

(defun get-game-event-by-id (game-event-id)
  (gethash game-event-id *game-events*))
