(in-package :cotd)

;; :string - the string to display

(defstruct message-box
  (had-message-this-turn nil :type boolean)
  (strings (make-colored-txt) :type colored-txt))

(defvar *full-message-box* (make-message-box))
(defvar *small-message-box* (make-message-box))

(defun add-message (str &optional (color sdl:*white*))
  (logger (format nil "ADD-MESSAGE: ~A~%" str))
  (add-colored-str (message-box-strings *full-message-box*) str color)
  (add-colored-str (message-box-strings *small-message-box*) str color))

(defun get-message-str (n &optional (message-box *full-message-box*))
  (first (nth n (colored-txt-list (message-box-strings message-box)))))

(defun message-list-length (&optional (message-box *full-message-box*))
  (length (colored-txt-list (message-box-strings message-box))))

(defun clear-message-list (&optional (message-box *full-message-box*))
  (setf (colored-txt-list (message-box-strings message-box)) ())
  (setf (message-box-had-message-this-turn message-box) nil))

(defun set-message-this-turn (bool &optional (message-box *full-message-box*))
  (setf (message-box-had-message-this-turn message-box) bool))

(defun get-message-this-turn (&optional (message-box *full-message-box*))
  (message-box-had-message-this-turn message-box))

(defun get-msg-str-list (&optional (message-box *full-message-box*))
  (loop with str = (make-array '(0) :element-type 'character :adjustable t :fill-pointer t)
        for (line color) in (reverse (colored-txt-list (message-box-strings message-box)))
        do
           (format str "~A" line)
        finally (return str)))

(defun prepend-article-func (article name &rest args)
  (let ((article-str (cond
                       ((= article +article-a+) "a ")
                       ((= article +article-the+) "the ")
                       (t ""))))
    (when (or (find +noun-proper+ args)
              (and (find +noun-common+ args)
                   (find +noun-plural+ args)
                   (= article +article-a+)))
      (setf article-str ""))
    (format nil "~A~A" article-str name)))

(defmacro prepend-article (article name-func)
  `(multiple-value-call #'prepend-article-func ,article ,name-func))
