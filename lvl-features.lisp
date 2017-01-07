(in-package :cotd)

;;----------------------
;; FEATURE-TYPE
;;----------------------

(defclass feature-type ()
  ((id :initarg :id :accessor id :type fixnum)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name feature" :initarg :name :accessor name)
   (func :initform nil :initarg :func :accessor func)))

(defun get-feature-type-by-id (feature-type-id)
  (gethash feature-type-id *feature-types*))

(defun set-feature-type (feature-type)
  (setf (gethash (id feature-type) *feature-types*) feature-type))

;;--------------------
;; FEATURE
;;--------------------

(defclass feature ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (feature-type :initform 0 :initarg :feature-type :accessor feature-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   ))

(defmethod initialize-instance :after ((feature feature) &key)
  (setf (id feature) (find-free-id *lvl-features*))
  (setf (gethash (id feature) *lvl-features*) feature)
  )

(defun get-feature-by-id (feature-id)
  (gethash feature-id *lvl-features*))

(defmethod name ((feature feature))
  (name (get-feature-type-by-id (feature-type feature))))

(defmethod func ((feature feature))
  (func (get-feature-type-by-id (feature-type feature))))
