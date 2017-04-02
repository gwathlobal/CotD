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
   (on-step :initform nil :initarg :on-step :accessor on-step)
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; :trait-blocks-move - +terrain-trait-blocks-move+
   ;; :trait-blocks-vision - +terrain-trait-blocks-vision+
   ;; :trait-blocks-projectiles - +terrain-trait-blocks-projectiles+
   ;; :trait-opaque-floor - +terrain-trait-opaque-floor+
   ;; :trait-slope-up - +terrain-trait-slope-up+
   ;; :trait-slope-down - +terrain-trait-slope-down+
   ;; :trait-not-climable - +terrain-trait-not-climable+
   ;; :trait-light-source - +terrain-trait-light-source+
   ))


(defun set-terrain-type (terrain-type)
  (when (>= (id terrain-type) (length *terrain-types*))
    (adjust-array *terrain-types* (list (1+ (id terrain-type)))))
  (setf (aref *terrain-types* (id terrain-type)) terrain-type))

(defun get-terrain-type-by-id (terrain-type-id)
  (aref *terrain-types* terrain-type-id))

(defmethod initialize-instance :after ((terrain-type terrain-type) &key trait-blocks-move trait-blocks-vision trait-blocks-projectiles trait-opaque-floor trait-slope-up trait-slope-down trait-not-climable trait-light-source)
  
  (when trait-blocks-move
    (setf (gethash +terrain-trait-blocks-move+ (trait terrain-type)) t))
  (when trait-blocks-vision
    (setf (gethash +terrain-trait-blocks-vision+ (trait terrain-type)) t))
  (when trait-blocks-projectiles
    (setf (gethash +terrain-trait-blocks-projectiles+ (trait terrain-type)) t))
  (when trait-opaque-floor
    (setf (gethash +terrain-trait-opaque-floor+ (trait terrain-type)) t))
  (when trait-slope-up
    (setf (gethash +terrain-trait-slope-up+ (trait terrain-type)) t))
  (when trait-slope-down
    (setf (gethash +terrain-trait-slope-down+ (trait terrain-type)) t))
  (when trait-not-climable
    (setf (gethash +terrain-trait-not-climable+ (trait terrain-type)) t))
  (when trait-light-source
    (setf (gethash +terrain-trait-light-source+ (trait terrain-type)) trait-light-source))
  )

(defun get-terrain-type-trait (terrain-type-id key)
  (gethash key (trait (get-terrain-type-by-id terrain-type-id))))

(defun get-terrain-name (terrain-type-id)
  (name (get-terrain-type-by-id terrain-type-id)))


