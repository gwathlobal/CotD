(in-package :cotd)

(defvar *cotd-release* nil)

(defun logger (string &optional (stream *standard-output*))
  (if *cotd-release*
    nil
    (format stream string)))
