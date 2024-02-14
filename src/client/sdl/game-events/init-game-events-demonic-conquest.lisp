(in-package :cotd-sdl)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-angels+
                                           :descr-func #'(lambda ()
                                                           (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                             (format nil "To win, destroy all demons in the district. To lose, have all angels killed or let the demons create ~A demonic sigils and let them charge for ~A turns." sigils-num max-turns)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-angels+)
                                                                      (> (total-angels (level world)) 0)
                                                                      (zerop (total-demons (level world))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-angels+)
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list (level world))))
                                                                      (> (total-angels (level world)) 0)
                                                                      (zerop (total-demons (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                        (= (loyal-faction *player*) +faction-type-church+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Demonic conquest prevented."
                                                                                :score (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                                         0
                                                                                                                         (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                               for mimic = (get-mob-by-id mimic-id)
                                                                                                                               with cur-score = 0
                                                                                                                               when (not (eq mimic *player*))
                                                                                                                                 do
                                                                                                                                    (incf cur-score (cur-score mimic))
                                                                                                                               finally (return cur-score)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-angels-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                             (format nil "To win, create at least ~A demonic sigils (using your ability) and let them charge for ~A turns. To lose, have all demons killed." sigils-num max-turns)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                           (if (and (> (total-demons (level world)) 0)
                                                                    (get-demon-conquest-turns-left world)
                                                                    (>= (length (demonic-sigils (level world))) sigils-num)
                                                                    (>= (get-demon-conquest-turns-left world) max-turns))
                                                             t
                                                             nil)))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "District successfully conquered by demons."
                                                                                :score (calculate-player-score 1500)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                             (format nil "To win, destroy all demons in the district. To lose, have all military killed or let the demons create ~A demonic sigils and let them charge for ~A turns." sigils-num max-turns)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (> (total-humans (level world)) 0)
                                                                  (zerop (total-demons (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (= (loyal-faction *player*) +faction-type-military+)
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Demonic conquest prevented."
                                                                                :score (calculate-player-score (+ 1450 (* 7 (total-humans (level world)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-military-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-church+
                                           :descr-func #'(lambda ()
                                                           (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                             (format nil "To win, destroy all demons in the district. To lose, get all priests and angels killed or let the demons create ~A demonic sigils and let them charge for ~A turns." sigils-num max-turns)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-church+)
                                                                  (> (nth +faction-type-church+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-demons (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                        (= (loyal-faction *player*) +faction-type-church+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Demonic conquest prevented."
                                                                                :score (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                                         0
                                                                                                                         (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                               for mimic = (get-mob-by-id mimic-id)
                                                                                                                               with cur-score = 0
                                                                                                                               when (not (eq mimic *player*))
                                                                                                                                 do
                                                                                                                                    (incf cur-score (cur-score mimic))
                                                                                                                               finally (return cur-score)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-church-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-satanists+
                                           :descr-func #'(lambda ()
                                                           (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                             (format nil "To win, create at least ~A demonic sigils (using your ability) and let them charge for ~A turns. To lose, get all satanists and demons killed." sigils-num max-turns)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
                                                           (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                    (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                    (get-demon-conquest-turns-left world)
                                                                    (>= (length (demonic-sigils (level world))) sigils-num)
                                                                    (>= (get-demon-conquest-turns-left world) max-turns))
                                                             t
                                                             nil)))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "District successfully conquered by demons."
                                                                                :score (calculate-player-score 1500)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-satanists-won))
                                                           )))
