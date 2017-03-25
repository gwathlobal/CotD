(in-package :cotd)

;; :string - the string to display

(defstruct message-box
  (had-message-this-turn nil :type boolean)
  (strings () :type list))

(defvar *full-message-box* (make-message-box))
(defvar *small-message-box* (make-message-box))

(defun add-message (str)
  (logger (format nil "ADD-MESSAGE: ~A~%" str))
  (push str (message-box-strings *full-message-box*))
  (push str (message-box-strings *small-message-box*)))

(defun get-message-str (n &optional (message-box *full-message-box*))
  (nth n (message-box-strings message-box)))

(defun message-list-length (&optional (message-box *full-message-box*))
  (length (message-box-strings message-box)))

(defun clear-message-list (&optional (message-box *full-message-box*))
  (setf (message-box-strings message-box) ())
  (setf (message-box-had-message-this-turn message-box) nil))

(defun set-message-this-turn (bool &optional (message-box *full-message-box*))
  (setf (message-box-had-message-this-turn message-box) bool))

(defun get-message-this-turn (&optional (message-box *full-message-box*))
  (message-box-had-message-this-turn message-box))

(defun get-msg-str-list (&optional (message-box *full-message-box*))
  (loop with str = (make-array '(0) :element-type 'character :adjustable t :fill-pointer t)
        for line in (reverse (message-box-strings message-box))
        do
           (format str "~A" line)
        finally (return str)))

