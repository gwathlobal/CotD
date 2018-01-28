(in-package :cotd)

(set-ai-package (make-instance 'ai-package :id +ai-package-coward+
                                           :final t :priority 9
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if nearest-enemy
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                             (logger (format nil "AI-PACKAGE-COWARD: ~A [~A] is in fear with an enemy ~A [~A].~%" (name actor) (id actor) (name nearest-enemy) (id nearest-enemy)))
                                                             (ai-mob-flee actor nearest-enemy)
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-split-soul+
                                           :final nil :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-ally hostile-mobs allied-mobs))
                                                            (if nearest-enemy
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                             (logger (format nil "AI-PACKAGE-SPLIT-SOUL: ~A [~A] is trying to move away from the enemy ~A [~A].~%" (name actor) (id actor) (name nearest-enemy) (id nearest-enemy)))
                                                             
                                                             (let ((farthest-tile nil))
                                                               (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                           (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                             (when (and terrain
                                                                                                                        (or (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                            (get-terrain-type-trait terrain +terrain-trait-water+))
                                                                                                                        (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                        (not (get-mob-* (level *world*) dx dy (z actor)))
                                                                                                                        nearest-enemy)
                                                                                                               (unless farthest-tile
                                                                                                                 (setf farthest-tile (list dx dy (z actor))))
                                                                                                               (when (> (get-distance dx dy (x nearest-enemy) (y nearest-enemy))
                                                                                                                        (get-distance (first farthest-tile) (second farthest-tile) (x nearest-enemy) (y nearest-enemy)))
                                                                                                                 (setf farthest-tile (list dx dy (z actor))))))))
                                                               (if farthest-tile
                                                                 (setf (path-dst actor) farthest-tile nearest-target nil)
                                                                 (setf (path-dst actor) (list (x actor) (y actor) (z actor)) nearest-target nil))
                                                               )
                                                             (setf nearest-target nil)
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-horde+
                                           :final t :priority 8
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
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-ally allied-mobs hostile-mobs))

                                                             ;; if the mob has horde behavior, compare relative strengths of allies to relative strength of enemies
                                                             ;; if less - flee
                                                             (ai-mob-flee actor nearest-enemy)
                                                             
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-wants-bless+
                                           :final nil :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-enemy nearest-ally hostile-mobs allied-mobs))
                                                            t)
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore hostile-mobs nearest-ally))

                                                             ;; if the mob wants to give blessings, find the nearest unblessed ally
                                                             ;; if it is closer than the enemy, go to it
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
                                                               (logger (format nil "AI-PACKAGE-WANTS-TO-BLESS: ~A [~A] wants to give blessings. Nearest unblessed ally ~A [~A]~%"
                                                                               (name actor) (id actor) (if nearest-ally (name nearest-ally) nil) (if nearest-ally (id nearest-ally) nil)))
                                                               (when (or (and nearest-ally
                                                                              (not nearest-enemy))
                                                                         (and nearest-ally
                                                                              nearest-enemy
                                                                              (< (get-distance (x actor) (y actor) (x nearest-ally) (y nearest-ally))
                                                                                 (get-distance (x actor) (y actor) (x nearest-enemy) (y nearest-enemy)))))
                                                                 (logger (format nil "AI-PACKAGE-WANTS-TO-BLESS: ~A [~A] changed target ~A [~A].~%" (name actor) (id actor) (name nearest-ally) (id nearest-ally)))
                                                                 (setf nearest-target nearest-ally))
                                                               )
                                                             
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-cautious+
                                           :final nil :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and nearest-enemy
                                                                     (> (strength nearest-enemy) (strength actor)))
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore hostile-mobs nearest-ally allied-mobs))

                                                             ;; if the mob is cautious and the nearest enemy's strength is higher than the mobs - set nearest enemy to nil
                                                             (logger (format nil "AI-PACKAGE-CAUTIOUS: ~A [~A] is too cautious to attack ~A [~A] because STR ~A vs ~A.~%"
                                                                             (name actor) (id actor) (name nearest-enemy) (id nearest-enemy) (strength actor) (strength nearest-enemy)))
                                                             (setf nearest-target nil)
                                                                                                                          
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-trinity-mimic+
                                           :final nil :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore actor nearest-enemy nearest-ally hostile-mobs allied-mobs))
                                                            t)
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

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
                                                             
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-takes-items+
                                           :final t :priority 8
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (null nearest-enemy)
                                                                     (loop for item-id in (get-items-* (level *world*) (x actor) (y actor) (z actor))
                                                                           for item = (get-item-by-id item-id)
                                                                           when (not (zerop (value item)))
                                                                             collect it))
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             (loop for item-id in (get-items-* (level *world*) (x actor) (y actor) (z actor))
                                                                   for item = (get-item-by-id item-id)
                                                                   when (not (zerop (value item)))
                                                                     do
                                                                        (logger (format nil "AI-PACKAGE-TAKES-ITEMS: ~A [~A] decided to take item ~A [~A].~%"
                                                                                        (name actor) (id actor) (name item) (id item)))
                                                                        (mob-pick-item actor item)
                                                                        (loop-finish)
                                                                   )
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-kleptomaniac+
                                           :final nil :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (null nearest-enemy)
                                                                     (visible-items actor))
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; when mob is kleptomaniac and has no target
                                                             (let ((visible-items (copy-list (visible-items actor))))
                                                               (setf visible-items (remove-if #'(lambda (item)
                                                                                                  (zerop (value item)))
                                                                                              visible-items
                                                                                              :key #'get-item-by-id))
                                                               
                                                               (setf visible-items (stable-sort visible-items #'(lambda (a b)
                                                                                                                  (if (< (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                         (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                    t
                                                                                                                    nil))
                                                                                                :key #'get-item-by-id))
                                                                 
                                                               (loop for item-id in visible-items
                                                                     for item = (get-item-by-id item-id)
                                                                     when (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x item) (y item) (z item) (if (riding-mob-id actor)
                                                                                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                              (map-size actor))
                                                                                                   (get-mob-move-mode actor))
                                                                       do
                                                                          (setf (path-dst actor) (list (x item) (y item) (z item)))
                                                                          (setf (path actor) nil)
                                                                          (loop-finish)
                                                                     when (and (> (map-size actor) 1)
                                                                               (ai-find-move-around actor (x item) (y item)))
                                                                       do
                                                                          (setf (path-dst actor) (ai-find-move-around actor (x item) (y item)))
                                                                          (setf (path actor) nil)
                                                                          (loop-finish)
                                                                     finally
                                                                        (when item
                                                                          (logger (format nil "AI-PACKAGE-KLEPTOMANIAC: Mob (~A ~A ~A) wants to get item ~A [~A] at (~A, ~A, ~A)~%"
                                                                                          (x actor) (y actor) (z actor) (name item) (id item) (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))))
                                                               )

                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-curious+
                                           :final nil :priority 6
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (null nearest-enemy)
                                                                     (not (null (heard-sounds actor))))
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; if the mob is curious and it has nothing to do - move to the nearest sound, if any
                                                             (setf (heard-sounds actor) (stable-sort (heard-sounds actor) #'(lambda (a b)
                                                                (if (< (get-distance-3d (x actor) (y actor) (z actor) (sound-x a) (sound-y a) (sound-z a))
                                                                       (get-distance-3d (x actor) (y actor) (z actor) (sound-x b) (sound-y b) (sound-z b)))
                                                                  t
                                                                  nil))))

                                                             (loop for sound in (heard-sounds actor)
                                                                   when (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (sound-x sound) (sound-y sound) (sound-z sound)
                                                                                                 (if (riding-mob-id actor)
                                                                                                   (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                   (map-size actor))
                                                                                                 (get-mob-move-mode actor))
                                                                     do
                                                                        (setf (path-dst actor) (list (sound-x sound) (sound-y sound) (sound-z sound)))
                                                                        (setf (path actor) nil)
                                                                        (loop-finish)
                                                                   when (and (> (map-size actor) 1)
                                                                             (ai-find-move-around actor (sound-x sound) (sound-y sound)))
                                                                     do
                                                                        (setf (path-dst actor) (ai-find-move-around actor (sound-x sound) (sound-y sound)))
                                                                        (setf (path actor) nil)
                                                                        (loop-finish)
                                                                   finally (logger (format nil "AI-PACKAGE-CURIOUS: Mob (~A ~A ~A) wants to investigate sound at (~A, ~A, ~A)~%"
                                                                                           (x actor) (y actor) (z actor) (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor)))))
                                                             
                                                             nearest-target)))

