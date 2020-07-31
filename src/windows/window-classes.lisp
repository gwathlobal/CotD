(in-package :cotd)

(defconstant +cotd-unicode-question-mark+ 63)
(defconstant +cotd-unicode-at-sign+ 64)
(defconstant +cotd-unicode-latin-q-captial+ 81)
(defconstant +cotd-unicode-latin-a-small+ 97)
(defconstant +cotd-unicode-latin-b-small+ 98)
(defconstant +cotd-unicode-latin-c-small+ 99)
(defconstant +cotd-unicode-latin-d-small+ 100)
(defconstant +cotd-unicode-latin-e-small+ 101)
(defconstant +cotd-unicode-latin-f-small+ 102)
(defconstant +cotd-unicode-latin-i-small+ 105)
(defconstant +cotd-unicode-latin-j-small+ 106)
(defconstant +cotd-unicode-latin-l-small+ 108)
(defconstant +cotd-unicode-latin-m-small+ 109)
(defconstant +cotd-unicode-latin-n-small+ 110)
(defconstant +cotd-unicode-latin-r-small+ 114)
(defconstant +cotd-unicode-latin-s-small+ 115)
(defconstant +cotd-unicode-greater-than-sign+ 62)
(defconstant +cotd-unicode-less-than-sign+ 60)

(defparameter *glyph-w* 15)
(defparameter *glyph-h* 15)

(defvar *quit-func* 0)
(defvar *start-func* 0)
(defparameter *current-window* nil)
(defparameter *rects-to-update* ())
(defvar *msg-box-window-height*)

(defenum:defenum menu-command-enum (:menu-stop-loop
                                    :menu-continue
                                    :menu-load-scenario
                                    ))

(defclass window ()
  ((return-to :initarg :return-to :initform *current-window* :accessor return-to)
   (quit-func :initform *quit-func* :accessor quit-func)))

(defgeneric make-output (win))

(defgeneric get-input (win key mod unicode))

(defgeneric run-window (win))

(defun go-to-quit-game ()
  (funcall *quit-func*))

(defun go-to-start-game ()
  (funcall *start-func*))

(defmacro continuable (&body body)
  "Helper macro that we can use to allow us to continue from an error. Remember to hit C in slime or pick the restart so errors don't kill the app."
  `(restart-case (progn ,@body) (continue () :report "Continue")))

#+swank
(defun update-swank ()
  "Called from within the main loop, this keep the lisp repl working while the game runs"
  (continuable (let ((connection (or swank::*emacs-connection* (swank::default-connection))))
                 (when connection
                   (swank::handle-requests connection t)))))
#-swank
(defun update-swank ()
  nil)
