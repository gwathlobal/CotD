(in-package :cotd)

(defun get-distance (sx sy tx ty)
  (declare (type fixnum sx sy tx ty))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)))))

(defun get-distance-3d (sx sy sz tx ty tz)
  (declare (type fixnum sx sy sz tx ty tz))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)) (* (- sz tz) (- sz tz)))))

(defun check-LOS-propagate (dx dy dz prev-cell &key (check-move nil) (check-vision nil) (check-projectile nil) (player-reveal-cell nil) (check-sound nil))
  ;(declare (optimize (speed 3)))
  (let ((terrain)
        (vision-block-power 0))
    (when (or (< dx 0) (>= dx (array-dimension (terrain (level *world*)) 0))
              (< dy 0) (>= dy (array-dimension (terrain (level *world*)) 1))
              (< dz 0) (>= dz (array-dimension (terrain (level *world*)) 2)))
      (return-from check-LOS-propagate nil))
    
    ;; LOS does not propagate vertically through floors
    (when (and prev-cell
               (/= (- (third prev-cell) dz) 0)
               (or check-move
                   check-vision
                   check-projectile))
      (if (> (- (third prev-cell) dz) 0)
        ;; prev is up, the tile above current has opaque floor & the prev tile has opaque floor
        (when (and (get-terrain-* (level *world*) dx dy (third prev-cell))
                   (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (third prev-cell)) +terrain-trait-opaque-floor+) t)
                       (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (third prev-cell)) +terrain-trait-opaque-floor+) 100))
                   (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell)) +terrain-trait-opaque-floor+) t)
                       (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell)) +terrain-trait-opaque-floor+) 100)))
          (return-from check-LOS-propagate nil))
        ;; prev is down
        (when (and (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz)
                   (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz) +terrain-trait-opaque-floor+) t)
                       (eq (get-terrain-type-trait (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz) +terrain-trait-opaque-floor+) 100))
                   (get-terrain-* (level *world*) dx dy dz)
                   (or (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-opaque-floor+) t)
                       (eq (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-opaque-floor+) 100)))
          (return-from check-LOS-propagate nil)))
      )

    (when player-reveal-cell
      (reveal-cell-on-map (level *world*) dx dy dz :reveal-mob (if (or (null (get-mob-* (level *world*) dx dy dz))
                                                                       (eq (get-mob-* (level *world*) dx dy dz) *player*))
                                                                 t
                                                                 (check-mob-visible (get-mob-* (level *world*) dx dy dz) :observer *player*))))
    
    (setf terrain (get-terrain-* (level *world*) dx dy dz))
    (unless terrain
      (return-from check-LOS-propagate nil))

    (when (and check-move
               (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
      (return-from check-LOS-propagate nil))
    
    (when (and check-vision
               (get-terrain-type-trait terrain +terrain-trait-blocks-vision+))
      (if (eq (get-terrain-type-trait terrain +terrain-trait-blocks-vision+) t)
        (incf vision-block-power 100)
        (incf vision-block-power (get-terrain-type-trait terrain +terrain-trait-blocks-vision+))))
    
    (when (and check-projectile
               (get-terrain-type-trait terrain +terrain-trait-blocks-projectiles+))
      (return-from check-LOS-propagate nil))

    (when (and check-sound
               (or (eq (get-terrain-type-trait terrain +terrain-trait-blocks-sound+) t)
                   (eq (get-terrain-type-trait terrain +terrain-trait-blocks-sound+) 100)))
      (return-from check-LOS-propagate nil))

    (loop for feature-id in (get-features-* (level *world*) dx dy dz)
          for lvl-feature = (get-feature-by-id feature-id)
          when (and check-vision
                    (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+))
            do
               (if (eq (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+) t)
                 (incf vision-block-power 100)
                 (incf vision-block-power (get-feature-type-trait lvl-feature +feature-trait-blocks-vision+)))
          )

    (when check-vision
      (return-from check-LOS-propagate vision-block-power))
    
    t))

