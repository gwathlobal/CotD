(in-package :cotd)

(set-effect-type (make-instance 'effect-type :id +mob-effect-possessed+ :name "Possessed" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blessed+ :name "Blessed" :color sdl:*blue*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore actor))
                                                         (incf (total-blessed *world*))
                                                         (incf (stat-blesses (get-mob-by-id (actor-id effect))))
                                                         (when (eq *player* (get-mob-by-id (actor-id effect)))
                                                           (incf (cur-score *player*) 5))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            (decf (total-blessed *world*))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-reveal-true-form+ :name "Revealed" :color sdl:*red*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (when (slave-mob-id actor)
                                                              (setf (face-mob-type-id actor) (mob-type (get-mob-by-id (slave-mob-id actor))))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-concealed+ :name "Concealed" :color sdl:*cyan*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (setf (face-mob-type-id actor) +mob-type-man+)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (setf (face-mob-type-id actor) (mob-type actor)))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-calling-for-help+ :name "Summoning" :color sdl:*green*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-called-for-help+ :name "Called" :color sdl:*green*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-shield+ :name "Divine shield" :color sdl:*yellow*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-cursed+ :name "Cursed" :color (sdl:color :r 139 :g 69 :b 19)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blind+ :name "Blind" :color (sdl:color :r 100 :g 100 :b 100)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-sight actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-sight actor))))

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

(set-effect-type (make-instance 'effect-type :id +mob-effect-necrolink+ :name "Necrolink" :color (sdl:color :r 100 :g 100 :b 100)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (setf (order actor) nil))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-gravity-pull+ :name "Gravity pull" :color sdl:*red*))

(set-effect-type (make-instance 'effect-type :id +mob-effect-flying+ :name "Flying" :color sdl:*cyan*
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (apply-gravity actor))))

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

(set-effect-type (make-instance 'effect-type :id +mob-effect-extinguished-light+ :name "Extinguished light" :color (sdl:color :r 100 :g 100 :b 100)
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (cur-light actor))
                                                         (setf (cur-light actor) 0)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (cur-light actor) (param1 effect))
                                                            (update-visible-mobs actor)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-melded+ :name "Melded" :color sdl:*cyan*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (let ((singer nil)
                                                               (gazer nil)
                                                               (mender nil)
                                                               (cur-hp 0)
                                                               (final-mob-type nil))
                                                           (loop for mob-id in (append (list (id actor)) (melded-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (incf cur-hp (cur-hp mob))
                                                                    (cond
                                                                      ((= (mob-type mob) +mob-type-star-singer+) (setf singer t))
                                                                      ((= (mob-type mob) +mob-type-star-gazer+) (setf gazer t))
                                                                      ((= (mob-type mob) +mob-type-star-mender+) (setf mender t))))
                                                                 
                                                           (loop for mob-id in (append (list (id actor)) (melded-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (setf (is-melded mob) t)
                                                                    (setf (cur-hp mob) (truncate cur-hp (length (append (list (id actor)) (melded-id-list actor))))))
                                                           (setf (is-melded actor) nil)
                                                           
                                                           (cond
                                                             ((and singer gazer mender) (setf final-mob-type +mob-type-star-singer-gazer-mender+))
                                                             ((and singer mender) (setf final-mob-type +mob-type-star-singer-mender+))
                                                             ((and singer gazer) (setf final-mob-type +mob-type-star-singer-gazer+))
                                                             ((and gazer mender) (setf final-mob-type +mob-type-star-gazer-mender+)))

                                                           (setf (mob-type actor) final-mob-type)
                                                           (setf (face-mob-type-id actor) (mob-type actor))
                                                           (set-cur-weapons actor)
                                                           (adjust-dodge actor)
                                                           (adjust-armor actor)
                                                           (adjust-m-acc actor)
                                                           (adjust-r-acc actor)
                                                           (adjust-sight actor)
                                                           
                                                           ;; set up current abilities cooldowns
                                                           (loop for ability-id being the hash-key in (abilities actor) do
                                                             (setf (gethash ability-id (abilities-cd actor)) 0))
                                                           )
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (mob-type actor) (param1 effect))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)

                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id being the hash-key in (abilities actor) do
                                                              (setf (gethash ability-id (abilities-cd actor)) 0)))
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore effect))
                                                          (let ((cur-hp 0))
                                                            (loop for mob-id in (append (list (id actor)) (melded-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (incf cur-hp (cur-hp mob)))
                                                                                                                                     
                                                           (loop for mob-id in (append (list (id actor)) (melded-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (setf (cur-hp mob) (truncate cur-hp (length (append (list (id actor)) (melded-id-list actor))))))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-righteous-fury+ :name "Righteous fury" :color (sdl:color :r 255 :g 140 :b 0)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (setf (weapon actor) (list "Flaming sword" (list +weapon-dmg-fire+ 4 7 (truncate +normal-ap+ 1.3) 100 (list :chops-body-parts :is-fire)) nil))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is filled with righteous fury. " (visible-name actor))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (set-cur-weapons actor)
                                                            (set-mob-effect actor :effect-type-id +mob-effect-slow+ :actor-id (id actor) :cd 3)
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A is no longer filled with righteous fury. " (visible-name actor))))
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-wet+ :name "Wet" :color sdl:*blue*
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-armor actor)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-pain-link-source+ :name "Pain link" :color sdl:*white*
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            ;; param1 - id of the mob, affected by the +mob-effect-pain-link-source+
                                                            (when (param1 effect)
                                                              (rem-mob-effect (get-mob-by-id (param1 effect)) +mob-effect-pain-link-target+))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-pain-link-target+ :name "Pain link" :color sdl:*magenta*
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            ;; I need this otherwise there will be an infinite recursion 
                                                            (when (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+)
                                                              (setf (param1 (get-effect-by-id (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+))) nil))
                                                            (rem-mob-effect (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-soul-reinforcement+ :name "Reinforced soul" :color sdl:*cyan*))
