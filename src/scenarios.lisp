(in-package :cotd)

;;---------------------------------
;; SCENARIO-FEATURE-TYPE Constants
;;---------------------------------

(defconstant +scenario-feature-weather+ 0)
(defconstant +scenario-feature-city-layout+ 1)
(defconstant +scenario-feature-player-faction+ 2)
(defconstant +scenario-feature-time-of-day+ 3)

;;---------------------------------
;; SCENARIO-FEATURE Constants
;;---------------------------------

(defconstant +weather-type-clear+ 0)
(defconstant +weather-type-snow+ 1)
(defconstant +city-layout-test+ 2)
(defconstant +city-layout-normal+ 3)
(defconstant +city-layout-river+ 4)
(defconstant +city-layout-port+ 5)
(defconstant +player-faction-player+ 6)
(defconstant +player-faction-test+ 7)
(defconstant +player-faction-angels+ 8)
(defconstant +player-faction-demons+ 9)
(defconstant +city-layout-forest+ 10)
(defconstant +city-layout-island+ 11)
(defconstant +player-faction-military-chaplain+ 12)
(defconstant +city-layout-barricaded-city+ 13)
(defconstant +player-faction-military-scout+ 14)
(defconstant +tod-type-night+ 15)
(defconstant +tod-type-day+ 16)
(defconstant +tod-type-morning+ 17)
(defconstant +tod-type-evening+ 18)
(defconstant +player-faction-thief+ 19)

(defparameter *scenario-features* (make-array (list 0) :adjustable t))

(defstruct (scenario-feature (:conc-name sf-))
  (id)
  (name)
  (type)
  (debug nil :type boolean)
  (disabled nil :type boolean)
  (func nil))

(defun set-scenario-feature (scenario-feature)
  (when (>= (sf-id scenario-feature) (length *scenario-features*))
    (adjust-array *scenario-features* (list (1+ (sf-id scenario-feature)))))
  (setf (aref *scenario-features* (sf-id scenario-feature)) scenario-feature))

(defun get-scenario-feature-by-id (scenario-feature-id)
  (aref *scenario-features* scenario-feature-id))

(defun get-all-scenario-features-by-type (scenario-feature-type-id &optional (include-debug t))
  (loop for sf across *scenario-features*
        when (or (and (= (sf-type sf) scenario-feature-type-id)
                      include-debug
                      (not (sf-disabled sf)))
                 (and (= (sf-type sf) scenario-feature-type-id)
                      (not include-debug)
                      (not (sf-debug sf))
                      (not (sf-disabled sf))))
          collect (sf-id sf)))

;;---------------------------------
;; Get max buildings functions
;;---------------------------------

(defun get-max-buildings-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    max-building-types))

(defun get-max-buildings-river ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    max-building-types))

(defun get-max-buildings-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    max-building-types))

;;---------------------------------
;; Get reserved buildings functions
;;---------------------------------

(defun get-reserved-buildings-normal ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 2)
    reserved-building-types))

(defun get-reserved-buildings-river ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    reserved-building-types))

(defun get-reserved-buildings-port ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 0)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    reserved-building-types))

;;---------------------------------
;; Auxuliary scenario functions
;;---------------------------------

(defun place-city-river-e (reserved-level)
  (let ((max-x (1- (truncate (array-dimension reserved-level 0) 2)))
        (min-x 0))
    (loop for x from min-x below max-x
          for building-type-id = (if (and (zerop (mod (1+ x) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2)) 2) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2) 2) building-type-id))))

(defun place-city-river-w (reserved-level)
  (let ((max-x (array-dimension reserved-level 0))
        (min-x (1- (truncate (array-dimension reserved-level 0) 2))))
    (loop for x from (+ min-x 2) below max-x
          for building-type-id = (if (and (zerop (mod (1+ (- x min-x)) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2)) 2) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2) 2) building-type-id))))
           
