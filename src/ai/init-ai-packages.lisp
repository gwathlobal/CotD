(in-package :cotd)

(set-ai-package (make-instance 'ai-package :id +ai-package-coward+
                                           :priority 9
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if nearest-enemy
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-ally hostile-mobs allied-mobs check-result))
                                                             (logger (format nil "AI-PACKAGE-COWARD: ~A [~A] is in fear with an enemy ~A [~A].~%" (name actor) (id actor) (name nearest-enemy) (id nearest-enemy)))
                                                             (ai-mob-flee actor nearest-enemy)
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-split-soul+
                                           :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if nearest-enemy
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-ally hostile-mobs allied-mobs check-result))
                                                             (logger (format nil "AI-PACKAGE-SPLIT-SOUL: ~A [~A] is trying to move away from the enemy ~A [~A].~%" (name actor) (id actor) (name nearest-enemy) (id nearest-enemy)))

                                                             (if (mob-ability-p actor +mob-abil-immobile+)
                                                               (move-mob actor 5)
                                                               (progn
                                                                 ;; 1) find the tile farthest from the nearest enemy
                                                                 (let ((farthest-tile nil))
                                                                   (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                                   (when (eq (check-move-on-level actor dx dy (z actor)) t)
                                                                                                                     (unless farthest-tile
                                                                                                                       (setf farthest-tile (list dx dy (z actor))))
                                                                                                                     (when (> (get-distance dx dy (x nearest-enemy) (y nearest-enemy))
                                                                                                                              (get-distance (first farthest-tile) (second farthest-tile) (x nearest-enemy) (y nearest-enemy)))
                                                                                                                       (setf farthest-tile (list dx dy (z actor)))))))
                                                                   (if farthest-tile
                                                                     (setf (path-dst actor) farthest-tile)
                                                                     (setf (path-dst actor) (list (x actor) (y actor) (z actor))))
                                                                   )

                                                                 ;; 2) move to that tile
                                                                 (move-mob actor (x-y-into-dir (- (first (path-dst actor)) (x actor))
                                                                                               (- (second (path-dst actor)) (y actor))))
                                                                 ))
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-horde+
                                           :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-enemy nearest-ally))
                                                            (let ((ally-str (strength actor))
                                                                  (enemy-str 0))
                                                              (declare (type fixnum ally-str enemy-str))
                                                              (dolist (ally-id allied-mobs)
                                                                 (declare (type fixnum ally-id))
                                                                 (incf ally-str (strength (get-mob-by-id ally-id))))
                                                              (dolist (enemy-id hostile-mobs)
                                                                 (incf enemy-str (strength (get-mob-type-by-id (face-mob-type-id (get-mob-by-id enemy-id))))))
                                                              
                                                              (logger (format nil "AI-PACKAGE-HORDE: ~A [~A] has horde behavior. Ally vs. Enemy strength is ~A vs ~A.~%" (name actor) (id actor) ally-str enemy-str))
                                                              (if (< ally-str enemy-str)
                                                                t
                                                                nil))
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-ally allied-mobs hostile-mobs check-result))

                                                             ;; if the mob has horde behavior, compare relative strengths of allies to relative strength of enemies
                                                             ;; if less - flee
                                                             (ai-mob-flee actor nearest-enemy)
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-wants-bless+
                                           :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs))
                                                            (let ((nearest-ally nil))
                                                              (loop for mob-id of-type fixnum in allied-mobs
                                                                    for target-mob = (get-mob-by-id mob-id)
                                                                    with vis-mob-type = nil
                                                                    do
                                                                       (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id target-mob)))
                                                                       ;; when you are of the same faction, you know who is who
                                                                       (when (= (faction actor) (faction target-mob))
                                                                         (setf vis-mob-type (get-mob-type-by-id (mob-type target-mob))))
                                                                       
                                                                       ;; find the nearest allied unblessed mob mob
                                                                       (when (and (mob-ability-p vis-mob-type +mob-abil-can-be-blessed+)
                                                                                  (not (mob-effect-p target-mob +mob-effect-blessed+))
                                                                                  (not (= (mob-type target-mob) +mob-type-ghost+)))
                                                                         (unless nearest-ally
                                                                           (setf nearest-ally target-mob))
                                                                         (when (< (get-distance (x target-mob) (y target-mob) (x actor) (y actor))
                                                                                  (get-distance (x nearest-ally) (y nearest-ally) (x actor) (y actor)))
                                                                           (setf nearest-ally target-mob)))
                                                                    )
                                                              (logger (format nil "AI-PACKAGE-WANTS-TO-BLESS: ~A [~A] thinks of giving blessings. Nearest unblessed ally ~A [~A]~%"
                                                                              (name actor) (id actor) (if nearest-ally (name nearest-ally) nil) (if nearest-ally (id nearest-ally) nil)))
                                                              (if (or (and nearest-ally
                                                                           (not nearest-enemy))
                                                                      (and nearest-ally
                                                                           nearest-enemy
                                                                           (< (get-distance (x actor) (y actor) (x nearest-ally) (y nearest-ally))
                                                                              (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)))))
                                                                nearest-ally
                                                                nil)
                                                              ))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs))

                                                             (logger (format nil "AI-PACKAGE-WANTS-TO-BLESS: ~A [~A] decided to give blessings to ~A [~A]~%"
                                                                             (name actor) (id actor) (if check-result (name check-result) nil) (if check-result (id check-result) nil)))
                                                             (loop with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     ;; set path-dst to the allied mob if there is no path-dst or it is different from the allied mob position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x check-result))
                                                                               (/= (second (path-dst actor)) (y check-result))
                                                                               (/= (third (path-dst actor)) (z check-result)))
                                                                       (ai-set-path-dst actor (x check-result) (y check-result) (z check-result)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                           (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; if the target is close enough and the actor has divinity concealed - transform
                                                                     (let ((check-result)
                                                                           (ability (get-ability-type-by-id +mob-abil-reveal-divine+)))
                                                                       (setf check-result (funcall (on-check-ai ability) ability actor nearest-enemy nearest-ally))
                                                                       (when check-result
                                                                         (logger (format nil "AI-PACKAGE-WANTS-TO-BLESS: ~A [~A] decides to invoke ability ~A~%" (name actor) (id actor) (name ability)))
                                                                         (funcall (on-invoke-ai ability) ability actor nearest-enemy nearest-ally check-result)
                                                                         (loop-finish)))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-cautious+
                                           :priority +ai-priority-never+
                                           ))

