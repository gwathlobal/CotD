(in-package :cotd)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-eliminate-satanists-win-for-angels+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all demons & satanists in the district. To lose, have all angels killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-angels+)
                                                                      (> (total-angels (level world)) 0)
                                                                      (zerop (total-demons (level world)))
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list (level world)))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-angels+)
                                                                      (> (total-angels (level world)) 0)
                                                                      (zerop (total-demons (level world)))
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list (level world))))
                                                                      (zerop (nth +faction-type-military+ (total-faction-list (level world))))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let* ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                         (= (loyal-faction *player*) +faction-type-church+))
                                                                                   t
                                                                                   nil))
                                                                  (bonus (if if-player-won
                                                                           1400
                                                                           0)))
                                                             (trigger-game-over world
                                                                                :final-str "Satanists eliminated."
                                                                                :score (calculate-player-score (+ bonus (if (not (mimic-id-list *player*))
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

(set-game-event (make-instance 'game-event :id +game-event-eliminate-satanists-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all military units in the district. To lose, have all satanists killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                      (<= (nth +faction-type-military+ (total-faction-list (level world))) 0))
                                                                 (and (/= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                      (<= (nth +faction-type-military+ (total-faction-list (level world))) 0)))
                                                             t
                                                             nil))
                                           :on-trigger #'(lambda (world)
                                                           (let* ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                         (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                   t
                                                                                   nil))
                                                                  (bonus (if if-player-won
                                                                           1450
                                                                           0)))
                                                             (trigger-game-over world
                                                                                :final-str "Satanists protected."
                                                                                :score (calculate-player-score bonus)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-eliminate-satanists-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all satanists in the district. To lose, have all military units killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                  (zerop (nth +faction-type-satanists+ (total-faction-list (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let* ((if-player-won (if (= (loyal-faction *player*) +faction-type-military+)
                                                                                  t
                                                                                   nil))
                                                                  (bonus (if if-player-won
                                                                           1500
                                                                           0)))
                                                             (trigger-game-over world
                                                                                :final-str "Satanists eliminated."
                                                                                :score (calculate-player-score (+ bonus (* 10 (total-humans (level world)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-military-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-eliminate-satanists-win-for-church+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all satanists and demons in the district. To lose, get all priests and angels killed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-church+)
                                                                  (> (nth +faction-type-church+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-demons (level world)))
                                                                  (zerop (nth +faction-type-satanists+ (total-faction-list (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                        (= (loyal-faction *player*) +faction-type-church+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Satanists eliminated."
                                                                                :score (calculate-player-score (+ 1450 (if (not (mimic-id-list *player*))
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

(set-game-event (make-instance 'game-event :id +game-event-eliminate-satanists-win-for-satanists+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all military units in the district. To lose, have all satanists killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                  (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                  (zerop (nth +faction-type-military+ (total-faction-list (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Satanists protected."
                                                                                :score (calculate-player-score 1450)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-satanists-won))
                                                           )))