(defun place-city-river-n (reserved-level)
  (let ((max-y (1- (truncate (array-dimension reserved-level 1) 2)))
        (min-y 0))
    (loop for y from min-y below max-y
          for building-type-id = (if (and (zerop (mod (1+ y) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y 2) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y 2) building-type-id))))

(defun place-city-river-s (reserved-level)
  (let ((max-y (array-dimension reserved-level 1))
        (min-y (1- (truncate (array-dimension reserved-level 1) 2))))
    (loop for y from (+ min-y 2) below max-y
          for building-type-id = (if (and (zerop (mod (1+ (- y min-y)) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y 2) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y 2) building-type-id))))

(defun place-city-river-center (reserved-level)
  (let ((x (1- (truncate (array-dimension reserved-level 0) 2)))
        (y (1- (truncate (array-dimension reserved-level 1) 2))))
    
    (setf (aref reserved-level (+ x 0) (+ y 0) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 0) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 0) (+ y 1) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 1) 2) +building-city-river+)))

(defun change-level-to-snow (template-level)
  (loop for x from 0 below (array-dimension template-level 0) do
    (loop for y from 0 below (array-dimension template-level 1) do
      (loop for z from (1- (array-dimension template-level 2)) downto 0 do
        (cond
          ((= (aref template-level x y z) +terrain-border-floor+) (setf (aref template-level x y z) +terrain-border-floor-snow+))
          ((= (aref template-level x y z) +terrain-border-grass+) (setf (aref template-level x y z) +terrain-border-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-dirt+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-dirt-bright+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-grass+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-tree-birch+) (setf (aref template-level x y z) +terrain-tree-birch-snow+))
          ((= (aref template-level x y z) +terrain-water-liquid+) (progn (setf (aref template-level x y z) +terrain-water-ice+)
                                                                         (when (< z (1- (array-dimension template-level 2)))
                                                                           (setf (aref template-level x y (1+ z)) +terrain-water-ice+))))
          ((= (aref template-level x y z) +terrain-floor-leaves+) (setf (aref template-level x y z) +terrain-floor-leaves-snow+))))))
  template-level)

