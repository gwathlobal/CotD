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
   (on-step :initform nil :initarg :on-step :accessor on-step) ;; a function that takes (mob x y z)
   (on-use :initform nil :initarg :on-use :accessor on-use) ;; a funcation that takes (mob x y z)
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; :trait-blocks-move - +terrain-trait-blocks-move+
   ;; :trait-blocks-vision - +terrain-trait-blocks-vision+
   ;; :trait-blocks-projectiles - +terrain-trait-blocks-projectiles+
   ;; :trait-opaque-floor - +terrain-trait-opaque-floor+
   ;; :trait-slope-up - +terrain-trait-slope-up+
   ;; :trait-slope-down - +terrain-trait-slope-down+
   ;; :trait-not-climable - +terrain-trait-not-climable+
   ;; :trait-light-source - +terrain-trait-light-source+
   ;; :trait-blocks-sound - +terrain-trait-blocks-sound+
   ;; :trait-blocks-sound-floor - +terrain-trait-blocks-sound-floor+
   ;; :trait-water - +terrain-trait-water+
   ;; :trait-move-cost-factor - +terrain-trait-move-cost-factor+
   ))


(defun set-terrain-type (terrain-type)
  (when (>= (id terrain-type) (length *terrain-types*))
    (adjust-array *terrain-types* (list (1+ (id terrain-type)))))
  (setf (aref *terrain-types* (id terrain-type)) terrain-type))

(defun get-terrain-type-by-id (terrain-type-id)
  (aref *terrain-types* terrain-type-id))

(defmethod initialize-instance :after ((terrain-type terrain-type) &key trait-blocks-move trait-blocks-vision trait-blocks-projectiles trait-opaque-floor trait-slope-up trait-slope-down trait-not-climable trait-light-source
                                                                        trait-blocks-sound trait-blocks-sound-floor trait-water (trait-move-cost-factor 1))
  
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
  (when trait-blocks-sound
    (setf (gethash +terrain-trait-blocks-sound+ (trait terrain-type)) trait-blocks-sound))
  (when trait-blocks-sound-floor
    (setf (gethash +terrain-trait-blocks-sound-floor+ (trait terrain-type)) trait-blocks-sound-floor))
  (when trait-water
    (setf (gethash +terrain-trait-water+ (trait terrain-type)) trait-water))
  (when trait-move-cost-factor
    (setf (gethash +terrain-trait-move-cost-factor+ (trait terrain-type)) trait-move-cost-factor))
  )

(defun get-terrain-type-trait (terrain-type-id key)
  (gethash key (trait (get-terrain-type-by-id terrain-type-id))))

(defun get-terrain-name (terrain-type-id)
  (name (get-terrain-type-by-id terrain-type-id)))

(defun get-terrain-on-step (terrain-type-id)
  (on-step (get-terrain-type-by-id terrain-type-id)))

(defun get-terrain-on-use (terrain-type-id)
  (on-use (get-terrain-type-by-id terrain-type-id)))


