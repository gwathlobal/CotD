(in-package :cotd)

;;; ------------------------------------------------------------------
;;; Per-sweep memoization of a cell's terrain+feature vision-blocking
;;; power.
;;;
;;; A single FOV/LOS sweep (one DRAW-FOV call, or one mob's vision
;;; update) fires many overlapping LINE-OF-SIGHT rays that all pass
;;; through the same cells near the origin. Each such visit used to
;;; redo the same GET-TERRAIN-TYPE-TRAIT hash lookups and walk the same
;;; feature list again. Since a cell's *own* blocking power doesn't
;;; depend on which ray is passing through it (only the floor-crossing
;;; check in CHECK-LOS-PROPAGATE depends on PREV-CELL), it's safe to
;;; cache it for the duration of one sweep.
;;;
;;; *VISION-BLOCK-CACHE* must be rebound fresh (via WITH-VISION-BLOCK-CACHE)
;;; for every independent sweep and never reused across them -- it goes
;;; stale the instant terrain or features change (e.g. a door opens).
;;; ------------------------------------------------------------------

(defvar *vision-block-cache* nil)

;;; Overlapping rays in one sweep also keep re-revealing the same map
;;; cell to the player (REVEAL-CELL-ON-MAP is considerably heavier than
;;; the vision-block check -- it looks up terrain/feature/item/mob
;;; glyphs), and its result for a given cell can't change mid-sweep for
;;; the same reason CHECK-LOS-PROPAGATE's terrain/feature computation
;;; can't. *REVEALED-CELL-CACHE* dedupes those calls the same way.
(defvar *revealed-cell-cache* nil)

(defmacro with-vision-block-cache (() &body body)
  `(let ((*vision-block-cache* (make-hash-table :test 'eql))
         (*revealed-cell-cache* (make-hash-table :test 'eql)))
     ,@body))

(declaim (inline vision-cache-key))
(defun vision-cache-key (x y z)
  (declare (type fixnum x y z))
  ;; Masks each axis to 20 bits -- comfortably covers any realistic
  ;; level, and stays well inside a 62-bit fixnum on 64-bit SBCL.
  (the fixnum (logior (ash (logand x #xFFFFF) 40)
                       (ash (logand y #xFFFFF) 20)
                       (logand z #xFFFFF))))

(defun compute-vision-block-power-of-cell (level dx dy dz)
  "Combined terrain+feature vision-blocking power of a single cell.
Assumes the cell exists -- callers check that via GET-TERRAIN-* first."
  (let ((terrain (get-terrain-* level dx dy dz))
        (vision-block-power 0))
    (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
      (if (eq (get-terrain-type-trait terrain +terrain-trait-blocks-vision+) t)
        (incf vision-block-power 100)
        (incf vision-block-power (get-terrain-type-trait terrain +terrain-trait-blocks-vision+))))
    (loop for feature-id in (get-features-* level dx dy dz)
          for lvl-feature = (get-feature-by-id feature-id)
          when (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+)
            do
               (if (eq (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+) t)
                 (incf vision-block-power 100)
                 (incf vision-block-power (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+))))
    vision-block-power))

(defun vision-block-power-of-cell (level dx dy dz)
  (declare (type fixnum dx dy dz))
  (if *vision-block-cache*
    (multiple-value-bind (cached foundp) (gethash (vision-cache-key dx dy dz) *vision-block-cache*)
      (if foundp
        cached
        (setf (gethash (vision-cache-key dx dy dz) *vision-block-cache*)
              (compute-vision-block-power-of-cell level dx dy dz))))
    (compute-vision-block-power-of-cell level dx dy dz)))

(defun get-distance (sx sy tx ty)
  (declare (type fixnum sx sy tx ty))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)))))

(defun get-distance-3d (sx sy sz tx ty tz)
  (declare (type fixnum sx sy sz tx ty tz))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)) (* (- sz tz) (- sz tz)))))

;; "Is this closer than that radius" is the single most common thing done with
;; the two functions above, and written as (< (get-distance-3d ...) radius) it
;; compares a float against an integer, which SBCL cannot open-code: it has to
;; convert the float to a rational first. Converting the radius to a float
;; instead gives the same answer - these radii are sight ranges and light
;; radii, orders of magnitude below the 2^24 where a single-float stops being
;; able to hold an integer exactly - and compares two floats.
(declaim (inline distance-under-p distance-3d-under-p))

(defun distance-under-p (sx sy tx ty limit)
  "True when <SX, SY> is strictly nearer than LIMIT to <TX, TY>."
  (declare (type fixnum sx sy tx ty limit) (optimize (speed 3)))
  (< (get-distance sx sy tx ty) (coerce limit 'single-float)))

(defun distance-3d-under-p (sx sy sz tx ty tz limit)
  "True when <SX, SY, SZ> is strictly nearer than LIMIT to <TX, TY, TZ>."
  (declare (type fixnum sx sy sz tx ty tz limit) (optimize (speed 3)))
  (< (get-distance-3d sx sy sz tx ty tz) (coerce limit 'single-float)))

;; The light, mob and item quadrant maps are all scanned the same way: take
;; everything bucketed in the nine quadrants around the one the mob stands in.
;; Written out at each call site, the neighbour offsets are only known to be
;; fixnums, so adding them to the quadrant index needs a bignum-capable add;
;; here their real range is named once and the whole scan stays in fixnums.
(defun quadrant-neighbours (quadrants quad-x quad-y)
  "Everything in the nine quadrant buckets around <QUAD-X, QUAD-Y>, in the
fixed order the callers have always seen: QX ascending, and QY within it."
  (declare (type (simple-array t (* *)) quadrants)
           (type (signed-byte 30) quad-x quad-y)
           (optimize (speed 3)))
  (let ((result ()))
    (dotimes (i 3)
      (dotimes (j 3)
        (let ((x (+ quad-x i -1))
              (y (+ quad-y j -1)))
          (declare (type fixnum x y))
          (when (and (>= x 0) (>= y 0)
                     (< x (array-dimension quadrants 0))
                     (< y (array-dimension quadrants 1)))
            (setf result (append result (aref quadrants x y)))))))
    result))

(defun check-LOS-propagate (dx dy dz prev-cell &key (check-move nil) (check-vision nil) (check-projectile nil) (player-reveal-cell nil) (check-sound nil))
  ;(declare (optimize (speed 3)))
  (let ((terrain))
    (when (or (< dx 0) (>= dx (array-dimension (terrain (level *world*)) 0))
              (< dy 0) (>= dy (array-dimension (terrain (level *world*)) 1))
              (< dz 0) (>= dz (array-dimension (terrain (level *world*)) 2)))
      (return-from check-LOS-propagate nil))
    
    ;; check if LOS propagates vertically through floors (depending on the type of LOS)
    (when (and prev-cell
               (/= (- (third prev-cell) dz) 0))
      (loop for (check trait) in `((,check-move ,+terrain-trait-blocks-move-floor+) (,check-vision ,+terrain-trait-blocks-vision-floor+) (,check-projectile ,+terrain-trait-blocks-projectiles-floor+))
            when check do
              (if (> (- (third prev-cell) dz) 0)
                ;; prev is up, the tile above current has trait & the prev tile has trait
                (when (and (get-terrain-* (level *world*) dx dy (third prev-cell))
                           (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (third prev-cell)) trait) t)
                               (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (third prev-cell)) trait) 100))
                           (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell)) trait) t)
                               (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell)) trait) 100)))
                  (return-from check-LOS-propagate nil))
                ;; prev is down
                (when (and (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz)
                           (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz) trait) t)
                               (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz) trait) 100))
                           (get-terrain-* (level *world*) dx dy dz)
                           (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-blocks-move-floor+) t)
                               (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-blocks-move-floor+) 100)))
                  (return-from check-LOS-propagate nil)))))
    
    (when player-reveal-cell
      (when (and (<= (abs (- (x *player*) dx)) 5)
                 (<= (abs (- (y *player*) dy)) 5)
                 (/= (z *player*) dz))
        (pushnew dz (visible-z-list *player*)))
      (let ((key (vision-cache-key dx dy dz)))
        (unless (and *revealed-cell-cache* (gethash key *revealed-cell-cache*))
          (when *revealed-cell-cache*
            (setf (gethash key *revealed-cell-cache*) t))
          (reveal-cell-on-map (level *world*) dx dy dz :reveal-mob (if (or (null (get-mob-* (level *world*) dx dy dz))
                                                                           (eq (get-mob-* (level *world*) dx dy dz) *player*))
                                                                     t
                                                                     (check-mob-visible (get-mob-* (level *world*) dx dy dz) :observer *player*))))))
    
    (setf terrain (get-terrain-* (level *world*) dx dy dz))
    (unless terrain
      (return-from check-LOS-propagate nil))

    (when (and check-move
               (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
      (return-from check-LOS-propagate nil))

    (when (and check-projectile
               (get-terrain-type-trait terrain +terrain-trait-blocks-projectiles+))
      (return-from check-LOS-propagate nil))

    (when (and check-sound
               (or (eq (get-terrain-type-trait terrain +terrain-trait-blocks-sound+) t)
                   (eq (get-terrain-type-trait terrain +terrain-trait-blocks-sound+) 100)))
      (return-from check-LOS-propagate nil))

    (when check-vision
      (return-from check-LOS-propagate (vision-block-power-of-cell (level *world*) dx dy dz)))

    t))

