(in-package :cotd)

(defconstant +city-type-random+ 0)
(defconstant +city-type-normal-summer+ 1)
(defconstant +city-type-normal-winter+ 2)
(defconstant +city-type-river-summer+ 3)
(defconstant +city-type-river-winter+ 4)

(defparameter *city-types* (make-array (list 0) :adjustable t))

(defstruct city-type 
  (id)
  (return-max-buildings #'(lambda () nil) :type function)
  (return-reserv-buildings #'(lambda () nil) :type function)
  (process-reserve-func nil)
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

(defun place-city-river-e (reserved-level)
  (let ((max-x (1- (truncate (array-dimension reserved-level 0) 2)))
        (min-x 0))
    (loop for x from min-x below max-x
          for building-type-id = (if (and (zerop (mod (1+ x) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2))) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2)) building-type-id))))

(defun place-city-river-w (reserved-level)
  (let ((max-x (array-dimension reserved-level 0))
        (min-x (1- (truncate (array-dimension reserved-level 0) 2))))
    (loop for x from (+ min-x 2) below max-x
          for building-type-id = (if (and (zerop (mod (1+ (- x min-x)) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2))) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2)) building-type-id))))
           
(defun place-city-river-n (reserved-level)
  (let ((max-y (1- (truncate (array-dimension reserved-level 1) 2)))
        (min-y 0))
    (loop for y from min-y below max-y
          for building-type-id = (if (and (zerop (mod (1+ y) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y) building-type-id))))

(defun place-city-river-s (reserved-level)
  (let ((max-y (array-dimension reserved-level 1))
        (min-y (1- (truncate (array-dimension reserved-level 1) 2))))
    (loop for y from (+ min-y 2) below max-y
          for building-type-id = (if (and (zerop (mod (1+ (- y min-y)) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y) building-type-id))))

(defun place-city-river-center (reserved-level)
  (let ((x (1- (truncate (array-dimension reserved-level 0) 2)))
        (y (1- (truncate (array-dimension reserved-level 1) 2))))
    
    (setf (aref reserved-level (+ x 0) (+ y 0)) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 0)) +building-city-river+)
    (setf (aref reserved-level (+ x 0) (+ y 1)) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 1)) +building-city-river+)))
