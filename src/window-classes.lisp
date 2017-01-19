(in-package :cotd)

(defparameter *glyph-w* 15)
(defparameter *glyph-h* 15)

(defvar *quit-func* 0)
(defvar *start-func* 0)
(defparameter *current-window* nil)
(defparameter *rects-to-update* ())
(defvar *msg-box-window-height*)

(defclass window ()
  ((return-to :initarg :return-to :initform *current-window* :accessor return-to)
   (quit-func :initform *quit-func* :accessor quit-func)))

(defgeneric make-output (win))

(defgeneric get-input (win key mod unicode))

(defgeneric run-window (win))
