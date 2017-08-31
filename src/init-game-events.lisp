(in-package :cotd)

(defparameter *game-events-military-list* (list +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-gunner+ +mob-type-gunner+ +mob-type-sergeant+ +mob-type-scout+ +mob-type-chaplain+))

(set-game-event (make-instance 'game-event :id +game-event-win-for-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (zerop (total-demons world))
                                                                 (and (mob-ability-p *player* +mob-abil-angel+)
                                                                      (= (mob-type *player*) +mob-type-angel+)
                                                                      (>= (cur-fp *player*) (max-fp *player*))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 1400)
                                                                                                                                (faction-name *player*)
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
                                                                                                                                (faction-name *player*)
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
                                                                                                                                (faction-name *player*)
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
                                                         (if (check-dead *player*)
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let ((highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                (calculate-player-score 0)
                                                                                                                                (faction-name *player*)
                                                                                                                                (real-game-time world)
                                                                                                                                (if (null (killed-by *player*))
                                                                                                                                  "Killed by unknown forces."
                                                                                                                                  (format nil "Killed by ~A." (killed-by *player*)))
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
                                                                                                                                (faction-name *player*)
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
                                                                                                                                (faction-name *player*)
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
