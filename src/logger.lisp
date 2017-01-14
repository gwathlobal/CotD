(in-package :cotd)

(defvar *cotd-release* nil)

(defun logger (string)
  (if *cotd-release*
    nil
    (format t string)))
