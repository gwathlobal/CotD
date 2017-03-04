(in-package :cotd)

;;----------------------
;; LEVEL
;;----------------------

(defclass level ()
  ((terrain :initform nil :accessor terrain :type simple-array) ; of type int, which is a idx of terrain-type
   (memo :initform nil :accessor memo :type simple-array) ; of type list containing (idx of glyph, color of glyph, color of background, visibility flag, revealed flag)
   (mobs :initform nil :accessor mobs :type simple-array) ; of type fixnum, which is the id of a mob
   (items :initform nil :accessor items :type simple-array) ; of type (<item id> ...)
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
        (setf (aref (mobs level) nx ny) (id mob))))))

(defun remove-mob-from-level-list (level mob)
  (setf (mob-id-list level) (remove (id mob) (mob-id-list level)))
  
  (let ((sx) (sy))
    (setf sx (- (x mob) (truncate (1- (map-size mob)) 2)))
    (setf sy (- (y mob) (truncate (1- (map-size mob)) 2)))
    
    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        (setf (aref (mobs level) nx ny) nil)))))

(defun add-feature-to-level-list (level feature)
  (pushnew (id feature) (feature-id-list level)))

(defun remove-feature-from-level-list (level feature)
  (setf (feature-id-list level) (remove (id feature) (feature-id-list level))))

(defun add-item-to-level-list (level item)
  (pushnew (id item) (item-id-list level))
  (push (id item) (aref (items level) (x item) (y item))))

(defun remove-item-from-level-list (level item)
  (setf (item-id-list level) (remove (id item) (item-id-list level)))
  (setf (aref (items level) (x item) (y item)) (remove (id item) (aref (items level) (x item) (y item)))))

(defun get-terrain-* (level x y)
  (when (or (< x 0) (>= x *max-x-level*)
            (< y 0) (>= y *max-y-level*))
    (return-from get-terrain-* nil))
  (aref (terrain level) x y))

(defun set-terrain-* (level x y terrain-type-id)
  (setf (aref (terrain level) x y) terrain-type-id))

(defun get-features-* (level x y)
  (let ((feature)
	(feature-list nil))
    (dolist (feature-id (feature-id-list level))
      (setf feature (get-feature-by-id feature-id))
      (when (and (= (x feature) x) (= (y feature) y))
	(setf feature-list (append feature-list (list feature)))))
    feature-list))

(defun get-mob-* (level x y)
  (when (or (< x 0) (>= x *max-x-level*)
            (< y 0) (>= y *max-y-level*))
    (return-from get-mob-* nil))
  (if (aref (mobs level) x y)
    (get-mob-by-id (aref (mobs level) x y))
    nil))

(defun get-items-* (level x y)
  (when (or (< x 0) (>= x *max-x-level*)
            (< y 0) (>= y *max-y-level*))
    (return-from get-items-* nil))
  (aref (items level) x y))

(defun get-memo-* (level x y)
  (aref (memo level) x y))
  
(defun set-memo-* (level x y single-memo)
  (setf (aref (memo level) x y) single-memo))

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

(defun set-single-memo-* (level x y &key (glyph-idx (get-single-memo-glyph-idx (get-memo-* level x y)))
                                         (glyph-color (get-single-memo-glyph-color (get-memo-* level x y))) 
                                         (back-color (get-single-memo-back-color (get-memo-* level x y))) 
                                         (visibility (get-single-memo-visibility (get-memo-* level x y)))
                                         (revealed (get-single-memo-revealed (get-memo-* level x y))))
  (set-memo-* level x y (create-single-memo glyph-idx glyph-color back-color visibility revealed)))

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

   (animation-queue :initform () :accessor animation-queue)
   ))
