(in-package :cotd)

(set-effect-type (make-instance 'effect-type :id +mob-effect-possessed+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Possessed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blessed+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Blessed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*blue*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore actor))
                                                         (incf (total-blessed (level *world*)))
                                                         (incf (stat-blesses (get-mob-by-id (actor-id effect))))
                                                         (when (eq *player* (get-mob-by-id (actor-id effect)))
                                                           (incf (cur-score *player*) 5))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            (decf (total-blessed (level *world*)))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-reveal-true-form+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Revealed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-disguise-for-mob actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (rem-mob-effect-simple actor +mob-effect-reveal-true-form+)
                                                            (adjust-disguise-for-mob actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-concealed+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Concealed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-disguise-for-mob actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (rem-mob-effect-simple actor +mob-effect-divine-concealed+)
                                                            (adjust-disguise-for-mob actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-calling-for-help+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Concealed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-called-for-help+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Called")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-divine-shield+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Divine shield")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-cursed+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Cursed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 139 :g 69 :b 19))
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-blind+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Blind")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-sight actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-sight actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-fear+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Fear")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-climbing-mode+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Climbing")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (rem-mob-effect-simple actor +mob-effect-climbing-mode+)
                                                            (when (apply-gravity actor)
                                                              (set-mob-location actor (x actor) (y actor) (z actor))
                                                              (make-act actor +normal-ap+)))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-alertness+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "On alert")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-ready-to-possess+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Ready to possess")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-avatar-of-brilliance+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Avatar of Brilliance")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-archangel+)
                                                           (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         (set-cur-weapons actor)
                                                         (adjust-abilities actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         
                                                         (set-mob-effect actor :effect-type-id +mob-effect-flying+ :actor-id (id actor))

                                                         ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A transforms itself into an Avatar of Brilliance. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (let ((old-max-hp (max-hp actor))
                                                                  (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                              (setf (mob-type actor) +mob-type-angel+)
                                                              (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                              (when (and (zerop (cur-hp actor))
                                                                         (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms itself back into a chrome angel. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind)))
                                                            
                                                            (rem-mob-effect actor +mob-effect-flying+))
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore effect))
                                                          (when (not (mob-effect-p actor +mob-effect-gravity-pull+))
                                                            (set-mob-effect actor :effect-type-id +mob-effect-flying+ :actor-id (id actor))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-empowered-undead+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Empowered")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (mob-type actor)) ;; store mob-type-id in param1 of the effect
                                                         (set-mob-effect (get-mob-by-id (actor-id effect)) :effect-type-id +mob-effect-necrolink+ :actor-id (actor-id effect) :cd t :param1 (target-id effect))
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-reanimated-empowered+)
                                                           (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         (set-cur-weapons actor)
                                                         (let ((was-ghost nil))
                                                           (when (mob-ability-p actor +mob-abil-ghost-possess+)
                                                             (setf was-ghost t))
                                                           (adjust-abilities actor)
                                                           (when was-ghost
                                                             (mob-set-ability actor +mob-abil-ghost-possess+ t)
                                                             (mob-set-ability actor +mob-abil-ghost-release+ t)
                                                             (mob-remove-ability actor +mob-abil-possessable+)))
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         (setf (order actor) (list +mob-order-follow+ (actor-id effect)))

                                                         
                                                         ;(set-name actor)

                                                          ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is empowered. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                               :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))
                                             :on-remove #'(lambda (effect actor)
                                                            (let ((old-max-hp (max-hp actor))
                                                                  (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                              (setf (mob-type actor) (param1 effect))
                                                              (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                              (when (and (zerop (cur-hp actor))
                                                                         (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (let ((was-ghost nil))
                                                              (when (mob-ability-p actor +mob-abil-ghost-possess+)
                                                                (setf was-ghost t))
                                                              (adjust-abilities actor)
                                                              (when was-ghost
                                                                (mob-set-ability actor +mob-abil-ghost-possess+ t)
                                                                (mob-set-ability actor +mob-abil-ghost-release+ t)
                                                                (mob-remove-ability actor +mob-abil-possessable+)))
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
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A loses its power. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-necrolink+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Necrolink")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (setf (order actor) nil))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-gravity-pull+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Gravity pull")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-flying+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Flying")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (apply-gravity actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-slow+
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Slowed")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-speed actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (rem-mob-effect-simple actor (effect-type effect))
                                                            (adjust-speed actor)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-holy-touch+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Holy touch")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (weapon actor))
                                                         (setf (weapon actor) (list "Holy touch" (list +weapon-dmg-fire+ 2 3 +normal-ap+ 100 (list :is-fire)) nil))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (weapon actor) (param1 effect))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-extinguished-light+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Extinguished light")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))
                                             :on-add #'(lambda (effect actor)
                                                         (setf (param1 effect) (cur-light actor))
                                                         (setf (cur-light actor) 0)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (cur-light actor) (param1 effect))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-merged+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Merged")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (let ((singer nil)
                                                               (gazer nil)
                                                               (mender nil)
                                                               (cur-hp 0)
                                                               (final-mob-type nil))
                                                           (loop for mob-id in (append (list (id actor)) (merged-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (incf cur-hp (cur-hp mob))
                                                                    (cond
                                                                      ((= (mob-type mob) +mob-type-star-singer+) (setf singer t))
                                                                      ((= (mob-type mob) +mob-type-star-gazer+) (setf gazer t))
                                                                      ((= (mob-type mob) +mob-type-star-mender+) (setf mender t))))
                                                                 
                                                           (loop for mob-id in (append (list (id actor)) (merged-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (setf (is-merged mob) t)
                                                                    (setf (cur-hp mob) (truncate cur-hp (length (append (list (id actor)) (merged-id-list actor))))))
                                                           (setf (is-merged actor) nil)
                                                           
                                                           (cond
                                                             ((and singer gazer mender) (setf final-mob-type +mob-type-star-singer-gazer-mender+))
                                                             ((and singer mender) (setf final-mob-type +mob-type-star-singer-mender+))
                                                             ((and singer gazer) (setf final-mob-type +mob-type-star-singer-gazer+))
                                                             ((and gazer mender) (setf final-mob-type +mob-type-star-gazer-mender+)))

                                                           (setf (mob-type actor) final-mob-type)
                                                           (setf (face-mob-type-id actor) (mob-type actor))
                                                           (set-cur-weapons actor)
                                                           (adjust-abilities actor)
                                                           (adjust-dodge actor)
                                                           (adjust-armor actor)
                                                           (adjust-m-acc actor)
                                                           (adjust-r-acc actor)
                                                           (adjust-sight actor)
                                                           
                                                           ;; set up current abilities cooldowns
                                                           (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                           )
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (setf (mob-type actor) (param1 effect))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)

                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0)))
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore effect))
                                                          (let ((cur-hp 0))
                                                            (loop for mob-id in (append (list (id actor)) (merged-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (incf cur-hp (cur-hp mob)))
                                                                                                                                     
                                                           (loop for mob-id in (append (list (id actor)) (merged-id-list actor))
                                                                 for mob = (get-mob-by-id mob-id)
                                                                 do
                                                                    (setf (cur-hp mob) (truncate cur-hp (length (append (list (id actor)) (merged-id-list actor)))))
                                                                    (when (check-dead mob)
                                                                      (make-dead mob :splatter t :msg t :msg-newline t :killer nil :corpse t :aux-params () :keep-items nil)))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-righteous-fury+ 
                                :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Righteous fury")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 255 :g 140 :b 0))
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (setf (weapon actor) (list "Flaming sword" (list +weapon-dmg-fire+ 4 7 (truncate +normal-ap+ 1.3) 100 (list :chops-body-parts :is-fire)) nil))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is filled with righteous fury. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (set-cur-weapons actor)
                                                            (set-mob-effect actor :effect-type-id +mob-effect-slow+ :actor-id (id actor) :cd 3)
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A is no longer filled with righteous fury. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-wet+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Wet")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*blue*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (adjust-armor actor)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-pain-link-source+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Pain link")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            ;; param1 - id of the mob, affected by the +mob-effect-pain-link-source+
                                                            (when (param1 effect)
                                                              (rem-mob-effect (get-mob-by-id (param1 effect)) +mob-effect-pain-link-target+))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-pain-link-target+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Pain link")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            ;; I need this otherwise there will be an infinite recursion 
                                                            (when (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+)
                                                              (setf (param1 (get-effect-by-id (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+))) nil))
                                                            (rem-mob-effect (get-mob-by-id (actor-id effect)) +mob-effect-pain-link-source+)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-soul-reinforcement+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Reinforced soul")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-silence+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Silenced")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-confuse+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Confused")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-split-soul-source+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Split soul")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            ;; param1 - id of the mob, affected by the +mob-effect-split-soul-target+
                                                            (when (param1 effect)
                                                              (rem-mob-effect (get-mob-by-id (param1 effect)) +mob-effect-split-soul-target+))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-split-soul-target+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Split soul")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-remove #'(lambda (effect actor)
                                                            ;; I need this otherwise there will be an infinite recursion 
                                                            (when (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-split-soul-source+)
                                                              (setf (param1 (get-effect-by-id (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-split-soul-source+))) nil))
                                                            (rem-mob-effect (get-mob-by-id (actor-id effect)) +mob-effect-split-soul-source+)
                                                            ;; have to avoid recursion in make-dead with this
                                                            (rem-mob-effect-simple actor +mob-effect-split-soul-target+)
                                                            (when (> (cur-hp actor) 0)
                                                              (setf (cur-hp actor) 0)
                                                              (make-dead actor :splatter nil :msg nil :msg-newline nil :killer nil :corpse nil :aux-params nil))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-sprint+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Sprint")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (rem-mob-effect actor +mob-effect-climbing-mode+)
                                                         (decf (cur-move-speed actor) 25)
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (incf (cur-move-speed actor) 25)
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-exerted+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Exerted")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-casting-shadow+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Casting shadows")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-disguised+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Disguised")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         ;; Malseraph likes when you lose disguises
                                                         (increase-piety-for-god +god-entity-malseraph+ actor 30))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))

                                                            (rem-mob-effect-simple actor +mob-effect-disguised+)
                                                            (adjust-disguise-for-mob actor)
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A reveals itself as ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                           (get-qualified-name actor))
                                                                                  :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind)))
                                                            ;; Malseraph likes when you lose disguises
                                                            (increase-piety-for-god +god-entity-malseraph+ actor 30))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-constriction-source+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Constricting")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)
                                             :on-remove #'(lambda (effect actor)
                                                            ;; the param1 here is (list (list x y z)            - xyz coordinates of the constrictor
                                                            ;;                          (list id1 id2 id3 ...)) - collection of mob IDs that are being constricted by this constrictor 
                                                            (rem-mob-effect-simple actor +mob-effect-constriction-source+)
                                                            
                                                            (loop for target-id in (second (param1 effect))
                                                                  for target = (get-mob-by-id target-id)
                                                                  do
                                                                     (rem-mob-effect target +mob-effect-constriction-target+))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-constriction-target+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Constricted")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-dodge actor))
                                             :on-remove #'(lambda (effect actor)
                                                            ;; the param1 here is (list x y z) - xyz coordinates of the mob being constricted
                                                            (when (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-constriction-source+)
                                                              (let ((source-effect (get-effect-by-id (mob-effect-p (get-mob-by-id (actor-id effect)) +mob-effect-constriction-source+))))
                                                                (setf (second (param1 source-effect)) (remove (id actor) (second (param1 source-effect))))
                                                                (unless (second (param1 source-effect))
                                                                  (rem-mob-effect (get-mob-by-id (actor-id effect)) +mob-effect-constriction-source+))))
                                                            )
                                             :on-tick #'(lambda (effect actor)
                                                          (inflict-damage actor :min-dmg (get-melee-weapon-dmg-min (get-mob-by-id (actor-id effect))) :max-dmg (get-melee-weapon-dmg-min (get-mob-by-id (actor-id effect)))
                                                                                :dmg-type (get-melee-weapon-dmg-type (get-mob-by-id (actor-id effect)))
                                                                                :att-spd nil :weapon-aux () :acc 100 
                                                                                :actor (get-mob-by-id (actor-id effect))
                                                                                :no-hit-message t
                                                                                :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                              (format nil "~A constricts around ~A for ~A damage. "
                                                                                                                      (capitalize-name (prepend-article +article-the+ (visible-name (get-mob-by-id (actor-id effect)))))
                                                                                                                      (prepend-article +article-the+ (visible-name actor)) cur-dmg))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-irradiated+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Irradiated")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore actor))
                                                             (cond
                                                               ((> (param1 effect) 10) sdl:*red*)
                                                               ((> (param1 effect) 5) sdl:*yellow*)
                                                               (t sdl:*green*)))
                                             :on-tick #'(lambda (effect actor)
                                                          (when (zerop (random 3))
                                                            (decf (param1 effect)))
                                                          (when (> (param1 effect) 0)
                                                            (let ((r (random 200)))
                                                              (cond
                                                                ((= r 0) (when (not (mob-ability-p actor +mob-abil-casts-light+))
                                                                             (mob-set-mutation actor +mob-abil-casts-light+)
                                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                    (format nil "~A is now casting light. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                    :color sdl:*white*
                                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                  :singlemind)))))
                                                                ((= r 1) (when (not (mob-ability-p actor +mob-abil-vulnerable-to-fire+))
                                                                           (mob-set-mutation actor +mob-abil-vulnerable-to-fire+)
                                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                  (format nil "~A is now vulnerable to fire. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                  :color sdl:*white*
                                                                                                  :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                :singlemind)))))
                                                                ((= r 2) (when (not (mob-ability-p actor +mob-abil-vulnerable-to-vorpal+))
                                                                           (mob-set-mutation actor +mob-abil-vulnerable-to-vorpal+)
                                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                  (format nil "~A is now vulnerable to vorpal. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                  :color sdl:*white*
                                                                                                  :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                :singlemind))))))))
                                                          (when (<= (param1 effect) 0)
                                                            (rem-mob-effect actor (effect-type effect))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-deep-breath+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Deep breath")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 100 :g 100 :b 100))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (generate-sound actor (x actor) (y actor) (z actor) 50 #'(lambda (str)
                                                                                                                       (format nil "You hear someone exhaling~A. " str)))

                                                            (check-surroundings (x actor) (y actor) nil
                                                                                #'(lambda (dx dy)
                                                                                    (let ((target (get-mob-* (level *world*) dx dy (z actor))))
                                                                                      (when target
                                                                                        (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                               (format nil "~A irradiates ~A. "
                                                                                                                       (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                                       (prepend-article +article-the+ (visible-name target)))
                                                                                                               :color sdl:*white*
                                                                                                               :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                             :singlemind)))
                                                                                        (let* ((malseraph (get-god-by-id (get-worshiped-god-type (worshiped-god actor))))
                                                                                               (irradiate-bonus (funcall (piety-level-func malseraph) malseraph (get-worshiped-god-piety (worshiped-god actor))))
                                                                                               (irradiate-value (if (zerop irradiate-bonus)
                                                                                                                  -1
                                                                                                                  (random irradiate-bonus))))
                                                                                          (if (mob-effect-p target +mob-effect-irradiated+)
                                                                                            (progn
                                                                                              (let ((effect (get-effect-by-id (mob-effect-p target +mob-effect-irradiated+))))
                                                                                                (incf (param1 effect) (+ 2 irradiate-value))))
                                                                                            (progn
                                                                                              (set-mob-effect target :effect-type-id +mob-effect-irradiated+ :actor-id (id actor) :cd t :param1 (+ 2 irradiate-value)))))
                                                                                        ))
                                                                                    ))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-polymorph-sheep+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Polymorhped")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)
                                             :on-add #'(lambda (effect actor)

                                                         (when (mob-effect-p actor +mob-effect-avatar-of-brilliance+)
                                                           (rem-mob-effect actor +mob-effect-avatar-of-brilliance+))

                                                         (when (mob-effect-p actor +mob-effect-empowered-undead+)
                                                           (rem-mob-effect actor +mob-effect-empowered-undead+))

                                                         (when (mob-effect-p actor +mob-effect-polymorph-tree+)
                                                           (rem-mob-effect actor +mob-effect-polymorph-tree+))

                                                         (when (mob-effect-p actor +mob-effect-demonic-power+)
                                                           (rem-mob-effect actor +mob-effect-demonic-power+))
                                                                                                                  
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A transforms into a sheep. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind)))
                                                         
                                                         (let ((old-max-hp (max-hp actor))
                                                               (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                           (setf (mob-type actor) +mob-type-sheep+)
                                                           (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                           (when (and (zerop (cur-hp actor))
                                                                      (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))

                                                         ;; polymorph block mutations
                                                         (loop for ability-type-id in (get-mob-all-abilities actor)
                                                               with mutation-list = ()
                                                               when (and (mob-is-ability-mutation actor ability-type-id)
                                                                         (on-remove-mutation (get-ability-type-by-id ability-type-id)))
                                                                 do
                                                                    (mob-remove-mutation actor ability-type-id)
                                                                    (pushnew ability-type-id mutation-list)
                                                               finally
                                                                  (setf (param1 effect) (append (param1 effect) (list mutation-list))))
                                                         
                                                         (set-cur-weapons actor)
                                                         (adjust-abilities actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         
                                                         ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         
                                                         (increase-piety-for-god +god-entity-malseraph+ actor 50))
                                             :on-remove #'(lambda (effect actor)
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms back into a ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                           (name (get-mob-type-by-id (first (param1 effect)))))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            
                                                            (let ((old-max-hp (max-hp actor))
                                                                  (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                              (setf (mob-type actor) (first (param1 effect)))
                                                              (setf (max-hp actor) (second (param1 effect)))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                              (when (and (zerop (cur-hp actor))
                                                                         (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)

                                                            ;; polymorph returns mutations
                                                            (loop for ability-type-id in (third (param1 effect))
                                                                  when (on-add-mutation (get-ability-type-by-id ability-type-id))
                                                                 do
                                                                    (mob-set-mutation actor ability-type-id))
                                                            
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            
                                                            (increase-piety-for-god +god-entity-malseraph+ actor 50))
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-glowing+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Glowing")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore actor effect))
                                                             sdl:*yellow*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-parasite+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Parasite")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 0 :g 100 :b 0))
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))
                                             :on-remove #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-evolving+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Evolving")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-remove #'(lambda (effect actor)
                                                            ;; evolution finished, give the ability
                                                            (when (eq (cd effect) 0)
                                                              (let ((ability-type-id (first (param1 effect)))
                                                                    (str (second (param1 effect))))
                                                                (mob-set-mutation actor ability-type-id)
                                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                       (format nil "~A finishes evolving and ~A. "
                                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                               str)
                                                                                       :color sdl:*white*
                                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                     :singlemind)))))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-adrenaline+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Adrenaline")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore actor))
                                                             (cond
                                                               ((> (param1 effect) 10) sdl:*red*)
                                                               ((> (param1 effect) 5) sdl:*yellow*)
                                                               (t sdl:*green*)))
                                             :on-tick #'(lambda (effect actor)
                                                          (when (>= (param1 effect) 15)
                                                            (setf (param1 effect) 15))

                                                          (decf (param1 effect))
                                                          (when (zerop (random 4))
                                                            (decf (param1 effect)))
                                                          (when (<= (param1 effect) 0)
                                                            (rem-mob-effect actor (effect-type effect))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-metabolic-boost+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Metabolic boost")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         
                                                         (adjust-speed actor)
                                                         (adjust-dodge actor))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))

                                                            (rem-mob-effect-simple actor +mob-effect-metabolic-boost+)
                                                            (adjust-dodge actor)
                                                            (adjust-speed actor)
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "The metabolism of ~A returns to the norm. " (prepend-article +article-the+ (visible-name actor)))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-spines+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Spines")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))

                                                            (rem-mob-effect-simple actor +mob-effect-spines+)
                                                            (adjust-armor actor)
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A retracts its spines. " (prepend-article +article-the+ (visible-name actor)))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-mortality+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Dies in")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))

                                                            (rem-mob-effect-simple actor +mob-effect-mortality+)
                                                            (when (> (cur-hp actor) 0)
                                                              (setf (cur-hp actor) 0)
                                                              (when (check-dead actor)
                                                                (make-dead actor :splatter nil :msg t :killer nil :corpse t :aux-params ())
                                                                (when (mob-effect-p actor +mob-effect-possessed+)
                                                                  (setf (cur-hp (get-mob-by-id (slave-mob-id actor))) 0)
                                                                  (setf (x (get-mob-by-id (slave-mob-id actor))) (x actor)
                                                                        (y (get-mob-by-id (slave-mob-id actor))) (y actor)
                                                                        (z (get-mob-by-id (slave-mob-id actor))) (z actor))
                                                                  (make-dead (get-mob-by-id (slave-mob-id actor)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))))
                                                            
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-laying-eggs+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Laying eggs")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             (sdl:color :r 60 :g 179 :b 113))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            (when (eq (cd effect) 0)
                                                              (funcall (param1 effect))
                                                              )
                                                            
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-regenerate+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Regenerate")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore effect))
                                                          (incf (cur-hp actor))
                                                          (when (> (cur-hp actor) (max-hp actor))
                                                            (setf (cur-hp actor) (max-hp actor))))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-corroded+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Corroded")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*red*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))
                                             :on-remove #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-primordial-transfer+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Primdordial transfer")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-polymorph-tree+ 
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Polymorhped")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)
                                             :on-add #'(lambda (effect actor)

                                                         (when (mob-effect-p actor +mob-effect-avatar-of-brilliance+)
                                                           (rem-mob-effect actor +mob-effect-avatar-of-brilliance+))

                                                         (when (mob-effect-p actor +mob-effect-empowered-undead+)
                                                           (rem-mob-effect actor +mob-effect-empowered-undead+))

                                                         (when (mob-effect-p actor +mob-effect-polymorph-sheep+)
                                                           (rem-mob-effect actor +mob-effect-polymorph-sheep+))
                                                         
                                                         (when (mob-effect-p actor +mob-effect-demonic-power+)
                                                           (rem-mob-effect actor +mob-effect-demonic-power+))

                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A transforms into a tree. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind)))
                                                         
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-tree+)
                                                           (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))

                                                         ;; polymorph block mutations
                                                         (loop for ability-type-id in (get-mob-all-abilities actor)
                                                               with mutation-list = ()
                                                               when (and (mob-is-ability-mutation actor ability-type-id)
                                                                         (on-remove-mutation (get-ability-type-by-id ability-type-id)))
                                                                 do
                                                                    (mob-remove-mutation actor ability-type-id)
                                                                    (pushnew ability-type-id mutation-list)
                                                               finally
                                                                  (setf (param1 effect) (append (param1 effect) (list mutation-list))))
                                                         
                                                         (set-cur-weapons actor)
                                                         (adjust-abilities actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         
                                                         ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         
                                                         (increase-piety-for-god +god-entity-malseraph+ actor 50))
                                             :on-remove #'(lambda (effect actor)
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms back into a ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                           (name (get-mob-type-by-id (first (param1 effect)))))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            
                                                            (let ((old-max-hp (max-hp actor))
                                                                  (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                              (setf (mob-type actor) (first (param1 effect)))
                                                              (setf (max-hp actor) (second (param1 effect)))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                              (when (and (zerop (cur-hp actor))
                                                                         (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)

                                                            ;; polymorph returns mutations
                                                            (loop for ability-type-id in (third (param1 effect))
                                                                  when (on-add-mutation (get-ability-type-by-id ability-type-id))
                                                                 do
                                                                    (mob-set-mutation actor ability-type-id))
                                                            
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            
                                                            (increase-piety-for-god +god-entity-malseraph+ actor 50))
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-rest-in-peace+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Rest in peace")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*white*)))

(set-effect-type (make-instance 'effect-type :id +mob-effect-life-guard+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Meat shield")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))

                                                         (setf (mob-type actor) (mob-type (get-mob-by-id (slave-mob-id actor))))
                                                         (setf (max-hp actor) (max-hp (get-mob-by-id (slave-mob-id actor))))
                                                         (setf (cur-hp actor) (cur-hp (get-mob-by-id (slave-mob-id actor))))
                                                         (setf (weapon actor) (weapon (get-mob-by-id (slave-mob-id actor))))

                                                         (adjust-abilities actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)

                                                         (mob-set-ability actor +mob-abil-ghost-possess+ t)
                                                         (mob-set-ability actor +mob-abil-ghost-release+ t)
                                                         (mob-set-ability actor +mob-abil-detect-unnatural+ t)
                                                         (mob-remove-ability actor +mob-abil-possessable+)
                                                         
                                                         ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))

                                                            (setf (mob-type actor) +mob-type-ghost+)
                                                            (setf (cur-hp (get-mob-by-id (slave-mob-id actor))) (cur-hp actor))
                                                            (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                            (setf (cur-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))

                                                            (set-cur-weapons actor)
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                                  when (null (gethash ability-id (abilities-cd actor)))
                                                                    do
                                                                       (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-invisibility+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Invisibility")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-soul-sickness+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Soul sickness")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*cyan*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A gets infected with soul sickness. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind)))
                                                         )
                                             :on-tick #'(lambda (effect actor)
                                                          (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                          (when (and (get-mob-* (level *world*) dx dy (z actor))
                                                                                                                     (mob-ability-p (get-mob-* (level *world*) dx dy (z actor)) +mob-abil-soul+)
                                                                                                                     (not (mob-effect-p (get-mob-* (level *world*) dx dy (z actor)) +mob-effect-soul-sickness+)))
                                                                                                            (set-mob-effect (get-mob-* (level *world*) dx dy (z actor))
                                                                                                                            :effect-type-id +mob-effect-soul-sickness+
                                                                                                                            :actor-id (id actor)
                                                                                                                            :cd 30))))
                                                          (when (and (zerop (random 4))
                                                                     (> (cur-hp actor) 1)
                                                                     (mob-ability-p actor +mob-abil-soul+))
                                                            (inflict-damage actor :min-dmg 1 :max-dmg 1
                                                                                  :dmg-type +weapon-dmg-mind+
                                                                                  :att-spd nil :weapon-aux () :acc 100 
                                                                                  :actor (get-mob-by-id (actor-id effect))
                                                                                  :no-hit-message t
                                                                                  :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                                (format nil "~A takes ~A damage from soul sickness. "
                                                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                                        cur-dmg))
                                                                                  :specific-no-dmg-string-func #'(lambda ()
                                                                                                                   (format nil "~A takes no damage from soul sickness. "
                                                                                                                           (capitalize-name (prepend-article +article-the+ (visible-name actor)))))))
                                                          )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-demonic-power+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Demonic power")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*magenta*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (let ((old-max-hp (max-hp actor)))
                                                           (setf (mob-type actor) +mob-type-satanist-empowered+)
                                                           (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                           (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp)))
                                                         (setf (face-mob-type-id actor) (mob-type actor))
                                                         (set-cur-weapons actor)
                                                         (adjust-abilities actor)
                                                         (adjust-dodge actor)
                                                         (adjust-armor actor)
                                                         (adjust-m-acc actor)
                                                         (adjust-r-acc actor)
                                                         (adjust-sight actor)
                                                         (incf (total-demons (level *world*)))
                                                         
                                                         ;; set up current abilities cooldowns
                                                         (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                    (format nil "You hear some strange noise~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A gains demonic power. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :color sdl:*white*
                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                              :singlemind))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (let ((old-max-hp (max-hp actor))
                                                                  (null-hp (if (<= (cur-hp actor) 0)
                                                                             t
                                                                             nil)))
                                                              (setf (mob-type actor) +mob-type-satanist+)
                                                              (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                              (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
                                                              (when (and (zerop (cur-hp actor))
                                                                         (null null-hp))
                                                                (setf (cur-hp actor) 1)))
                                                            (setf (face-mob-type-id actor) (mob-type actor))
                                                            (set-cur-weapons actor)
                                                            (adjust-abilities actor)
                                                            (adjust-dodge actor)
                                                            (adjust-armor actor)
                                                            (adjust-m-acc actor)
                                                            (adjust-r-acc actor)
                                                            (adjust-sight actor)
                                                            (decf (total-demons (level *world*)))
                                                            
                                                            ;; set up current abilities cooldowns
                                                            (loop for ability-id in (get-mob-all-abilities actor)
                                                               when (null (gethash ability-id (abilities-cd actor)))
                                                                 do
                                                                    (setf (gethash ability-id (abilities-cd actor)) 0))
                                                            
                                                            (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                               (format nil "You hear some strange noise~A.~%" str)))
                                                            
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A transforms back into a human being. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            
                                                            )
                                             ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-demonic-sigil+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Demonic sigil")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (push (id actor) (demonic-sigils (level *world*)))
                                                         (setf (param1 effect) 0))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (setf (demonic-sigils (level *world*)) (remove (id actor) (demonic-sigils (level *world*))))                                                            
                                                            )
                                             :on-tick #'(lambda (effect actor)
                                                          (declare (ignore actor))
                                                          (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                            (declare (ignore sigils-num))
                                                            (when (< (param1 effect) max-turns)
                                                              (incf (param1 effect))))
                                                          )))