(defun calculate-single-tile-brightness (level x y z &key (calc-for-player nil))
  (let ((brightness 0)) 
    ;; iterate through all mobs
    (loop for mob-id in (if calc-for-player
                          (nearby-light-mobs *player*)
                          (mob-id-list level))
          for tmob = (get-mob-by-id mob-id)
          for light-power = (* *light-power-faloff* (cur-light tmob))
          for vision-pwr = (cur-light tmob)
          for vision-power = (cur-light tmob)
          do
            (when (< (get-distance-3d (x tmob) (y tmob) (z tmob) x y z) (cur-light tmob))
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
                                      
                                      ;; insert set light function here
                                      (when (and (= x dx) (= y dy) (= z dz)
                                                 (> light-power brightness))
                                        (setf brightness light-power)
                                        (setf exit-result 'exit)
                                        (return))
                                      
                                      (decf light-power *light-power-faloff*)

                                      (when (<= vision-pwr 0)
                                        (setf exit-result 'exit)
                                        (return)))
                                    
                                    exit-result))))
        )

    ;; iterate through all stationary sources
    (loop for (tx ty tz light-radius) in (if calc-for-player
                                        (nearby-light-sources *player*)
                                        (coerce (light-sources level) 'list))
          for light-power = (* *light-power-faloff* light-radius)
          for vision-pwr = light-radius
          for vision-power = light-radius
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
    brightness
    ))

(defun calc-lit-tiles-for-player (mob)
  (logger (format nil "CALC-LIT-TILES: ~A [~A]~%" (name mob) (id mob)))

  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (set-single-memo-* (level *world*) x1 y1 z1 :light 0)
        )))
    
  (loop for (tx ty tz) in (visible-tile-list mob)
        for brightness = (- (calculate-single-tile-brightness (level *world*) tx ty tz :calc-for-player t)
                            (get-outdoor-light-* (level *world*) tx ty tz))
        do
           (when (> brightness (get-single-memo-light (get-memo-* (level *world*) tx ty tz)))
             (set-single-memo-* (level *world*) tx ty tz :light brightness))
        ))

(defun update-visible-mobs-normal (mob)
  (setf (brightness mob) 0)
  (when (eq mob *player*)
    (setf (nearby-light-mobs *player*) nil)
    (setf (nearby-light-sources *player*) nil))
  
  ;; check through all stationary light sources
  (loop for (x y z light-radius) across (light-sources (level *world*))
        for i from 0 below (length (light-sources (level *world*)))
        for light-power = (* *light-power-faloff* light-radius)
        for vision-pwr = light-radius
        for vision-power = light-radius
        do
           ;; set up mob brightness
           (when (and (not (zerop light-radius))
                      (< (get-distance-3d x y z (x mob) (y mob) (z mob)) light-radius))
               (line-of-sight x y z (x mob) (y mob) (z mob)
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

                                    (when (and (get-mob-* (level *world*) dx dy dz) 
                                               (eq (get-mob-* (level *world*) dx dy dz) mob)
                                               (> light-power (brightness mob)))
                                      (setf (brightness mob) light-power))
                                    (decf light-power *light-power-faloff*)

                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return)))
                                    
                                  exit-result))))
           ;; set up nearby stationary light sources for player
           (when (and (eq mob *player*)
                      (< (get-distance-3d x y z (x mob) (y mob) (z mob)) (+ light-radius (cur-sight mob))))
             (push (list x y z light-radius) (nearby-light-sources *player*)))
        )
  
  (loop for mob-id in (mob-id-list (level *world*))
        for tmob = (get-mob-by-id mob-id)
        for vision-pwr = (cur-sight mob)
        for vision-power = (cur-sight mob)
        for light-power = (* *light-power-faloff* (cur-light tmob))
        for light-pwr = (cur-light tmob)
        for light-power-base = (cur-light tmob)
        do
           ;; if you share minds with your faction - add all your faction mobs and all mobs that they see
           (when (and (not (eq mob tmob))
                      (mob-ability-p mob +mob-abil-shared-minds+)
                      (mob-ability-p tmob +mob-abil-shared-minds+)
                      (= (faction mob) (faction tmob)))
             (pushnew (id tmob) (shared-visible-mobs mob))
               ;(format t "~A [~A] sees ~A~%" (name tmob) (id tmob) (visible-mobs tmob))
             (loop for vmob-id in (proper-visible-mobs tmob)
                   when (not (check-dead (get-mob-by-id vmob-id)))
                     do
                        (pushnew vmob-id (shared-visible-mobs mob)))
             (setf (shared-visible-mobs mob) (remove (id mob) (shared-visible-mobs mob))))
    
           ;; set up visible mobs
           (when (and (not (eq mob tmob))
                      (< (get-distance-3d (x mob) (y mob) (z mob) (x tmob) (y tmob) (z tmob)) (cur-sight mob)))
             (line-of-sight (x mob) (y mob) (z mob) (x tmob) (y tmob) (z tmob)
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                (let* ((exit-result t) (mob-id 0) (pwr-decrease 0)) 
                                  (declare (type fixnum mob-id))
                                  
                                  (block nil
                                    
                                    (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                    (unless pwr-decrease
                                      (setf exit-result 'exit)
                                        (return))
                                    (decf vision-pwr (truncate (* vision-power pwr-decrease) 100))
                                    (decf vision-pwr)
                                    
                                    (when (and (get-mob-* (level *world*) dx dy dz) 
                                               (not (eq (get-mob-* (level *world*) dx dy dz) mob))
                                               (check-mob-visible (get-mob-* (level *world*) dx dy dz) :observer mob))
                                        ;(format t "VISIBILITY ~A ~A" (name (get-mob-* (level *world*) dx dy dz)) (get-mob-visibility (get-mob-* (level *world*) dx dy dz)))
                                      (setf mob-id (id (get-mob-* (level *world*) dx dy dz)))
                                      (pushnew mob-id (proper-visible-mobs mob)))
                                    
                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return))
                                    
                                    )
                                  exit-result))))
           ;; set up mob brightness
           (when (and (< (get-distance-3d (x tmob) (y tmob) (z tmob) (x mob) (y mob) (z mob)) (cur-light tmob))
                      ;(not (eq mob tmob))
                      )
             (line-of-sight (x tmob) (y tmob) (z tmob) (x mob) (y mob) (z mob)
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                (let* ((exit-result t) (pwr-decrease 0)) 
                                  (block nil
                                    
                                    (setf pwr-decrease (check-LOS-propagate dx dy dz prev-cell :check-vision t))
                                    (unless pwr-decrease
                                      (setf exit-result 'exit)
                                      (return))
                                    (decf light-pwr (truncate (* light-power-base pwr-decrease) 100))
                                    (decf light-pwr)

                                    (when (and (get-mob-* (level *world*) dx dy dz) 
                                               (eq (get-mob-* (level *world*) dx dy dz) mob)
                                               (> light-power (brightness mob)))
                                      (setf (brightness mob) light-power))
                                    (decf light-power *light-power-faloff*)

                                    (when (<= light-pwr 0)
                                      (setf exit-result 'exit)
                                      (return)))
                                    
                                  exit-result))))

           ;; set up nearby mobs that are light sources for player
           (when (and (eq mob *player*)
                      (not (zerop (cur-light tmob)))
                      (< (get-distance-3d (x tmob) (y tmob) (z tmob) (x mob) (y mob) (z mob)) (+ (cur-light tmob) (cur-sight mob))))
             (push (id tmob) (nearby-light-mobs *player*)))
           
           ;; set up mobs that potentially hear you
           (when (and (not (eq mob tmob))
                      (< (get-distance-3d (x tmob) (y tmob) (z tmob) (x mob) (y mob) (z mob)) *max-hearing-range*))
             (pushnew mob-id (hear-range-mobs mob)))
        )

  (when (eq mob *player*)
    (calc-lit-tiles-for-player *player*))
  
  (incf (brightness mob) (get-outdoor-light-* (level *world*) (x mob) (y mob) (z mob)))
  
  (setf (visible-mobs mob) (append (proper-visible-mobs mob) (shared-visible-mobs mob)))
  (setf (visible-mobs mob) (remove-duplicates (visible-mobs mob))))

