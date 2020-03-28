(in-package :cotd)

(defparameter *win-conditions* (make-hash-table))

(defconstant +win-cond-demonic-attack+ 0)

(deftype win-cond-type () '(member :win-cond-demonic-attack))

(defclass win-condition ()
  ((id :initarg :id :accessor win-condition/id :type win-cond-type)
   (win-formula :initarg :win-formula :accessor win-condition/win-formula)
   (win-func :initarg :win-func :accessor win-condition/win-func)))


(defun set-win-condition (&key id win-formula win-func)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless win-formula (error ":WIN-FORMULA is an obligatory parameter!"))
  (unless win-func (error ":WIN-FUNC is an obligatory parameter!"))
  
  (setf (gethash id *win-conditions*) (make-instance 'win-condition :id id
                                                                    :win-formula win-formula
                                                                    :win-func win-func)))

(defun get-win-condition-by-id (win-condition-id)
  (gethash win-condition-id *win-conditions*))
