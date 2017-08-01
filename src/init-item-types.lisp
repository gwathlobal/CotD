(in-package :cotd)

(set-item-type (make-instance 'item-type :id +item-type-body-part-limb+
                                         :name "body part"
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 1))

(set-item-type (make-instance 'item-type :id +item-type-body-part-half+
                                         :name "body part"
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 2))

(set-item-type (make-instance 'item-type :id +item-type-body-part-body+
                                         :name "body part"
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 3))

(set-item-type (make-instance 'item-type :id +item-type-body-part-full+
                                         :name "body part"
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 4))

(set-item-type (make-instance 'item-type :id +item-type-coin+
                                         :name "coin"
                                         :glyph-idx 4 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 10000 :value 1))

(set-item-type (make-instance 'item-type :id +item-type-medkit+
                                         :name "medkit"
                                         :descr "A medkit that can heal 3-5 HP. Usable by humans only. Unusable underwater."
                                         :glyph-idx 1 :glyph-color sdl:*green* :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor item)
                                                     (declare (ignore item))
                                                     (let ((heal-pwr (+ 3 (random 3))))
                                                       (when (> (+ (cur-hp actor) heal-pwr)
                                                                (max-hp actor))
                                                         (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                       (incf (cur-hp actor) heal-pwr)
                                                                                                              
                                                       (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                                  (format nil "You hear some rustling sounds~A. " str)))
                                                       
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                              (format nil "~A uses a medkit to heal itself for ~A. " (capitalize-name (visible-name actor)) heal-pwr))))
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                       (mob-ability-p actor +mob-abil-human+))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   (or (and nearest-enemy
                                                                            (< (/ (cur-hp actor) (max-hp actor)) 
                                                                               0.7))
                                                                       (and (not nearest-enemy)
                                                                            (< (/ (cur-hp actor) (max-hp actor)) 
                                                                               0.5))))
                                                            t
                                                            nil))))

(set-item-type (make-instance 'item-type :id +item-type-smoke-bomb+
                                         :name "smoke bomb"
                                         :descr "A bomb that emits clouds of smoke to conseal you. Usable only by humans. Can not be used in water."
                                         :glyph-idx 1 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor item)
                                                     (declare (ignore item))
                                                     (when (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                       (let ((cell-list (list '(-1 -1 1) '(-1 0 1) '(-1 1 1) '(0 -1 1) '(0 0 1) '(0 1 1) '(1 -1 1) '(1 0 1) '(1 1 1)
                                                                              '(-1 -1 0) '(-1 0 0) '(-1 1 0) '(0 -1 0) '(0 0 0) '(0 1 0) '(1 -1 0) '(1 0 0) '(1 1 0)
                                                                              '(-1 -1 -1) '(-1 0 -1) '(-1 1 -1) '(0 -1 -1) '(0 0 -1) '(0 1 -1) '(1 -1 -1) '(1 0 -1) '(1 1 -1))))
                                                         (loop for cell in cell-list
                                                               for x = (+ (first cell) (x actor))
                                                               for y = (+ (second cell) (y actor))
                                                               for z = (+ (third cell) (z actor))
                                                               do
                                                                  (format t "(~A ~A ~A)~%" x y z)
                                                                  (when (and (>= x 0) (>= y 0) (>= z 0)
                                                                             (< x (array-dimension (terrain (level *world*)) 0)) (< y (array-dimension (terrain (level *world*)) 1)) (< z (array-dimension (terrain (level *world*)) 2))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-projectiles+))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-water+))
                                                                             (or (= (third cell) 0)
                                                                                 (and (> (third cell) 0)
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-opaque-floor+)))
                                                                                 (and (< (third cell) 0)
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level *world*) x y (z actor)) +terrain-trait-opaque-floor+)))))
                                                                    
                                                                    (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-smoke-thick+ :x x :y y :z z :counter 4))))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                                    (format nil "You hear some hiss~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A uses a smoke bomb. " (capitalize-name (visible-name actor)))))))
                                         :on-check-applic (lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                       (mob-ability-p actor +mob-abil-human+))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                   nearest-enemy
                                                                   (< (/ (cur-hp actor) (max-hp actor)) 
                                                                      0.4))
                                                            t
                                                            nil))))