(set-ai-package (make-instance 'ai-package :id +ai-package-trinity-mimic+
                                           :priority +ai-priority-always+
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-enemy nearest-ally hostile-mobs allied-mobs))
                                                            t)
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs check-result))

                                                             ;; if the mob is a trinity mimic, assign the first one as a leader and make all others in the group follow it
                                                             (setf (order actor) nil)
                                                             (loop for mimic-id in (mimic-id-list actor)
                                                                   for mimic = (get-mob-by-id mimic-id)
                                                                   when (and (not (eq mimic actor))
                                                                             (not (check-dead mimic))
                                                                             (not (is-merged mimic)))
                                                                     do
                                                                        (setf (order actor) (list +mob-order-follow+ mimic-id))
                                                                        (logger (format nil "AI-PACKAGE-TRINITY-MIMIC: ~A [~A] has to follow ~A [~A].~%"
                                                                                        (name actor) (id actor) (name mimic) (id mimic)))
                                                                        (loop-finish))
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-takes-valuable-items+
                                           :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (let ((valuable-items (loop for item-id in (get-items-* (level *world*) (x actor) (y actor) (z actor))
                                                                                        for item = (get-item-by-id item-id)
                                                                                        when (not (zerop (value item)))
                                                                                          collect item)))
                                                              (if (and (null nearest-enemy)
                                                                       valuable-items)
                                                                valuable-items
                                                                nil)))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             (logger (format nil "AI-PACKAGE-TAKES-ITEMS: ~A [~A] decided to take item ~A [~A].~%"
                                                                             (name actor) (id actor) (name (first check-result)) (id (first check-result))))
                                                             (mob-pick-item actor (first check-result))
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-kleptomaniac+
                                           :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (let ((valuable-items))
                                                              (if (and (null nearest-enemy)
                                                                       (setf valuable-items (loop for item-id in (visible-items actor)
                                                                                                  for item = (get-item-by-id item-id)
                                                                                                  when (and (not (zerop (value item)))
                                                                                                            (not (and (= (x item) (x actor))
                                                                                                                      (= (y item) (y actor))
                                                                                                                      (= (z item) (z actor))))
                                                                                                            (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x item) (y item) (z item)
                                                                                                                                         (if (riding-mob-id actor)
                                                                                                                                           (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                           (map-size actor))
                                                                                                                                         (get-mob-move-mode actor))
                                                                                                                (and (> (map-size actor) 1)
                                                                                                                     (ai-find-move-around actor (x item) (y item)))))
                                                                                                    collect item)))
                                                                valuable-items
                                                                nil)))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; when mob is kleptomaniac and has no target
                                                             ;; sort all items by distance from the actor
                                                             (loop with visible-items = (stable-sort check-result #'(lambda (a b)
                                                                                                                      (if (< (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                             (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                        t
                                                                                                                        nil)))
                                                                   with item = (first visible-items)
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-KLEPTOMANIAC: Mob (~A ~A ~A) wants to get item ~A [~A] at (~A, ~A, ~A)~%"
                                                                                     (x actor) (y actor) (z actor) (name item) (id item) (x item) (y item) (z item)))
                                                                     ;; set path-dst to the nearest item if there is no path-dst or it is different from the item position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x item))
                                                                               (/= (second (path-dst actor)) (y item))
                                                                               (/= (third (path-dst actor)) (z item)))
                                                                       (ai-set-path-dst actor (x item) (y item) (z item)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                           (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-curious+
                                           :priority 5
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (let ((heard-sounds))
                                                              (if (and (null nearest-enemy)
                                                                       (setf heard-sounds (loop for sound in (heard-sounds actor)
                                                                                                when (and (not (and (= (sound-x sound) (x actor))
                                                                                                                    (= (sound-y sound) (y actor))
                                                                                                                    (= (sound-z sound) (z actor))))
                                                                                                          (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (sound-x sound) (sound-y sound) (sound-z sound)
                                                                                                                                       (if (riding-mob-id actor)
                                                                                                                                         (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                         (map-size actor))
                                                                                                                                       (get-mob-move-mode actor))
                                                                                                              (and (> (map-size actor) 1)
                                                                                                                   (ai-find-move-around actor (sound-x sound) (sound-y sound)))))
                                                                                                  collect sound))
                                                                       )
                                                                heard-sounds
                                                                nil)))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; if the mob is curious and it has nothing to do - move to the nearest sound, if any
                                                             (loop with heard-sounds = (stable-sort check-result #'(lambda (a b)
                                                                                                                     (if (< (get-distance-3d (x actor) (y actor) (z actor) (sound-x a) (sound-y a) (sound-z a))
                                                                                                                            (get-distance-3d (x actor) (y actor) (z actor) (sound-x b) (sound-y b) (sound-z b)))
                                                                                                                       t
                                                                                                                       nil)))
                                                                   with sound = (first heard-sounds)
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-CURIOUS: Mob (~A ~A ~A) wants to investigate sound at (~A, ~A, ~A)~%"
                                                                                     (x actor) (y actor) (z actor) (sound-x sound) (sound-y sound) (sound-z sound)))
                                                                     ;; set path-dst to the nearest sound if there is no path-dst or it is different from the sound position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (sound-x sound))
                                                                               (/= (second (path-dst actor)) (sound-y sound))
                                                                               (/= (third (path-dst actor)) (sound-z sound)))
                                                                       (ai-set-path-dst actor (sound-x sound) (sound-y sound) (sound-z sound)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                               (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-cannibal+
                                           :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (let ((corpse-items))
                                                              (if (and (null nearest-enemy)
                                                                       (setf corpse-items (loop for item-id in (visible-items actor)
                                                                                                for item = (get-item-by-id item-id)
                                                                                                when (and (item-ability-p item +item-abil-corpse+)
                                                                                                          (not (and (= (x item) (x actor))
                                                                                                                    (= (y item) (y actor))
                                                                                                                    (= (z item) (z actor))))
                                                                                                          (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x item) (y item) (z item)
                                                                                                                                       (if (riding-mob-id actor)
                                                                                                                                         (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                         (map-size actor))
                                                                                                                                       (get-mob-move-mode actor))
                                                                                                              (and (> (map-size actor) 1)
                                                                                                                   (ai-find-move-around actor (x item) (y item)))))
                                                                                                  collect item)))
                                                                corpse-items
                                                                nil)))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; when mob is a cannibal go to the nearest visible item and try to eat it
                                                             (loop with visible-items = (stable-sort check-result #'(lambda (a b)
                                                                                                                      (if (< (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                             (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                        t
                                                                                                                        nil)))
                                                                   with item = (first visible-items)
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-CANNIBAL: Mob (~A ~A ~A) wants to get item ~A [~A] at (~A, ~A, ~A)~%"
                                                                                     (x actor) (y actor) (z actor) (name item) (id item) (x item) (y item) (z item)))
                                                                     ;; set path-dst to the nearest item if there is no path-dst or it is different from the item position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x item))
                                                                               (/= (second (path-dst actor)) (y item))
                                                                               (/= (third (path-dst actor)) (z item)))
                                                                       (ai-set-path-dst actor (x item) (y item) (z item)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                               (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-use-ability+
                                           :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore hostile-mobs allied-mobs))
                                                            (let ((ability-list (loop for ability-id being the hash-key in (abilities actor)
                                                                                      for ability = (get-ability-type-by-id ability-id)
                                                                                      for func of-type function = (on-check-ai ability)
                                                                                      with check-result = nil 
                                                                                      when (and func
                                                                                                (setf check-result (funcall func ability actor nearest-enemy nearest-ally)))
                                                                                        collect (list ability check-result))))
                                                              (if ability-list
                                                                ability-list
                                                                nil))
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs))

                                                             ;; randomly choose one ability and invoke it
                                                             (let ((ability-list check-result)
                                                                   (r 0))
                                                               (declare (type fixnum r)
                                                                        (type list ability-list))
                                                               (setf r (random (length ability-list)))
                                                               (let ((ai-invoke-func (on-invoke-ai (first (nth r ability-list)))))
                                                                 (declare (type function ai-invoke-func))
                                                                 (logger (format nil "AI-PACKAGE-USE-ABILITY: ~A [~A] decides to invoke ability ~A~%" (name actor) (id actor) (name (first (nth r ability-list)))))
                                                                 (funcall ai-invoke-func (first (nth r ability-list)) actor nearest-enemy nearest-ally (second (nth r ability-list))))
                                                               )
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-use-item+
                                           :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore hostile-mobs allied-mobs))
                                                            (let ((item-list (loop for item-id in (inv actor)
                                                                                   for item = (get-item-by-id item-id)
                                                                                   for ai-check-func of-type function = (on-check-ai item)
                                                                                   for use-func of-type function = (on-use item)
                                                                                   with check-result = nil 
                                                                                   when (and use-func
                                                                                             ai-check-func
                                                                                             (setf check-result (funcall ai-check-func actor item nearest-enemy nearest-ally)))
                                                                                     collect (list item check-result))))
                                                              (if item-list
                                                                item-list
                                                                nil))
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs))

                                                             ;; randomly choose one item and invoke it
                                                             (let ((item-list check-result)
                                                                   (r 0))
                                                               (declare (type fixnum r)
                                                                        (type list item-list))
                                                               (setf r (random (length item-list)))
                                                               (let ((ai-invoke-func (ai-invoke-func (first (nth r item-list)))))
                                                                 (logger (format nil "AI-PACKAGE-USE-ITEM: ~A [~A] decides to use item ~A [~A]~%"
                                                                                 (name actor) (id actor) (name (first (nth r item-list))) (id (first (nth r item-list)))))
                                                                 (funcall ai-invoke-func actor (first (nth r item-list)) nearest-enemy nearest-ally (second (nth r item-list))))
                                                               )
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-reload-ranged-weapon+
                                           :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (is-weapon-ranged actor)
                                                                     (or (not (mob-can-shoot actor))
                                                                         (and (not nearest-enemy)
                                                                              (get-ranged-weapon-max-charges actor)
                                                                              (< (get-ranged-weapon-charges actor) (get-ranged-weapon-max-charges actor)))))
                                                              t
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs nearest-enemy nearest-ally check-result))

                                                             ;; if no bullets in magazine - reload
                                                             ;; or
                                                             ;; if no enemy in sight and the magazine is not full - reload it
                                                             (mob-reload-ranged-weapon actor)
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-shoot-enemy+
                                           :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (is-weapon-ranged actor)
                                                                     (mob-can-shoot actor)
                                                                     nearest-enemy
                                                                     (let ((tx 0) (ty 0) (tz 0)
                                                                           (ex (x nearest-enemy)) (ey (y nearest-enemy)) (ez (z nearest-enemy)))
                                                                       (declare (type fixnum tx ty tz ex ey ez))
                                                                       (line-of-sight (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)
                                                                                      #'(lambda (dx dy dz prev-cell)
                                                                                          (declare (type fixnum dx dy dz))
                                                                                          (let ((exit-result t))
                                                                                            (block nil
                                                                                              (setf tx dx ty dy tz dz)
                                                                                              
                                                                                              (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                                (setf exit-result 'exit)
                                                                                                (return))
                                                                                              
                                                                                              )
                                                                                            exit-result)))
                                                                       (if (and (= tx ex)
                                                                                (= ty ey)
                                                                                (= tz ez))
                                                                         t
                                                                         nil)))
                                                              t
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs nearest-ally check-result))

                                                             ;; if can shoot and there is an enemy in sight - shoot it
                                                             (mob-shoot-target actor nearest-enemy)
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-follow-leader+
                                           :priority 6
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (order actor)
                                                                     (= (first (order actor)) +mob-order-follow+)
                                                                     (not nearest-enemy))
                                                              (progn
                                                                ;; a hack - while you check the conditions you also remove the order if the leader is dead 
                                                                (let ((leader (get-mob-by-id (second (order actor)))))
                                                                  (if (check-dead leader)
                                                                    (progn
                                                                      (setf (order actor) nil)
                                                                      nil)
                                                                    (progn
                                                                      (if (and (< (get-distance (x actor) (y actor) (x leader) (y leader)) 8)
                                                                               (> (get-distance (x actor) (y actor) (x leader) (y leader)) 2)
                                                                               (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x leader) (y leader) (z leader)
                                                                                                            (if (riding-mob-id actor)
                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                              (map-size actor))
                                                                                                            (get-mob-move-mode actor))
                                                                                   (and (> (map-size actor) 1)
                                                                                        (ai-find-move-around actor (x leader) (y leader)))))
                                                                        leader
                                                                        nil)))
                                                                  ))
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs allied-mobs nearest-ally))

                                                             (loop with leader = check-result
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-FOLLOW-LEADER: ~A [~A] (~A, ~A, ~A) wants to follow ~A [~A] at (~A, ~A, ~A)~%"
                                                                                     (name actor) (id actor) (x actor) (y actor) (z actor) (name leader) (id leader) (x leader) (y leader) (z leader)))
                                                                     ;; set path-dst to the leader if there is no path-dst or it is different from the leader position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x leader))
                                                                               (/= (second (path-dst actor)) (y leader))
                                                                               (/= (third (path-dst actor)) (z leader)))
                                                                       (ai-set-path-dst actor (x leader) (y leader) (z leader)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                               (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-approach-target+
                                           :priority 6
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-enemy nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (order actor)
                                                                     (= (first (order actor)) +mob-order-target+))
                                                              (progn
                                                                ;; a hack - while you check the conditions you also remove the order if the target is dead 
                                                                (let ((target (get-mob-by-id (second (order actor)))))
                                                                  (if (check-dead target)
                                                                    (progn
                                                                      (setf (order actor) nil)
                                                                      nil)
                                                                    (progn
                                                                      (if (and (find (id target) (visible-mobs actor))
                                                                               (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x target) (y target) (z target)
                                                                                                            (if (riding-mob-id actor)
                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                              (map-size actor))
                                                                                                            (get-mob-move-mode actor))
                                                                                   (and (> (map-size actor) 1)
                                                                                        (ai-find-move-around actor (x target) (y target)))))
                                                                        target
                                                                        nil)))
                                                                  ))
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs allied-mobs nearest-ally))

                                                             (loop with target = check-result
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-APPROACH-TARGET: ~A [~A] (~A, ~A, ~A) wants to go to ~A [~A] at (~A, ~A, ~A)~%"
                                                                                     (name actor) (id actor) (x actor) (y actor) (z actor) (name target) (id target) (x target) (y target) (z target)))
                                                                     ;; set path-dst to the target if there is no path-dst or it is different from the target position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x target))
                                                                               (/= (second (path-dst actor)) (y target))
                                                                               (/= (third (path-dst actor)) (z target)))
                                                                       (ai-set-path-dst actor (x target) (y target) (z target)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                               (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-attack-nearest-enemy+
                                           :priority 5
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and nearest-enemy
                                                                     (or (not (mob-get-ai-package actor +ai-package-cautious+))
                                                                         (and (mob-get-ai-package actor +ai-package-cautious+)
                                                                              (>= (strength actor) (strength nearest-enemy))))
                                                                     (or (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)
                                                                                                  (if (riding-mob-id actor)
                                                                                                    (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                    (map-size actor))
                                                                                                  (get-mob-move-mode actor))
                                                                         (and (> (map-size actor) 1)
                                                                              (ai-find-move-around actor (x nearest-enemy) (y nearest-enemy)))))
                                                              t
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore hostile-mobs allied-mobs nearest-ally check-result))

                                                             (loop with target = nearest-enemy
                                                                   with move-failed-once = nil
                                                                   with move-result = nil
                                                                   while t do
                                                                     (logger (format nil "AI-PACKAGE-ATTACK-NEAREST-ENEMY: ~A [~A] (~A, ~A, ~A) wants to attack ~A [~A] at (~A, ~A, ~A)~%"
                                                                                     (name actor) (id actor) (x actor) (y actor) (z actor) (name target) (id target) (x target) (y target) (z target)))
                                                                     ;; set path-dst to the target if there is no path-dst or it is different from the target position
                                                                     (when (or (null (path-dst actor))
                                                                               (/= (first (path-dst actor)) (x target))
                                                                               (/= (second (path-dst actor)) (y target))
                                                                               (/= (third (path-dst actor)) (z target)))
                                                                       (ai-set-path-dst actor (x target) (y target) (z target)))
                                                                     
                                                                     ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                     (when (null (path-dst actor))
                                                                       (ai-mob-random-dir actor)
                                                                       (loop-finish))
                                                                     
                                                                     ;; make a path to the destination target if there is no path plotted
                                                                     (when (or (null (path actor))
                                                                               (mob-ability-p actor +mob-abil-momentum+))
                                                                       (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                     
                                                                     ;; make a step along the path to the path-dst
                                                                     (setf move-result (ai-move-along-path actor))
                                                                     (cond
                                                                       ;; if the move failed twice - move in a random direction
                                                                       ((and move-failed-once
                                                                             (null move-result))
                                                                        (ai-mob-random-dir actor)
                                                                        (loop-finish))
                                                                       ;; if the move failed - reset path-dst and start anew
                                                                       ((and (null move-failed-once)
                                                                             (null move-result))
                                                                        (setf (path-dst actor) nil)
                                                                        (setf move-failed-once t)
                                                                        )
                                                                       ;; success
                                                                       (t
                                                                        (loop-finish))))
                                                             
                                                             )))

