(in-package :cotd)

(set-anim-type (make-animation-type :id +anim-type-fire-dot+
                                    :func #'(lambda (animation)
                                              (let ((x (anim-x animation))
                                                    (y (anim-y animation))
                                                    (glyph-idx 10)
                                                    (glyph-color (sdl:color :r 255 :g 140 :b 0))
                                                    (back-color sdl:*black*))
                                                (display-animation-on-map x y glyph-idx glyph-color back-color)
                                                ))
                                                  
                                    ))

(set-anim-type (make-animation-type :id +anim-type-severed-body-part+
                                    :func #'(lambda (animation)
                                              (let ((tx) (ty) (tz) (rx) (ry) (item)
                                                    (mob (first (anim-params animation)))
                                                    (body-part-str (second (anim-params animation))))

                                                (setf rx (- (random 7) 3))
                                                (setf ry (- (random 7) 3))
                                                (setf tx rx ty ry tz (z mob))
                                                
                                                (line-of-sight (x mob) (y mob) (z mob) (+ (x mob) rx) (+ (y mob) ry) (z mob)
                                                               #'(lambda (dx dy dz prev-cell)
                                                                   (declare (type fixnum dx dy dz))
                                                                   (let ((terrain) (exit-result t))
                                                                     (block nil
                                                                       (when (or (< dx 0) (>= dx (array-dimension (terrain (level *world*)) 0))
                                                                                 (< dy 0) (>= dy (array-dimension (terrain (level *world*)) 1))
                                                                                 (< dz 0) (>= dz (array-dimension (terrain (level *world*)) 2)))
                                                                         (setf exit-result 'exit)
                                                                         (return))
                                                                       
                                                                       ;; LOS does not propagate vertically through floors
                                                                       (when (and prev-cell
                                                                                  (/= (- (third prev-cell) dz) 0))
                                                                         (if (< (- (third prev-cell) dz) 0)
                                                                           (setf terrain (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) dz))
                                                                           (setf terrain (get-terrain-* (level *world*) (first prev-cell) (second prev-cell) (third prev-cell))))
                                                                         (when (or (null terrain)
                                                                                   (get-terrain-type-trait terrain +terrain-trait-opaque-floor+))
                                                                           (setf exit-result 'exit)
                                                                           (return)))
                                                            
                                                                       (setf terrain (get-terrain-* (level *world*) dx dy dz))
                                                                       (unless terrain
                                                                         (setf exit-result 'exit)
                                                                         (return))
                                                                       (when (get-terrain-type-trait terrain +terrain-trait-blocks-move+)
                                                                         (setf exit-result 'exit)
                                                                         (return))
                                                                       
                                                                       (setf tx dx ty dy)
                                                                       ;; display a severed flying body part
                                                                       (display-animation-on-map dx dy 5 sdl:*red* sdl:*black*)
                                                                       (sdl:update-display)
                                                                       (sdl-cffi::sdl-delay 100)
                                                                       
                                                                       ;; place a blood stain along the path of the head
                                                                       (add-feature-to-level-list (level *world*) 
                                                                                                  (make-instance 'feature :feature-type +feature-blood-fresh+ :x dx :y dy :z dz))
                                                                       (reveal-cell-on-map (level *world*) dx dy dz)
                                                                       (display-cell-on-map dx dy dz)
                                                                       )
                                                                     exit-result)))
                                                
                                                (setf item (make-instance 'item :item-type +item-type-body-part+ :x tx :y ty :z (z mob)))
                                                (setf (name item) (format nil "~@(~A~)'s ~A" (name mob) body-part-str))
                                                (add-item-to-level-list (level *world*) item)
                                                (reveal-cell-on-map (level *world*) tx ty (z mob))
                                                (display-cell-on-map tx ty tz)
                                                (logger (format nil "ANIMATION-FUNC: ~A [~A] leaves ~A [~A] at (~A ~A)~%" (name mob) (id mob) (name item) (id item) tx ty))
                                                )
                                              )
                                                  
                                    ))
