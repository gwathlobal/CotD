(in-package :cotd)

;;----------------------
;; TERRAIN-TYPE
;;----------------------
(defclass terrain-type ()
  ((id :initarg :id :accessor id :type fixnum)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name terrain" :initarg :name :accessor name)
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; :trait-blocks-move - +terrain-trait-blocks-move+
   ;; :trait-blocks-vision - +terrain-trait-blocks-vision+
   ))


(defun set-terrain-type (terrain-type)
  (setf (gethash (id terrain-type) *terrain-types*) terrain-type))

(defun get-terrain-type-by-id (terrain-type-id)
  (gethash terrain-type-id *terrain-types*))

(defmethod initialize-instance :after ((terrain-type terrain-type) &key trait-blocks-move trait-blocks-vision)
  
  (when trait-blocks-move
    (setf (gethash +terrain-trait-blocks-move+ (trait terrain-type)) t))
  (when trait-blocks-vision
    (setf (gethash +terrain-trait-blocks-vision+ (trait terrain-type)) t))
  )



(defun get-terrain-type-trait (terrain-type-id key)
  (gethash key (trait (get-terrain-type-by-id terrain-type-id))))

(defun get-terrain-name (terrain-type-id)
  (name (get-terrain-type-by-id terrain-type-id)))


