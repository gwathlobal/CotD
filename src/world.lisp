(in-package :cotd)

;;----------------------
;; LEVEL
;;----------------------

(defclass level ()
  ((player-game-time :initform 0 :accessor player-game-time)

   (terrain :initform nil :accessor terrain :type (or simple-array null)) ; of type int, which is a idx of terrain-type
   (memo :initform nil :accessor memo :type (or simple-array null)) ; of type list containing (idx of glyph, color of glyph, color of background, visibility flag, revealed flag)
   (mobs :initform nil :accessor mobs :type (or simple-array null)) ; of type fixnum, which is the id of a mob
   (items :initform nil :accessor items :type (or simple-array null)) ; of type (<item id> ...)
   (features :initform nil :accessor features :type (or simple-array null)) ; of type (<feature id> ...)
   (mob-id-list :initarg :mob-id-list :initform (make-list 0) :accessor mob-id-list)
   (item-id-list :initarg :item-id-list :initform (make-list 0) :accessor item-id-list)
   (feature-id-list :initarg :feature-id-list :initform (make-list 0) :accessor feature-id-list)
   (connect-map :initform (make-array '(6) :initial-element nil) :accessor connect-map :type simple-array) ; an array that holds connection maps (which are arrays themselves) for all sizes of mobs,
                                                                                                           ; note that sizes can only be odd numbers, so some indices of the array will hold nil 
   (aux-connect-map :initform (make-array '(6) :initial-element nil) :accessor aux-connect-map :type simple-array) ; an array that holds hash maps for all sizes of mobs (same as connect-map)
                                                                                                                   ; hash-maps hold connections between different rooms 
                                                                                                                   ; (so that opening/closing of doors does not require flood fills)
   (animation-queue :initform () :accessor animation-queue)
   
   (light-map :accessor light-map)
   (outdoor-light :initform 0 :accessor outdoor-light)
   (light-sources :initform (make-array '(0) :adjustable t) :accessor light-sources)
   (wind-dir :initform 5 :initarg :wind-dir :accessor wind-dir)
   (level-layout :initform 0 :initarg :level-layout :accessor level-layout)
   (mission-scenario :initform nil :initarg :mission-scenario :accessor mission-scenario)
   (delayed-arrival-points :initform () :initarg :delayed-arrival-points :accessor delayed-arrival-points) ;; is of type ((x y z) (...) ...)
   (delayed-demons-arrival-points :initform () :initarg :delayed-demons-arrival-points :accessor delayed-demons-arrival-points) ;; is of type ((x y z) (...) ...)
   (delayed-angels-arrival-points :initform () :initarg :delayed-angels-arrival-points :accessor delayed-angels-arrival-points) ;; is of type ((x y z) (...) ...)
   (delayed-military-arrival-points :initform () :initarg :delayed-military-arrival-points :accessor delayed-military-arrival-points) ;; is of type ((x y z) (...) ...)

   (game-events :initform () :accessor game-events)

   (demonic-portals :initform () :initarg :demonic-portals :accessor demonic-portals)
   (relic-id :initform nil :initarg :relic-id :accessor level/relic-id)
   (book-id :initform nil :initarg :book-id :accessor level/book-id)
   (demonic-sigils :initform () :initarg :demonic-sigils :accessor demonic-sigils)
   (demonic-machines :initform () :initarg :demonic-machines :accessor demonic-machines)
   (bomb-plant-locations :initform () :initarg :bomb-plant-locations :accessor bomb-plant-locations)
   (mob-quadrant-map :initform nil :initarg :mob-quadrant-map :accessor mob-quadrant-map)
   (item-quadrant-map :initform nil :initarg :item-quadrant-map :accessor item-quadrant-map)
   (light-quadrant-map :initform nil :initarg :light-quadrant-map :accessor light-quadrant-map)

   (world-sector :initform nil :accessor world-sector)
   (mission :initform nil :accessor mission)

   (mission-result :initform nil :accessor level/mission-result :type list)
   
   (lost-civilians :initform 0 :accessor lost-civilians)
   (initial-civilians :initform 0 :accessor initial-civilians)

   (initial-humans :initform 0 :accessor initial-humans)
   (initial-demons :initform 0 :accessor initial-demons)
   (initial-angels :initform 0 :accessor initial-angels)
   (initial-undead :initform 0 :accessor initial-undead)
   
   (total-humans :initform 0 :accessor total-humans)
   (total-demons :initform 0 :accessor total-demons)
   (total-angels :initform 0 :accessor total-angels)
   (total-blessed :initform 0 :accessor total-blessed)
   (total-undead :initform 0 :accessor total-undead)
   (total-faction-list :initform (loop for faction across *faction-types* collect 0) :accessor total-faction-list)

   (turns-for-delayed-angels :initform 220 :accessor turns-for-delayed-angels)
   (turns-for-delayed-demons :initform 220 :accessor turns-for-delayed-demons)
   (turns-for-delayed-military :initform 220 :accessor turns-for-delayed-military)

   (full-message-box :initform (make-message-box) :accessor level/full-message-box :type message-box)
   (small-message-box :initform (make-message-box) :accessor level/small-message-box :type message-box)

   (scenario-ended :initform nil :accessor level/scenario-ended :type boolean)
   )) 
   
(defun add-mob-to-level-list (level mob &optional (apply-gravity t))

  (when (riding-mob-id mob)
    (let ((mount (get-mob-by-id (riding-mob-id mob))))
      (setf (x mount) (x mob) (y mount) (y mob) (z mount) (z mob))
      (add-mob-to-level-list level (get-mob-by-id (riding-mob-id mob)) nil)))

  (unless (initial-added mob)
    (setf (initial-added mob) t)

    (when (mob-ability-p mob +mob-abil-human+)
      (incf (initial-humans (level *world*))))

    (when (mob-ability-p mob +mob-abil-civilian+)
      (incf (initial-civilians (level *world*))))

    (when (mob-ability-p mob +mob-abil-demon+)
      (incf (initial-demons (level *world*))))

    (when (mob-ability-p mob +mob-abil-undead+)
      (incf (initial-undead (level *world*))))

    (when (and (mob-ability-p mob +mob-abil-angel+)
               (not (mob-ability-p mob +mob-abil-animal+)))
      (incf (initial-angels (level *world*))))
    )

  (when (not (find (id mob) (mob-id-list level)))
    ;; make the player be always the first in the list
    (if (eq mob *player*)
      (push (id mob) (mob-id-list level))
      (if (mob-id-list level)
        (push (id mob) (cdr (nthcdr 0 (mob-id-list level)))) 
        (push (id mob) (mob-id-list level)))
      )
    
    (when (mob-ability-p mob +mob-abil-human+)
      (incf (total-humans (level *world*))))
    
    (when (mob-ability-p mob +mob-abil-demon+)
      (incf (total-demons (level *world*))))
    (when (mob-ability-p mob +mob-abil-undead+)
      (incf (total-undead (level *world*))))
    (when (and (mob-ability-p mob +mob-abil-angel+)
               (not (mob-ability-p mob +mob-abil-animal+)))
      (incf (total-angels (level *world*))))
    
    (incf (nth (loyal-faction mob) (total-faction-list (level *world*)))))
  
  (let ((sx) (sy))
    (setf sx (- (x mob) (truncate (1- (map-size mob)) 2)))
    (setf sy (- (y mob) (truncate (1- (map-size mob)) 2)))
    
    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        (setf (aref (mobs level) nx ny (z mob)) (id mob)))))

  (pushnew (id mob) (aref (mob-quadrant-map level) (truncate (x mob) 10) (truncate (y mob) 10)))

  (when apply-gravity
    (let ((final-z (z mob)))
      (when (setf final-z (apply-gravity mob))
        (set-mob-location mob (x mob) (y mob) final-z :apply-gravity t))))

  )

(defun remove-mob-from-level-list (level mob)

  (when (find (id mob) (mob-id-list level))

    (when (mob-ability-p mob +mob-abil-human+)
      (decf (total-humans (level *world*))))
    (when (mob-ability-p mob +mob-abil-demon+)
      (decf (total-demons (level *world*))))
    (when (mob-ability-p mob +mob-abil-undead+)
      (decf (total-undead (level *world*))))
    (when (and (mob-ability-p mob +mob-abil-angel+)
               (not (mob-ability-p mob +mob-abil-animal+)))
      (decf (total-angels (level *world*))))
    
    (when (mob-ability-p mob +mob-abil-civilian+)
      (incf (lost-civilians (level *world*))))
    
    (decf (nth (loyal-faction mob) (total-faction-list (level *world*))))
    
    (setf (mob-id-list level) (remove (id mob) (mob-id-list level))))
  
  (let ((sx) (sy))
    (setf sx (- (x mob) (truncate (1- (map-size mob)) 2)))
    (setf sy (- (y mob) (truncate (1- (map-size mob)) 2)))
    
    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        (setf (aref (mobs level) nx ny (z mob)) nil))))

  (setf (aref (mob-quadrant-map level) (truncate (x mob) 10) (truncate (y mob) 10))
        (remove (id mob) (aref (mob-quadrant-map level) (truncate (x mob) 10) (truncate (y mob) 10))))
  
  (log:info (format nil "REMOVE-MOB-FROM-LEVEL-LIST: ~A [~A] (~A ~A ~A) = ~A~%" (name mob) (id mob) (x mob) (y mob) (z mob) (get-mob-* level (x mob) (y mob) (z mob)))))

(defun add-feature-to-level-list (level feature)
  (if (and (can-merge-func feature)
           (funcall (can-merge-func feature) level feature)
           (merge-func feature))
    (progn
      ;;(format t "MERGE: ~A [~A] (~A ~A ~A)~%" (name feature) (id featur e) (x feature) (y feature) (z feature))
      (funcall (merge-func feature) level feature))
    (progn
      ;;(format t "~A [~A] (~A ~A ~A)~%" (name feature) (id feature) (x feature) (y feature) (z feature))
      
      (pushnew (id feature) (feature-id-list level))
      (push (id feature) (aref (features level) (x feature) (y feature) (z feature)))
      (when (and (not (get-feature-type-trait feature +feature-trait-no-gravity+))
                 (apply-gravity feature))
        (remove-feature-from-level-list level feature)
        (setf (z feature) (apply-gravity feature))
        (add-feature-to-level-list level feature))))
  )

(defun remove-feature-from-level-list (level feature)
  (setf (feature-id-list level) (remove (id feature) (feature-id-list level)))
  (setf (aref (features level) (x feature) (y feature) (z feature)) (remove (id feature) (aref (features level) (x feature) (y feature) (z feature)))))

(defun add-item-to-level-list (level item)
  
  (if (apply-gravity item)
    (progn
      (setf (z item) (apply-gravity item))
      (setf (aref (items level) (x item) (y item) (z item))
            (add-to-inv item (aref (items level) (x item) (y item) (z item)) nil)))
    (progn
      (setf (aref (items level) (x item) (y item) (z item))
            (add-to-inv item (aref (items level) (x item) (y item) (z item)) nil))))
  (when (get-item-by-id (id item))
    (pushnew (id item) (item-id-list level))
    (push (id item) (aref (item-quadrant-map level) (truncate (x item) 10) (truncate (y item) 10)))))

(defun remove-item-from-level-list (level item)
  (setf (item-id-list level) (remove (id item) (item-id-list level)))
  (setf (aref (item-quadrant-map level) (truncate (x item) 10) (truncate (y item) 10))
        (remove (id item) (aref (item-quadrant-map level) (truncate (x item) 10) (truncate (y item) 10))))
  (setf (aref (items level) (x item) (y item) (z item))
        (remove-from-inv item (aref (items level) (x item) (y item) (z item))))
  item)

;; Hot: ~400 call sites, and the dominant cost of flood-fill and therefore of
;; connectivity-map generation. Hoisting (terrain level) into a local removes
;; three of the four generic slot reads, and naming the array type lets SBCL
;; emit an inline aref instead of calling hairy-data-vector-ref. Together those
;; take the lookup from ~64ns to ~12ns without changing behaviour: out-of-range
;; coordinates still return NIL, which many callers rely on.
(declaim (inline get-terrain-* set-terrain-*))

(defun get-terrain-* (level x y z)
  (declare (type fixnum x y z) (optimize (speed 3)))
  (let ((arr (terrain level)))
    (declare (type (simple-array fixnum (* * *)) arr))
    (if (or (< x 0) (>= x (array-dimension arr 0))
            (< y 0) (>= y (array-dimension arr 1))
            (< z 0) (>= z (array-dimension arr 2)))
      nil
      (aref arr x y z))))

(defun set-terrain-* (level x y z terrain-type-id)
  (declare (type fixnum x y z terrain-type-id) (optimize (speed 3)))
  (let ((arr (terrain level)))
    (declare (type (simple-array fixnum (* * *)) arr))
    (setf (aref arr x y z) terrain-type-id)))

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

;; Hot: ~96 and ~109 call sites, and the memo layer was the single biggest
;; cost of a game turn. The array is created once per level with element type T
;; and never replaced, so naming the type lets SBCL open-code the aref instead
;; of calling hairy-data-vector-ref.
(declaim (inline get-memo-* set-memo-*))

(defun get-memo-* (level x y z)
  (declare (type fixnum x y z) (optimize (speed 3)))
  (aref (the (simple-array t (* * *)) (memo level)) x y z))

(defun set-memo-* (level x y z single-memo)
  (declare (type fixnum x y z) (optimize (speed 3)))
  (setf (aref (the (simple-array t (* * *)) (memo level)) x y z) single-memo))

(defun create-single-memo (glyph-idx glyph-color back-color visibility revealed light player)
  (make-array (list 7) :initial-contents (list glyph-idx glyph-color back-color visibility revealed light player))
  ;(list glyph-idx glyph-color back-color visibility revealed light)
  )

(defmacro do-memo-cells ((single-memo level) &body body)
  "Run BODY once per memo cell of LEVEL, with SINGLE-MEMO bound to the cell.

For the sweeps in los-fov.lisp that have to look at the whole level - a
90,000-cell array - this reads (MEMO LEVEL) once instead of once per cell.
Reached through GET-MEMO-* in a nested loop, that slot read is a generic
accessor call, and at 90,000 calls a sweep it cost more than everything the
sweeps actually do. The visiting order is the same one the nested loops
walked, X-major; nothing relies on it."
  (let ((memo-array (gensym "MEMO-ARRAY"))
        (index (gensym "INDEX")))
    `(let ((,memo-array (the (simple-array t (* * *)) (memo ,level))))
       (dotimes (,index (array-total-size ,memo-array))
         (let ((,single-memo (the simple-vector (row-major-aref ,memo-array ,index))))
           ,@body)))))

;; A single memo is the simple-vector built by create-single-memo.
(declaim (inline get-single-memo-glyph-idx get-single-memo-glyph-color get-single-memo-back-color get-single-memo-visibility get-single-memo-revealed get-single-memo-light get-single-memo-player))

(defun get-single-memo-glyph-idx (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 0))

(defun get-single-memo-glyph-color (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 1))

(defun get-single-memo-back-color (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 2))

(defun get-single-memo-visibility (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 3))

(defun get-single-memo-revealed (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 4))

(defun get-single-memo-light (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 5))

(defun get-single-memo-player (single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (svref single-memo 6))

;; Writing a field of a memo cell you already have in hand. SET-SINGLE-MEMO-*
;; below is the usual way in, but it looks the cell up from its coordinates,
;; which is wasted work inside DO-MEMO-CELLS - and these keep the field
;; offsets in this file with the readers above.
(declaim (inline (setf get-single-memo-glyph-color) (setf get-single-memo-back-color) (setf get-single-memo-visibility) (setf get-single-memo-light)))

(defun (setf get-single-memo-glyph-color) (value single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (setf (svref single-memo 1) value))

(defun (setf get-single-memo-back-color) (value single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (setf (svref single-memo 2) value))

(defun (setf get-single-memo-visibility) (value single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (setf (svref single-memo 3) value))

(defun (setf get-single-memo-light) (value single-memo)
  (declare (type simple-vector single-memo) (optimize (speed 3)))
  (setf (svref single-memo 5) value))

;; Inline: every one of the nine call sites passes constant keywords, so the
;; expansion is the lookup plus one SVREF store per field actually supplied -
;; no keyword parsing at run time. That matters because two of those sites
;; (the memo sweeps in los-fov.lisp) run once per cell of the whole level.
(declaim (inline set-single-memo-*))

(defun set-single-memo-* (level x y z &key (glyph-idx nil glyph-idx-p)
                                           (glyph-color nil glyph-color-p)
                                           (back-color nil back-color-p)
                                           (visibility nil visibility-p)
                                           (revealed nil revealed-p)
                                           (light nil light-p)
                                           (player nil player-p))
  "Update the supplied fields of the memo at X Y Z, leaving the others alone.

Each field used to default to its own (get-memo-* level x y z), so a one-field
update did seven separate 3D lookups and then wrote all seven fields back. The
result is the same either way - an unsupplied field was written back with the
value just read out of it - but this does one lookup and writes only what was
asked for. set-single-memo-* was 45.9% of a game turn before this."
  (declare (optimize (speed 3)))
  (let ((single-memo (get-memo-* level x y z)))
    (declare (type simple-vector single-memo))
    (when glyph-idx-p (setf (svref single-memo 0) glyph-idx))
    (when glyph-color-p (setf (svref single-memo 1) glyph-color))
    (when back-color-p (setf (svref single-memo 2) back-color))
    (when visibility-p (setf (svref single-memo 3) visibility))
    (when revealed-p (setf (svref single-memo 4) revealed))
    (when light-p (setf (svref single-memo 5) light))
    (when player-p (setf (svref single-memo 6) player))))

;;; A connect map is (simple-array fixnum (max-x max-y max-z +connect-map-move-count+)):
;;; one connectivity-region id per cell per movement mode, +connect-room-none+
;;; where none has been assigned.
;;;
;;; It used to be a 3D array of NIL or a small *adjustable* vector allocated
;;; per cell, grown with adjust-array as each of walk/climb/fly was filled in -
;;; so up to 90,000 allocations plus two reallocations each per level, and
;;; every read cost a hairy aref, a LENGTH, two bounds tests and a NIL test.
;;; get-connect-map-value was the hottest function in level generation.
;;; Flattening keeps the same values: an unset entry still reads as
;;; +connect-room-none+.

(deftype connect-map () '(simple-array fixnum (* * * #.+connect-map-move-count+)))

(defun make-connect-map (max-x max-y max-z)
  (declare (type fixnum max-x max-y max-z))
  (make-array (list max-x max-y max-z +connect-map-move-count+)
              :element-type 'fixnum
              :initial-element +connect-room-none+))

;; The CONNECT-MAP slot is the fixed six-element simple-vector made with the
;; LEVEL, indexed by mob size. Read it as (AREF (CONNECT-MAP LEVEL) SIZE) and
;; SBCL only knows the generic accessor returns T, so the read compiles to a
;; runtime dispatch on the array's element type; naming the type in this one
;; place gets every caller an inline SVREF instead.
(declaim (inline get-level-connect-map (setf get-level-connect-map)))

(defun get-level-connect-map (level map-size)
  (declare (type fixnum map-size) (optimize (speed 3)))
  (svref (the simple-vector (connect-map level)) map-size))

(defun (setf get-level-connect-map) (value level map-size)
  (declare (type fixnum map-size) (optimize (speed 3)))
  (setf (svref (the simple-vector (connect-map level)) map-size) value))

(declaim (inline get-connect-map-value set-connect-map-value))

(defun get-connect-map-value (connect-map x y z move-mode)
  (declare (type connect-map connect-map) (type fixnum x y z move-mode)
           (optimize (speed 3)))
  (aref connect-map x y z move-mode))

(defun set-connect-map-value (connect-map x y z move-mode value)
  (declare (type connect-map connect-map) (type fixnum x y z move-mode value)
           (optimize (speed 3)))
  (setf (aref connect-map x y z move-mode) value))

(defun get-level-connect-map-value (level x y z map-size move-mode)
  (declare (type fixnum x y z map-size move-mode) (optimize (speed 3)))
  (when (or (zerop map-size)
            (evenp map-size))
    (error "GET-CONNECT-MAP-SIZE: Map size should be an odd number"))
  (let ((connect-map (get-level-connect-map level map-size)))
    (if connect-map
      (aref (the connect-map connect-map) x y z move-mode)
      +connect-room-none+)))

(defun level-cells-connected-p (level sx sy sz tx ty tz map-size move-mode &key (can-open-doors t))
  (when (or (< sx 0) (< sy 0) (< sz 0) (>= sx (array-dimension (terrain level) 0)) (>= sy (array-dimension (terrain level) 1)) (>= sz (array-dimension (terrain level) 2))
            (< tx 0) (< ty 0) (< tz 0) (>= tx (array-dimension (terrain level) 0)) (>= ty (array-dimension (terrain level) 1)) (>= tz (array-dimension (terrain level) 2)))
    (return-from level-cells-connected-p nil))
  (let ((connect-map-value-start (get-level-connect-map-value level sx sy sz map-size move-mode))
        (connect-map-value-end (get-level-connect-map-value level tx ty tz map-size move-mode)))
    (if (or (= connect-map-value-start connect-map-value-end)
            (level-aux-map-connect-p level connect-map-value-start connect-map-value-end map-size move-mode :can-open-doors can-open-doors))
      t
      nil))
  )

(defun level-aux-map-connect-p (level room-id-start room-id-end map-size move-mode &key (can-open-doors t))
  (unless (aref (aux-connect-map level) map-size)
    (return-from level-aux-map-connect-p nil))
  (unless (aref (aref (aux-connect-map level) map-size) move-mode)
    (return-from level-aux-map-connect-p nil))
  
  (let ((connect-list (aref (aref (aux-connect-map level) map-size) move-mode))
        (connection nil))
    (setf connection (find-if #'(lambda (a)
                                  (if (or (and (= (first a) room-id-start) (= (second a) room-id-end))
                                          (and (= (first a) room-id-end) (= (second a) room-id-start)))
                                    t
                                    nil))
                              connect-list))
    (when (and connection
               (or can-open-doors
                   (and (not can-open-doors)
                        (plusp (get-aux-map-connection-actual connection)))))
      (return-from level-aux-map-connect-p t))

    ;; if no direct connection found - try to find connected rooms through intermediate connections
    (if (and (find-if #'(lambda (a) (if (or (= (first a) room-id-start) (= (second a) room-id-start)) t nil)) connect-list)
             (find-if #'(lambda (a) (if (or (= (first a) room-id-end) (= (second a) room-id-end)) t nil)) connect-list))
      (progn
        (let ((open-nodes ())
              (closed-nodes ()))
          (push room-id-start open-nodes)
          (loop for node = (first open-nodes)
                while (and node (/= node room-id-end)) do
                  (pop open-nodes)
                  (loop for (start end potential actual) in connect-list
                        for is-closed = (or (find start closed-nodes)
                                            (find end closed-nodes))
                        when (and (= start node)
                                  (not is-closed)
                                  (or can-open-doors
                                      (and (not can-open-doors)
                                           (plusp actual))))
                          do
                                 (push end open-nodes)
                        when (and (= end node)
                                  (not is-closed)
                                  (or can-open-doors
                                      (and (not can-open-doors)
                                           (plusp actual))))
                          do
                             (push start open-nodes))
                  (push node closed-nodes)
                )
          (if open-nodes
            t
            nil)))
      nil)))

(defun get-aux-map-connection-potential (connection)
  (third connection))

(defun get-aux-map-connection-actual (connection)
  (fourth connection))

(defun set-aux-map-connection (level room-id-start room-id-end map-size move-mode &key (delta-potential 1) (delta-actual 1))
  (unless (aref (aux-connect-map level) map-size)
    (setf (aref (aux-connect-map level) map-size) (make-array (list (1+ move-mode)) :initial-element nil :adjustable t)))
  (when (>= move-mode (length (aref (aux-connect-map level) map-size)))
    (adjust-array (aref (aux-connect-map level) map-size) (list (1+ move-mode)) :initial-element nil))

  (let* ((connect-list (aref (aref (aux-connect-map level) map-size) move-mode))
         (connection (find-if #'(lambda (a)
                                  (if (or (and (= (first a) room-id-start) (= (second a) room-id-end))
                                          (and (= (first a) room-id-end) (= (second a) room-id-start)))
                                    t
                                    nil))
                              connect-list)))
    ;; connection is (<room-id-start> <room-id-end> <number of potential links between rooms> <number of actual links between rooms>)
    (if connection
      (progn
        (incf (third connection) delta-potential)
        (incf (fourth connection) delta-actual)

        (when (minusp (third connection))
          (setf (third connection) 0))

        (when (minusp (fourth connection))
          (setf (fourth connection) 0))
        
        (when (zerop (third connection))
          (setf (aref (aref (aux-connect-map level) map-size) move-mode)
                (remove connection connect-list))))
      (progn
        (when (and (plusp delta-potential)
                   (or (plusp delta-actual)
                       (zerop delta-actual)))
          (push (list room-id-start room-id-end delta-potential delta-actual) (aref (aref (aux-connect-map level) map-size) move-mode)))))
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
  (setf (aref (light-sources level) (1- (length (light-sources level)))) light-source)
  (push light-source (aref (light-quadrant-map level) (truncate (first light-source) 10) (truncate (second light-source) 10))))

(defun return-weather-type-str (level)
  (let ((str (create-string)))
    (format str "~A" (cond
                       ((find +game-event-snow-falls+ (game-events level)) "Snow")
                       ((find +game-event-rain-falls+ (game-events level)) "Rain")
                       (t "Clear")))
    (when (find +game-event-unnatural-darkness+ (game-events level))
      (format str ", Darkness"))
    str))

;;----------------------
;; WORLD
;;----------------------

(defclass world ()
  ((world-game-time :initform 0 :accessor world-game-time)
   (turn-finished :initform nil :accessor turn-finished)
   
   (level :initform nil :accessor level :type (or level null))
   
   (game-events :initform () :accessor game-events)

   (world-map :initform nil :accessor world-map)
   (player-specific-faction :initform nil :accessor world/player-specific-faction)
   (present-missions :initform () :accessor world/present-missions)

   (mission-message-box :initform (make-message-box) :accessor world/mission-message-box :type message-box)
   (event-message-box :initform (make-message-box) :accessor world/event-message-box :type message-box)
   (effect-message-box :initform (make-message-box) :accessor world/effect-message-box :type message-box)

   (flesh-points :initform 0 :accessor world/flesh-points :type fixnum)
   (machine-destroyed :initform 0 :accessor world/machine-destroyed :type fixnum)
   (cur-military-num :initform 0 :accessor world/cur-military-num :type fixnum)
   (cur-demons-num :initform 0 :accessor world/cur-demons-num :type fixnum)

   (post-mission-results :initform () :accessor world/post-mission-results :type list)

   (demons-mission-limit :initform 0 :accessor world/demons-mission-limit :type fixnum)
   (military-mission-limit :initform 0 :accessor world/military-mission-limit :type fixnum)
   (angels-mission-limit :initform 0 :accessor world/angels-mission-limit :type fixnum)

   (missions-by-slot-type :initform () :accessor world/missions-by-slot-type :type plist) ;; mission-ids arranged into a plist by the mission-slot-type

   (campaign-effects :initform () :accessor world/campaign-effects :type list)

   (commands :initform (make-hash-table) :accessor world/commands) ;; keys are faction-type, value is (:command <command id> :cd <cd>)

   (random-number :initform (random 100) :accessor world/random-number)
   ))

(defmethod initialize-instance :after ((world world) &key)
  (with-slots (demon-missions-city military-missions-city angel-missions-city military-missions-offworld angel-missions-offworld) world
    (loop for mission-type being the hash-values in *mission-types*
          when (enabled mission-type)
            do
               (unless (getf (world/missions-by-slot-type world) (mission-slot-type mission-type))
                 (setf (getf (world/missions-by-slot-type world) (mission-slot-type mission-type)) ()))
               (push (id mission-type) (getf (world/missions-by-slot-type world) (mission-slot-type mission-type))))
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
    (format nil "~2,'0d ~A ~4,'0d ~2,'0d:~2,'0d:~2,'0d" (1+ day)
            (cond
              ((= month 0) "Jan")
              ((= month 1) "Feb")
              ((= month 2) "Mar")
              ((= month 3) "Apr")
              ((= month 4) "May")
              ((= month 5) "Jun")
              ((= month 6) "Jul")
              ((= month 7) "Aug")
              ((= month 8) "Sep")
              ((= month 9) "Oct")
              ((= month 10) "Nov")
              ((= month 11) "Dec")
              )
            year
            hour min sec)))

(defun show-date-time-YMD (date-time)
  (multiple-value-bind (year month day hour min sec) (get-current-date-time date-time)
    (declare (ignore hour min sec))
    
    (format nil "~2,'0d ~A ~4,'0d"
            (1+ day)
            (cond
              ((= month 0) "Jan")
              ((= month 1) "Feb")
              ((= month 2) "Mar")
              ((= month 3) "Apr")
              ((= month 4) "May")
              ((= month 5) "Jun")
              ((= month 6) "Jul")
              ((= month 7) "Aug")
              ((= month 8) "Sep")
              ((= month 9) "Oct")
              ((= month 10) "Nov")
              ((= month 11) "Dec")
              )
            year)))
