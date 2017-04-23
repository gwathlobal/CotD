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
   (aux-connect-map :initform (make-array '(6) :initial-element nil) :accessor aux-connect-map :type simple-array) ; an array that holds hash maps for all sizes of mobs (same as connect-map)
                                                                                                                   ; hash-maps hold connections between different rooms 
                                                                                                                   ; (so that opening/closing of doors does not require flood fills)
   (light-map :accessor light-map)
   (outdoor-light :initform 0 :accessor outdoor-light)
   (light-sources :initform (make-array '(0) :adjustable t) :accessor light-sources)
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
        (set-mob-location mob (x mob) (y mob) (apply-gravity mob) :apply-gravity nil)
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
  (if (apply-gravity item)
    (progn
      (setf (z item) (apply-gravity item))
      (setf (aref (items level) (x item) (y item) (z item))
            (add-to-inv item (aref (items level) (x item) (y item) (z item)) nil)))
    (progn
      (setf (aref (items level) (x item) (y item) (z item))
            (add-to-inv item (aref (items level) (x item) (y item) (z item)) nil)))))

(defun remove-item-from-level-list (level item)
  (setf (item-id-list level) (remove (id item) (item-id-list level)))
  (setf (aref (items level) (x item) (y item) (z item))
        (remove-from-inv item (aref (items level) (x item) (y item) (z item))))
  item)

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

(defun get-connect-map-value (connect-map x y z move-mode)
  (let ((move-mode-array (aref connect-map x y z)))
    ;(format t "GET ~A, MOVE-MODE ~A, LENGTH ~A~%" move-mode-array move-mode (length move-mode-array))
    (unless move-mode-array
      (return-from get-connect-map-value -1))
    (when (>= move-mode (length move-mode-array))
      (return-from get-connect-map-value -1))
    (unless (aref move-mode-array move-mode)
      (return-from get-connect-map-value -1))
    
    (aref move-mode-array move-mode)
    ))

(defun get-level-connect-map-value (level x y z map-size move-mode)
  (when (or (zerop map-size)
            (evenp map-size))
    (error "GET-CONNECT-MAP-SIZE: Map size should be an odd number"))
  (let ((move-mode-array (aref (aref (connect-map level) map-size) x y z)))
    (unless move-mode-array
      (return-from get-level-connect-map-value -1))
    (when (>= move-mode (length move-mode-array))
      (return-from get-level-connect-map-value -1))
    (unless (aref move-mode-array move-mode)
      (return-from get-level-connect-map-value -1))
    
    (aref move-mode-array move-mode)
    ))

(defun set-connect-map-value (connect-map x y z move-mode value)

  ;; we assume that the connect map arrays have been created
  (unless (aref connect-map x y z)
    (setf (aref connect-map x y z) (make-array (list (1+ move-mode)) :initial-element -1 :adjustable t)))
   
  (let ((move-mode-array (aref connect-map x y z)))
    (when (>= move-mode (length move-mode-array))
      (adjust-array move-mode-array (list (1+ move-mode))))
    ;(format t "SET ~A, MOVE-MODE ~A, LENGTH ~A~%" move-mode-array move-mode (length move-mode-array))
    (setf (aref move-mode-array move-mode) value)
    )
  )

(defun level-cells-connected-p (level sx sy sz tx ty tz map-size move-mode)
  (let ((connect-map-value-start (get-level-connect-map-value level sx sy sz map-size move-mode))
        (connect-map-value-end (get-level-connect-map-value level tx ty tz map-size move-mode)))
    (if (or (= connect-map-value-start connect-map-value-end)
            (level-aux-map-connect-p level connect-map-value-start connect-map-value-end map-size move-mode))
      t
      nil))
  )

(defun level-aux-map-connect-p (level room-id-start room-id-end map-size move-mode)
  ;; TODO: add recursion so that it could be possible to connect rooms through several intermediate connections
  (unless (aref (aux-connect-map level) map-size)
    (return-from level-aux-map-connect-p nil))
  (unless (aref (aref (aux-connect-map level) map-size) move-mode)
    (return-from level-aux-map-connect-p nil))
  
  (let ((connect-list (aref (aref (aux-connect-map level) map-size) move-mode)))
    (if (find-if #'(lambda (a)
                     (if (or (and (= (first a) room-id-start) (= (second a) room-id-end))
                             (and (= (first a) room-id-end) (= (second a) room-id-start)))
                       t
                       nil))
                 connect-list)
      t
      nil)))

(defun set-aux-map-connection (level room-id-start room-id-end map-size move-mode)
  (unless (aref (aux-connect-map level) map-size)
    (setf (aref (aux-connect-map level) map-size) (make-array (list (1+ move-mode)) :initial-element nil :adjustable t)))
  (when (>= move-mode (length (aref (aux-connect-map level) map-size)))
    (adjust-array (aref (aux-connect-map level) map-size) (list (1+ move-mode)) :initial-element nil))
  ;(unless (aref (aref (aux-connect-map level) map-size) move-mode)
  ;  (setf (aref (aref (aux-connect-map level) map-size) move-mode) (make-hash-table)))
  (let* ((connect-list (aref (aref (aux-connect-map level) map-size) move-mode))
         (connection (find-if #'(lambda (a)
                                  (if (or (and (= (first a) room-id-start) (= (second a) room-id-end))
                                          (and (= (first a) room-id-end) (= (second a) room-id-start)))
                                    t
                                    nil))
                              connect-list)))
    ;; connection is (<room-id-start> <room-id-end> <number of links between rooms>)
    (if connection
      (progn
        (incf (third connection)))
      (progn
        (push (list room-id-start room-id-end 1) (aref (aref (aux-connect-map level) map-size) move-mode))))
    ))

(defun delete-aux-map-connection (level room-id-start room-id-end map-size move-mode)
  (unless (aref (aux-connect-map level) map-size)
    (setf (aref (aux-connect-map level) map-size) (make-array (list (1+ move-mode)) :initial-element nil :adjustable t)))
  (when (>= move-mode (length (aref (aux-connect-map level) map-size)))
    (adjust-array (aref (aux-connect-map level) map-size) (list (1+ move-mode))))
  ;(unless (aref (aref (aux-connect-map level) map-size) move-mode)
  ;  (setf (aref (aref (aux-connect-map level) map-size) move-mode) (make-hash-table)))
  (let* ((connect-list (aref (aref (aux-connect-map level) map-size) move-mode))
         (connection (find-if #'(lambda (a)
                                  (if (or (and (= (first a) room-id-start) (= (second a) room-id-end))
                                          (and (= (first a) room-id-end) (= (second a) room-id-start)))
                                    t
                                    nil))
                              connect-list)))
    (when connection
      (decf (third connection))
      (when (zerop (third connection))
        (setf (aref (aref (aux-connect-map level) map-size) move-mode)
              (remove connection connect-list))))
    ))

