(in-package :cotd)

(defparameter *game-events-military-list* (list +mob-type-soldier+ +mob-type-soldier+ +mob-type-gunner+ +mob-type-sergeant+ +mob-type-scout+ +mob-type-chaplain+))

(set-game-event (make-instance 'game-event :id +game-event-win-for-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (zerop (total-demons world))
                                                                 (and (mob-ability-p *player* +mob-abil-angel+)
                                                                      (= (mob-type *player*) +mob-type-angel+)
                                                                      (or (and (mob-ability-p *player* +mob-abil-trinity-mimic+)
                                                                               (loop for mimic-id in (mimic-id-list *player*)
                                                                                     for mimic = (get-mob-by-id mimic-id)
                                                                                     with cur-fp = 0
                                                                                     with max-fp = 0
                                                                                     when (not (check-dead mimic))
                                                                                       do
                                                                                          (incf max-fp (max-fp mimic))
                                                                                          (incf cur-fp (cur-fp mimic))
                                                                                     finally (return (>= cur-fp max-fp)))
                                                                               )
                                                                          (and (not (mob-ability-p *player* +mob-abil-trinity-mimic+))
                                                                               (>= (cur-fp *player*) (max-fp *player*))))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Enemies eliminated.")
                                                                               ((>= (cur-fp *player*) (max-fp *player*)) "Ascended.")))
                                                                  (score (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                           0
                                                                                                           (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                 for mimic = (get-mob-by-id mimic-id)
                                                                                                                 with cur-score = 0
                                                                                                                 when (not (eq mimic *player*))
                                                                                                                   do
                                                                                                                      (incf cur-score (cur-score mimic))
                                                                                                                 finally (return cur-score
                                                                                                                                 ))))))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-angels-won+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-demons+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (zerop (total-angels world))
                                                                 (and (mob-ability-p *player* +mob-abil-demon+)
                                                                      (= (mob-type *player*) +mob-type-archdemon+)
                                                                      (>= (cur-fp *player*) (max-fp *player*))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-angels world)) "Enemies eliminated.")
                                                                               ((>= (cur-fp *player*) (max-fp *player*)) "Ascended.")))
                                                                  (score (calculate-player-score 1450))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                    (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-demons-won+ :highscores-place highscores-place))
                                                                                    (make-output *current-window*)
                                                                                    (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-humans+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (zerop (total-demons world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score (+ 1500 (* 10 (total-humans world)))))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-military-won+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-lose-game-died+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (if (or (and (not (mob-ability-p *player* +mob-abil-trinity-mimic+))
                                                                      (check-dead *player*))
                                                                 (and (mob-ability-p *player* +mob-abil-trinity-mimic+)
                                                                      (loop for mimic-id in (mimic-id-list *player*)
                                                                            for mimic = (get-mob-by-id mimic-id)
                                                                            with dead = 0
                                                                            when (check-dead mimic)
                                                                              do
                                                                                 (incf dead)
                                                                            finally (return (= dead (length (mimic-id-list *player*)))))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (if (null (killed-by *player*))
                                                                               "Killed by unknown forces."
                                                                               (format nil "Killed by ~A." (killed-by *player*))))
                                                                  (score (calculate-player-score 0))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (create-string "~%"))
                                                             (add-message (create-string "You are dead.~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-dead+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*)
                                                                                )
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-lose-game-possessed+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (if (and (mob-ability-p *player* +mob-abil-human+)
                                                                  (master-mob-id *player*))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (format nil "Possessed by ~A." (get-qualified-name (get-mob-by-id (master-mob-id *player*)))))
                                                                  (score (calculate-player-score 0))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (create-string "~%"))
                                                             (add-message (create-string "You are possessed.~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-possessed+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-snow-falls+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (loop repeat (sqrt (* (array-dimension (terrain (level world)) 0) (array-dimension (terrain (level world)) 1)))
                                                                 for x = (random (array-dimension (terrain (level world)) 0))
                                                                 for y = (random (array-dimension (terrain (level world)) 1))
                                                                 when (= (get-terrain-* (level world) x y 2) +terrain-floor-snow-prints+)
                                                                   do
                                                                      (logger (format nil "GAME-EVENT: Snow falls at (~A ~A)~%" x y))
                                                                      (set-terrain-* (level world) x y 2 +terrain-floor-snow+))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-adjust-outdoor-light+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (cond
                                                             ((find +game-event-unnatural-darkness+ (game-events world))
                                                              (progn
                                                                (setf (outdoor-light (level world))
                                                                      0)))
                                                             (t
                                                              (progn
                                                                (setf (outdoor-light (level world))
                                                                      (round (- 50 (* 50 (sin (+ 8 (* (/ pi (* 12 60 10)) (player-game-time world))))))))))
                                                             ))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-thief+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (>= (get-overall-value (inv *player*)) *thief-win-value*)
                                                                  (or (<= (x *player*) 1) (>= (x *player*) (- (array-dimension (terrain (level world)) 0) 2))
                                                                      (<= (y *player*) 1) (>= (y *player*) (- (array-dimension (terrain (level world)) 1) 2))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                            ;; write highscores
                                                           (let* ((final-str (format nil "Escaped with $~A." (calculate-total-value *player*)))
                                                                  (score (calculate-player-score 0))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                score
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                final-str
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-thief-won+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-rain-falls+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (loop repeat (sqrt (* (array-dimension (terrain (level world)) 0) (array-dimension (terrain (level world)) 1)))
                                                                 for x of-type fixnum = (random (array-dimension (terrain (level world)) 0))
                                                                 for y of-type fixnum = (random (array-dimension (terrain (level world)) 1))
                                                                 do
                                                                    (loop for z from (1- (array-dimension (terrain (level world)) 2)) downto 0
                                                                          when (or (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                                                                                   (and (> z 0)
                                                                                        (get-terrain-type-trait (get-terrain-* (level world) x y (1- z)) +terrain-trait-water+))
                                                                                   (and (> z 0)
                                                                                        (get-terrain-type-trait (get-terrain-* (level world) x y (1- z)) +terrain-trait-blocks-move+))
                                                                                   (get-mob-* (level world) x y z))
                                                                            do
                                                                               (logger (format nil "GAME-EVENT: Rain falls at (~A ~A ~A)~%" x y z))
                                                                               (place-animation x y z +anim-type-rain-dot+)
                                                                               (when (get-mob-* (level world) x y z)
                                                                                 (set-mob-effect (get-mob-* (level world) x y z) :effect-type-id +mob-effect-wet+ :actor-id (id (get-mob-* (level world) x y z)) :cd 2))
                                                                               (when (get-features-* (level world) x y z)
                                                                                 (loop for feature-id in (get-features-* (level world) x y z)
                                                                                       for feature = (get-feature-by-id feature-id)
                                                                                       when (or (= (feature-type feature) +feature-blood-old+)
                                                                                                (= (feature-type feature) +feature-blood-fresh+))
                                                                                         do
                                                                                            (remove-feature-from-level-list (level world) feature)
                                                                                            (remove-feature-from-world feature)
                                                                                       when (= (feature-type feature) +feature-blood-stain+)
                                                                                         do
                                                                                            (remove-feature-from-level-list (level world) feature)
                                                                                            (remove-feature-from-world feature)
                                                                                            (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-fresh+ :x x :y y :z z))
                                                                                       when (= (feature-type feature) +feature-fire+)
                                                                                         do
                                                                                            (decf (counter feature) 2)
                                                                                            (when (<= (counter feature) 0)
                                                                                              (remove-feature-from-level-list (level world) feature)
                                                                                              (remove-feature-from-world feature))))
                                                                               (loop-finish))
                                                                )
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-win-for-eater+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (zerop (total-demons world))
                                                                  (zerop (total-angels world)))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Enemies eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score 1430))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                 (if (mimic-id-list *player*)
                                                                                                                                   (faction-name *player*)
                                                                                                                                   (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                 (real-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (level-layout (level world)))
                                                                                                         *highscores*)))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-eater-won+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-ghost+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (if (mob-effect-p *player* +mob-effect-rest-in-peace+)
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                            ;; write highscores
                                                           (let* ((final-str (format nil "Put itself to rest."))
                                                                  (score (calculate-player-score 1450))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                 (faction-name *player*)
                                                                                                                                 (real-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (level-layout (level world)))
                                                                                                          *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (real-game-time world) (sf-name (get-scenario-feature-by-id (level-layout (level world))))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-ghost-won+ :highscores-place highscores-place))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-unnatural-darkness+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (when (zerop (random 10))
                                                             (setf (game-events world) (remove +game-event-unnatural-darkness+ (game-events world)))
                                                             (add-message (format nil "Unnatural darkness is no longer.~%"))))))

