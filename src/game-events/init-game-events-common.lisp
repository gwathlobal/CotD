(in-package :cotd)

(defparameter *game-events-military-list* (list +mob-type-soldier+ +mob-type-soldier+ +mob-type-gunner+ +mob-type-sergeant+ +mob-type-scout+ +mob-type-chaplain+))

(defun dump-when-dead ()
  (let* ((final-str (if (null (killed-by *player*))
                      "Killed by unknown forces."
                      (format nil "Killed by ~A." (killed-by *player*))))
         (score (calculate-player-score 0))
         )
    (values final-str score)
    ))

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-win-for-thief+
                                           :descr-func #'(lambda ()
                                                           "To win, gather at least $1500 worth of items and leave the district by moving to its border. To lose, die or get possessed.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (loyal-faction *player*) +faction-type-criminals+)
                                                                  (>= (get-overall-value (inv *player*)) *thief-win-value*)
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
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-thief-won+ :highscores-place highscores-place
                                                                                                                                          :player-won t :player-died nil))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-eater+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels and demons in the district. To lose, die.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-eater+)
                                                                      (zerop (total-demons world))
                                                                      (zerop (total-angels world)))
                                                                 (and (/= (loyal-faction *player*) +faction-type-eater+)
                                                                      (> (nth +faction-type-military+ (total-faction-list world)) 0)
                                                                      (zerop (total-demons world))
                                                                      (zerop (total-angels world))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           ;; write highscores
                                                           (let* ((final-str (cond
                                                                               ((zerop (total-demons world)) "Enemies of Primordials eliminated.")
                                                                               ))
                                                                  (score (calculate-player-score 1430))
                                                                  (highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                                                                                 score
                                                                                                                                 (if (mimic-id-list *player*)
                                                                                                                                   (faction-name *player*)
                                                                                                                                   (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                                                                                 (player-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (name (world-sector (level world))))
                                                                                                         *highscores*)))
                                                           
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-eater-won+ :highscores-place highscores-place
                                                                                                                                          :player-won t :player-died nil))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-win-for-ghost+
                                           :descr-func #'(lambda ()
                                                           "To win, find the Book of Rituals in the library and read it while standing on a sacrificial circle in the satanists' lair. To lose, die.")
                                           :disabled nil
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
                                                                                                                                 (player-game-time world)
                                                                                                                                 final-str
                                                                                                                                 (name (world-sector (level world))))
                                                                                                          *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
                                                                                          final-str (return-scenario-stats nil))
                                                             
                                                             (add-message (format nil "~%"))
                                                             (add-message (format nil "Congratulations! You have won the game!~%"))
                                                             (add-message (format nil "~%Press any key...~%"))
                                                             (setf *current-window* (make-instance 'cell-window))
                                                             (make-output *current-window*)
                                                             (sdl:with-events ()
                                                               (:quit-event () (funcall (quit-func *current-window*)) t)
                                                               (:key-down-event () 
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-ghost-won+ :highscores-place highscores-place
                                                                                                                                          :player-won t :player-died nil))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))


;;===========================
;; LOSE EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-lose-game-died+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (player-check-dead))
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
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
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
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-dead+ :highscores-place highscores-place
                                                                                                                                          :player-won nil :player-died t))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*)
                                                                                )
                                                               (:video-expose-event () (make-output *current-window*)))))))

(set-game-event (make-instance 'game-event :id +game-event-player-died+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (if (and (player-check-dead)
                                                                  (null (dead-message-displayed *player*)))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (declare (ignore world))
                                                           (add-message (create-string "~%"))
                                                           (add-message (create-string "You are dead.~%"))
                                                           (add-message (create-string "Wait while the scenario is resolved...~%~%"))
                                                                                                                      
                                                           (setf (dead-message-displayed *player*) t))))

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
                                                                                                                                (player-game-time world)
                                                                                                                                final-str
                                                                                                                                (name (world-sector (level world))))
                                                                                                         *highscores*)))
                                                             (write-highscores-to-file *highscores*)
                                                             (dump-character-on-game-over (name *player*) score (player-game-time world) (name (world-sector (level world)))
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
                                                                                (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-possessed+ :highscores-place highscores-place
                                                                                                                                          :player-won nil :player-died nil))
                                                                                (make-output *current-window*)
                                                                                (run-window *current-window*))
                                                               (:video-expose-event () (make-output *current-window*)))))))

