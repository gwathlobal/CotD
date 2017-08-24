(in-package :cotd)

(set-effect-type (make-instance 'effect-type :id +mob-effect-possessed+ :name "Possessed" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blessed+ :name "Blessed" :color sdl:*blue*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-reveal-true-form+ :name "Revealed" :color sdl:*red*
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (when (slave-mob-id actor)
                                                              (setf (face-mob-type-id actor) (mob-type (get-mob-by-id (slave-mob-id actor))))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-consealed+ :name "Consealed" :color sdl:*cyan*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-calling-for-help+ :name "Summoning" :color sdl:*green*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-called-for-help+ :name "Called" :color sdl:*green*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-shield+ :name "Divine shield" :color sdl:*yellow*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-cursed+ :name "Cursed" :color (sdl:color :r 139 :g 69 :b 19)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blind+ :name "Blind" :color (sdl:color :r 100 :g 100 :b 100)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-fear+ :name "Fear" :color sdl:*magenta*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-climbing-mode+ :name "Climbing" :color (sdl:color :r 100 :g 100 :b 100)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-alertness+ :name "On alert" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-ready-to-possess+ :name "Ready to possess" :color (sdl:color :r 100 :g 100 :b 100)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-avatar-of-brilliance+ :name "Avatar of Brilliance" :color sdl:*white*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-archangel+)
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         (set-cur-weapons actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         ;(set-name actor)

                                                         (set-mob-effect actor :effect-type-id +mob-effect-flying+ :actor-id (id actor))

                                                          ;; set up current abilities cooldowns
                                                         (loop for ability-id being the hash-key in (abilities actor) do
                                                           (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A transforms itself into Avatar of Brilliance. " (visible-name actor))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (let ((old-max-hp (max-hp actor)))
                                                              (setf (mob-type actor) +mob-type-angel+)
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            ;(set-name actor)

                                                            
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id being the hash-key in (abilities actor) do
                                                              (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms itself back into Chrome Angel.~%" (visible-name actor)))
                                                            
                                                            (rem-mob-effect actor +mob-effect-flying+))
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore effect))
                                                          (when (not (mob-effect-p actor +mob-effect-gravity-pull+))
                                                            (set-mob-effect actor :effect-type-id +mob-effect-flying+ :actor-id (id actor))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-empowered-undead+ :name "Empowered" :color sdl:*green*
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (mob-type actor)) ;; store mob-type-id in param1 of the effect
                                                         (set-mob-effect (get-mob-by-id (actor-id effect)) :effect-type-id +mob-effect-necrolink+ :actor-id (actor-id effect) :cd t :param1 (target-id effect))
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-reanimated-empowered+)
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         (set-cur-weapons actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         (setf (order actor) (list +mob-order-follow+ (actor-id effect)))
                                                         ;(set-name actor)

                                                          ;; set up current abilities cooldowns
                                                         (loop for ability-id being the hash-key in (abilities actor) do
                                                           (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is empowered. " (visible-name actor))))
                                             :on-remove #'(lambda (effect actor)
                                                            (let ((old-max-hp (max-hp actor)))
                                                              (setf (mob-type actor) (param1 effect))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            ;(set-name actor)
                                                            (setf (order actor) nil)

                                                            ;; remove necrolink from master
                                                            (rem-mob-effect (get-mob-by-id (actor-id effect)) +mob-effect-necrolink+)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id being the hash-key in (abilities actor) do
                                                              (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A loses its power. " (visible-name actor))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-necrolink+ :name "Necrolink" :color (sdl:color :r 100 :g 100 :b 100)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-gravity-pull+ :name "Gravity pull" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-flying+ :name "Flying" :color sdl:*cyan*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-slow+ :name "Slowed" :color sdl:*red*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (incf (cur-speed actor) 50)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (decf (cur-speed actor) 50)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-holy-touch+ :name "Holy touch" :color sdl:*white*
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (weapon actor))
                                                         (setf (weapon actor) (list "Holy touch" (list +weapon-dmg-fire+ 2 3 +normal-ap+ 100 (list :is-fire)) nil))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (weapon actor) (param1 effect))
                                                            )))
