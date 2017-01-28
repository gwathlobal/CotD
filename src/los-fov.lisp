(in-package :cotd)

(defun get-distance (sx sy tx ty)
  (declare (type fixnum sx sy tx ty))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)))))

(defun update-visible-mobs-normal (mob)
  (declare (optimize (speed 3)))
  (draw-fov (x mob) (y mob) (cur-sight mob) #'(lambda (dx dy)
                                                (declare (type fixnum dx dy))
                                                (let ((terrain) (exit-result t) (mob-id 0))
                                                  (declare (type fixnum mob-id))
                                                  (block nil
                                                    (when (or (< dx 0) (>= dx *max-x-level*)
                                                              (< dy 0) (>= dy *max-y-level*))
                                                      (setf exit-result 'exit)
                                                      (return))

                                                    (setf terrain (get-terrain-* (level *world*) dx dy))
                                                    (unless terrain
                                                      (setf exit-result 'exit)
                                                      (return))
                                                    (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
                                                      (setf exit-result 'exit)
                                                      (return))
                                                    (when (and (get-mob-* (level *world*) dx dy) 
                                                               (not (eq (get-mob-* (level *world*) dx dy) mob)))
                                                      (setf mob-id (id (get-mob-* (level *world*) dx dy)))
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

(defun update-visible-area-normal (level x y)
  (draw-fov x y (cur-sight *player*) #'(lambda (dx dy)
                                         (let ((terrain) (exit-result t))
                                           (block nil
                                             (when (or (< dx 0) (>= dx *max-x-level*)
                                                       (< dy 0) (>= dy *max-y-level*))
                                               (setf exit-result 'exit)
					       (return))

                                           ;; drawing terrain
                                           (set-single-memo-* level dx dy 
                                                              :glyph-idx (glyph-idx (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :glyph-color (glyph-color (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :back-color (back-color (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :visibility t
                                                              :revealed t)
                                           		
                                           ;; then feature, if any
                                           (when (get-features-* level dx dy)
                                             (let ((ftr (first (last (get-features-* level dx dy)))))
                                               
                                               (set-single-memo-* level 
                                                                  (x ftr) (y ftr) 
                                                                  :glyph-idx (if (glyph-idx (get-feature-type-by-id (feature-type ftr)))
                                                                               (glyph-idx (get-feature-type-by-id (feature-type ftr)))
                                                                               (get-single-memo-glyph-idx (get-memo-* level (x ftr) (y ftr))))
                                                                  :glyph-color (if (glyph-color (get-feature-type-by-id (feature-type ftr)))
                                                                                 (glyph-color (get-feature-type-by-id (feature-type ftr)))
                                                                                 (get-single-memo-glyph-color (get-memo-* level (x ftr) (y ftr))))
                                                                  :back-color (if (back-color (get-feature-type-by-id (feature-type ftr)))
                                                                                (back-color (get-feature-type-by-id (feature-type ftr)))
                                                                                (get-single-memo-back-color (get-memo-* level (x ftr) (y ftr))))
                                                                  :visibility t
                                                                  :revealed t)))
                                           ;; then mob, if any
                                           (when (get-mob-* level dx dy)
                                             
                                             (let ((vmob (get-mob-* level dx dy)))
                                               (set-single-memo-* level 
                                                                  (x vmob) (y vmob) 
                                                                  :glyph-idx (get-current-mob-glyph-idx vmob)
                                                                  :glyph-color (get-current-mob-glyph-color vmob)
                                                                  :back-color (get-current-mob-back-color vmob)
                                                                  :visibility t
                                                                  :revealed t))
                                             )
                                           ;; checking for impassable objects
                                           
                                           (setf terrain (get-terrain-* level dx dy))
                                           (unless terrain
                                             (setf exit-result 'exit)
                                             (return))
                                           (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
                                             (setf exit-result 'exit)
                                             (return))
                                           (when (and (get-mob-* level dx dy) 
                                                      (not (eq (get-mob-* level dx dy) *player*))
                                                      (get-single-memo-visibility (get-memo-* level dx dy)))
                                             (pushnew (id (get-mob-* level dx dy)) (visible-mobs *player*)))
                                           )
					   exit-result)))
  )

(defun update-visible-area-all (level x y)
  (declare (ignore x y))
  ;; update visible area
  (dotimes (x1 *max-x-level*)
    (dotimes (y1 *max-y-level*)
      (set-single-memo-* level x1 y1 
			 :glyph-idx (glyph-idx (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :glyph-color (glyph-color (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :back-color (back-color (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :visibility t)
      ))
  (dolist (feature-id (feature-id-list level))
    (set-single-memo-* level 
		       (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)) 
		       :glyph-idx (if (glyph-idx (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				      (glyph-idx (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				      (get-single-memo-glyph-idx (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :glyph-color (if (glyph-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
					(glyph-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
					(get-single-memo-glyph-color (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :back-color (if (back-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				       (back-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				       (get-single-memo-back-color (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :visibility t))
  
  (dolist (mob-id (mob-id-list level))
    ;;(format t "MOB NAME ~A, MOB ID ~A, MOB X ~A, MOB Y ~A~%" (name (get-mob-by-id mob-id)) mob-id (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)))
    (set-single-memo-* level 
		       (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)) 
		       :glyph-idx (get-current-mob-glyph-idx (get-mob-by-id mob-id))
		       :glyph-color (get-current-mob-glyph-color (get-mob-by-id mob-id))
		       :back-color (get-current-mob-back-color (get-mob-by-id mob-id))
		       :visibility t)

    ))

(defun update-visible-area (level x y)
  ;; make the the whole level invisible
  (dotimes (x1 *max-x-level*)
    (dotimes (y1 *max-y-level*)
      (if (get-single-memo-revealed (get-memo-* level x1 y1))
        (set-single-memo-* level x1 y1 :glyph-color (sdl:color :r 50 :g 50 :b 50) :visibility nil)
        (set-single-memo-* level x1 y1 :visibility nil))
      ))

  
  (setf (visible-mobs *player*) nil)
  (if (mob-ability-p *player* +mob-abil-see-all+)
    (update-visible-area-all level x y)
    (update-visible-area-normal level x y))
  
  (logger (format nil "PLAYER-VISIBLE-MOBS: ~A~%" (visible-mobs *player*)))
  )

(defun draw-fov (cx cy r func)
  (declare (optimize (speed 3)))
  (declare (type fixnum cx cy r)
           (type function func))
  (funcall func cx cy)
  (let ((target-cells nil))
    (loop for i of-type fixnum from 0 to 360 by 1
          for tx of-type fixnum = (+ cx (round (* r (cos (* i (/ pi 180))))))
          for ty of-type fixnum = (- cy (round (* r (sin (* i (/ pi 180 ))))))
          do
             (unless (find (cons tx ty) target-cells :test #'equal)
               (push (cons tx ty) target-cells)))
    (loop for (tx . ty) in target-cells do
          (line-of-sight cx cy tx ty func))
    ))

(defun line-of-sight (sx sy tx ty func)
  (declare (optimize (speed 3))
           (type fixnum sx sy tx ty)
           (type function func))
  
  ;; stop at once if the starting point = target point
  (when (and (= sx tx) (= sy ty))
    (funcall func sx sy)
    (return-from line-of-sight nil))
 
   (let ((x 0) (y 0) (nx (1+ (abs (- sx tx)))) (ny (1+ (abs (- sy ty))))
         (px 1) (py 1) (slope 0) (ix 0) (iy 0))
     (declare (type fixnum x y nx ny px py ix iy)
              (type rational slope))
     
    ;; determine the direction where to draw the line
    (cond
      ((> sx tx) (setf ix -1))
      ((= sx tx) (setf ix 0))
      (t (setf ix 1)))
    (cond
      ((> sy ty) (setf iy -1))
      ((= sy ty) (setf iy 0))
      (t (setf iy 1)))
    (if (>= nx ny) (setf slope (/ nx ny)) (setf slope (/ ny nx)))
    
    (if (>= nx ny)
	(progn (loop while (< (abs x) nx) do
		    (when (>= (abs x) (round (* slope py)))
		      (incf y iy)
		      (incf py))
		    
		    (when (eql (funcall func (+ sx x) (+ sy y)) 'exit) ;(format t "RET!~%") 
		      (return-from line-of-sight nil))
		    
		    (incf x ix)
		    ))
	(progn (loop while (< (abs y) ny) do
		    (when (>= (abs y) (round (* slope px)))
		      (incf x ix)
		      (incf px))
		    
		    (when (eql (funcall func (+ sx x) (+ sy y)) 'exit) ;(format t "RET!~%") 
			  (return-from line-of-sight nil))
		    
		    (incf y iy)
		    ))))
  t)

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
