(in-package :cotd)

(defparameter *win-conditions* (make-hash-table))

(defenum:defenum win-cond-enum (:win-cond-demonic-attack
                                :win-cond-demonic-raid
                                :win-cond-thief
                                :win-cond-demonic-conquest
                                :win-cond-military-conquest
                                :win-cond-demon-campaign
                                :win-cond-military-campaign
                                :win-cond-angels-campaign))

(defclass win-condition ()
  ((id :initarg :id :accessor win-condition/id :type win-cond-enum)
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
