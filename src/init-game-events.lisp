(in-package :cotd)

(defparameter *game-events-military-list* (list +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-soldier+ +mob-type-gunner+ +mob-type-gunner+ +mob-type-sergeant+ +mob-type-sergeant+ +mob-type-chaplain+))

(set-game-event (make-instance 'game-event :id +game-event-win-for-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (zerop (total-demons world))
                                                                 (and (mob-ability-p *player* +mob-abil-angel+)
                                                                      (= (mob-type *player*) +mob-type-archangel+)
                                                                      (>= (cur-fp *player*) (max-fp *player*))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (declare (ignore world))
                                                           (add-message (format nil "~%"))
                                                           (add-message (format nil "Congratulations! You have won the game!~%"))
                                                           (setf *current-window* (make-instance 'cell-window))
                                                           (make-output *current-window*)
                                                           (sdl:with-events ()
                                                             (:quit-event () (funcall (quit-func *current-window*)) t)
                                                             (:key-down-event () 
                                                                              (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-angels-won+))
                                                                              (make-output *current-window*)
                                                                              (run-window *current-window*))
                                                             (:video-expose-event () (make-output *current-window*))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-demons+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (zerop (total-angels world))
                                                                 (and (mob-ability-p *player* +mob-abil-demon+)
                                                                      (= (mob-type *player*) +mob-type-archdemon+)
                                                                      (>= (cur-fp *player*) (max-fp *player*))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (declare (ignore world))
                                                           (add-message (format nil "~%"))
                                                           (add-message (format nil "Congratulations! You have won the game!~%"))
                                                           (setf *current-window* (make-instance 'cell-window))
                                                           (make-output *current-window*)
                                                           (sdl:with-events ()
                                                             (:quit-event () (funcall (quit-func *current-window*)) t)
                                                             (:key-down-event () 
                                                                              (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-demons-won+))
                                                                              (make-output *current-window*)
                                                                              (run-window *current-window*))
                                                             (:video-expose-event () (make-output *current-window*))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-humans+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (zerop (total-demons world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (declare (ignore world))
                                                           (add-message (format nil "~%"))
                                                           (add-message (format nil "Congratulations! You have won the game!~%"))
                                                           (setf *current-window* (make-instance 'cell-window))
                                                           (make-output *current-window*)
                                                           (sdl:with-events ()
                                                             (:quit-event () (funcall (quit-func *current-window*)) t)
                                                             (:key-down-event () 
                                                                              (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-military-won+))
                                                                              (make-output *current-window*)
                                                                              (run-window *current-window*))
                                                             (:video-expose-event () (make-output *current-window*))))))

(set-game-event (make-instance 'game-event :id +game-event-lose-game+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (if (check-dead *player*)
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (declare (ignore world))
                                                           (add-message (create-string "~%"))
                                                           (add-message (create-string "You are dead.~%"))
                                                           (setf *current-window* (make-instance 'cell-window))
                                                           (update-visible-area (level *world*) (x *player*) (y *player*))
                                                           (make-output *current-window*)
                                                           (sdl:with-events ()
                                                             (:quit-event () (funcall (quit-func *current-window*)) t)
                                                             (:key-down-event () 
                                                                              (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-dead+))
                                                                              (make-output *current-window*)
                                                                              (run-window *current-window*))
                                                             (:video-expose-event () (make-output *current-window*))))))

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
                                                                                             (cons 1 (- *max-y-level* 2))                      ;; south-east
                                                                                             (cons (- *max-x-level* 15) 1)                     ;; north-west
                                                                                             (cons (- *max-x-level* 15) (- *max-y-level* 2)))) ;; south-west
                                                                 )
                                                                 

                                                             ;; place for north and south horizontally
                                                             (loop for (sx . sy) in placement-list-horiz do
                                                               (loop for x from 0 to 9
                                                                     for military-picked = (nth (random (length *game-events-military-list*)) *game-events-military-list*)
                                                                     when (and (not (get-mob-* (level world) (+ sx x) sy))
                                                                               (not (get-terrain-type-trait (get-terrain-* (level world) (+ sx x) sy) +terrain-trait-blocks-move+)))
                                                                       do
                                                                          (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x (+ sx x) :y sy))))
                                                             
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
                                                                 when (= (get-terrain-* (level world) x y) +terrain-floor-snow-prints+)
                                                                   do
                                                                      (logger (format nil "GAME-EVENT: Snow falls at (~A ~A)~%" x y))
                                                                      (set-terrain-* (level world) x y +terrain-floor-snow+))
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
                                                           (loop for y from 0 below *max-y-level*
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below *max-x-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
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
                                                           (loop for y from (1- *max-y-level*) downto 0
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below *max-x-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
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
                                                           (loop for x from 0 below *max-x-level*
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below *max-y-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
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
                                                           (loop for x from (1- *max-x-level*) downto 0 
                                                                 with max-units = 40
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below *max-y-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
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
                                                           (loop for x from (1- *max-x-level*) downto 0 
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below *max-y-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the western piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for x from 0 below *max-x-level*
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for y from 0 below *max-y-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the southern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from (1- *max-y-level*) downto 0
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below *max-x-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))

                                                           ;; find the suitable place on the northern piers for the military
                                                           ;; place the units until the total number is reached
                                                           (loop for y from 0 below *max-y-level*
                                                                 with max-units = 10
                                                                 with military-list = *game-events-military-list*
                                                                 do
                                                                    (loop for x from 0 below *max-x-level*
                                                                          for military-picked = (nth (random (length military-list)) military-list)
                                                                          when (and (not (get-mob-* (level world) x y))
                                                                                    (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                                                                            do
                                                                               (add-mob-to-level-list (level world) (make-instance 'mob :mob-type military-picked :x x :y y))
                                                                               (decf max-units)
                                                                               (when (zerop max-units) (loop-finish)))
                                                                    (when (zerop max-units) (loop-finish)))
                                                           )
                               ))
