(in-package :cotd)

;;----------------------
;; LEVEL
;;----------------------

(defclass level ()
  ((terrain :initform nil :accessor terrain :type simple-array) ; of type int, which is a idx of terrain-type
   (memo :initform nil :accessor memo :type simple-array) ; of type list containing (idx of glyph, color of glyph, color of background, visibility flag, revealed flag)
   (mobs :initform nil :accessor mobs :type simple-array) ; of type fixnum, which is the id of a mob
   (items :initform nil :accessor items :type simple-array) ; of type (<item id> ...)
   (features :initform nil :accessor features :type simple-array) ; of type (<feature id> ...)
   (mob-id-list :initarg :mob-id-list :initform (make-list 0) :accessor mob-id-list)
   (item-id-list :initarg :item-id-list :initform (make-list 0) :accessor item-id-list)
   (feature-id-list :initarg :feature-id-list :initform (make-list 0) :accessor feature-id-list)
   (connect-map :initform (make-array '(6) :initial-element nil) :accessor connect-map :type simple-array) ; an array that holds connection maps (which are arrays themselves) for all sizes of mobs,
                                                                                                           ; note that sizes can only be odd numbers, so some indices of the array will hold nil 
   ))
   
(defun add-mob-to-level-list (level mob)
  (pushnew (id mob) (mob-id-list level))
  
  (let ((sx) (sy))
    (setf sx (- (x mob) (truncate (1- (map-size mob)) 2)))
    (setf sy (- (y mob) (truncate (1- (map-size mob)) 2)))
    
    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        (setf (aref (mobs level) nx ny (z mob)) (id mob)))))

  (when (apply-gravity mob)
      (let ((init-z (z mob)) (cur-dmg 0))
        (set-mob-location mob (x mob) (y mob) (apply-gravity mob))
        (setf cur-dmg (* 5 (1- (- init-z (z mob)))))
        (decf (cur-hp mob) cur-dmg)
        (when (> cur-dmg 0)
          (print-visible-message (x mob) (y mob) (z mob) level
                                 (format nil "~A falls and takes ~A damage. " (visible-name mob) cur-dmg)))
        (when (check-dead mob)
          (make-dead mob :splatter t :msg t :msg-newline nil :killer nil :corpse t :aux-params ())))))

(defun remove-mob-from-level-list (level mob)
  (setf (mob-id-list level) (remove (id mob) (mob-id-list level)))
  
  (let ((sx) (sy))
    (setf sx (- (x mob) (truncate (1- (map-size mob)) 2)))
    (setf sy (- (y mob) (truncate (1- (map-size mob)) 2)))
    
    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        (setf (aref (mobs level) nx ny (z mob)) nil)))))

(defun add-feature-to-level-list (level feature)
  (pushnew (id feature) (feature-id-list level))
  (push (id feature) (aref (features level) (x feature) (y feature) (z feature)))

  (when (apply-gravity feature)
    (remove-feature-from-level-list level feature)
    (setf (z feature) (apply-gravity feature))
    (add-feature-to-level-list level feature)))

(defun remove-feature-from-level-list (level feature)
  (setf (feature-id-list level) (remove (id feature) (feature-id-list level)))
  (setf (aref (features level) (x feature) (y feature) (z feature)) (remove (id feature) (aref (features level) (x feature) (y feature) (z feature)))))

(defun add-item-to-level-list (level item)
  (pushnew (id item) (item-id-list level))
  (push (id item) (aref (items level) (x item) (y item) (z item)))

  (when (apply-gravity item)
    (remove-item-from-level-list level item)
    (setf (z item) (apply-gravity item))
    (add-item-to-level-list level item)))

(defun remove-item-from-level-list (level item)
  (setf (item-id-list level) (remove (id item) (item-id-list level)))
  (setf (aref (items level) (x item) (y item) (z item)) (remove (id item) (aref (items level) (x item) (y item) (z item)))))