(defun update-visible-mobs-fov (mob)
  (declare (optimize (speed 3)))
  (draw-fov (x mob) (y mob) (z mob) (cur-sight mob) #'(lambda (dx dy dz prev-cell)
                                                        (declare (type fixnum dx dy dz))
                                                        (let* ((exit-result t) (mob-id 0) (cur-sight (cur-sight mob)) (cur-sight-1 (1+ cur-sight))
                                                               (dist (get-distance-3d (x mob) (y mob) (z mob) dx dy dz)))
                                                          (declare (type fixnum mob-id cur-sight cur-sight-1)
                                                                   (type float dist))
                                                          (block nil

                                                            (when (> dist cur-sight-1)
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
  
  
  (if (mob-ability-p mob +mob-abil-see-all+)
    (update-visible-mobs-all mob)
    (update-visible-mobs-normal mob))
  
  
  (when (eq mob *player*)
    (setf (view-x *player*) (x *player*))
    (setf (view-y *player*) (y *player*)))
  (logger (format nil "UPDATE-VISIBLE-MOBS: ~A [~A] sees ~A~%" (name mob) (id mob) (visible-mobs mob)))
  )

(defun update-visible-items (mob)
  (setf (visible-items mob) nil)
  
  (loop for item-id in (item-id-list (level *world*))
        for item = (get-item-by-id item-id)
        for vision-pwr = (cur-sight mob)
        for vision-power = (cur-sight mob)
        when (< (get-distance-3d (x mob) (y mob) (z mob) (x item) (y item) (z item)) (cur-sight mob))
          do
             ;; set up visible mobs
             (line-of-sight (x mob) (y mob) (z mob) (x item) (y item) (z item)
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
                                    
                                    ;(unless (check-LOS-propagate dx dy dz prev-cell :check-vision t)
                                    ;  (setf exit-result 'exit)
                                    ;  (return))
                                    
                                    (when (get-items-* (level *world*) dx dy dz) 
                                      (loop for n-item-id in (get-items-* (level *world*) dx dy dz)
                                            when (= item-id n-item-id)
                                              do
                                                 (pushnew n-item-id (visible-items mob))))

                                    (when (<= vision-pwr 0)
                                      (setf exit-result 'exit)
                                      (return))
                                    )
                                  exit-result))))
  (logger (format nil "UPDATE-VISIBLE-ITEMS: ~A [~A] sees ~A~%" (name mob) (id mob) (visible-items mob))))

(defun reveal-cell-on-map (level map-x map-y map-z &key (reveal-mob t))
  ;; drawing terrain
  (let ((glyph-idx)
        (glyph-color)
        (back-color))
    (if (and (or (eq (get-terrain-* level map-x map-y map-z) +terrain-floor-air+)
                 (eq (get-terrain-* level map-x map-y map-z) +terrain-border-air+))
             (> map-z 0)
             (get-terrain-type-trait (get-terrain-* level map-x map-y (1- map-z)) +terrain-trait-water+))
      (progn
        (setf glyph-idx (glyph-idx (get-terrain-type-by-id (get-terrain-* level map-x map-y (1- map-z)))))
        (setf glyph-color (sdl:color :r 0 :g 0 :b 128))
        (setf back-color (back-color (get-terrain-type-by-id (get-terrain-* level map-x map-y (1- map-z))))))
      (progn
        (setf glyph-idx (glyph-idx (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (setf glyph-color (glyph-color (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (setf back-color (back-color (get-terrain-type-by-id (get-terrain-* level map-x map-y map-z))))
        (when (< (+ (get-single-memo-light (get-memo-* level map-x map-y map-z))
                    (get-outdoor-light-* level map-x map-y map-z))
                 *mob-visibility-threshold*)
          (setf glyph-color (sdl:color :r 25 :g 25 :b 112)))))
    
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
              (when (< (+ (get-single-memo-light (get-memo-* level map-x map-y map-z))
                    (get-outdoor-light-* level map-x map-y map-z))
                       *mob-visibility-threshold*)
                (setf glyph-color (sdl:color :r 25 :g 25 :b 112))))
            (when (back-color (get-feature-type-by-id (feature-type ftr)))
              (setf back-color (back-color (get-feature-type-by-id (feature-type ftr)))))
            ))))
    
    
    ;; then item, if any
    (when (get-items-* level map-x map-y map-z)
      (let ((vitem (get-item-by-id (first (get-items-* level map-x map-y map-z)))))
        (setf glyph-idx (glyph-idx vitem))
        (setf glyph-color (glyph-color vitem))
        (setf back-color (back-color vitem))
        (when (< (+ (get-single-memo-light (get-memo-* level map-x map-y map-z))
                    (get-outdoor-light-* level map-x map-y map-z))
                       *mob-visibility-threshold*)
                (setf glyph-color (sdl:color :r 25 :g 25 :b 112)))
        ))
    
    ;; finally mob, if any
    (when (and reveal-mob
               (get-mob-* level map-x map-y map-z))
      (let ((vmob (get-mob-* level map-x map-y map-z)))
        (setf glyph-idx (get-current-mob-glyph-idx vmob :x map-x :y map-y :z map-z))
        (setf glyph-color (get-current-mob-glyph-color vmob))
        (setf back-color (get-current-mob-back-color vmob))
        )
      )
    (set-single-memo-* level map-x map-y map-z
                       :glyph-idx glyph-idx
                       :glyph-color glyph-color
                       :back-color back-color
                       :visibility t
                       :revealed t)
  ))

(defun update-visible-area-normal (level x y z &key (no-z nil))
  (let ((vision-power (1+ (cur-sight *player*)))
        (vision-pwr (1+ (cur-sight *player*))))
    (setf (visible-tile-list *player*) nil)
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
                        (pushnew (id (get-mob-* level dx dy dz)) (proper-visible-mobs *player*))
                        
                        )

                      (push (list dx dy dz) (visible-tile-list *player*))
                      
                      (when (<= vision-pwr 0)
                        (setf exit-result 'exit)
                        (return))
                      
                    ;(unless (check-LOS-propagate dx dy dz prev-cell :check-vision t :player-reveal-cell t)
                    ;  (setf exit-result 'exit)
                    ;  (return))
                                          
                      )
                    exit-result))
              :LOS-start-func #'(lambda ()
                                  (setf vision-pwr (1+ (cur-sight *player*))))
              :no-z no-z
              ))

  (setf (visible-tile-list *player*) (remove-duplicates (visible-tile-list *player*)
                                                        :test #'(lambda (a b)
                                                                  (if (and (= (first a) (first b))
                                                                           (= (second a) (second b))
                                                                           (= (third a) (third b)))
                                                                    t
                                                                    nil))))

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
                      (not (get-terrain-type-trait (get-terrain-* level (x mob) (y mob) (1+ (z mob))) +terrain-trait-opaque-floor+))
                      )
             (if (get-faction-relation (faction *player*) (get-visible-faction mob))
               (set-single-memo-* (level *world*) (x mob) (y mob) (1+ (z mob)) :back-color sdl:*blue*)
               (set-single-memo-* (level *world*) (x mob) (y mob) (1+ (z mob)) :back-color sdl:*red*))))
  
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
          (set-single-memo-* level x1 y1 z1 :glyph-color (sdl:color :r 50 :g 50 :b 50) :back-color sdl:*black* :visibility nil)
          (set-single-memo-* level x1 y1 z1 :visibility nil))
      )))

  (setf (visible-mobs *player*) nil)
  (setf (proper-visible-mobs *player*) nil)
  ;(setf (shared-visible-mobs *player*) nil)
  
  (if (mob-ability-p *player* +mob-abil-see-all+)
    (update-visible-area-all level x y z)
    (update-visible-area-normal level x y z :no-z no-z))

  (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*) (view-z *player*) (z *player*))
  
  (logger (format nil "PLAYER-VISIBLE-MOBS: ~A~%" (visible-mobs *player*)))  
  )

