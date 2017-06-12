(in-package :cotd)

(set-effect-type (make-instance 'effect-type :id +mob-effect-possessed+ :name "Possessed" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blessed+ :name "Blessed" :color sdl:*blue*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-reveal-true-form+ :name "Revealed" :color sdl:*red*
                                             :on-remove #'(lambda (effect-type actor)
                                                            (declare (ignore effect-type))
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
                                             :on-add #'(lambda (effect-type actor)
                                                         (declare (ignore effect-type))
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
                                                         (set-name actor)

                                                          ;; set up current abilities cooldowns
                                                         (loop for ability-id being the hash-key in (abilities actor) do
                                                           (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A transforms itself into Avatar of Brilliance. " (visible-name actor))))
                                             :on-remove #'(lambda (effect-type actor)
                                                            (declare (ignore effect-type))
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
                                                            (set-name actor)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id being the hash-key in (abilities actor) do
                                                              (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms itself back into Chrome Angel.~%" (visible-name actor))))))
