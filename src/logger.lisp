(in-package :cotd)

(defvar *cotd-release* nil)

(defenum:defenum log-options-enum (:log-option-all
                                   :log-option-file
                                   :log-option-none))

(defparameter *cotd-logging* :log-option-all)

(defun logger (string &optional (stream *standard-output*))
  ;;(format stream string)
  ;(if *cotd-release*
  ;  nil
  ;  (log:info string))
  (log:info string)
  )
