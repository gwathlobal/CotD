(in-package :cotd)

(set-game-event (make-instance 'game-event :id +game-event-campaign-demon-win+
                                           :descr-func #'(lambda ()
                                                           (let ((max-flesh-points (win-condition/win-formula (get-win-condition-by-id :win-cond-demon-campaign))))
                                                             (format nil "To win, collect ~A pts of flesh by winning missions." max-flesh-points)))
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
                                                           (setf *current-window* (make-instance 'campaign-over-window :campaign-over-type :game-over-demons-won
                                                                                                                       :player-won (eq (get-general-faction-from-specific (world/player-specific-faction world)) +faction-type-demons+)))
                                                           (make-output *current-window*)
                                                           (run-window *current-window*)
                                                           )))
