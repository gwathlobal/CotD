(in-package :cotd)

(defconstant +default-font-w+ 6)
(defconstant +default-font-h+ 13)
;(defparameter +glyph-w+ 8)
;(defparameter +glyph-h+ 16)

(defparameter +glyph-w+ 15)
(defparameter +glyph-h+ 15)

(defvar *quit-func* 0)
(defparameter *current-window* nil)
(defparameter *rects-to-update* ())
(defparameter *msg-box-window-height* (* +default-font-h+ 10))
(defvar *game-over-func*)

(defclass window ()
  ((return-to :initarg :return-to :initform *current-window* :accessor return-to)
   (quit-func :initform *quit-func* :accessor quit-func)))

(defclass cell-window (window)
  ((shoot-mode :initform :single :accessor shoot-mode)
   (meaningful-action :initform nil :accessor meaningful-action)))

(defgeneric make-output (win))

(defgeneric get-input (win key mod unicode))

(defgeneric run-window (win))



(defparameter *off-y-command-line* (+ +glyph-h+ (* *max-y-view* +glyph-h+) +glyph-h+ *msg-box-window-height* +glyph-h+))