(defun place-reserved-buildings-river (reserved-level)
  (let ((result) (r) (n nil) (s nil) (w nil) (e nil))
    (setf r (random 11))
    (cond
      ((= r 0) (setf w t e t))           ;; 0 - we
      ((= r 1) (setf n t s t))           ;; 1 - ns
      ((= r 2) (setf n t e t))           ;; 2 - ne
      ((= r 3) (setf n t w t))           ;; 3 - nw
      ((= r 4) (setf s t e t))           ;; 4 - se
      ((= r 5) (setf s t w t))           ;; 5 - sw
      ((= r 6) (setf n t w t e t))       ;; 6 - nwe
      ((= r 7) (setf s t w t e t))       ;; 7 - swe
      ((= r 8) (setf n t s t e t))       ;; 8 - nse
      ((= r 9) (setf n t s t w t))       ;; 9 - nsw
      ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe
    
    (when n (place-city-river-n reserved-level))
    (when s (place-city-river-s reserved-level))
    (when w (place-city-river-w reserved-level))
    (when e (place-city-river-e reserved-level))
    (place-city-river-center reserved-level)
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-river+)
                  (= (aref reserved-level x y 2) +building-city-bridge+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-port-n (reserved-level)
  (let ((result))
    (loop for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   +building-city-pier+
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level x 0 2) +building-city-sea+)
             (setf (aref reserved-level x 1 2) building-type-id)
             (setf (aref reserved-level x 2 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (push (list random-warehouse-1 x 3 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (push (list random-warehouse-2 x 5 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-port-s (reserved-level)
  (let ((result) (max-y (1- (array-dimension reserved-level 1))))
    (loop for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   +building-city-pier+
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level x (- max-y 0) 2) +building-city-sea+)
             (setf (aref reserved-level x (- max-y 1) 2) building-type-id)
             (setf (aref reserved-level x (- max-y 2) 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (push (list random-warehouse-1 x (- max-y 4) 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (push (list random-warehouse-2 x (- max-y 6) 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-port-e (reserved-level)
  (let ((result) (max-x (1- (array-dimension reserved-level 0))))
    (loop for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   +building-city-pier+
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level (- max-x 0) y 2) +building-city-sea+)
             (setf (aref reserved-level (- max-x 1) y 2) building-type-id)
             (setf (aref reserved-level (- max-x 2) y 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (push (list random-warehouse-1 (- max-x 4) y 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (push (list random-warehouse-2 (- max-x 6) y 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-port-w (reserved-level)
  (let ((result))
    (loop for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   +building-city-pier+
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          with z = 2
          do
             (setf (aref reserved-level 0 y z) +building-city-sea+)
             (setf (aref reserved-level 1 y z) building-type-id)
             (setf (aref reserved-level 2 y z) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 3 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 3 y z reserved-level)
               (push (list random-warehouse-1 3 y z) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 5 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 5 y z reserved-level)
               (push (list random-warehouse-2 5 y z) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun create-mobs-from-template (world mob-template-list)
  (loop for (mob-type-id x y z) in mob-template-list 
        do
           (add-mob-to-level-list (level world) (make-instance 'mob :mob-type mob-type-id :x x :y y :z z))))

(defun populate-world-with-mobs (world mob-template-list placement-func)
  (loop for (mob-template-id . num) in mob-template-list do
    (loop repeat num
          do
             (funcall placement-func world (make-instance 'mob :mob-type mob-template-id))))
  )

(defun adjust-initial-visibility (world mob-template-list)
  (declare (ignore mob-template-list))
  ;(format t "ADJUST-INITIAL-VISIBILITY~%")
  (loop for mob-id in (mob-id-list (level world))
        for mob = (get-mob-by-id mob-id)
        do
           (calculate-mob-vision-hearing mob)))

(defun find-unoccupied-place-around (world mob sx sy sz)
  (loop with min-x = sx
        with max-x = sx
        with min-y = sy
        with max-y = sy
        with max-x-level = (array-dimension (terrain (level *world*)) 0)
        with max-y-level = (array-dimension (terrain (level *world*)) 1)
        for cell-list = nil
        do
           ;; prepare the list of cells
           ;; north 
           (setf cell-list (append cell-list (loop with y = min-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; east
           (setf cell-list (append cell-list (loop with x = max-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))
           ;; south
           (setf cell-list (append cell-list (loop with y = max-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; west
           (setf cell-list (append cell-list (loop with x = min-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))

           ;; iterate through the list of cells
           (loop for (x . y) in cell-list
                 when (and (>= x 0) (< x max-x-level) (>= y 0) (< y max-y-level)
                           (eq (check-move-on-level mob x y sz) t)
                           ;(not (get-mob-* (level world) x y))
                           (get-terrain-type-trait (get-terrain-* (level world) x y sz) +terrain-trait-opaque-floor+)
                           (/= (get-level-connect-map-value (level world) x y sz (if (riding-mob-id mob)
                                                                                   (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                   (map-size mob))
                                                            (get-mob-move-mode mob))
                               +connect-room-none+))
                   do
                      (setf (x mob) x (y mob) y (z mob) sz)
                      (add-mob-to-level-list (level world) mob)
                      (return-from find-unoccupied-place-around mob))

           ;; if the loop is not over - increase the boundaries
           (decf min-x)
           (decf min-y)
           (incf max-x)
           (incf max-y)
           ))
 
(defun find-unoccupied-place-outside (world mob)
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (not (and (> x 7) (< x (- max-x 7)) (> y 7) (< y (- max-y 7))))
                   (eq (check-move-on-level mob x y z) t)
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-inside (world mob)
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (eq (check-move-on-level mob x y z) t)
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-on-top (world mob)
  ;(setf (z mob) (1- (array-dimension (terrain (level *world*)) 2)))
  
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        with nz = nil
        for x = (random max-x)
        for y = (random max-y)
        for z = (1- (array-dimension (terrain (level *world*)) 2))
        do
           (setf (x mob) x (y mob) y (z mob) z)
           (setf nz (apply-gravity mob)) 
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (get-terrain-type-trait (get-terrain-* (level world) x y nz) +terrain-trait-opaque-floor+)
                   nz
                   (> nz 2)
                   (eq (check-move-on-level mob x y nz) t)
                   (/= (get-level-connect-map-value (level world) x y nz (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+))
        finally (setf (x mob) x (y mob) y (z mob) nz)
                (add-mob-to-level-list (level world) mob)))

(defun place-reserved-buildings-forest (reserved-level)
  (let ((result))
    ;; place +building-city-park-tiny+ and +building-city-park-3+ along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-park-tiny+)
             (setf (aref reserved-level x (1- (array-dimension reserved-level 1)) 2) +building-city-park-tiny+)
             (when (level-city-can-place-build-on-grid +building-city-park-3+ x 1 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ x 1 2 reserved-level)
               (push (list +building-city-park-3+ x 1 2) result))
             (when (level-city-can-place-build-on-grid +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (push (list +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2) result)))
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-park-tiny+)
             (setf (aref reserved-level (1- (array-dimension reserved-level 0)) y 2) +building-city-park-tiny+)
             (when (level-city-can-place-build-on-grid +building-city-park-3+ 1 y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ 1 y 2 reserved-level)
               (push (list +building-city-park-3+ 1 y 2) result))
             (when (level-city-can-place-build-on-grid +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (push (list +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (= (aref reserved-level x y 2) +building-city-park-tiny+)
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-island (reserved-level)
  (let ((result))
    ;; place water along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-sea+)
             (setf (aref reserved-level x 1 2) +building-city-sea+)
             (setf (aref reserved-level x 2 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 1) 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 2) 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 3) 2) +building-city-sea+))
            
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-sea+)
             (setf (aref reserved-level 1 y 2) +building-city-sea+)
             (when (and (>= y 2) (<= y (- (array-dimension reserved-level 1) 3)))
               (setf (aref reserved-level 2 y 2) +building-city-sea+))
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 1) y 2) +building-city-sea+)
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) y 2) +building-city-sea+)
             (when (and (>= y 2) (<= y (- (array-dimension reserved-level 1) 3)))
               (setf (aref reserved-level (- (array-dimension reserved-level 0) 3) y 2) +building-city-sea+)))

    ;; place four piers - north, south, east, west
    (let ((min) (max) (r))
      ;; north
      (setf min 3 max (- (array-dimension reserved-level 0) 3))
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level r 1 2) +building-city-pier+)
      (setf (aref reserved-level r 2 2) +building-city-pier+)
      
      ;; south
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level r (- (array-dimension reserved-level 1) 2) 2) +building-city-pier+)
      (setf (aref reserved-level r (- (array-dimension reserved-level 1) 3) 2) +building-city-pier+)
      
      ;; west
      (setf min 3 max (- (array-dimension reserved-level 1) 3))
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level 1 r 2) +building-city-pier+)
      (setf (aref reserved-level 2 r 2) +building-city-pier+)

      ;; east
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level (- (array-dimension reserved-level 1) 2) r 2) +building-city-pier+)
      (setf (aref reserved-level (- (array-dimension reserved-level 1) 3) r 2) +building-city-pier+))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+)
                  (= (aref reserved-level x y 2) +building-city-island-ground-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-barricaded-city (reserved-level)
  (let ((result))
   
    (loop for x from 1 below (1- (array-dimension reserved-level 0))
          do
             (setf (aref reserved-level x 1 2) +building-city-barricade-we+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-we+))

     ;; making lines along the city borders - west & east
    (loop for y from 1 below (1- (array-dimension reserved-level 1))
          do
             (setf (aref reserved-level 1 y 2) +building-city-barricade-ns+)
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) y 2) +building-city-barricade-ns+))

    ;; making barricade corners
    (setf (aref reserved-level 1 1 2) +building-city-barricade-se+)
    (setf (aref reserved-level 1 (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-ne+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) 1 2) +building-city-barricade-sw+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-nw+)

    ;; making entrances to the city
    (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) 1 2) +building-city-reserved+)
    (setf (aref reserved-level 1 (truncate (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) (truncate (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) (- (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-barricade-ns+)
                  (= (aref reserved-level x y 2) +building-city-barricade-we+)
                  (= (aref reserved-level x y 2) +building-city-barricade-ne+)
                  (= (aref reserved-level x y 2) +building-city-barricade-se+)
                  (= (aref reserved-level x y 2) +building-city-barricade-sw+)
                  (= (aref reserved-level x y 2) +building-city-barricade-nw+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun set-up-outdoor-light (level light-power)
  (setf (outdoor-light level) light-power)

  ;; propagate light from above to determine which parts of the map are outdoor and which are "inside"
  ;; also set up all stationary light sources
  (loop for x from 0 below (array-dimension (light-map level) 0) do
    (loop for y from 0 below (array-dimension (light-map level) 1)
          for light-pwr = 100
          do
             (loop for z from (1- (array-dimension (light-map level) 2)) downto 0
                   do
                      (setf (aref (light-map level) x y z) light-pwr)
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+)
                        (setf light-pwr 0))
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+)
                        (add-light-source level (make-light-source x y z (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+))))
                   )))

  )
