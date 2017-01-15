(in-package :cotd)

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
                                                                              (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-angels-won+))
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
                                                         (if (= (game-time world) 2200)
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "GAME-EVENT: Cavalry has arrived!"))
                                                           
                                                           ;; find a suitable place for the military along the map borders
                                                           ;; four groups are created - north, south, east and west
                                                           ;; place the units
                                                           (let ((placement-list-horiz (list (cons (- (truncate *max-x-level* 2) 3) 1)                      ;; north
                                                                                             (cons (- (truncate *max-x-level* 2) 3) (- *max-y-level* 2))))  ;; south
                                                                 (placement-list-vert (list (cons 1 (- (truncate *max-y-level* 2) 3))                       ;; east
                                                                                            (cons (- *max-x-level* 2) (- (truncate *max-y-level* 2) 3)))))  ;; west 

                                                             ;; place for north and south horizontally
                                                             (loop for (sx . sy) in placement-list-horiz do
                                                               (loop for x from 0 to 9
                                                                     when (and (not (get-mob-* (level world) (+ sx x) sy))
                                                                               (not (get-terrain-type-trait (get-terrain-* (level world) (+ sx x) sy) +terrain-trait-blocks-move+)))
                                                                       do
                                                                          (add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-soldier+ :x (+ sx x) :y sy))))

                                                             ;; place for east and west vertically
                                                             (loop for (sx . sy) in placement-list-vert do
                                                               (loop for y from 0 to 9
                                                                     when (and (not (get-mob-* (level world) sx (+ sy y)))
                                                                               (not (get-terrain-type-trait (get-terrain-* (level world) sx (+ sy y)) +terrain-trait-blocks-move+)))
                                                                       do
                                                                          (add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-soldier+ :x sx :y (+ sy y)))))
                                                             ))
                                                           ))
