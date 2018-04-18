(in-package :cotd)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-angels+
                                           :descr (format nil "To win, destroy all demons in the district. To lose, have all angels killed or let the demons create ~A demonic sigils and let them charge for ~A turns." *demonic-conquest-win-sigils-num* *demonic-conquest-win-sigils-turns*)
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-angels+)
                                                                      (> (total-angels world) 0)
                                                                      (zerop (total-demons world)))
                                                                 (and (/= (loyal-faction *player*) +faction-type-angels+)
                                                                      (zerop (nth +faction-type-satanists+ (total-faction-list world)))
                                                                      (> (total-angels world) 0)
                                                                      (zerop (total-demons world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Demonic conquest prevented.")
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
                                                                                                                                 (real-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (level-layout (level world)))
                                                                                                          *highscores*))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
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

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-demons+
                                           :descr (format nil "To win, create at least ~A demonic sigils (using your ability) and let them charge for ~A turns. To lose, have all demons killed." *demonic-conquest-win-sigils-num* *demonic-conquest-win-sigils-turns*)
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (> (total-demons world) 0)
                                                                  (get-demon-conquest-turns-left world)
                                                                  (>= (length (demonic-sigils (level world))) *demonic-conquest-win-sigils-num*)
                                                                  (>= (get-demon-conquest-turns-left world) *demonic-conquest-win-sigils-turns*))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str "District successfully conquered by demons.")
                                                                  (score (calculate-player-score 1500))
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
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
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

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-military+
                                           :descr (format nil "To win, destroy all demons in the district. To lose, have all military killed or let the demons create ~A demonic sigils and let them charge for ~A turns." *demonic-conquest-win-sigils-num* *demonic-conquest-win-sigils-turns*)
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (> (total-humans world) 0)
                                                                  (zerop (total-demons world)))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Demonic conquest prevented.")
                                                                               ))
                                                                  (score (calculate-player-score (+ 1450 (* 7 (total-humans world)))))
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
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
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

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-church+
                                           :descr (format nil "To win, destroy all demons in the district. To lose, get all priests and angels killed or let the demons create ~A demonic sigils and let them charge for ~A turns." *demonic-conquest-win-sigils-num* *demonic-conquest-win-sigils-turns*)
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-church+)
                                                                  (> (nth +faction-type-church+ (total-faction-list world)) 0)
                                                                  (zerop (total-demons world)))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Demonic conquest prevented.")
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
                                                                                                                                 (real-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (level-layout (level world)))
                                                                                                          *highscores*))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
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

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-win-for-satanists+
                                           :descr (format nil "To win, create at least ~A demonic sigils (using your ability) and let them charge for ~A turns. To lose, get all satanists and demons killed." *demonic-conquest-win-sigils-num* *demonic-conquest-win-sigils-turns*)
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-satanists+)
                                                                  (> (nth +faction-type-satanists+ (total-faction-list world)) 0)
                                                                  (get-demon-conquest-turns-left world)
                                                                  (>= (length (demonic-sigils (level world))) *demonic-conquest-win-sigils-num*)
                                                                  (>= (get-demon-conquest-turns-left world) *demonic-conquest-win-sigils-turns*))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str "District successfully conquered by demons.")
                                                                  (score (calculate-player-score 1500))
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
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                          *highscores*))
                                                             
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
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

