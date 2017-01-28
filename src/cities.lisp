(in-package :cotd)

(defconstant +city-type-random+ 0)
(defconstant +city-type-normal-summer+ 1)
(defconstant +city-type-normal-winter+ 2)

(defparameter *city-types* (make-array (list 0) :adjustable t))

(defstruct city-type 
  (id)
  (return-max-buildings #'(lambda () nil) :type function)
  (return-reserv-buildings #'(lambda () nil) :type function)
  (post-processing-func nil))

(defun set-city-type (city-type)
  (when (>= (city-type-id city-type) (length *city-types*))
    (adjust-array *city-types* (list (1+ (city-type-id city-type)))))
  (setf (aref *city-types* (city-type-id city-type)) city-type))

(defun get-city-type-by-id (city-type-id)
  (aref *city-types* city-type-id))

(defun get-all-city-types ()
  ;; do not count +city-type-random+ type 
  (loop for city-type-id from 1 below (length *city-types*) collect city-type-id))