;;===========================
;; ENCHANTMENT EVENTS
;;===========================

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
                                                                                                                                                   (prepend-article +article-the+ (visible-name item)))
                                                                                                :color sdl:*white*
                                                                                                :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                              :singlemind)))
                                                                         (invoke-reanimate-body item)
                                                                         (setf corpse-items (remove item corpse-items))
                                                                       ))))
                                                           
                                                           )))

;;===========================
;; OTHER EVENTS
;;===========================

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
                                                                      (round (- 50 (* 50 (sin (+ 8 (* (/ pi (* 12 60 10)) (world-game-time world))))))))))
                                                             ))))


;;===========================
;; ARRIVAL EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-delayed-arrival-military+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (player-game-time world) (turns-for-delayed-military (level world))) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "~%GAME-EVENT: The military has arrived!~%"))

                                                           ;; find a suitable arrival point to accomodate 4 groups of military
                                                           (let ((arrival-point-list (copy-list (delayed-military-arrival-points (level world))))
                                                                 (military-list (list (list (list +mob-type-chaplain+ 1 nil)
                                                                                            (list +mob-type-sergeant+ 1 nil)
                                                                                            (list +mob-type-scout+ 1 nil)
                                                                                            (list +mob-type-soldier+ 3 nil)
                                                                                            (list +mob-type-gunner+ 1 nil))
                                                                                      (list (list +mob-type-chaplain+ 1 nil)
                                                                                            (list +mob-type-sergeant+ 1 nil)
                                                                                            (list +mob-type-scout+ 1 nil)
                                                                                            (list +mob-type-soldier+ 3 nil)
                                                                                            (list +mob-type-gunner+ 1 nil))
                                                                                      (list (list +mob-type-chaplain+ 1 nil)
                                                                                            (list +mob-type-sergeant+ 1 nil)
                                                                                            (list +mob-type-scout+ 1 nil)
                                                                                            (list +mob-type-soldier+ 3 nil)
                                                                                            (list +mob-type-gunner+ 1 nil))
                                                                                      (list (list +mob-type-chaplain+ 1 nil)
                                                                                            (list +mob-type-sergeant+ 1 nil)
                                                                                            (list +mob-type-scout+ 1 nil)
                                                                                            (list +mob-type-soldier+ 3 nil)
                                                                                            (list +mob-type-gunner+ 1 nil)))))

                                                             (when (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-military-chaplain+)
                                                               (setf military-list (remove (first military-list) military-list))
                                                               (push (list (list +mob-type-chaplain+ 1 t)
                                                                           (list +mob-type-sergeant+ 1 nil)
                                                                           (list +mob-type-scout+ 1 nil)
                                                                           (list +mob-type-soldier+ 3 nil)
                                                                           (list +mob-type-gunner+ 1 nil))
                                                                     military-list))

                                                             (when (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-military-scout+)
                                                               (push (list (list +mob-type-scout+ 1 t))
                                                                     military-list))

                                                             (loop for squad-list in military-list do
                                                               (destructuring-bind (mob-type-id mob-num is-player) (first squad-list)
                                                                 (declare (ignore mob-num))
                                                                 (let ((leader (if is-player
                                                                                 (progn
                                                                                   (setf (player-outside-level *player*) nil)
                                                                                   *player*)
                                                                                 (make-instance 'mob :mob-type mob-type-id))))
                                                                   (loop while (> (length arrival-point-list) 0) 
                                                                         for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                                                                         for x = (first random-arrival-point)
                                                                         for y = (second random-arrival-point)
                                                                         for z = (third random-arrival-point)
                                                                         do
                                                                            (setf arrival-point-list (remove random-arrival-point arrival-point-list))
                                                                            
                                                                            (find-unoccupied-place-around (level world) leader x y z)
                                                                            
                                                                            (loop-finish))
                                                                   
                                                                   (setf squad-list (remove (first squad-list) squad-list))
                                                                   
                                                                   (when squad-list
                                                                     (populate-level-with-mobs (level world) squad-list
                                                                                               #'(lambda (level mob)
                                                                                                   (find-unoccupied-place-around level mob (x leader) (y leader) (z leader)))))))
                                                                   )
                                                             (loop for mob-id in (mob-id-list (level world))
                                                                   for horse = (get-mob-by-id mob-id)
                                                                   for rider = (if (mounted-by-mob-id horse)
                                                                                 (get-mob-by-id (mounted-by-mob-id horse))
                                                                                 nil)
                                                                   when rider
                                                                     do
                                                                        (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
                                                             )
                                                           )
                               ))


(set-game-event (make-instance 'game-event :id +game-event-delayed-arrival-angels+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (player-game-time world) (turns-for-delayed-angels (level world))) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "~%GAME-EVENT: The angels have arrived!~%"))

                                                           ;; find suitale arrival points to accomodate chrome angels & trinity mimics
                                                           (let ((arrival-point-list (copy-list (delayed-angels-arrival-points (level world))))
                                                                 (angels-list (list (list +mob-type-angel+ *min-angels-number* nil))))

                                                             (if (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-angel-trinity+)
                                                               (push (list +mob-type-star-singer+ 1 t) angels-list)
                                                               (push (list +mob-type-star-singer+ 1 nil)
                                                                     angels-list))

                                                             (when (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-angel-chrome+)
                                                               (push (list +mob-type-angel+ 1 t)
                                                                     angels-list))

                                                             (loop for (angel-type angel-number is-player) in angels-list do
                                                               (loop repeat angel-number do
                                                                 (if (or (= angel-type +mob-type-star-singer+)
                                                                         (= angel-type +mob-type-star-gazer+)
                                                                         (= angel-type +mob-type-star-mender+))
                                                                   (progn
                                                                     (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place trinity mimics~%"))
                                                                     (loop with is-free = t
                                                                           with mob1 = (if is-player
                                                                                         (progn
                                                                                           (setf (player-outside-level *player*) nil)
                                                                                           *player*)
                                                                                         (make-instance 'mob :mob-type +mob-type-star-singer+))
                                                                           with mob2 = (if is-player
                                                                                         (get-mob-by-id (second (mimic-id-list *player*)))
                                                                                         (make-instance 'mob :mob-type +mob-type-star-gazer+))
                                                                           with mob3 = (if is-player
                                                                                         (get-mob-by-id(third (mimic-id-list *player*)))
                                                                                         (make-instance 'mob :mob-type +mob-type-star-mender+))
                                                                           for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                                                                           for x = (first random-arrival-point)
                                                                           for y = (second random-arrival-point)
                                                                           for z = (third random-arrival-point)
                                                                           do
                                                                              (setf arrival-point-list (remove random-arrival-point arrival-point-list))
                                                                              (setf is-free t)
                                                                              (check-surroundings x y t #'(lambda (dx dy)
                                                                                                            (when (or (not (eq (check-move-on-level mob1 dx dy z) t))
                                                                                                                      (not (get-terrain-type-trait (get-terrain-* (level world) dx dy z) +terrain-trait-opaque-floor+)))
                                                                                                              (setf is-free nil))))
                                                                              (when is-free
                                                                                
                                                                                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                                                                                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                                                                                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                                                                                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                                                                                
                                                                                (setf (x mob1) (1- x) (y mob1) (1- y) (z mob1) z)
                                                                                (add-mob-to-level-list (level world) mob1)
                                                                                (setf (x mob2) (1+ x) (y mob2) (1- y) (z mob2) z)
                                                                                (add-mob-to-level-list (level world) mob2)
                                                                                (setf (x mob3) x (y mob3) (1+ y) (z mob3) z)
                                                                                (add-mob-to-level-list (level world) mob3)
                                                                                
                                                                                (loop-finish))))
                                                                   (progn
                                                                     (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place chrome angels~%"))
                                                                     
                                                                     (loop with angel = (if is-player
                                                                                          (progn
                                                                                            (setf (player-outside-level *player*) nil)
                                                                                            *player*)
                                                                                          (make-instance 'mob :mob-type angel-type))
                                                                           while (> (length arrival-point-list) 0) 
                                                                           for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                                                                           for x = (first random-arrival-point)
                                                                           for y = (second random-arrival-point)
                                                                           for z = (third random-arrival-point)
                                                                           do
                                                                              (setf arrival-point-list (remove random-arrival-point arrival-point-list))
                                                                              
                                                                              (find-unoccupied-place-around (level world) angel x y z)
                                                                              
                                                                              (loop-finish))))
                                                                     ))
                                                             )
                                                           )
                               ))