(defun get-terrain-* (level x y z)
  (when (or (< x 0) (>= x (array-dimension (terrain level) 0))
            (< y 0) (>= y (array-dimension (terrain level) 1))
            (< z 0) (>= z (array-dimension (terrain level) 2)))
    (return-from get-terrain-* nil))
  (aref (terrain level) x y z))

(defun set-terrain-* (level x y z terrain-type-id)
  (setf (aref (terrain level) x y z) terrain-type-id))

(defun get-features-* (level x y z)
  (when (or (< x 0) (>= x (array-dimension (items level) 0))
            (< y 0) (>= y (array-dimension (items level) 1))
            (< z 0) (>= z (array-dimension (items level) 2)))
    (return-from get-features-* nil))
  (aref (features level) x y z))

(defun get-mob-* (level x y z)
  (when (or (< x 0) (>= x (array-dimension (mobs level) 0))
            (< y 0) (>= y (array-dimension (mobs level) 1))
            (< z 0) (>= z (array-dimension (mobs level) 2)))
    (return-from get-mob-* nil))
  (if (aref (mobs level) x y z)
    (get-mob-by-id (aref (mobs level) x y z))
    nil))

(defun get-items-* (level x y z)
  (when (or (< x 0) (>= x (array-dimension (items level) 0))
            (< y 0) (>= y (array-dimension (items level) 1))
            (< z 0) (>= z (array-dimension (items level) 2)))
    (return-from get-items-* nil))
  (aref (items level) x y z))

(defun get-memo-* (level x y z)
  (aref (memo level) x y z))
  
(defun set-memo-* (level x y z single-memo)
  (setf (aref (memo level) x y z) single-memo))

(defun create-single-memo (glyph-idx glyph-color back-color visibility revealed)
  (list glyph-idx glyph-color back-color visibility revealed))

(defun get-single-memo-glyph-idx (single-memo)
  (nth 0 single-memo))

(defun get-single-memo-glyph-color (single-memo)
  (nth 1 single-memo))

(defun get-single-memo-back-color (single-memo)
  (nth 2 single-memo))

(defun get-single-memo-visibility (single-memo)
  (nth 3 single-memo))

(defun get-single-memo-revealed (single-memo)
  (nth 4 single-memo))

(defun set-single-memo-* (level x y z &key (glyph-idx (get-single-memo-glyph-idx (get-memo-* level x y z)))
                                           (glyph-color (get-single-memo-glyph-color (get-memo-* level x y z))) 
                                           (back-color (get-single-memo-back-color (get-memo-* level x y z))) 
                                           (visibility (get-single-memo-visibility (get-memo-* level x y z)))
                                           (revealed (get-single-memo-revealed (get-memo-* level x y z))))
  (set-memo-* level x y z (create-single-memo glyph-idx glyph-color back-color visibility revealed)))

;;----------------------
;; WORLD
;;----------------------

(defclass world ()
  ((player-game-time :initform 0 :accessor player-game-time)
   (real-game-time :initform 0 :accessor real-game-time)
   (turn-finished :initform nil :accessor turn-finished)
   
   (level :initform nil :accessor level :type level)
   
   (initial-humans :initform 0 :accessor initial-humans)
   (initial-demons :initform 0 :accessor initial-demons)
   (initial-angels :initform 0 :accessor initial-angels)
   
   (total-humans :initform 0 :accessor total-humans)
   (total-demons :initform 0 :accessor total-demons)
   (total-angels :initform 0 :accessor total-angels)
   (total-blessed :initform 0 :accessor total-blessed)

   (game-events :initform () :accessor game-events)

   (cur-mob-path :initform 0 :accessor cur-mob-path)
   (path-lock :initform (bt:make-lock) :accessor path-lock)
   (path-cv :initform (bt:make-condition-variable) :accessor path-cv)

   (cur-mob-fov :initform 0 :accessor cur-mob-fov)
   (fov-lock :initform (bt:make-lock) :accessor fov-lock)
   (fov-cv :initform (bt:make-condition-variable) :accessor fov-cv)

   (animation-queue :initform () :accessor animation-queue)
   ))
