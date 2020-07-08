(in-package :cotd)

(set-game-event (make-instance 'game-event :id +game-event-campaign-demon-win+
                                           :descr-func #'(lambda ()
                                                           (let ((max-flesh-points (win-condition/win-formula (get-win-condition-by-id :win-cond-demon-campaign))))
                                                             (format nil "To win:~% - collect ~A pts of flesh, or~% - corrupt all districts in the City.~%To lose:~% - have all dimensional engines shattered, or ~% - let the satanists' lair be destroyed while having no corrupted districts in the City." max-flesh-points)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (let* ((win-condition (get-win-condition-by-id :win-cond-demon-campaign))
                                                                (max-flesh-points (win-condition/win-formula win-condition))
                                                                (normal-sectors-left (funcall (win-condition/win-func win-condition) world win-condition)))
                                                           (if (or (>= (world/flesh-points world) max-flesh-points)
                                                                   (<= normal-sectors-left 0))
                                                             t
                                                             nil)))
                                           :on-trigger #'(lambda (world)
                                                           (let* ((win-condition (get-win-condition-by-id :win-cond-demon-campaign))
                                                                  (normal-sectors-left (funcall (win-condition/win-func win-condition) world win-condition))
                                                                  (demon-win-type))
                                                             (cond
                                                               ((<= normal-sectors-left 0) (setf demon-win-type :campaign-over-demons-conquer))
                                                               (t (setf demon-win-type :campaign-over-demons-gather)))
                                                             (setf *current-window* (make-instance 'campaign-over-window :campaign-over-type demon-win-type
                                                                                                                         :player-won (eq (get-general-faction-from-specific (world/player-specific-faction world)) +faction-type-demons+)))
                                                             (make-output *current-window*)
                                                             (run-window *current-window*))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-campaign-military-win+
                                           :descr-func #'(lambda ()
                                                            (let ((max-flesh-points (win-condition/win-formula (get-win-condition-by-id :win-cond-demon-campaign))))
                                                              (format nil "To win, reconquer corrupted districts while all satanists' lairs are destroyed. ~%To lose, let the demons capture all districts in the City or gather ~A pts of flesh." max-flesh-points)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (let* ((win-condition (get-win-condition-by-id :win-cond-military-campaign)))
                                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func win-condition) world win-condition)
                                                             (if (and (<= corrupted-sectors-left 0)
                                                                      (<= satanist-lairs-left 0))
                                                             t
                                                             nil))
                                                           ))
                                           :on-trigger #'(lambda (world)
                                                           (setf *current-window* (make-instance 'campaign-over-window :campaign-over-type :campaign-over-military-won
                                                                                                                       :player-won (eq (get-general-faction-from-specific (world/player-specific-faction world)) +faction-type-military+)))
                                                           (make-output *current-window*)
                                                           (run-window *current-window*)
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-campaign-angel-win+
                                           :descr-func #'(lambda ()
                                                           (let ((max-flesh-points (win-condition/win-formula (get-win-condition-by-id :win-cond-demon-campaign))))
                                                             (format nil "To win, destroy all dimensional engines that enable the Pandemonium to escape the Prison Dimension.~%To lose, let the demons capture all districts in the City or gather ~A pts of flesh." max-flesh-points)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (let* ((win-condition (get-win-condition-by-id :win-cond-angels-campaign))
                                                                (machines-left (funcall (win-condition/win-func win-condition) world win-condition)))
                                                           (if (<= machines-left 0)
                                                             t
                                                             nil)))
                                           :on-trigger #'(lambda (world)
                                                           (setf *current-window* (make-instance 'campaign-over-window :campaign-over-type :campaign-over-angels-won
                                                                                                                       :player-won (eq (get-general-faction-from-specific (world/player-specific-faction world)) +faction-type-angels+)))
                                                           (make-output *current-window*)
                                                           (run-window *current-window*)
                                                           )))