(set-ai-package (make-instance 'ai-package :id +ai-package-patrol-district+
                                           :priority 5
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (not nearest-enemy)
                                                                     )
                                                              t
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs allied-mobs nearest-ally check-result))

                                                             (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: Mob (~A, ~A, ~A) wants to patrol the district~%" (x actor) (y actor) (z actor)))
                                                             (block ai-function
                                                               ;; take N attempts to find a random destination spot in the nearest sector that has not been visited recently if no path is set
                                                               (when (null (path-dst actor))
                                                                 (let ((nearest-sector nil)
                                                                       (rx 0) 
                                                                       (ry 0)
                                                                       (rz 0)
                                                                       )
                                                                   (declare (type fixnum rx ry rz))
                                                                   (loop for dx from 0 below (array-dimension (memory-map actor) 0) do
                                                                     (loop for dy from 0 below (array-dimension (memory-map actor) 1) do
                                                                       (unless nearest-sector
                                                                         (setf nearest-sector (list dx dy (aref (memory-map actor) dx dy))))
                                                                       (cond
                                                                         ((< (aref (memory-map actor) dx dy)
                                                                             (third nearest-sector))
                                                                          (progn
                                                                            (setf nearest-sector (list dx dy (aref (memory-map actor) dx dy)))))
                                                                         ((and (= (aref (memory-map actor) dx dy)
                                                                                  (third nearest-sector))
                                                                               (< (get-distance (truncate (x actor) 10) (truncate (y actor) 10) dx dy)
                                                                                  (get-distance (truncate (x actor) 10) (truncate (y actor) 10) (first nearest-sector) (second nearest-sector))))
                                                                          (progn
                                                                            (setf nearest-sector (list dx dy (aref (memory-map actor) dx dy))))))
                                                                       ))

                                                                   (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: NEAREST-SECTOR ~A vs CUR-SECTOR ~A~%" nearest-sector (list (truncate (x actor) 10) (truncate (y actor) 10))))
                                                                   
                                                                   (setf rx (+ (* (first nearest-sector) 10) (random 10)))
                                                                   (setf ry (+ (* (second nearest-sector) 10) (random 10)))
                                                                   (setf rz (- (+ 5 (z actor)) (1+ (random 10))))
                                                                 
                                                                   (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: TERRAIN ~A~%" (get-terrain-* (level *world*) (x actor) (y actor) (z actor))))
                                                                   (loop while (or (< rx 0) (< ry 0) (< rz 0)
                                                                                   (>= rx (array-dimension (terrain (level *world*)) 0))
                                                                                   (>= ry (array-dimension (terrain (level *world*)) 1))
                                                                                   (>= rz (array-dimension (terrain (level *world*)) 2))
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move+)
                                                                                   (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                                        (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-opaque-floor+))
                                                                                        (not (mob-effect-p actor +mob-effect-flying+)))
                                                                                   (not (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) rx ry rz (if (riding-mob-id actor)
                                                                                                                                                                          (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                          (map-size actor))
                                                                                                                 (get-mob-move-mode actor)))
                                                                                   )
                                                                         do
                                                                            (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: R (~A ~A ~A)~%TERRAIN = ~A, MOB ~A [~A], CONNECTED ~A~%"
                                                                                            rx ry rz
                                                                                            (get-terrain-* (level *world*) rx ry rz)
                                                                                            (get-mob-* (level *world*) rx ry rz) (if (get-mob-* (level *world*) rx ry rz)
                                                                                                                                   (id (get-mob-* (level *world*) rx ry rz))
                                                                                                                                   nil)
                                                                                            (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) rx ry rz (if (riding-mob-id actor)
                                                                                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                              (map-size actor))
                                                                                                                     (get-mob-move-mode actor))))
                                                                            (setf rx (+ (* (first nearest-sector) 10) (random 10)))
                                                                            (setf ry (+ (* (second nearest-sector) 10) (random 10)))
                                                                            (setf rz (- (+ 5 (z actor)) (1+ (random 10))))
                                                                            (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: NEW R (~A ~A ~A)~%" rx ry rz)))
                                                                   (ai-set-path-dst actor rx ry rz)
                                                                   (logger (format nil "AI-PACKAGE-PATROL-DISTRICT: Mob's destination is randomly set to (~A, ~A, ~A)~%"
                                                                                   (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))))
                                                               
                                                               (let ((move-result nil))
                                                                 ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                 (when (null (path-dst actor))
                                                                   (ai-mob-random-dir actor)
                                                                   (return-from ai-function))
                                                                     
                                                                 ;; make a path to the destination target if there is no path plotted
                                                                 (when (or (null (path actor))
                                                                           (mob-ability-p actor +mob-abil-momentum+))
                                                                   (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                 
                                                                 ;; make a step along the path to the path-dst
                                                                 (setf move-result (ai-move-along-path actor))
                                                                 (cond
                                                                   ;; if the move failed - move in a random direction
                                                                   ((null move-result)
                                                                    (setf (path-dst actor) nil)
                                                                    (ai-mob-random-dir actor)
                                                                    (return-from ai-function)
                                                                    )
                                                                   ;; success
                                                                   (t
                                                                    (return-from ai-function))))
                                                               
                                                             ))))

(set-ai-package (make-instance 'ai-package :id +ai-package-find-random-location+
                                           :priority 4
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (not nearest-enemy)
                                                                     )
                                                              t
                                                              nil)
                                                            )
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                                                             (declare (ignore nearest-enemy hostile-mobs allied-mobs nearest-ally check-result))

                                                             (logger (format nil "AI-PACKAGE-FIND-RANDOM-LOCATION: Mob (~A, ~A, ~A) wants to go to a random nearby place~%" (x actor) (y actor) (z actor)))
                                                             (block ai-function
                                                               ;; take N attempts to find a random destination spot if no path is set
                                                               (unless (path-dst actor)
                                                                 (let ((rx (- (+ 10 (x actor))
                                                                              (1+ (random 20)))) 
                                                                       (ry (- (+ 10 (y actor))
                                                                              (1+ (random 20))))
                                                                       (rz (- (+ 5 (z actor))
                                                                              (1+ (random 10))))
                                                                       )
                                                                   (declare (type fixnum rx ry rz))
                                                                   (logger (format nil "AI-PACKAGE-FIND-RANDOM-LOCATION: TERRAIN ~A~%" (get-terrain-* (level *world*) (x actor) (y actor) (z actor))))
                                                                   (loop while (or (< rx 0) (< ry 0) (< rz 0)
                                                                                   (>= rx (array-dimension (terrain (level *world*)) 0))
                                                                                   (>= ry (array-dimension (terrain (level *world*)) 1))
                                                                                   (>= rz (array-dimension (terrain (level *world*)) 2))
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move+)
                                                                                   (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                                        (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-opaque-floor+))
                                                                                        (not (mob-effect-p actor +mob-effect-flying+)))
                                                                                   (not (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) rx ry rz (if (riding-mob-id actor)
                                                                                                                                                                          (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                          (map-size actor))
                                                                                                                 (get-mob-move-mode actor)))
                                                                                   )
                                                                         do
                                                                            (logger (format nil "AI-PACKAGE-FIND-RANDOM-LOCATION: R (~A ~A ~A)~%TERRAIN = ~A, MOB ~A [~A], CONNECTED ~A~%"
                                                                                            rx ry rz
                                                                                            (get-terrain-* (level *world*) rx ry rz)
                                                                                            (get-mob-* (level *world*) rx ry rz) (if (get-mob-* (level *world*) rx ry rz)
                                                                                                                                   (id (get-mob-* (level *world*) rx ry rz))
                                                                                                                                   nil)
                                                                                            (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) rx ry rz (if (riding-mob-id actor)
                                                                                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                              (map-size actor))
                                                                                                                     (get-mob-move-mode actor))))
                                                                            (setf rx (- (+ 10 (x actor))
                                                                                        (1+ (random 20))))
                                                                            (setf ry (- (+ 10 (y actor))
                                                                                        (1+ (random 20))))
                                                                            (setf rz (- (+ 5 (z actor))
                                                                                        (1+ (random 10))))
                                                                            (logger (format nil "AI-PACKAGE-FIND-RANDOM-LOCATION: NEW R (~A ~A ~A)~%" rx ry rz)))
                                                                   (ai-set-path-dst actor rx ry rz)
                                                                   (logger (format nil "AI-PACKAGE-FIND-RANDOM-LOCATION: Mob's destination is randomly set to (~A, ~A, ~A)~%"
                                                                                   (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))))
                                                               
                                                               (let ((move-result nil))
                                                                 ;; exit (and move randomly) if the path-dst is still null after the previous set attempt
                                                                 (when (null (path-dst actor))
                                                                   (ai-mob-random-dir actor)
                                                                   (return-from ai-function))
                                                                     
                                                                 ;; make a path to the destination target if there is no path plotted
                                                                 (when (or (null (path actor))
                                                                           (mob-ability-p actor +mob-abil-momentum+))
                                                                   (ai-plot-path-to-dst actor (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                                 
                                                                 ;; make a step along the path to the path-dst
                                                                 (setf move-result (ai-move-along-path actor))
                                                                 (cond
                                                                   ;; if the move failed - move in a random direction
                                                                   ((null move-result)
                                                                    (setf (path-dst actor) nil)
                                                                    (ai-mob-random-dir actor)
                                                                    (return-from ai-function)
                                                                    )
                                                                   ;; success
                                                                   (t
                                                                    (return-from ai-function))))
                                                               
                                                             ))))