(defun get-outdoor-light-* (level x y z)
  ;(format t "GET-OUTDOOR-LIGHT: ~A ~A ~A ~A" level x y z)
  (truncate (* (outdoor-light level)
               (aref (light-map level) x y z))
            100))

(defun make-light-source (x y z light-radius)
  (list x y z light-radius))

(defun add-light-source (level light-source)
  (adjust-array (light-sources level) (list (1+ (length (light-sources level)))))
  (setf (aref (light-sources level) (1- (length (light-sources level)))) light-source))

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

;;----------------------
;; DATE
;;----------------------

(defun get-current-date-time (date-time)
  (let ((year 0)
        (month 0)
        (day 0)
        (hour 0)
        (min 0)
        (sec 0))
    (multiple-value-setq (year month) (truncate (* date-time 6) (* 12 30 24 60 60)))
    (multiple-value-setq (month day) (truncate month (* 30 24 60 60)))
    (multiple-value-setq (day hour) (truncate day (* 24 60 60)))
    (multiple-value-setq (hour min) (truncate hour (* 60 60)))
    (multiple-value-setq (min sec) (truncate min 60))
    (values year month day hour min sec)))

(defun set-current-date-time (year month day hour min sec)
  (let ((date-time 0))
    (incf date-time (truncate (* year 12 30 24 60 60) 6))
    (incf date-time (truncate (* month 30 24 60 60) 6))
    (incf date-time (truncate (* day 24 60 60) 6))
    (incf date-time (truncate (* hour 60 60) 6))
    (incf date-time (truncate (* min 60) 6))
    (incf date-time (truncate sec 6))
    date-time))

(defun show-date-time-short (date-time)
  (multiple-value-bind (year month day hour min sec) (get-current-date-time date-time)
    (format nil "~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d" year (1+ month) (1+ day) hour min sec)))