(defun draw-fov (cx cy cz r func &key (limit-z nil) (no-z nil) (LOS-start-func #'(lambda () nil)))
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy cz r)
           (type function func LOS-start-func))
  (let ((target-cells nil)
        (max-z (if limit-z
                 (if (>= (+ cz r) (array-dimension (terrain (level *world*)) 2))
                   (1- (array-dimension (terrain (level *world*)) 2))
                   (+ cz r))
                 (+ cz r)))
        (min-z (if limit-z
                 (if (< (- cz r) 0)
                   0
                   (- cz r))
                 (- cz r))))
    (declare (type fixnum max-z min-z))
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
    
    ))

(defun draw-fov-old (cx cy cz r func)
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy cz r)
           (type function func))
  (let ((target-cells nil))
    (loop for i of-type fixnum from 0 to 360 by 1
          for tx of-type fixnum = (+ cx (round (* r (cos (* i (/ pi 180))))))
          for ty of-type fixnum = (- cy (round (* r (sin (* i (/ pi 180 ))))))
          do
             (unless (find (cons tx ty) target-cells :test #'equal)
               (push (cons tx ty) target-cells)))
    (loop for (tx . ty) in target-cells do
      (line-of-sight cx cy cz tx ty cz func))
    ))

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

(defun update-visible-mobs-cube (mob)
  (let ((max-x (if (>= (+ (x mob) (cur-sight mob)) (array-dimension (terrain (level *world*)) 0))
                   (1- (array-dimension (terrain (level *world*)) 0))
                   (+ (x mob) (cur-sight mob))))
        (min-x (if (< (- (x mob) (cur-sight mob)) 0)
                   0
                   (- (x mob) (cur-sight mob))))
        (max-y (if (>= (+ (y mob) (cur-sight mob)) (array-dimension (terrain (level *world*)) 1))
                   (1- (array-dimension (terrain (level *world*)) 1))
                   (+ (y mob) (cur-sight mob))))
        (min-y (if (< (- (y mob) (cur-sight mob)) 0)
                   0
                   (- (y mob) (cur-sight mob))))
        (max-z (if (>= (+ (z mob) (cur-sight mob)) (array-dimension (terrain (level *world*)) 2))
                   (1- (array-dimension (terrain (level *world*)) 2))
                   (+ (z mob) (cur-sight mob))))
        (min-z (if (< (- (z mob) (cur-sight mob)) 0)
                   0
                   (- (z mob) (cur-sight mob)))))
  (loop for dx from min-x to max-x do
    (loop for dy from min-y to max-y do
      (loop for dz from min-z to max-z
            do
               (block nil
                 ;(when (or (< dx 0) (< dy 0) (< dz 0) (>= dx (array-dimension (terrain (level *world*)) 0)) (>= dy (array-dimension (terrain (level *world*)) 1)) (>= dz (array-dimension (terrain (level *world*)) 2)))
                 ;  (return))

                 (when (get-mob-* (level *world*) dx dy dz)
                   (line-of-sight (x mob) (y mob) (z mob) dx dy dz
                                  #'(lambda (dx dy dz prev-cell)
                                      (declare (type fixnum dx dy dz))
                                      (let* ((exit-result t) (mob-id 0) (cur-sight (cur-sight mob)) (cur-sight-1 (1+ cur-sight))
                                             (dist (get-distance-3d (x mob) (y mob) (z mob) dx dy dz)))
                                        (declare (type fixnum mob-id cur-sight cur-sight-1)
                                                 (type float dist))
                                        (block nil
                                          
                                          (when (> dist cur-sight-1)
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
                                        exit-result))))
                 ))))))

(defun fov-shadow-casting (cx cy r opaque-func vis-func)
  (funcall vis-func cx cy)
  (labels ((compute (octant sx sy r x top bottom)
             (loop for x1 from x to r
                   with top-y
                   with bottom-y
                   with was-opaque 
                   do
                      (setf top-y (if (= (car top) 1)
                                    x1
                                    (truncate (+ (* (1+ (* x1 2))
                                                    (cdr top))
                                                 (car top)
                                                 -1)
                                              (* 2 (car top)))))
                      (setf bottom-y (if (= (cdr bottom) 0)
                                       0
                                       (truncate (+ (* (- (* 2 x1) 1)
                                                       (cdr bottom))
                                                    (car bottom))
                                                 (* 2 (car bottom)))))
                      (setf was-opaque -1) ;; 0:false, 1:true, -1:not applicable

                      ;(format t "LOOP 1: x1 ~A was-opaque ~A~%" x1 was-opaque)
                      
                      (loop for y1 from top-y downto bottom-y
                            with tx
                            with ty
                            with in-range
                            with is-opaque
                            do
                               
                               (setf tx sx)
                               (setf ty sy)
                               (cond
                                 ((= octant 0) (incf tx x1) (decf ty y1))
                                 ((= octant 1) (incf tx y1) (decf ty x1))
                                 ((= octant 2) (decf tx y1) (decf ty x1))
                                 ((= octant 3) (decf tx x1) (decf ty y1))
                                 ((= octant 4) (decf tx x1) (incf ty y1))
                                 ((= octant 5) (decf tx y1) (incf ty x1))
                                 ((= octant 6) (incf tx y1) (incf ty x1))
                                 ((= octant 7) (incf tx x1) (incf ty y1))
                                 )
                               (setf in-range (< (get-distance sx sy tx ty) r))
                               
                               (when (and in-range
                                          (or (/= y1 top-y)
                                              (>= (* (cdr top) x1)
                                                  (* (car top) y1)))
                                          (or (/= y1 bottom-y)
                                              (<= (* (cdr bottom) x1)
                                                  (* (car bottom) y1)))
                                          )
                                 (funcall vis-func tx ty))
                               

                               (setf is-opaque (or (not in-range)
                                                   (funcall opaque-func tx ty)))

                               ;(format t "LOOP 2: tx ~A, ty ~A, was-opaque ~A, is-opaque ~A, octant ~A~%" tx ty was-opaque is-opaque octant)
                               
                               (when (/= x1 r)
                                 (if is-opaque
                                   (progn
                                     (when (= was-opaque 0)
                                       (if (or (not in-range)
                                               (= y1 bottom-y))
                                         (progn
                                           (setf bottom (cons (- (* x1 2) 1) (1+ (* y1 2)) ))
                                           
                                           (loop-finish)) 
                                         (progn
                                           ;(format t "LOOP: tx ~A, ty ~A, opaque ~A, was-opaque ~A, dist ~A vs r ~A~%" tx ty is-opaque was-opaque (get-distance sx sy tx ty) r)
                                           (compute octant sx sy r (1+ x1) top (cons (- (* x1 2) 1) (1+ (* y1 2))))))
                                       )
                                     (setf was-opaque 1))
                                   (progn
                                     (when (> was-opaque 0) (setf top (cons (1+ (* x1 2)) (1+ (* y1 2)) )))
                                     (setf was-opaque 0))))
                            )
                      (when (/= was-opaque 0) (loop-finish))
                   )))
    
    (loop for octant from 0 below 8 do
      (compute octant cx cy r 1 (cons 1 1) (cons 1 0)))
    
    )
  )

(defun fov-milazzo-algorithm (cx cy r opaque-func vis-func)
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy r)
           (type function opaque-func vis-func))
  (funcall vis-func cx cy)
  (labels ((>-slope (slope x y) (declare (type fixnum x y) (type cons slope)) (return-from >-slope (> (* (cdr slope) x) (* (car slope) y))))
           (>=-slope (slope x y) (declare (type fixnum x y) (type cons slope)) (return-from >=-slope (>= (* (cdr slope) x) (* (car slope) y))))
           (<-slope (slope x y) (declare (type fixnum x y) (type cons slope)) (return-from <-slope (< (* (cdr slope) x) (* (car slope) y))))
           (<=-slope (slope x y) (declare (type fixnum x y) (type cons slope)) (return-from <=-slope (<= (* (cdr slope) x) (* (car slope) y))))
           (blocks-light (x y octant sx sy)
             (declare (type fixnum x y octant sx sy))
             (let ((nx sx)
                   (ny sy))
               (cond
                 ((= octant 0) (incf nx x) (decf ny y))
                 ((= octant 1) (incf nx y) (decf ny x))
                 ((= octant 2) (decf nx y) (decf ny x))
                 ((= octant 3) (decf nx x) (decf ny y))
                 ((= octant 4) (decf nx x) (incf ny y))
                 ((= octant 5) (decf nx y) (incf ny x))
                 ((= octant 6) (incf nx y) (incf ny x))
                 ((= octant 7) (incf nx x) (incf ny y)))
               (funcall opaque-func nx ny)))
           (set-visible (x y octant sx sy)
             (declare (type fixnum x y octant sx sy))
             (let ((nx sx)
                   (ny sy))
               (cond
                 ((= octant 0) (incf nx x) (decf ny y))
                 ((= octant 1) (incf nx y) (decf ny x))
                 ((= octant 2) (decf nx y) (decf ny x))
                 ((= octant 3) (decf nx x) (decf ny y))
                 ((= octant 4) (decf nx x) (incf ny y))
                 ((= octant 5) (decf nx y) (incf ny x))
                 ((= octant 6) (incf nx y) (incf ny x))
                 ((= octant 7) (incf nx x) (incf ny y)))
               (funcall vis-func nx ny)))
           (compute (octant sx sy r x top bottom)
             (declare (type fixnum sx sy r x)
                      (type cons top bottom))
             (loop for x1 from x to r
                   with top-y of-type fixnum
                   with ax of-type fixnum
                   with bottom-y of-type fixnum
                   with was-opaque of-type fixnum
                   do
                      (if (= (cdr top) 1)
                        (setf top-y x1)
                        (progn 
                          (setf top-y (truncate (+ (* (- (* x1 2) 1)
                                                      (cdr top))
                                                   (car top))
                                                (* 2 (car top))))
                          (if (blocks-light x1 top-y octant sx sy)
                            (progn
                              (when (and (>=-slope top (* x1 2) (1+ (* top-y 2)))
                                         (not (blocks-light x1 (1+ top-y) octant sx sy)))
                                (incf top-y)))
                            (progn
                              (setf ax (* x1 2))
                              (when (blocks-light (1+ x1) (1+ top-y) octant sx sy) (incf ax))
                              (when (>-slope top ax (1+ (* top-y 2))) (incf top-y))))))
                      (if (= (cdr bottom) 0)
                        (setf bottom-y 0)
                        (progn 
                          (setf bottom-y (truncate (+ (* (- (* x1 2) 1)
                                                      (cdr bottom))
                                                   (car bottom))
                                                   (* 2 (car bottom))))
                          (when (and (>=-slope bottom (* x1 2) (1+ (* bottom-y 2)))
                                     (blocks-light x1 bottom-y octant sx sy)
                                     (not (blocks-light x1 (1+ bottom-y) octant sx sy)))
                            (incf bottom-y))))
                      (setf was-opaque -1) ;;0:false, 1:true, -1:not applicable
                      (loop for y1 from top-y downto bottom-y
                            with is-opaque of-type boolean
                            with is-visible of-type boolean
                            with nx of-type fixnum
                            with ny of-type fixnum
                            do
                               (when (< (get-distance 0 0 x1 y1) r)
                                 (setf is-opaque (blocks-light x1 y1 octant sx sy))
                                 (setf is-visible (or is-opaque
                                                      (and (or (/= y1 top-y)
                                                               (>=-slope top x1 y1))
                                                           (or (/= y1 bottom-y)
                                                               (<=-slope bottom x1 y1)))))
                                 ;(setf is-visible (or is-opaque
                                 ;                     (and (or (/= y1 top-y)
                                 ;                              (>-slope top (1+ (* x1 7)) (- (* y1 7) 1)))
                                 ;                          (or (/= y1 bottom-y)
                                 ;                              (<-slope bottom (- (* x1 7) 1) (+ (* y1 7) 1))))))
                                 (when is-visible (set-visible x1 y1 octant sx sy))
                                 (when (/= x1 r)
                                   (if is-opaque
                                     (progn
                                       (when (= was-opaque 0)
                                         (setf nx (* x1 2))
                                         (setf ny (1+ (* y1 2)))
                                         (when (blocks-light x1 (1+ y1) octant sx sy) (decf nx))
                                         (if (>-slope top nx ny)
                                           (if (= y1 bottom-y)
                                             (progn
                                               (setf bottom (cons nx ny))
                                               (loop-finish))
                                             (compute octant sx sy r (1+ x1) top (cons nx ny)))
                                           (when (= y1 bottom-y)
                                             (return-from compute nil))))
                                       (setf was-opaque 1))
                                     (progn
                                       (when (> was-opaque 0)
                                         (setf nx (* x1 2))
                                         (setf ny (1+ (* y1 2)))
                                         (when (blocks-light (1+ x1) (1+ y1) octant sx sy) (incf nx))
                                         (when (>=-slope bottom nx ny) (return-from compute nil))
                                         (setf top (cons nx ny)))
                                       (setf was-opaque 0))))))
                      (when (/= was-opaque 0) (loop-finish))
                      
                   )))
    
    (loop for octant from 0 below 8 do
      (compute octant cx cy r 1 (cons 1 1) (cons 1 0)))
    
    ))

