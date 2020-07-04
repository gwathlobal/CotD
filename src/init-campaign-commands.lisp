(in-package :cotd)

(set-campaign-command :id :campaign-command-angel-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-angels+
                      :disabled nil
                      :trigger-on-start t
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore world campaign-command))
                                           nil
                                           ))

(set-campaign-command :id :campaign-command-demon-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :trigger-on-start t
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore world campaign-command))
                                           nil
                                           ))

(set-campaign-command :id :campaign-command-military-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :trigger-on-start t
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore world campaign-command))
                                           nil
                                           ))

(set-campaign-command :id :campaign-command-satanist-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :trigger-on-start t
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore world campaign-command))
                                           nil
                                           ))

(set-campaign-command :id :campaign-command-church-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-church+
                      :disabled nil
                      :trigger-on-start t
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore world campaign-command))
                                           nil
                                           ))

(set-campaign-command :id :campaign-command-satanist-sacrifice
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Sacrifice a citizen")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Find a new citizen and sacrifice them to give demons more opportunities to invade.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :trigger-on-start nil
                      :cd 10
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and (not (zerop satanist-lairs-left))
                                                    (not (find-campaign-effects-by-id world :campaign-effect-satanist-sacrifice)))
                                               t
                                               nil)))
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore campaign-command))
                                           (add-campaign-effect world :id :campaign-effect-satanist-sacrifice :cd 5)
                                           ))

(set-campaign-command :id :campaign-command-satanist-hide-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Hide a lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Increase the paranoia level of your fellow cultists to protect the lair from infiltration.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :trigger-on-start t
                      :cd 7
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and (not (zerop satanist-lairs-left))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible)))
                                               t
                                               nil)))
                                         )
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore campaign-command))
                                           (add-campaign-effect world :id :campaign-effect-satanist-lair-hidden :cd 5)
                                           ))

(set-campaign-command :id :campaign-command-demon-reform-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reform a satanist' lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Seduce willing undividuals to recreate the once destroyed satanist' lair.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :trigger-on-start nil
                      :cd 12
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (zerop satanist-lairs-left)
                                               t
                                               nil))))
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore campaign-command))
                                           (place-satanist-lair-on-map (world-map world) 1)
                                           (let ((message-box-list `(,(world/sitrep-message-box world))))
                                             (add-message (format nil "The ") sdl:*white* message-box-list)
                                             (add-message (format nil "satanists' lair") sdl:*yellow* message-box-list)
                                             (add-message (format nil " has been ") sdl:*white* message-box-list)
                                             (add-message (format nil " reformed.~%") sdl:*yellow* message-box-list))
                                           ))

(set-campaign-command :id :campaign-command-military-reveal-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reveal a satanist' lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Infiltrate the satanists' lair and make it vulnerable for attack.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :trigger-on-start nil 
                      :cd 6
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and (not (zerop satanist-lairs-left))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-hidden)))
                                               t
                                               nil))))
                      :on-trigger-func #'(lambda (world campaign-command)
                                           (declare (ignore campaign-command))
                                           (add-campaign-effect world :id :campaign-effect-satanist-lair-visible :cd 5)  
                                           ))
