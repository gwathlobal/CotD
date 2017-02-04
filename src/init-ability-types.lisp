(in-package :cotd)

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-heal-self+ :name "Heal self" :descr "Invoke divine powers to heal yourself." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (let ((heal-pwr (+ (* 4 (mob-ability-p actor +mob-abil-heal-self+))
                                                                   (random (* 3 (mob-ability-p actor +mob-abil-heal-self+))))))
                                                  (when (> (+ (cur-hp actor) heal-pwr)
                                                           (max-hp actor))
                                                    (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                  (incf (cur-hp actor) heal-pwr)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (print-visible-message (x actor) (y actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to heal itself for ~A.~%" (name actor) heal-pwr))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-divine-consealed+)
                                                        nil
                                                        t))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to heal and less than 50% hp - heal
                                                  (if (and (< (/ (cur-hp actor) (max-hp actor)) 
                                                              0.5)
                                                           (mob-ability-p actor +mob-abil-heal-self+)
                                                           (can-invoke-ability actor actor +mob-abil-heal-self+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-conseal-divine+ :name "Conseal divinity" :descr "Disguise yourself as a human. Divine abilities do not work while in human form." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (set-mob-effect actor +mob-effect-divine-consealed+)
                                                (setf (face-mob-type-id actor) +mob-type-human+)
                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A invokes divine powers to disguise itself as a human.~%" (name actor))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-divine-consealed+)
                                                        nil
                                                        t))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if the dst is more than 3 tiles away - stealth, if possible
                                                  (if (and (path actor)
                                                           (> (length (path actor)) 3)
                                                           (mob-ability-p actor +mob-abil-conseal-divine+)
                                                           (can-invoke-ability actor actor +mob-abil-conseal-divine+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-reveal-divine+ :name "Reveal divinity" :descr "Invoke to reveal you divinity." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (rem-mob-effect actor +mob-effect-divine-consealed+)
                                                (setf (face-mob-type-id actor) (mob-type actor))
                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A reveals its true divine form.~%" (name actor))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-divine-consealed+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to heal and need to reveal itself - do it
                                                  ;; if the dst tile is less than 2 tiles away - unstealth, if possible
                                                  (if (or (and (<= (length (path actor)) 1)
                                                               (mob-ability-p actor +mob-abil-reveal-divine+)
                                                               (can-invoke-ability actor actor +mob-abil-reveal-divine+))
                                                          (and (< (/ (cur-hp actor) (max-hp actor)) 
                                                                  0.5)
                                                               (mob-ability-p actor +mob-abil-heal-self+)
                                                               (mob-effect-p actor +mob-effect-divine-consealed+)
                                                               (mob-ability-p actor +mob-abil-reveal-divine+)
                                                               (can-invoke-ability actor actor +mob-abil-reveal-divine+)
                                                               (abil-applic-cost-p +mob-abil-heal-self+ actor)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-detect-good+ :name "Detect good" :descr "You are able to reveal the true form of divine beings when you touch them. You can also sense the general direction to the nearest diving being." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (rem-mob-effect target +mob-effect-divine-consealed+)
                                                (setf (face-mob-type-id target) (mob-type target))
                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A reveals the true form of ~A. " (name actor) (get-qualified-name target))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-detect-good+)
                                                               (mob-effect-p target +mob-effect-divine-consealed+))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-detect-evil+ :name "Detect evil" :descr "You are able to reveal the true form of demonic beings when you touch them. You can also sense the general direction to the nearest demonic being." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (unless (mob-effect-p target +mob-effect-reveal-true-form+)
                                                  (print-visible-message (x actor) (y actor) (level *world*) 
                                                                         (format nil "~A reveals the true form of ~A. " (name actor) (get-qualified-name target))))
                                                (setf (face-mob-type-id target) (mob-type target))
                                                (set-mob-effect target +mob-effect-reveal-true-form+ 5))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-detect-evil+)
                                                               (mob-effect-p target +mob-effect-possessed+))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-possessable+ :name "Can be possessed" :descr "Your body can be possessed by demonic forces." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-can-possess+ :name "Can possess" :descr "You are able to possess bodies of mortal creatures. Possessed creatures may sometimes revolt. Higher-ranking demons are better at supressing the victim's willpower." 
                                 :passive t :cost 0 :spd +normal-ap+ 
                                 :final t :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (logger (format nil "MOB-POSSESS-TARGET: ~A [~A] possesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
                                                
                                                (remove-mob-from-level-list (level *world*) target)
                                                (set-mob-location actor (x target) (y target))
                                                                                                
                                                (setf (master-mob-id target) (id actor))
                                                (setf (slave-mob-id actor) (id target))
                                                (set-mob-effect actor +mob-effect-possessed+)
                                                (set-mob-effect target +mob-effect-possessed+)
                                                (setf (face-mob-type-id actor) (mob-type target))
                                                
                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A possesses ~A.~%" (name actor) (name target)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-can-possess+)
                                                               (mob-ability-p target +mob-abil-possessable+)
                                                               (not (mob-effect-p target +mob-effect-blessed+))
                                                               (not (mob-effect-p target +mob-effect-divine-shield+))
                                                               (not (mob-effect-p actor +mob-effect-possessed+))
                                                               (not (mob-effect-p target +mob-effect-possessed+))
                                                               )
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-purging-touch+ :name "Purging touch" :descr "You are able to destroy demons who possess humans without harming the mortal bodies of the latter." 
                                 :passive t :cost 0 :spd 0 
                                 :final t :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (melee-target actor target)
                                                (logger (format nil "INSIDE PURGING TOUCH: ~A, (check-dead target) ~A~%" (name target) (check-dead target)))
                                                (when (check-dead target)
                                                  (incf (cur-fp actor))
                                                  (mob-depossess-target target))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-purging-touch+)
                                                               (mob-effect-p target +mob-effect-possessed+)
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+)))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-blessing-touch+ :name "Blessing touch" :descr "You are able to bless humans when you touch them." 
                                 :passive t :cost 0 :spd +normal-ap+
                                 :final t :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (logger (format nil "MOB-BLESS-TARGET: ~A [~A] blesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (set-mob-effect target +mob-effect-blessed+)
                                                (incf (total-blessed *world*))
                                                (incf (cur-fp actor))
                                                (incf (stat-blesses actor))
                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A blesses ~A.~%" (name actor) (name target)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-blessing-touch+)
                                                               (mob-ability-p target +mob-abil-can-be-blessed+)
                                                               (get-faction-relation (faction actor) (faction target))
                                                               (not (mob-effect-p target +mob-effect-blessed+))
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+)))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-can-be-blessed+ :name "Can be blessed" :descr "You are able to receive blessing from divine beings." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-unholy+ :name "Unholy" :descr "You burn (dmg: 1-2) when touching a blessed creature." 
                                 :passive t :cost 0 :spd +normal-ap+
                                 :final t :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))

                                                (logger (format nil "MOB-CONSUME-BLESSING-ON-TARGET: ~A [~A] is scorched by blessing of ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (rem-mob-effect target +mob-effect-blessed+)
                                                (decf (total-blessed *world*))

                                                (mob-burn-blessing target actor)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-unholy+)
                                                               (mob-effect-p target +mob-effect-blessed+))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-angel+ :name "Angel" :descr "You belong to divine beings." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon+ :name "Demon" :descr "You belong to the forces of hell." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-human+ :name "Human" :descr "You belong to mankind." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-see-all+ :name "Omniscience" :descr "You can see everything." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-lifesteal+ :name "Lifesteal" :descr "You heal yourself with the lifeforce of your slain enemies. The more powerful creature you kill - the more health you gain." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-kill t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))

                                                (logger (format nil "MOB-LIFESTEAL: ~A [~A] steals life from the dead ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (let ((heal-pwr))
                                                  (setf heal-pwr (* 2 (1+ (strength target))))
                                                  (when (> (+ (cur-hp actor) heal-pwr)
                                                           (max-hp actor))
                                                    (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                  (incf (cur-hp actor) heal-pwr)
                                                       
                                                  (unless (zerop heal-pwr)
                                                    (print-visible-message (x actor) (y actor) (level *world*) 
                                                                           (format nil "~A heals for ~A with the lifeforce of ~A. " (name actor) heal-pwr (name target))))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type actor target))
                                                      t)))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-call-for-help+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 1 :spd (truncate +normal-ap+ 3) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (logger (format nil "MOB-CALL-FOR-HELP: ~A [~A] calls for help~%" (name actor) (id actor)))
                                                
                                                (let ((allies-list))
                                                  ;; collect all allies that are able to answer the call within the 40 cell radius
                                                  (setf allies-list (loop for ally-mob-id in (mob-id-list (level *world*))
                                                                          when (and (not (eq actor (get-mob-by-id ally-mob-id)))
                                                                                    (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                                    (mob-ability-p (get-mob-by-id ally-mob-id) +mob-abil-answer-the-call+)
                                                                                    (<= (get-distance (x actor) (y actor) (x (get-mob-by-id ally-mob-id)) (y (get-mob-by-id ally-mob-id))) 40)
                                                                                    )
                                                                            collect ally-mob-id))
                                                  
                                                  ;; remove all allies that are visible to you so that only distant ones could answer 
                                                  (setf allies-list (remove-if #'(lambda (e) (member e (visible-mobs actor))) allies-list))
                                                  (logger (format nil "MOB-CALL-FOR-HELP: The following allies might answer the call ~A~%" allies-list))
                                                  
                                                  ;; place the effect of "called for help" on the allies in the final list 
                                                  (loop for ally-mob-id in allies-list 
                                                        do
                                                           (set-mob-effect (get-mob-by-id ally-mob-id) +mob-effect-called-for-help+ 2))
                                                  
                                                  (set-mob-effect actor +mob-effect-calling-for-help+ 2)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (print-visible-message (x actor) (y actor) (level *world*) 
                                                                         (format nil "~A calls for reinforcements.~%" (name actor))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-calling-for-help+)
                                                        nil
                                                        t))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                   ;; call for reinforcements if there is a threatening enemy in sight and hp < 50% and you are not the last one
                                                  (if (and nearest-enemy
                                                           (not (zerop (strength nearest-enemy)))
                                                           (< (/ (cur-hp actor) (max-hp actor)) 
                                                              0.5)
                                                           (mob-ability-p actor +mob-abil-call-for-help+)
                                                           (can-invoke-ability actor actor +mob-abil-call-for-help+)
                                                           (> (total-demons *world*) 1))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-answer-the-call+ :name "Answer the call" :descr "Invoke hellish powers to answer the summoning of your allies. If somebody has already answered the call, nothing will happen. If the teleport is successful, the ability will cost 5 time units." 
                                 :cost 0 :spd 0 :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] answers the call~%" (name actor) (id actor)))
                                                
                                                (let ((allies-list))
                                                  ;; find all allies that called for help with 40 cell radius
                                                  (setf allies-list (loop for ally-mob-id in (mob-id-list (level *world*))
                                                                          when (and (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                                    (mob-effect-p (get-mob-by-id ally-mob-id) +mob-effect-calling-for-help+)
                                                                                    (<= (get-distance (x actor) (y actor) (x (get-mob-by-id ally-mob-id)) (y (get-mob-by-id ally-mob-id))) 40)
                                                                                    )
                                                                            collect ally-mob-id))
                                                  
                                                  (if allies-list
                                                    (progn
                                                      (let ((called-ally (get-mob-by-id (first allies-list)))
                                                            (fx nil) (fy nil))
                                                        ;; if anyone found, find a free place around the caller
                                                        (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the caller ~A [~A]~%" (name actor) (id actor) (name called-ally) (id called-ally)))
                                                        (check-surroundings (x called-ally) (y called-ally) nil #'(lambda (x y)
                                                                                                                    (when (and (not (get-mob-* (level *world*) x y))
                                                                                                                               (not (get-terrain-type-trait (get-terrain-* (level *world*) x y) +terrain-trait-blocks-move+)))
                                                                                                                      (setf fx x fy y))))
                                                        (if (and fx fy)
                                                          ;; free place found
                                                          (progn
                                                            (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the place to teleport (~A, ~A)~%" (name actor) (id actor) fx fy))
                                                            (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                   (format nil "~A disappeares in thin air.~%" (name actor)))
                                                            ;; teleport the caster to the caller
                                                            (set-mob-location actor fx fy)

                                                            (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                   (format nil "~A answers the call of ~A.~%" (name actor) (name called-ally)))
                                                            ;; remove the calling for help status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            (make-act actor (truncate +normal-ap+ 2))
                                                            
                                                            (incf (stat-answers actor))
                                                            (incf (stat-calls called-ally))
                                                            )
                                                          (progn
                                                            (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] unable to the place to teleport~%" (name actor) (id actor)))
                                                            (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                   (format nil "~A blinks for a second, but remains in place.~%" (name actor)))
                                                            ;; no free place found - just remove the status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            ))
                                                        ))
                                                    (progn
                                                      ;; if none found, simply remove the "answer the call" status
                                                      (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] is unable to find the caller ~%" (name actor) (id actor)))
                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~A blinks for a second, but remains in place.~%" (name actor)))
                                                      (rem-mob-effect actor +mob-effect-called-for-help+)
                                                      ))
                                                    ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-called-for-help+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; answer the call if there is no enemy in sight
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-answer-the-call+)
                                                           (can-invoke-ability actor actor +mob-abil-answer-the-call+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-loves-infighting+ :name "Loves infighting" :descr "You do not mind attacking your own kin." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-bless+ :name "Prayer" :descr "Pray to God for help." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-BLESS: ~A [~A] prays for smiting~%" (name actor) (id actor)))

                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A starts to pray. " (name actor)))

                                                (let ((enemy-list nil))
                                                  (if (zerop (random 3))
                                                    (progn
                                                      
                                                      ;; 1/3th chance to do anything
                                                      
                                                      ;; collect all unholy enemies in sight
                                                      (setf enemy-list (loop for enemy-mob-id in (visible-mobs actor)
                                                                             when (and (not (get-faction-relation (faction actor) (faction (get-mob-by-id enemy-mob-id))))
                                                                                       (mob-ability-p (get-mob-by-id enemy-mob-id) +mob-abil-unholy+))
                                                                               collect enemy-mob-id))
                                                      
                                                      (logger (format nil "MOB-PRAYER-BLESS: ~A [~A] affects the following enemies ~A with the prayer~%" (name actor) (id actor) enemy-list))
                                                      
                                                      ;; reveal all enemies and burn them like they are blessed
                                                      (loop for enemy-mob-id in enemy-list
                                                            do
                                                               (logger (format nil "MOB-PRAYER-BLESS: ~A [~A] affects the enemy ~A~%" (name actor) (id actor) (get-mob-by-id enemy-mob-id)))
                                                               (when (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-possessed+)
                                                                 (unless (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-reveal-true-form+)
                                                                   (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                          (format nil "~A reveals the true form of ~A. " (name actor) (get-qualified-name (get-mob-by-id enemy-mob-id)))))
                                                                 (setf (face-mob-type-id (get-mob-by-id enemy-mob-id)) (mob-type (get-mob-by-id enemy-mob-id)))
                                                                 (set-mob-effect (get-mob-by-id enemy-mob-id) +mob-effect-reveal-true-form+ 5))
                                                               (mob-burn-blessing actor (get-mob-by-id enemy-mob-id)))
                                                      (unless enemy-list
                                                        (print-visible-message (x actor) (y actor) (level *world*) 
                                                                               (format nil "~%")))
                                                      )
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~%")))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-prayer-bless+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-bless+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-bless+)
                                                           (or nearest-enemy
                                                               (zerop (random 5))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-free-call+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 0 :spd (truncate +normal-ap+ 3) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (logger (format nil "MOB-FREE-CALL-FOR-HELP: ~A [~A] calls for help~%" (name actor) (id actor)))
                                                
                                                (let ((allies-list))
                                                  ;; collect all allies that are able to answer the call within the whole map
                                                  (setf allies-list (loop for ally-mob-id in (mob-id-list (level *world*))
                                                                          when (and (not (eq actor (get-mob-by-id ally-mob-id)))
                                                                                    (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                                    (mob-ability-p (get-mob-by-id ally-mob-id) +mob-abil-free-call+)
                                                                                    )
                                                                            collect ally-mob-id))
                                                  
                                                  ;; remove all allies that are visible to you so that only distant ones could answer 
                                                  (setf allies-list (remove-if #'(lambda (e) (member e (visible-mobs actor))) allies-list))
                                                  (logger (format nil "MOB-FREE-CALL-FOR-HELP: The following allies might answer the call ~A~%" allies-list))
                                                  
                                                  ;; place the effect of "called for help" on the allies in the final list 
                                                  (loop for ally-mob-id in allies-list 
                                                        do
                                                           (set-mob-effect (get-mob-by-id ally-mob-id) +mob-effect-called-for-help+ 2))
                                                  
                                                  (set-mob-effect actor +mob-effect-calling-for-help+ 2)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (print-visible-message (x actor) (y actor) (level *world*) 
                                                                         (format nil "~A murmurs some incantations.~%" (name actor))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-calling-for-help+)
                                                        nil
                                                        t))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; for satanists: call for reinforcements whenever there is a threatening enemy in sight and there still demons out there
                                                  (if (and nearest-enemy
                                                           (not (zerop (strength nearest-enemy)))
                                                           (mob-ability-p actor +mob-abil-free-call+)
                                                           (can-invoke-ability actor actor +mob-abil-free-call+)
                                                           (> (total-demons *world*) 0))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))
(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-shield+ :name "Prayer" :descr "Pray to God for help." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] prays for shielding~%" (name actor) (id actor)))

                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A starts to pray. " (name actor)))

                                                (let ((ally-list nil))
                                                  (if (zerop (random 3))
                                                    (progn
                                                      
                                                      ;; 1/3th chance to do anything
                                                      
                                                      ;; collect all allies in sight
                                                      (setf ally-list (loop for ally-mob-id in (visible-mobs actor)
                                                                             when (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                               collect ally-mob-id))
                                                      ;; do not forget self
                                                      (pushnew (id actor) ally-list)
                                                      
                                                      (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the following allies ~A with the prayer~%" (name actor) (id actor) ally-list))
                                                      
                                                      ;; grant all allies invulnerability for 5 turns
                                                      (loop for ally-mob-id in ally-list
                                                            do
                                                               (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the ally ~A~%" (name actor) (id actor) (get-mob-by-id ally-mob-id)))
                                                               (set-mob-effect (get-mob-by-id ally-mob-id) +mob-effect-divine-shield+ 5)
                                                               (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                      (format nil "~A is granted divine shield. " (name (get-mob-by-id ally-mob-id))))
                                                            )

                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~%"))
                                                      )
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~%")))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-prayer-shield+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-shield+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-shield+)
                                                           (zerop (random 3)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-curse+ :name "Curse" :descr "Curse the enemy with diabolical incantations." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-CURSE: ~A [~A] incants the curses~%" (name actor) (id actor)))

                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A laughs and curses maniacally. " (name actor)))

                                                (let ((enemy-list nil))
                                                  (if (zerop (random 3))
                                                    (progn
                                                      
                                                      ;; 1/3th chance to do anything
                                                      
                                                      ;; collect all unholy enemies in sight
                                                      (setf enemy-list (loop for enemy-mob-id in (visible-mobs actor)
                                                                             when (not (get-faction-relation (faction actor) (faction (get-mob-by-id enemy-mob-id))))
                                                                               collect enemy-mob-id))
                                                      
                                                      (logger (format nil "MOB-CURSE: ~A [~A] affects the following enemies ~A with the curse~%" (name actor) (id actor) enemy-list))
                                                      
                                                      ;; place a curse on them for 5 turns
                                                      (loop for enemy-mob-id in enemy-list
                                                            with protected = nil
                                                            do
                                                               (setf protected nil)
                                                               ;; divine shield and blessings also grant one-time protection from curses
                                                               (when (and (not protected) (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-blessed+))
                                                                 (rem-mob-effect (get-mob-by-id enemy-mob-id) +mob-effect-blessed+)
                                                                 (setf protected t))

                                                               (when (and (not protected) (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-divine-shield+))
                                                                 (rem-mob-effect (get-mob-by-id enemy-mob-id) +mob-effect-divine-shield+)
                                                                 (setf protected t))

                                                               (if protected
                                                                 (progn
                                                                   (logger (format nil "MOB-CURSE: ~A [~A] was protected, so the curse removes protection only~%" (name (get-mob-by-id enemy-mob-id)) (id (get-mob-by-id enemy-mob-id))))
                                                                   (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                          (format nil "~A's curse removed divine protection from ~A. " (name actor) (name (get-mob-by-id enemy-mob-id))))
                                                                   )
                                                                 (progn
                                                                   (logger (format nil "MOB-CURSE: ~A [~A] affects the enemy ~A with a curse~%" (name actor) (id actor) (get-mob-by-id enemy-mob-id)))
                                                                   (set-mob-effect (get-mob-by-id enemy-mob-id) +mob-effect-cursed+ 5)
                                                                   (print-visible-message (x actor) (y actor) (level *world*) 
                                                                                      (format nil "~A is cursed. " (name (get-mob-by-id enemy-mob-id))))))
                                                            )

                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~%")))
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (level *world*) 
                                                                             (format nil "~%")))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-curse+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; for satanists: if able to curse - do it
                                                  (if (and (mob-ability-p actor +mob-abil-curse+)
                                                           (can-invoke-ability actor actor +mob-abil-curse+)
                                                           nearest-enemy
                                                           (zerop (random 3)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-keen-senses+ :name "Keen senses" :descr "When confronted by the supernatural, you can see through its illusions." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-reveal+ :name "Prayer" :descr "Pray to reveal supernatural beings." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-REVEAL: ~A [~A] prays for revealing supernatural beings~%" (name actor) (id actor)))

                                                (print-visible-message (x actor) (y actor) (level *world*) 
                                                                       (format nil "~A starts to pray. " (name actor)))

                                                (if (zerop (random 3))
                                                  (progn
                                                    ;; 1/3th chance to do anything
                                                    
                                                    ;; reveal true form of all mobs in line of sight
                                                    (loop for mob-id in (visible-mobs actor)
                                                          for target = (get-mob-by-id mob-id)
                                                          do
                                                             (when (mob-effect-p target +mob-effect-divine-consealed+)
                                                               (rem-mob-effect target +mob-effect-divine-consealed+)
                                                               (setf (face-mob-type-id target) (mob-type target))
                                                               (print-visible-message (x target) (y target) (level *world*) 
                                                                                      (format nil "~A reveals the true form of ~A. " (name actor) (get-qualified-name target))))
                                                             (when (mob-effect-p target +mob-effect-possessed+)
                                                               (unless (mob-effect-p target +mob-effect-reveal-true-form+)
                                                                 (print-visible-message (x target) (y target) (level *world*) 
                                                                                        (format nil "~A reveals the true form of ~A. " (name actor) (get-qualified-name target))))
                                                               (setf (face-mob-type-id target) (mob-type target))
                                                               (set-mob-effect target +mob-effect-reveal-true-form+ 5)))                                                      
                                                    
                                                    (print-visible-message (x actor) (y actor) (level *world*) 
                                                                           (format nil "~%"))
                                                    )
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (level *world*) 
                                                                           (format nil "~%"))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-prayer-reveal+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-reveal+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-reveal+)
                                                           (zerop (random 3)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))
