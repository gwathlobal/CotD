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

(declaim (ftype (function (world &key (:final-str string)
                                 (:score fixnum)
                                 (:if-player-won boolean)
                                 (:player-msg string)
                                 (:game-over-type game-over-enum)
                                 (:mission-result list))
                          null)
                trigger-game-over))
(defun trigger-game-over (world &key final-str score if-player-won player-msg game-over-type mission-result)
    
  (let* ((tmp-world world)
         (tmp-final-str final-str)
         (tmp-score score)
         (tmp-if-player-won if-player-won)
         (tmp-player-msg player-msg)
         (tmp-game-over-type game-over-type)
         (highscores-place)
         (player-died (player-check-dead))
         (tmp-mission-result (copy-list mission-result)))
    (declare (type string tmp-final-str player-msg) (type boolean tmp-if-player-won) (type fixnum tmp-score) (type game-over-enum game-over-type))
    
    (when player-died
      (multiple-value-setq (tmp-final-str tmp-score) (dump-when-dead)))
    
    (setf highscores-place (add-highscore-record (make-highscore-record (name *player*)
                                                                        tmp-score
                                                                        (if (mimic-id-list *player*)
                                                                          (faction-name *player*)
                                                                          (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))
                                                                        (player-game-time tmp-world)
                                                                        tmp-final-str
                                                                        (name (world-sector (level tmp-world))))
                                                 *highscores*))
    
    (write-highscores-to-file *highscores*)
    (dump-character-on-game-over (name *player*) tmp-score (player-game-time tmp-world) (name (world-sector (level tmp-world)))
                                 tmp-final-str (return-scenario-stats nil))

    ;; increase world flesh points
    (when (or (eq tmp-game-over-type :game-over-demons-won)
              (eq tmp-game-over-type :game-over-satanists-won))
      (when (null (getf tmp-mission-result :flesh-points))
        (loop with sum = 0
              for item-id in (item-id-list (level tmp-world))
              for item = (get-item-by-id item-id)
              when (item-ability-p item +item-abil-corpse+) do 
                (incf sum (item-ability-p item +item-abil-corpse+))
              finally (setf (getf tmp-mission-result :flesh-points) (truncate sum 40)))))

    (setf (getf tmp-mission-result :mission-result) tmp-game-over-type)
    
    (setf (level/mission-result (level tmp-world)) tmp-mission-result)

    (add-message (format nil "~%"))
    (add-message tmp-player-msg)
    (add-message (format nil "~%Press any key...~%"))
    
    (setf *current-window* (make-instance 'cell-window))
    (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
    (make-output *current-window*)
    (sdl:with-events ()
      (:quit-event () (funcall (quit-func *current-window*)) t)
      (:key-down-event () 
                       (setf *current-window* (make-instance 'final-stats-window :game-over-type tmp-game-over-type :highscores-place highscores-place
                                                                                 :player-won tmp-if-player-won :player-died player-died))
                       (make-output *current-window*)
                       (run-window *current-window*))
      (:video-expose-event () (make-output *current-window*)))
    )
  nil)

(defun get-demon-raid-overall-points (world)
  (loop for feature-id in (demonic-portals (level world))
        for feature = (get-feature-by-id feature-id)
        when (= (feature-type feature) +feature-demonic-portal+)
          sum (if (param1 feature)
                (param1 feature)
                0)))

(defun get-demon-steal-check-relic-captured (world)
  (loop for feature-id in (feature-id-list (level world))
        for feature = (get-feature-by-id feature-id)
        when (= (feature-type feature) +feature-demonic-portal+)
          do
             (when (param1 feature)
               (return-from get-demon-steal-check-relic-captured t))
        )
  nil)

(defun get-demon-conquest-turns-left (world)
  (multiple-value-bind (sigils-num max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
    (declare (ignore max-turns))
    (loop for sigil-id in (stable-sort (demonic-sigils (level world)) #'(lambda (a b)
                                                                          (if (> (param1 (get-effect-by-id (mob-effect-p (get-mob-by-id a) +mob-effect-demonic-sigil+)))
                                                                                 (param1 (get-effect-by-id (mob-effect-p (get-mob-by-id b) +mob-effect-demonic-sigil+))))
                                                                            t
                                                                            nil)))
          repeat sigils-num
          for sigil = (get-mob-by-id sigil-id)
          for effect = (get-effect-by-id (mob-effect-p sigil +mob-effect-demonic-sigil+))
          minimize (param1 effect))))

(defun get-military-conquest-check-alive-sigils (level)
  (if (> (length (demonic-sigils level)) 0)
    t
    nil))

(defun get-angel-steal-angel-with-relic (world)
  (let ((relic-item (if (level/relic-id (level world))
                      (get-item-by-id (level/relic-id (level world)))
                      nil)))
    (when (and relic-item
               (inv-id relic-item)
               (mob-ability-p (get-mob-by-id (inv-id relic-item)) +mob-type-angel+))
      (return-from get-angel-steal-angel-with-relic (get-mob-by-id (inv-id relic-item)))))
  nil)

(defun get-angel-sabotage-check-alive-machines (level)
  (if (> (length (demonic-machines level)) 0)
    t
    nil))

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

                                                           (trigger-game-over world
                                                                              :final-str (format nil "Escaped with $~A." (calculate-total-value *player*))
                                                                              :score (calculate-player-score 0)
                                                                              :if-player-won t
                                                                              :player-msg (format nil "Congratulations! You have won the game!~%")
                                                                              :game-over-type :game-over-thief-won)
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-win-for-eater+
                                           :descr-func #'(lambda ()
                                                           "To win, destroy all angels and demons in the district. To lose, die.")
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (or (and (= (loyal-faction *player*) +faction-type-eater+)
                                                                      (zerop (total-demons (level world)))
                                                                      (zerop (total-angels (level world))))
                                                                 (and (/= (loyal-faction *player*) +faction-type-eater+)
                                                                      (> (nth +faction-type-military+ (total-faction-list (level world))) 0)
                                                                      (zerop (total-demons (level world)))
                                                                      (zerop (total-angels (level world)))))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (trigger-game-over world
                                                                              :final-str "Enemies of Primordials eliminated."
                                                                              :score (calculate-player-score 1430)
                                                                              :if-player-won t
                                                                              :player-msg (format nil "Congratulations! You have won the game!~%")
                                                                              :game-over-type :game-over-eater-won)
                                                           )))

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
                                                           (trigger-game-over world
                                                                              :final-str "Put itself to rest."
                                                                              :score (calculate-player-score 1450)
                                                                              :if-player-won t
                                                                              :player-msg (format nil "Congratulations! You have won the game!~%")
                                                                              :game-over-type :game-over-ghost-won)
                                                           )))


