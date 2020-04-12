(in-package :cotd)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-military-conquest-win-for-angels+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all demonic sigils in the district. To lose, have all angels killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-angels+)
                                                                      (> (total-angels (level world)) 0)
                                                                      (null (get-military-conquest-check-alive-sigils (level world))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-angels+)
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list (level world))))
                                                                      (> (total-angels (level world)) 0)
                                                                      (null (get-military-conquest-check-alive-sigils (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                        (= (loyal-faction *player*) +faction-type-church+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "District successfully conquered back."
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

(set-game-event (make-instance 'game-event :id +game-event-military-conquest-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all angels and military in the district. To lose, have all demonic sigils destroyed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (zerop (total-angels (level world)))
                                                                      (zerop (nth +faction-type-military+ (total-faction-list (level world)))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (zerop (nth +faction-type-military+ (total-faction-list (level world))))
                                                                      (zerop (nth +faction-type-church+ (total-faction-list (level world))))
                                                                      (zerop (total-angels (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "District successfully defended by demons."
                                                                                :score (calculate-player-score 1500)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-military-conquest-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all demonic sigils in the district. To lose, have all military killed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-military+)
                                                                      (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                      (null (get-military-conquest-check-alive-sigils (level world))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-military+)
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list (level world))))
                                                                      (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                      (null (get-military-conquest-check-alive-sigils (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (= (loyal-faction *player*) +faction-type-military+)
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Enemies eliminated."
                                                                                :score (calculate-player-score (+ 1450 (* 7 (total-humans (level world)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-military-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-military-conquest-win-for-satanists+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels and military in the district. To lose, have all demonic sigils destroyed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                  (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-angels (level world)))
                                                                  (zerop (nth +faction-type-military+ (total-faction-list (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "District successfully defended by demons."
                                                                                :score (calculate-player-score 1500)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))
