(in-package :cotd)

(defclass item-type ()
  ((id :initarg :id :accessor id)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name item" :initarg :name :accessor name)))

(defun get-item-type-by-id (mob-type-id)
  (aref *item-types* mob-type-id))

(defun set-item-type (item-type)
  (when (>= (id item-type) (length *item-types*))
    (adjust-array *item-types* (list (1+ (id item-type)))))
  (setf (aref *item-types* (id item-type)) item-type))

(defclass item ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (name :initform nil :accessor name)
   (item-type :initform 0 :initarg :item-type :accessor item-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   (z :initarg :z :initform 0 :accessor z :type fixnum)))

(defmethod initialize-instance :after ((item item) &key)
  (setf (id item) (find-free-id *items*))
  (setf (aref *items* (id item)) item)

  (setf (name item) (format nil "~A" (name (get-item-type-by-id (item-type item)))))
  )

(defun get-item-by-id (item-id)
  (aref *items* item-id))

(defmethod glyph-idx ((item item))
  (glyph-idx (get-item-type-by-id (item-type item))))

(defmethod glyph-color ((item item))
  (glyph-color (get-item-type-by-id (item-type item))))

(defmethod back-color ((item item))
  (back-color (get-item-type-by-id (item-type item))))
