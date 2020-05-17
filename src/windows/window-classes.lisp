(in-package :cotd)

(defconstant +cotd-unicode-question-mark+ 63)
(defconstant +cotd-unicode-at-sign+ 64)
(defconstant +cotd-unicode-latin-q-captial+ 81)
(defconstant +cotd-unicode-latin-a-small+ 97)
(defconstant +cotd-unicode-latin-f-small+ 102)
(defconstant +cotd-unicode-latin-i-small+ 105)
(defconstant +cotd-unicode-latin-j-small+ 106)
(defconstant +cotd-unicode-latin-l-small+ 108)
(defconstant +cotd-unicode-latin-m-small+ 109)
(defconstant +cotd-unicode-latin-r-small+ 114)
(defconstant +cotd-unicode-greater-than-sign+ 62)
(defconstant +cotd-unicode-less-than-sign+ 60)

(defparameter *glyph-w* 15)
(defparameter *glyph-h* 15)

(defvar *quit-func* 0)
(defvar *start-func* 0)
(defvar *game-func* 0)
(defparameter *current-window* nil)
(defparameter *rects-to-update* ())
(defvar *msg-box-window-height*)

(defclass window ()
  ((return-to :initarg :return-to :initform *current-window* :accessor return-to)
   (quit-func :initform *quit-func* :accessor quit-func)))

(defgeneric make-output (win))

(defgeneric get-input (win key mod unicode))

(defgeneric run-window (win))
