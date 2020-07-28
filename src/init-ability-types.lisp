(in-package :cotd)

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-heal-self+ :name "Heal self" :descr "Invoke divine powers to heal yourself." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (let ((heal-pwr (+ (* 4 (mob-ability-value actor +mob-abil-heal-self+))
                                                                   (random (* 3 (mob-ability-value actor +mob-abil-heal-self+))))))
                                                  (when (> (+ (cur-hp actor) heal-pwr)
                                                           (max-hp actor))
                                                    (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                  (incf (cur-hp actor) heal-pwr)
                                                  (decf (cur-fp actor) (cost ability-type))

                                                  (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                             (format nil "You hear some strange noise~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to heal itself for ~A. " (capitalize-name (prepend-article +article-the+  (visible-name actor))) heal-pwr)
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-conceal-divine+ :name "Conceal divinity" :descr "Disguise yourself as a human. Divine abilities do not work while in human form." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 25
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-divine-concealed+ :actor-id (id actor) :cd t)
                                                (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                           (format nil "You hear some strange noise~A. " str)))
                                                (when (check-mob-visible actor :observer *player*)
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to disguise itself as a human. " (capitalize-name (prepend-article +article-the+  (name actor))))
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-reveal-true-form+))
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if the dst is more than 3 tiles away - stealth, if possible
                                                  (if (and (path actor)
                                                           (> (length (path actor)) 3)
                                                           (or (not nearest-enemy)
                                                               (and nearest-enemy
                                                                    (> (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2)))
                                                           (mob-ability-p actor +mob-abil-conceal-divine+)
                                                           (can-invoke-ability actor actor +mob-abil-conceal-divine+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-reveal-divine+ :name "Reveal divinity" :descr "Invoke to reveal you divinity." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 25
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (rem-mob-effect actor +mob-effect-divine-concealed+)
                                                (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                           (format nil "You hear some strange noise~A. " str)))
                                                 (when (check-mob-visible actor :observer *player*)
                                                   (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                          (format nil "~A reveals its true divine form. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                          :color sdl:*white*
                                                                          :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                        :singlemind)))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-effect-p actor +mob-effect-divine-concealed+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if able to heal and need to reveal itself - do it
                                                  ;; if the enemy is near and the dst tile is less than 2 tiles away - unstealth, if possible
                                                  (if (or (and (<= (length (path actor)) 1)
                                                               (mob-ability-p actor +mob-abil-reveal-divine+)
                                                               (can-invoke-ability actor actor +mob-abil-reveal-divine+)
                                                               nearest-enemy
                                                               (< (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy))
                                                                  2))
                                                          (and (< (/ (cur-hp actor) (max-hp actor)) 
                                                                  0.5)
                                                               (mob-ability-p actor +mob-abil-heal-self+)
                                                               (mob-effect-p actor +mob-effect-divine-concealed+)
                                                               (mob-ability-p actor +mob-abil-reveal-divine+)
                                                               (can-invoke-ability actor actor +mob-abil-reveal-divine+)
                                                               (abil-applic-cost-p +mob-abil-heal-self+ actor)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-detect-good+ :name "Detect good" :descr "You are able to reveal the true form of divine beings when you touch them. You can also sense the general direction to the nearest diving being." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch t
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (rem-mob-effect target +mob-effect-divine-concealed+)
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A reveals the true form of ~A. "
                                                                               (capitalize-name (prepend-article +article-the+  (visible-name actor)))
                                                                               (prepend-article +article-the+ (get-qualified-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-detect-good+)
                                                               (mob-effect-p target +mob-effect-divine-concealed+))
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
                                                                         (format nil "~A reveals the true form of ~A. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                 (prepend-article +article-the+ (get-qualified-name target)))
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind))))
                                                (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-detect-evil+)
                                                               (mob-effect-p target +mob-effect-possessed+)
                                                               (not (mob-ability-p target +mob-abil-ghost-possess+)))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-possessable+ :name "Can be possessed" :descr "Your body can be possessed by demonic forces." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-nameless+ :name "Nameless" :descr "You are one of may and have no name." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-strength-in-numbers+ :name "Strength in numbers" :descr "You get +10% max damage for each attack for every friendly demon in your line of sight." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-coward+ :name "Coward" :descr "You are a coward and feel safe only when demonic allies are nearby. You get twice as much bonus from the Strength in numbers ability." 
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
                                                
                                                (log:info (format nil "MOB-POSSESS-TARGET: ~A [~A] possesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
                                                
                                                (rem-mob-effect actor +mob-effect-ready-to-possess+)
                                                
                                                (mob-possess-target actor target)
                                                
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A possesses ~A. " (capitalize-name (prepend-article +article-the+ (name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
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
                                                
                                                (melee-target actor target :kill-possessed nil)
                                                (log:info (format nil "INSIDE PURGING TOUCH: ~A, (check-dead target) ~A~%" (name target) (check-dead target)))
                                                (when (and (check-dead target)
                                                           (slave-mob-id target))
                                                  (incf (cur-fp actor))
                                                  (mob-depossess-target target))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-purging-touch+)
                                                               (mob-effect-p target +mob-effect-possessed+)
                                                               (not (mob-ability-p target +mob-abil-ghost-possess+))
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+)))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-purge-rune+ :name "Purge rune" :descr "Purge a demonic rune and gain 4 power for it. You must stand next to a rune to purge it." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-select-rune
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is a feature (demonic rune) to be purged
                                                (log:info (format nil "MOB-PURGE-RUNE: ~A [~A] purges ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor)
                                                                (name target) (id target) (x target) (y target) (z target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A purges ~A and gains power. "
                                                                                                                             (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                                             (prepend-article +article-a+ (name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                
                                                (remove-feature-from-level-list (level *world*) target)
                                                (remove-feature-from-world target)
                                                (incf (cur-fp actor) 4)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((rune nil))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                        (loop for feature-id in (get-features-* (level *world*) dx dy (z actor))
                                                                                                              for feature = (get-feature-by-id feature-id)
                                                                                                              when (get-feature-type-trait feature +feature-trait-demonic-rune+)
                                                                                                                do
                                                                                                                   (setf rune feature)
                                                                                                                   (loop-finish))))
                                                        (if (and rune
                                                                 (mob-ability-p actor +mob-abil-purge-rune+))
                                                          t
                                                          nil)))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((rune nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (loop for feature-id in (get-features-* (level *world*) dx dy (z actor))
                                                                                                          for feature = (get-feature-by-id feature-id)
                                                                                                          when (get-feature-type-trait feature +feature-trait-demonic-rune+)
                                                                                                            do
                                                                                                               (setf rune feature)
                                                                                                               (loop-finish))))
                                                    (if (and (mob-ability-p actor +mob-abil-purge-rune+)
                                                             (can-invoke-ability actor actor +mob-abil-purge-rune+)
                                                             (not nearest-enemy)
                                                             rune
                                                             )
                                                      rune
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((features (remove-if #'(lambda (a)
                                                                                     (if (get-feature-type-trait (get-feature-by-id a) +feature-trait-demonic-rune+)
                                                                                       nil
                                                                                       t))
                                                                                 (get-features-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                            (exit-result nil))

                                                        (cond
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (= (view-z *player*) (z *player*))
                                                                (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                (> (length features) 1))
                                                           (progn
                                                             (let ((feature-line-list nil)
                                                                   (feature-prompt-list)
                                                                   (feature-list (copy-list features)))

                                                               (setf feature-line-list (loop for feature-id in feature-list
                                                                                             for feature = (get-feature-by-id feature-id)
                                                                                             collect (format nil "~A"
                                                                                                             (capitalize-name (name feature)))))
                                                               ;; populate the ability prompt list
                                                               (setf feature-prompt-list (loop for feature-id in feature-list
                                                                                               collect #'(lambda (cur-sel)
                                                                                                           (declare (ignore cur-sel))
                                                                                                           "[Enter] Purge  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a demonic rune to purge:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
                                                                                                                     (mob-invoke-ability *player* (get-feature-by-id (nth cur-sel feature-list)) ability-type-id)
                                                                                                                     (setf *current-window* (return-to (return-to (return-to *current-window*))))
                                                                                                                     (make-output *current-window*)
                                                                                                                     (setf exit-result t))
                                                                                                     :line-list feature-line-list
                                                                                                     :prompt-list feature-prompt-list))
                                                               (make-output *current-window*)
                                                               (run-window *current-window*))
                                                             exit-result)
                                                           )
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (= (view-z *player*) (z *player*))
                                                                (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                (= (length features) 1))
                                                           (progn
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* (get-feature-by-id (first features)) ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil)))
                                                        
                                                        )
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-blessing-touch+ :name "Blessing touch" :descr "You are able to bless humans when you touch them." 
                                 :passive t :cost 0 :spd +normal-ap+
                                 :final t :on-touch t
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (log:info (format nil "MOB-BLESS-TARGET: ~A [~A] blesses ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (set-mob-effect target :effect-type-id +mob-effect-blessed+ :actor-id (id actor))
                                                (incf (cur-fp actor))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A blesses ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-blessing-touch+)
                                                               (mob-ability-p target +mob-abil-can-be-blessed+)
                                                               (get-faction-relation (faction actor) (faction target))
                                                               (not (mob-effect-p target +mob-effect-blessed+)))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-can-be-blessed+ :name "Can be blessed" :descr "You are able to receive blessings from divine beings." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-civilian+ :name "Civilian" :descr "You are a civilian, mainly the suffering side of any conflict." 
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

                                                (log:info (format nil "MOB-CONSUME-BLESSING-ON-TARGET: ~A [~A] is scorched by blessing of ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (rem-mob-effect target +mob-effect-blessed+)
                                                
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

                                                (log:info (format nil "MOB-LIFESTEAL: ~A [~A] steals life from the dead ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
  
                                                (let ((heal-pwr))
                                                  (setf heal-pwr (* 2 (1+ (strength target))))
                                                  (when (> (+ (cur-hp actor) heal-pwr)
                                                           (max-hp actor))
                                                    (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                  (incf (cur-hp actor) heal-pwr)
                                                       
                                                  (unless (zerop heal-pwr)
                                                    (when (check-mob-visible actor :observer *player* :complete-check t)
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A heals for ~A with the lifeforce of ~A. "
                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor))) heal-pwr
                                                                                     (prepend-article +article-the+ (visible-name target)))
                                                                             :color sdl:*white*
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                           :singlemind)))))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type actor target))
                                                      t)))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-call-for-help+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 1 :spd (truncate +normal-ap+ 3) :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 30
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (log:info (format nil "MOB-CALL-FOR-HELP: ~A [~A] calls for help~%" (name actor) (id actor)))
                                                
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
                                                  (log:info (format nil "MOB-CALL-FOR-HELP: The following allies might answer the call ~A~%" allies-list))
                                                  
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
                                                                           (format nil "~A calls for reinforcements. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-calling-for-help+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                   ;; call for reinforcements if there is a threatening enemy in sight and hp < 50% and you are not the last one
                                                  (if (and nearest-enemy
                                                           (not (zerop (strength nearest-enemy)))
                                                           (< (/ (cur-hp actor) (max-hp actor)) 
                                                              0.5)
                                                           (mob-ability-p actor +mob-abil-call-for-help+)
                                                           (can-invoke-ability actor actor +mob-abil-call-for-help+)
                                                           (> (total-demons (level *world*)) 1))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-answer-the-call+ :name "Answer the call" :descr "Invoke hellish powers to answer the summoning of your allies. If somebody has already answered the call, nothing will happen. If the teleport is successful, the ability will cost 5 time units." 
                                 :cost 0 :spd 0 :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (log:info (format nil "MOB-ANSWER-THE-CALL: ~A [~A] answers the call~%" (name actor) (id actor)))
                                                
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
                                                        (log:info (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the caller ~A [~A]~%" (name actor) (id actor) (name called-ally) (id called-ally)))
                                                        (check-surroundings (x called-ally) (y called-ally) nil #'(lambda (x y)
                                                                                                                    (when (and (not (get-mob-* (level *world*) x y (z called-ally)))
                                                                                                                               (not (get-terrain-type-trait (get-terrain-* (level *world*) x y (z called-ally))
                                                                                                                                                            +terrain-trait-blocks-move+)))
                                                                                                                      (setf fx x fy y fz (z called-ally)))))
                                                        (if (and fx fy fz)
                                                          ;; free place found
                                                          (progn
                                                            (log:info (format nil "MOB-ANSWER-THE-CALL: ~A [~A] finds the place to teleport (~A, ~A)~%" (name actor) (id actor) fx fy))
                                                            (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A. " str)))
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A disappeares in thin air. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            ;; teleport the caster to the caller
                                                            (set-mob-location actor fx fy fz)

                                                            (if (get-faction-relation (faction called-ally) (faction *player*))
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A answers the call of ~A. "
                                                                                             (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                             (prepend-article +article-the+ (visible-name called-ally)))
                                                                                     :color sdl:*white*
                                                                                     :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                   :singlemind)))
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A appears out of thin air. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                     :color sdl:*white*
                                                                                     :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                   :singlemind))))
                                                            ;; remove the calling for help status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            (make-act actor (truncate +normal-ap+ 2))
                                                            
                                                            (incf (stat-answers actor))
                                                            (incf (stat-calls called-ally))
                                                            )
                                                          (progn
                                                            (log:info (format nil "MOB-ANSWER-THE-CALL: ~A [~A] unable to the place to teleport~%" (name actor) (id actor)))
                                                            (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A. " str)))
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                   (format nil "~A blinks for a second, but remains in place. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            ;; no free place found - just remove the status from the called and the caller
                                                            (rem-mob-effect called-ally +mob-effect-calling-for-help+)
                                                            (rem-mob-effect actor +mob-effect-called-for-help+)
                                                            ))
                                                        ))
                                                    (progn
                                                      ;; if none found, simply remove the "answer the call" status
                                                      (log:info (format nil "MOB-ANSWER-THE-CALL: ~A [~A] is unable to find the caller ~%" (name actor) (id actor)))
                                                      (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear crackling~A. " str)))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A blinks for a second, but remains in place. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                             :color sdl:*white*
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                           :singlemind)))
                                                      (rem-mob-effect actor +mob-effect-called-for-help+)
                                                      ))
                                                    ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-effect-p actor +mob-effect-called-for-help+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-loves-infighting+ :name "Loves infighting" :descr "You do not mind attacking your own kin." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-bless+ :name "Pray for righteousness" :descr "Pray to reveal unholy creatures (1/3rd chance only) and burn them for 1-2 dmg, as well as to grant divine protection (1/3rd chance only) to all humans & angels. Affected humans in the area will also start to follow you. Divine protection prevents one harmful action from affecting the shielded target." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (log:info (format nil "MOB-PRAYER-RIGHTEOUSNESS: ~A [~A] prays for righteousness~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for righteousness. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))

                                                (let ((enemy-list nil)
                                                      (ally-list nil))
                                                  (when (zerop (random 3))
                                                    ;; 1/3th chance to do anything
                                                                                                        
                                                    ;; collect all unholy enemies in sight
                                                    (setf enemy-list (loop for enemy-mob-id in (visible-mobs actor)
                                                                           when (and (not (get-faction-relation (faction actor) (faction (get-mob-by-id enemy-mob-id))))
                                                                                     (mob-ability-p (get-mob-by-id enemy-mob-id) +mob-abil-unholy+))
                                                                             collect enemy-mob-id))
                                                    
                                                    (log:info (format nil "MOB-PRAYER-RIGHTEOUSNESS: ~A [~A] affects the following enemies ~A with the prayer~%" (name actor) (id actor) enemy-list))
                                                    
                                                    ;; reveal all enemies and burn them like they are blessed
                                                    (loop for enemy-mob-id in enemy-list
                                                          do
                                                             (log:info (format nil "MOB-PRAYER-RIGHTEOUSNESS: ~A [~A] affects the enemy ~A~%" (name actor) (id actor) (get-mob-by-id enemy-mob-id)))
                                                             (when (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-possessed+)
                                                               (unless (mob-effect-p (get-mob-by-id enemy-mob-id) +mob-effect-reveal-true-form+)
                                                                 (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                        (format nil "~A reveals the true form of ~A. "
                                                                                                (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                (prepend-article +article-the+ (get-qualified-name (get-mob-by-id enemy-mob-id))))
                                                                                        :color sdl:*white*
                                                                                        :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                      :singlemind))))
                                                               (set-mob-effect (get-mob-by-id enemy-mob-id) :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))
                                                             (incf (brightness actor) 50)
                                                             (mob-burn-blessing actor (get-mob-by-id enemy-mob-id)))
                                                    )
                                                  (when (zerop (random 3))
                                                    ;; 1/3th chance to do anything
                                                    
                                                    ;; collect all allies in sight
                                                    (setf ally-list (loop for ally-mob-id in (visible-mobs actor)
                                                                          when (or (mob-ability-p (get-mob-by-id ally-mob-id) +mob-abil-human+)
                                                                                   (mob-ability-p (get-mob-by-id ally-mob-id) +mob-abil-angel+))
                                                                            collect ally-mob-id))
                                                    ;; do not forget self
                                                    (pushnew (id actor) ally-list)
                                                    
                                                    (log:info (format nil "MOB-PRAYER-RIGHTEOUSNESS: ~A [~A] affects the following allies ~A with the prayer~%" (name actor) (id actor) ally-list))
                                                    
                                                    ;; grant all allies invulnerability for 99 turns
                                                    (loop for ally-mob-id in ally-list
                                                          for mob = (get-mob-by-id ally-mob-id)
                                                          do
                                                             (log:info (format nil "MOB-PRAYER-RIGHTEOUSNESS: ~A [~A] affects the ally ~A~%" (name actor) (id actor) mob))
                                                             (set-mob-effect mob :effect-type-id +mob-effect-divine-shield+ :actor-id (id actor) :cd 99)
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A is granted divine shield" (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind)))
                                                             (when (and (not (eq mob actor))
                                                                        (mob-ability-p mob +mob-abil-human+)
                                                                        (not (mob-ability-p mob +mob-abil-independent+))
                                                                        (or (not (order mob))
                                                                            (and (order mob)
                                                                                 (= (first (order mob)) +mob-order-follow+)
                                                                                 (/= (second (order mob)) (id actor))
                                                                                 (zerop (random 2)))
                                                                            (and (order mob)
                                                                                 (/= (first (order mob)) +mob-order-follow+))))
                                                               (setf (order mob) (list +mob-order-follow+ (id actor)))
                                                               (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                      (format nil " and starts to follow ~A" (visible-name actor))
                                                                                      :color sdl:*white*
                                                                                      :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                    :singlemind))))
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil ". ")
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind)))
                                                          )
                                                    
                                                    ))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-prayer-bless+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-bless+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-bless+)
                                                           (or (not (mob-effect-p actor +mob-effect-divine-shield+))
                                                               (and (not (zerop (length (visible-mobs actor))))
                                                                    (zerop (random 4)))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-free-call+ :name "Summon ally" :descr "Invoke hellish powers to summon one ally to your place. Remember that you may call but nobody is obliged to answer." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil :cd 3
                                 :motion 30
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (log:info (format nil "MOB-FREE-CALL-FOR-HELP: ~A [~A] calls for help~%" (name actor) (id actor)))
                                                
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
                                                  (log:info (format nil "MOB-FREE-CALL-FOR-HELP: The following allies might answer the call ~A~%" allies-list))
                                                  
                                                  ;; place the effect of "called for help" on the allies in the final list 
                                                  (loop for ally-mob-id in allies-list 
                                                        do
                                                           (set-mob-effect (get-mob-by-id ally-mob-id) :effect-type-id +mob-effect-called-for-help+ :actor-id (id actor) :cd 2))
                                                  
                                                  (set-mob-effect actor :effect-type-id +mob-effect-calling-for-help+ :actor-id (id actor) :cd 2)
                                                  (decf (cur-fp actor) (cost ability-type))
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone reciting incantations~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A calls for reinforcements. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-calling-for-help+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; for satanists: call for reinforcements whenever there is a threatening enemy in sight and there still demons out there
                                                  (if (and nearest-enemy
                                                           (not (zerop (strength nearest-enemy)))
                                                           (mob-ability-p actor +mob-abil-free-call+)
                                                           (can-invoke-ability actor actor +mob-abil-free-call+)
                                                           (> (total-demons (level *world*)) 0))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))
