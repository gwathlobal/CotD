(in-package :cotd)

(defclass objective-type ()
  ((id :initarg :id :accessor id)
   (descr :initarg :descr :accessor descr)))


(defun set-objective-type (objective-type)
  (when (>= (id objective-type) (length *objective-types*))
    (adjust-array *objective-types* (list (1+ (id objective-type))) :initial-element nil))
  (setf (aref *objective-types* (id objective-type)) objective-type))

(defun get-objective-type-by-id (objective-type-id)
  (aref *objective-types* objective-type-id)) 
