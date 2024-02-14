(in-package :cotd)

(defconstant +anim-type-fire-dot+ 0)
(defconstant +anim-type-severed-body-part+ 1)
(defconstant +anim-type-rain-dot+ 2)
(defconstant +anim-type-acid-dot+ 3)

(defparameter *animation-types* (make-array (list 0) :adjustable t))

(defstruct (animation-type (:conc-name anim-type-))
  (id)
  (func))

(defun set-anim-type (animation-type)
  (when (>= (anim-type-id animation-type) (length *animation-types*))
    (adjust-array *animation-types* (list (1+ (anim-type-id animation-type)))))
  (setf (aref *animation-types* (anim-type-id animation-type)) animation-type))

(defun get-anim-type (animation-type-id)
  (aref *animation-types* animation-type-id))

(defstruct (animation (:conc-name anim-))
  (id)
  (x)
  (y)
  (z)
  (params))

(defun play-animation (animation)
  (funcall (anim-type-func (get-anim-type (anim-id animation))) animation))