(set-game-event (make-instance 'game-event :id +game-event-constant-reanimation+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (let ((corpse-items (loop for item-id in (item-id-list (level world))
                                                                                     for item = (get-item-by-id item-id)
                                                                                     when (and (item-ability-p item +item-abil-corpse+)
                                                                                               (not (get-mob-* (level world) (x item) (y item) (z item))))
                                                                                       collect item)))
                                                             (loop with failure-result = t
                                                                   while (and (eq failure-result t)
                                                                              corpse-items)
                                                                   do
                                                                     (setf failure-result nil)
                                                                     (when (zerop (random 3))
                                                                       (setf failure-result t))
                                                                     (let ((item (nth (random (length corpse-items))
                                                                                      corpse-items)))
                                                                       (when (not (get-mob-* (level world) (x item) (y item) (z item)))
                                                                         (print-visible-message (x item) (y item) (z item) (level *world*) (format nil "An evil spirit has entered ~A. "
                                                                                                                                                   (prepend-article +article-the+ (visible-name item))))
                                                                         (invoke-reanimate-body item)
                                                                         (setf corpse-items (remove item corpse-items))
                                                                       ))))
                                                           
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-delayed-arrival-military+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 2) (turn-finished world))
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

(set-game-event (make-instance 'game-event :id +game-event-delayed-arrival-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 3) (turn-finished world))
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
