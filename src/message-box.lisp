(in-package :cotd)

;; :string - the string to display

(defstruct message-box
  (had-message-this-turn nil :type boolean)
  (strings () :type list))

(defvar *message-box* (make-message-box))

(defun add-message (str)
  (logger (format nil "ADD-MESSAGE: ~A~%" str))
  (push str (message-box-strings *message-box*)))

(defun get-message-str (n)
  (nth n (message-box-strings *message-box*)))

(defun message-list-length ()
  (length (message-box-strings *message-box*)))

(defun clear-message-list ()
  (setf *message-box* (make-message-box)))

(defun set-message-this-turn (bool)
  (setf (message-box-had-message-this-turn *message-box*) bool))

(defun get-message-this-turn ()
  (message-box-had-message-this-turn *message-box*))

(defun get-msg-str-list ()
  (loop with str = (make-array '(0) :element-type 'character :adjustable t :fill-pointer t)
        for line in (reverse (message-box-strings *message-box*))
        do
           (format str "~A" line)
        finally (return str)))

