(in-package :cotd)

(set-anim-type (make-animation-type :id +anim-type-fire-dot+
                                    :func #'(lambda (animation)
                                              (let ((x (anim-x animation))
                                                    (y (anim-y animation))
                                                    (z (anim-z animation))
                                                    (glyph-idx 10)
                                                    (glyph-color (sdl:color :r 255 :g 140 :b 0))
                                                    (back-color sdl:*black*))
                                                (multiple-value-bind (sx sy) (calculate-start-coord (x *player*) (y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
                                                  (when (and (check-tile-on-map x y z sx sy *max-x-view* *max-y-view* (view-z *player*))
                                                             (get-single-memo-visibility (get-memo-* (level *world*) x y z)))
                                                    (display-animation-on-map x y z glyph-idx glyph-color back-color)))
                                                ))
                                                  
                                    ))

(set-anim-type (make-animation-type :id +anim-type-severed-body-part+
                                    :func #'(lambda (animation)
                                              (let ((tx) (ty) (tz) (rx) (ry) (item)
                                                    (mob (first (anim-params animation)))
                                                    (body-part-str (second (anim-params animation)))
                                                    (body-part-type (third (anim-params animation))))

                                                (setf rx (- (random 7) 3))
                                                (setf ry (- (random 7) 3))
                                                (setf tx rx ty ry tz (z mob))
                                                
                                                (line-of-sight (x mob) (y mob) (z mob) (+ (x mob) rx) (+ (y mob) ry) (z mob)
                                                               #'(lambda (dx dy dz prev-cell)
                                                                   (declare (type fixnum dx dy dz))
                                                                   (let ((exit-result t))
                                                                     (block nil

                                                                       (unless (check-LOS-propagate dx dy dz prev-cell :check-move t)
                                                                         (setf exit-result 'exit)
                                                                         (return))

                                                                       (setf tx dx ty dy tz dz)
                                                                       ;; display a severed flying body part
                                                                       (multiple-value-bind (sx sy) (calculate-start-coord (x *player*) (y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
                                                                         (when (and (check-tile-on-map dx dy dz sx sy *max-x-view* *max-y-view* (view-z *player*))
                                                                                    (get-single-memo-visibility (get-memo-* (level *world*) dx dy dz)))
                                                                           (display-animation-on-map dx dy dz 5 sdl:*red* sdl:*black*)
                                                                           (sdl:update-display)
                                                                           (sdl-cffi::sdl-delay 100))
                                                                       
                                                                       ;; place a blood stain along the path of the head
                                                                         (add-feature-to-level-list (level *world*) 
                                                                                                    (make-instance 'feature :feature-type +feature-blood-fresh+ :x dx :y dy :z dz))
                                                                         (when (and (check-tile-on-map dx dy dz sx sy *max-x-view* *max-y-view* (view-z *player*))
                                                                                    (get-single-memo-visibility (get-memo-* (level *world*) dx dy dz)))
                                                                           (reveal-cell-on-map (level *world*) dx dy dz)
                                                                           (display-cell-on-map dx dy dz)))
                                                                       )
                                                                     exit-result)))
                                                
                                                (setf item (make-instance 'item :item-type body-part-type :x tx :y ty :z tz))
                                                (setf (name item) (format nil "~A's ~A" (alive-name mob) body-part-str))
                                                (setf (alive-name item) (format nil "~A" (alive-name mob)))
                                                (add-item-to-level-list (level *world*) item)
                                                (multiple-value-bind (sx sy) (calculate-start-coord (x *player*) (y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
                                                  (when (and (check-tile-on-map tx ty tz sx sy *max-x-view* *max-y-view* (view-z *player*))
                                                             (get-single-memo-visibility (get-memo-* (level *world*) tx ty tz)))
                                                    (reveal-cell-on-map (level *world*) tx ty tz)
                                                    (display-cell-on-map tx ty tz)))
                                                (logger (format nil "ANIMATION-FUNC: ~A [~A] leaves ~A [~A] at (~A ~A)~%" (name mob) (id mob) (name item) (id item) tx ty))
                                                )
                                              )
                                                  
                                    ))
