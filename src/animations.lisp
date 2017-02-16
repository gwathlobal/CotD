(in-package :cotd)

(defconstant +anim-type-fire-dot+ 0)

(defparameter *animation-types* (make-array (list 0) :adjustable t))

(defstruct (animation-type (:conc-name anim-type-))
  (id)
  (glyph-idx)
  (glyph-color)
  (back-color))

(defun set-anim-type (animation-type)
  (when (>= (anim-type-id animation-type) (length *animation-types*))
    (adjust-array *animation-types* (list (1+ (anim-type-id animation-type)))))
  (setf (aref *animation-types* (anim-type-id animation-type)) animation-type))

(defun get-anim-type (animation-type-id)
  (aref *animation-types* animation-type-id))

(defstruct (animation (:conc-name anim-))
  (id)
  (x)
  (y))

(set-anim-type (make-animation-type :id +anim-type-fire-dot+ :glyph-idx 10 :glyph-color (sdl:color :r 255 :g 140 :b 0) :back-color sdl:*black*))
