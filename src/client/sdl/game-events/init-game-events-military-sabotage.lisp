(in-package :cotd-sdl)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-military-sabotage-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all of raw flesh storages in the district. You can do it by using a Bomb item next to the Target bomb location. To lose, have all military killed or possessed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-military+)
                                                                      (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                      (null (bomb-plant-locations (level world))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-military+)
                                                                      (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                      (null (bomb-plant-locations (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (= (loyal-faction *player*) +faction-type-military+)
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Raw flesh storages successfully sabotaged."
                                                                                :score (calculate-player-score (+ 1450 0))
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-military-won))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-military-sabotage-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           (format nil "To win, destroy all military. To lose, have all raw flesh storages destroyed."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (zerop (nth +faction-type-military+ (total-faction-list (level world))))
                                                                      (bomb-plant-locations (level world)))
                                                                 (and (/= (loyal-faction *player*) +faction-type-demons+)
                                                                      (> (total-demons (level world)) 0)
                                                                      (zerop (nth +faction-type-military+ (total-faction-list (level world))))
                                                                      (bomb-plant-locations (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((if-player-won (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                        (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                  t
                                                                                  nil)))
                                                             (trigger-game-over world
                                                                                :final-str "Raw flesh storages successfully defended by demons."
                                                                                :score (calculate-player-score 1500)
                                                                                :if-player-won if-player-won
                                                                                :player-msg (if if-player-won
                                                                                              (format nil "Congratulations! Your faction has won!~%")
                                                                                              (format nil "Curses! Your faction has lost!~%"))
                                                                                :game-over-type :game-over-demons-won))
                                                           )))
