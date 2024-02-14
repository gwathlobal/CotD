(in-package :cotd-sdl)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-angelic-steal-win-for-angels+
                                           :descr-func #'(lambda ()
                                                           "To win, capture the relic in the corrupted shrine and get to the edge of the map with it. To lose, have all angels killed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (get-angel-steal-angel-with-relic world)
                                                                  (or (<= (x (get-angel-steal-angel-with-relic world)) 1)
                                                                      (>= (x (get-angel-steal-angel-with-relic world)) (- (array-dimension (terrain (level world)) 0) 2))
                                                                      (<= (y (get-angel-steal-angel-with-relic world)) 1)
                                                                      (>= (y (get-angel-steal-angel-with-relic world)) (- (array-dimension (terrain (level world)) 1) 2))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                        (= (loyal-faction *player*) +faction-type-church+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Relic sucessfully returned."
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

(set-game-event (make-instance 'game-event :id +game-event-angelic-steal-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels & military in the district. To lose, have all demons killed or let the angels take the relic and escape with it.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (zerop (total-angels (level world))))
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
                                                                                :final-str "Angelic retrieval attempt prevented."
                                                                                :score (calculate-player-score 1350)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-angelic-steal-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all demons in the district. To lose, have all military killed."))
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
                                                                                :final-str "Enemies eliminated."
                                                                                :score (calculate-player-score (+ 1500 (* 7 (total-humans (level world)))))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-military-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-angelic-steal-win-for-satanists+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels & military in the district. To lose, have all demons & satanists killed or let the angels take the relic and escape with it.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                  (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-angels (level world))))
                                                           t
                                                           nil)
                                                         )
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Angelic retrieval attempt prevented."
                                                                                :score (calculate-player-score 1350)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-satanists-won))
                                                           )))
