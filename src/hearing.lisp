(in-package :cotd)

(defstruct sound
  (x -1)
  (y -1)
  (z -1))

(defun general-direction-dir (sx sy tx ty)
  (let ((a (round (* (atan (- sy ty) (- sx tx)) (/ 180 pi))))
        (result 0))
    (when (and (= sx tx) (= sy ty))
      (return-from general-direction-dir 0))
    (cond
      ((and (> a 22.5) (<= a 67.5)) (setf result 7))
      ((and (> a 67.5) (<= a 112.5)) (setf result 8))
      ((and (> a 112.5) (<= a 157.5)) (setf result 9))
      ((and (< a -22.5) (>= a -67.5)) (setf result 1))
      ((and (< a -67.5) (>= a -112.5)) (setf result 2))
      ((and (< a -112.5) (>= a -157.5)) (setf result 3))
      ((or (> a 157.5) (< a -157.5)) (setf result 6))
      ((or (> a -22.5) (<= a 22.5)) (setf result 4)))
    result))

(defun propagate-sound-from-location (target sx sy sz sound-power sound-str-func &key (force-sound nil) (source nil))
  (let ((sound-pwr sound-power))
    (line-of-sight sx sy sz (x target) (y target) (z target)
                   #'(lambda (dx dy dz prev-cell)
                       (declare (type fixnum dx dy dz))
                       (let* ((exit-result t))   
                         (block nil
                           (let ((pwr-decrease 0) (trait) (x) (y) (z))
                             (cond
                               ((null prev-cell)
                                (progn
                                  (setf trait +terrain-trait-blocks-sound+)
                                  (setf x dx y dy z dz)))
                               ((> (- dz (third prev-cell)) 0)
                                (progn
                                  (setf trait +terrain-trait-blocks-sound-floor+)
                                  (setf x dx y dy z dz)))
                               ((< (- dz (third prev-cell)) 0)
                                (progn
                                  (setf trait +terrain-trait-blocks-sound-floor+)
                                  (setf x (first prev-cell) y (second prev-cell) z (third prev-cell))))
                               (t
                                (progn
                                  (setf trait +terrain-trait-blocks-sound+)
                                  (setf x dx y dy z dz))))

                             
                             
                             (cond
                               ((eq (get-terrain-type-trait (get-terrain-* (level *world*) x y z) trait) t) (progn (setf pwr-decrease 100)
                                                                                                                   (decf sound-pwr (truncate (* sound-power pwr-decrease) 100))))
                               ((eq (get-terrain-type-trait (get-terrain-* (level *world*) x y z) trait) nil) (progn (decf sound-pwr *sound-power-falloff*)))
                               (t (progn (setf pwr-decrease (get-terrain-type-trait (get-terrain-* (level *world*) x y z) trait))
                                         (decf sound-pwr (truncate (* sound-power pwr-decrease) 100)))))
                             ;(format t "TRAIT ~A, (~A ~A ~A) ~A, PWR-DECREASE ~A, SOUND-PWR ~A~%" trait x y z prev-cell pwr-decrease sound-pwr)
                             )
                             
                           (when (<= sound-pwr 0)
                             (setf sound-pwr 0)
                             (setf exit-result 'exit)
                             (return))
                           )
                         exit-result)))

    (logger (format nil "PROPAGATE-SOUND-FROM-LOCATION: Initial sound power ~A, final sound power ~A, Source ~A [~A] (~A ~A ~A), Target ~A [~A] (~A ~A ~A), Sound string ~A~%"
                    sound-power sound-pwr
                    (if source (name source) nil) (if source (id source) nil) sx sy sz
                    (name target) (id target) (x target) (y target) (z target)
                    (funcall sound-str-func "")))
    
    (when (not (zerop sound-pwr))
      (let ((sound-z (cond ((> sz (z target)) 1)
                           ((< sz (z target)) -1)
                           (t 0)))
            (sound-dir)
            (nx sx)
            (ny sy)
            (nz sz)
            (dir-str))
        (when (and (> sound-pwr 10)
                   (or force-sound
                       (null source)     
                       (and source
                            (or (and (not (eq target *player*))
                                     (not (check-mob-visible source :observer target :complete-check t)))
                                (and (eq target *player*)
                                     (not (get-single-memo-visibility (get-memo-* (level *world*) sx sy sz))))
                                (and (eq target *player*)
                                     (get-single-memo-visibility (get-memo-* (level *world*) sx sy sz))
                                     (not (check-mob-visible source :observer target :complete-check nil)))))))
          (format t "VISIBLE-MOBS of ~A [~A] are ~A~%" (name target) (id target) (visible-mobs target))
          (when (< sound-pwr 30)
            (setf nx (+ sx 2 (* -1 (random 5))))
            (when (< nx 0) (setf nx 0))
            (when (>= nx (array-dimension (terrain (level *world*)) 0)) (setf nx (1- (array-dimension (terrain (level *world*)) 0))))
            (setf ny (+ sy 2 (* -1 (random 5))))
            (when (< ny 0) (setf ny 0))
            (when (>= ny (array-dimension (terrain (level *world*)) 1)) (setf ny (1- (array-dimension (terrain (level *world*)) 1)))))
          
          (push (make-sound :x nx :y ny :z nz) (heard-sounds target))
          (setf sound-dir (general-direction-dir (x target) (y target) nx ny))
          (when (eq target *player*)
            (setf dir-str (format nil "~A~A~A"
                                  (cond
                                    ((< (get-distance-3d sx sy sz (x target) (y target) (z target)) 3) " nearby")
                                    ((> (get-distance-3d sx sy sz (x target) (y target) (z target)) 8) " in the distance")
                                    (t ""))
                                  (cond
                                    ((= sound-dir 1) " to the southwest")
                                    ((= sound-dir 2) " to the south")
                                    ((= sound-dir 3) " to the southeast")
                                    ((= sound-dir 4) " to the west")
                                    ((= sound-dir 6) " to the east")
                                    ((= sound-dir 7) " to the northwest")
                                    ((= sound-dir 8) " to the north")
                                    ((= sound-dir 9) " to the northeast")
                                    (t ""))
                                  (cond
                                    ((= sound-z 1) " above")
                                    ((= sound-z -1) " below")
                                    (t ""))))
            (print-visible-message (x target) (y target) (z target) (level *world*) (funcall sound-str-func dir-str))
            ))))))
