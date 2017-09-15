(in-package :cotd)

(defparameter *game-events-military-list* (list +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-gunner+ +mob-type-gunner+ +mob-type-sergeant+ +mob-type-scout+ +mob-type-chaplain+))

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
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score (+ 1400 (if (not (mimic-id-list *player*))
                                                                                                                                                                  0
                                                                                                                                                                  (loop for mimic-id in (mimic-id-list *player*)
                                                                                                                                                                        for mimic = (get-mob-by-id mimic-id)
                                                                                                                                                                        with cur-score = 0
                                                                                                                                                                        when (not (eq mimic *player*))
                                                                                                                                                                          do
                                                                                                                                                                             (incf cur-score (cur-score mimic))
                                                                                                                                                                        finally (return cur-score
                                                                                                                                                                                        )))))
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (cond
                                                                                                                                  ((zerop (total-demons world)) "Enemies eliminated.")
                                                                                                                                  ((>= (cur-fp *player*) (max-fp *player*)) "Ascended."))
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
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
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 1450)
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (cond
                                                                                                                                  ((zerop (total-angels world)) "Enemies eliminated.")
                                                                                                                                  ((>= (cur-fp *player*) (max-fp *player*)) "Ascended."))
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
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
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score (+ 1500 (* 10 (total-humans world))))
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (cond
                                                                                                                                  ((zerop (total-demons world)) "Enemies eliminated.")
                                                                                                                                  )
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
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
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 0)
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (if (null (killed-by *player*))
                                                                                                                                  "Killed by unknown forces."
                                                                                                                                  (format nil "Killed by ~A." (prepend-article +article-a+ (values-list (killed-by *player*)))))
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (create-string "~%"))
                                                             (add-message (create-string "You are dead.~%"))
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
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 0)
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (format nil "Possessed by ~A." (get-qualified-name (get-mob-by-id (master-mob-id *player*))))
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (create-string "~%"))
                                                             (add-message (create-string "You are possessed.~%"))
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

(set-game-event (make-instance 'game-event :id +game-event-military-arrive+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived!~%"))
                                                           
                                                           ;; find a suitable place for the military along the map borders
                                                           ;; four groups are created - north-east, south-east, north-west and south-west
                                                           ;; place the units
                                                           (let ((placement-list-horiz (list (cons 1 1)                                        ;; north-east
                                                                                             (cons 1 (- (array-dimension (terrain (level world)) 1) 2))                      ;; south-east
                                                                                             (cons (- (array-dimension (terrain (level world)) 0) 15) 1)                     ;; north-west
                                                                                             (cons (- (array-dimension (terrain (level world)) 0) 15) (- (array-dimension (terrain (level world)) 1) 2)))) ;; south-west
                                                                 )
                                                                 

                                                             ;; place for north and south horizontally
                                                             (loop for (sx . sy) in placement-list-horiz do
                                                               (loop for x from 0 to 9
                                                                     for military-picked = (nth (random (length *game-events-military-list*)) *game-events-military-list*)
                                                                     when (and (not (get-mob-* (level world) (+ sx x) sy 2))
                                                                               (not (get-terrain-type-trait (get-terrain-* (level world) (+ sx x) sy 2) +terrain-trait-blocks-move+)))
                                                                       do
                                                                          (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x (+ sx x) :y sy :z 2))))
                                                             
                                                             ))
                               ))

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

(set-game-event (make-instance 'game-event :id +game-event-military-arrive-port-n+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived to the northern piers!~%"))

                                                           ;; find the suitable place on the northern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))

(set-game-event (make-instance 'game-event :id +game-event-military-arrive-port-s+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived to the southern piers!~%"))

                                                           ;; find the suitable place on the southern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from (1- (array-dimension (terrain (level world)) 1)) downto 0
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))

(set-game-event (make-instance 'game-event :id +game-event-military-arrive-port-w+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived to the western piers!~%"))

                                                           ;; find the suitable place on the western piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))

(set-game-event (make-instance 'game-event :id +game-event-military-arrive-port-e+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived to the eastern piers!~%"))

                                                           ;; find the suitable place on the eastern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for x from (1- (array-dimension (terrain (level world)) 0)) downto 0 
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))

(set-game-event (make-instance 'game-event :id +game-event-military-arrive-island+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (real-game-time world) 220) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived to the island!~%"))

                                                           ;; find the suitable place on the eastern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for x from (1- (array-dimension (terrain (level world)) 0)) downto 0 
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the western piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the southern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from (1- (array-dimension (terrain (level world)) 1)) downto 0
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the northern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from 0 below (array-dimension (terrain (level world)) 1)
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below (array-dimension (terrain (level world)) 0)
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y 2))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-blocks-move+))
                                                                                    (get-terrain-type-trait (get-terrain-* (level world) x y 2) +terrain-trait-opaque-floor+))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y :z 2))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))

(set-game-event (make-instance 'game-event :id +game-event-adjust-outdoor-light+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (setf (outdoor-light (level world))
                                                                 (round (- 50 (* 50 (sin (+ 8 (* (/ pi (* 12 60 10)) (player-game-time world))))))))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-win-for-thief+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (>= (get-overall-value (inv *player*)) *thief-win-value*)
                                                                  (or (<= (x *player*) 1) (>= (x *player*) (- (array-dimension (terrain (level world)) 0) 2))
                                                                      (<= (y *player*) 1) (>= (y *player*) (- (array-dimension (terrain (level world)) 1) 2))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                            ;; write highscores
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 0)
                                                                                                                                (if (mimic-id-list *player*)
                                                                                                                                  (faction-name *player*)
                                                                                                                                  (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                (real-game-time world)
                                                                                                                                (format nil "Escaped with $~A." (calculate-total-value *player*))
                                                                                                                                (level-layout (level world)))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
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
                                                                 for x = (random (array-dimension (terrain (level world)) 0))
                                                                 for y = (random (array-dimension (terrain (level world)) 1))
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
