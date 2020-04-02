(in-package :cotd)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-demon-attack-win-for-angels+
                                           :descr-func #'(lambda ()
                                                           (let ((win-figure (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-attack))))
                                                             (format nil "To win, destroy all demons in the district. To lose, have all angels killed or have ~A% of civilians in the district destroyed or possessed." win-figure)))
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
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons (level world))) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                           0
                                                                                                           (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                 for mimic = (get-mob-by-id mimic-id)
                                                                                                                 with cur-score = 0
                                                                                                                 when (not (eq mimic *player*))
                                                                                                                   do
                                                                                                                      (incf cur-score (cur-score mimic))
                                                                                                                 finally (return cur-score))))))
                                                                  (highscores-place)
                                                                  (player-faction (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                          (= (loyal-faction *player*) +faction-type-church+))
                                                                                    t
                                                                                    nil))
                                                                  (player-died (player-check-dead)))

                                                             (when player-died
                                                               (multiple-value-setq (final-str score) (dump-when-dead)))

                                                             (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                 (if (mimic-id-list *player*)
                                                                                                                                   (faction-name *player*)
                                                                                                                                   (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                 (player-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (name (world-sector (level world))))
                                                                                                          *highscores*))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))

                                                             (if player-faction
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Congratulations! Your faction has won!~%"))
                                                                 (add-message (format nil "~%Press any key...~%")))
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Curses! Your faction has lost!~%"))
                                                                 (add-message (format nil "~%Press any key...~%"))))
                                                             
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-angels-won+ :highscores-place highscores-place
                                                                                                                                          :player-won player-faction :player-died player-died))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-demon-attack-win-for-demons+
                                           :descr-func #'(lambda ()
                                                           (let ((win-figure (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-attack))))
                                                             (format nil "To win, destroy or possess ~A% of civilians in the district. To lose, have all demons killed." win-figure)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (let* ((win-condition (get-win-condition-by-id :win-cond-demonic-attack))
                                                                (civilians-left (funcall (win-condition/win-func win-condition) world win-condition)))
                                                           (if (or (and (= (loyal-faction *player*) +faction-type-demons+)
                                                                        (> (total-demons (level world)) 0)
                                                                        (<= civilians-left 0))
                                                                   (and (/= (loyal-faction *player*) +faction-type-demons+)
                                                                        (> (total-demons (level world)) 0)
                                                                        (<= civilians-left 0)))
                                                             t
                                                             nil)))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str "Civilians eliminated.")
                                                                  (score (calculate-player-score 1450))
                                                                  (highscores-place)
                                                                  (player-faction (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                          (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                    t
                                                                                    nil))
                                                                  (player-died (player-check-dead)))

                                                             (when player-died
                                                               (multiple-value-setq (final-str score) (dump-when-dead)))

                                                             (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (if player-faction
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Congratulations! Your faction has won!~%"))
                                                                 (add-message (format nil "~%Press any key...~%")))
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Curses! Your faction has lost!~%"))
                                                                 (add-message (format nil "~%Press any key...~%"))))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-demons-won+ :highscores-place highscores-place
                                                                                                                      :player-won player-faction :player-died player-died))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-demon-attack-win-for-military+
                                           :descr-func #'(lambda ()
                                                           (let ((win-figure (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-attack))))
                                                             (format nil "To win, destroy all demons in the district. To lose, have all military killed or have ~A% of civilians in the district destroyed or possessed." win-figure)))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (> (total-humans (level world)) 0)
                                                                  (zerop (total-demons (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons (level world))) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score (+ 1500 (* 10 (total-humans (level world))))))
                                                                  (highscores-place)
                                                                  (player-faction (if (= (loyal-faction *player*) +faction-type-military+)
                                                                                    t
                                                                                    nil))
                                                                  (player-died (player-check-dead)))

                                                             (when player-died
                                                               (multiple-value-setq (final-str score) (dump-when-dead)))

                                                             (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (if player-faction
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Congratulations! Your faction has won!~%"))
                                                                 (add-message (format nil "~%Press any key...~%")))
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Curses! Your faction has lost!~%"))
                                                                 (add-message (format nil "~%Press any key...~%"))))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-military-won+ :highscores-place highscores-place
                                                                                                                      :player-won player-faction :player-died player-died))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-demon-attack-win-for-church+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all demons in the district. To lose, get all priests and angels killed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-church+)
                                                                  (> (nth +faction-type-church+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-demons (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons (level world))) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                           0
                                                                                                           (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                 for mimic = (get-mob-by-id mimic-id)
                                                                                                                 with cur-score = 0
                                                                                                                 when (not (eq mimic *player*))
                                                                                                                   do
                                                                                                                      (incf cur-score (cur-score mimic))
                                                                                                                 finally (return cur-score))))))
                                                                  (highscores-place)
                                                                  (player-faction (if (or (= (loyal-faction *player*) +faction-type-angels+)
                                                                                          (= (loyal-faction *player*) +faction-type-church+))
                                                                                    t
                                                                                    nil))
                                                                  (player-died (player-check-dead)))

                                                             (when player-died
                                                               (multiple-value-setq (final-str score) (dump-when-dead)))

                                                             (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                 (if (mimic-id-list *player*)
                                                                                                                                   (faction-name *player*)
                                                                                                                                   (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                 (player-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (name (world-sector (level world))))
                                                                                                          *highscores*))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))

                                                             (if player-faction
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Congratulations! Your faction has won!~%"))
                                                                 (add-message (format nil "~%Press any key...~%")))
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Curses! Your faction has lost!~%"))
                                                                 (add-message (format nil "~%Press any key...~%"))))
                                                             
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-church-won+ :highscores-place highscores-place
                                                                                                                                          :player-won player-faction :player-died player-died))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-demon-attack-win-for-satanists+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels in the district. To lose, get all satanists and demons killed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                  (> (nth +faction-type-satanists+ (total-faction-list (level world))) 0)
                                                                  (zerop (total-angels (level world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-angels (level world))) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score 1450))
                                                                  (highscores-place)
                                                                  (player-faction (if (or (= (loyal-faction *player*) +faction-type-demons+)
                                                                                          (= (loyal-faction *player*) +faction-type-satanists+))
                                                                                    t
                                                                                    nil))
                                                                  (player-died (player-check-dead)))

                                                             (when player-died
                                                               (multiple-value-setq (final-str score) (dump-when-dead)))

                                                             (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (if player-faction
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Congratulations! Your faction has won!~%"))
                                                                 (add-message (format nil "~%Press any key...~%")))
                                                               (progn
                                                                 (add-message (format nil "~%"))
                                                                 (add-message (format nil "Curses! Your faction has lost!~%"))
                                                                 (add-message (format nil "~%Press any key...~%"))))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-satanists-won+ :highscores-place highscores-place
                                                                                                                      :player-won player-faction :player-died player-died))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))
