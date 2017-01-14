(in-package :cotd)

;; :string - the string to display

(defvar *message-box* (make-list 0))

(defun add-message (str)
  (logger (format nil "ADD-MESSAGE: ~A~%" str))
  (let ((line (make-hash-table)))
    (setf (gethash :string line) str)
    (setf *message-box* (append *message-box* (list line)))))

(defun get-message-str (n)
  (gethash :string (nth n *message-box*)))

(defun message-list-length ()
  (length *message-box*))

(defun clear-message-list ()
  (setf *message-box* (make-list 0)))

(defun get-msg-str-list ()
  (let ((str (make-array '(0) :element-type 'character :adjustable t :fill-pointer t)))
    (dolist (line *message-box*)
      (format str "~A" (gethash :string line)))
    str))