;;===========================
;; ARRIVAL EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-delayed-arrival-military+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 60) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "~%GAME-EVENT: The military has arrived!~%"))

                                                           ;; find a suitable arrival point to accomodate 4 groups of military
                                                           (let ((arrival-points (copy-list (delayed-arrival-points (level world)))))
                                                             (loop with max-troops = 4
                                                                   while (not (zerop max-troops))
                                                                   for n = (random (length arrival-points))
                                                                   for arrival-point = (nth n arrival-points)
                                                                   do
                                                                      (let ((free-cells 0) (m-picked 0))
                                                                        (check-surroundings (first arrival-point) (second arrival-point) t
                                                                                            #'(lambda (dx dy)
                                                                                                (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                                                                           (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                                                                           (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+))
                                                                                                  (incf free-cells))))
                                                                        (when (>= free-cells (1- (length *game-events-military-list*)))
                                                                          
                                                                          (check-surroundings (first arrival-point) (second arrival-point) t
                                                                                              #'(lambda (dx dy)
                                                                                                  (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                                                                             (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                                                                             (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+)
                                                                                                             (<= m-picked (1- (length *game-events-military-list*))))
                                                                                                    (add-mob-to-level-list (level world) (make-instance 'mob :mob-type (nth m-picked *game-events-military-list*)
                                                                                                                                                             :x dx :y dy :z (third arrival-point)))
                                                                                                    (incf m-picked))))
                                                                          (decf max-troops)
                                                                          ))
                                                                   ))
                                                           )
                               ))


(set-game-event (make-instance 'game-event :id +game-event-demon-conquest-delayed-arrival-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 40) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "~%GAME-EVENT: The angels have arrived!~%"))

                                                           (let ((arrival-points (copy-list (delayed-arrival-points (level world)))))
                                                             ;; find a suitable arrival point to accomodate trinity mimics
                                                             (loop with positioned = nil
                                                                   with trinity-mimic-list = (list +mob-type-star-singer+ +mob-type-star-gazer+ +mob-type-star-mender+)
                                                                   while (null positioned)
                                                                   for n = (random (length arrival-points))
                                                                   for arrival-point = (nth n arrival-points)
                                                                   do
                                                                      (let ((free-cells ()))
                                                                        (check-surroundings (first arrival-point) (second arrival-point) t
                                                                                            #'(lambda (dx dy)
                                                                                                (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                                                                           (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                                                                           (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+))
                                                                                                  (push (list dx dy (third arrival-point)) free-cells))))
                                                                        (when (>= (length free-cells) (length trinity-mimic-list))
                                                                          (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+ :x (first (nth 0 free-cells)) :y (second (nth 0 free-cells)) :z (third (nth 0 free-cells))))
                                                                                (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+ :x (first (nth 1 free-cells)) :y (second (nth 1 free-cells)) :z (third (nth 1 free-cells))))
                                                                                (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+ :x (first (nth 2 free-cells)) :y (second (nth 2 free-cells)) :z (third (nth 2 free-cells)))))
                                                                            
                                                                            (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                                                                            (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                                                                            (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                                                                            (setf (name mob2) (name mob1) (name mob3) (name mob1))
                                                                            
                                                                            (add-mob-to-level-list (level world) mob1)
                                                                            (add-mob-to-level-list (level world) mob2)
                                                                            (add-mob-to-level-list (level world) mob3))
                                                                          
                                                                          (setf positioned t)
                                                                          ))
                                                                   )
                                                             (loop with positioned = nil
                                                                   with max-angels = 5
                                                                   while (null positioned)
                                                                   for n = (random (length arrival-points))
                                                                   for arrival-point = (nth n arrival-points)
                                                                   do
                                                                      (let ((free-cells 0) (m-picked 0))
                                                                        (check-surroundings (first arrival-point) (second arrival-point) t
                                                                                            #'(lambda (dx dy)
                                                                                                (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                                                                           (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                                                                           (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+))
                                                                                                  (incf free-cells))))
                                                                        (when (>= free-cells max-angels)
                                                                          
                                                                          (check-surroundings (first arrival-point) (second arrival-point) t
                                                                                              #'(lambda (dx dy)
                                                                                                  (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                                                                             (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                                                                             (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+)
                                                                                                             (<= m-picked max-angels))
                                                                                                    (add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-angel+
                                                                                                                                                             :x dx :y dy :z (third arrival-point)))
                                                                                                    (incf m-picked))))
                                                                          (setf positioned t)
                                                                          ))
                                                                   ))
                                                           )
                               ))
