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
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; :trait-blocks-vision - +feature-trait-blocks-vision+
   ;; :trait-smoke - +feature-trait-smoke+
   ;; :trait-no-gravity - +feature-trait-no-gravity+
   ;; :trait-fire - +feature-trait-fire+
   ;; :trait-remove-on-dungeon-generation - +feature-trait-remove-on-dungeon-generation+
   ;; :trait-can-have-rune - +feature-trait-can-have-rune+
   ;; :trait-demonic-rune - +feature-trait-demonic-rune+ (takes item-type-id that will be later used in deciphering the rune into an item)
   (can-merge-func :initform #'(lambda (level feature-new)
                                 (let ((result nil))
                                   (loop for feat-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                         for feat-old = (get-feature-by-id feat-old-id)
                                         when (= (feature-type feature-new) (feature-type feat-old))
                                           do
                                              (setf result t)
                                              (loop-finish)
                                         )
                                   result))
                   :initarg :can-merge-func :accessor can-merge-func)
   (merge-func :initform #'(lambda (level feature-new)
                             (loop for feat-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                   for feat-old = (get-feature-by-id feat-old-id)
                                   when (= (feature-type feature-new) (feature-type feat-old))
                                     do
                                        (remove-feature-from-level-list (level *world*) feature-new)
                                        (remove-feature-from-world feature-new)
                                        (loop-finish)
                                   )
                             )
               :initarg :merge-func :accessor merge-func)
   (on-tick-func :initform nil :initarg :on-tick-func :accessor on-tick-func) ;; a funcation that takes (level feature)
   ))

(defun get-feature-type-by-id (feature-type-id)
  (aref *feature-types* feature-type-id))

(defun set-feature-type (feature-type)
  (when (>= (id feature-type) (length *feature-types*))
    (adjust-array *feature-types* (list (1+ (id feature-type)))))
  (setf (aref *feature-types* (id feature-type)) feature-type))

(defmethod initialize-instance :after ((feature-type feature-type) &key trait-blocks-vision trait-smoke trait-no-gravity trait-fire trait-remove-on-dungeon-generation trait-demonic-rune)
  
  (when trait-blocks-vision
    (setf (gethash +feature-trait-blocks-vision+ (trait feature-type)) trait-blocks-vision))
  (when trait-smoke
    (setf (gethash +feature-trait-smoke+ (trait feature-type)) trait-smoke))
  (when trait-no-gravity
    (setf (gethash +feature-trait-no-gravity+ (trait feature-type)) trait-no-gravity))
  (when trait-fire
    (setf (gethash +feature-trait-fire+ (trait feature-type)) trait-fire))
  (when trait-remove-on-dungeon-generation
    (setf (gethash +feature-trait-remove-on-dungeon-generation+ (trait feature-type)) trait-remove-on-dungeon-generation))
  (when trait-demonic-rune
    (setf (gethash +feature-trait-demonic-rune+ (trait feature-type)) trait-demonic-rune))
  )

;;--------------------
;; FEATURE
;;--------------------

(defclass feature ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (feature-type :initform 0 :initarg :feature-type :accessor feature-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   (z :initarg :z :initform 0 :accessor z :type fixnum)
   (counter :initform 0 :initarg :counter :accessor counter :type fixnum)
   (param1 :initform nil :initarg :param1 :accessor param1)
   ))

(defmethod initialize-instance :after ((feature feature) &key)
  (setf (id feature) (find-free-id *lvl-features*))
  (setf (aref *lvl-features* (id feature)) feature)

  (when (and (zerop (counter feature))
             (or (get-feature-type-trait feature +feature-trait-smoke+)
                 (get-feature-type-trait feature +feature-trait-fire+)))
    (setf (counter feature) 1))
  )

(defun get-feature-by-id (feature-id)
  (aref *lvl-features* feature-id))

(defun remove-feature-from-world (feature)
  (setf (feature-id-list (level *world*)) (remove (id feature) (feature-id-list (level *world*))))
  (setf (aref *lvl-features* (id feature)) nil))

(defmethod name ((feature feature))
  (name (get-feature-type-by-id (feature-type feature))))

(defmethod on-tick-func ((feature feature))
  (on-tick-func (get-feature-type-by-id (feature-type feature))))