(defun calculate-single-tile-brightness (level x y z &key (calc-for-player nil))
  (let ((brightness 0)
        (darkness 0)) 
    ;; iterate through all mobs
    (loop for mob-id of-type fixnum in (if calc-for-player
                          (nearby-light-mobs *player*)
                          (mob-id-list level))
          for tmob of-type mob = (get-mob-by-id mob-id)
          for light-power of-type fixnum = (* *light-power-faloff* (abs (cur-light tmob)))
          for vision-pwr of-type fixnum = (abs (cur-light tmob))
          for vision-power of-type fixnum = (abs (cur-light tmob))
          do
            (when (< (get-distance-3d (x tmob) (y tmob) (z tmob) x y z) (abs (cur-light tmob)))
               (line-of-sight (x tmob) (y tmob) (z tmob) x y z
                              #'(lambda (dx dy dz prev-cell)
                                  (declare (type fixnum dx dy dz))
                                  (let* ((exit-result t) (pwr-decrease 0)) 
                                    (block nil
                                      
                                      (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                      (unless pwr-decrease
                                        (setf exit-result 'exit)
                                        (return))
                                      (decf vision-pwr (truncate (* vision-power pwr-decrease) 100))
                                      (decf vision-pwr)
                                      
                                      (if (> (cur-light tmob) 0)
                                        (progn
                                          ;; if the light emitted by a mob is positive - increase brightness
                                          (when (and (= x dx) (= y dy) (= z dz)
                                                     (> light-power brightness))
                                            (setf brightness light-power)
                                            (setf exit-result 'exit)
                                            (return))
                                          (decf light-power *light-power-faloff*))
                                        (progn
                                           ;; if the light emitted by a mob is negative - increase darkness
                                          (when (and (= x dx) (= y dy) (= z dz)
                                                     (> light-power darkness))
                                            (setf darkness light-power)
                                            (setf exit-result 'exit)
                                            (return))
                                          (decf light-power *dark-power-faloff*)))
                                      
                                      

                                      (when (<= vision-pwr 0)
                                        (setf exit-result 'exit)
                                        (return)))
                                    
                                    exit-result))))
        )

    ;; iterate through all stationary sources
    (loop for (tx ty tz light-radius) in (if calc-for-player
                                        (nearby-light-sources *player*)
                                        (coerce (light-sources level) 'list))
          for light-power of-type fixnum = (* *light-power-faloff* light-radius)
          for vision-pwr of-type fixnum = light-radius
          for vision-power of-type fixnum = light-radius
          do
             (when (and (not (zerop light-radius))
                        (< (get-distance-3d tx ty tz x y z) light-radius))
               (line-of-sight tx ty tz x y z
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                
                                (let* ((exit-result t) (pwr-decrease 0)) 
                                  (block nil

                                    (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                    (unless pwr-decrease
                                      (setf exit-result 'exit)
                                      (return))
                                    (decf vision-pwr (truncate (* vision-power pwr-decrease) 100))
                                    (decf vision-pwr)

                                    ;; insert set light func here
                                    (when (and (= x dx) (= y dy) (= z dz)
                                               (> light-power brightness))
                                        (setf brightness light-power)
                                        (setf exit-result 'exit)
                                        (return))
                                    
                                    (decf light-power *light-power-faloff*)

                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return)))
                                    
                                  exit-result)))))
    ;; increase brigtness by outdoor brightness
    (incf brightness (get-outdoor-light-* level x y z))
    (decf brightness darkness)

    ;; find nearby mobs that are casting shadows and check if the tile in question is the tile they are casting shadows to
    (when (>= brightness *mob-visibility-threshold*)
      (check-surroundings x y nil #'(lambda (dx dy)
                                      (when (and (>= dx 0) (< dx (array-dimension (terrain level) 0))
                                                 (>= dy 0) (< dy (array-dimension (terrain level) 1))
                                                 (get-mob-* level dx dy z)
                                                 (mob-effect-p (get-mob-* level dx dy z) +mob-effect-casting-shadow+))
                                        (let ((effect (get-effect-by-id (mob-effect-p (get-mob-* level dx dy z) +mob-effect-casting-shadow+))))
                                          (when (and (= (+ dx (first (param1 effect))) x)
                                                     (= (+ dy (second (param1 effect))) y))
                                            (setf brightness (- *mob-visibility-threshold* 10))))))))
    (when (< brightness 0)
      (setf brightness 0))
    brightness
    ))

(defun calc-lit-tiles-for-player (mob)
  (log:info "CALC-LIT-TILES: ~A [~A]" (name mob) (id mob))

  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (declare (type fixnum x1))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (declare (type fixnum y1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (declare (type fixnum z1))
        (set-single-memo-* (level *world*) x1 y1 z1 :light 0)
        )))

  (loop for tx of-type fixnum from (- (x mob) (cur-sight mob)) to (+ (x mob) (cur-sight mob)) do
    (loop for ty of-type fixnum from (- (y mob) (cur-sight mob)) to (+ (y mob) (cur-sight mob)) do
      (loop for tz of-type fixnum from (- (z mob) (cur-sight mob)) to (+ (z mob) (cur-sight mob))
            with brightness of-type fixnum = 0
            when (and (>= tx 0) (< tx (array-dimension (terrain (level *world*)) 0))
                      (>= ty 0) (< ty (array-dimension (terrain (level *world*)) 1))
                      (>= tz 0) (< tz (array-dimension (terrain (level *world*)) 2)))
              do
               (setf brightness (calculate-single-tile-brightness (level *world*) tx ty tz :calc-for-player t))
               (when (> brightness (get-single-memo-light (get-memo-* (level *world*) tx ty tz)))
                 (set-single-memo-* (level *world*) tx ty tz :light brightness)))))
  )

(defun update-visible-mobs-normal (mob)
  (declare (optimize (speed 3) (safety 0)))
  (with-vision-block-cache ()
  (setf (brightness mob) 0)
  (setf (darkness mob) 0)
  (when (eq mob *player*)
    (setf (nearby-light-mobs *player*) nil)
    (setf (nearby-light-sources *player*) nil))

  ;; MOB does not move while its own field of view is computed, so its
  ;; position and sight radius are read once into typed locals. Through the
  ;; generic slot accessors they are only known to be T, and this function
  ;; does arithmetic with them once per cell of every line of sight it traces
  ;; - which is where the (SPEED 3) above is supposed to pay off.
  (let* ((mob-x (the fixnum (x mob)))
         (mob-y (the fixnum (y mob)))
         (mob-z (the fixnum (z mob)))
         ;; narrower than FIXNUM where a product or a sum of two of these has
         ;; to stay in one
         (sight (the (unsigned-byte 30) (cur-sight mob)))
         (quad-x (truncate mob-x 10))
         (quad-y (truncate mob-y 10)))
    (declare (type fixnum mob-x mob-y mob-z)
             (type (unsigned-byte 30) sight)
             (type (signed-byte 30) quad-x quad-y))
    ;; check through all stationary light sources
  (loop for (x y z light-radius) of-type (fixnum fixnum fixnum fixnum)
          in (quadrant-neighbours (the (simple-array t (* *)) (light-quadrant-map (level *world*)))
                                  quad-x quad-y)
        for radius of-type (unsigned-byte 30) = light-radius
        for light-power of-type fixnum = (* *light-power-faloff* radius)
        for vision-pwr of-type fixnum = radius
        for vision-power of-type (unsigned-byte 30) = radius
        do
           ;; set up mob brightness
           (when (and (not (zerop radius))
                      (distance-3d-under-p x y z mob-x mob-y mob-z radius))
               (line-of-sight x y z mob-x mob-y mob-z
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                
                                (let* ((exit-result t) (pwr-decrease 0)) 
                                  (block nil

                                    (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                    (unless pwr-decrease
                                      (setf exit-result 'exit)
                                      (return))
                                    ;; with :CHECK-VISION, CHECK-LOS-PROPAGATE returns
                                    ;; either NIL (ruled out just above) or the cell's
                                    ;; vision-block power, an integer.
                                    (decf vision-pwr (truncate (* vision-power (the (unsigned-byte 30) pwr-decrease)) 100))
                                    (decf vision-pwr)

                                    (when (and (get-mob-* (level *world*) dx dy dz) 
                                               (eq (get-mob-* (level *world*) dx dy dz) mob)
                                               (> light-power (the fixnum (brightness mob))))
                                      (setf (brightness mob) light-power))
                                    (decf light-power *light-power-faloff*)

                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return)))
                                    
                                  exit-result))))
           ;; set up nearby stationary light sources for player
           (when (and (eq mob *player*)
                      (distance-3d-under-p x y z mob-x mob-y mob-z (+ radius sight)))
             (push (list x y z light-radius) (nearby-light-sources *player*)))
        )

    (loop with nearest-evil = nil
          with nearest-good = nil
          for mob-id of-type fixnum in (if (mob-ability-p mob +mob-abil-shared-minds+)
                                         (mob-id-list (level *world*))
                                         (quadrant-neighbours (the (simple-array t (* *)) (mob-quadrant-map (level *world*)))
                                                              quad-x quad-y))
          for tmob of-type mob = (get-mob-by-id mob-id)
          ;; the same reason as for MOB's own coordinates above: read each of
          ;; TMOB's once per iteration, with its type named
          for tmob-x of-type fixnum = (x tmob)
          for tmob-y of-type fixnum = (y tmob)
          for tmob-z of-type fixnum = (z tmob)
          for tmob-light of-type (signed-byte 30) = (cur-light tmob)
          for light-abs of-type (unsigned-byte 30) = (abs tmob-light)
          for vision-pwr of-type fixnum = sight
          for vision-power of-type (unsigned-byte 30) = sight
          for light-power of-type fixnum = (* *light-power-faloff* light-abs)
          for light-pwr of-type fixnum = light-abs
          for light-power-base of-type (unsigned-byte 30) = light-abs
          
          do
             ;; find nearest evil mob
             (when (and (not (check-dead tmob))
                        (mob-ability-p tmob +mob-abil-demon+)
                        (not (eq tmob mob)))
               (unless nearest-evil (setf nearest-evil tmob))
               (when (< (get-distance mob-x mob-y tmob-x tmob-y)
                        (get-distance mob-x mob-y (the fixnum (x nearest-evil)) (the fixnum (y nearest-evil))))
                 (setf nearest-evil tmob)))

             ;; find nearest good mob
             (when (and (not (check-dead tmob))
                        (mob-ability-p tmob +mob-abil-angel+)
                        (not (eq tmob mob)))
               (unless nearest-good (setf nearest-good tmob))
               (when (< (get-distance mob-x mob-y tmob-x tmob-y)
                        (get-distance mob-x mob-y (the fixnum (x nearest-good)) (the fixnum (y nearest-good))))
                 (setf nearest-good tmob)))
             
             ;; if you share minds with your faction - add all your faction mobs and all mobs that they see
             ;; except for trinity mimic - they share minds only with their own union
             (when (and (not (eq mob tmob))
                        (mob-ability-p mob +mob-abil-shared-minds+)
                        (mob-ability-p tmob +mob-abil-shared-minds+)
                        (= (the fixnum (faction mob)) (the fixnum (faction tmob)))
                        (or (and (not (mob-ability-p mob +mob-abil-trinity-mimic+))
                                 (not (mob-ability-p tmob +mob-abil-trinity-mimic+)))
                            (and (mob-ability-p mob +mob-abil-trinity-mimic+)
                                 (mob-ability-p tmob +mob-abil-trinity-mimic+)
                                 (find (the fixnum (id mob)) (the list (mimic-id-list tmob))))))
               (pushnew mob-id (shared-visible-mobs mob))
               ;(format t "~A [~A] sees ~A~%" (name tmob) (id tmob) (visible-mobs tmob))
               (loop for vmob-id in (proper-visible-mobs tmob)
                     when (and (not (check-dead (get-mob-by-id vmob-id)))
                               (not (is-merged (get-mob-by-id vmob-id))))
                       do
                          (pushnew vmob-id (shared-visible-mobs mob)))
               (setf (shared-visible-mobs mob) (remove (id mob) (shared-visible-mobs mob))))
             
             ;; you see all mobs that you have parasites on
             (when (and (not (eq mob tmob))
                        (mob-ability-p mob +mob-abil-primordial+)
                      (mob-effect-p tmob +mob-effect-parasite+))
               (pushnew mob-id (shared-visible-mobs mob))
               
               (setf (shared-visible-mobs mob) (remove (id mob) (shared-visible-mobs mob))))

             ;; set up mob brightness
             (when (and (distance-3d-under-p tmob-x tmob-y tmob-z mob-x mob-y mob-z light-abs)
                      ;(not (eq mob tmob))
                        )
               (line-of-sight tmob-x tmob-y tmob-z mob-x mob-y mob-z
                              #'(lambda (dx dy dz prev-cell)
                                  (declare (type fixnum dx dy dz))
                                  (let* ((exit-result t) (pwr-decrease 0)) 
                                    (block nil
                                      
                                      (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                      (unless pwr-decrease
                                        (setf exit-result 'exit)
                                        (return))
                                      ;; with :CHECK-VISION, CHECK-LOS-PROPAGATE returns
                                      ;; either NIL (ruled out just above) or the cell's
                                      ;; vision-block power, an integer.
                                      (decf light-pwr (truncate (* light-power-base (the (unsigned-byte 30) pwr-decrease)) 100))
                                      (decf light-pwr)
                                      
                                      (if (> tmob-light 0)
                                        (progn
                                          ;; if the light emitted by a mob is positive - increase brightness
                                          (when (and (get-mob-* (level *world*) dx dy dz) 
                                                     (eq (get-mob-* (level *world*) dx dy dz) mob)
                                                     (> light-power (the fixnum (brightness mob))))
                                            (setf (brightness mob) light-power))
                                          (decf light-power *light-power-faloff*))
                                        (progn
                                          ;; if the light emitted by a mob is positive - increase darkness
                                          (when (and (get-mob-* (level *world*) dx dy dz) 
                                                     (eq (get-mob-* (level *world*) dx dy dz) mob)
                                                     (> light-power (the fixnum (darkness mob))))
                                            (setf (darkness mob) light-power))
                                          (decf light-power *dark-power-faloff*)))
                                      
                                      (when (<= light-pwr 0)
                                        (setf exit-result 'exit)
                                        (return)))
                                    
                                    exit-result))))
             
             ;; set up visible mobs
             (when (and (not (eq mob tmob))
                        (distance-3d-under-p mob-x mob-y mob-z tmob-x tmob-y tmob-z sight))
               (line-of-sight mob-x mob-y mob-z tmob-x tmob-y tmob-z
                              #'(lambda (dx dy dz prev-cell)
                                  (declare (type fixnum dx dy dz))
                                  (let* ((exit-result t) (mob-id 0) (pwr-decrease 0)) 
                                    (declare (type fixnum mob-id))
                                    
                                    (block nil
                                      
                                      (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                      (unless pwr-decrease
                                        (setf exit-result 'exit)
                                        (return))
                                      ;; with :CHECK-VISION, CHECK-LOS-PROPAGATE returns
                                      ;; either NIL (ruled out just above) or the cell's
                                      ;; vision-block power, an integer.
                                      (decf vision-pwr (truncate (* vision-power (the (unsigned-byte 30) pwr-decrease)) 100))
                                      (decf vision-pwr)

                                      (when (and (get-mob-* (level *world*) dx dy dz) 
                                                 (not (eq (get-mob-* (level *world*) dx dy dz) mob))
                                                 (check-mob-visible (get-mob-* (level *world*) dx dy dz) :observer mob))
                                        ;;(format t "VISIBILITY ~A ~A" (name (get-mob-* (level *world*) dx dy dz)) (get-mob-visibility (get-mob-* (level *world*) dx dy dz)))
                                        (setf mob-id (id (get-mob-* (level *world*) dx dy dz)))
                                        (pushnew mob-id (proper-visible-mobs mob)))
                                      
                                      (when (<= vision-pwr 0)
                                        (setf exit-result 'exit)
                                        (return))
                                      
                                      )
                                    exit-result))))
             
             ;; set up nearby mobs that are light sources for player
             (when (and (eq mob *player*)
                        (not (zerop tmob-light))
                        (distance-3d-under-p tmob-x tmob-y tmob-z mob-x mob-y mob-z (+ tmob-light sight)))
               (push (id tmob) (nearby-light-mobs *player*)))
             
             ;; set up mobs that potentially hear you
             (when (and (not (eq mob tmob))
                        (distance-3d-under-p tmob-x tmob-y tmob-z mob-x mob-y mob-z *max-hearing-range*))
               (pushnew mob-id (hear-range-mobs mob)))
          finally
             (if (and nearest-evil
                      (mob-ability-p mob +mob-abil-detect-evil+))
               (setf (sense-evil-id mob) (id nearest-evil))
               (setf (sense-evil-id mob) nil))
             (if (and nearest-good
                      (mob-ability-p mob +mob-abil-detect-good+))
               (setf (sense-good-id mob) (id nearest-good))
               (setf (sense-good-id mob) nil))
          )

  (when (eq mob *player*)
    (calc-lit-tiles-for-player *player*))
  
  ;; written out rather than INCF/DECF: those re-read the place, and through
  ;; the generic accessor that read is only known to be a NUMBER
  (setf (brightness mob) (+ (the (signed-byte 30) (brightness mob))
                            (the (signed-byte 30) (get-outdoor-light-* (level *world*) mob-x mob-y mob-z))))
  (setf (brightness mob) (- (the (signed-byte 30) (brightness mob)) (the (signed-byte 30) (darkness mob))))

  ;; find nearby mobs that are casting shadows and check if the tile in question is the tile they are casting shadows to
  (when (>= (the fixnum (brightness mob)) *mob-visibility-threshold*)
    (let ((terrain (the (simple-array fixnum (* * *)) (terrain (level *world*)))))
      (check-surroundings mob-x mob-y nil #'(lambda (dx dy)
                                                (declare (type fixnum dx dy))
                                                (when (and (>= dx 0) (< dx (array-dimension terrain 0))
                                                           (>= dy 0) (< dy (array-dimension terrain 1))
                                                           (get-mob-* (level *world*) dx dy mob-z)
                                                           (mob-effect-p (get-mob-* (level *world*) dx dy mob-z) +mob-effect-casting-shadow+))
                                                  (let ((effect (get-effect-by-id (mob-effect-p (get-mob-* (level *world*) dx dy mob-z) +mob-effect-casting-shadow+))))
                                                    (when (and (= (+ dx (the fixnum (first (param1 effect)))) mob-x)
                                                               (= (+ dy (the fixnum (second (param1 effect)))) mob-y))
                                                      (setf (brightness mob) (- *mob-visibility-threshold* 10)))))))))

  ;; if the mob is glowing - increase its brightness by 100
  (when (mob-effect-p mob +mob-effect-glowing+)
    (setf (brightness mob) (+ (the (signed-byte 30) (brightness mob)) 100)))
  
  (when (< (the fixnum (brightness mob)) 0)
    (setf (brightness mob) 0))
  
  (setf (visible-mobs mob) (append (proper-visible-mobs mob) (shared-visible-mobs mob)))
  (setf (visible-mobs mob) (remove-duplicates (visible-mobs mob))))))

(defun update-visible-mobs-fov (mob)
  (declare (optimize (speed 3)))
  (draw-fov (x mob) (y mob) (z mob) (cur-sight mob) #'(lambda (dx dy dz prev-cell)
                                                        (declare (type fixnum dx dy dz))
                                                        (let* ((exit-result t) (mob-id 0) (cur-sight (cur-sight mob)) (cur-sight-1 (1+ cur-sight))
                                                               (dist (get-distance-3d (x mob) (y mob) (z mob) dx dy dz)))
                                                          (declare (type fixnum mob-id cur-sight cur-sight-1)
                                                                   (type single-float dist))
                                                          (block nil

                                                            ;; CUR-SIGHT-1 is a small integer radius, so
                                                            ;; converting it is exact and this is the same
                                                            ;; comparison - see DISTANCE-3D-UNDER-P.
                                                            (when (> dist (coerce cur-sight-1 'single-float))
                                                              (setf exit-result 'exit)
                                                              (return))
                                                           
                                                            (unless (check-LOS-propagate dx dy dz prev-cell :check-vision t)
                                                              (setf exit-result 'exit)
                                                              (return))
                                                             
                                                            (when (and (get-mob-* (level *world*) dx dy dz) 
                                                                       (not (eq (get-mob-* (level *world*) dx dy dz) mob)))
                                                              (setf mob-id (id (get-mob-* (level *world*) dx dy dz)))
                                                              (pushnew mob-id (visible-mobs mob)))
                                                            
                                                            )
                                                          exit-result)))
  )

(defun update-visible-mobs-all (mob)
  (loop 
    for mob-id in (mob-id-list (level *world*))
    do
       (when (/= mob-id (id mob))
         (pushnew mob-id (visible-mobs mob)))))

(defun update-visible-mobs (mob)
  (setf (visible-mobs mob) nil)
  (setf (proper-visible-mobs mob) nil)
  (setf (shared-visible-mobs mob) nil)
  (setf (hear-range-mobs mob) nil)
  
  
  (if (mob-ability-p mob +mob-abil-see-all+)
    (update-visible-mobs-all mob)
    (update-visible-mobs-normal mob))
  
  
  (when (eq mob *player*)
    (setf (view-x *player*) (x *player*))
    (setf (view-y *player*) (y *player*)))
  (log:info "~A [~A] sees ~A" (name mob) (id mob) (visible-mobs mob))
  )

(defun update-visible-items (mob)
  (declare (optimize (speed 3) (safety 0)))
  (with-vision-block-cache ()
  (setf (visible-items mob) nil)

  ;; MOB does not move while its field of view is computed, so its position and
  ;; sight radius are read once into typed locals: through the generic slot
  ;; accessors they come back as T, which would put every comparison and every
  ;; quadrant index below through generic arithmetic.
  (let ((mob-x (the fixnum (x mob)))
        (mob-y (the fixnum (y mob)))
        (mob-z (the fixnum (z mob)))
        (sight (the (unsigned-byte 30) (cur-sight mob)))
        (quadrants (the (simple-array t (* *)) (item-quadrant-map (level *world*)))))
    (declare (type fixnum mob-x mob-y mob-z)
             ;; narrower than FIXNUM so that the VISION-POWER x PWR-DECREASE
             ;; product below is known to stay in one
             (type (unsigned-byte 30) sight))
    (let ((quad-x (truncate mob-x 10))
          (quad-y (truncate mob-y 10)))
      ;; narrower than FIXNUM so the neighbour offsets below stay in one
      (declare (type (signed-byte 30) quad-x quad-y))

  (loop for item-id of-type fixnum in (quadrant-neighbours quadrants quad-x quad-y)
        for item = (get-item-by-id item-id)
        for vision-pwr of-type fixnum = sight
        for vision-power of-type (unsigned-byte 30) = sight
        when (distance-3d-under-p mob-x mob-y mob-z (the fixnum (x item)) (the fixnum (y item)) (the fixnum (z item)) sight)
          do
             ;; set up visible mobs
             (line-of-sight mob-x mob-y mob-z (x item) (y item) (z item)
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                (let* ((exit-result t) (pwr-decrease 0)) 
                                  (block nil

                                    (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                    (unless pwr-decrease
                                      (setf exit-result 'exit)
                                      (return))
                                    ;; with :CHECK-VISION, CHECK-LOS-PROPAGATE returns
                                    ;; either NIL (ruled out just above) or the cell's
                                    ;; vision-block power, an integer.
                                    (decf vision-pwr (truncate (* vision-power (the (unsigned-byte 30) pwr-decrease)) 100))
                                    (decf vision-pwr)
                                    
                                    ;(unless (check-LOS-propagate dx dy dz prev-cell :check-vision t)
                                    ;  (setf exit-result 'exit)
                                    ;  (return))
                                    
                                    (when (get-items-* (level *world*) dx dy dz) 
                                      (loop for n-item-id of-type fixnum in (get-items-* (level *world*) dx dy dz)
                                            when (= item-id n-item-id)
                                              do
                                                 (pushnew n-item-id (visible-items mob))))

                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return))
                                    )
                                  exit-result))))))
  (log:info "~A [~A] sees ~A" (name mob) (id mob) (visible-items mob))))

(defun update-visible-items-player ()
  (setf (visible-items *player*) nil)
  (let ((vision-power (1+ (cur-sight *player*)))
        (vision-pwr (1+ (cur-sight *player*))))
    (draw-fov (x *player*) (y *player*) (z *player*) (cur-sight *player*)
              #'(lambda (dx dy dz prev-cell)
                  (let ((exit-result t) (pwr-decrease))
                    (block nil
                      (when (> (get-distance-3d (x *player*) (y *player*) (z *player*) dx dy dz) (1+ (cur-sight *player*)))
                        (setf exit-result 'exit)
                        (return))
                      
                      (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t ))
                      (unless pwr-decrease
                        (setf exit-result 'exit)
                        (return))
                      (decf vision-pwr (truncate (* vision-power pwr-decrease) 100))
                      (decf vision-pwr)
                      
                      (when (get-items-* (level *world*) dx dy dz) 
                        (loop for n-item-id in (get-items-* (level *world*) dx dy dz)
                              do
                                 (pushnew n-item-id (visible-items *player*))))

                      (when (<= vision-pwr 0)
                        (setf exit-result 'exit)
                        (return))
                                         
                      )
                    exit-result))
              :LOS-start-func #'(lambda ()
                                  (setf vision-pwr (1+ (cur-sight *player*))))
              :no-z nil
              )) 
  
  )

(defun reveal-cell-on-map (level map-x map-y map-z &key (reveal-mob t))
  ;; drawing terrain
  (let ((glyph-idx)
        (glyph-color)
        (back-color)
        (player nil))
    (if (and (or (eq (get-terrain-* level map-x map-y map-z) +terrain-floor-air+)
                 (eq (get-terrain-* level map-x map-y map-z) +terrain-border-air+))
             (> map-z 0)
             (get-terrain-type-trait (get-terrain-* level map-x map-y (1- map-z)) +terrain-trait-water+))
      (progn
        (setf glyph-idx (glyph-idx (get-terrain-type-by-id (get-terrain-* level map-x map-y (1- map-z)))))
        (setf glyph-color *fov-deep-water-color*)
        (setf back-color (back-color (get-terrain-type-by-id (get-terrain-* level map-x map-y (1- map-z))))))
      (progn
        (setf glyph-idx (glyph-idx (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (setf glyph-color (glyph-color (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (setf back-color (back-color (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (when (< (get-single-memo-light (get-memo-* level map-x map-y map-z))
                 *mob-visibility-threshold*)
          (setf glyph-color *fov-dim-light-color*))))
    
    ;; then feature, if any
    (if (and (or (eq (get-terrain-* level map-x map-y map-z) +terrain-floor-air+)
                 (eq (get-terrain-* level map-x map-y map-z) +terrain-border-air+))
             (> map-z 0)
             (get-terrain-type-trait (get-terrain-* level map-x map-y (1- map-z)) +terrain-trait-water+)
             (null (get-features-* level map-x map-y map-z)))
      (progn
        (when (get-features-* level map-x map-y (1- map-z))
          (let ((ftr (get-feature-by-id (first (get-features-* level map-x map-y (1- map-z))))))
            (when (glyph-idx (get-feature-type-by-id (feature-type ftr)))
              (setf glyph-idx (glyph-idx (get-feature-type-by-id (feature-type ftr))))) 
            (when (glyph-color (get-feature-type-by-id (feature-type ftr)))
              (setf glyph-color (glyph-color (get-feature-type-by-id (feature-type ftr)))))
            (when (back-color (get-feature-type-by-id (feature-type ftr)))
              (setf back-color (back-color (get-feature-type-by-id (feature-type ftr)))))
            )))
      (progn
        (when (get-features-* level map-x map-y map-z)
          (let ((ftr (get-feature-by-id (first (get-features-* level map-x map-y map-z)))))
            (when (glyph-idx (get-feature-type-by-id (feature-type ftr)))
              (setf glyph-idx (glyph-idx (get-feature-type-by-id (feature-type ftr))))) 
            (when (glyph-color (get-feature-type-by-id (feature-type ftr)))
              (setf glyph-color (glyph-color (get-feature-type-by-id (feature-type ftr))))
              (when (< (get-single-memo-light (get-memo-* level map-x map-y map-z))
                       *mob-visibility-threshold*)
                (setf glyph-color *fov-dim-light-color*)))
            (when (back-color (get-feature-type-by-id (feature-type ftr)))
              (setf back-color (back-color (get-feature-type-by-id (feature-type ftr)))))
            ))))
    
    
    ;; then item, if any
    (when (get-items-* level map-x map-y map-z)
      (let ((vitem (get-item-by-id (first (get-items-* level map-x map-y map-z)))))
        (setf glyph-idx (glyph-idx vitem))
        (setf glyph-color (glyph-color vitem))
        (setf back-color (back-color vitem))
        (when (< (get-single-memo-light (get-memo-* level map-x map-y map-z))
                 *mob-visibility-threshold*)
                (setf glyph-color *fov-dim-light-color*))
        ))
    
    ;; finally mob, if any
    (when (and reveal-mob
               (get-mob-* level map-x map-y map-z))
      (let ((vmob (get-mob-* level map-x map-y map-z)))
        (setf glyph-idx (get-current-mob-glyph-idx vmob :x map-x :y map-y :z map-z))
        (setf glyph-color (get-current-mob-glyph-color vmob))
        (setf back-color (get-current-mob-back-color vmob))
        (when (eq vmob *player*)
          (setf player t))
        )
      )
    (set-single-memo-* level map-x map-y map-z
                       :glyph-idx glyph-idx
                       :glyph-color glyph-color
                       :back-color back-color
                       :visibility t
                       :revealed t
                       :player player)
  ))

(defun update-visible-area-normal (level x y z &key (no-z nil))
  (let ((vision-power (1+ (cur-sight *player*)))
        (vision-pwr (1+ (cur-sight *player*))))
    (setf (visible-z-list *player*) ())
    (draw-fov x y z (cur-sight *player*)
              #'(lambda (dx dy dz prev-cell)
                  (let ((exit-result t) (pwr-decrease))
                    (block nil
                      (when (> (get-distance-3d x y z dx dy dz) (1+ (cur-sight *player*)))
                        (setf exit-result 'exit)
                        (return))
                      
                      (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t :player-reveal-cell t))
                      (unless pwr-decrease
                        (setf exit-result 'exit)
                        (return))
                      (decf vision-pwr (truncate (* vision-power pwr-decrease) 100))
                      (decf vision-pwr)
                      
                      (when (and (get-mob-* level dx dy dz) 
                                 (not (eq (get-mob-* level dx dy dz) *player*))
                                 (check-mob-visible (get-mob-* level dx dy dz) :observer *player*)
                                 )
                        ;(format t "~A [~A] (~A ~A ~A)~%" (name (get-mob-* level dx dy dz)) (id (get-mob-* level dx dy dz)) dx dy dz)
                        (pushnew (id (get-mob-* level dx dy dz)) (proper-visible-mobs *player*))
                        
                        )

                      (when (<= vision-pwr 0)
                        (setf exit-result 'exit)
                        (return))
                                         
                      )
                    exit-result))
              :LOS-start-func #'(lambda ()
                                  (setf vision-pwr (1+ (cur-sight *player*))))
              :no-z no-z
              ))

  (setf (visible-mobs *player*) (append (proper-visible-mobs *player*) (shared-visible-mobs *player*)))
  (setf (visible-mobs *player*) (remove-duplicates (visible-mobs *player*)))
  
  (loop for mob-id in (visible-mobs *player*)
        for mob = (get-mob-by-id mob-id)
        do
           (reveal-cell-on-map (level *world*) (x mob) (y mob) (z mob) :reveal-mob t)
           ;; if the terrain has no floor, you can see an indication that there is a mob on the tile below
           (when (and (< (z mob) (1- (array-dimension (terrain (level *world*)) 2)))
                      (get-single-memo-visibility (get-memo-* level (x mob) (y mob) (1+ (z mob))))
                      (get-single-memo-revealed (get-memo-* level (x mob) (y mob) (1+ (z mob))))
                      (not (get-terrain-type-trait (get-terrain-* level (x mob) (y mob) (1+ (z mob))) +terrain-trait-blocks-move-floor+))
                      )
             (if (get-faction-relation (faction *player*) (get-visible-faction mob))
               (set-single-memo-* (level *world*) (x mob) (y mob) (1+ (z mob)) :back-color +color-blue+)
               (set-single-memo-* (level *world*) (x mob) (y mob) (1+ (z mob)) :back-color +color-red+))))
  
  )

(defun update-visible-area-all (level x y z)
  (declare (ignore x y z))
  ;; update visible area
  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (reveal-cell-on-map level x1 y1 z1)
      ))))

(defun update-visible-area (level x y z &key (no-z nil))
  ;; make the the whole level invisible
  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (if (get-single-memo-revealed (get-memo-* level x1 y1 z1))
          (set-single-memo-* level x1 y1 z1 :glyph-color *memo-remembered-color* :back-color +color-black+ :visibility nil)
          (set-single-memo-* level x1 y1 z1 :visibility nil))
      )))

  (setf (visible-mobs *player*) nil)
  (setf (proper-visible-mobs *player*) nil)
  ;(setf (shared-visible-mobs *player*) nil)
  
  (if (mob-ability-p *player* +mob-abil-see-all+)
    (update-visible-area-all level x y z)
    (update-visible-area-normal level x y z :no-z no-z))

  (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*) (view-z *player*) (z *player*))
  
  (log:info "PLAYER-VISIBLE-MOBS: ~A" (visible-mobs *player*))  
  )

(defun draw-fov (cx cy cz r func &key (limit-z nil) (no-z nil) (LOS-start-func #'(lambda () nil)))
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy cz r)
           (type function func LOS-start-func))
  (with-vision-block-cache ()
  (let* ((target-cells nil)
        (max-level-z (array-dimension (the (simple-array fixnum (* * *)) (terrain (level *world*))) 2))
        (max-z (if limit-z
                 (if (>= (+ cz r) max-level-z)
                   (1- max-level-z)
                   (+ cz r))
                 (+ cz r)))
        (min-z (if limit-z
                 (if (< (- cz r) 0)
                   0
                   (- cz r))
                 (- cz r))))
    (declare (type fixnum max-z min-z max-level-z))
    (when no-z
      (setf min-z cz max-z cz))
    
    ;; push the top & bottom z-plane
    (loop for x from (- r) to r
          for dx of-type fixnum = (+ cx x)
          do
             (loop for y from (- r) to r
                   for dy of-type fixnum = (+ cy y)
                   do
                      (push (list dx dy min-z) target-cells)
                      (push (list dx dy max-z) target-cells)))
    
    ;; push all z-planes in between
    (loop for z of-type fixnum from (1+ min-z) to (1- max-z)
          for xr+ of-type fixnum = (+ cx r)
          for xr- of-type fixnum = (- cx r)
          for yr+ of-type fixnum = (+ cy r)
          for yr- of-type fixnum = (- cy r)
          do
             (loop for n from (- r) to r
                   for xn of-type fixnum = (+ cx n)
                   do
                      (push (list xn yr+ z) target-cells)
                      (push (list xn yr- z) target-cells))
             (loop for n from (- r) to r
                   for yn of-type fixnum = (+ cy n)
                   do
                      (push (list xr+ yn z) target-cells)
                      (push (list xr- yn z) target-cells))
          )
  
    ;; check LOS for all perimeter cells
    (loop for (tx ty tz) in target-cells do
      (funcall LOS-start-func)
      (line-of-sight cx cy cz tx ty tz func))

    )))

(defun line-of-sight (x0 y0 z0 x1 y1 z1 func)
  (declare (optimize (speed 3))
           (type fixnum x0 x1 y0 y1 z0 z1)
           (type function func))
  (let* ((dx (abs (- x1 x0)))
         (dy (abs (- y1 y0)))
         (dz (abs (- z1 z0)))
         (sx (if (< x0 x1) 1 -1))
         (sy (if (< y0 y1) 1 -1))
         (sz (if (< z0 z1) 1 -1))
         (dm (max dx dy dz))
         (i dm))
    (declare (type fixnum dx dy dz sx sy sz dm i))
    (setf x1 (truncate dm 2) y1 (truncate dm 2) z1 (truncate dm 2))
    (loop with prev-cell = nil
          while (and (not (< i 0))
                     (not (eq (funcall func x0 y0 z0 prev-cell) 'exit)))
          do
             (decf i)
             (setf prev-cell (list x0 y0 z0))
             (decf x1 dx) (decf y1 dy) (decf z1 dz)
             (when (< x1 0)
               (incf x1 dm)
               (incf x0 sx))
             (when (< y1 0)
               (incf y1 dm)
               (incf y0 sy))
             (when (< z1 0)
               (incf z1 dm)
               (incf z0 sz))
          ))
  )