(set-ai-package (make-instance 'ai-package :id +ai-package-cannibal+
                                           :final nil :priority 7
                                           :on-check-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs)
                                                            (declare (ignore nearest-ally hostile-mobs allied-mobs))
                                                            (if (and (null nearest-enemy)
                                                                     (visible-items actor))
                                                              t
                                                              nil))
                                           :on-invoke-ai #'(lambda (actor nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)
                                                             (declare (ignore nearest-enemy hostile-mobs nearest-ally allied-mobs))

                                                             ;; when mob is a cannibal go to the nearest visible item and try to eat it
                                                             ;; find all visible corpses
                                                             ;; go to the nearest such item
                                                             (let ((visible-items (copy-list (visible-items actor))))
                                                               (setf visible-items (remove-if #'(lambda (item)
                                                                                                  (not (item-ability-p item +item-abil-corpse+)))
                                                                                              visible-items
                                                                                              :key #'get-item-by-id))
                                                               
                                                               (setf visible-items (stable-sort visible-items #'(lambda (a b)
                                                                                                                  (if (< (get-distance-3d (x actor) (y actor) (z actor) (x a) (y a) (z a))
                                                                                                                         (get-distance-3d (x actor) (y actor) (z actor) (x b) (y b) (z b)))
                                                                                                                    t
                                                                                                                    nil))
                                                                                                :key #'get-item-by-id))
                                                               
                                                               (loop for item-id in visible-items
                                                                     for item = (get-item-by-id item-id)
                                                                     when (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) (x item) (y item) (z item) (if (riding-mob-id actor)
                                                                                                                                                                              (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                                                                                              (map-size actor))
                                                                                                   (get-mob-move-mode actor))
                                                                       do
                                                                          (setf (path-dst actor) (list (x item) (y item) (z item)))
                                                                          (setf (path actor) nil)
                                                                          (loop-finish)
                                                                     when (and (> (map-size actor) 1)
                                                                               (ai-find-move-around actor (x item) (y item)))
                                                                       do
                                                                          (setf (path-dst actor) (ai-find-move-around actor (x item) (y item)))
                                                                          (setf (path actor) nil)
                                                                          (loop-finish)
                                                                     finally
                                                                        (when item
                                                                          (logger (format nil "AI-PACKAGE-CANNIBAL: Mob (~A ~A ~A) wants to get item ~A [~A] at (~A, ~A, ~A)~%"
                                                                                          (x actor) (y actor) (z actor) (name item) (id item) (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))))
                                                               )
                                                             
                                                             nearest-target)))
