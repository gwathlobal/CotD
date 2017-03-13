(in-package :cotd)

(defun get-distance (sx sy tx ty)
  (declare (type fixnum sx sy tx ty))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)))))

(defun get-distance-3d (sx sy sz tx ty tz)
  (declare (type fixnum sx sy sz tx ty tz))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)) (* (- sz tz) (- sz tz)))))

(defun check-LOS-propagate (dx dy dz prev-cell &key (check-move nil) (check-vision nil) (check-projectile nil) (player-reveal-cell nil))
  (let ((terrain))
    (when (or (< dx 0) (>= dx (array-dimension (terrain (level *world*)) 0))
              (< dy 0) (>= dy (array-dimension (terrain (level *world*)) 1))
              (< dz 0) (>= dz (array-dimension (terrain (level *world*)) 2)))
      (return-from check-LOS-propagate nil))
    
    ;; LOS does not propagate vertically through floors
    (when (and prev-cell
               (/= (- (third prev-cell) dz) 0))
      (if (< (- (third prev-cell) dz) 0)
        (setf terrain (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz))
        (setf terrain (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell))))
      (when (or (null terrain)
                (get-terrain-type-trait terrain +terrain-trait-opaque-floor+))
        (return-from check-LOS-propagate nil)))

    (when player-reveal-cell
      (reveal-cell-on-map (level *world*) dx dy dz))
    
    (setf terrain (get-terrain-* (level *world*) dx dy dz))
    (unless terrain
      (return-from check-LOS-propagate nil))

    (when (and check-move
               (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
      (return-from check-LOS-propagate nil))
    
    (when (and check-vision
               (get-terrain-type-trait terrain +terrain-trait-blocks-vision+))
      (return-from check-LOS-propagate nil))
    
    (when (and check-projectile
               (get-terrain-type-trait terrain +terrain-trait-blocks-projectiles+))
      (return-from check-LOS-propagate nil))

    t))

(defun update-visible-mobs-normal (mob)
  (loop for mob-id in (mob-id-list (level *world*))
        for tmob = (get-mob-by-id mob-id)
        when (< (get-distance-3d (x mob) (y mob) (z mob) (x tmob) (y tmob) (z tmob)) (cur-sight mob))
          do
             (line-of-sight (x mob) (y mob) (z mob) (x tmob) (y tmob) (z tmob)
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                (let* ((exit-result t) (mob-id 0)) 
                                  (declare (type fixnum mob-id))
                   
                                  (block nil

                                    (unless (check-LOS-propagate dx dy dz prev-cell :check-vision t)
                                      (setf exit-result 'exit)
                                      (return))
                                    
                                    (when (and (get-mob-* (level *world*) dx dy dz) 
                                               (not (eq (get-mob-* (level *world*) dx dy dz) mob)))
                                      (setf mob-id (id (get-mob-* (level *world*) dx dy dz)))
                                      (pushnew mob-id (visible-mobs mob)))
                                    
                                    )
                                  exit-result)))))

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
  
  
  (if (mob-ability-p mob +mob-abil-see-all+)
    (update-visible-mobs-all mob)
    (update-visible-mobs-normal mob))
  
  
  (when (eq mob *player*)
    (setf (view-x *player*) (x *player*))
    (setf (view-y *player*) (y *player*)))
  (logger (format nil "UPDATE-VISIBLE-MOBS: ~A [~A] sees ~A~%" (name mob) (id mob) (visible-mobs mob)))
  )

(defun reveal-cell-on-map (level map-x map-y map-z)
  ;; drawing terrain
  (let ((glyph-idx)
        (glyph-color)
        (back-color))
    (setf glyph-idx (glyph-idx (get-terrain-type-by-id (aref (terrain level) map-x map-y map-z))))
    (setf glyph-color (glyph-color (get-terrain-type-by-id (aref (terrain level) map-x map-y map-z))))
    (setf back-color (back-color (get-terrain-type-by-id (aref (terrain level) map-x map-y map-z))))
          
    ;; then feature, if any
    (when (get-features-* level map-x map-y map-z)
      (let ((ftr (get-feature-by-id (first (get-features-* level map-x map-y map-z)))))
        (when (glyph-idx (get-feature-type-by-id (feature-type ftr)))
          (setf glyph-idx (glyph-idx (get-feature-type-by-id (feature-type ftr))))) 
        (when (glyph-color (get-feature-type-by-id (feature-type ftr)))
          (setf glyph-color (glyph-color (get-feature-type-by-id (feature-type ftr)))))
        (when (back-color (get-feature-type-by-id (feature-type ftr)))
          (setf back-color (back-color (get-feature-type-by-id (feature-type ftr)))))
        ))
    
    ;; then item, if any
    (when (get-items-* level map-x map-y map-z)
      (let ((vitem (get-item-by-id (first (get-items-* level map-x map-y map-z)))))
        (setf glyph-idx (glyph-idx vitem))
        (setf glyph-color (glyph-color vitem))
        (setf back-color (back-color vitem))
        ))
    
    ;; finally mob, if any
    (when (get-mob-* level map-x map-y map-z)
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

(defun update-visible-area-normal (level x y z)
 
  (draw-fov x y z (cur-sight *player*) #'(lambda (dx dy dz prev-cell)
                                         (let ((exit-result t))
                                           (block nil
                                             
                                             (when (> (get-distance-3d x y z dx dy dz) (1+ (cur-sight *player*)))
                                               (setf exit-result 'exit)
					       (return))

                                             (unless (check-LOS-propagate dx dy dz prev-cell :check-vision t :player-reveal-cell t)
                                               (setf exit-result 'exit)
                                               (return))
                                             
                                             (when (and (get-mob-* level dx dy dz) 
                                                        (not (eq (get-mob-* level dx dy dz) *player*)))
                                               (pushnew (id (get-mob-* level dx dy dz)) (visible-mobs *player*)))
                                             )
					   exit-result))
            )
  
  )

(defun update-visible-area-all (level x y z)
  (declare (ignore x y z))
  ;; update visible area
  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (reveal-cell-on-map level x1 y1 z1)
      ))))

(defun update-visible-area (level x y z)
  ;; make the the whole level invisible
  (dotimes (x1 (array-dimension (memo (level *world*)) 0))
    (dotimes (y1 (array-dimension (memo (level *world*)) 1))
      (dotimes (z1 (array-dimension (memo (level *world*)) 2))
        (if (get-single-memo-revealed (get-memo-* level x1 y1 z1))
          (set-single-memo-* level x1 y1 z1 :glyph-color (sdl:color :r 50 :g 50 :b 50) :visibility nil)
          (set-single-memo-* level x1 y1 z1 :visibility nil))
      )))

  (setf (visible-mobs *player*) nil)
  
  (if (mob-ability-p *player* +mob-abil-see-all+)
    (update-visible-area-all level x y z)
    (update-visible-area-normal level x y z))
  
  (logger (format nil "PLAYER-VISIBLE-MOBS: ~A~%" (visible-mobs *player*)))  
  )

(defun draw-fov (cx cy cz r func &optional (limit-z t))
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy cz r)
           (type function func))
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
      (line-of-sight cx cy cz tx ty tz func)
          )
    
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