(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-shield+ :name "Pray for protection" :descr "Pray to grant divine protection (1/3rd chance only) to all allies in the area. Divine protection prevents one harmful action from affecting the shielded target." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (log:info (format nil "MOB-PRAYER-SHIELD: ~A [~A] prays for shielding~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for protection. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))

                                                (let ((ally-list nil))
                                                  (when (zerop (random 3))
                                                    ;; 1/3th chance to do anything
                                                    
                                                    ;; collect all allies in sight
                                                    (setf ally-list (loop for ally-mob-id in (visible-mobs actor)
                                                                          when (get-faction-relation (faction actor) (faction (get-mob-by-id ally-mob-id)))
                                                                            collect ally-mob-id))
                                                    ;; do not forget self
                                                    (pushnew (id actor) ally-list)
                                                    
                                                    (log:info (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the following allies ~A with the prayer~%" (name actor) (id actor) ally-list))
                                                    
                                                    ;; grant all allies invulnerability for 99 turns
                                                    (loop for ally-mob-id in ally-list
                                                          do
                                                             (log:info (format nil "MOB-PRAYER-SHIELD: ~A [~A] affects the ally ~A~%" (name actor) (id actor) (get-mob-by-id ally-mob-id)))
                                                             (set-mob-effect (get-mob-by-id ally-mob-id) :effect-type-id +mob-effect-divine-shield+ :actor-id (id actor) :cd 99)
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A is granted divine shield. " (capitalize-name (prepend-article +article-the+ (visible-name (get-mob-by-id ally-mob-id)))))
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind)))
                                                          )
                                                    
                                                    ))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-prayer-shield+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-shield+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-shield+)
                                                           (zerop (random 4)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-curse+ :name "Curse" :descr "Curse all visible enemies with diabolical incantations. The cursed individuals will have a 25% chance to miss. You only have 1/2 chance to successfully invoke the curse." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (log:info (format nil "MOB-CURSE: ~A [~A] incants the curses~%" (name actor) (id actor)))
                                                
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone laughing and cursing~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A laughs and curses maniacally. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                (invoke-curse actor)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-curse+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                
                                                (log:info (format nil "MOB-PRAYER-REVEAL: ~A [~A] prays for revealing supernatural beings~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for revelation. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))

                                                ;; reveal true form of all mobs in line of sight, 1/3rd chance
                                                (when (zerop (random 2))
                                                  (loop for mob-id in (visible-mobs actor)
                                                        for target = (get-mob-by-id mob-id)
                                                        do
                                                           (when (mob-effect-p target +mob-effect-divine-concealed+)
                                                             (rem-mob-effect target +mob-effect-divine-concealed+)
                                                             (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                             (print-visible-message (x target) (y target) (z actor) (level *world*) 
                                                                                    (format nil "~A reveals the true form of ~A. "
                                                                                            (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                            (prepend-article +article-the+ (get-qualified-name target)))
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind))))
                                                           (when (mob-effect-p target +mob-effect-possessed+)
                                                             (unless (mob-effect-p target +mob-effect-reveal-true-form+)
                                                               (print-visible-message (x target) (y target) (z actor) (level *world*) 
                                                                                      (format nil "~A reveals the true form of ~A. "
                                                                                              (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                              (prepend-article +article-the+ (get-qualified-name target)))
                                                                                      :color sdl:*white*
                                                                                      :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                    :singlemind))))
                                                             (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5))))                                                      
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-prayer-reveal+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-reveal+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-reveal+)
                                                           (not (zerop (length (visible-mobs actor))))
                                                           (zerop (random 4)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                                       (format nil "~A orders nearby allies to follow him. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                
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
                                                                                  (format nil "~A obeys. " (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                  :color sdl:*white*
                                                                                  :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                :singlemind)))
                                                           (incf follower-num)
                                                           (when (>= follower-num 5) (loop-finish)))

                                                (log:info (format nil "MOB-ORDER-FOLLOW-ME: ~A [~A] orders to follow him. Followers ~A~%" (name actor) (id actor) (get-followers-list actor)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-military-follow-me+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                                                                       (not (mob-ability-p mob +mob-abil-independent+)))
                                                                               count mob-id)))
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-blindness+ :name "Blindness" :descr "A flash of light that blinds nearby enemies for 2 turns." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A channels the heavenly light. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                (log:info (format nil "MOB-BLIND: ~A [~A] casts blindness.~%" (name actor) (id actor)))
                                                ;; blind nearby non-angel mobs
                                                (loop for i from 0 below (length (proper-visible-mobs actor))
                                                      for mob = (get-mob-by-id (nth i (proper-visible-mobs actor)))
                                                      when (not (mob-ability-p mob +mob-abil-angel+))
                                                        do
                                                           (set-mob-effect mob :effect-type-id +mob-effect-blind+ :actor-id (id actor) :cd 2)
                                                           (if (eq *player* mob)
                                                             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                             (setf (visible-mobs mob) nil))
                                                           (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                  (format nil "~A is blind. " (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                  :color sdl:*white*
                                                                                  :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                :singlemind)))
                                                           )

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-blindness+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; cast blindness when your power is less than the power of enemies around you
                                                  ;; or you have <= than 25% of max hp
                                                  (if (and (mob-ability-p actor +mob-abil-blindness+)
                                                           (can-invoke-ability actor actor +mob-abil-blindness+)
                                                           (not (zerop (loop for mob-id in (visible-mobs actor)
                                                                             for mob = (get-mob-by-id mob-id)
                                                                             when (not (mob-effect-p mob +mob-effect-blind+))
                                                                               count mob-id)))
                                                           (or (and (<= (cur-hp actor) (truncate (max-hp actor) 4))
                                                                    nearest-enemy
                                                                    )
                                                               (< (strength actor) (loop for mob-id in (visible-mobs actor)
                                                                                         for mob = (get-mob-by-id mob-id)
                                                                                         when (not (get-faction-relation (faction actor) (get-visible-faction mob)))
                                                                                           sum (strength mob)))))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                                       (format nil "~A roars to fear its enemies. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :observed-mob actor
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                (invoke-fear actor (mob-ability-value actor +mob-abil-instill-fear+))
                                                          
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-instill-fear+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-charge+ :name "Charge" :descr "Move up to 3 tiles to the specified place. Anybody on your way will be pushed back (if possible) and attacked." 
                                 :cd 4 :cost 0 :spd (truncate (* +normal-ap+ 1.5)) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; here the target is not a mob, but a (cons x y)
                                                (log:info (format nil "MOB-CHARGE: ~A [~A] charges to ~A.~%" (name actor) (id actor) target))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A charges. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                
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
                                                  
                                                  (setf game-time (world-game-time *world*))
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
                                                           (when (or (eq charge-result nil)
                                                                     (and (typep charge-result 'list)
                                                                          (eq (first charge-result) :obstacles)))
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A hits an obstacle. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind))))
                                                           (unless (eq charge-result t)
                                                             (loop-finish))
                                                        )
                                                  (setf (cur-ap actor) cur-ap)
                                                  (setf (world-game-time *world*) game-time)
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-charge+)
                                                               (not (mob-ability-p actor +mob-abil-immobile+))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor (cons (x nearest-enemy) (y nearest-enemy)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                        (progn
                                                          nil)
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-nearest-ally-next
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-HORSEBACK-RIDING: ~A [~A] mounts ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (setf (mounted-by-mob-id target) (id actor))
                                                (setf (riding-mob-id actor) (id target))
                                                (set-mob-location actor (x target) (y target) (z target))

                                                (when (or (check-mob-visible actor :observer *player*)
                                                          (check-mob-visible target :observer *player*))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A mounts ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind))))
                                                (adjust-dodge actor)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((mount nil))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                        (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                          (when (and mob
                                                                                                                     (get-faction-relation (faction actor) (faction mob))
                                                                                                                     (mob-ability-p mob +mob-abil-horse-can-be-ridden+)
                                                                                                                     (not (mounted-by-mob-id mob)))
                                                                                                            (setf mount mob)))))
                                                        (if (and mount
                                                                 (mob-ability-p actor +mob-abil-horseback-riding+)
                                                                 (not (riding-mob-id actor)))
                                                          t
                                                          nil)))
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
                                                      mount
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (not (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                               (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                               (get-faction-relation (faction *player*) (faction (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (mob-ability-p (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +mob-abil-horse-can-be-ridden+)
                                                               (not (mounted-by-mob-id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (find (id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))) (visible-mobs *player*)))
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; here the target is not a mob, but a (cons x y)

                                                (let ((mount (get-mob-by-id (riding-mob-id actor))))
                                                  (log:info (format nil "MOB-DISMOUNT: ~A [~A] dismounts ~A [~A].~%" (name actor) (id actor) (name mount) (id mount)))
                                                  
                                                  (setf (mounted-by-mob-id mount) nil)
                                                  (setf (riding-mob-id actor) nil)

                                                  
                                                  (set-mob-location actor (car target) (cdr target) (z actor))
                                                  
                                                  (set-mob-location mount (x mount) (y mount) (z mount))
                                                  
                                                  (when (or (check-mob-visible actor :observer *player*)
                                                            (check-mob-visible mount :observer *player*)) 
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A dismounts ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name mount)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy check-result))
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
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (cons (view-x *player*) (view-y *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-dominate-fiend+ :name "Dominate fiend" :descr "You can mount a fiend, if you stand next to it. Riding a fiend will reveal your true form." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-nearest-hostile-next
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-DOMINATE-FIEND: ~A [~A] mounts ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))

                                                (when (or (check-mob-visible actor :observer *player*)
                                                          (check-mob-visible target :observer *player*))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A mounts ~A" (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))
                                                  ;; reveal the true form of those who ride fiends
                                                  (when (and (slave-mob-id actor)
                                                             (not (mob-effect-p actor +mob-effect-reveal-true-form+)))
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil " and reveals itself as ~A" (prepend-article +article-the+ (get-qualified-name actor)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil ". ")
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind))))
                                                
                                                (setf (mounted-by-mob-id target) (id actor))
                                                (setf (riding-mob-id actor) (id target))

                                                (set-mob-location actor (x target) (y target) (z target))

                                                (adjust-dodge actor)
                                                
                                                (set-mob-effect actor :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 4)
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((mount nil))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                        (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                          (when (and mob
                                                                                                                     (mob-ability-p mob +mob-abil-fiend-can-be-ridden+)
                                                                                                                     (not (mounted-by-mob-id mob)))
                                                                                                            (setf mount mob)))))
                                                        (if (and mount
                                                                 (mob-ability-p actor +mob-abil-dominate-fiend+)
                                                                 (not (riding-mob-id actor)))
                                                          t
                                                          nil)))
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
                                                      mount
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (not (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                               (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                               (mob-ability-p (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +mob-abil-fiend-can-be-ridden+)
                                                               (not (mounted-by-mob-id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                               (find (id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))) (visible-mobs *player*)))
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-nearest-ally
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-EAGLE-EYE: ~A [~A] uses eagle eye to reveal ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (if (or (mob-effect-p target +mob-effect-divine-concealed+)
                                                          (and (mob-effect-p target +mob-effect-possessed+)
                                                               (not (mob-effect-p target +mob-effect-reveal-true-form+))))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A reveals the true form of ~A. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))
                                                    
                                                    (rem-mob-effect target +mob-effect-divine-concealed+)
                                                    (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "It is ~A. " (prepend-article +article-the+ (get-qualified-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A tries to reveal the true form of ~A. But ~A does not conceal anything. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
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
                                                           (or (mob-effect-p nearest-ally +mob-effect-divine-concealed+)
                                                               (and (mob-effect-p nearest-ally +mob-effect-possessed+)
                                                                    (not (mob-effect-p nearest-ally +mob-effect-reveal-true-form+))))
                                                           (zerop (random 4)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy check-result))
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
                                                                           (not (mob-effect-p mob +mob-effect-divine-concealed+))))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-MIND-BURN: ~A [~A] uses mind burn on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A invokes mind burn on ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                  
                                                (inflict-damage target :min-dmg 2 :max-dmg 4 :dmg-type +weapon-dmg-mind+
                                                                       :att-spd nil :weapon-aux () :acc 100 :add-blood nil :no-dodge t
                                                                       :actor actor :no-hit-message t
                                                                       :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                     (format nil "~A has its mind burned for ~A dmg. " (capitalize-name (prepend-article +article-the+ (name target))) cur-dmg)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                                
                                                (invoke-teleport-self actor 80 (z actor))
                                                )
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-dominate-gargantaur+ :name "Dominate Gargantaur" :descr "You can mount a Gargantaur, if you stand next to it, but at a cost of inflicting yourself the amount of damage equal to the half of your maximum HP. Riding one will reveal your true form." 
                                 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-nearest-hostile-next
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-DOMINATE-GARGANTAUR: ~A [~A] mounts ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (let ((cur-dmg (truncate (max-hp actor) 2)))
                                                  (decf (cur-hp actor) cur-dmg)

                                                  (if (<= (cur-hp actor) 0)
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A cringes with pain, taking ~A dmg, while trying to mount ~A. "
                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor))) cur-dmg (prepend-article +article-the+ (visible-name target)))
                                                                             :color (if (eq *player* actor)
                                                                                        (sdl:color :r 255 :g 140 :b 0)
                                                                                        sdl:*yellow*)
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                           :singlemind)))
                                                      (when (eq actor *player*)
                                                        (setf (killed-by *player*) "trying to dominate the gargantaur"))
                                                      (make-dead actor :splatter t :msg t :msg-newline nil :killer nil :corpse t :aux-params ()))
                                                    (progn
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil "~A cringes with pain, taking ~A dmg, and mounts ~A"
                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor))) cur-dmg (prepend-article +article-the+ (visible-name target)))
                                                                             :color (if (eq *player* actor)
                                                                                        (sdl:color :r 255 :g 140 :b 0)
                                                                                        sdl:*yellow*)
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                           :singlemind)))

                                                      ;; reveal the true form of those who ride fiends
                                                      (when (mob-effect-p actor +mob-effect-divine-concealed+)
                                                        (rem-mob-effect actor +mob-effect-divine-concealed+)
                                                        (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                               (format nil " to reveal itself as ~A" (prepend-article +article-the+ (get-qualified-name actor)))
                                                                               :color (if (eq *player* actor)
                                                                                        (sdl:color :r 255 :g 140 :b 0)
                                                                                        sdl:*yellow*)
                                                                               :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                             :singlemind))))
                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                             (format nil ". ")
                                                                             :color (if (eq *player* actor)
                                                                                        (sdl:color :r 255 :g 140 :b 0)
                                                                                        sdl:*yellow*)
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                           :singlemind)))
                                                      ;; show message for LOW HP
                                                      (when (and (eq *player* actor)
                                                                 (< (/ (cur-hp actor) (max-hp actor)) 
                                                                    0.3))
                                                        (add-message "LOW HP!!! " sdl:*red*))
                                                      
                                                      (setf (mounted-by-mob-id target) (id actor))
                                                      (setf (riding-mob-id actor) (id target))
                                                      (set-mob-location actor (x target) (y target) (z target))
                                                                                                            
                                                      (adjust-dodge actor)
                                                      
                                                      (set-mob-effect actor :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 4)
                                                      
                                                      ))
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((mount nil))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                        (let ((mob (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                          (when (and mob
                                                                                                                     (= (mob-type mob) +mob-type-gargantaur+)
                                                                                                                     (null (mounted-by-mob-id mob)))
                                                                                                            (setf mount mob)))))
                                                        (if (and mount
                                                                 (mob-ability-p actor +mob-abil-dominate-gargantaur+)
                                                                 (not (riding-mob-id actor)))
                                                          t
                                                          nil)))
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
                                                      mount
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
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
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-GARGANTAURS-MIND-BURN: ~A [~A] uses mind burn on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A uses its Gargantaur to burn the mind of ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                  
                                                (inflict-damage target :min-dmg 2 :max-dmg 4 :dmg-type +weapon-dmg-mind+
                                                                       :att-spd nil :weapon-aux () :acc 100 :add-blood nil :no-dodge t
                                                                       :actor actor :no-hit-message t
                                                                       :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                     (format nil "~A has its mind burned for ~A dmg. " (capitalize-name (prepend-article +article-the+ (name target))) cur-dmg)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-death-from-above
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-DEATH-FROM-ABOVE: ~A [~A] uses death from above on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A strikes from above. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                                                                
                                                (let ((tx (x target)) (ty (y target)) (tz (1+ (z target))))
                                                  (block surround
                                                    (check-surroundings (x target) (y target) nil
                                                                        #'(lambda (dx dy)
                                                                            (when (eq (check-move-on-level actor dx dy (z target)) t)
                                                                              (setf tx dx ty dy tz (z target))
                                                                              (when (zerop (random 4))
                                                                                (return-from surround))))))
                                                  (set-mob-location actor tx ty tz))

                                                 ;; set motion
                                                (incf-mob-motion target *mob-motion-melee*)
                                                
                                                ;; generate sound
                                                (generate-sound target (x target) (y target) (z target) *mob-sound-melee* #'(lambda (str)
                                                                                                                              (format nil "You hear sounds of fighting~A. " str)))

                                                (inflict-damage target :min-dmg 5 :max-dmg 8 :dmg-type +weapon-dmg-iron+
                                                                       :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t
                                                                       :actor actor)
  
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*))
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
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-climbing+ :name "Climbing" :descr "Toggle the climbing mode. While in the climbing mode you are able to scale walls up and down and will not fall as long as you remain next to a solid wall or a floor. You can toggle the climbing mode at any time. However, you are unable to climb while sprinting." 
                                 :cost 0 :spd 0 :passive nil
                                 :final t :on-touch nil
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (if (mob-effect-p actor +mob-effect-climbing-mode+)
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle off the climbing mode. "))
                                                    (rem-mob-effect actor +mob-effect-climbing-mode+))
                                                  (progn
                                                    (when (eq actor *player*)
                                                      (add-message "You toggle on the climbing mode. "))
                                                    (set-mob-effect actor :effect-type-id +mob-effect-climbing-mode+ :actor-id (id actor) :cd t))))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-climbing+)
                                                               (not (mob-effect-p actor +mob-effect-sprint+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-climbing+)
                                                           (can-invoke-ability actor actor +mob-abil-climbing+)
                                                           (not (mob-effect-p actor +mob-effect-climbing-mode+)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-no-breathe+ :name "Does not breathe" :descr "Your do not require oxygen to sustain your life." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-open-close-door+ :name "Open/close door" :descr "Open or close door (depending on the current status of the door in question). You can also open a closed door by walking into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :start-map-select-func #'player-start-map-select-door
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (= (get-terrain-* (level *world*) x y z) +terrain-door-open+)
                                                    (print-visible-message x y z (level *world*) (format nil "~A opens the door. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    (print-visible-message x y z (level *world*) (format nil "~A closes the door. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-light
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (or (null (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+))
                                                          (eq 0 (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+)))
                                                    (print-visible-message x y z (level *world*) (format nil "~A switches off the light. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    (print-visible-message x y z (level *world*) (format nil "~A switches on the light. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-toggle-light+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if you can toggle lights and you happen to be nearby, and you do not radiate light yourself - switch it off
                                                  ;; if you can toggle lights and you happen to be nearby, and you do radiate light yourself - switch it on
                                                  (let ((light-source nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-can-switch-light+)
                                                                                                                 (or (and (<= (cur-light actor) 0)
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (not (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+))))
                                                                                                                     (and (> (cur-light actor) 0)
                                                                                                                          (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                                                                          (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+)))))
                                                                                                        (setf light-source (list dx dy (z actor)))))))
                                                    (if (and (mob-ability-p actor +mob-abil-toggle-light+)
                                                             (can-invoke-ability actor actor +mob-abil-toggle-light+)
                                                             light-source
                                                             (or (not nearest-enemy)
                                                                 (and nearest-enemy
                                                                      (>= (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy))
                                                                          4))))
                                                      light-source
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type))
                                                   )
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                 (get-terrain-type-trait terrain +terrain-trait-can-switch-light+))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-open-close-window+ :name "Open/close window" :descr "Open or close window (depending on the current status of the door in question). You can also open a closed window by walking into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :start-map-select-func #'player-start-map-select-window
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (when (get-terrain-on-use (get-terrain-* (level *world*) x y z))
                                                    (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z))
                                                  (if (= (get-terrain-* (level *world*) x y z) +terrain-wall-window-opened+)
                                                    (print-visible-message x y z (level *world*) (format nil "~A opens the window. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                    (print-visible-message x y z (level *world*) (format nil "~A closes the window. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :observed-mob actor
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
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
                                                  (setf (x target) (x actor) (y target) (y actor) (z target) (z actor))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A destroys its host. "
                                                                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                  (setf (cur-hp target) 0)
                                                  (make-dead target :splatter t :msg nil :killer actor :corpse nil :aux-params ())
                                                  
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor (get-mob-by-id (slave-mob-id actor)) (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-reanimate-corpse+ :name "Reanimate body" :descr "Invite an outworldly demon to enter a dead body (or a severed body part) and reanimate it. The strength of the reanimated corpse depends on its completeness - missing parts will reduce it." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :cd 4 :motion 60
                                 :start-map-select-func #'player-start-map-select-corpse
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-REANIMATE-BODY: ~A [~A] reanimates ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))
                                                ;; target here is the item to be reanimated
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A raises his hands and intones an incantation. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :observed-mob actor
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear somebody chanting~A. " str)))
                                                (invoke-reanimate-body target)
                                                (incf (stat-raised-dead actor))
                                                (when (eq actor *player*)
                                                  (incf (cur-score *player*) 10))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-reanimate-corpse+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
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
                                                    (if (and (mob-ability-p actor +mob-abil-reanimate-corpse+)
                                                             (can-invoke-ability actor actor +mob-abil-reanimate-corpse+)
                                                             item-id)
                                                      item-id
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor (get-item-by-id check-result) (id ability-type)))
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
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
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
                                                             (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-empower-undead
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A raises his hands and intones an incantation. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :observed-mob actor
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
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
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-empower-undead+)
                                                           (can-invoke-ability actor actor +mob-abil-empower-undead+)
                                                           (not (mob-effect-p actor +mob-effect-necrolink+))
                                                           nearest-ally
                                                           (mob-ability-p nearest-ally +mob-abil-undead+)
                                                           (not (mob-ability-p nearest-ally +mob-abil-ghost-possess+))
                                                           (not (mob-effect-p nearest-ally +mob-effect-empowered-undead+)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy check-result))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 target
                                                                 (get-faction-relation (faction *player*) (faction target))
                                                                 (mob-ability-p target +mob-abil-undead+)
                                                                 (not (mob-effect-p target +mob-effect-empowered-undead+))
                                                                 (find (id target) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
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
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile to be ignited
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (print-visible-message x y z (level *world*) (format nil "~A sets the ~A on fire. "
                                                                                                       (capitalize-name (prepend-article +article-the+ (visible-name actor))) (get-terrain-name (get-terrain-* (level *world*) x y z)))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))
                                                  (ignite-tile (level *world*) x y z (x actor) (y actor) (z actor))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-ignite-the-fire+)
                                                               (get-melee-weapon-aux-param actor :is-fire)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+)))
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
                                                      flammable-tile
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (get-terrain-type-trait terrain +terrain-trait-flammable+))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-avatar-of-brilliance+ :name "Avatar of Brilliance" :descr "Transform yourself into an Avatar of Brilliance for 6 turns, significantly boosting your combat prowess." 
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
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-avatar-of-brilliance+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-gravity-chains+ :name "Gravity chains" :descr "Make your chains grab a target and inflict 2-4 vorpal dmg. If the target is flying or climbing, it is forced to the ground and will not be able to use respective abilities for 3 turns. Divine protection will nullify the damage but not the secondary effects."
                                 :cd 4 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-GRAVITY-CHAINS: ~A [~A] uses gravity chains on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A invokes gravity chains on ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))

                                                (generate-sound actor (x target) (y target) (z target) 80 #'(lambda (str)
                                                                                                              (format nil "You hear metal clanking~A. " str)))

                                                (set-mob-effect target :effect-type-id +mob-effect-gravity-pull+ :actor-id (id actor) :cd 3)
                                                (inflict-damage target :min-dmg 2 :max-dmg 4 :dmg-type +weapon-dmg-vorpal+
                                                                       :att-spd nil :weapon-aux () :acc 100 :add-blood nil :no-dodge t
                                                                       :actor actor
                                                                       :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                     (format nil "~A takes ~A dmg. " (capitalize-name (prepend-article +article-the+ (name target))) cur-dmg)))
                                                
                                                (rem-mob-effect target +mob-effect-climbing-mode+)
                                                (rem-mob-effect target +mob-effect-flying+)
                                                
                                                (when (apply-gravity target)
                                                  (set-mob-location target (x target) (y target) (z target)))

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-gravity-chains+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
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
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 target
                                                                 (not (eq *player* target))
                                                                 (find (id target) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
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

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-smite+ :name "Smite" :descr "Pray to cast down celestial retribution onto an unholy enemy inflicting 1-2 dmg for each visible human character around." 
                                 :cd 5 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-hostile-unholy 
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-SMITE: ~A [~A] uses smite on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone praying~A." str)))
                                                (if (mob-ability-p target +mob-abil-unholy+)
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A smites ~A" (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                    (when (mob-effect-p target +mob-effect-possessed+)
                                                      (unless (mob-effect-p target +mob-effect-reveal-true-form+)
                                                        (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                               (format nil " and reveals it to be ~A" (prepend-article +article-the+ (get-qualified-name target)))
                                                                               :color sdl:*white*
                                                                               :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                             :singlemind))))
                                                      (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                      )
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil ". ")
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    (loop for mob-id in (append (list (id actor)) (visible-mobs actor))
                                                          for mob = (get-mob-by-id mob-id)
                                                          with cur-dmg = 0
                                                          when (and (not (check-dead mob))
                                                                    (mob-ability-p mob +mob-abil-human+))
                                                            do
                                                               (incf cur-dmg (1+ (random 2)))
                                                          finally (when (not (zerop cur-dmg))
                                                                    (let ((dir (1+ (random 9))))
                                                                      (multiple-value-bind (dx dy) (x-y-dir dir) 				
                                                                        (when (> 50 (random 100))
                                                                          (add-feature-to-level-list (level *world*) 
                                                                                                     (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy) :z (z target))))))
                                                                    
                                                                    (decf (cur-hp target) cur-dmg)
                                                                    (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                           (format nil "~A is hit for ~A damage. " (capitalize-name (prepend-article +article-the+ (visible-name target))) cur-dmg)
                                                                                           :color (if (eq *player* target)
                                                                                                      (sdl:color :r 255 :g 140 :b 0)
                                                                                                      sdl:*yellow*)
                                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                         :singlemind)))
                                                                    ;; show message for LOW HP
                                                                    (when (and (eq *player* target)
                                                                               (< (/ (cur-hp target) (max-hp target)) 
                                                                                  0.3))
                                                                      (add-message "LOW HP!!! " sdl:*red*))
                                                                    
                                                                    (when (check-dead target)
                                                                      (when (mob-effect-p target +mob-effect-possessed+)
                                                                        (mob-depossess-target target))
                                                                      
                                                                      (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params (list :is-fire)))
                                                                      
                                                                    (generate-sound target (x target) (y target) (z target) 80 #'(lambda (str)
                                                                                                                                   (format nil "You hear gasps~A. " str)))))
                                                    )
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A prays, but nothing happens. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-smite+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  ;; a little bit of cheating here
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (or (and (mob-effect-p nearest-enemy +mob-effect-possessed+)
                                                                    (mob-effect-p nearest-enemy +mob-effect-reveal-true-form+)
                                                                    (mob-ability-p nearest-enemy +mob-abil-unholy+))
                                                               (and (not (mob-effect-p nearest-enemy +mob-effect-possessed+))
                                                                    (mob-ability-p nearest-enemy +mob-abil-unholy+))))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-slow+ :name "Slow" :descr "Pray to slow down one enemy causing it to take 50% more time when attempting any action." 
                                 :cd 5 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-SLOW: ~A [~A] uses slow on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone praying~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A slows ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))


                                                (set-mob-effect target :effect-type-id +mob-effect-slow+ :actor-id (id actor) :cd 4)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-slow+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  ;; a little bit of cheating here
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (not (mob-effect-p nearest-enemy +mob-effect-slow+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-prayer-wrath+ :name "Pray for wrath" :descr "Pray to grant your followers holy touch for 3 turns. Holy touch is a melee fire based attack." 
                                 :cd 5 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                
                                                (log:info (format nil "MOB-PRAYER-WRATH: ~A [~A] prays for wrath~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone praying~A." str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A prays for wrath. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (loop for ally-mob-id in (append (visible-mobs actor) (list (id actor)))
                                                      for mob = (get-mob-by-id ally-mob-id)
                                                      when (or (eq mob actor)
                                                               (and (order mob)
                                                                    (= (first (order mob)) +mob-order-follow+)
                                                                    (= (second (order mob)) (id actor))))
                                                          do
                                                             (log:info (format nil "MOB-PRAYER-WRATH: ~A [~A] affects the ally ~A~%" (name actor) (id actor) mob))
                                                             (set-mob-effect mob :effect-type-id +mob-effect-holy-touch+ :actor-id (id actor) :cd 3)
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A is granted holy touch. " (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                    :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                      )

                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-prayer-wrath+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if able to pray - do it
                                                  (if (and (mob-ability-p actor +mob-abil-prayer-wrath+)
                                                           (can-invoke-ability actor actor +mob-abil-prayer-wrath+)
                                                           nearest-enemy)
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-shadow-step+ :name "Shadow step" :descr "Dissolve into shadows and reform yourself at a destination tile. Can only be usable if both your origin tile and your destination tile are not lit." 
                                 :cd 10 :cost 0 :spd (truncate (* +normal-ap+ 0.8)) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the destination tile
                                                (log:info (format nil "MOB-SHADOW-STEP: ~A [~A] shadow steps to ~A~%" (name actor) (id actor) target))
                                                
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A steps into the shadows and disappears. "
                                                                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))
                                                  (set-mob-location actor x y z :apply-gravity t)
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A steps out of the shadows. "
                                                                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                       :singlemind)))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-shadow-step+)
                                                               (< (brightness actor) *mob-visibility-threshold*))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((free-tile-around nil))
                                                    (when nearest-enemy
                                                      (check-surroundings (x nearest-enemy) (y nearest-enemy) nil
                                                                          #'(lambda (dx dy)
                                                                              (let ((terrain (get-terrain-* (level *world*) dx dy (z nearest-enemy))))
                                                                                (when (and terrain
                                                                                           (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                                           (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                           (not (get-mob-* (level *world*) dx dy (z nearest-enemy)))
                                                                                           (< (calculate-single-tile-brightness (level *world*) dx dy (z nearest-enemy)) *mob-visibility-threshold*))
                                                                                  (setf free-tile-around (list dx dy (z nearest-enemy))))))))
                                                    (if (and (mob-ability-p actor +mob-abil-shadow-step+)
                                                             (can-invoke-ability actor actor +mob-abil-shadow-step+)
                                                             nearest-enemy
                                                             (or
                                                              ;; offensive shadow step
                                                              (and (> (/ (cur-hp actor) (max-hp actor)) 
                                                                      0.7)
                                                                   (> (strength actor) (strength nearest-enemy))
                                                                   free-tile-around)
                                                              )
                                                             )
                                                      free-tile-around
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                 (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (< (calculate-single-tile-brightness (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) *mob-visibility-threshold*)
                                                                 )
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-extinguish-light+ :name "Extinguish light" :descr "Pronounce an incantation to reduce a character's light radius to 0 for 4 turns or to switch off a stationary light source at range." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
                                 :start-map-select-func #'player-start-map-select-extinguish-light
                                 :on-invoke #'(lambda (ability-type actor target)
                                                ;; target here is list of (x y z) coordinates for the tile to be toggled

                                                (log:info (format nil "MOB-EXTINGUISH-LIGHT: ~A [~A] extinguishes light at ~A~%" (name actor) (id actor) target))
                                                
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (if (get-mob-* (level *world*) x y z)
                                                    (progn
                                                      (setf target (get-mob-* (level *world*) x y z))
                                                      (log:info (format nil "MOB-EXTINGUISH-LIGHT: ~A [~A] extinguishes light of ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
                                                      
                                                      (set-mob-effect target :effect-type-id +mob-effect-extinguished-light+ :actor-id (id actor) :cd 4)

                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                             (format nil "~A intones an incantation and darkness falls onto ~A. "
                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                     (prepend-article +article-the+ (visible-name target)))
                                                                             :observed-mob actor
                                                                             :color sdl:*white*
                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                    (progn
                                                      (when (and (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+)
                                                                 (> (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-light-source+) 0)
                                                                 (get-terrain-on-use (get-terrain-* (level *world*) x y z)))
                                                        (funcall (get-terrain-on-use (get-terrain-* (level *world*) x y z)) actor x y z)
                                                        (print-visible-message x y z (level *world*) (format nil "~A intones an incantation and the light switches off. "
                                                                                                             (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                               :observed-mob actor
                                                                               :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                      )
                                                    ))
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear somebody chanting~A. " str)))
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-extinguish-light+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-extinguish-light+)
                                                             (can-invoke-ability actor actor +mob-abil-extinguish-light+)
                                                             nearest-enemy
                                                             (> (cur-light nearest-enemy) 0)
                                                             (not (mob-ability-p nearest-enemy +mob-abil-casts-light+))
                                                             (< (get-outdoor-light-* (level *world*) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) *mob-visibility-threshold*))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor (list (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) (id ability-type))
                                                   )
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (or (and (get-terrain-type-trait terrain +terrain-trait-light-source+)
                                                                          (not (zerop (get-terrain-type-trait terrain +terrain-trait-light-source+))))
                                                                     (and (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                                          (> (cur-light (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))) 0)
                                                                          (find (id (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))) (visible-mobs *player*)))))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-umbral-aura+ :name "Umbral aura" :descr "You emit darkness around you." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-trinity-mimic+ :name "Trinity mimic" :descr "You are not linked to the singlemind of the angelkind, but you have even tighter bonds with the select few of them." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-merge+ :name "Merge" :descr "Cause your bonded trinity mimic standing nearby to merge into you. Melding is allowed only if the target is standing on the solid ground. The act of melding clears all effects from the target. While being merged you will have your HP redistributed each turn with other merged mimics so that all of you have the same amount of HP. Killing the amalgamated entity means killing all angels merged into it." 
                                 :cost 0 :spd (truncate +normal-ap+ 1.2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :start-map-select-func #'player-start-map-select-merge
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))

                                                (log:info (format nil "MOB-MERGE: ~A [~A] merges with ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                            (format nil "You hear some eerie sounds~A. " str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A merges with ~A. " (capitalize-name (prepend-article +article-the+ (visible-name target))) (prepend-article +article-the+ (visible-name actor)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (remove-mob-from-level-list (level *world*) target)

                                                ;; merging inventories
                                                (loop for item-id in (inv target)
                                                      for item = (get-item-by-id item-id)
                                                      do
                                                         (remove-from-inv item (inv target))
                                                         (setf (inv actor) (add-to-inv item (inv actor) (id actor))))
                                                (setf (inv target) nil)
                                                
                                                (loop for effect-type-id being the hash-key in (effects target) do
                                                  (rem-mob-effect target effect-type-id))

                                                (when (mob-effect-p actor +mob-effect-merged+)
                                                  (rem-mob-effect actor +mob-effect-merged+))
                                                  
                                                (setf (merged-id-list actor) (append (merged-id-list actor) (list (id target)) (merged-id-list target)))
                                                (setf (merged-id-list target) nil)

                                                (incf (cur-fp actor) (cur-fp target))
                                                (setf (cur-fp target) 0)
                                                                                                
                                                (set-mob-effect actor :effect-type-id +mob-effect-merged+ :actor-id (id actor) :param1 (mob-type actor))

                                                (when (zerop (random 20))
                                                  (if (check-mob-visible actor :observer *player* :complete-check t)
                                                    (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                                (format nil "~A says: \"Power overwhelming!\"~A. "
                                                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor))) str))
                                                                    :force-sound t)
                                                    (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                                (format nil "Somebody says: \"Power overwhelming!\"~A. " str))
                                                                    :force-sound t))
                                                  )
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((ally nil)
                                                            (check-func #'(lambda (mob)
                                                                            (if (and mob
                                                                                     (find (id mob) (mimic-id-list actor))
                                                                                     (not (mob-effect-p mob +mob-effect-possessed+))
                                                                                     (not (riding-mob-id mob))
                                                                                     (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) (z mob)) +terrain-trait-blocks-move-floor+))
                                                                              mob
                                                                              nil))))
                                                        (setf ally (block nil
                                                                     (check-surroundings (x actor) (y actor) nil
                                                                                         #'(lambda (dx dy)
                                                                                             (let* ((mob (get-mob-* (level *world*) dx dy (z actor)))
                                                                                                    (res (funcall check-func mob)))
                                                                                               (when res (return res)))))
                                                                     
                                                                     (when (< (1+ (z actor)) (array-dimension (terrain (level *world*)) 2))
                                                                       (check-surroundings (x actor) (y actor) nil
                                                                                           #'(lambda (dx dy)
                                                                                               (let* ((mob (get-mob-* (level *world*) dx dy (1+ (z actor))))
                                                                                                      (res (funcall check-func mob)))
                                                                                                 (when res (return res))))))
                                                                     (when (>= (1- (z actor)) 0)
                                                                       (check-surroundings (x actor) (y actor) nil
                                                                                           #'(lambda (dx dy)
                                                                                               (let* ((mob (get-mob-* (level *world*) dx dy (1- (z actor))))
                                                                                                      (res (funcall check-func mob)))
                                                                                                 (when res (return res))))))))
                                                        
                                                        (if (and ally
                                                                 (mob-ability-p actor +mob-abil-merge+)
                                                                 (not (mob-effect-p actor +mob-effect-possessed+))
                                                                 (not (mob-effect-p actor +mob-effect-divine-concealed+)))
                                                          t
                                                          nil)))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type))
                                                  (if (and (mob-ability-p actor +mob-abil-merge+)
                                                           (can-invoke-ability actor actor +mob-abil-merge+)
                                                           (not nearest-enemy)
                                                           nearest-ally
                                                           (find (id nearest-ally) (mimic-id-list actor))
                                                           (not (mob-effect-p nearest-ally +mob-effect-possessed+))
                                                           (not (riding-mob-id nearest-ally))
                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-ally) (y nearest-ally) (z nearest-ally)) +terrain-trait-blocks-move-floor+)
                                                           (< (get-distance-3d (x actor) (y actor) (z actor) (x nearest-ally) (y nearest-ally) (z nearest-ally))
                                                              2))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy check-result))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (< (get-distance-3d (view-x *player*) (view-y *player*) (view-z *player*) (x *player*) (y *player*) (z *player*)) 2)
                                                                 target
                                                                 (not (eq target *player*))
                                                                 (find (id target) (visible-mobs *player*))
                                                                 (find (id target) (mimic-id-list *player*))
                                                                 (not (mob-effect-p target +mob-effect-possessed+))
                                                                 (not (riding-mob-id target))
                                                                 (get-terrain-type-trait (get-terrain-* (level *world*) (x target) (y target) (z target)) +terrain-trait-blocks-move-floor+))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* target ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-unmerge+ :name "Unmerge" :descr "Cause all merged trinity mimics to unmerge into nearby tiles." 
                                 :cost 0 :spd (truncate +normal-ap+ 1.4) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))

                                                (log:info (format nil "MOB-UNMERGE: ~A [~A] unmerges ~A.~%" (name actor) (id actor) (loop for mimic-id in (merged-id-list actor)
                                                                                                                                      for mimic = (get-mob-by-id mimic-id)
                                                                                                                                      for i from 0
                                                                                                                                      with str = (create-string)
                                                                                                                                      do
                                                                                                                                         (when (> i 0)
                                                                                                                                           (format str ", "))
                                                                                                                                         (format str "~A [~A]" (name mimic) (id mimic))
                                                                                                                                      finally (return str))))

                                                (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                           (format nil "You hear some eerie sounds~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A unmerges all trinity mimics. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (rem-mob-effect actor +mob-effect-merged+)
                                                
                                                (let ((tile-list))
                                                  (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                  (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                 (not (get-mob-* (level *world*) dx dy (z actor)))
                                                                                                                 )
                                                                                                        (push (list dx dy (z actor)) tile-list)))))

                                                  (loop for mimic-id in (merged-id-list actor)
                                                        for mimic = (get-mob-by-id mimic-id)
                                                        for random-tile = (random (length tile-list))
                                                        for (x y z) = (nth random-tile tile-list)
                                                        with fp-per-mimic = (floor (cur-fp actor) (1+ (length (merged-id-list actor))))
                                                        do
                                                           (setf (is-merged mimic) nil)
                                                           (setf tile-list (remove (nth random-tile tile-list)
                                                                                   tile-list))
                                                           (incf (cur-fp mimic) fp-per-mimic)
                                                           (decf (cur-fp actor) fp-per-mimic)
                                                           (setf (x mimic) x (y mimic) y (z mimic) z)
                                                           (rem-mob-effect mimic +mob-effect-merged+)
                                                           (add-mob-to-level-list (level *world*) mimic))
                                                  (setf (merged-id-list actor) nil)
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((tile-list))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                  (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                 (not (get-mob-* (level *world*) dx dy (z actor)))
                                                                                                                 )
                                                                                                        (push (list dx dy (z actor)) tile-list)))))
                                                        
                                                        (if (and (mob-ability-p actor +mob-abil-unmerge+)
                                                                 (merged-id-list actor)
                                                                 (>= (length tile-list) 2)
                                                                 (not (mob-effect-p actor +mob-effect-divine-concealed+)))
                                                          t
                                                          nil)))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-unmerge+)
                                                           (can-invoke-ability actor actor +mob-abil-unmerge+)
                                                           nearest-enemy)
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-heal-other+ :name "Heal other" :descr "Invoke divine powers to heal one ally (including yourself)." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-nearest-ally
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-HEAL-OTHER: ~A [~A] heals ~A [~A].~%" (name actor) (id actor) (name target) (id target)))
                                                (let ((heal-pwr (+ (* 4 (mob-ability-value actor +mob-abil-heal-other+))
                                                                   (random (* 3 (mob-ability-value actor +mob-abil-heal-other+))))))
                                                  (when (> (+ (cur-hp target) heal-pwr)
                                                           (max-hp target))
                                                    (setf heal-pwr (- (max-hp target) (cur-hp target))))
                                                  (incf (cur-hp target) heal-pwr)
                                                  (decf (cur-fp actor) (cost ability-type))

                                                  (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                             (format nil "You hear some strange noise~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A invokes divine powers to heal ~A for ~A. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                 (prepend-article +article-the+ (visible-name target)) heal-pwr)
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-heal-other+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy))
                                                  (let ((heal-self (if (< (/ (cur-hp actor) (max-hp actor)) 
                                                                          0.6)
                                                                     actor
                                                                     nil))
                                                        (heal-ally (if (and nearest-ally
                                                                            (< (get-distance-3d (x actor) (y actor) (z actor) (x nearest-ally) (y nearest-ally) (z nearest-ally))
                                                                               (cur-sight actor))
                                                                            (< (/ (cur-hp nearest-ally) (max-hp nearest-ally)) 
                                                                               0.6))
                                                                     nearest-ally
                                                                     nil)))
                                                  (if (and (mob-ability-p actor +mob-abil-heal-other+)
                                                           (can-invoke-ability actor actor +mob-abil-heal-other+)
                                                           (or heal-self
                                                               heal-ally)
                                                           )
                                                    (if heal-ally
                                                      heal-ally
                                                      heal-self)
                                                    nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and target
                                                                 (get-faction-relation (faction *player*) (faction target))
                                                                 (check-mob-visible target :observer *player* :complete-check t)
                                                                 (find (id target) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* target ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                       )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-righteous-fury+ :name "Righteous fury" :descr "Feel the rage of the righteous. You will hit harder and faster for 5 turns but after the fury subsides you will be slowed for 3 turns." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear someone roaring~A. " str)))
                                                (set-mob-effect actor :effect-type-id +mob-effect-righteous-fury+ :actor-id (id actor) :cd 5)
                                                (decf (cur-fp actor) (cost ability-type))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-righteous-fury+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-slow+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (> (strength nearest-enemy) 
                                                                       (strength actor)))
                                                               (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.3)))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-righteous-fury+)
                                                           (can-invoke-ability actor actor +mob-abil-righteous-fury+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-pain-link+ :name "Pain link" :descr "Link yourself with one of the enemies causing it to inflict 30% more damage to you for 10 turns, but 30% damage less to everyone else. Only one link may be present at a time." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 20
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-PAIN-LINK: ~A [~A] uses pain link on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A. " str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A applies pain link to ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))


                                                (rem-mob-effect actor +mob-effect-pain-link-source+)
                                                (set-mob-effect target :effect-type-id +mob-effect-pain-link-target+ :actor-id (id actor) :cd 10)
                                                (set-mob-effect actor :effect-type-id +mob-effect-pain-link-source+ :actor-id (id actor) :cd 10 :param1 (id target))

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-pain-link+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (not (mob-effect-p nearest-enemy +mob-effect-pain-link-target+))
                                                           (not (mob-effect-p actor +mob-effect-pain-link-source+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-soul-reinforcement+ :name "Soul reinforcement" :descr "Invoke divine powers to reinforce the soul of an ally (inclduing yourself) for 3 turns. The reinforced soul will allow the target to remain in this world for a bit longer thus preventing the next fatal blow. In that case, the effect will be cancelled and the target will be left with 1 HP." 
                                 :cost 3 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
                                 :start-map-select-func #'player-start-map-select-nearest-ally
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-SOUL-REINFORCEMENT: ~A [~A] reinforces sould of ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear some eerie noises~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A invokes divine powers to reinforce the soul of ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                
                                                (set-mob-effect target :effect-type-id +mob-effect-soul-reinforcement+ :actor-id (id actor) :cd 3)

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-soul-reinforcement+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy))
                                                  (let ((reinforce-self (if (< (/ (cur-hp actor) (max-hp actor)) 
                                                                               0.2)
                                                                          actor
                                                                          nil))
                                                        (reinforce-ally (if (and nearest-ally
                                                                                 (< (get-distance-3d (x actor) (y actor) (z actor) (x nearest-ally) (y nearest-ally) (z nearest-ally))
                                                                                    (cur-sight actor))
                                                                                 (< (/ (cur-hp nearest-ally) (max-hp nearest-ally)) 
                                                                                    0.2))
                                                                          nearest-ally
                                                                          nil)))
                                                    (if (and (mob-ability-p actor +mob-abil-soul-reinforcement+)
                                                             (can-invoke-ability actor actor +mob-abil-soul-reinforcement+)
                                                             (or reinforce-self
                                                                 reinforce-ally))
                                                      (if reinforce-ally
                                                        reinforce-ally
                                                        reinforce-self)
                                                    nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((target (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and target
                                                                 (get-faction-relation (faction *player*) (faction target))
                                                                 (check-mob-visible target :observer *player* :complete-check t))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* target ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                       )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-silence+ :name "Silence" :descr "Channel divine powers to silence an opponent for 3 turns. Silenced characters are not able to use abilities that require voice." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 30
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-SILENCE: ~A [~A] uses silence on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A. " str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A silences ~A. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))


                                                (set-mob-effect target :effect-type-id +mob-effect-silence+ :actor-id (id actor) :cd 3)

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-silence+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (not (mob-effect-p nearest-enemy +mob-effect-silence+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-confuse+ :name "Confuse" :descr "Channel divine powers to confuse an opponent for 4 turns. More powerful creatures may resist confusion. Confused characters have a 50% chance to make a random move instead of an intended action." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 40
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-CONFUSE: ~A [~A] uses confuse on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A. " str)))

                                                (if (> (1+ (random 6)) (strength target))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A confuses ~A. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    
                                                    (set-mob-effect target :effect-type-id +mob-effect-confuse+ :actor-id (id actor) :cd 4))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A tries to confuse ~A, but ~A resists. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))

                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-confuse+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (not (mob-effect-p nearest-enemy +mob-effect-confuse+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-split-soul+ :name "Split soul" :descr "Split your soul to create an image of yourself next to you. The image will last for 6 turns. You will be able to control the image and transfer yourself to your image's place. You can have only one image created at a time." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                ;; target here is list of (x y z) coordinates for the tile to be placed an image
                                                (multiple-value-bind (x y z) (values-list target)
                                                  (print-visible-message x y z (level *world*) (format nil "~A splits its soul. "
                                                                                                       (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :observed-mob actor
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear some eerie sounds~A." str)))
                                                  (let ((image (make-instance (if (eq actor *player*)
                                                                                'player
                                                                                'mob)
                                                                              :mob-type +mob-type-angel-image+ :x (first target) :y (second target) :z (third target))))
                                                    (setf (name image) (format nil "~A's image" (name actor)))
                                                    (setf (alive-name image) (name image))
                                                    (set-mob-effect image :effect-type-id +mob-effect-split-soul-target+ :actor-id (id actor) :cd 6)
                                                    (set-mob-effect actor :effect-type-id +mob-effect-split-soul-source+ :actor-id (id actor) :cd 6 :param1 (id image))
                                                    (add-mob-to-level-list (level *world*) image))
                                                  )
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-split-soul+)
                                                               (not (mob-effect-p actor +mob-effect-split-soul-source+))
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((farthest-tile nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (or (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                                                                     (get-terrain-type-trait terrain +terrain-trait-water+))
                                                                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                 (not (get-mob-* (level *world*) dx dy (z actor)))
                                                                                                                 nearest-enemy)
                                                                                                        (unless farthest-tile
                                                                                                          (setf farthest-tile (list dx dy (z actor))))
                                                                                                        (when (> (get-distance dx dy (x nearest-enemy) (y nearest-enemy))
                                                                                                                 (get-distance (first farthest-tile) (second farthest-tile) (x nearest-enemy) (y nearest-enemy)))
                                                                                                          (setf farthest-tile (list dx dy (z actor))))))))
                                                    (if (and (mob-ability-p actor +mob-abil-split-soul+)
                                                             (can-invoke-ability actor actor +mob-abil-split-soul+)
                                                             farthest-tile
                                                             nearest-enemy
                                                             (<= (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2)
                                                             (> (strength nearest-enemy) (strength actor)))
                                                      farthest-tile
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (= (view-z *player*) (z *player*))
                                                                 (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                 (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 (or (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                     (get-terrain-type-trait terrain +terrain-trait-water+))
                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-restore-soul+ :name "Restore soul" :descr "Transfer the rest of your soul to the location of your image, destroying the image in the process. You can not restore your soul if your soul source is riding a gargantaur." 
                                 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (let ((source (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p actor +mob-effect-split-soul-target+)))))
                                                      (x (x actor))
                                                      (y (y actor))
                                                      (z (z actor)))
                                                  (cond
                                                    ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                                                          (get-single-memo-visibility (get-memo-* (level *world*) (x source) (y source) (z source)))
                                                          (check-mob-visible actor :observer *player*)
                                                          (check-mob-visible source :observer *player*))
                                                     (progn
                                                       (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                  (format nil "You hear some eerie sounds~A. " str)))
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                              (format nil "~A restores its soul to the location of its image. "
                                                                                      (capitalize-name (prepend-article +article-the+ (visible-name source))))
                                                                              :observed-mob actor
                                                                              :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                    ((and (get-single-memo-visibility (get-memo-* (level *world*) (x source) (y source) (z source)))
                                                          (check-mob-visible source :observer *player*))
                                                     (progn
                                                       (generate-sound actor (x source) (y source) (z source) 60 #'(lambda (str)
                                                                                                                     (format nil "You hear some eerie sounds~A. " str)))
                                                       (print-visible-message (x source) (y source) (z source) (level *world*)
                                                                              (format nil "~A restores its soul to the location of its image. "
                                                                                      (capitalize-name (prepend-article +article-the+ (visible-name source))))
                                                                              :observed-mob source
                                                                              :color (if (and (find (id source) (shared-visible-mobs *player*))
                                                                                              (not (find (id source) (proper-visible-mobs *player*))))
                                                                                       *shared-mind-msg-color*
                                                                                       sdl:*white*)
                                                                         :tags (list (when (and (find (id source) (shared-visible-mobs *player*))
                                                                                              (not (find (id source) (proper-visible-mobs *player*))))
                                                                                       :singlemind)))))
                                                    ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                                                          (check-mob-visible actor :observer *player*))
                                                     (progn
                                                       (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                     (format nil "You hear some eerie sounds~A. " str)))
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                              (format nil "~A restores its soul to the location of its image. "
                                                                                      (capitalize-name (prepend-article +article-the+ (visible-name source))))
                                                                              :observed-mob actor
                                                                              :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))))
                                                  
                                                  (rem-mob-effect actor +mob-effect-split-soul-target+)
                                                  (set-mob-location source x y z :apply-gravity nil)
                                                  (when (eq actor *player*)
                                                    (setf *player* source))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-restore-soul+)
                                                               (mob-effect-p actor +mob-effect-split-soul-target+)
                                                               (mob-effect-p (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p actor +mob-effect-split-soul-target+)))) +mob-effect-split-soul-source+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (null (riding-mob-id (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p actor +mob-effect-split-soul-target+)))))))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (mob-effect-p actor +mob-effect-split-soul-target+)
                                                    (progn
                                                      (let ((source (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p actor +mob-effect-split-soul-target+))))))
                                                        (log:info (format nil "CHECK-AI-RESTORE-SOUL: ~A [~A], source ~A, cur-hp ~A, ratio ~A, nearest-enemy ~A, can-invoke ~A~%"
                                                                        (name actor) (id actor) (name source) (cur-hp source) (/ (cur-hp source) (max-hp source))
                                                                        (or (null nearest-enemy)
                                                                            (>= (get-distance (x actor) (x actor) (x nearest-enemy) (y nearest-enemy)) 2))
                                                                        (can-invoke-ability actor actor +mob-abil-restore-soul+)))
                                                        (if (and (mob-ability-p actor +mob-abil-restore-soul+)
                                                                 (can-invoke-ability actor actor +mob-abil-restore-soul+)
                                                                 (< (/ (cur-hp source) (max-hp source)) 
                                                                    0.3)
                                                                 (null (riding-mob-id source))
                                                                 (or (null nearest-enemy)
                                                                     (>= (get-distance (x actor) (x actor) (x nearest-enemy) (y nearest-enemy)) 2))
                                                                 
                                                                 )
                                                          t
                                                          nil)))
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-resurrection+ :name "Resurrection" :descr "Restore the original soul to the body and make it alive again. The resurrection is only possible for bodies that are not mangled or corrupted by demonic reanimations." 
                                 :cost 6 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-resurrect
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-RESURRECTION: ~A [~A] resurrects ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))
                                                ;; target here is the item to be reanimated
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A channels divine energy. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :observed-mob actor
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear somebody chanting~A. " str)))
                                                (let ((mob-corpse))
                                                  (setf mob-corpse (get-mob-by-id (dead-mob target)))
                                                  (setf (x mob-corpse) (x target) (y mob-corpse) (y target) (z mob-corpse) (z target))
                                                  (setf (dead= mob-corpse) nil)
                                                  (setf (cur-hp mob-corpse) (max-hp mob-corpse))
                                                  (setf (cur-fp mob-corpse) 0)
                                                  (setf (cur-ap mob-corpse) (max-ap mob-corpse))
                                                  (when (merged-id-list mob-corpse)
                                                    (loop for mob-id in (merged-id-list mob-corpse)
                                                          for mob = (get-mob-by-id mob-id)
                                                          do
                                                             (setf (dead= mob) nil)
                                                             (setf (cur-hp mob) (max-hp mob))
                                                             (setf (cur-fp mob) 0)
                                                             (when (and (mob-ability-p mob +mob-abil-angel+)
                                                                        (not (mob-ability-p mob +mob-abil-animal+)))
                                                               (incf (total-angels (level *world*))))
                                                             (when (mob-ability-p mob +mob-abil-human+)
                                                               (incf (total-humans (level *world*))))
                                                             (incf (nth (loyal-faction mob) (total-faction-list (level *world*)))))
                                                    (set-mob-effect mob-corpse :effect-type-id +mob-effect-merged+ :actor-id (id mob-corpse) :param1 (mob-type mob-corpse)))
                                                  (add-mob-to-level-list (level *world*) mob-corpse)
                                                  (remove-item-from-level-list (level *world*) target)

                                                  (when (eq mob-corpse *player*)
                                                    (setf (dead-message-displayed *player*) nil))
                                                  
                                                  (print-visible-message (x mob-corpse) (y mob-corpse) (z mob-corpse) (level *world*) (format nil "~A stands up and walks. "
                                                                                                                                              (capitalize-name (prepend-article +article-the+ (visible-name mob-corpse))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  (log:info (format nil "MOB-RESURRECTION: ~A [~A] is resurrected at (~A ~A ~A).~%" (name mob-corpse) (id mob-corpse) (x mob-corpse) (y mob-corpse) (z mob-corpse)))
                                                  (remove-item-from-world target)
                                                  (incf (stat-raised-dead actor))
                                                  (when (eq actor *player*)
                                                    (incf (cur-score *player*) 10)))
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-resurrection+)
                                                               (not (mob-effect-p actor +mob-effect-divine-concealed+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (let ((item-id (funcall #'(lambda ()
                                                                        (let ((visible-items (copy-list (visible-items actor))))
                                                                          (setf visible-items (remove-if #'(lambda (a)
                                                                                                             (if (= (item-type a) +item-type-body-part-full+)
                                                                                                               nil
                                                                                                               t))
                                                                                                         visible-items
                                                                                                         :key #'get-item-by-id))
                                                                          (setf visible-items (remove-if #'(lambda (a)
                                                                                                             (if (get-mob-* (level *world*) (x a) (y a) (z a))
                                                                                                               t
                                                                                                               nil))
                                                                                                         visible-items
                                                                                                         :key #'get-item-by-id))
                                                                          (setf visible-items (remove-if #'(lambda (a)
                                                                                                             (if (and (dead-mob a)
                                                                                                                      (mob-ability-p (get-mob-by-id (dead-mob a)) +mob-abil-angel+))
                                                                                                               nil
                                                                                                               t))
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
                                                    (if (and (mob-ability-p actor +mob-abil-resurrection+)
                                                             (can-invoke-ability actor actor +mob-abil-resurrection+)
                                                             item-id)
                                                      item-id
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor (get-item-by-id check-result) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((items (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (exit-result nil))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (= (item-type a) +item-type-body-part-full+)
                                                                                     nil
                                                                                     t))
                                                                               items
                                                                               :key #'get-item-by-id))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (and (dead-mob a)
                                                                                            (not (mob-ability-p (get-mob-by-id (dead-mob a)) +mob-abil-demon+)))
                                                                                     nil
                                                                                     t))
                                                                               items
                                                                               :key #'get-item-by-id))
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
                                                                                          collect (format nil "~A"
                                                                                                          (capitalize-name (prepend-article +article-a+ (visible-name item)))
                                                                                                          )))
                                                               ;; populate the ability prompt list
                                                               (setf item-prompt-list (loop for item-id in item-list
                                                                                            collect #'(lambda (cur-sel)
                                                                                                        (declare (ignore cur-sel))
                                                                                                        "[Enter] Resurrect  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a body to resurrect:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
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
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil))))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-sprint+ :name "Sprint" :descr "Concenrate all your physical efforts, making yourself move 25% faster for 4 turns. You are unable to sprint while riding another creature." 
                                 :cd 10 :spd 0 :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (set-mob-effect actor :effect-type-id +mob-effect-sprint+ :actor-id (id actor) :cd 4)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-sprint+)
                                                               (not (mob-effect-p actor +mob-effect-exerted+))
                                                               (not (riding-mob-id actor)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (> (strength nearest-enemy) 
                                                                       (strength actor)))
                                                               (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.3)))
                                                           (mob-ability-p actor +mob-abil-sprint+)
                                                           (can-invoke-ability actor actor +mob-abil-sprint+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-jump+ :name "Jump" :descr "Jump to a specified location up to 3 tiles away. Jumping lets you cling to walls if you are able to and the destination allows it. Sprinting lets you jump 1 tile farther and you will still be able to cling to a wall after the jump. You are able to jump over small obstacles like tables and fences." 
                                 :cd 0 :cost 0 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; here the target is not a mob, but a (cons x y)
                                                (log:info (format nil "MOB-JUMP: ~A [~A] jumps to ~A.~%" (name actor) (id actor) target))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A jumps. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (let ((path-line nil))
                                                                                                   
                                                  (line-of-sight (x actor) (y actor) (z actor) (car target) (cdr target) (z actor) #'(lambda (dx dy dz prev-cell)
                                                                                                                                         (declare (ignore dz prev-cell))
                                                                                                                                         (let ((exit-result t))
                                                                                                                                            (block nil
                                                                                                                                              (push (cons dx dy) path-line)
                                                                                                                                              exit-result))))
                                                  (setf path-line (nreverse path-line))
                                                  (pop path-line)
                                                  
                                                  (loop for (dx . dy) in path-line
                                                        with charge-distance = (if (mob-effect-p actor +mob-effect-sprint+)
                                                                                 3
                                                                                 2)
                                                        with charge-result = nil
                                                        with sdx = (x actor)
                                                        with sdy = (y actor)
                                                        with prev-dx = (x actor)
                                                        with prev-dy = (y actor)
                                                        with hit-obstacle = nil
                                                        with can-jump-over = nil
                                                        while (not (zerop charge-distance))
                                                        do
                                                           (decf charge-distance)
                                                           (setf charge-result (check-move-on-level actor dx dy (z actor)))
                                                           (if (not (eq charge-result t))
                                                             (setf hit-obstacle t)
                                                             (setf hit-obstacle nil))
                                                           (if (and charge-result
                                                                    (typep charge-result 'list)
                                                                    (eq (first charge-result) :obstacles)
                                                                    (get-terrain-type-trait (get-terrain-* (level *world*)
                                                                                                           (first (first (second charge-result)))
                                                                                                           (second (first (second charge-result)))
                                                                                                           (third (first (second charge-result))))
                                                                                            +terrain-trait-can-jump-over+))
                                                             (setf can-jump-over t)
                                                             (setf can-jump-over nil))
                                                           (setf sdx dx sdy dy)
                                                           (when (and hit-obstacle
                                                                      (null can-jump-over))
                                                             (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                    (format nil "~A hits an obstacle. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                   :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                             (setf sdx prev-dx sdy prev-dy)
                                                             (loop-finish))
                                                           (when (null hit-obstacle)
                                                             (setf prev-dx sdx prev-dy sdy))
                                                           (when (and (zerop charge-distance)
                                                                      hit-obstacle
                                                                      can-jump-over)
                                                             (setf sdx prev-dx sdy prev-dy))
                                                        finally
                                                           (rem-mob-effect actor +mob-effect-sprint+)
                                                           (when (mob-ability-p actor +mob-abil-climbing+)
                                                             (set-mob-effect actor :effect-type-id +mob-effect-climbing-mode+ :actor-id (id actor) :cd t))
                                                           (when (or (/= (x actor) sdx)
                                                                     (/= (y actor) sdy))
                                                             (set-mob-location actor sdx sdy (z actor) :apply-gravity t)))
                                                  (set-mob-effect actor :effect-type-id +mob-effect-exerted+ :actor-id (id actor) :cd 6)
                                                  ))
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-jump+)
                                                               (not (riding-mob-id actor))
                                                               (not (mob-effect-p actor +mob-effect-exerted+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (mob-ability-p actor +mob-abil-jump+)
                                                           (can-invoke-ability actor actor +mob-abil-jump+))
                                                    nil
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor (cons (x nearest-enemy) (y nearest-enemy)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (eq *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                        (progn
                                                          nil)
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
                                                          (mob-invoke-ability *player* (cons (view-x *player*) (view-y *player*)) ability-type-id)
                                                          t))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-bend-space+ :name "Bend space" :descr "Bend space around yourself instantly warping to some other place up to 6 tiles away." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (invoke-bend-space actor)
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (and nearest-enemy
                                                                (< (/ (cur-hp actor) (max-hp actor)) 
                                                                   0.5))
                                                           (mob-ability-p actor +mob-abil-bend-space+)
                                                           (can-invoke-ability actor actor +mob-abil-bend-space+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-cast-shadow+ :name "Cast shadow" :descr "Cause a character to cast unnatural shadows on an adjacent tile for 6 turns. These shadows are valid for the Shadow Step ability." 
                                 :cd 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 40
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-CAST-SHADOW: ~A [~A] uses cast shadow on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A causes ~A to cast unnatural shadows. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (prepend-article +article-the+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (rem-mob-effect target +mob-effect-casting-shadow+)
                                                (set-mob-effect target :effect-type-id +mob-effect-casting-shadow+ :actor-id (id actor) :cd 6 :param1 (let ((dx (x target))
                                                                                                                                                            (dy (y target)))
                                                                                                                                                        (loop for r = (1+ (random 9))
                                                                                                                                                              while (= r 5)
                                                                                                                                                              finally (multiple-value-setq (dx dy) (x-y-dir r)))
                                                                                                                                                        (list dx dy)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-cast-shadow+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (not (mob-effect-p nearest-enemy +mob-effect-casting-shadow+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-cannibalize+ :name "Cannibalize" :descr "Eat the corpse you are standing on to gain 3 HP and 1 power. If your HP are at the maximum, also gain 1 maximum HP." 
                                 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-CANNIBALIZE: ~A [~A] invokes cannibalize on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone munching~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A devours ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))) (prepend-article +article-a+ (visible-name target)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (let ((already-mutated nil) (mutation-chance 20))
                                                  (when (dead-mob target)
                                                    (cond
                                                      ((mob-ability-p (get-mob-by-id (dead-mob target)) +mob-abil-human+)
                                                       (progn
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-toggle-light+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A can now toggle lights. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t))
                                                         
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-vulnerable-to-vorpal+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A is now vulnerable to vorpal. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t))))
                                                      
                                                      ((mob-ability-p (get-mob-by-id (dead-mob target)) +mob-abil-demon+)
                                                       (progn
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-bend-space+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A can now bend space. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t))
                                                         
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-vulnerable-to-fire+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A is now vulnerable to fire. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t))))
                                                      
                                                      ((mob-ability-p (get-mob-by-id (dead-mob target)) +mob-abil-angel+)
                                                       (progn
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-regenerate+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A can now regenerate. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t))
                                                         
                                                         (when (and (null already-mutated)
                                                                    (zerop (random mutation-chance)))
                                                           (mob-set-mutation actor +mob-abil-casts-light+)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A is now casting light. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                  :color sdl:*yellow*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                           (setf already-mutated t)))))))
                                                
                                                (remove-item-from-level-list (level *world*) target)
                                                (remove-item-from-world target)

                                                (incf (cur-hp actor) 3)
                                                
                                                (when (> (cur-hp actor) (max-hp actor))
                                                  (incf (max-hp actor))
                                                  (setf (cur-hp actor) (max-hp actor)))

                                                (if (mob-effect-p actor +mob-effect-primordial-transfer+)
                                                  (let ((transfer-target (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p actor +mob-effect-primordial-transfer+))))))
                                                    (when (eq transfer-target *player*)
                                                      (add-message (format nil "Your larva transfers power to you. ")))
                                                    (incf (cur-fp transfer-target))
                                                    (when (> (cur-fp transfer-target) (max-fp transfer-target))
                                                      (setf (cur-fp transfer-target) (max-fp transfer-target))))
                                                  (progn
                                                    (incf (cur-fp actor))
                                                    (when (> (cur-fp actor) (max-fp actor))
                                                      (setf (cur-fp actor) (max-fp actor)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (loop for item-id in (get-items-* (level *world*) (x actor) (y actor) (z actor))
                                                                for item = (get-item-by-id item-id)
                                                                with corpses = nil
                                                                when (item-ability-p item +item-abil-corpse+)
                                                                  do
                                                                     (push item corpses)
                                                                finally (return (if corpses
                                                                          t
                                                                          nil))))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-cannibalize+)
                                                           (can-invoke-ability actor actor +mob-abil-cannibalize+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (let ((target (loop for item-id in (get-items-* (level *world*) (x actor) (y actor) (z actor))
                                                                       for item = (get-item-by-id item-id)
                                                                       with corpses = nil
                                                                       when (item-ability-p item +item-abil-corpse+)
                                                                         do
                                                                            (push item corpses)
                                                                       finally (return (first corpses)))))
                                                     
                                                     (mob-invoke-ability actor target (id ability-type))))
                                 :obj-select-func #'(lambda (ability-type-id)
                                                      (let ((items (get-items-* (level *world*) (x *player*) (y *player*) (z *player*)))
                                                            (exit-result nil))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (item-ability-p (get-item-by-id a) +item-abil-corpse+)
                                                                                     nil
                                                                                     t))
                                                                               items))
                                                        (cond
                                                          ((> (length items) 1)
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
                                                                                                        "[Enter] Devour  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a body part to devour:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
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
                                                          ((= (length items) 1)
                                                           (progn
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil)))))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-primordial+ :name "Primordial" :descr "You dwelt on Earth before the advent of humankind. You will dwell on Earth after its inevitable demise." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-make-disguise+ :name "Make a disguise" :descr "Create a disguise out of two costumes. The disguise lets you conceal your true nature and present yourself as an ordinary man or a woman." 
                                 :spd (* +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone working~A. " str)))
                                                
                                                (setf (inv actor) (remove-from-inv-by-type +item-type-clothing+ (inv actor) 2))
                                                (mob-pick-item actor (make-instance 'item :item-type +item-type-disguise+ :x (x actor) :y (y actor) :z (z actor) :qty 1)
                                                               :spd nil :silent t)
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A creates a disguise. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-make-disguise+)
                                                               (>= (loop for item in (get-inv-items-by-type (inv actor) +item-type-clothing+)
                                                                         sum (qty item))
                                                                   2))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-make-disguise+)
                                                           (can-invoke-ability actor actor +mob-abil-make-disguise+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-remove-disguise+ :name "Remove a disguise" :descr "Remove a man-made disguise from yourself." 
                                 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear clothes rustling~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A removes its disguise. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                (rem-mob-effect actor +mob-effect-disguised+)
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-remove-disguise+)
                                                               (mob-effect-p actor +mob-effect-disguised+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-remove-disguise+)
                                                           (can-invoke-ability actor actor +mob-abil-remove-disguise+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-constriction+ :name "Constriction" :descr "When you attack a character in melee, you are able to grab and constrict around them. When constricting, you continue to deal damage to the constricted character even if you are already attacking another character. Constriction is broken when you or the constricted character move to another tile." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-deep-breath+ :name "Deep breath" :descr "Make a deep breath. On the next turn,  Malseraph transforms your exhale into sickly rays irradiating everybody around you. The power of the irradiation increases with the number of times the target is affected by the rays. Heavy irradiation may sometimes make the target unable to act. The amount of irradiation depends on your favor with Malseraph."
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (log:info (format nil "MOB-DEEP-BREATH: ~A [~A] uses deep breath.~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 40 #'(lambda (str)
                                                                                                           (format nil "You hear someone breathing~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A takes a deep breath. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                (set-mob-effect actor :effect-type-id +mob-effect-deep-breath+ :actor-id (id actor) :cd 2)
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-deep-breath+)
                                                               (not (mob-effect-p actor +mob-effect-deep-breath+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (< (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2)
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor))))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-irradiate+ :name "Irradiate" :descr "Channel hellish powers to affect the target character with sickly invisible rays. Exposure to them causes irradiation of the target. The power of the irradiation increases with the number of times the target is affected by the rays. Heavy irradiation may sometimes make the target unable to act. The amount of irradiation depends on your favor with Malseraph." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 20
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (log:info (format nil "MOB-IRRADIATE: ~A [~A] uses irradiate on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A. " str)))
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
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-irradiate+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (or (not (mob-effect-p nearest-enemy +mob-effect-irradiated+))
                                                               (and (mob-effect-p nearest-enemy +mob-effect-irradiated+)
                                                                    (< (param1 (get-effect-by-id (mob-effect-p nearest-enemy +mob-effect-irradiated+))) 5)
                                                                    (zerop (random 2)))
                                                               (and (mob-effect-p nearest-enemy +mob-effect-irradiated+)
                                                                    (< (param1 (get-effect-by-id (mob-effect-p nearest-enemy +mob-effect-irradiated+))) 10)
                                                                    (zerop (random 3)))))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-fission+ :name "Fission" :descr "Cause a violent outburst of energy from all irradiated targets in sight. The damage to the target scales with the degree of irradiation. Characters that are not irradiated are not affected." 
                                 :cost 1 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 40
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (let ((targets))
                                                  (setf targets (loop for mob-id in (visible-mobs actor)
                                                                      for mob = (get-mob-by-id mob-id)
                                                                      when (mob-effect-p mob +mob-effect-irradiated+)
                                                                        collect mob))
                                                
                                                  (log:info (format nil "MOB-FISSION: ~A [~A] uses fission on ~A.~%" (name actor) (id actor) (loop with str = (create-string)
                                                                                                                                                 for mob in targets do
                                                                                                                                                   (format str "~A [~A], " (name mob) (id mob))
                                                                                                                                                 finally
                                                                                                                                                    (return str))))
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone chanting~A. " str)))
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A causes fission. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  (loop for mob in targets
                                                        when (> (param1 (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+))) 0)
                                                          do
                                                             (inflict-damage mob :actor actor
                                                                                 :min-dmg (param1 (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+)))
                                                                                 :max-dmg (* 2 (param1 (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+))))
                                                                                 :dmg-type +weapon-dmg-radiation+ :no-dodge t :no-hit-message t
                                                                                 :att-spd nil :weapon-aux () :acc 100
                                                                                 :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                               (format nil "~A takes ~A damage. " (capitalize-name (prepend-article +article-the+ (name mob))) cur-dmg)))
                                                             (rem-mob-effect mob +mob-effect-irradiated+))
                                                  
                                                  (decf (cur-fp actor) (cost ability-type)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-fission+)
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (not (get-faction-relation (faction actor) (get-visible-faction nearest-enemy :viewer actor)))
                                                           (or (and (mob-effect-p nearest-enemy +mob-effect-irradiated+)
                                                                    (< (param1 (get-effect-by-id (mob-effect-p nearest-enemy +mob-effect-irradiated+))) 5)
                                                                    (zerop (random 3)))
                                                               (and (mob-effect-p nearest-enemy +mob-effect-irradiated+)
                                                                    (< (param1 (get-effect-by-id (mob-effect-p nearest-enemy +mob-effect-irradiated+))) 10)
                                                                    (zerop (random 2)))
                                                               (and (mob-effect-p nearest-enemy +mob-effect-irradiated+)
                                                                    (>= (param1 (get-effect-by-id (mob-effect-p nearest-enemy +mob-effect-irradiated+))) 10))))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-create-parasites+ :name "Spawn parasites" :descr "Start the scarab egg laying process. 6 parasites become ready to use in 3 turns. Parasites can infest an enemy character for a very long period of time. Parasited characters will have their direct resistances against flesh and acid damage reduced by 1. You can always see the location of parasited characters." 
                                 :cost 1 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-laying-eggs+ :actor-id (id actor) :cd 3
                                                                      :param1 #'(lambda ()
                                                                                  (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-parasite+ :x (x actor) :y (y actor) :z (z actor) :qty 6)
                                                                                                 :spd nil :silent t)
                                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                         (format nil "6 parasite eggs have finished growing inside ~A. "
                                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                         :color sdl:*white*
                                                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                       :singlemind)))))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "Parasite eggs start to grow inside ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-create-parasites+)
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-laying-eggs+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-create-parasites+)
                                                           (can-invoke-ability actor actor +mob-abil-create-parasites+)
                                                           (< (loop for item in (get-inv-items-by-type (inv actor) +item-type-eater-parasite+)
                                                                    sum (qty item))
                                                                   3))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-adrenal-gland+ :name "Adrenal gland" :descr "When you attack somebody, your adrenaline level will start to increase. Increased adrenaline will make your attacks faster." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-acid-spit+ :name "Grow an acid gland" :descr "Evolve to give yourself an ability to spit acid at your enemies. The evolution process takes 10 turns. The acid spit is mutually exclusive with the clawed tentacles, corrosive sacs and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-acid-spit+ "grows an acid gland"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-acid-spit+)
                                                               (not (mob-ability-p actor +mob-abil-acid-spit+))
                                                               (not (mob-ability-p actor +mob-abil-corrosive-bile+))
                                                               (not (mob-ability-p actor +mob-abil-accurate-bile+))
                                                               (not (mob-ability-p actor +mob-abil-clawed-tentacle+))
                                                               (not (mob-ability-p actor +mob-abil-piercing-needles+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-acid-spit+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-acid-spit+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-acid-spit+ :name "Acid spit" :descr "You are able to spit at your enemies dealing 1-3 acid damage." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil
                                 :on-add-mutation #'(lambda (ability-type actor)
                                                      (declare (ignore ability-type))
                                                      (if (mob-ability-p actor +mob-abil-corroding-secretion+)
                                                        (setf (weapon actor) (list "Tentacles & Acid spit"
                                                                                 (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts))
                                                                                 (list +weapon-dmg-acid+ 1 3 +normal-ap+ 1 0 1 100 "spits at" (list :no-charges :corrodes))))
                                                        (setf (weapon actor) (list "Tentacles & Acid spit"
                                                                                   (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts))
                                                                                   (list +weapon-dmg-acid+ 1 3 +normal-ap+ 1 0 1 100 "spits at" (list :no-charges)))))
                                                      (adjust-r-acc actor)
                                                      )
                                 :on-remove-mutation #'(lambda (ability-type actor)
                                                         (declare (ignore ability-type))
                                                         (setf (weapon actor) (list "Tentacles" (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts)) nil))
                                                         (adjust-r-acc actor)
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-corrosive-bile+ :name "Grow corrosive sacs" :descr "Evolve to give yourself an ability to spit corrosive bile at your enemies. The evolution process takes 10 turns. Corrosive bile is shot upwards and lands to the destination tile on the next turn, dealing damage to charaters in and around it. The corrosive sacs are mutually exclusive with the clawed tentacles, acid spite and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-corrosive-bile+ "grows corrosive sacs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-corrosive-bile+)
                                                               (not (mob-ability-p actor +mob-abil-acid-spit+))
                                                               (not (mob-ability-p actor +mob-abil-corroding-secretion+))
                                                               (not (mob-ability-p actor +mob-abil-corrosive-bile+))
                                                               (not (mob-ability-p actor +mob-abil-clawed-tentacle+))
                                                               (not (mob-ability-p actor +mob-abil-piercing-needles+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-corrosive-bile+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-corrosive-bile+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-corrosive-bile+ :name "Corrosive bile" :descr "Spit corrosive bile at a tile. It is shot upwards and lands to the destination tile on the next turn, dealing 4-8 acid damage to charaters in and around it. Available if there are no obstacles above you up to the highest Z level. Corrosive bile is not very accurate and will sometimes land next to the targeted location." 
                                 :cost 0 :cd 4 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 40
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target is (x y z)
                                                (log:info (format nil "MOB-CORROSIVE-BILE: ~A [~A] uses corrosive bile on ~A.~%" (name actor) (id actor) target))

                                                (let ((x (+ (first target) (- (random 3) 1)))
                                                      (y (+ (second target) (- (random 3) 1))))

                                                  (when (mob-ability-p actor +mob-abil-accurate-bile+)
                                                    (setf x (first target) y (second target)))
                                                                                                    
                                                  (loop with final-z = (third target)
                                                        for z from (1- (array-dimension (terrain (level *world*)) 2)) downto final-z
                                                        when (and (get-terrain-* (level *world*) x y z)
                                                                  (or (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move-floor+)))
                                                          do
                                                             (loop-finish)
                                                        when (and (get-terrain-* (level *world*) x y z)
                                                                  (or (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+)
                                                                      (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-projectiles+)
                                                                      (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-water+)))
                                                          do
                                                             (incf z)
                                                             (loop-finish)
                                                             
                                                        finally
                                                           (when (< z (array-dimension (terrain (level *world*)) 2))
                                                             (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-corrosive-bile-target+ :x x :y y :z z :counter 2 :param1 (id actor)))))
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 40 #'(lambda (str)
                                                                                                             (format nil "You hear someone bodily sounds~A. " str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A spits corrosive bile. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))

                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-corrosive-bile+)
                                                               (loop for z from (1+ (z actor)) below (array-dimension (terrain (level *world*)) 2)
                                                                     with clear-path = t
                                                                     when (and (get-terrain-* (level *world*) (x actor) (y actor) z)
                                                                               (or (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-blocks-move+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-blocks-move-floor+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-blocks-projectiles+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-water+)))
                                                                       do
                                                                          (setf clear-path nil)
                                                                          (loop-finish)
                                                                     finally (return clear-path)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (< (get-distance-3d (x *player*) (y *player*) (z *player*) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 9)
                                                           (loop for z from (1- (array-dimension (terrain (level *world*)) 2)) downto (1+ (z nearest-enemy))
                                                                 with clear-path = t
                                                                 when (and (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z)
                                                                           (or (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-blocks-move+)
                                                                               (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-blocks-move-floor+)
                                                                               (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-blocks-projectiles+)
                                                                               (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-water+)))
                                                                   do
                                                                      (setf clear-path nil)
                                                                      (loop-finish)
                                                                 finally (return clear-path)))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor (list (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                               (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 9)
                                                               (loop for z from (1- (array-dimension (terrain (level *world*)) 2)) downto (1+ (view-z *player*))
                                                                     with clear-path = t
                                                                     when (and (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                                               (or (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-blocks-move+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-blocks-move-floor+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-blocks-projectiles+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-water+)))
                                                                       do
                                                                          (setf clear-path nil)
                                                                          (loop-finish)
                                                                     finally (return clear-path)))
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
                                                          (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                          t)
                                                        (progn
                                                          nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-clawed-tentacle+ :name "Grow clawed tentacles" :descr "Evolve to give yourself clawed tentacles which significatly increase melee damage. The evolution process takes 10 turns. The clawed tentacles are mutually exclusive with the acid spit, corrosive sacs and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-clawed-tentacle+ "grows clawed tentacles"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-clawed-tentacle+)
                                                               (not (mob-ability-p actor +mob-abil-acid-spit+))
                                                               (not (mob-ability-p actor +mob-abil-corroding-secretion+))
                                                               (not (mob-ability-p actor +mob-abil-corrosive-bile+))
                                                               (not (mob-ability-p actor +mob-abil-accurate-bile+))
                                                               (not (mob-ability-p actor +mob-abil-clawed-tentacle+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-clawed-tentacle+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-clawed-tentacle+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-clawed-tentacle+ :name "Clawed tentacles" :descr "Your tentacles have sharp claws." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil
                                 :on-add-mutation #'(lambda (ability-type actor)
                                                      (declare (ignore ability-type))
                                                      (setf (weapon actor) (list "Clawed tentacles" (list +weapon-dmg-flesh+ 3 5 (truncate (* +normal-ap+ 0.75)) 100 (list :constricts)) nil))
                                                      )
                                 :on-remove-mutation #'(lambda (ability-type actor)
                                                         (declare (ignore ability-type))
                                                         (setf (weapon actor) (list "Tentacles" (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts)) nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-chitinous-plating+ :name "Grow chitinous plating" :descr "Evolve to increase your skin thickness which will turn it into full-scale armor. The evolution process takes 10 turns. Chitinous plating gives 2 points of direct resistance against flesh, iron, fire, vorpal and acid damage. The chitinous plating is mutually exclusive with the metabolic boost and retracting spines." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-chitinous-plating+ "gets completely covered with chitin"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-chitinous-plating+)
                                                               (not (mob-ability-p actor +mob-abil-chitinous-plating+))
                                                               (not (mob-ability-p actor +mob-abil-metabolic-boost+))
                                                               (not (mob-ability-p actor +mob-abil-jump+))
                                                               (not (mob-ability-p actor +mob-abil-retracting-spines+))
                                                               (not (mob-ability-p actor +mob-abil-acidic-tips+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-chitinous-plating+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-chitinous-plating+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-chitinous-plating+ :name "Chitinous plating" :descr "You are completely covered with chitin which gives you 2 points of direct resistance against flesh, iron, fire, vorpal and acid damage." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil
                                 :on-add-mutation #'(lambda (ability-type actor)
                                                      (declare (ignore ability-type))
                                                      (adjust-armor actor)
                                                      )
                                 :on-remove-mutation #'(lambda (ability-type actor)
                                                         (declare (ignore ability-type))
                                                         (adjust-armor actor)
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-metabolic-boost+ :name "Increase metabolism" :descr "Evolve to give youself an ability to boost your metabolism at will. The evolution process takes 10 turns. The metabolic boost grants you increased dodging and overall speed for 4 turns. The metabolic boost is mutually exclusive with the chitinous plating and retracting spines." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-metabolic-boost+ "can now boost metabolism at will"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-metabolic-boost+)
                                                               (not (mob-ability-p actor +mob-abil-chitinous-plating+))
                                                               (not (mob-ability-p actor +mob-abil-thick-carapace+))
                                                               (not (mob-ability-p actor +mob-abil-metabolic-boost+))
                                                               (not (mob-ability-p actor +mob-abil-retracting-spines+))
                                                               (not (mob-ability-p actor +mob-abil-acidic-tips+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-metabolic-boost+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-metabolic-boost+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-metabolic-boost+ :name "Metabolic boost" :descr "Accelerate your metabolism which increases your dodging by 50% and overall speed by 30% for 4 turns." 
                                 :cd 8 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (set-mob-effect actor :effect-type-id +mob-effect-metabolic-boost+ :actor-id (id actor) :cd 4)
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A accelerates its metabolism. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-metabolic-boost+)
                                                               (not (mob-effect-p actor +mob-effect-metabolic-boost+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and nearest-enemy
                                                           (< (get-distance-3d (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 3)
                                                           (mob-ability-p actor +mob-abil-metabolic-boost+)
                                                           (can-invoke-ability actor actor +mob-abil-metabolic-boost+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-retracting-spines+ :name "Grow retracting spines" :descr "Evolve to give yourself retracting spines. The evolution process takes 10 turns. The spines grant you 40% resistance against flesh, iron, fire, vorpal and acid damage for 4 turns. Additionally, characters attacking you in melee while the spines are active will take 1-3 flesh damage. The retracting spines are mutually exclusive with the metabolic boost and chitinous plating." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-retracting-spines+ "grows retracting spines"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-retracting-spines+)
                                                               (not (mob-ability-p actor +mob-abil-chitinous-plating+))
                                                               (not (mob-ability-p actor +mob-abil-thick-carapace+))
                                                               (not (mob-ability-p actor +mob-abil-metabolic-boost+))
                                                               (not (mob-ability-p actor +mob-abil-jump+))
                                                               (not (mob-ability-p actor +mob-abil-retracting-spines+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-retracting-spines+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-retracting-spines+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-retracting-spines+ :name "Extend spines" :descr "Extend your spines which gives you 40% resistance against flesh, iron, fire, vorpal and acid damage for 4 turns. Additionally, characters attacking you in melee while the spines are active will take 1-3 flesh damage." 
                                 :cd 8 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (set-mob-effect actor :effect-type-id +mob-effect-spines+ :actor-id (id actor) :cd 4)
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A extends its spines. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-retracting-spines+)
                                                               (not (mob-effect-p actor +mob-effect-spines+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and nearest-enemy
                                                           (< (get-distance-3d (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 3)
                                                           (mob-ability-p actor +mob-abil-retracting-spines+)
                                                           (can-invoke-ability actor actor +mob-abil-retracting-spines+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-spawn-locusts+ :name "Grow locust spawning sacs" :descr "Evolve to let your ovipositor spawn locusts. The evolution process takes 15 turns. Locusts live for 10 turns, have 8 HP and deal 3-4 flesh dmg in melee. The locust spawning sacs are mutually exclusive with the scarab spawning sacs." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-spawn-locusts+ "grows locust spawning sacs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-spawn-locusts+)
                                                               (not (mob-ability-p actor +mob-abil-spawn-locusts+))
                                                               (not (mob-ability-p actor +mob-abil-spawn-scarabs+))
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-spawn-locusts+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-spawn-locusts+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-spawn-locusts+ :name "Spawn locust eggs" :descr "Start the egg laying process. 2 eggs become ready to use in 6 turns and can later quickly develop into locusts. A locust has 8 HP, deals 3-4 flesh damage in melee and lives for 10 turns." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-laying-eggs+ :actor-id (id actor) :cd 6
                                                                      :param1 #'(lambda ()
                                                                                  (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-locust-egg+ :x (x actor) :y (y actor) :z (z actor) :qty 2)
                                                                                                 :spd nil :silent t)
                                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                         (format nil "2 locust eggs have finished growing inside ~A. "
                                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                         :color sdl:*white*
                                                                                                         :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                       :singlemind)))))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "Locust eggs start to grow inside ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-spawn-locusts+)
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-laying-eggs+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-spawn-locusts+)
                                                           (can-invoke-ability actor actor +mob-abil-spawn-locusts+)
                                                           (< (loop for item in (get-inv-items-by-type (inv actor) +item-type-eater-locust-egg+)
                                                                    sum (qty item))
                                                              2))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-ovipositor+ :name "Grow ovipositor" :descr "Evolve to get an ability to lay eggs different kind of eggs. The evolution process takes 15 turns." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-oviposit+ "grows ovipositor"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-ovipositor+)
                                                               (not (mob-ability-p actor +mob-abil-oviposit+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-ovipositor+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-ovipositor+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-oviposit+ :name "Ovipositor" :descr "You are able to lay different kinds of eggs." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-spawn-scarabs+ :name "Grow scarab spawning sacs" :descr "Evolve to let your ovipositor spawn scarabs. The evolution process takes 15 turns. Scarabs are living bombs that try to move to the target and explode to deal 6-10 acid damage when contacting an enemy. The scarab spawning sacs are mutually exclusive with the locust spawning sacs." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-spawn-scarabs+ "grows scarab spawning sacs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-spawn-scarabs+)
                                                               (not (mob-ability-p actor +mob-abil-spawn-locusts+))
                                                               (not (mob-ability-p actor +mob-abil-spawn-scarabs+))
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-spawn-scarabs+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-spawn-scarabs+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-spawn-scarabs+ :name "Spawn scarab eggs" :descr "Start the scarab egg laying process. Eggs become ready to use in 6 turns and can later quickly develop into scarabs. Scarabs are living bombs that try to move to the target and explode to deal 6-10 acid damage when contacting an enemy." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-laying-eggs+ :actor-id (id actor) :cd 6
                                                                      :param1 #'(lambda ()
                                                                                  (if (mob-ability-p actor +mob-abil-oviposit-more-eggs+)
                                                                                    (progn
                                                                                      (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-scarab-egg+ :x (x actor) :y (y actor) :z (z actor) :qty 2)
                                                                                                     :spd nil :silent t)
                                                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                             (format nil "2 scarab eggs have finished growing inside ~A. "
                                                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                             :color sdl:*white*
                                                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                           :singlemind))))
                                                                                    (progn
                                                                                      (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-scarab-egg+ :x (x actor) :y (y actor) :z (z actor) :qty 1)
                                                                                                     :spd nil :silent t)
                                                                                      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                             (format nil "A scarab egg has finished growing inside ~A. "
                                                                                                                     (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                             :color sdl:*white*
                                                                                                             :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                           :singlemind)))))))
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "Scarab eggs start to grow inside ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                       :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                     :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-oviposit+)
                                                               (mob-ability-p actor +mob-abil-spawn-scarabs+)
                                                               (not (mob-effect-p actor +mob-effect-laying-eggs+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-spawn-scarabs+)
                                                           (can-invoke-ability actor actor +mob-abil-spawn-scarabs+)
                                                           (< (loop for item in (get-inv-items-by-type (inv actor) +item-type-eater-scarab-egg+)
                                                                    sum (qty item))
                                                                   2))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-acid-explosion+ :name "Acid explosion" :descr "You explode when contacting allies and enemies." 
                                 :passive t :cost 0 :spd +normal-ap+
                                 :final t :on-touch t
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                
                                                (log:info (format nil "MOB-ACID-EXPLOSION: ~A [~A] explodes on ~A [~A]~%" (name actor) (id actor) (name target) (id target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A explodes. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (let ((targets nil)
                                                      (max-range 1))
                                                  (draw-fov (x actor) (y actor) (z actor) max-range
                                                            #'(lambda (dx dy dz prev-cell)
                                                                (let ((exit-result t))
                                                                  (block nil
                                                                    (when (> (get-distance-3d (x actor) (y actor) (z actor) dx dy dz) (1+ max-range))
                                                                      (setf exit-result 'exit)
                                                                      (return))
                                                                    
                                                                    (when (eq (check-LOS-propagate dx dy dz prev-cell :check-move t) nil)
                                                                      (setf exit-result 'exit)
                                                                      (return))
                                                                    
                                                                    (place-animation dx dy dz +anim-type-acid-dot+ :params ())
                                                                    
                                                                    (when (and (get-mob-* (level *world*) dx dy dz)) 
                                                                      (pushnew (get-mob-* (level *world*) dx dy dz) targets))
                                                                    )
                                                                  exit-result)))
                                                  
                                                  (loop for target in targets
                                                        for cur-dmg = 0
                                                        do
                                                           (incf cur-dmg (inflict-damage target :min-dmg 6 :max-dmg 10 :dmg-type +weapon-dmg-acid+
                                                                                                :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t :no-hit-message t :no-check-dead t
                                                                                                :actor actor))
                                                           (if (zerop cur-dmg)
                                                             (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                    (format nil "~A is not hurt. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                                    :color (if (if-cur-mob-seen-through-shared-vision *player*)
                                                                                             *shared-mind-msg-color*
                                                                                             sdl:*white*))
                                                             (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                    (format nil "~A takes ~A damage. " (capitalize-name (prepend-article +article-the+ (visible-name target))) cur-dmg)
                                                                                    :color sdl:*white*
                                                                                    :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                  :singlemind))))
                                                           (when (and (not (eq target actor))
                                                                      (check-dead target))
                                                             (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params ())
                                                             
                                                             (when (mob-effect-p target +mob-effect-possessed+)
                                                               (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                               (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                                     (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                                     (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                               (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))))
                                                  
                                                  (setf (cur-hp actor) 0)
                                                  (when (check-dead actor)
                                                    (make-dead actor :splatter nil :msg t :killer nil :corpse nil :aux-params ())
                                                    (when (mob-effect-p actor +mob-effect-possessed+)
                                                      (setf (cur-hp (get-mob-by-id (slave-mob-id actor))) 0)
                                                      (setf (x (get-mob-by-id (slave-mob-id actor))) (x actor)
                                                            (y (get-mob-by-id (slave-mob-id actor))) (y actor)
                                                            (z (get-mob-by-id (slave-mob-id actor))) (z actor))
                                                      (make-dead (get-mob-by-id (slave-mob-id actor)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ())))
                                                  )
                                                
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type))
                                                      (if (and (mob-ability-p actor +mob-abil-acid-explosion+)
                                                               (not (get-faction-relation (faction actor) (faction target))))
                                                        t
                                                        nil))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-acid-locusts+ :name "Morph acidic spawning sacs" :descr "Evolve to make your spawning sacs create locusts with acid (instead of flesh) damage. The evolution process takes 15 turns. This mutation is only available if you already have the locust spawning sacs." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-acid-locusts+ "grows acidic spawning sacs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-acid-locusts+)
                                                               (mob-ability-p actor +mob-abil-spawn-locusts+)
                                                               (not (mob-ability-p actor +mob-abil-acid-locusts+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-acid-locusts+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-acid-locusts+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-fast-scarabs+ :name "Morph faster scarabs" :descr "Evolve to make your scarabs cover ground quicker. The evolution process takes 15 turns. This mutation is only available if you already have the scarab spawning sacs." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-fast-scarabs+ "grows adrenalized ovipositor"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-fast-scarabs+)
                                                               (mob-ability-p actor +mob-abil-spawn-scarabs+)
                                                               (not (mob-ability-p actor +mob-abil-fast-scarabs+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-fast-scarabs+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-fast-scarabs+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-acid-locusts+ :name "Acid locusts" :descr "The locusts you spawn will have an acid attack (instead of a flesh one)." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-fast-scarabs+ :name "Fast scarabs" :descr "The scarabs you spawn will cover ground to the target quicker." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-regenerate+ :name "Regenerate" :descr "Heal 6 HP within 6 turns." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-regenerate+ :actor-id (id actor) :cd 6)
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to regenerate. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-regenerate+)
                                                               (not (mob-effect-p actor +mob-effect-regenerate+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-regenerate+)
                                                           (can-invoke-ability actor actor +mob-abil-regenerate+)
                                                           (>= (- (max-hp actor) (cur-hp actor))
                                                               6))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-casts-light+ :name "Casts light" :descr "You light radius is always 6. Prevails over the Extinguish light ability." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-vulnerable-to-vorpal+ :name "Vulnerable to vorpal" :descr "Your direct resistance to vorpal is always 2 points lower than usual." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-vulnerable-to-fire+ :name "Vulnerable to fire" :descr "Your direct resistance to fire is always 2 points lower than usual." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-oviposit-more-eggs+ :name "Morph multiple eggcells" :descr "Evolve to make your ovipositor lay 2 scarab eggs at once instead of one. The evolution process takes 15 turns. This mutation is only available if you already have the scarab spawning sacs." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-oviposit-more-eggs+ "can now lay more eggs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-oviposit-more-eggs+)
                                                               (mob-ability-p actor +mob-abil-spawn-scarabs+)
                                                               (not (mob-ability-p actor +mob-abil-oviposit-more-eggs+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-oviposit-more-eggs+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-oviposit-more-eggs+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-oviposit-more-eggs+ :name "Multiple eggcells" :descr "Your ovipositor lays 2 scarab eggs at once instead of one." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-tougher-locusts+ :name "Morph chitin injection" :descr "Evolve to make your locusts last 15 turns (instead of 10) and have 14 HP (instead of 8). The evolution process takes 15 turns. This mutation is only available if you already have the locust spawning sacs." 
                                 :cost 4 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 15 :param1 (list +mob-abil-tougher-locusts+ "can now spawn tougher locusts"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-tougher-locusts+)
                                                               (mob-ability-p actor +mob-abil-spawn-locusts+)
                                                               (not (mob-ability-p actor +mob-abil-tougher-locusts+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-tougher-locusts+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-tougher-locusts+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-tougher-locusts+ :name "Chitin injection" :descr "Your locusts last 15 turns (instead of 10) and have 14 HP (instead of 8)." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-cure-mutation+ :name "Cure mutation" :descr "Cure one mutation you have gained." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                ;; target is ability-type-id
                                                (log:info (format nil "MOB-CURE-MUTATION: ~A [~A] invokes cure mutatation on ~A [~A].~%" (name actor) (id actor) (name (get-ability-type-by-id target)) (id (get-ability-type-by-id target))))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear someone bodily sounds~A. " str)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A gets rid of ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                               (name (get-ability-type-by-id target)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (mob-remove-mutation actor target)
                                                (decf (cur-fp actor) (cost ability-type))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (loop for ability-type-id in (get-mob-all-abilities actor)
                                                            with has-mutation = nil
                                                            when (mob-is-ability-mutation actor ability-type-id)
                                                              do
                                                                 (setf has-mutation t)
                                                                 (loop-finish)
                                                            finally (return (if has-mutation
                                                                              t
                                                                              nil)))
                                                      )
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((malmutations (loop for malmutation in (list +mob-abil-vulnerable-to-fire+ +mob-abil-vulnerable-to-vorpal+ +mob-abil-casts-light+)
                                                                           when (and (mob-ability-p actor malmutation)
                                                                                     (mob-is-ability-mutation actor malmutation))
                                                                             collect malmutation)))
                                                    
                                                    (if (and (not nearest-enemy)
                                                             (mob-ability-p actor +mob-abil-cure-mutation+)
                                                             malmutations
                                                             (can-invoke-ability actor actor +mob-abil-cure-mutation+))
                                                      malmutations
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (let* ((target-mutation (nth (random (length check-result)) check-result)))
                                                     (mob-invoke-ability actor target-mutation (id ability-type))))
                                 :obj-select-func #'(lambda (ability-type-id)
                                                      (let ((mutations (loop for ability-type-id being the hash-key in (abilities *player*)
                                                                             with mutations = ()
                                                                             when (mob-is-ability-mutation *player* ability-type-id)
                                                                               do
                                                                                  (pushnew ability-type-id mutations)
                                                                             finally (return mutations)))
                                                            (exit-result nil))
                                                        (cond
                                                          ((>= (length mutations) 1)
                                                           (progn
                                                             (let ((mutation-line-list nil)
                                                                   (mutation-prompt-list)
                                                                   (mutation-list (copy-list mutations)))

                                                               (setf mutation-line-list (loop for mutation-id in mutation-list
                                                                                              for mutation = (get-ability-type-by-id mutation-id)
                                                                                              collect (format nil "~A" (name mutation))))
                                                               
                                                               ;; populate the ability prompt list
                                                               (setf mutation-prompt-list (loop for mutation-id in mutation-list
                                                                                                collect #'(lambda (cur-sel)
                                                                                                            (declare (ignore cur-sel))
                                                                                                            "[Enter] Cure  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a mutation to cure:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
                                                                                                                     (mob-invoke-ability *player* (nth cur-sel mutation-list) ability-type-id)
                                                                                                                     (setf *current-window* (return-to (return-to (return-to *current-window*))))
                                                                                                                     (make-output *current-window*)
                                                                                                                     (setf exit-result t))
                                                                                                     :line-list mutation-line-list
                                                                                                     :prompt-list mutation-prompt-list))
                                                               (make-output *current-window*)
                                                               (run-window *current-window*))
                                                             exit-result)
                                                           )
                                                          (t
                                                           (progn
                                                             nil)))))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-thick-carapace+ :name "Grow thick carapace" :descr "Evolve to further increase your carapace thickness. The evolution process takes 10 turns. Thick carapace gives 1 point of direct resistance against flesh, iron, fire, vorpal and acid damage. The thick carapace is mutually exclusive with the metabolic boost, retracting spines and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-thick-carapace+ "grows an even thicker carapace"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-thick-carapace+)
                                                               (mob-ability-p actor +mob-abil-chitinous-plating+)
                                                               (not (mob-ability-p actor +mob-abil-thick-carapace+))
                                                               (not (mob-ability-p actor +mob-abil-metabolic-boost+))
                                                               (not (mob-ability-p actor +mob-abil-retracting-spines+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-thick-carapace+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-thick-carapace+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-thick-carapace+ :name "Thick carapace" :descr "Your carapace is thicker than usual which gives you 1 point of direct resistance against flesh, iron, fire, vorpal and acid damage." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil
                                 :on-add-mutation #'(lambda (ability-type actor)
                                                      (declare (ignore ability-type))
                                                      (adjust-armor actor)
                                                      )
                                 :on-remove-mutation #'(lambda (ability-type actor)
                                                         (declare (ignore ability-type))
                                                         (adjust-armor actor)
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-acidic-tips+ :name "Grow acidic tips" :descr "Evolve to give your retracting spines an acidic tip. The evolution process takes 10 turns. The spines will deal 1-3 acid (instead of flesh) damage. Acidic tips are mutually exclusive with the metabolic boost, chitinous plating and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-acidic-tips+ "now secretes acid at the tips of its spines"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-acidic-tips+)
                                                               (not (mob-ability-p actor +mob-abil-chitinous-plating+))
                                                               (not (mob-ability-p actor +mob-abil-thick-carapace+))
                                                               (not (mob-ability-p actor +mob-abil-metabolic-boost+))
                                                               (mob-ability-p actor +mob-abil-retracting-spines+)
                                                               (not (mob-ability-p actor +mob-abil-acidic-tips+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-acidic-tips+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-acidic-tips+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-acidic-tips+ :name "Acidic tips" :descr "Your retracting spines have an acidic tip which makes them deal 1-3 acid (instead of flesh) damage." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-jump+ :name "Grow extensor muscles" :descr "Evolve to grant your extensor muscles extra force thus letting you jump. The evolution process takes 10 turns. Jumping is mutually exclusive with the retracting spines, chitinous plating and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-jump+ "can now jump"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-jump+)
                                                               (not (mob-ability-p actor +mob-abil-chitinous-plating+))
                                                               (not (mob-ability-p actor +mob-abil-thick-carapace+))
                                                               (mob-ability-p actor +mob-abil-metabolic-boost+)
                                                               (not (mob-ability-p actor +mob-abil-jump+))
                                                               (not (mob-ability-p actor +mob-abil-retracting-spines+))
                                                               (not (mob-ability-p actor +mob-abil-acidic-tips+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-jump+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-jump+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-piercing-needles+ :name "Grow piercing needles" :descr "Evolve to give your tentacles tiny needles that stick into the constricted target and decrease its dodge chance by 40%. The evolution process takes 10 turns. The piercing needles are mutually exclusive with the acid spit, corrosive sacs and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-piercing-needles+ "grows tiny needles on its tentacles"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-piercing-needles+)
                                                               (not (mob-ability-p actor +mob-abil-acid-spit+))
                                                               (not (mob-ability-p actor +mob-abil-corrosive-bile+))
                                                               (mob-ability-p actor +mob-abil-clawed-tentacle+)
                                                               (not (mob-ability-p actor +mob-abil-piercing-needles+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-piercing-needles+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-piercing-needles+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-piercing-needles+ :name "Piercing needles" :descr "Your tentacles have tiny needles that stick into the constricted target and decrease its dodge chance by 40%." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-corroding-secretion+ :name "Increase acid strength" :descr "Evolve to make you acid spit corrode its target reducing its direct resistance against acid and flesh damage by 1. The evolution process takes 10 turns. Increased acid strength is mutually exclusive with the clawed tentacles, corrosive sacs and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-corroding-secretion+ "now has increased acid strength"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-corroding-secretion+)
                                                               (mob-ability-p actor +mob-abil-acid-spit+)
                                                               (not (mob-ability-p actor +mob-abil-corroding-secretion+))
                                                               (not (mob-ability-p actor +mob-abil-corrosive-bile+))
                                                               (not (mob-ability-p actor +mob-abil-clawed-tentacle+))
                                                               (not (mob-ability-p actor +mob-abil-piercing-needles+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-corroding-secretion+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-corroding-secretion+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-corroding-secretion+ :name "Corroding secretion" :descr "Your acid spit corrodes the target, decreasing its direct resistance against flesh and acid damage by 1." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil
                                 :on-add-mutation #'(lambda (ability-type actor)
                                                      (declare (ignore ability-type))
                                                      (when (and (mob-ability-p actor +mob-abil-corroding-secretion+)
                                                                 (mob-ability-p actor +mob-abil-acid-spit+))
                                                        (setf (weapon actor) (list "Tentacles & Acid spit"
                                                                                   (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts))
                                                                                   (list +weapon-dmg-acid+ 1 3 +normal-ap+ 1 0 1 100 "spits at" (list :no-charges :corrodes))))
                                                        (adjust-r-acc actor)
                                                        )
                                                      )
                                 :on-remove-mutation #'(lambda (ability-type actor)
                                                         (declare (ignore ability-type))
                                                         (setf (weapon actor) (list "Tentacles & Acid spit"
                                                                                    (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts))
                                                                                    (list +weapon-dmg-acid+ 1 3 +normal-ap+ 1 0 1 100 "spits at" (list :no-charges))))
                                                         (adjust-r-acc actor)
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-accurate-bile+ :name "Increase cerebellum" :descr "Evolve to give your corrosive bile increased accuracy so that it always lands to the destination tile. The evolution process takes 10 turns. Increased cerebellum is mutually exclusive with the clawed tentacles, acid spit and their upgrades." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 10 :param1 (list +mob-abil-accurate-bile+ "grows increased cerebellum"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-accurate-bile+)
                                                               (not (mob-ability-p actor +mob-abil-acid-spit+))
                                                               (not (mob-ability-p actor +mob-abil-corroding-secretion+))
                                                               (mob-ability-p actor +mob-abil-corrosive-bile+)
                                                               (not (mob-ability-p actor +mob-abil-accurate-bile+))
                                                               (not (mob-ability-p actor +mob-abil-clawed-tentacle+))
                                                               (not (mob-ability-p actor +mob-abil-piercing-needles+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-accurate-bile+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-accurate-bile+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-accurate-bile+ :name "Increased cerebellum" :descr "Your corrosive bile always lands to the destination tile, without any deviations." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-hooks-and-suckers+ :name "Grow hooks & sucker cups" :descr "Evolve to give your tentacles hooks and sucker cups which lets you climb walls. The evolution process takes 20 turns." 
                                 :cost 2 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-climbing+ "can now climb walls"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-hooks-and-suckers+)
                                                               (not (mob-ability-p actor +mob-abil-climbing+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-hooks-and-suckers+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-hooks-and-suckers+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-disguise-as-human+ :name "Morph facade readjustment" :descr "Evolve to give yourself an ability to disguise as a human at will. The evolution process takes 20 turns. Requires the hooks & sucker cups mutation." 
                                 :cost 4 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-disguise-as-human+ "can now disguise itself as a human"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-disguise-as-human+)
                                                               (mob-ability-p actor +mob-abil-climbing+)
                                                               (not (mob-ability-p actor +mob-abil-disguise-as-human+))
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-disguise-as-human+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-disguise-as-human+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-disguise-as-human+ :name "Disguise as a human" :descr "Disguise yourself as a human." 
                                 :cost 0 :cd 10 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 25
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (invoke-disguise actor)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (not (mob-effect-p actor +mob-effect-disguised+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  ;; if the dst is more than 3 tiles away - stealth, if possible
                                                  (if (and (path actor)
                                                           (> (length (path actor)) 3)
                                                           (mob-ability-p actor +mob-abil-disguise-as-human+)
                                                           (can-invoke-ability actor actor +mob-abil-disguise-as-human+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-spawn-larva+ :name "Grow larva spawning sacs" :descr "Evolve to let your ovipositor spawn seeker larvae. The evolution process takes 20 turns. Larvae are small fragile creatures that can not defend themselves but will eat corpses and collect power to you." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-spawn-larva+ "grows larva spawning sacs"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-spawn-larva+)
                                                               (not (mob-ability-p actor +mob-abil-spawn-larva+))
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-spawn-larva+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-spawn-larva+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-spawn-larva+ :name "Spawn a larva egg" :descr "Start the egg laying process. 1 egg become ready to use in 6 turns and can later quickly develop into a larva. A larva has 6 HP, can not attack and collects power from the corpses for you." 
                                 :cost 2 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-laying-eggs+ :actor-id (id actor) :cd 6
                                                                      :param1 #'(lambda ()
                                                                                  (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-larva-egg+ :x (x actor) :y (y actor) :z (z actor) :qty 1)
                                                                                                 :spd nil :silent t)
                                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                         (format nil "A larva egg has finished growing inside ~A. "
                                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "Larva eggs start to grow inside ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-spawn-larva+)
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-laying-eggs+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-enemy nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-spawn-larva+)
                                                           (can-invoke-ability actor actor +mob-abil-spawn-larva+)
                                                           (< (loop for item in (get-inv-items-by-type (inv actor) +item-type-eater-larva-egg+)
                                                                    sum (qty item))
                                                              1))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-spore-colony+ :name "Grow spore colony eggcells" :descr "Evolve to let your ovipositor spawn spore colonies. The evolution process takes 20 turns. Spore colonies are immobile mindless creature that spit acid at enemies in their sight." 
                                 :cost 4 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-spore-colony+ "grows spore colony eggcells"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-mutate-spore-colony+)
                                                               (not (mob-ability-p actor +mob-abil-spore-colony+))
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-evolving+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-spore-colony+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-spore-colony+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-spore-colony+ :name "Spawn a spore colony egg" :descr "Start the egg laying process. 1 egg become ready to use in 12 turns and can later quickly develop into a spore colony. Spore colonies are immobile mindless creatures that flouresce and spit for 1-4 acid damage at any enemy of the primordials in its sight." 
                                 :cost 4 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 100
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-laying-eggs+ :actor-id (id actor) :cd 12
                                                                      :param1 #'(lambda ()
                                                                                  (mob-pick-item actor (make-instance 'item :item-type +item-type-eater-colony-egg+ :x (x actor) :y (y actor) :z (z actor) :qty 1)
                                                                                                 :spd nil :silent t)
                                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                                         (format nil "A spore colony egg has finished growing inside ~A. "
                                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor)))))
                                                                                  :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "Spore colony eggs start to grow inside ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-spore-colony+)
                                                               (mob-ability-p actor +mob-abil-oviposit+)
                                                               (not (mob-effect-p actor +mob-effect-laying-eggs+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (mob-ability-p actor +mob-abil-spore-colony+)
                                                           (can-invoke-ability actor actor +mob-abil-spore-colony+)
                                                           (not nearest-enemy)
                                                           (< (loop for item in (get-inv-items-by-type (inv actor) +item-type-eater-colony-egg+)
                                                                    sum (qty item))
                                                              1))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-immobile+ :name "Immobile" :descr "You are unable to move around." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-float+ :name "Floating" :descr "You float in the air and do not take any damage when falling down from any height. You do not generate any sounds or footprints while moving. Does not work when you possess a corporeal body." 
                                 :passive t :cost 0 :spd 0
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-ghost-possess+ :name "Possess" :descr "You are able to possess humans or corpses from a distance. Note that you can attempt to possess anybody but the ability will fail on inappropriate targets. You can not possess a blessed or divine shielded character. While in possession of a host, you wear its body as your own, gaining all its abilities and HP as the result. When your host dies, you emerge from the body unscathed (except for cases when an angel kills your zombie host - you will burn together with your body). You can attempt to possess another host while already wearing one but this will lead to releasing control of the first host." 
                                 :cd 8 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-ghost-possess
                                 :on-invoke #'(lambda (ability-type actor target)
                                                ;; target is either item or mob
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-GHOST-POSSESS: ~A [~A] uses ranged possession on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (cond
                                                  ;; you failed to possess a blessed target
                                                  ((and (subtypep (type-of target) 'mob)
                                                        (mob-ability-p target +mob-abil-possessable+)
                                                        (null (master-mob-id target))
                                                        (mob-effect-p target +mob-effect-blessed+))
                                                   (progn
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A tries to possess ~A, but the blessing protects from it. "
                                                                                    (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                    (prepend-article +article-the+ (visible-name target)))
                                                                            :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                     ))
                                                   ;; you failed to possess a divine protected target
                                                  ((and (subtypep (type-of target) 'mob)
                                                        (mob-ability-p target +mob-abil-possessable+)
                                                        (null (master-mob-id target))
                                                        (mob-effect-p target +mob-effect-divine-shield+))
                                                   (progn
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A tries to possess ~A, but the divine shield protects from it. "
                                                                                    (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                    (prepend-article +article-the+ (visible-name target)))
                                                                            :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                     ))
                                                   ;; you can not possess the target for any other reason
                                                  ((and (subtypep (type-of target) 'mob)
                                                        (not (and (mob-ability-p target +mob-abil-possessable+)
                                                                  (null (master-mob-id target))
                                                                  (not (mob-effect-p target +mob-effect-blessed+))
                                                                  (not (mob-effect-p target +mob-effect-divine-shield+))))
                                                        )
                                                   (progn
                                                     (if (or (mob-effect-p target +mob-effect-divine-concealed+)
                                                             (and (mob-effect-p target +mob-effect-possessed+)
                                                                  (not (mob-effect-p target +mob-effect-reveal-true-form+))))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A tries to possess ~A, but suddenly reveals its true form. "
                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                        (prepend-article +article-the+ (visible-name target)))
                                                                                :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                         
                                                         (rem-mob-effect target +mob-effect-divine-concealed+)
                                                         (set-mob-effect target :effect-type-id +mob-effect-reveal-true-form+ :actor-id (id actor) :cd 5)
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "It is ~A. " (prepend-article +article-the+ (get-qualified-name target)))
                                                                                :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A tries to possess ~A, but fails. "
                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                        (prepend-article +article-the+ (visible-name target)))
                                                                                :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))))
                                                  (t
                                                   (progn
                                                      ;; remove invisibility
                                                     (when (mob-effect-p actor +mob-effect-invisibility+)
                                                       (rem-mob-effect actor +mob-effect-invisibility+))

                                                     ;; you depossess your currently possessed body
                                                     (when (slave-mob-id actor)
                                                       (let ((slave-mob (get-mob-by-id (slave-mob-id actor))))
                                                         (cond
                                                           ((mob-ability-p slave-mob +mob-abil-undead+)
                                                            (progn
                                                              (rem-mob-effect actor +mob-effect-life-guard+)
                                                              (mob-depossess-target actor)
                                                              (mob-transfer-effects actor slave-mob)
                                                              (setf (cur-hp slave-mob) 0)
                                                              (make-dead slave-mob :splatter nil)
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A slumps to the ground. " (capitalize-name (prepend-article +article-the+ (name slave-mob))))
                                                                                     :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                           (t
                                                            (progn
                                                              (rem-mob-effect actor +mob-effect-life-guard+)
                                                              (mob-depossess-target actor)
                                                              (mob-transfer-effects actor slave-mob)
                                                              )))))

                                                     (cond
                                                       ((subtypep (type-of target) 'mob)
                                                        (progn
                                                          (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                 (format nil "~A possesses ~A. " (capitalize-name (prepend-article +article-the+ (name actor))) (prepend-article +article-the+ (visible-name target)))
                                                                                 :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                          (mob-possess-target actor target)
                                                          (mob-transfer-effects target actor)
                                                          (set-mob-effect actor :effect-type-id +mob-effect-life-guard+ :actor-id (id actor) :cd t)
                                                          ))
                                                       ((subtypep (type-of target) 'item)
                                                        (progn
                                                          (let ((mob-corpse-type) (mob-corpse))
                                                            (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A possesses ~A. "
                                                                                                                                         (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                                                         (prepend-article +article-the+ (visible-name target)))
                                                                                   :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                            (cond
                                                              ((eq (item-ability-p target +item-abil-corpse+) 1) (setf mob-corpse-type +mob-type-reanimated-pwr-1+))
                                                              ((eq (item-ability-p target +item-abil-corpse+) 2) (setf mob-corpse-type +mob-type-reanimated-pwr-2+))
                                                              ((eq (item-ability-p target +item-abil-corpse+) 3) (setf mob-corpse-type +mob-type-reanimated-pwr-3+))
                                                              (t (setf mob-corpse-type +mob-type-reanimated-pwr-4+)))
                                                            (setf mob-corpse (make-instance 'mob :mob-type mob-corpse-type :x (x target) :y (y target) :z (z target)))
                                                            (setf (name mob-corpse) (format nil "reanimated ~A" (name target)))
                                                            (setf (alive-name mob-corpse) (alive-name target))
                                                            (add-mob-to-level-list (level *world*) mob-corpse)
                                                            (remove-item-from-level-list (level *world*) target)
                                                            (print-visible-message (x mob-corpse) (y mob-corpse) (z mob-corpse) (level *world*) (format nil "~A starts to move. "
                                                                                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                                   :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                            (remove-item-from-world target)
                                                            (decf (stat-raised-dead actor))
                                                            
                                                            (mob-possess-target actor mob-corpse)
                                                            (set-mob-effect actor :effect-type-id +mob-effect-life-guard+ :actor-id (id actor) :cd t)
                                                            (incf (stat-possess actor))
                                                            )))
                                                       )
                                                     )))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-ghost-possess+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  ;; a little bit of cheating here
                                                  (let ((corpse-items (loop for item-id in (visible-items actor)
                                                                            for item = (get-item-by-id item-id)
                                                                            when (and (item-ability-p item +item-abil-corpse+)
                                                                                      (not (get-mob-* (level *world*) (x item) (y item) (z item))))
                                                                              collect item))
                                                        (final-result nil))
                                                    (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                             (or (null (slave-mob-id actor))
                                                                 (and nearest-enemy
                                                                      (mob-ability-p nearest-enemy +mob-abil-angel+)
                                                                      (mob-ability-p actor +mob-abil-undead+)
                                                                      (< (/ (cur-hp actor) (max-hp actor)) 
                                                                         0.4)))
                                                             (or (and nearest-enemy
                                                                      (mob-ability-p nearest-enemy +mob-abil-possessable+)
                                                                      (null (master-mob-id nearest-enemy))
                                                                      (setf final-result nearest-enemy))
                                                                 (and corpse-items
                                                                      (setf final-result (first corpse-items)))))
                                                      final-result
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (items (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (exit-result nil))

                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (item-ability-p (get-item-by-id a) +item-abil-corpse+)
                                                                                     nil
                                                                                     t))
                                                                               items))
                                                        (cond
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (or (null mob)
                                                                    (eq mob *player*))
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
                                                                                                        "[Enter] Possess  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a body part to possess:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
                                                                                                                     (mob-invoke-ability *player* (get-inv-item-by-pos item-list cur-sel) ability-type-id)
                                                                                                                     (setf *current-window* (return-to (return-to (return-to *current-window*))))
                                                                                                                     (make-output *current-window*)
                                                                                                                     (setf exit-result t))
                                                                                                     :line-list item-line-list
                                                                                                     :prompt-list item-prompt-list))
                                                               (make-output *current-window*)
                                                               (run-window *current-window*))
                                                             exit-result)
                                                           )
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (or (null mob)
                                                                    (eq mob *player*))
                                                                (= (length items) 1))
                                                           (progn
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                             t))
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                mob
                                                                (not (eq *player* mob))
                                                                (find (id mob) (visible-mobs *player*)))
                                                           (progn
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* mob ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil)))
                                                        )
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-invisibility+ :name "Invisibility" :descr "Make yourself invisible to enemy's eyes." 
                                 :cd 20 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 0
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type target))
                                                (set-mob-effect actor :effect-type-id +mob-effect-invisibility+ :actor-id (id actor) :cd 6)
                                                (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                           (format nil "You hear some strange noise~A. " str)))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-invisibility+))
                                                               (not (mob-effect-p actor +mob-effect-silence+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  ;; if the dst is more than 3 tiles away - stealth, if possible
                                                  (if (and (path actor)
                                                           nearest-enemy
                                                           (= (cur-hp actor) 1)
                                                           (mob-ability-p actor +mob-abil-invisibility+)
                                                           (can-invoke-ability actor actor +mob-abil-invisibility+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-passwall+ :name "Passwall" :descr "Pass through a row of solid, normally impassable terrain tiles. You must be next to such tile, your location relative to this tile sets the direction of your movement during passwall. You emerge on the other side of the tile row. You are also able to pass up and down through floors and ceilings. If you will not be able to emerge from the given tile row (for any reason), you will not be able to invoke the ability." 
                                 :cd 6 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is list of (x y z) coordinates for the tile which is the first in the row of passwalled tiles
                                                (let* ((dx (- (first target) (x actor)))
                                                       (dy (- (second target) (y actor)))
                                                       (dz (- (third target) (z actor)))
                                                       (passwall-result (mob-move-passwall actor dx dy dz)))
                                                  (when passwall-result
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                           (format nil "~A merges into the ~A. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (get-terrain-name (get-terrain-* (level *world*) (first target) (second target) (third target))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    (set-mob-location actor (first passwall-result) (second passwall-result) (third passwall-result))
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                           (format nil "~A emerges from the ~A. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (get-terrain-name (get-terrain-* (level *world*) (- (x actor) dx) (- (y actor) dy) (- (z actor) dz))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    ))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-passwall+)
                                                               (not (slave-mob-id actor))
                                                               (let ((solid-tile nil))
                                                                 (loop for dx from -1 to 1 do
                                                                   (loop for dy from -1 to 1 do
                                                                     (loop for dz from -1 to 1 do
                                                                       (when (and (>= (+ (x actor) dx) 0) (< (+ (x actor) dx) (array-dimension (terrain (level *world*)) 0))
                                                                                  (>= (+ (y actor) dy) 0) (< (+ (y actor) dy) (array-dimension (terrain (level *world*)) 1))
                                                                                  (>= (+ (z actor) dz) 0) (< (+ (z actor) dz) (array-dimension (terrain (level *world*)) 2))
                                                                                  (get-terrain-* (level *world*) (+ (x actor) dx) (+ (y actor) dy) (+ (z actor) dz))
                                                                                  (get-terrain-type-trait (get-terrain-* (level *world*) (+ (x actor) dx) (+ (y actor) dy) (+ (z actor) dz)) +terrain-trait-blocks-move+))
                                                                         (setf solid-tile t)))))
                                                                 solid-tile))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((step-x 0)
                                                        (step-y 0))
                                                    (if (and (mob-ability-p actor +mob-abil-passwall+)
                                                             (can-invoke-ability actor actor +mob-abil-passwall+)
                                                             nearest-enemy
                                                             (setf step-x (cond
                                                                            ((> (x nearest-enemy) (x actor)) -1)
                                                                            ((< (x nearest-enemy) (x actor)) 1)
                                                                            (t 0)))
                                                             (setf step-y (cond
                                                                            ((> (y nearest-enemy) (y actor)) -1)
                                                                            ((< (y nearest-enemy) (y actor)) 1)
                                                                            (t 0)))
                                                             (get-terrain-* (level *world*) (+ (x actor) step-x) (+ (y actor) step-y) (z actor))
                                                             (get-terrain-type-trait (get-terrain-* (level *world*) (+ (x actor) step-x) (+ (y actor) step-y) (z actor)) +terrain-trait-blocks-move+)
                                                             (mob-move-passwall actor step-x step-y 0)
                                                             )
                                                      (list (+ (x actor) step-x) (+ (y actor) step-y) (z actor))
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((terrain (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (< (get-distance-3d (view-x *player*) (view-y *player*) (view-z *player*) (x *player*) (y *player*) (z *player*)) 2)
                                                                 terrain
                                                                 (or (get-terrain-type-trait terrain +terrain-trait-blocks-move+)
                                                                     (and (/= (- (view-z *player*) (z *player*)) 0)
                                                                          (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)))
                                                                 (mob-move-passwall *player* (- (view-x *player*) (x *player*)) (- (view-y *player*) (y *player*)) (- (view-z *player*) (z *player*))))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-ghost-release+ :name "Release host" :descr "Release your control of your host. Undead host slump back to the ground while alive hosts are released unharmed. Note that the inventory of remains with the host." 
                                 :cd 0 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-self
                                 :on-invoke #'(lambda (ability-type actor target)
                                                ;; target is (x y z) coordinates of where the ghost will be placed
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-GHOST-RELEASE: ~A [~A] releases host ~A [~A].~%" (name actor) (id actor)
                                                                (name (get-mob-by-id (slave-mob-id actor))) (id (get-mob-by-id (slave-mob-id actor)))))

                                                ;; you depossess your currently possessed body
                                                (let ((slave-mob (get-mob-by-id (slave-mob-id actor))))
                                                  (cond
                                                    ((mob-ability-p slave-mob +mob-abil-undead+)
                                                     (progn
                                                       (rem-mob-effect actor +mob-effect-life-guard+)
                                                       (mob-depossess-target actor)
                                                       (mob-transfer-effects actor slave-mob)
                                                       (setf (cur-hp slave-mob) 0)
                                                       (make-dead slave-mob :splatter nil)
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                              (format nil "~A slumps to the ground. " (capitalize-name (prepend-article +article-the+ (name slave-mob))))
                                                                              :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                       (set-mob-location actor (first target) (second target) (third target))))
                                                    (t
                                                     (progn
                                                       (rem-mob-effect actor +mob-effect-life-guard+)
                                                       (mob-depossess-target actor)
                                                       (mob-transfer-effects actor slave-mob)
                                                       (set-mob-location actor (first target) (second target) (third target))
                                                       (set-mob-location slave-mob (x slave-mob) (y slave-mob) (z slave-mob))
                                                       (setf (brightness slave-mob) (brightness actor))
                                                       )))
                                                    
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-ghost-release+)
                                                               (slave-mob-id actor))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore actor nearest-ally ability-type nearest-enemy))
                                                  ;; a little bit of cheating here
                                                  nil)
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy check-result))
                                                   (mob-invoke-ability actor nil (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (< (get-distance-3d (view-x *player*) (view-y *player*) (view-z *player*) (x *player*) (y *player*) (z *player*)) 2)
                                                               (check-move-on-level *player* (view-x *player*) (view-y *player*) (view-z *player*))
                                                               (not (and (not (mob-ability-p *player* +mob-abil-undead+))
                                                                         (= (get-distance-3d (view-x *player*) (view-y *player*) (view-z *player*) (x *player*) (y *player*) (z *player*)) 0))))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                            t)
                                                          (progn
                                                            nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-decipher-rune+ :name "Decipher rune" :descr "Study a demonic rune and learn its meaning. You must stand next to a rune to study it." 
                                 :cost 0 :spd (* +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 60
                                 :start-map-select-func #'player-start-map-select-rune
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target here is a feature (demonic rune) to be deciphered
                                                (log:info (format nil "MOB-DECIPHER-RUNE: ~A [~A] deciphers ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor)
                                                                (name target) (id target) (x target) (y target) (z target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) (format nil "~A deciphers ~A. "
                                                                                                                             (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                                                             (prepend-article +article-a+ (name target)))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (mob-pick-item actor (make-instance 'item :item-type (get-feature-type-trait target +feature-trait-demonic-rune+) :x (x actor) :y (y actor) :z (z actor) :qty 1)
                                                               :spd nil :silent t)
                                                (remove-feature-from-level-list (level *world*) target)
                                                (remove-feature-from-world target)
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (let ((rune nil))
                                                        (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                        (loop for feature-id in (get-features-* (level *world*) dx dy (z actor))
                                                                                                              for feature = (get-feature-by-id feature-id)
                                                                                                              when (get-feature-type-trait feature +feature-trait-demonic-rune+)
                                                                                                                do
                                                                                                                   (setf rune feature)
                                                                                                                   (loop-finish))))
                                                        (if (and (mob-ability-p actor +mob-abil-decipher-rune+)
                                                                 rune
                                                                 )
                                                          t
                                                          nil))
                                                      )
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((rune nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (loop for feature-id in (get-features-* (level *world*) dx dy (z actor))
                                                                                                          for feature = (get-feature-by-id feature-id)
                                                                                                          when (get-feature-type-trait feature +feature-trait-demonic-rune+)
                                                                                                            do
                                                                                                               (setf rune feature)
                                                                                                               (loop-finish))))
                                                    (if (and (mob-ability-p actor +mob-abil-decipher-rune+)
                                                             (can-invoke-ability actor actor +mob-abil-decipher-rune+)
                                                             (not nearest-enemy)
                                                             rune
                                                             )
                                                      rune
                                                      nil)))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally nearest-enemy))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((features (remove-if #'(lambda (a)
                                                                                     (if (get-feature-type-trait (get-feature-by-id a) +feature-trait-demonic-rune+)
                                                                                       nil
                                                                                       t))
                                                                                 (get-features-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                            (exit-result nil))

                                                        (cond
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (= (view-z *player*) (z *player*))
                                                                (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                (> (length features) 1))
                                                           (progn
                                                             (let ((feature-line-list nil)
                                                                   (feature-prompt-list)
                                                                   (feature-list (copy-list features)))

                                                               (setf feature-line-list (loop for feature-id in feature-list
                                                                                             for feature = (get-feature-by-id feature-id)
                                                                                             collect (format nil "~A"
                                                                                                             (capitalize-name (name feature)))))
                                                               ;; populate the ability prompt list
                                                               (setf feature-prompt-list (loop for feature-id in feature-list
                                                                                               collect #'(lambda (cur-sel)
                                                                                                           (declare (ignore cur-sel))
                                                                                                           "[Enter] Decipher  [Escape] Cancel")))
                                                               
                                                               ;; show selection window
                                                               (setf *current-window* (make-instance 'select-obj-window 
                                                                                                     :return-to *current-window* 
                                                                                                     :header-line "Choose a demonic rune to decipher:"
                                                                                                     :enter-func #'(lambda (cur-sel)
                                                                                                                     (clear-message-list (level/small-message-box (level *world*)))
                                                                                                                     (mob-invoke-ability *player* (get-feature-by-id (nth cur-sel feature-list)) ability-type-id)
                                                                                                                     (setf *current-window* (return-to (return-to (return-to *current-window*))))
                                                                                                                     (make-output *current-window*)
                                                                                                                     (setf exit-result t))
                                                                                                     :line-list feature-line-list
                                                                                                     :prompt-list feature-prompt-list))
                                                               (make-output *current-window*)
                                                               (run-window *current-window*))
                                                             exit-result)
                                                           )
                                                          ((and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                (= (view-z *player*) (z *player*))
                                                                (< (get-distance (view-x *player*) (view-y *player*) (x *player*) (y *player*)) 2)
                                                                (= (length features) 1))
                                                           (progn
                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                             (mob-invoke-ability *player* (get-feature-by-id (first features)) ability-type-id)
                                                             t))
                                                          (t
                                                           (progn
                                                             nil)))
                                                        
                                                        )
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-flesh+ :name "Demon word: Flesh" :descr "Complete the demon invitation process and turn a zombie into an imp. Available only if you have deciphered demon runes Un and Ged." 
                                 :cd 10 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-empower-undead
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-FLESH: ~A [~A] uses demon word flesh on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))
                                                ;; if used on a ghost the ability will fail
                                                (if (mob-ability-p target +mob-abil-ghost-possess+)
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A pronounces Demon word: Flesh, but nothing happens. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A pronounces Demon word: Flesh and ~A turns into an imp. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    
                                                    (when (mob-effect-p target +mob-effect-empowered-undead+)
                                                      (rem-mob-effect target +mob-effect-empowered-undead+))
                                                    
                                                    (let ((old-max-hp (max-hp target)))
                                                      (setf (mob-type target) +mob-type-imp+)
                                                      (setf (max-hp target) (max-hp (get-mob-type-by-id (mob-type target))))
                                                      (setf (cur-hp target) (round (* (cur-hp target) (max-hp target)) old-max-hp)))
                                                    (setf (face-mob-type-id target) (mob-type target))
                                                    (setf (name target) nil)
                                                    (set-name target)
                                                    (set-cur-weapons target)
                                                    (adjust-abilities target)
                                                    (adjust-dodge target)
                                                    (adjust-armor target)
                                                    (adjust-m-acc target)
                                                    (adjust-r-acc target)
                                                    (adjust-sight target)
                                                    
                                                    ;; set up current abilities cooldowns
                                                    (loop for ability-id being the hash-key in (abilities target)
                                                          when (null (gethash ability-id (abilities-cd target)))
                                                            do
                                                               (setf (gethash ability-id (abilities-cd target)) 0))
                                                    ))
                                                         
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-flesh+)
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-flesh+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-invite+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy))
                                                  ;; a little bit of cheating here
                                                  (if (and (can-invoke-ability actor nearest-ally (id ability-type))
                                                           nearest-ally
                                                           (mob-ability-p nearest-ally +mob-abil-undead+)
                                                           (not (mob-ability-p nearest-ally +mob-abil-ghost-possess+))
                                                           )
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy check-result))
                                                   (mob-invoke-ability actor nearest-ally (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*))
                                                                 (mob-ability-p mob +mob-abil-undead+))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-soul+ :name "Soul" :descr "You have a soul." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil :on-touch nil
                                 :on-invoke nil
                                 :on-check-applic nil))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-plague+ :name "Demon word: Plague" :descr "Infest the target with soul sickness. Soul sickness is a special demon-devised disease that affects only soulful beings (like humans and angels) for 30 turns. Each turn a character affected with soul sickness has a 25% chance to lose 1 HP. However, the disease never takes the last HP. Disease carrier will also infect soulful characters standing nearby. But beware, though you have pledged your service to demons you are still human and can be affected yourself. Available only if you have deciphered demon runes Un and Drux." 
                                 :cd 10 :cost 0 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 10
                                 :start-map-select-func #'player-start-map-select-nearest-hostile
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-PLAGUE: ~A [~A] uses demon word plague on ~A [~A].~%" (name actor) (id actor) (name target) (id target)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))

                                                (if (mob-ability-p target +mob-abil-soul+)
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A pronounces Demon word: Plague. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    (set-mob-effect target :effect-type-id +mob-effect-soul-sickness+ :actor-id (id actor) :cd 30))
                                                  (progn
                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                           (format nil "~A pronounces Demon word: Plague, but ~A is not affected. "
                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                   (prepend-article +article-the+ (visible-name target)))
                                                                           :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-plague+)
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-flesh+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-decay+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-ally))
                                                  ;; a little bit of cheating here
                                                  (if (and (can-invoke-ability actor nearest-enemy (id ability-type))
                                                           nearest-enemy
                                                           (mob-ability-p nearest-enemy +mob-abil-soul+)
                                                           (not (mob-effect-p nearest-enemy +mob-effect-soul-sickness+)))
                                                      t
                                                      nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-ally check-result))
                                                   (mob-invoke-ability actor nearest-enemy (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 mob
                                                                 (not (eq *player* mob))
                                                                 (find (id mob) (visible-mobs *player*)))
                                                          (progn
                                                            (clear-message-list (level/small-message-box (level *world*)))
                                                            (mob-invoke-ability *player* mob ability-type-id)
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-power+ :name "Demon word: Power" :descr "Gain the powers of an Archdemon for 7 turns. Available only if you have deciphered demon runes Un and Med." 
                                 :cd 15 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-POWER: ~A [~A] uses demon word power.~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A pronounces Demon word: Power. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                    
                                                (set-mob-effect actor :effect-type-id +mob-effect-demonic-power+ :actor-id (id actor) :cd 7)
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-power+)
                                                               (not (mob-effect-p actor +mob-effect-demonic-power+))
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-flesh+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-transform+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (> (strength nearest-enemy) 
                                                                       (strength actor)))
                                                               (and nearest-enemy
                                                                    (< (/ (cur-hp actor) (max-hp actor)) 
                                                                       0.3)))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-demon-word-power+)
                                                           (can-invoke-ability actor actor +mob-abil-demon-word-power+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-darkness+ :name "Demon word: Darkness" :descr "Plead to Nephitis to blot out the sun. The sun's power will eventually prevail but while the enchantment lasts everything will be drowned in darkness. Available only if you have deciphered demon runes Gon, Drux and Tal." 
                                 :cd 30 :spd (* +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-DARKNESS: ~A [~A] uses demon word darkness.~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A pronounces Demon word: Darkness. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                (pushnew +game-event-unnatural-darkness+ (game-events (level *world*)))
                                                (add-message "Unnatural darkness falls on the world! " sdl:*magenta*)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-darkness+)
                                                               (not (find +game-event-unnatural-darkness+ (game-events (level *world*))))
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-barrier+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-decay+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-all+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-demon-word-darkness+)
                                                           (can-invoke-ability actor actor +mob-abil-demon-word-darkness+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-invasion+ :name "Demon word: Invasion" :descr "Plead to Yosototh to weaken the barriers between the worlds and let evil spirits reanimate corpses in the city. This enchantment makes corpses reanimate on their own from time to time, without your interference. Available only if you have deciphered demon runes Gon, Ged and Tal." 
                                 :cd 30 :spd (* +normal-ap+ 4) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-INVASION: ~A [~A] uses demon word invasion.~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A pronounces Demon word: Invasion. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                (pushnew +game-event-constant-reanimation+ (game-events (level *world*)))
                                                (add-message "You seem to start hearing whispers from beyond! " sdl:*magenta*)
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-invasion+)
                                                               (not (find +game-event-constant-reanimation+ (game-events (level *world*))))
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-barrier+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-invite+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-all+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-demon-word-invasion+)
                                                           (can-invoke-ability actor actor +mob-abil-demon-word-invasion+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-demon-word-knockback+ :name "Demon word: Knockback" :descr "Push all characters around you away. Available only if you have deciphered demon runes Veh and Med." 
                                 :cd 10 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-DEMON-WORD-KNOCKBACK: ~A [~A] uses demon word knockback.~%" (name actor) (id actor)))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear someone chanting~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A pronounces Demon word: Knockback. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (let ((mobs))
                                                  (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                  (when (get-mob-* (level *world*) dx dy (z actor))
                                                                                                    (pushnew (get-mob-* (level *world*) dx dy (z actor)) mobs))))
                                                  (loop for target in mobs
                                                        for dx = (- (x target) (x actor))
                                                        for dy = (- (y target) (y actor))
                                                        when (eq (check-move-on-level target (+ (x target) dx) (+ (y target) dy) (z target)) t)
                                                          do
                                                             (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                    (format nil "~A is pushed away from ~A. "
                                                                                            (capitalize-name (prepend-article +article-the+ (visible-name target)))
                                                                                            (prepend-article +article-the+ (visible-name actor)))
                                                                                    :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                             (set-mob-location target (+ (x target) dx) (+ (y target) dy) (z target))
                                                        ))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-demon-word-knockback+)
                                                               (not (mob-effect-p actor +mob-effect-silence+))
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-away+)
                                                               (get-inv-items-by-type (inv actor) +item-type-scroll-demonic-rune-transform+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and nearest-enemy
                                                           (mob-ability-p actor +mob-abil-demon-word-knockback+)
                                                           (can-invoke-ability actor actor +mob-abil-demon-word-knockback+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-detect-unnatural+ :name "Detect unnatural" :descr "You can sense the general direction to objects of power, like the sacrificial cirle or the Book of Rituals." 
                                 :passive t :cost 0 :spd 0 
                                 :final nil
                                 ))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-throw-corpse-into-portal+ :name "Throw corpses into portal" :descr "Throw all corpses you have into a demonic portal. You must be standing on top of the demonic portal and have corpses in your inventory to do that. Increases your flesh points that count towards victory during demonic raid." 
                                 :spd (truncate +normal-ap+ 1.5) :passive nil
                                 :final t :on-touch nil
                                 :motion 90
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (let ((corpses-list (loop for item-id in (inv actor)
                                                                          for item = (get-item-by-id item-id)
                                                                          when (item-ability-p item +item-abil-corpse+)
                                                                            collect item))
                                                      (portal (loop for feature-id in (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                    for feature = (get-feature-by-id feature-id)
                                                                    when (= (feature-type feature) +feature-demonic-portal+)
                                                                      do
                                                                         (return feature))))
                                                  (log:info (format nil "MOB-THROW-CORPSE-INTO-PORTAL: ~A [~A] throws the following corpses ~A into portal ~A [~A].~%" (name actor) (id actor)
                                                                  (loop for item in corpses-list
                                                                    collect (format nil "[~A] " (id item)))
                                                                  (name portal)
                                                                  (id portal)))
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                             (format nil "You hear something heavy being moved~A." str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A throws corpses into the demonic portal. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  
                                                  (loop for corpse-item in corpses-list
                                                        for pts = (item-ability-p corpse-item +item-abil-corpse+)
                                                        do
                                                           (if (param1 portal)
                                                             (incf (param1 portal) (* (qty corpse-item) pts))
                                                             (setf (param1 portal) (* (qty corpse-item) pts)))
                                                    
                                                    (incf (stat-corpses-thrown actor) (* (qty corpse-item) pts))
                                                    (when (eq actor *player*)
                                                      (incf (cur-score *player*) (* 3 pts (qty corpse-item))))
                                                    (setf (inv actor) (remove-from-inv corpse-item (inv actor)))
                                                    (remove-item-from-world corpse-item))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-throw-corpse-into-portal+)
                                                               (eql (mission-type-id (mission (level *world*))) :mission-type-demonic-raid)
                                                               (loop for item-id in (inv actor)
                                                                     for item = (get-item-by-id item-id)
                                                                     when (item-ability-p item +item-abil-corpse+)
                                                                       collect item)
                                                               (loop for feature-id in (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                     for feature = (get-feature-by-id feature-id)
                                                                     when (= (feature-type feature) +feature-demonic-portal+)
                                                                       do
                                                                          (return feature)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (eq (mission-type-id (mission (level *world*))) :mission-type-demonic-raid)
                                                           (mob-ability-p actor +mob-abil-throw-corpse-into-portal+)
                                                           (can-invoke-ability actor actor +mob-abil-throw-corpse-into-portal+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-throw-relic-into-portal+ :name "Throw relic into portal" :descr "Throw the relic you have into a demonic portal. You must be standing on top of the demonic portal and have the relic in your inventory to do that. Usable only during the demonic thievery mission." 
                                 :spd (truncate +normal-ap+ 1.5) :passive nil
                                 :final t :on-touch nil
                                 :motion 90
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (let ((relic-list (loop for item-id in (inv actor)
                                                                          for item = (get-item-by-id item-id)
                                                                          when (= (item-type item) +item-type-church-reliс+)
                                                                            collect item))
                                                      (portal (loop for feature-id in (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                    for feature = (get-feature-by-id feature-id)
                                                                    when (= (feature-type feature) +feature-demonic-portal+)
                                                                      do
                                                                         (return feature))))
                                                  (log:info (format nil "MOB-THROW-RELIC-INTO-PORTAL: ~A [~A] throws the relic ~A into portal ~A [~A].~%" (name actor) (id actor)
                                                                  (loop for item in relic-list
                                                                    collect (format nil "[~A] " (id item)))
                                                                  (name portal)
                                                                  (id portal)))
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 100 #'(lambda (str)
                                                                                                             (format nil "You hear some buzzing sound~A." str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A throws the relic into the demonic portal. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  
                                                  (loop for relic-item in relic-list
                                                        do
                                                           (setf (param1 portal) t)
                                                           
                                                           (when (eq actor *player*)
                                                             (incf (cur-score *player*) (* 200 (qty relic-item))))
                                                           (setf (inv actor) (remove-from-inv relic-item (inv actor)))
                                                           (remove-item-from-world relic-item))
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-throw-relic-into-portal+)
                                                               (eql (mission-type-id (mission (level *world*))) :mission-type-demonic-thievery)
                                                               (loop for item-id in (inv actor)
                                                                     for item = (get-item-by-id item-id)
                                                                     when (= (item-type item) +item-type-church-reliс+)
                                                                       collect item)
                                                               (loop for feature-id in (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                     for feature = (get-feature-by-id feature-id)
                                                                     when (= (feature-type feature) +feature-demonic-portal+)
                                                                       do
                                                                          (return feature)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally nearest-enemy))
                                                  (if (and (eq (mission-type-id (mission (level *world*))) :mission-type-demonic-thievery)
                                                           (mob-ability-p actor +mob-abil-throw-relic-into-portal+)
                                                           (can-invoke-ability actor actor +mob-abil-throw-relic-into-portal+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-create-demon-sigil+ :name "Summon demonic sigil" :descr (format nil "Summon a demonic sigil next to you. You can not summon sigils closer than ~A tiles to each other. Usable only during the demonic conquest mission." *demonic-conquest-win-sigils-dist*)
                                 :spd (truncate +normal-ap+ 1.5) :passive nil
                                 :cd 50 :final t :on-touch nil
                                 :motion 100
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                ;; target is (x y z)
                                                (log:info (format nil "MOB-CREATE-DEMON-SIGIL: ~A [~A] spawns a demon sigil at (~A ~A ~A).~%" (name actor) (id actor) (first target) (second target) (third target)))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                       (format nil "~A creates a demonic sigil. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :observed-mob actor
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                           (format nil "You hear otherworldly sounds~A. " str)))
                                                (let ((sigil-mob))
                                                  (setf sigil-mob (make-instance 'mob :mob-type +mob-type-demon-sigil+ :x (first target) :y (second target) :z (third target)))
                                                  (add-mob-to-level-list (level *world*) sigil-mob)
                                                  (set-mob-effect sigil-mob :effect-type-id +mob-effect-demonic-sigil+ :actor-id (id sigil-mob) :cd t))
                                                                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (eql (mission-type-id (mission (level *world*))) :mission-type-demonic-conquest)
                                                               (mob-ability-p actor +mob-abil-create-demon-sigil+)
                                                               (loop with result = t
                                                                     for sigil-id in (demonic-sigils (level *world*))
                                                                     for sigil = (get-mob-by-id sigil-id)
                                                                     when (< (get-distance (x actor) (y actor) (x sigil) (y sigil)) *demonic-conquest-win-sigils-dist*)
                                                                       do
                                                                          (setf result nil)
                                                                          (loop-finish)
                                                                     finally (return result)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (let ((final-cell nil))
                                                    (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                    (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                      (when (and terrain
                                                                                                                 (get-terrain-type-trait terrain +terrain-trait-blocks-move-floor+)
                                                                                                                 (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                 (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                        (when (null final-cell)
                                                                                                          (setf final-cell (list dx dy (z actor))))
                                                                                                        (when (and nearest-enemy
                                                                                                                   (> (get-distance-3d dx dy (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))
                                                                                                                      (get-distance-3d (first final-cell) (second final-cell) (third final-cell)
                                                                                                                                       (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))))
                                                                                                          (setf final-cell (list dx dy (z actor))))))))
                                                    (if (and (mob-ability-p actor +mob-abil-create-demon-sigil+)
                                                             (can-invoke-ability actor actor +mob-abil-create-demon-sigil+)
                                                             final-cell)
                                                    final-cell
                                                    nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                               (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                               (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 2)
                                                               (not (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +terrain-trait-blocks-move+)))
                                                        (progn
                                                          (clear-message-list (level/small-message-box (level *world*)))
                                                          (mob-invoke-ability *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) ability-type-id)
                                                          t)
                                                        (progn
                                                          nil))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-skinchange-to-melee+ :name "Skinchange to Butcher" :descr "Change your skin to become a Butcher. The Butcher is a ferocious melee warrior." 
                                 :cd 15 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-SKINCHANGE-TO-MELEE: ~A [~A] uses skinchange to melee.~%" (name actor) (id actor)))

                                                (let ((old-max-hp (max-hp actor))
                                                      (was-flyer (if (= (mob-type actor) +mob-type-skinchanger-flyer+)
                                                                    t
                                                                    nil)))
                                                  (setf (mob-type actor) +mob-type-skinchanger-melee+)
                                                  (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                  (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
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
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear a sound of flesh tearing~A." str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A turns into a Butcher. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  
                                                  (when (and was-flyer
                                                             (not (mob-effect-p actor +mob-effect-flying+))
                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                             (apply-gravity actor))
                                                    (set-mob-location actor (x actor) (y actor) (z actor)))
                                                  )
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-skinchange-to-melee+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (= (z actor) (z nearest-enemy))
                                                                    (< (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2)))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-skinchange-to-melee+)
                                                           (can-invoke-ability actor actor +mob-abil-skinchange-to-melee+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-skinchange-to-ranged+ :name "Skinchange to Ravager" :descr "Change your skin to become a Ravager. The Ravager is able to attack from afar." 
                                 :cd 15 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-SKINCHANGE-TO-RANGED: ~A [~A] uses skinchange to ranged.~%" (name actor) (id actor)))

                                                (let ((old-max-hp (max-hp actor))
                                                      (was-flyer (if (= (mob-type actor) +mob-type-skinchanger-flyer+)
                                                                    t
                                                                    nil)))
                                                  (setf (mob-type actor) +mob-type-skinchanger-ranged+)
                                                  (setf (max-hp actor) (max-hp (get-mob-type-by-id (mob-type actor))))
                                                  (setf (cur-hp actor) (round (* (cur-hp actor) (max-hp actor)) old-max-hp))
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
                                                  
                                                  (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear a sound of flesh tearing~A." str)))
                                                  
                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                         (format nil "~A turns into a Ravager. "
                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                         :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                  (when (and was-flyer
                                                             (not (mob-effect-p actor +mob-effect-flying+))
                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                             (apply-gravity actor))
                                                    (set-mob-location actor (x actor) (y actor) (z actor)))
                                                )
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-skinchange-to-ranged+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (/= (z actor) (z nearest-enemy)))
                                                               (and nearest-enemy
                                                                    (>= (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2)
                                                                    ))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-skinchange-to-ranged+)
                                                           (can-invoke-ability actor actor +mob-abil-skinchange-to-ranged+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-skinchange-to-flyer+ :name "Skinchange to Corruptor" :descr "Change your skin to become a Corruptor. The Corruptors are able to fly." 
                                 :cd 15 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-SKINCHANGE-TO-FLYER: ~A [~A] uses skinchange to flyer.~%" (name actor) (id actor)))

                                                (let ((old-max-hp (max-hp actor)))
                                                  (setf (mob-type actor) +mob-type-skinchanger-flyer+)
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
                                                                                                
                                                ;; set up current abilities cooldowns
                                                (loop for ability-id in (get-mob-all-abilities actor)
                                                      when (null (gethash ability-id (abilities-cd actor)))
                                                        do
                                                           (setf (gethash ability-id (abilities-cd actor)) 0))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear a sound of flesh tearing~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A turns into a Corruptor. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-skinchange-to-flyer+)
                                                               )
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-skinchange-to-flyer+)
                                                           (can-invoke-ability actor actor +mob-abil-skinchange-to-flyer+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-skin-ranged-to-turret+ :name "Grow roots and spores" :descr "Evolve to give yourself an ability to skinchange into a Spore colony. The evolution process takes 20 turns. The Spore colony is an immobile creature with a strong ranged attack." 
                                 :cost 5 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-skinchange-to-turret+ "grows roots and spores"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-evolving+))
                                                               (not (mob-ability-p actor +mob-abil-skinchange-to-turret+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-skin-ranged-to-turret+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-skin-ranged-to-turret+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-skinchange-to-turret+ :name "Skinchange to Spore colony" :descr "Change your skin to become a Spore colony. The Spore colony is immobile, but has a strong ranged attack." 
                                 :cd 15 :spd (truncate +normal-ap+ 2) :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target ability-type))
                                                (log:info (format nil "MOB-SKIN-TO-TURRET: ~A [~A] uses skinchange to spore colony.~%" (name actor) (id actor)))

                                                (let ((old-max-hp (max-hp actor)))
                                                  (setf (mob-type actor) +mob-type-skinchanger-turret+)
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
                                                                                                
                                                ;; set up current abilities cooldowns
                                                (loop for ability-id in (get-mob-all-abilities actor)
                                                      when (null (gethash ability-id (abilities-cd actor)))
                                                        do
                                                           (setf (gethash ability-id (abilities-cd actor)) 0))

                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                           (format nil "You hear a sound of flesh tearing~A." str)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A turns into a Spore colony. "
                                                                               (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (mob-ability-p actor +mob-abil-skinchange-to-turret+)
                                                               (not (= (mob-type actor) +mob-type-skinchanger-turret+))
                                                               (= (mob-type actor) +mob-type-skinchanger-ranged+))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (or (and nearest-enemy
                                                                    (> (strength nearest-enemy) 
                                                                       (strength actor))
                                                                    (or (/= (z actor) (z nearest-enemy))
                                                                        (>= (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)) 2))))
                                                           (null (riding-mob-id actor))
                                                           (mob-ability-p actor +mob-abil-skinchange-to-turret+)
                                                           (can-invoke-ability actor actor +mob-abil-skinchange-to-turret+))
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-charge+ :name "Grow contracting muscles" :descr "Evolve to give yourself an ability to charge to the enemy. The evolution process takes 20 turns." 
                                 :cost 5 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-charge+ "grows contracting muscles"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-evolving+))
                                                               (not (mob-ability-p actor +mob-abil-charge+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-charge+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-charge+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-explosive-glands+ :name "Grow exploding glands" :descr "Evolve to give yourself an ability to explode corpses for 6-10 acid dmg. The evolution process takes 20 turns." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-explosive-glands+ "grows exploding glands"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-evolving+))
                                                               (not (mob-ability-p actor +mob-abil-explosive-glands+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-explosive-glands+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-explosive-glands+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-explosive-glands+ :name "Spit explosive parasite" :descr "You spit a parasite into a corpse. The parasite explodes the corpse to deal 6-10 acid dmg tp everybody nearby. The ability is only available in the Corruptor skin." 
                                 :cost 0 :cd 7 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-corpse
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-SPIT-EXPLOSIVE-PARASITE: ~A [~A] spits parasite at ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A spits an explosive parasite. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                       (format nil "~A explodes. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (let ((targets nil)
                                                      (max-range 1))
                                                  (draw-fov (x target) (y target) (z target) max-range
                                                            #'(lambda (dx dy dz prev-cell)
                                                                (let ((exit-result t))
                                                                  (block nil
                                                                    (when (> (get-distance-3d (x target) (y target) (z target) dx dy dz) (1+ max-range))
                                                                      (setf exit-result 'exit)
                                                                      (return))
                                                                    
                                                                    (when (eq (check-LOS-propagate dx dy dz prev-cell :check-move t) nil)
                                                                      (setf exit-result 'exit)
                                                                      (return))
                                                                    
                                                                    (place-animation dx dy dz +anim-type-acid-dot+ :params ())
                                                                    
                                                                    (when (and (get-mob-* (level *world*) dx dy dz)) 
                                                                      (pushnew (get-mob-* (level *world*) dx dy dz) targets))
                                                                    )
                                                                  exit-result)))
                                                  
                                                  (loop for target in targets
                                                        for cur-dmg = 0
                                                        do
                                                           (incf cur-dmg (inflict-damage target :min-dmg 6 :max-dmg 10 :dmg-type +weapon-dmg-acid+
                                                                                                :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t :no-hit-message t :no-check-dead t
                                                                                                :actor actor))
                                                           (if (zerop cur-dmg)
                                                             (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                    (format nil "~A is not hurt. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                                    :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                             (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                    (format nil "~A takes ~A damage. " (capitalize-name (prepend-article +article-the+ (visible-name target))) cur-dmg)
                                                                                    :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind))))
                                                           (when (and (not (eq target actor))
                                                                      (check-dead target))
                                                             (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params ())
                                                             
                                                             (when (mob-effect-p target +mob-effect-possessed+)
                                                               (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                               (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                                     (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                                     (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                               (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))))

                                                  (remove-item-from-level-list (level *world*) target)
                                                  (remove-item-from-world target)
                                                  )
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-explosive-glands+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy ability-type nearest-ally))
                                                  (let ((corpse-item (funcall #'(lambda ()
                                                                                  (let ((visible-items (copy-list (visible-items actor)))
                                                                                        (best-item nil))
                                                                                    ;; find all corpses
                                                                                    (setf visible-items (remove-if #'(lambda (a)
                                                                                                                       (if (item-ability-p a +item-abil-corpse+)
                                                                                                                         nil
                                                                                                                         t))
                                                                                                                   visible-items
                                                                                                                   :key #'get-item-by-id))
                                                                                    ;; find corpse with maximum enemies (and not you) near it
                                                                                    (loop for item-id in visible-items
                                                                                          for item = (get-item-by-id item-id)
                                                                                          for mob-count = 0
                                                                                          for found-self = nil
                                                                                          with best-count = 0
                                                                                          do
                                                                                             (check-surroundings (x item) (y item) t #'(lambda (dx dy)
                                                                                                                                         (let ((mob (get-mob-* (level *world*) dx dy (z item))))
                                                                                                                                           (when (and mob
                                                                                                                                                    (find (id mob) (visible-mobs actor))
                                                                                                                                                    (not (get-faction-relation (faction actor) (get-visible-faction mob :viewer actor))))
                                                                                                                                             (incf mob-count))
                                                                                                                                           (when (eq mob actor)
                                                                                                                                             (setf found-self t)))))
                                                                                             (when (and (> mob-count best-count)
                                                                                                        (not found-self))
                                                                                               (setf best-item item)
                                                                                               (setf best-count mob-count)))
                                                                                    best-item)))))
                                                    (if (and (mob-ability-p actor +mob-abil-explosive-glands+)
                                                             (can-invoke-ability actor actor +mob-abil-explosive-glands+)
                                                             corpse-item)
                                                      corpse-item
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((items (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (exit-result nil))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (item-ability-p a +item-abil-corpse+)
                                                                                     nil
                                                                                     t))
                                                                               items
                                                                               :key #'get-item-by-id))
                                                        
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 items
                                                                 (<= (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 8)
                                                                 (let ((tx 0) (ty 0) (tz 0)
                                                                       (ex (view-x *player*)) (ey (view-y *player*)) (ez (view-z *player*)))
                                                                   (declare (type fixnum tx ty tz ex ey ez))
                                                                   (line-of-sight (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)
                                                                                  #'(lambda (dx dy dz prev-cell)
                                                                                      (declare (type fixnum dx dy dz))
                                                                                      (let ((exit-result t))
                                                                                        (block nil
                                                                                          (setf tx dx ty dy tz dz)
                                                                                          
                                                                                          (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                            (setf exit-result 'exit)
                                                                                            (return))
                                                                                          
                                                                                          )
                                                                                        exit-result)))
                                                                   (if (and (= tx ex)
                                                                            (= ty ey)
                                                                            (= tz ez))
                                                                     t
                                                                     nil)))
                                                          
                                                          (progn
                                                            (if (> (length items) 1)
                                                              (progn
                                                                (let ((item-line-list nil)
                                                                      (item-prompt-list)
                                                                      (item-list (copy-list items)))
                                                                  
                                                                  (setf item-line-list (loop for item-id in item-list
                                                                                             for item = (get-item-by-id item-id)
                                                                                             collect (format nil "~A"
                                                                                                              (capitalize-name (prepend-article +article-a+ (visible-name item)))
                                                                                                              )))
                                                                   ;; populate the ability prompt list
                                                                   (setf item-prompt-list (loop for item-id in item-list
                                                                                                collect #'(lambda (cur-sel)
                                                                                                            (declare (ignore cur-sel))
                                                                                                            "[Enter] Explode  [Escape] Cancel")))
                                                                   
                                                                   ;; show selection window
                                                                   (setf *current-window* (make-instance 'select-obj-window 
                                                                                                         :return-to *current-window* 
                                                                                                         :header-line "Choose a body to explode:"
                                                                                                         :enter-func #'(lambda (cur-sel)
                                                                                                                         (clear-message-list (level/small-message-box (level *world*)))
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
                                                              (progn
                                                                 (clear-message-list (level/small-message-box (level *world*)))
                                                                 (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                                 t))
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-mutate-poisoning-glands+ :name "Grow poisoning glands" :descr "Evolve to give yourself an ability to poison corpses. The evolution process takes 20 turns." 
                                 :cost 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil
                                 :motion 50
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore target))
                                                (generate-sound actor (x actor) (y actor) (z actor) 80 #'(lambda (str)
                                                                                                             (format nil "You hear some burping~A. " str)))

                                                (set-mob-effect actor :effect-type-id +mob-effect-evolving+ :actor-id (id actor) :cd 20 :param1 (list +mob-abil-poisoning-glands+ "grows poisoning glands"))
                                                
                                                (decf (cur-fp actor) (cost ability-type))
                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A starts to evolve. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (and (not (mob-effect-p actor +mob-effect-evolving+))
                                                               (not (mob-ability-p actor +mob-abil-poisoning-glands+)))
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore ability-type nearest-ally))
                                                  (if (and (not nearest-enemy)
                                                           (mob-ability-p actor +mob-abil-mutate-poisoning-glands+)
                                                           (can-invoke-ability actor actor +mob-abil-mutate-poisoning-glands+)
                                                           )
                                                    t
                                                    nil))
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally check-result))
                                                   (mob-invoke-ability actor actor (id ability-type)))))

(set-ability-type (make-instance 'ability-type 
                                 :id +mob-abil-poisoning-glands+ :name "Spit poisoning parasite" :descr "You spit a parasite into a corpse. The parasite poisons the corpse and make it emit gas that deals 3-6 acid dmg to that steps into it. The ability is only available in the Corruptor skin." 
                                 :cost 0 :cd 3 :spd +normal-ap+ :passive nil
                                 :final t :on-touch nil :removes-disguise t
                                 :motion 50
                                 :start-map-select-func #'player-start-map-select-corpse
                                 :on-invoke #'(lambda (ability-type actor target)
                                                (declare (ignore ability-type))
                                                (log:info (format nil "MOB-SPIT-POISONING-PARASITE: ~A [~A] spits parasite at ~A [~A] at (~A ~A ~A).~%" (name actor) (id actor) (name target) (id target) (x target) (y target) (z target)))

                                                (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                       (format nil "~A spits a poisoning parasite. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))

                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                       (format nil "~A starts to emit gas. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                       :color sdl:*white*
                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                         :singlemind)))
                                                
                                                (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-smoke-acid-gas+ :x (x target) :y (y target) :z (z target)
                                                                                                                   :counter 10))
                                                )
                                 :on-check-applic #'(lambda (ability-type actor target)
                                                      (declare (ignore ability-type target))
                                                      (if (mob-ability-p actor +mob-abil-poisoning-glands+)
                                                        t
                                                        nil))
                                 :on-check-ai #'(lambda (ability-type actor nearest-enemy nearest-ally)
                                                  (declare (ignore nearest-enemy ability-type nearest-ally))
                                                  (let ((corpse-item (funcall #'(lambda ()
                                                                                  (let ((visible-items (copy-list (visible-items actor)))
                                                                                        (best-item nil))
                                                                                    ;; find all corpses
                                                                                    (setf visible-items (remove-if #'(lambda (a)
                                                                                                                       (if (item-ability-p a +item-abil-corpse+)
                                                                                                                         nil
                                                                                                                         t))
                                                                                                                   visible-items
                                                                                                                   :key #'get-item-by-id))
                                                                                    ;; find corpse with an enemy (and not you) above it
                                                                                    (loop for item-id in visible-items
                                                                                          for item = (get-item-by-id item-id)
                                                                                          for mob = (get-mob-* (level *world*) (x item) (y item) (z item))
                                                                                          for found-self = nil
                                                                                          do
                                                                                             (when (and mob
                                                                                                        (find (id mob) (visible-mobs actor))
                                                                                                        (not (get-faction-relation (faction actor) (get-visible-faction mob :viewer actor)))
                                                                                                        (not (eq mob actor)))
                                                                                               (setf best-item item))
                                                                                             )
                                                                                    best-item)))))
                                                    (if (and (mob-ability-p actor +mob-abil-poisoning-glands+)
                                                             (can-invoke-ability actor actor +mob-abil-poisoning-glands+)
                                                             corpse-item)
                                                      corpse-item
                                                      nil))
                                                  )
                                 :on-invoke-ai #'(lambda (ability-type actor nearest-enemy nearest-ally check-result)
                                                   (declare (ignore nearest-enemy nearest-ally))
                                                   (mob-invoke-ability actor check-result (id ability-type)))
                                 :map-select-func #'(lambda (ability-type-id)
                                                      (let ((items (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                            (exit-result nil))
                                                        (setf items (remove-if #'(lambda (a)
                                                                                   (if (item-ability-p a +item-abil-corpse+)
                                                                                     nil
                                                                                     t))
                                                                               items
                                                                               :key #'get-item-by-id))
                                                        
                                                        (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                 items
                                                                 (<= (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 8)
                                                                 (let ((tx 0) (ty 0) (tz 0)
                                                                       (ex (view-x *player*)) (ey (view-y *player*)) (ez (view-z *player*)))
                                                                   (declare (type fixnum tx ty tz ex ey ez))
                                                                   (line-of-sight (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)
                                                                                  #'(lambda (dx dy dz prev-cell)
                                                                                      (declare (type fixnum dx dy dz))
                                                                                      (let ((exit-result t))
                                                                                        (block nil
                                                                                          (setf tx dx ty dy tz dz)
                                                                                          
                                                                                          (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                            (setf exit-result 'exit)
                                                                                            (return))
                                                                                          
                                                                                          )
                                                                                        exit-result)))
                                                                   (if (and (= tx ex)
                                                                            (= ty ey)
                                                                            (= tz ez))
                                                                     t
                                                                     nil)))
                                                          
                                                          (progn
                                                            (if (> (length items) 1)
                                                              (progn
                                                                (let ((item-line-list nil)
                                                                      (item-prompt-list)
                                                                      (item-list (copy-list items)))
                                                                  
                                                                  (setf item-line-list (loop for item-id in item-list
                                                                                             for item = (get-item-by-id item-id)
                                                                                             collect (format nil "~A"
                                                                                                              (capitalize-name (prepend-article +article-a+ (visible-name item)))
                                                                                                              )))
                                                                   ;; populate the ability prompt list
                                                                   (setf item-prompt-list (loop for item-id in item-list
                                                                                                collect #'(lambda (cur-sel)
                                                                                                            (declare (ignore cur-sel))
                                                                                                            "[Enter] Poison  [Escape] Cancel")))
                                                                   
                                                                   ;; show selection window
                                                                   (setf *current-window* (make-instance 'select-obj-window 
                                                                                                         :return-to *current-window* 
                                                                                                         :header-line "Choose a body to poison:"
                                                                                                         :enter-func #'(lambda (cur-sel)
                                                                                                                         (clear-message-list (level/small-message-box (level *world*)))
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
                                                              (progn
                                                                 (clear-message-list (level/small-message-box (level *world*)))
                                                                 (mob-invoke-ability *player* (get-item-by-id (first items)) ability-type-id)
                                                                 t))
                                                            t)
                                                          (progn
                                                            nil)))
                                                      )))
