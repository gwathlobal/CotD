(in-package :cotd)

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-heal-self+ :name "Heal self" :descr "Invoke divine powers to heal yourself." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (let ((heal-pwr (+ (* 4 (mob-ability-p actor +mob-abil-heal-self+))
                                                                   (random (* 3 (mob-ability-p actor +mob-abil-heal-self+))))))
                                                  (when (> (+ (cur-hp actor) heal-pwr)
                                                           (max-hp actor))
                                                    (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                  (incf (cur-hp actor) heal-pwr)
                                                  (decf (cur-fp actor) (cost ability-type))

                                                  (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                             (format nil "You hear some strange noise~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to heal itself for ~A. " (capitalize-name (visible-name actor)) heal-pwr))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-effect-p actor +mob-effect-divine-consealed+)
                                                        nil
                                                        t))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if able to heal and less than 50% hp - heal
                                                  (if (and (or (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.5))
                                                               (and (not nearest-enemy)
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.9)))
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
                                 :motion 25
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-divine-consealed+ :actor-id (id actor) :cd t)
                                                (setf (face-mob-type-id actor) +mob-type-human+)
                                                (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                           (format nil "You hear some strange noise~A. " str)))
                                                (when (check-mob-visible actor :observer *player*)
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to disguise itself as a human. " (capitalize-name (name actor))))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-reveal-true-form+))
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+)))
                                                        t
                                                        nil))
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
                                 :motion 25
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (rem-mob-effect actor +mob-effect-divine-consealed+)
                                                (setf (face-mob-type-id actor) (mob-type actor))
                                                (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                           (format nil "You hear some strange noise~A. " str)))
                                                 (when (check-mob-visible actor :observer *player*)
                                                   (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                          (format nil "~A reveals its true divine form. " (capitalize-name (name actor))))))
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
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (get-qualified-name target))))
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
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (get-qualified-name target))))
                                                (setf (face-mob-type-id target) (mob-type target))
                                                (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))
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
                                 :id +mob-abil-can-possess+ :name "Can possess" :descr "You are able to possess bodies of mortal creatures. Possessed creatures may sometimes revolt. Higher-ranking demons are better at supressing the victim's willpower. You need to be in the \"Ready to possess\" mode (see \"Toggle possession mode\" ability). You can not possess mortals while mounted." 
                                 :passive t :cost 0 :spd +normal-ap+ 
                                 :final t :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (logger (format nil "MOB-POSSESS-TARGET: ~A [~A] possesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
                                                
                                                (remove-mob-from-level-list (level *world*) target)
                                                (set-mob-location actor (x target) (y target) (z target))
                                                                                                
                                                (setf (master-mob-id target) (id actor))
                                                (setf (slave-mob-id actor) (id target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-possessed+ :actor-id (id actor))
                                                (set-mob-effect target :effect-type-id +mob-effect-possessed+ :actor-id (id target))
                                                (setf (face-mob-type-id actor) (mob-type target))
                                                (rem-mob-effect actor +mob-effect-ready-to-possess+)
                                                (incf (stat-possess actor))

                                                ;; when the target is riding something - replace the rider with the actor
                                                (when (riding-mob-id target)
                                                  (setf (riding-mob-id actor) (riding-mob-id target))
                                                  (setf (mounted-by-mob-id (get-mob-by-id (riding-mob-id actor))) (id actor))
                                                  (setf (riding-mob-id target) nil))
                                                
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A possesses ~A. " (capitalize-name (name actor)) (visible-name target)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-can-possess+)
                                                               (mob-ability-p target +mob-abil-possessable+)
                                                               (mob-effect-p actor +mob-effect-ready-to-possess+)
                                                               (not (mob-effect-p target +mob-effect-blessed+))
                                                               (not (mob-effect-p target +mob-effect-divine-shield+))
                                                               (not (mob-effect-p actor +mob-effect-possessed+))
                                                               (not (mob-effect-p target +mob-effect-possessed+))
                                                               (not (riding-mob-id actor))
                                                               )
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-purging-touch+ :name "Purging touch" :descr "You are able to destroy demons who possess humans without harming the mortal bodies of the latter." 
                                 :passive t :cost 0 :spd 0 
                                 :final t :on-touch t
                                 :motion 10
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
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (logger (format nil "MOB-BLESS-TARGET: ~A [~A] blesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (set-mob-effect target :effect-type-id +mob-effect-blessed+ :actor-id (id actor))
                                                (incf (total-blessed *world*))
                                                (incf (cur-fp actor))
                                                (incf (stat-blesses actor))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A blesses ~A. " (capitalize-name (visible-name actor)) (visible-name target)))
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
                                 :id +mob-abil-can-be-blessed+ :name "Can be blessed" :descr "You are able to receive blessings from divine beings." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-unholy+ :name "Unholy" :descr "You burn (dmg: 1-2) when touching a blessed creature." 
                                 :passive t :cost 0 :spd +normal-ap+
                                 :final t :on-touch t
                                 :motion 30
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
                                 :motion 10
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
                                                    (when (check-mob-visible actor :observer *player* :complete-check t)
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A heals for ~A with the lifeforce of ~A. " (capitalize-name (visible-name actor)) heal-pwr (visible-name target)))))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type actor target))
                                                      t)))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-call-for-help+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 1 :spd (truncate +normal-ap+ 3) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
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
                                                           (set-mob-effect (get-mob-by-id ally-mob-id) :effect-type-id +mob-effect-called-for-help+ :actor-id (id actor) :cd 2))
                                                  
                                                  (set-mob-effect actor :effect-type-id +mob-effect-calling-for-help+ :actor-id (id actor) :cd 2)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone reciting incantations~A. " str)))
                                                  (when (check-mob-visible actor :observer *player*)
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A calls for reinforcements. " (capitalize-name (visible-name actor))))))
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
                                 :motion 50
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
                                                            (fx nil) (fy nil) (fz nil))
                                                        ;; if anyone found, find a free place around the caller
                                                        (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the caller ~A [~A]~%" (name actor) (id actor) (name called-ally) (id called-ally)))
                                                        (check-surroundings (x called-ally) (y called-ally) nil #'(lambda (x y)
                                                                                                                    (when (and (not (get-mob-* (level *world*) x y (z called-ally)))
                                                                                                                               (not (get-terrain-type-trait (get-terrain-* (level *world*) x y (z called-ally))
                                                                                                                                                            +terrain-trait-blocks-move+)))
                                                                                                                      (setf fx x fy y fz (z called-ally)))))
                                                        (if (and fx fy fz)
                                                          ;; free place found
                                                          (progn
                                                            (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the place to teleport (~A, ~A)~%" (name actor) (id actor) fx fy))
                                                            (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A. " str)))
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A disappeares in thin air. " (capitalize-name (visible-name actor))))
                                                            ;; teleport the caster to the caller
                                                            (set-mob-location actor fx fy fz)

                                                            (if (get-faction-relation (faction called-ally) (faction *player*))
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A answers the call of ~A. " (capitalize-name (visible-name actor)) (visible-name called-ally)))
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A appears out of thin air. " (capitalize-name (visible-name actor)))))
                                                            ;; remove the calling for help status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            (make-act actor (truncate +normal-ap+ 2))
                                                            
                                                            (incf (stat-answers actor))
                                                            (incf (stat-calls called-ally))
                                                            )
                                                          (progn
                                                            (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] unable to the place to teleport~%" (name actor) (id actor)))
                                                            (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A. " str)))
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A blinks for a second, but remains in place. " (capitalize-name (visible-name actor))))
                                                            ;; no free place found - just remove the status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            ))
                                                        ))
                                                    (progn
                                                      ;; if none found, simply remove the "answer the call" status
                                                      (logger (format nil "MOB-ANSWER-THE-CALL: ~A [~A] is unable to find the caller ~%" (name actor) (id actor)))
                                                      (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A." str)))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A blinks for a second, but remains in place. " (capitalize-name (visible-name actor))))
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
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-BLESS: ~A [~A] prays for smiting~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to pray. " (capitalize-name (visible-name actor))))

                                                (let ((enemy-list nil))
                                                  (when (zerop (random 3))
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
                                                                 (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                        (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (get-qualified-name (get-mob-by-id enemy-mob-id)))))
                                                               (setf (face-mob-type-id (get-mob-by-id enemy-mob-id)) (mob-type (get-mob-by-id enemy-mob-id)))
                                                               (set-mob-effect (get-mob-by-id enemy-mob-id) :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))
                                                             (mob-burn-blessing actor (get-mob-by-id enemy-mob-id)))
                                                    ))
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
                                                           (not (zerop (length (visible-mobs actor))))
                                                           (or nearest-enemy
                                                               (zerop (random 5))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-free-call+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil :cd 3
                                 :motion 30
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (logger (format nil "MOB-FREE-CALL-FOR-HELP: ~A [~A] calls for help~%" (name actor) (id actor)))
                                                
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
                                                  (logger (format nil "MOB-FREE-CALL-FOR-HELP: The following allies might answer the call ~A~%" allies-list))
                                                  
                                                  ;; place the effect of "called for help" on the allies in the final list 
                                                  (loop for ally-mob-id in allies-list 
                                                        do
                                                           (set-mob-effect (get-mob-by-id ally-mob-id) :effect-type-id +mob-effect-called-for-help+ :actor-id (id actor) :cd 2))
                                                  
                                                  (set-mob-effect actor :effect-type-id +mob-effect-calling-for-help+ :actor-id (id actor) :cd 2)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone reciting incantations~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A calls for reinforcements. " (capitalize-name (visible-name actor))) :observed-mob actor))
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
                                 :id +mob-abil-prayer-shield+ :name "Pray for protection" :descr "Pray to grant divine protection (1/3rd chance only) to all allies in the area. Divine protection prevents the next harmful action against you." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] prays for shielding~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for protection. " (capitalize-name (visible-name actor))))

                                                (let ((ally-list nil))
                                                  (when (zerop (random 3))
                                                    ;; 1/3th chance to do anything
                                                    
                                                    ;; collect all allies in sight
                                                    (setf ally-list (loop for ally-mob-id in (visible-mobs actor)
                                                                          when (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                            collect ally-mob-id))
                                                    ;; do not forget self
                                                    (pushnew (id actor) ally-list)
                                                    
                                                    (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the following allies ~A with the prayer~%" (name actor) (id actor) ally-list))
                                                    
                                                    ;; grant all allies invulnerability for 99 turns
                                                    (loop for ally-mob-id in ally-list
                                                          do
                                                             (logger (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the ally ~A~%" (name actor) (id actor) (get-mob-by-id ally-mob-id)))
                                                             (set-mob-effect (get-mob-by-id ally-mob-id) :effect-type-id +mob-effect-divine-shield+ :actor-id (id actor) :cd 99)
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A is granted divine shield. " (capitalize-name (visible-name (get-mob-by-id ally-mob-id)))))
                                                          )
                                                    
                                                    ))
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
                                 :id +mob-abil-curse+ :name "Curse" :descr "Curse all visible enemies with diabolical incantations. The cursed individuals will have a 25% chance to miss. You only have 1/2 chance to successfully invoke the curse." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-CURSE: ~A [~A] incants the curses~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone laughing and cursing~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A laughs and curses maniacally. " (capitalize-name (visible-name actor))))

                                                (let ((enemy-list nil))
                                                  (when (zerop (random 2))
                                                    ;; 1/2th chance to do anything
                                                    
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
                                                                 (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                        (format nil "~A's curse removed divine protection from ~A. " (capitalize-name (visible-name actor)) (visible-name (get-mob-by-id enemy-mob-id))))
                                                                 )
                                                               (progn
                                                                 (logger (format nil "MOB-CURSE: ~A [~A] affects the enemy ~A with a curse~%" (name actor) (id actor) (get-mob-by-id enemy-mob-id)))
                                                                 (set-mob-effect (get-mob-by-id enemy-mob-id) :effect-type-id +mob-effect-cursed+ :actor-id (id actor) :cd 5)
                                                                 (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                        (format nil "~A is cursed. " (capitalize-name (visible-name (get-mob-by-id enemy-mob-id)))))))
                                                          )

                                                    ))
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
                                 :id +mob-abil-prayer-reveal+ :name "Pray for revelation" :descr "Pray to reveal supernatural beings in the area (1/2nd chance) and prevent them from being disguised for a while." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-PRAYER-REVEAL: ~A [~A] prays for revealing supernatural beings~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for revelation. " (capitalize-name (visible-name actor))))

                                                ;; reveal true form of all mobs in line of sight, 1/3rd chance
                                                (when (zerop (random 2))
                                                  (loop for mob-id in (visible-mobs actor)
                                                        for target = (get-mob-by-id mob-id)
                                                        do
                                                           (when (mob-effect-p target +mob-effect-divine-consealed+)
                                                             (rem-mob-effect target +mob-effect-divine-consealed+)
                                                             (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                             (setf (face-mob-type-id target) (mob-type target))
                                                             (print-visible-message (x target) (y target) (z actor) (level *world*) 
                                                                                    (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (get-qualified-name target))))
                                                           (when (mob-effect-p target +mob-effect-possessed+)
                                                             (unless (mob-effect-p target +mob-effect-reveal-true-form+)
                                                               (print-visible-message (x target) (y target) (z actor) (level *world*) 
                                                                                      (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (get-qualified-name target))))
                                                             (setf (face-mob-type-id target) (mob-type target))
                                                             (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))))                                                      
                                                
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
                                                           (not (zerop (length (visible-mobs actor))))
                                                           (zerop (random 3)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-military-follow-me+ :name "Follow me!" :descr "Order nearby subordinates to follow you. Up to five people may obey this order. Troops that are already following others, may be reluctant to follow you." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))

                                                (generate-sound actor (x actor) (y actor) (z actor) 10 #'(lambda (str)
                                                                                                             (format nil "You hear someone shouting orders~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A orders nearby allies to follow him. " (capitalize-name (visible-name actor))))
                                                
                                                ;; set order to up to six nearby units without orders
                                                (loop for i from 0 below (length (visible-mobs actor))
                                                      for mob = (get-mob-by-id (nth i (visible-mobs actor)))
                                                      with follower-num = 0
                                                      when (and (= (faction actor) (faction mob))
                                                                (not (mob-ability-p mob +mob-abil-independent+))
                                                                (or (not (order mob))
                                                                    (and (order mob)
                                                                         (= (first (order mob)) +mob-order-follow+)
                                                                         (/= (second (order mob)) (id actor))
                                                                         (zerop (random 2)))
                                                                    (and (order mob)
                                                                         (/= (first (order mob)) +mob-order-follow+))))
                                                        do
                                                           (setf (order mob) (list +mob-order-follow+ (id actor)))
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A obeys. " (capitalize-name (visible-name mob))))
                                                           (incf follower-num)
                                                           (when (>= follower-num 5) (loop-finish)))

                                                (logger (format nil "MOB-ORDER-FOLLOW-ME: ~A [~A] orders to follow him. Followers ~A~%" (name actor) (id actor) (get-followers-list actor)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-military-follow-me+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to order - do it
                                                  (if (and (mob-ability-p actor +mob-abil-military-follow-me+)
                                                           (can-invoke-ability actor actor +mob-abil-military-follow-me+)
                                                           (zerop (count-follower-list actor))
                                                           (not (zerop (loop for mob-id in (visible-mobs actor)
                                                                             for mob = (get-mob-by-id mob-id)
                                                                             when (and (= (faction actor) (faction mob))
                                                                                       (not (= (mob-type mob) +mob-type-chaplain+)))
                                                                               count mob-id)))
                                                           (zerop (random 3)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-blindness+ :name "Blindness" :descr "A flash of light that blinds nearby enemies for 2 turns." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A channels the heavenly light. " (capitalize-name (visible-name actor))))
                                                (logger (format nil "MOB-BLIND: ~A [~A] casts blindness.~%" (name actor) (id actor)))
                                                ;; blind nearby non-angel mobs
                                                (loop for i from 0 below (length (visible-mobs actor))
                                                      for mob = (get-mob-by-id (nth i (visible-mobs actor)))
                                                      when (not (mob-ability-p mob +mob-abil-angel+))
                                                        do
                                                           (set-mob-effect mob :effect-type-id +mob-effect-blind+ :actor-id (id actor) :cd 2)
                                                           (adjust-sight mob)
                                                           (if (eq *player* mob)
                                                             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                             (setf (visible-mobs mob) nil))
                                                           (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                  (format nil "~A is blind. " (capitalize-name (visible-name mob))))
                                                           )

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-blindness+)
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; cast blindness when your power is less than the power of enemies around you
                                                  ;; or you have <= than 25% of max hp
                                                  (if (and (mob-ability-p actor +mob-abil-blindness+)
                                                           (can-invoke-ability actor actor +mob-abil-blindness+)
                                                           (not (zerop (loop for mob-id in (visible-mobs actor)
                                                                             for mob = (get-mob-by-id mob-id)
                                                                             when (not (mob-effect-p mob +mob-effect-blind+))
                                                                               count mob-id)))
                                                           (or (<= (cur-hp actor) (truncate (max-hp actor) 4))
                                                               (< (strength actor) (loop for mob-id in (visible-mobs actor)
                                                                                         for mob = (get-mob-by-id mob-id)
                                                                                         when (not (get-faction-relation (faction actor) (faction mob)))
                                                                                           sum (strength mob)))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-instill-fear+ :name "Instill fear" :descr "Fear visible enemies around your for 3 turns. More powerfull characters may resist fear." 
                                 :cost 1 :spd (truncate +normal-ap+ 1.3) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))

                                                (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                            (format nil "You hear a roar~A. " str)))
                                                
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A roars to fear its enemies. " (capitalize-name (visible-name actor)))
                                                                       :observed-mob actor)
                                                (logger (format nil "MOB-INSTILL-FEAR: ~A [~A] casts instill fear.~%" (name actor) (id actor)))
                                                ;; fear nearby visible enemy mobs
                                                ;; fear can be resisted depending on the strength of the mob
                                                (loop for i from 0 below (length (visible-mobs actor))
                                                      for mob = (get-mob-by-id (nth i (visible-mobs actor)))
                                                      when (not (get-faction-relation (faction actor) (faction mob)))
                                                        do
                                                           (if (> (random (+ (strength mob) (mob-ability-p actor +mob-abil-instill-fear+))) (strength mob))
                                                             (progn
                                                               (set-mob-effect mob :effect-type-id +mob-effect-fear+ :actor-id (id actor) :cd 3)
                                                               (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                      (format nil "~A is feared. " (capitalize-name (visible-name mob)))
                                                                                      :observed-mob mob))
                                                             (progn
                                                               (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                      (format nil "~A resists fear. " (capitalize-name (visible-name mob)))
                                                                                      :observed-mob mob))))
                                                          
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-instill-fear+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; cast fear when you are revealed (or they won't understand that they need to fear you) and
                                                  ;; your power is less than the power of enemies around you
                                                  ;; or you have <= than 25% of max hp
                                                  (if (and (mob-ability-p actor +mob-abil-instill-fear+)
                                                           (can-invoke-ability actor actor +mob-abil-instill-fear+)
                                                           (= (face-mob-type-id actor) (mob-type actor))
                                                           (not (zerop (loop for mob-id in (visible-mobs actor)
                                                                             for mob = (get-mob-by-id mob-id)
                                                                             when (and (not (get-faction-relation (faction actor) (faction mob)))
                                                                                       (not (mob-effect-p mob +mob-effect-fear+)))
                                                                               count mob-id)))
                                                           (or (<= (cur-hp actor) (truncate (max-hp actor) 4))
                                                               (< (strength actor) (loop for mob-id in (visible-mobs actor)
                                                                                         for mob = (get-mob-by-id mob-id)
                                                                                         when (not (get-faction-relation (faction actor) (faction mob)))
                                                                                           sum (strength mob)))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-charge+ :name "Charge" :descr "Move up to 3 tiles to the specified place. Anybody on your way will be pushed back (if possible) and attacked." 
                                 :cd 4 :cost 0 :spd (truncate (* +normal-ap+ 1.5)) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; here the target is not a mob, but a (cons x y)
                                                (logger (format nil "MOB-CHARGE: ~A [~A] charges to ~A.~%" (name actor) (id actor) target))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A charges. " (capitalize-name (visible-name actor))))
                                                
                                                (let ((path-line nil) (cur-ap) (game-time) (dx1) (dy1) (target1 (cons (car target) (cdr target))))
                                                  (setf dx1 (- (car target) (x actor)))
                                                  (setf dy1 (- (cdr target) (y actor)))

                                                  (when (or (< (abs dx1) 3) (< (abs dy1) 3))
                                                    (setf (car target1) (+ (car target1) (* 3 dx1)))
                                                    (setf (cdr target1) (+ (cdr target1) (* 3 dy1))))
                                                  
                                                  (line-of-sight (x actor) (y actor) (z actor) (car target1) (cdr target1) (z actor) #'(lambda (dx dy dz prev-cell)
                                                                                                                                         (declare (ignore dz prev-cell))
                                                                                                                                         (let ((exit-result t))
                                                                                                                                            (block nil
                                                                                                                                              (push (cons dx dy) path-line)
                                                                                                                                              exit-result))))
                                                  (setf path-line (nreverse path-line))
                                                  (pop path-line)
                                                  
                                                  (setf game-time (player-game-time *world*))
                                                  (setf cur-ap (cur-ap actor))
                                                  
                                                  (loop for (nx . ny) in path-line
                                                        for dx = (- nx (x actor))
                                                        for dy = (- ny (y actor))
                                                        with charge-distance = 3
                                                        with charge-result = nil
                                                        while (not (zerop charge-distance))
                                                        do
                                                           (decf charge-distance)
                                                           (setf charge-result (move-mob actor (x-y-into-dir dx dy) :push t))
                                                           (when (eq charge-result nil)
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A hits an obstacle. " (capitalize-name (visible-name actor)))))
                                                           (unless (eq charge-result t)
                                                             (loop-finish))
                                                        )
                                                  (setf (cur-ap actor) cur-ap)
                                                  (setf (player-game-time *world*) game-time)
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-charge+)
                                                               (not (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if there is unobstructed direct path towards the enemy - charge
                                                  (block nil
                                                    (unless nearest-enemy
                                                      (return nil))
                                                    (let ((blocked nil))
                                                      (line-of-sight (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)
                                                                     #'(lambda (dx dy dz prev-cell)
                                                                         (declare (type fixnum dx dy))
                                                                         (let ((exit-result t))
                                                                           (block nil
                                                                             (unless (check-LOS-propagate dx dy dz prev-cell :check-move t)
                                                                               (setf exit-result 'exit)
                                                                               (setf blocked t)
                                                                               (return))
                                                                             )
                                                                           exit-result)))
                                                      (if (and (mob-ability-p actor +mob-abil-charge+)
                                                               (can-invoke-ability actor actor +mob-abil-charge+)
                                                               (not blocked))
                                                        t
                                                        nil))))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (mob-invoke-ability actor (cons (x nearest-enemy) (y nearest-enemy)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                        (progn
                                                          nil)
                                                        (progn
                                                          (clear-message-list *small-message-box*)
                                                          (mob-invoke-ability *player* (cons (view-x *player*) (view-y *player*)) ability-type-id)
                                                          t))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-momentum+ :name "Momentum" :descr "You can move quicker than most but it is difficult for you to change direction." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-animal+ :name "Animal" :descr "You are an animal." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-horseback-riding+ :name "Horseback riding" :descr "You can ride horses. To mount a horse, you must stand next to it." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-HORSEBACK-RIDING: ~A [~A] mounts ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                

                                                (set-mob-location actor (x target) (y target) (z target))
                                                (setf (mounted-by-mob-id target) (id actor))
                                                (setf (riding-mob-id actor) (id target))

                                                (when (or (check-mob-visible actor :observer *player*)
                                                          (check-mob-visible target :observer *player*))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A mounts ~A. " (capitalize-name (visible-name actor)) (visible-name target))))
                                                (adjust-dodge actor)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-horseback-riding+)
                                                               (not (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy nearest-ally))
                                                  (let ((mount nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (get-faction-relation (faction actor) (faction mob))
                                                                                                                 (mob-ability-p mob +mob-abil-horse-can-be-ridden+)
                                                                                                                 (not (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                    (if (and mount
                                                             (can-invoke-ability actor actor (id ability-type)))
                                                      t
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let ((mount nil))
                                                     (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (get-faction-relation (faction actor) (faction mob))
                                                                                                                 (mob-ability-p mob +mob-abil-horse-can-be-ridden+)
                                                                                                                 (null (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                     (mob-invoke-ability actor mount (id ability-type))))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (not (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                               (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                               (get-faction-relation (faction *player*) (faction (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (mob-ability-p (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +mob-abil-horse-can-be-ridden+)
                                                               (not (mounted-by-mob-id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))))
                                                        (progn
                                                          (clear-message-list *small-message-box*)
                                                          (mob-invoke-ability *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                          t)
                                                        (progn
                                                          nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-horse-can-be-ridden+ :name "Can be ridden" :descr "If somebody has the 'Horseback riding' ability, he/she can mount you." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-dismount+ :name "Dismount" :descr "Get off your mount, if you are riding one." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; here the target is not a mob, but a (cons x y)

                                                (let ((mount (get-mob-by-id (riding-mob-id actor))))
                                                  (logger (format nil "MOB-DISMOUNT: ~A [~A] dismounts ~A [~A].~%" (name actor) (id actor) (name mount) (id mount)))
                                                  
                                                  (setf (mounted-by-mob-id mount) nil)
                                                  (setf (riding-mob-id actor) nil)

                                                  
                                                  (set-mob-location actor (car target) (cdr target) (z actor))
                                                  
                                                  (set-mob-location mount (x mount) (y mount) (z mount))
                                                  
                                                  (when (or (check-mob-visible actor :observer *player*)
                                                            (check-mob-visible mount :observer *player*)) 
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A dismounts ~A. " (capitalize-name (visible-name actor)) (visible-name mount)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-dismount+)
                                                               (riding-mob-id actor))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore actor nearest-enemy ability-type nearest-ally))
                                                  nil
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((cell-list nil)
                                                            (half-size (truncate (1- (map-size (get-mob-by-id (riding-mob-id *player*)))) 2)))
                                                        ;; collect all cells around the mount
                                                        (loop for off of-type fixnum from (1- (- half-size)) to (1+ (+ half-size))
                                                              for x of-type fixnum = (+ (x *player*) off)
                                                              for y of-type fixnum = (+ (y *player*) off)
                                                              for y-up of-type fixnum = (- (y *player*) half-size 1)
                                                              for y-down of-type fixnum = (+ (y *player*) half-size 1)
                                                              for x-up of-type fixnum = (- (x *player*) half-size 1)
                                                              for x-down of-type fixnum = (+ (x *player*) half-size 1)
                                                              do
                                                                 (push (cons x y-up) cell-list)
                                                                 (push (cons x y-down) cell-list)
                                                                 (push (cons x-up y) cell-list)
                                                                 (push (cons x-down y) cell-list))

                                                        ;; remove all duplicate cells
                                                        (setf cell-list (remove-duplicates cell-list :test #'(lambda (a b)
                                                                                                               (let ((x1 (car a)) (x2 (car b)) (y1 (cdr a)) (y2 (cdr b)))
                                                                                                                 (declare (type fixnum x1 x2 y1 y2))
                                                                                                                 (if (and (= x1 x2) (= y1 y2))
                                                                                                                   t
                                                                                                                   nil)))))

                                                        (if (and (eq (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (z *player*)) nil)
                                                                 (eq (check-move-on-level *player* (view-x *player*) (view-y *player*) (z *player*)) t)
                                                                 (find (cons (view-x *player*) (view-y *player*)) cell-list
                                                                       :test #'(lambda (a b)
                                                                                 (let ((x1 (car a)) (x2 (car b)) (y1 (cdr a)) (y2 (cdr b)))
                                                                                   (declare (type fixnum x1 x2 y1 y2))
                                                                                   (if (and (= x1 x2) (= y1 y2))
                                                                                     t
                                                                                     nil)))))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (cons (view-x *player*) (view-y *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-dominate-fiend+ :name "Dominate fiend" :descr "You can mount a fiend, if you stand next to it. Riding a fiend will reveal your true form." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-DOMINATE-FIEND: ~A [~A] mounts ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (when (or (check-mob-visible actor :observer *player*)
                                                          (check-mob-visible target :observer *player*))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A mounts ~A" (capitalize-name (visible-name actor)) (visible-name target)))
                                                  ;; reveal the true form of those who ride fiends
                                                  (when (and (slave-mob-id actor)
                                                             (not (mob-effect-p actor +mob-effect-reveal-true-form+)))
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil " and reveals itself as ~A" (get-qualified-name actor))))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil ". ")))
                                                
                                                
                                                (set-mob-location actor (x target) (y target) (z target))
                                                
                                                (setf (mounted-by-mob-id target) (id actor))
                                                (setf (riding-mob-id actor) (id target))

                                                (adjust-dodge actor)
                                                
                                                
                                                (setf (face-mob-type-id actor) (mob-type actor))
                                                (set-mob-effect actor :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 4)
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-dominate-fiend+)
                                                               (not (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy nearest-ally))
                                                  (let ((mount nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (mob-ability-p mob +mob-abil-fiend-can-be-ridden+)
                                                                                                                 (not (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                    (if (and mount
                                                             (can-invoke-ability actor mount (id ability-type)))
                                                      t
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let ((mount nil))
                                                     (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (mob-ability-p mob +mob-abil-fiend-can-be-ridden+)
                                                                                                                 (null (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                     (mob-invoke-ability actor mount (id ability-type))))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (not (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                               (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                               (mob-ability-p (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +mob-abil-fiend-can-be-ridden+)
                                                               (not (mounted-by-mob-id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))))
                                                        (progn
                                                          (clear-message-list *small-message-box*)
                                                          (mob-invoke-ability *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                          t)
                                                        (progn
                                                          nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-fiend-can-be-ridden+ :name "Can be ridden" :descr "If somebody has the 'Dominate fiend' ability, he/she can mount you." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-starts-with-horse+ :name "Starts with a horse" :descr "You start your mission riding a horse." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-independent+ :name "Independent" :descr "You do not take orders from anyone." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-eagle-eye+ :name "Eagle eye" :descr "You can inspect an enemy unit to reveal its true form." 
                                 :cd 4 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-EAGLE-EYE: ~A [~A] uses eagle eye to reveal ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (if (or (mob-effect-p target +mob-effect-divine-consealed+)
                                                          (and (mob-effect-p target +mob-effect-possessed+)
                                                               (not (mob-effect-p target +mob-effect-reveal-true-form+))))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A reveals the true form of ~A. " (capitalize-name (visible-name actor)) (visible-name target)))
                                                    
                                                    (rem-mob-effect target +mob-effect-divine-consealed+)
                                                    (setf (face-mob-type-id target) (mob-type target))
                                                    (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "It is ~A. " (get-qualified-name target))))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A tries to reveal the true form of ~A. But ~A does not conseal anything. "
                                                                                   (capitalize-name (visible-name actor)) (visible-name target) (visible-name target)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-eagle-eye+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy))
                                                  ;; a little bit of cheating here
                                                  (if (and (can-invoke-ability actor actor (id ability-type))
                                                           nearest-ally
                                                           (or (mob-effect-p nearest-ally +mob-effect-divine-consealed+)
                                                               (and (mob-effect-p nearest-ally +mob-effect-possessed+)
                                                                    (not (mob-effect-p nearest-ally +mob-effect-reveal-true-form+))))
                                                           (zerop (random 4)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (not (mob-effect-p mob +mob-effect-reveal-true-form+))
                                                                 (not (and (mob-ability-p mob +mob-abil-demon+)
                                                                           (not (mob-effect-p mob +mob-effect-possessed+))))
                                                                 (not (and (mob-ability-p mob +mob-abil-angel+)
                                                                           (not (mob-effect-p mob +mob-effect-divine-consealed+)))))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-facing+ :name "Facing" :descr "You can not change the direction of your movement easily. You must first face the place where you go." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-immovable+ :name "Immovable" :descr "You won't let anybody push you around." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mind-burn+ :name "Mind burn" :descr "Burn the mind of an enemy in your line of sight for 2-4 dmg." 
                                 :cd 4 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-MIND-BURN: ~A [~A] uses mind burn on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (let ((cur-dmg))
                                                  (setf cur-dmg (+ 2 (random 3)))
                                                  (decf (cur-hp target) cur-dmg)
                                                                                                    
                                                  (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                         (format nil "~A burns the mind of ~A for ~A damage. " (capitalize-name (visible-name actor)) (visible-name target)  cur-dmg))
                                                  (when (check-dead target)
                                                    (make-dead target :splatter nil :msg t :msg-newline nil :killer actor :corpse t :aux-params ())
                                                    (when (mob-effect-p target +mob-effect-possessed+)
                                                      (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                      (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                            (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                            (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                      (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))
                                                    )
    
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-mind-burn+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor actor (id ability-type))
                                                           nearest-enemy)
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-gargantaur-teleport+ :name "Teleport self" :descr "Teleport yourself somewhere else." 
                                 :cd 20 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (logger (format nil "MOB-GARGANTAUR-TELEPORT: ~A [~A] teleports self~%" (name actor) (id actor)))

                                                (let ((max-x (array-dimension (terrain (level *world*)) 0))
                                                      (max-y (array-dimension (terrain (level *world*)) 1))
                                                      (rx (- (+ 80 (x actor))
                                                             (1+ (random 160)))) 
                                                      (ry (- (+ 80 (y actor))
                                                             (1+ (random 160))))
                                                      (n 2000))
                                                  ;; 2000 hundred tries to find a suitable place for teleport
                                                  (loop while (or (< rx 0) (< ry 0) (>= rx max-x) (>= ry max-y)
                                                                  (< (get-distance (x actor) (y actor) rx ry) 80)
                                                                  (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry (z actor)) +terrain-trait-opaque-floor+))
                                                                  (not (eq (check-move-on-level actor rx ry (z actor)) t))
                                                                  (= (get-level-connect-map-value (level *world*) rx ry (z actor) (if (riding-mob-id actor)
                                                                                                                                  (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                  (map-size actor))
                                                                                                  (get-mob-move-mode actor))
                                                                      +connect-room-none+))
                                                        do
                                                           
                                                           (decf n)
                                                           (when (zerop n)
                                                             (loop-finish))
                                                           (setf rx (- (+ 80 (x actor))
                                                                       (1+ (random 160))))
                                                           (setf ry (- (+ 80 (y actor))
                                                                       (1+ (random 160)))))
                                                  ;;(format t "MOB-GARGANTAUR-TELEPORT: (RX RY) = (~A ~A), N = ~A, CHECK-MOVE ~A, DIST = ~A~%" rx ry n (check-move-on-level actor rx ry (z actor)) (get-distance (x actor) (y actor) rx ry))
                                                  (if (not (zerop n))
                                                    (progn
                                                      (generate-sound actor (x actor) (y actor) (z actor) 120 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A." str)))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A disappeares in thin air. " (capitalize-name (visible-name actor))))
                                                      (set-mob-location actor rx ry (z actor))
                                                      (generate-sound actor (x actor) (y actor) (z actor) 120 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A." str)))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A appears out of thin air. " (capitalize-name (visible-name actor)))))
                                                    (progn
                                                      (generate-sound actor (x actor) (y actor) (z actor) 120 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A." str)))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A blinks for a second, but remains in place. " (capitalize-name (visible-name actor))))))
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-gargantaur-teleport+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; teleport if there is no enemy in sight or if HP < 50%
                                                  (if (and (mob-ability-p actor +mob-abil-gargantaur-teleport+)
                                                           (can-invoke-ability actor actor +mob-abil-gargantaur-teleport+)
                                                           (or (not nearest-enemy)
                                                               (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.5))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-dominate-gargantaur+ :name "Dominate Gargantaur" :descr "You can mount a Gargantaur, if you stand next to it, but at a cost of inflicting yourself the amount of damage equal to the half of your maximum HP. Riding one will reveal your true form." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-DOMINATE-GARGANTAUR: ~A [~A] mounts ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (let ((cur-dmg (truncate (max-hp actor) 2)))
                                                  (decf (cur-hp actor) cur-dmg)

                                                  (if (<= (cur-hp actor) 0)
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A cringes with pain, taking ~A dmg, while trying to mount ~A. " (capitalize-name (visible-name actor)) cur-dmg (visible-name target)))
                                                      (make-dead actor :splatter t :msg t :msg-newline nil :killer nil :corpse t :aux-params ()))
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A cringes with pain, taking ~A dmg, and mounts ~A" (capitalize-name (visible-name actor)) cur-dmg (visible-name target)))

                                                      ;; reveal the true form of those who ride fiends
                                                      (when (mob-effect-p actor +mob-effect-divine-consealed+)
                                                        (rem-mob-effect actor +mob-effect-divine-consealed+)
                                                        (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                               (format nil " to reveal itself as ~A" (get-qualified-name actor))))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil ". "))
                                                      
                                                      (set-mob-location actor (x target) (y target) (z target))
                                                      
                                                      (setf (mounted-by-mob-id target) (id actor))
                                                      (setf (riding-mob-id actor) (id target))
                                                                                                            
                                                      (adjust-dodge actor)
                                                      
                                                      
                                                      (setf (face-mob-type-id actor) (mob-type actor))
                                                      (set-mob-effect actor :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 4)
                                                      
                                                      ))
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-dominate-gargantaur+)
                                                               (not (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy nearest-ally))
                                                  (let ((mount nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (= (mob-type mob) +mob-type-gargantaur+)
                                                                                                                 (null (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                    (if (and mount
                                                             (> (/ (cur-hp actor) (max-hp actor)) 
                                                                0.5)
                                                             (can-invoke-ability actor mount (id ability-type)))
                                                      t
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let ((mount nil))
                                                     (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and mob
                                                                                                                 (= (mob-type mob) +mob-type-gargantaur+)
                                                                                                                 (null (mounted-by-mob-id mob)))
                                                                                                        (setf mount mob)))))
                                                     (mob-invoke-ability actor mount (id ability-type))))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mount-list nil))
                                                        (check-surroundings (x *player*) (y *player*) nil #'(lambda (dx dy)
                                                                                                              (let ((mob (get-mob-* (level *world*) dx dy (z *player*))))
                                                                                                                (when (and mob
                                                                                                                           (= (mob-type mob) +mob-type-gargantaur+)
                                                                                                                           (null (mounted-by-mob-id mob)))
                                                                                                                  (pushnew mob mount-list)))))
                                                        
                                                        (if (find (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) mount-list)
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                        (progn
                                                          nil))
                                                      ))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-gargantaurs-mind-burn+ :name "Gargantaur's mind burn" :descr "Use your Gargantuar to burn the mind of an enemy in your line of sight for 2-4 dmg. You must be riding a Gargantaur to invoke this ability." 
                                 :cd 4 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-GARGANTAURS-MIND-BURN: ~A [~A] uses mind burn on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (let ((cur-dmg))
                                                  (setf cur-dmg (+ 2 (random 3)))
                                                  (decf (cur-hp target) cur-dmg)
                                                                                                    
                                                  (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                         (format nil "~A uses its Gargantaur to burn the mind of ~A for ~A damage. " (capitalize-name (visible-name actor)) (visible-name target)  cur-dmg))
                                                  (when (check-dead target)
                                                    (make-dead target :splatter nil :msg t :msg-newline nil :killer actor :corpse t :aux-params ())
                                                    (when (mob-effect-p target +mob-effect-possessed+)
                                                      (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                      (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                            (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                            (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                      (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))
                                                    )
    
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-gargantaurs-mind-burn+)
                                                               (riding-mob-id actor)
                                                               (= (mob-type (get-mob-by-id (riding-mob-id actor))) +mob-type-gargantaur+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor actor (id ability-type))
                                                           nearest-enemy)
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))


(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-death-from-above+ :name "Death from Above" :descr "Jump from above on your prey and land a devastating attack for 5-8 iron dmg." 
                                 :cd 1 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-DEATH-FROM-ABOVE: ~A [~A] uses death from above on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A strikes from above. " (capitalize-name (visible-name actor))))
                                                                                                
                                                (let ((tx (x target)) (ty (y target)) (tz (1+ (z target))))
                                                  (block surround
                                                    (check-surroundings (x target) (y target) nil
                                                                        #'(lambda (dx dy)
                                                                            (when (eq (check-move-on-level actor dx dy (z target)) t)
                                                                              (setf tx dx ty dy tz (z target))
                                                                              (when (zerop (random 4))
                                                                                (return-from surround))))))
                                                  (set-mob-location actor tx ty tz))

                                                (make-melee-attack actor target :weapon (list "Knife" (list +weapon-dmg-iron+ 5 8 +normal-ap+ 100 ()) ())
                                                                                :acc 100 :no-dodge t :make-act nil)
                                                
                                                (when (check-dead target)
                                                  (when (mob-effect-p target +mob-effect-possessed+)
                                                    (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                    (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                          (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                          (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                    (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-death-from-above+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor actor (id ability-type))
                                                           nearest-enemy
                                                           ;; check if you are above
                                                           (> (z actor) (z nearest-enemy))
                                                           ;; check if you are not too far
                                                           (< (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 3)
                                                           ;; check if there is unobstructed line of sight
                                                           (funcall #'(lambda ()
                                                                        (let ((result t) (x (x actor)) (y (y actor)))
                                                                          (when (and (<= (abs (- (x actor) (x nearest-enemy))) 1)
                                                                                     (<= (abs (- (y actor) (y nearest-enemy))) 1))
                                                                            (setf x (x nearest-enemy) y (y nearest-enemy)))
                                                                          (line-of-sight x y (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)
                                                                                         #'(lambda (dx dy dz prev-cell)
                                                                                             (declare (type fixnum dx dy dz))
                                                                                             (let* ((exit-result t))
                                                                                               (block nil
                                                                                                 (unless (check-LOS-propagate dx dy dz prev-cell :check-move t)
                                                                                                   (setf exit-result 'exit)
                                                                                                   (setf result nil)
                                                                                                   (return))
                                                                                                 )
                                                                                               exit-result)))
                                                                          result)))
                                                           )
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (> (z *player*) (z mob))
                                                                 (< (get-distance (x *player*) (y *player*) (x mob) (y mob)) 3)
                                                                 (funcall #'(lambda ()
                                                                              (let ((result t) (x (x *player*)) (y (y *player*)))
                                                                                (when (and (<= (abs (- (x *player*) (x mob))) 1)
                                                                                           (<= (abs (- (y *player*) (y mob))) 1))
                                                                                  (setf x (x mob) y (y mob)))
                                                                                (line-of-sight x y (z *player*) (x mob) (y mob) (z mob)
                                                                                               #'(lambda (dx dy dz prev-cell)
                                                                                                   (declare (type fixnum dx dy dz))
                                                                                                   (let* ((exit-result t))
                                                                                                     (block nil
                                                                                                       (unless (check-LOS-propagate dx dy dz prev-cell :check-move t)
                                                                                                         (setf exit-result 'exit)
                                                                                                         (setf result nil)
                                                                                                         (return))
                                                                                                       )
                                                                                                     exit-result)))
                                                                                result)))
                                                                 )
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-climbing+ :name "Climbing" :descr "Toggle the climbing mode. While in the climbing mode you are able to scale walls up and down and will not fall as long as you remain next to a solid wall or a floor. You can toggle the climbing mode at any time." 
                                 :cost 0 :spd 0 :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (if (mob-effect-p actor +mob-effect-climbing-mode+)
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle off the climbing mode. "))
                                                    (rem-mob-effect actor +mob-effect-climbing-mode+)
                                                    (when (apply-gravity actor)
                                                      (set-mob-location actor (x actor) (y actor) (z actor))
                                                      (make-act actor +normal-ap+)))
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle on the climbing mode. "))
                                                    (set-mob-effect actor :effect-type-id +mob-effect-climbing-mode+ :actor-id (id actor) :cd t))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-climbing+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-climbing+)
                                                           (can-invoke-ability actor actor +mob-abil-climbing+)
                                                           (not (mob-effect-p actor +mob-effect-climbing-mode+)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-no-breathe+ :name "Does no breathe" :descr "Your do not require oxygen to sustain your life." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-open-close-door+ :name "Open/close door" :descr "Open or close door (depending on the current status of the door in question). You can also open a closed door by walking into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (= (get-terrain-* (level *world*) x y z) +terrain-door-open+)
                                                    (print-visible-message x y z (level *world*) (format nil "~A opens the door. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                    (print-visible-message x y z (level *world*) (format nil "~A closes the door. " (capitalize-name (visible-name actor))) :observed-mob actor)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-open-close-door+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-open-close-door+)
                                                           (can-invoke-ability actor actor +mob-abil-open-close-door+)
                                                           (path actor)
                                                           (= (get-terrain-* (level *world*) (first (first (path actor))) (second (first (path actor))) (third (first (path actor)))) +terrain-door-closed+)
                                                           (null (get-mob-* (level *world*) (first (first (path actor))) (second (first (path actor))) (third (first (path actor))))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor (first (path actor)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (or (= terrain +terrain-door-closed+)
                                                                     (= terrain +terrain-door-open+)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-toggle-light+ :name "Toggle light" :descr "Switch a light on or off (depending on the current status of the light source in question). You can also toggle a light by walking into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (or (null (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+))
                                                          (eq 0 (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+)))
                                                    (print-visible-message x y z (level *world*) (format nil "~A switches off the light. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                    (print-visible-message x y z (level *world*) (format nil "~A switches on the light. " (capitalize-name (visible-name actor))) :observed-mob actor)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-toggle-light+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  ;; if you can toggle lights and you happen to be nearby, and you do not radiate light yourself - switch it off
                                                  ;; if you can toggle lights and you happen to be nearby, and you do radiate light yourself - switch it on
                                                  (let ((light-source nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (or (and (zerop (cur-light actor))
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (not (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+))))
                                                                                                                     (and (not (zerop (cur-light actor)))
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+)))))
                                                                                                        (setf light-source (list dx dy (z actor)))))))
                                                    (if (and (mob-ability-p actor +mob-abil-toggle-light+)
                                                             (can-invoke-ability actor actor +mob-abil-toggle-light+)
                                                             light-source)
                                                      t
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let ((light-source nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (or (and (zerop (cur-light actor))
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (not (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+))))
                                                                                                                     (and (not (zerop (cur-light actor)))
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+)))))
                                                                                                        (setf light-source (list dx dy (z actor)))))))
                                                     (when light-source
                                                       (mob-invoke-ability actor light-source (id ability-type))))
                                                   )
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (get-terrain-type-trait terrain +terrain-trait-light-source+))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-open-close-window+ :name "Open/close window" :descr "Open or close window (depending on the current status of the door in question). You can also open a closed window by walking into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (= (get-terrain-* (level *world*) x y z) +terrain-wall-window-opened+)
                                                    (print-visible-message x y z (level *world*) (format nil "~A opens the window. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                    (print-visible-message x y z (level *world*) (format nil "~A closes the window. " (capitalize-name (visible-name actor))) :observed-mob actor)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-open-close-window+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-open-close-window+)
                                                           (can-invoke-ability actor actor +mob-abil-open-close-window+)
                                                           (path actor)
                                                           (= (get-terrain-* (level *world*) (first (first (path actor))) (second (first (path actor))) (third (first (path actor)))) +terrain-wall-window+)
                                                           (null (get-mob-* (level *world*) (first (first (path actor))) (second (first (path actor))) (third (first (path actor))))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor (first (path actor)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (or (= terrain +terrain-wall-window+)
                                                                     (= terrain +terrain-wall-window-opened+)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-can-possess-toggle+ :name "Toggle possession mode" :descr "Toggle your ability to possess other creatures. If switched off, you will attack a possessable target instead of possessing it. You can toggle the possession mode at any time." 
                                 :cost 0 :spd 0 :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (if (mob-effect-p actor +mob-effect-ready-to-possess+)
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle off the possession mode. "))
                                                    (rem-mob-effect actor +mob-effect-ready-to-possess+))
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle on the possession mode. "))
                                                    (set-mob-effect actor :effect-type-id +mob-effect-ready-to-possess+ :actor-id (id actor) :cd t))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-can-possess-toggle+)
                                                               (null (slave-mob-id actor))
                                                               (null (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-can-possess-toggle+)
                                                           (can-invoke-ability actor actor +mob-abil-can-possess-toggle+)
                                                           (not (mob-effect-p actor +mob-effect-ready-to-possess+)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-sacrifice-host+ :name "Sacrifice host" :descr "Sacrifice the human you are currently possessing to gain health and power. However, killing the human host will (obviously) show your true face." 
                                 :cost 0 :spd 5 :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (let ((target (get-mob-by-id (slave-mob-id actor))))
                                                  ;; target here is the slave mob
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A destroys its host. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                  (setf (cur-hp target) 0)
                                                  (make-dead target :splatter t :msg t :killer actor :corpse nil :aux-params ())
                                                  
                                                  (loop repeat 8
                                                        for (dx dy) = (multiple-value-list (x-y-dir (1+ (random 9))))
                                                        do
                                                           (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ dx (x actor)) :y (+ dy (y actor)) :z (z actor))))
                                                  (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-stain+ :x (x actor) :y (y actor) :z (z actor)))
                                                  (rem-mob-effect actor +mob-effect-possessed+)
                                                  (setf (face-mob-type-id actor) (mob-type actor))
                                                  (setf (master-mob-id target) nil)
                                                  (setf (slave-mob-id actor) nil)
                                                  (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                             (format nil "You hear a scream and ripping of flesh~A." str)))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-sacrifice-host+)
                                                               (slave-mob-id actor))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-sacrifice-host+)
                                                           (can-invoke-ability actor actor +mob-abil-sacrifice-host+)
                                                           (< (/ (cur-hp actor) (max-hp actor)) 
                                                              0.25))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor (get-mob-by-id (slave-mob-id actor)) (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-reanimate-corpse+ :name "Reanimate body" :descr "Invite an outworldly demon to enter a dead body (or a severed body part) and reanimate it. The strength of the reanimated corpse depends on its completeness - missing parts will reduce it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :cd 4 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (logger (format nil "MOB-REANIMATE-BODY: ~A [~A] reanimates ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))
                                                ;; target here is the item to be reanimated
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A raises his hands and intones an incantation. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear somebody chanting~A. " str)))
                                                (let ((mob-corpse-type) (mob-corpse))
                                                  (cond
                                                    ((eq (item-ability-p target +item-abil-corpse+) 1) (setf mob-corpse-type +mob-type-reanimated-pwr-1+))
                                                    ((eq (item-ability-p target +item-abil-corpse+) 2) (setf mob-corpse-type +mob-type-reanimated-pwr-2+))
                                                    ((eq (item-ability-p target +item-abil-corpse+) 3) (setf mob-corpse-type +mob-type-reanimated-pwr-3+))
                                                    (t (setf mob-corpse-type +mob-type-reanimated-pwr-4+)))
                                                  (setf mob-corpse (make-instance 'mob :mob-type mob-corpse-type :x (x target) :y (y target) :z (z target)))
                                                  (setf (name mob-corpse) (format nil "Reanimated ~A" (name target)))
                                                  (setf (alive-name mob-corpse) (alive-name target))
                                                  (add-mob-to-level-list (level *world*) mob-corpse)
                                                  (remove-item-from-level-list (level *world*) target)
                                                  (print-visible-message (x mob-corpse) (y mob-corpse) (z mob-corpse) (level *world*) (format nil "~A starts to move. " (capitalize-name (visible-name target))))
                                                  (logger (format nil "MOB-REANIMATE-BODY: ~A [~A] is reanimated at (~A ~A ~A).~%" (name actor) (id actor) (x mob-corpse) (y mob-corpse) (z mob-corpse)))
                                                  (remove-item-from-world target)
                                                  (incf (stat-raised-dead actor)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-reanimate-corpse+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-reanimate-corpse+)
                                                           (can-invoke-ability actor actor +mob-abil-reanimate-corpse+)
                                                           (funcall #'(lambda ()
                                                                        (let ((visible-items (copy-list (visible-items actor))))
                                                                          (setf visible-items (remove-if #'(lambda (a)
                                                                                                             (if (item-ability-p (get-item-by-id a) +item-abil-corpse+)
                                                                                                               nil
                                                                                                               t))
                                                                                                         visible-items))
                                                                          (setf visible-items (remove-if #'(lambda (a)
                                                                                                             (if (get-mob-* (level *world*) (x a) (y a) (z a))
                                                                                                               t
                                                                                                               nil))
                                                                                                         visible-items
                                                                                                         :key #'get-item-by-id))
                                                                          (setf visible-items (stable-sort visible-items #'(lambda (a b)
                                                                                                                             (if (> (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                                    (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                               t
                                                                                                                               nil))
                                                                                                           :key #'get-item-by-id))
                                                                          (if visible-items
                                                                            (first visible-items)
                                                                            nil))))
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let ((item-id (funcall #'(lambda ()
                                                                               (let ((visible-items (copy-list (visible-items actor))))
                                                                                 (setf visible-items (remove-if #'(lambda (a)
                                                                                                                    (if (item-ability-p (get-item-by-id a) +item-abil-corpse+)
                                                                                                                      nil
                                                                                                                      t))
                                                                                                                visible-items))
                                                                                 (setf visible-items (remove-if #'(lambda (a)
                                                                                                                    (if (get-mob-* (level *world*) (x a) (y a) (z a))
                                                                                                                      t
                                                                                                                      nil))
                                                                                                                visible-items
                                                                                                                :key #'get-item-by-id))
                                                                                 (setf visible-items (stable-sort visible-items #'(lambda (a b)
                                                                                                                                    (if (> (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                                           (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                                      t
                                                                                                                                      nil))
                                                                                                                  :key #'get-item-by-id))
                                                                                 (if visible-items
                                                                                   (first visible-items)
                                                                                   nil))))))
                                                     (mob-invoke-ability actor (get-item-by-id item-id) (id ability-type))))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((items (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (exit-result nil))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (item-ability-p (get-item-by-id a) +item-abil-corpse+)
                                                                                     nil
                                                                                     t))
                                                                               items))
                                                        (cond
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (> (length items) 1))
                                                           (progn
                                                             (let ((item-line-list nil)
                                                                   (item-prompt-list)
                                                                   (item-list (copy-list items)))

                                                               (setf item-line-list (loop for item-id in item-list
                                                                                          for item = (get-item-by-id item-id)
                                                                                          collect (format nil "~A~A"
                                                                                                          (capitalize-name (name item))
                                                                                                          (if (> (qty item) 1)
                                                                                                            (format nil " x~A" (qty item))
                                                                                                            ""))))
                                                               ;; populate the ability prompt list
                                                               (setf item-prompt-list (loop for item-id in item-list
                                                                                            collect #'(lambda (cur-sel)
                                                                                                        (declare (ignore cur-sel))
                                                                                                        "[Enter] Reanimate  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a body part to reanimate:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list *small-message-box*)
                                                                                                                     (mob-invoke-ability *player* (get-inv-item-by-pos item-list cur-sel) ability-type-id)
                                                                                                                     (setf *current-window* (return-to (return-to (return-to *current-window*))))
                                                                                                                     ;(set-idle-calcing win)
                                                                                                                     (make-output *current-window*)
                                                                                                                     ;(show-time-label (idle-calcing win) (+ 20 (* *glyph-w* *max-x-view*)) (+ 10 237) t)
                                                                                                                     (setf exit-result t))
                                                                                                     :line-list item-line-list
                                                                                                     :prompt-list item-prompt-list))
                                                               (make-output *current-window*)
                                                               (run-window *current-window*))
                                                             exit-result)
                                                           )
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (= (length items) 1)
                                                                (item-ability-p (get-item-by-id (first items)) +item-abil-corpse+))
                                                           (progn
                                                             (clear-message-list *small-message-box*)
                                                             (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil))))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-undead+ :name "Undead" :descr "Your existance defies all logic - you are dead, yet you live. However, fire may burn your body to ashes." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-shared-minds+ :name "Shared minds" :descr "You share a single mind with your kind - you see what they see, they see what you see." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-empower-undead+ :name "Empower undead" :descr "Link the demon inside a dead body with your own life force, enhancing its strength and making it follow you. You can only have one undead unit empowered at the same time." 
                                 :cd 5 :cost 0 :spd 5 :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A raises his hands and intones an incantation. " (capitalize-name (visible-name actor))) :observed-mob actor)
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear somebody chanting~A. " str)))
                                                
                                                ;; if the actor has already empowered a mob, remove the empower effect from it
                                                (when (mob-effect-p actor +mob-effect-necrolink+)
                                                  (let ((effect (get-effect-by-id (mob-effect-p actor +mob-effect-necrolink+))))
                                                    (rem-mob-effect (get-mob-by-id (param1 effect)) +mob-effect-empowered-undead+)))
                                                ;; target here is an undead mob
                                                (set-mob-effect target :effect-type-id +mob-effect-empowered-undead+ :actor-id (id actor) :cd t :param1 (id actor))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-empower-undead+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-empower-undead+)
                                                           (can-invoke-ability actor actor +mob-abil-empower-undead+)
                                                           (not (mob-effect-p actor +mob-effect-necrolink+))
                                                           nearest-ally
                                                           (mob-ability-p nearest-ally +mob-abil-undead+)
                                                           (not (mob-effect-p nearest-ally +mob-effect-empowered-undead+)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 target
                                                                 (get-faction-relation (faction *player*) (faction target))
                                                                 (mob-ability-p target +mob-abil-undead+)
                                                                 (not (mob-effect-p target +mob-effect-empowered-undead+)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* target ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                       )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-ignite-the-fire+ :name "Ignite the fire" :descr "Set flammable furniture or grass on fire. Fire may damage those standing in it and produces smoke." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be ignited
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (print-visible-message x y z (level *world*) (format nil "~A sets ~A on fire. " (capitalize-name (visible-name actor)) (get-terrain-name (get-terrain-* (level *world*) x y z)))
                                                                         :observed-mob actor)
                                                  (ignite-tile (level *world*) x y z (x actor) (y actor) (z actor))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-ignite-the-fire+)
                                                               (get-melee-weapon-aux-param actor :is-fire)
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((flammable-tile nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-flammable+)
                                                                                                                 nearest-enemy
                                                                                                                 (= dx (x nearest-enemy))
                                                                                                                 (= dy (y nearest-enemy))
                                                                                                                 (= (z actor) (z nearest-enemy))
                                                                                                                 )
                                                                                                        (setf flammable-tile (list dx dy (z actor)))))))
                                                    (if (and (mob-ability-p actor +mob-abil-ignite-the-fire+)
                                                             (can-invoke-ability actor actor +mob-abil-ignite-the-fire+)
                                                             flammable-tile
                                                             (< (/ (cur-hp actor) (max-hp actor)) 
                                                              0.6))
                                                      
                                                      t
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (let ((flammable-tile nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-flammable+)
                                                                                                                 nearest-enemy
                                                                                                                 (= dx (x nearest-enemy))
                                                                                                                 (= dy (y nearest-enemy))
                                                                                                                 (= (z actor) (z nearest-enemy))
                                                                                                                 )
                                                                                                        (setf flammable-tile (list dx dy (z actor)))))))
                                                    (mob-invoke-ability actor flammable-tile (id ability-type))))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (get-terrain-type-trait terrain +terrain-trait-flammable+))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-avatar-of-brilliance+ :name "Avatar of Brilliance" :descr "Transform youself into Avatar of Brilliance for 6 turns, significantly boosting your combat prowess." 
                                 :cost 4 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-avatar-of-brilliance+ :actor-id (id actor) :cd 6)
                                                (decf (cur-fp actor) (cost ability-type))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-avatar-of-brilliance+)
                                                               (not (mob-effect-p actor +mob-effect-divine-consealed+))
                                                               (not (mob-effect-p actor +mob-effect-avatar-of-brilliance+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if able to heal and less than 50% hp - heal
                                                  (if (and (or (and nearest-enemy
                                                                    (> (strength nearest-enemy) 
                                                                       (strength actor)))
                                                               (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.3)))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-avatar-of-brilliance+)
                                                           (can-invoke-ability actor actor +mob-abil-avatar-of-brilliance+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-gravity-chains+ :name "Gravity chains" :descr "Make your chains grab a target and inflict 2-4 dmg. If the target is flying or climbing, it is forced to the ground and will not be able to use respective abilities for 3 turns."
                                 :cd 4 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (let ((cur-dmg (+ 2 (random 3))))
                                                  (set-mob-effect target :effect-type-id +mob-effect-gravity-pull+ :actor-id (id actor) :cd 3)
                                                  (decf (cur-hp target) cur-dmg)
                                                  (generate-sound actor (x target) (y target) (z target) 80 #'(lambda (str)
                                                                                                                (format nil "You hear metal clanking~A. " str)))
                                                  
                                                  (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                         (format nil "~A invokes gravity chains on ~A to inflict ~A dmg. " (capitalize-name (visible-name actor)) (visible-name target) cur-dmg))
                                                  (rem-mob-effect target +mob-effect-climbing-mode+)
                                                  (rem-mob-effect target +mob-effect-flying+)
                                                  (when (apply-gravity target)
                                                    (set-mob-location target (x target) (y target) (z target)))
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-gravity-chains+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-gravity-chains+)
                                                           (can-invoke-ability actor actor +mob-abil-gravity-chains+)
                                                           nearest-enemy
                                                           (not (mob-effect-p nearest-enemy +mob-effect-gravity-pull+))
                                                           (or (and (= (z actor) (z nearest-enemy))
                                                                    (> (get-distance-3d (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 1.5))
                                                               (and (/= (z actor) (z nearest-enemy))
                                                                    (not (and (= (x actor) (x nearest-enemy))
                                                                              (= (y actor) (y nearest-enemy)))))))
                                                    
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                   (declare (ignore nearest-ally))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 
                                                                 target
                                                                 (not (eq *player* target)))
                                                          (progn
                                                            (clear-message-list *small-message-box*)
                                                            (mob-invoke-ability *player* target ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-flying+ :name "Can fly" :descr "You can fly permanently." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-no-corpse+ :name "No corpse" :descr "Your body does not leave a corpse when you die." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))