;;-----------------------------
;; FOV Multithreading function
;;-----------------------------

#||
(defun thread-fov-loop (stream)
  (loop while t do
    (bt:with-lock-held ((fov-lock *world*))
      ;(format stream "~%THREAD: cur-mob-fov ~A, player turn ~A~%" (cur-mob-fov *world*) (not (made-turn *player*)))
      (if (and (< (cur-mob-fov *world*) (length (mob-id-list (level *world*))))
               ;(not (made-turn *player*))
               )
        (progn
          (when (not (dead= (get-mob-by-id (cur-mob-fov *world*))))
            (logger (format nil "~%THREAD: Mob ~A [~A] calculates FOV~%" (name (get-mob-by-id (cur-mob-fov *world*))) (id (get-mob-by-id (cur-mob-fov *world*)))) stream)
            
            (let ((mob (get-mob-by-id (cur-mob-fov *world*))))
              ;; setting the fov-map to nil
              (loop for x from 0 below (array-dimension (fov-map mob) 0) do
                (loop for y from 0 below (array-dimension (fov-map mob) 1) do
                  (loop for z from 0 below (array-dimension (fov-map mob) 2) do
                    (setf (aref (fov-map mob) x y z) nil))))
              
              (draw-fov (x mob) (y mob) (z mob) (cur-sight mob)
                        #'(lambda (dx dy dz)
                            (declare (type fixnum dx dy dz))
                            (let* ((terrain) (exit-result t) (cur-sight (cur-sight mob)) (cur-sight-1 (1+ cur-sight))
                                 (dist (get-distance-3d (x mob) (y mob) (z mob) dx dy dz)))
                            (declare (type fixnum cur-sight cur-sight-1)
                                     (type float dist))
                            (block nil
                              (when (or (< dx 0) (>= dx (array-dimension (terrain (level *world*)) 0))
                                        (< dy 0) (>= dy (array-dimension (terrain (level *world*)) 1))
                                        (< dz 0) (>= dz (array-dimension (terrain (level *world*)) 2)))
                                (setf exit-result 'exit)
                                (return))
                              (when (> dist cur-sight-1)
                                (setf exit-result 'exit)
                                (return))
                              
                              
                              (setf terrain (get-terrain-* (level *world*) dx dy dz))
                              (unless terrain
                                (setf exit-result 'exit)
                                (return))
                              (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
                                (setf exit-result 'exit)
                                (return))

                              (setf (aref (fov-map mob)
                                          (- dx (- (x mob) *max-mob-sight*))
                                          (- dy (- (y mob) *max-mob-sight*))
                                          (- dz (- (z mob) *max-mob-sight*)))
                                    t)
                              )
                              exit-result)))
            ))
          (incf (cur-mob-fov *world*))
          )
        (progn
          (logger (format nil "THREAD: Done calculating FOVs~%~%") stream)
          (setf (cur-mob-fov *world*) (length (mob-id-list (level *world*))))
          (bt:condition-wait (fov-cv *world*) (fov-lock *world*)))
        
        ))))
||#