(defmethod can-merge-func ((feature feature))
  (can-merge-func (get-feature-type-by-id (feature-type feature))))

(defmethod merge-func ((feature feature))
  (merge-func (get-feature-type-by-id (feature-type feature))))

(defun get-feature-type-trait (feature feature-trait-id)
  (gethash feature-trait-id (trait (get-feature-type-by-id (feature-type feature)))))

(defun feature-smoke-on-tick (level feature)
  (when (zerop (random 3))
    (if (= (counter feature) 1)
      (progn
        (if (zerop (random 2))
          (progn
            (remove-feature-from-level-list level feature)
            (remove-feature-from-world feature))
          (progn
            (let ((dir (1+ (random 9)))
                  (dir-z (1- (random 3)))
                  (dx) (dy))
              (cond
                ((= dir-z -1) (when (and (not (zerop (z feature)))
                                         (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-move-floor+))
                                         (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-move+))
                                         (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-projectiles+)))
                                (remove-feature-from-level-list level feature)
                                (decf (z feature))
                                (add-feature-to-level-list level feature)))
                ((= dir-z 1) (when (and (< (z feature) (1- (array-dimension (terrain level) 2)))
                                        (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-move-floor+))
                                        (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-move+))
                                        (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-projectiles+)))
                                (remove-feature-from-level-list level feature)
                                (incf (z feature))
                                (add-feature-to-level-list level feature)))
                (t (if (= (wind-dir level) 5)
                     (multiple-value-setq (dx dy) (x-y-dir dir))
                     (multiple-value-setq (dx dy) (x-y-dir (wind-dir level))))
                   (setf dx (+ (x feature) dx) dy (+ (y feature) dy))
                   (when (and (not (get-terrain-type-trait (get-terrain-* level dx dy (z feature)) +terrain-trait-blocks-move+))
                              (not (get-terrain-type-trait (get-terrain-* level dx dy (z feature)) +terrain-trait-blocks-projectiles+)))
                     (remove-feature-from-level-list level feature)
                     (setf (x feature) dx)
                     (setf (y feature) dy)
                     (add-feature-to-level-list level feature))))
              ))))
      (progn
        (let ((feature-new nil)
              (dir (1+ (random 9)))
              (dir-z (1- (random 3)))
              (dx) (dy))
          (cond
            ((= dir-z -1) (when (and (not (zerop (z feature)))
                                     (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-move-floor+))
                                     (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-move+))
                                     (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (z feature)) +terrain-trait-blocks-projectiles+)))
                            (setf feature-new (make-instance 'feature :feature-type (get-feature-type-trait feature +feature-trait-smoke+) :x (x feature) :y (y feature) :z (z feature)))
                            (decf (counter feature))
                            (decf (z feature-new))
                            (add-feature-to-level-list level feature-new)))
            ((= dir-z 1) (when (and (< (z feature) (1- (array-dimension (terrain level) 2)))
                                    (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-move-floor+))
                                    (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-move+))
                                    (not (get-terrain-type-trait (get-terrain-* level (x feature) (y feature) (1+ (z feature))) +terrain-trait-blocks-projectiles+)))
                           (setf feature-new (make-instance 'feature :feature-type (get-feature-type-trait feature +feature-trait-smoke+) :x (x feature) :y (y feature) :z (z feature)))
                           (decf (counter feature))
                           (incf (z feature-new))
                           (add-feature-to-level-list level feature-new)))
            (t (multiple-value-setq (dx dy) (x-y-dir dir))
               (setf dx (+ (x feature) dx) dy (+ (y feature) dy))
               (when (and (not (get-terrain-type-trait (get-terrain-* level dx dy (z feature)) +terrain-trait-blocks-move+))
                          (not (get-terrain-type-trait (get-terrain-* level dx dy (z feature)) +terrain-trait-blocks-projectiles+)))
                 (setf feature-new (make-instance 'feature :feature-type (get-feature-type-trait feature +feature-trait-smoke+) :x (x feature) :y (y feature) :z (z feature)))
                 (decf (counter feature))
                 (setf (x feature-new) dx)
                 (setf (y feature-new) dy)
                 (add-feature-to-level-list level feature-new))))
          )))))