;;===========================
;; LOSE EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-lose-game-died+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         (player-check-dead))
                                           :on-trigger #'(lambda (world)
                                                           (trigger-game-over world
                                                                              :if-player-won nil
                                                                              :player-msg (format nil "You are dead.~%")
                                                                              :game-over-type :game-over-player-dead)
                                                           )))

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
                                                           (trigger-game-over world
                                                                              :final-str (format nil "Possessed by ~A." (get-qualified-name (get-mob-by-id (master-mob-id *player*))))
                                                                              :score (calculate-player-score 0)
                                                                              :if-player-won nil
                                                                              :player-msg (format nil "You are possessed.~%")
                                                                              :game-over-type :game-over-player-possessed)
                                                           )))

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
                                                           (let ((military-list (list (list (list +mob-type-chaplain+ 1 nil)
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
                                                                   (loop with arrival-point-list = (copy-list (delayed-military-arrival-points (level world)))
                                                                         while (> (length arrival-point-list) 0) 
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
                                                           (let ((angels-list (list (list +mob-type-angel+ *min-angels-number* nil))))

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
                                                                     (loop with arrival-point-list = (copy-list (delayed-angels-arrival-points (level world)))
                                                                           with is-free = t
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
                                                                           while (> (length arrival-point-list) 0) 
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
                                                                     
                                                                     (loop with arrival-point-list = (copy-list (delayed-angels-arrival-points (level world)))
                                                                           with angel = (if is-player
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

(set-game-event (make-instance 'game-event :id +game-event-delayed-arrival-demons+ :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (= (player-game-time world) (turns-for-delayed-demons (level world))) (turn-finished world))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (logger (format nil "~%GAME-EVENT: The demons have arrived!~%"))

                                                           ;; find suitale arrival points to accomodate demons
                                                           (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
                                                             (declare (ignore year month day min sec))
                                                             (let ((demon-list (if (and (>= hour 7) (< hour 19))
                                                                                  (list (list +mob-type-archdemon+ 1 nil)
                                                                                        (list +mob-type-demon+ 15 nil)
                                                                                        (list +mob-type-imp+ *min-imps-number* nil))
                                                                                  (list (if (zerop (random 2))
                                                                                          (list +mob-type-archdemon+ 1 nil)
                                                                                          (list +mob-type-shadow-devil+ 1 nil))
                                                                                        (list +mob-type-demon+ 7 nil)
                                                                                        (list +mob-type-shadow-demon+ 8 nil)
                                                                                        (list +mob-type-imp+ (truncate *min-imps-number* 2) nil)
                                                                                        (list +mob-type-shadow-imp+ (truncate *min-imps-number* 2) nil)))))
                                                               
                                                               (if (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-demon-malseraph+)
                                                                 (push (list +mob-type-malseraph-puppet+ 1 t) demon-list)
                                                                 (push (list +mob-type-malseraph-puppet+ 1 nil) demon-list))

                                                               (when (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-demon-crimson+)
                                                                 (push (list +mob-type-imp+ 1 t) demon-list))

                                                               (when (= (player-lvl-mod-placement-id (mission (level world))) +lm-placement-demon-shadow+)
                                                                 (push (list +mob-type-shadow-imp+ 1 t) demon-list))

                                                               (loop for (demon-type demon-number is-player) in demon-list do
                                                                 (loop repeat demon-number do
                                                                   (loop with arrival-point-list = (copy-list (delayed-demons-arrival-points (level world)))
                                                                         with demon = (if is-player
                                                                                        (progn
                                                                                          (setf (player-outside-level *player*) nil)
                                                                                          *player*)
                                                                                        (make-instance 'mob :mob-type demon-type))
                                                                         while (> (length arrival-point-list) 0) 
                                                                         for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                                                                         for x = (first random-arrival-point)
                                                                         for y = (second random-arrival-point)
                                                                         for z = (third random-arrival-point)
                                                                         do
                                                                            (setf arrival-point-list (remove random-arrival-point arrival-point-list))
                                                                            
                                                                            (find-unoccupied-place-around (level world) demon x y z)
                                                                            
                                                                            (loop-finish))))
                                                               ))
                                                           )
                               ))