(set-effect-type (make-instance 'effect-type :id +mob-effect-demonic-machine+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Demonic machine")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (push (id actor) (demonic-machines (level *world*))))
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore effect))
                                                            (setf (demonic-machines (level *world*)) (remove (id actor) (demonic-machines (level *world*))))                                                            
                                                            )
                                ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-bomb-ticking+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Bomb ticking")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore actor))
                                                         (unless (param1 effect)
                                                           (setf (param1 effect) 0))
                                                         )
                                             :on-remove #'(lambda (effect actor)
                                                            (declare (ignore actor effect))
                                                                                                                        
                                                            )
                                             :on-tick #'(lambda (effect actor)
                                                          (with-slots (param1) effect
                                                            (incf param1)

                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                                   (format nil "The bomb ticks... ~A! " param1)
                                                                                   :observed-mob actor
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))

                                                            (generate-sound actor (x actor) (y actor) (z actor) 20 #'(lambda (str)
                                                                                                                (format nil "You hear a clock ticking~A. " str)))
                                                            
                                                            (when (= param1 2)
                                                              (remove-mob-from-level-list (level *world*) actor)
                                                              (let ((bomb-mob))
                                                                (setf bomb-mob (make-instance 'mob :mob-type +mob-type-military-bomb-2+ :x (x actor) :y (y actor) :z (z actor)))
                                                                (add-mob-to-level-list (level *world*) bomb-mob)
                                                                (set-mob-effect bomb-mob :effect-type-id +mob-effect-bomb-ticking+ :actor-id (actor-id effect) :cd t :param1 param1)
                                                                (set-mob-location bomb-mob (x bomb-mob) (y bomb-mob) (z bomb-mob) :apply-gravity t)
                                                                (setf (cur-hp bomb-mob) (cur-hp actor))
                                                                (update-visible-mobs bomb-mob)
                                                                ;; a hack to stop the new bomb from ticking on the same turn
                                                                (setf (cur-ap bomb-mob) 0)))
                                                            
                                                            (when (= param1 4)
                                                              (remove-mob-from-level-list (level *world*) actor)
                                                              (let ((bomb-mob))
                                                                (setf bomb-mob (make-instance 'mob :mob-type +mob-type-military-bomb-3+ :x (x actor) :y (y actor) :z (z actor)))
                                                                (add-mob-to-level-list (level *world*) bomb-mob)
                                                                (set-mob-effect bomb-mob :effect-type-id +mob-effect-bomb-ticking+ :actor-id (actor-id effect) :cd t :param1 param1)
                                                                (set-mob-location bomb-mob (x bomb-mob) (y bomb-mob) (z bomb-mob) :apply-gravity t)
                                                                (update-visible-mobs bomb-mob)
                                                                (setf (cur-hp bomb-mob) (cur-hp actor))
                                                                ;; a hack to stop the new bomb from ticking on the same turn
                                                                (setf (cur-ap bomb-mob) 0)))

                                                            (when (> param1 5)
                                                              (remove-mob-from-level-list (level *world*) actor)
                                                              
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                                     (format nil "KABOOM! ")
                                                                                     :observed-mob actor
                                                                                     :color sdl:*white*
                                                                                     :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                   :singlemind)))

                                                              (generate-sound actor (x actor) (y actor) (z actor) 150 #'(lambda (str)
                                                                                                                         (format nil "You hear a huge explosion~A. " str)))

                                                              (let ((bomb-plant-target-feature (get-feature-by-id (find +feature-bomb-plant-target+ (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                                                                        :key #'(lambda (a)
                                                                                                                                 (feature-type (get-feature-by-id a)))))))
                                                                (loop for (x y z) in (param1 bomb-plant-target-feature) do
                                                                  (set-terrain-* (level *world*) x y z +terrain-floor-air+))
                                                                
                                                                (remove-feature-from-level-list (level *world*) bomb-plant-target-feature)
                                                                (remove-feature-from-world bomb-plant-target-feature)
                                                                (setf (bomb-plant-locations (level *world*)) (remove (id bomb-plant-target-feature) (bomb-plant-locations (level *world*)))))
                                                          
                                                              (make-explosion-at-xyz (level *world*) (x actor) (y actor) (z actor) 3 (get-mob-by-id (actor-id effect))
                                                                                     :dmg-list `((:min-dmg 6 :max-dmg 10 :dmg-type ,+weapon-dmg-fire+ :weapon-aux (:is-fire))
                                                                                                 (:min-dmg 6 :max-dmg 10 :dmg-type ,+weapon-dmg-iron+ :weapon-aux (:is-fire))))
                                                          
                                                            )))
                                ))

(set-effect-type (make-instance 'effect-type :id +mob-effect-reduce-resitances+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore effect actor))
                                                            "Reduce resistances")
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*yellow*)
                                             :on-add #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))
                                             :on-remove #'(lambda (effect actor)
                                                         (declare (ignore effect))
                                                         (adjust-armor actor))))

(set-effect-type (make-instance 'effect-type :id +mob-effect-strength-in-numbers+
                                             :name-func #'(lambda (effect actor)
                                                            (declare (ignore actor))
                                                            (format nil "Strength in numbers (~A%)" (param1 effect)))
                                             :color-func #'(lambda (effect actor)
                                                             (declare (ignore effect actor))
                                                             sdl:*green*)))
