(in-package :cotd)

;;----------------------------------------
;; MISSION-TYPES
;;----------------------------------------

(set-mission-type :id +mission-type-test+
                  :name "Test"
                  :faction-list-func #'(lambda (world-sector)
                                         (declare (ignore world-sector))
                                         (let ((faction-list (list (list +faction-type-none+ +mission-faction-present+)
                                                                   )))
                                           
                                           faction-list))
                  :scenario-faction-list (list (list +specific-faction-type-test+ +lm-placement-test+))
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; update visibility for all added mobs
                                                        (push #'update-visibility-after-creation
                                                              func-list)

                                                        ;; place player
                                                        (push #'place-player-on-level
                                                              func-list)
                                                        
                                                        func-list))

                  )

(set-mission-type :id +mission-type-demonic-attack+
                  :name "Demonic attack"
                  :is-available-func #'(lambda (world-map x y)
                                         (let ((near-demons nil))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells world-map) 0))
                                                                                      (< dy (array-dimension (cells world-map) 1))
                                                                                      (or (= (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-demons+)
                                                                                          (= (wtype (aref (cells world-map) dx dy)) +world-sector-corrupted-forest+)
                                                                                          (= (wtype (aref (cells world-map) dx dy)) +world-sector-corrupted-port+)
                                                                                          (= (wtype (aref (cells world-map) dx dy)) +world-sector-corrupted-residential+)
                                                                                          (= (wtype (aref (cells world-map) dx dy)) +world-sector-corrupted-lake+)))
                                                                             (setf near-demons t))))
                                           (if (and near-demons
                                                    (or (= (wtype (aref (cells world-map) x y)) +world-sector-normal-forest+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-normal-port+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-normal-residential+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-normal-lake+)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (unless (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list))
                                           faction-list))
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; add lose condition on death & all other win conditions
                                                        (push #'add-lose-and-win-coditions-to-level
                                                              func-list)
                                                        
                                                        ;; update visibility for all added mobs
                                                        (push #'update-visibility-after-creation
                                                              func-list)
                                                        
                                                        ;; remove all starting features
                                                        (push #'remove-dungeon-gen-functions
                                                              func-list)

                                                        ;; set up turns for delayed arrival for all parties
                                                        (push #'setup-turns-for-delayed-arrival
                                                              func-list)
                                                                  
                                                        ;; create delayed points from respective features
                                                        (push #'place-delayed-arrival-points-on-level
                                                              func-list)    

                                                        ;; place 1 thief
                                                        (push #'place-ai-thief-on-level
                                                              func-list)
                                                                  
                                                        ;; place 1 eater of the dead
                                                        (push #'place-ai-primordial-on-level
                                                              func-list)
                                                        
                                                        ;; place 1 ghost
                                                        (push #'place-ai-ghost-on-level
                                                              func-list)
                                                        
                                                        ;; add military
                                                        (push #'place-ai-military-on-level
                                                              func-list)
                                                                                                                
                                                        ;; place angels
                                                        (push #'place-ai-angels-on-level
                                                              func-list)
                                                        
                                                        ;; place demons
                                                        (push #'place-ai-demons-on-level
                                                              func-list)

                                                        ;; place player
                                                        (push #'place-player-on-level
                                                              func-list)

                                                        func-list))
                  :scenario-faction-list (list (list +specific-faction-type-player+ +lm-placement-player+)
                                               (list +specific-faction-type-dead-player+ +lm-placement-dead-player+)
                                               (list +specific-faction-type-angel-chrome+ +lm-placement-angel-chrome+)
                                               (list +specific-faction-type-angel-trinity+ +lm-placement-angel-trinity+)
                                               (list +specific-faction-type-demon-crimson+ +lm-placement-demon-crimson+)
                                               (list +specific-faction-type-demon-shadow+ +lm-placement-demon-shadow+)
                                               (list +specific-faction-type-demon-malseraph+ +lm-placement-demon-malseraph+)
                                               (list +specific-faction-type-military-chaplain+ +lm-placement-military-chaplain+)
                                               (list +specific-faction-type-military-scout+ +lm-placement-military-scout+)
                                               (list +specific-faction-type-priest+ +lm-placement-priest+)
                                               (list +specific-faction-type-satanist+ +lm-placement-satanist+)
                                               (list +specific-faction-type-eater+ +lm-placement-eater+)
                                               (list +specific-faction-type-skinchanger+ +lm-placement-skinchanger+)
                                               (list +specific-faction-type-thief+ +lm-placement-thief+)
                                               (list +specific-faction-type-ghost+ +lm-placement-ghost+)
                                               )
                  :ai-package-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                         (list +faction-type-military+ (list +ai-package-patrol-district+))
                                         (list +faction-type-church+ (list +ai-package-patrol-district+))
                                         (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                         (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-demon-attack-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-demon-attack-win-for-angels+)
                                            (list +faction-type-military+ +game-event-demon-attack-win-for-military+)
                                            (list +faction-type-church+ +game-event-demon-attack-win-for-church+)
                                            (list +faction-type-satanists+ +game-event-demon-attack-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            (list +faction-type-criminals+ +game-event-win-for-thief+)
                                            (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                            )
                  )

(set-mission-type :id +mission-type-demonic-raid+
                  :name "Demonic raid"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (= (wtype (aref (cells world-map) x y)) +world-sector-normal-forest+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-port+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-island+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-residential+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-lake+))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list))
                                           faction-list))
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; add lose condition on death & all other win conditions
                                                        (push #'add-lose-and-win-coditions-to-level
                                                              func-list)
                                                        
                                                        ;; update visibility for all added mobs
                                                        (push #'update-visibility-after-creation
                                                              func-list)
                                                        
                                                        ;; remove all starting features
                                                        (push #'remove-dungeon-gen-functions
                                                              func-list)

                                                        ;; set up turns for delayed arrival for all parties
                                                        (push #'setup-turns-for-delayed-arrival
                                                              func-list)
                                                                  
                                                        ;; create delayed points from respective features
                                                        (push #'place-delayed-arrival-points-on-level
                                                              func-list)    

                                                        ;; place 1 thief
                                                        (push #'place-ai-thief-on-level
                                                              func-list)
                                                                  
                                                        ;; place 1 eater of the dead
                                                        (push #'place-ai-primordial-on-level
                                                              func-list)
                                                        
                                                        ;; place 1 ghost
                                                        (push #'place-ai-ghost-on-level
                                                              func-list)
                                                        
                                                        ;; add military
                                                        (push #'place-ai-military-on-level
                                                              func-list)
                                                                                                                
                                                        ;; place angels
                                                        (push #'place-ai-angels-on-level
                                                              func-list)
                                                        
                                                        ;; place demons
                                                        (push #'place-ai-demons-on-level
                                                              func-list)

                                                        ;; place player
                                                        (push #'place-player-on-level
                                                              func-list)
                                                        
                                                        ;; place demonic portals
                                                        (push #'(lambda (level world-sector mission world)
                                                                  (declare (ignore world-sector mission world))
                                                                  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Placing demonic portals~%"))

                                                                  ;; remove standard demon arrival points
                                                                  (loop for feature-id in (feature-id-list level)
                                                                        for lvl-feature = (get-feature-by-id feature-id)
                                                                        when (= (feature-type lvl-feature) +feature-demons-arrival-point+) do
                                                                          (remove-feature-from-level-list level lvl-feature))

                                                                  ;; add portals
                                                                  (let ((portals ())
                                                                       (max-portals 6))
                                                                   (loop with max-x = (- (array-dimension (terrain level) 0) 60)
                                                                         with max-y = (- (array-dimension (terrain level) 1) 60)
                                                                         with cur-portal = 0
                                                                         for free-place = t
                                                                         for x = (+ (random max-x) 30)
                                                                         for y = (+ (random max-y) 30)
                                                                         while (< (length portals) max-portals) do
                                                                           (check-surroundings x y t #'(lambda (dx dy)
                                                                                                         (when (or (get-terrain-type-trait (get-terrain-* level dx dy 2) +terrain-trait-blocks-move+)
                                                                                                                   (not (get-terrain-type-trait (get-terrain-* level dx dy 2) +terrain-trait-opaque-floor+))
                                                                                                                   (get-terrain-type-trait (get-terrain-* level dx dy 2) +terrain-trait-water+))
                                                                                                           (setf free-place nil))))
                                                                           (when (and free-place
                                                                                      (not (find (list x y 2) portals :test #'(lambda (a b)
                                                                                                                                (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 10)
                                                                                                                                  t
                                                                                                                                  nil)
                                                                                                                                )))
                                                                                      (loop for feature-id in (feature-id-list level)
                                                                                            for feature = (get-feature-by-id feature-id)
                                                                                            with result = t
                                                                                            when (and (= (feature-type feature) +feature-start-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            finally (return result)))
                                                                             (push (list x y 2) portals)
                                                                             (incf cur-portal)))
                                                                   (loop for (x y z) in portals do
                                                                     ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id +feature-demonic-portal+)) x y z)
                                                                     (add-feature-to-level-list level (make-instance 'feature :feature-type +feature-demonic-portal+ :x x :y y :z z))
                                                                     (add-feature-to-level-list level (make-instance 'feature :feature-type +feature-demons-arrival-point+ :x x :y y :z z))))
                                                                  )
                                                              func-list)

                                                        func-list))
                  :scenario-faction-list (list (list +specific-faction-type-player+ +lm-placement-player+)
                                               (list +specific-faction-type-dead-player+ +lm-placement-dead-player+)
                                               (list +specific-faction-type-angel-chrome+ +lm-placement-angel-chrome+)
                                               (list +specific-faction-type-angel-trinity+ +lm-placement-angel-trinity+)
                                               (list +specific-faction-type-demon-crimson+ +lm-placement-demon-crimson+)
                                               (list +specific-faction-type-demon-shadow+ +lm-placement-demon-shadow+)
                                               (list +specific-faction-type-demon-malseraph+ +lm-placement-demon-malseraph+)
                                               (list +specific-faction-type-military-chaplain+ +lm-placement-military-chaplain+)
                                               (list +specific-faction-type-military-scout+ +lm-placement-military-scout+)
                                               (list +specific-faction-type-priest+ +lm-placement-priest+)
                                               (list +specific-faction-type-satanist+ +lm-placement-satanist+)
                                               (list +specific-faction-type-eater+ +lm-placement-eater+)
                                               (list +specific-faction-type-skinchanger+ +lm-placement-skinchanger+)
                                               (list +specific-faction-type-thief+ +lm-placement-thief+)
                                               (list +specific-faction-type-ghost+ +lm-placement-ghost+)
                                               )
                  :ai-package-list (list (list +faction-type-demons+ (list +ai-package-search-corpses+ +ai-package-pick-corpses+ +ai-package-return-corpses-to-portal+
                                                                           +ai-package-patrol-district+))
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                         (list +faction-type-military+ (list +ai-package-patrol-district+))
                                         (list +faction-type-church+ (list +ai-package-patrol-district+))
                                         (list +faction-type-satanists+ (list +ai-package-search-corpses+ +ai-package-pick-corpses+ +ai-package-return-corpses-to-portal+
                                                                              +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                         (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-demon-raid-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-demon-raid-win-for-angels+)
                                            (list +faction-type-military+ +game-event-demon-raid-win-for-military+)
                                            (list +faction-type-church+ +game-event-demon-raid-win-for-church+)
                                            (list +faction-type-satanists+ +game-event-demon-raid-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            (list +faction-type-criminals+ +game-event-win-for-thief+)
                                            (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                            )
                  )

(set-mission-type :id +mission-type-demonic-conquest+
                  :name "Demonic conquest"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (= (wtype (aref (cells world-map) x y)) +world-sector-normal-forest+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-port+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-island+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-residential+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-normal-lake+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-forest+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-port+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-island+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-residential+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-lake+))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list))
                                           faction-list)))

(set-mission-type :id +mission-type-demonic-thievery+
                  :name "Demonic thievery"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (and (find :church (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
                                                  (find +item-type-church-reliс+ (items (aref (cells world-map) x y))))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list))
                                           faction-list)))

(set-mission-type :id +mission-type-military-conquest+
                  :name "Military conquest"
                  :is-available-func #'(lambda (world-map x y)
                                         (let ((near-military nil))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells world-map) 0))
                                                                                      (< dy (array-dimension (cells world-map) 1))
                                                                                      (= (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-military+))
                                                                             (setf near-military t))))
                                           (if (and near-military
                                                    (or (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-forest+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-port+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-island+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-residential+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-lake+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-forest+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-port+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-island+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-residential+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-lake+)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-military+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-demons+ +mission-faction-delayed+) faction-list)
                                             )
                                           faction-list)))

(set-mission-type :id +mission-type-military-raid+
                  :name "Military raid"
                  :is-available-func #'(lambda (world-map x y)
                                         (let ((near-military nil))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells world-map) 0))
                                                                                      (< dy (array-dimension (cells world-map) 1))
                                                                                      (= (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-military+))
                                                                             (setf near-military t))))
                                           (if (and near-military
                                                    (or (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-forest+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-port+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-island+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-residential+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-lake+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-forest+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-port+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-island+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-residential+)
                                                        (= (wtype (aref (cells world-map) x y)) +world-sector-abandoned-lake+)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-military+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-present+)
                                                                   (list +faction-type-angels+ +mission-faction-delayed+)
                                                                   (list +faction-type-angels+ +mission-faction-absent+)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-demons+ +mission-faction-delayed+) faction-list)
                                             )
                                           faction-list)))

(set-mission-type :id +mission-type-celestial-purge+
                  :name "Celestial purge"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-forest+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-port+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-island+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-residential+)
                                                 (= (wtype (aref (cells world-map) x y)) +world-sector-corrupted-lake+))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ +mission-faction-present+))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-demons+ +mission-faction-delayed+) faction-list)
                                             )
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list)
                                             )
                                           faction-list)))

(set-mission-type :id +mission-type-celestial-retrieval+
                  :name "Celestial retrieval"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (and (not (find :church (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a))))
                                                  (find +item-type-church-reliс+ (items (aref (cells world-map) x y))))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ +mission-faction-present+))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-demons+ +mission-faction-delayed+) faction-list)
                                             )
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ +mission-faction-present+) faction-list)
                                             (push (list +faction-type-military+ +mission-faction-delayed+) faction-list)
                                             )
                                           faction-list)))

;;----------------------------------------
;; MISSION-DISTRICTS
;;----------------------------------------

(set-mission-district (make-instance 'mission-district :id +city-layout-normal+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-forest+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-port+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-island+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-barricaded-city+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-lake+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-lake-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-port-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-normal+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-forest+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-port+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-island+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-lake+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-lake-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-ruined-port-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-normal+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-forest+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-port+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-island+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-lake+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-lake-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-port-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-normal+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-forest+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-port+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-island+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-lake+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-lake-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-corrupted-steal-port-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

;;----------------------------------------
;; MISSION-SCENARIOS
;;----------------------------------------

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-test+
                                                       :name "test"
                                                       :enabled nil
                                                       :district-layout-list ()
                                                       :faction-list ()
                                                       :scenario-faction-list ()
                                                       :objective-list (list (list +faction-type-angels+ (list +ai-package-patrol-district+)))
                                                       :win-condition-list ()
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-attack+
                                                       :name "Demonic attack"
                                                       :district-layout-list (list +city-layout-normal+ +city-layout-forest+ +city-layout-port+ +city-layout-island+ +city-layout-river+ +city-layout-barricaded-city+ +city-layout-lake+
                                                                                   +city-layout-lake-river+ +city-layout-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-attack-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-attack-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-attack-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-attack-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-attack-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-attack-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-attack-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-attack-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-attack-military-scout+)
                                                                                    (list +specific-faction-type-priest+ +sf-faction-demonic-attack-priest+)
                                                                                    (list +specific-faction-type-satanist+ +sf-faction-demonic-attack-satanist+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-attack-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-attack-skinchanger+)
                                                                                    (list +specific-faction-type-thief+ +sf-faction-demonic-attack-thief+)
                                                                                    (list +specific-faction-type-ghost+ +sf-faction-demonic-attack-ghost+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-church+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-attack-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-attack-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-attack-win-for-military+)
                                                                                 (list +faction-type-church+ +game-event-demon-attack-win-for-church+)
                                                                                 (list +faction-type-satanists+ +game-event-demon-attack-win-for-satanists+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 (list +faction-type-criminals+ +game-event-win-for-thief+)
                                                                                 (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                                                                 )
                                                       :angel-disguised-mob-type-id +mob-type-man+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-raid+
                                                       :name "Demonic raid"
                                                       :district-layout-list (list +city-layout-normal+ +city-layout-forest+ +city-layout-port+ +city-layout-island+ +city-layout-river+ +city-layout-barricaded-city+ +city-layout-lake+
                                                                                   +city-layout-lake-river+ +city-layout-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-raid-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-raid-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-raid-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-raid-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-raid-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-raid-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-raid-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-raid-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-raid-military-scout+)
                                                                                    (list +specific-faction-type-priest+ +sf-faction-demonic-raid-priest+)
                                                                                    (list +specific-faction-type-satanist+ +sf-faction-demonic-raid-satanist+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-raid-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-raid-skinchanger+)
                                                                                    (list +specific-faction-type-thief+ +sf-faction-demonic-raid-thief+)
                                                                                    (list +specific-faction-type-ghost+ +sf-faction-demonic-raid-ghost+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-search-corpses+ +ai-package-pick-corpses+ +ai-package-return-corpses-to-portal+
                                                                                                               +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-church+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-satanists+ (list +ai-package-search-corpses+ +ai-package-pick-corpses+ +ai-package-return-corpses-to-portal+
                                                                                                                  +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-raid-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-raid-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-raid-win-for-military+)
                                                                                 (list +faction-type-church+ +game-event-demon-raid-win-for-church+)
                                                                                 (list +faction-type-satanists+ +game-event-demon-raid-win-for-satanists+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 (list +faction-type-criminals+ +game-event-win-for-thief+)
                                                                                 (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-raid+)
                                                       :win-value-func #'(lambda ()
                                                                           (setf *demonic-raid-win-value* 200))
                                                       :angel-disguised-mob-type-id +mob-type-man+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-steal+
                                                       :name "Demonic thievery"
                                                       :district-layout-list (list +city-layout-normal+ +city-layout-forest+ +city-layout-port+ +city-layout-island+ +city-layout-river+ +city-layout-barricaded-city+ +city-layout-lake+
                                                                                   +city-layout-lake-river+ +city-layout-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-steal-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-steal-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-steal-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-steal-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-steal-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-steal-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-steal-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-steal-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-steal-military-scout+)
                                                                                    (list +specific-faction-type-priest+ +sf-faction-demonic-steal-priest+)
                                                                                    (list +specific-faction-type-satanist+ +sf-faction-demonic-steal-satanist+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-steal-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-steal-skinchanger+)
                                                                                    (list +specific-faction-type-thief+ +sf-faction-demonic-steal-thief+)
                                                                                    (list +specific-faction-type-ghost+ +sf-faction-demonic-steal-ghost+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-search-relic+ +ai-package-pick-relic+ +ai-package-return-relic-to-portal+ +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-church+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-satanists+ (list +ai-package-search-relic+ +ai-package-pick-relic+ +ai-package-return-relic-to-portal+ +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-steal-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-steal-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-steal-win-for-military+)
                                                                                 (list +faction-type-church+ +game-event-demon-steal-win-for-church+)
                                                                                 (list +faction-type-satanists+ +game-event-demon-steal-win-for-satanists+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 (list +faction-type-criminals+ +game-event-win-for-thief+)
                                                                                 (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-steal+)
                                                       :angel-disguised-mob-type-id +mob-type-man+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-conquest+
                                                       :name "Demonic conquest"
                                                       :district-layout-list (list +city-layout-normal+ +city-layout-forest+ +city-layout-port+ +city-layout-island+ +city-layout-river+ +city-layout-barricaded-city+ +city-layout-lake+
                                                                                   +city-layout-lake-river+ +city-layout-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-conquest-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-conquest-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-conquest-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-conquest-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-conquest-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-conquest-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-conquest-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-conquest-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-conquest-military-scout+)
                                                                                    (list +specific-faction-type-priest+ +sf-faction-demonic-conquest-priest+)
                                                                                    (list +specific-faction-type-satanist+ +sf-faction-demonic-conquest-satanist+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-conquest-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-conquest-skinchanger+)
                                                                                    (list +specific-faction-type-thief+ +sf-faction-demonic-conquest-thief+)
                                                                                    (list +specific-faction-type-ghost+ +sf-faction-demonic-conquest-ghost+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-church+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-criminals+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-ghost+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-conquest-win-for-military+)
                                                                                 (list +faction-type-church+ +game-event-demon-conquest-win-for-church+)
                                                                                 (list +faction-type-satanists+ +game-event-demon-conquest-win-for-satanists+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 (list +faction-type-criminals+ +game-event-win-for-thief+)
                                                                                 (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-steal+)
                                                       :angel-disguised-mob-type-id +mob-type-man+
                                                       ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-raid-ruined+
                                                       :name "Demonic raid"
                                                       :district-layout-list (list +city-layout-ruined-normal+ +city-layout-ruined-forest+ +city-layout-ruined-port+ +city-layout-ruined-island+ +city-layout-ruined-river+
                                                                                   +city-layout-ruined-lake+ +city-layout-ruined-lake-river+ +city-layout-ruined-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-raid-ruined-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-raid-ruined-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-raid-ruined-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-raid-ruined-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-raid-ruined-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-raid-ruined-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-raid-ruined-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-raid-ruined-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-raid-ruined-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-raid-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-raid-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-search-corpses+ +ai-package-pick-corpses+ +ai-package-return-corpses-to-portal+
                                                                                                               +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-raid-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-raid-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-raid-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-raid+
                                                                           +mission-sf-ruined-district+)
                                                       :win-value-func #'(lambda ()
                                                                           (setf *demonic-raid-win-value* 100))
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-conquest-ruined+
                                                       :name "Demonic conquest"
                                                       :district-layout-list (list +city-layout-ruined-normal+ +city-layout-ruined-forest+ +city-layout-ruined-port+ +city-layout-ruined-island+ +city-layout-ruined-river+
                                                                                   +city-layout-ruined-lake+ +city-layout-ruined-lake-river+ +city-layout-ruined-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-military+ +mission-faction-absent+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-conquest-ruined-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-conquest-ruined-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-conquest-ruined-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-conquest-ruined-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-conquest-ruined-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-conquest-ruined-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-conquest-ruined-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-conquest-ruined-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-conquest-ruined-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-conquest-ruined-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-conquest-ruined-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-conquest-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-steal+
                                                                           +mission-sf-ruined-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                                       ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-military-conquest-ruined+
                                                       :name "Military conquest"
                                                       :district-layout-list (list +city-layout-ruined-normal+ +city-layout-ruined-forest+ +city-layout-ruined-port+ +city-layout-ruined-island+ +city-layout-ruined-river+
                                                                                   +city-layout-ruined-lake+ +city-layout-ruined-lake-river+ +city-layout-ruined-port-river+)
                                                       :faction-list (list (list +faction-type-military+ +mission-faction-attacker+)
                                                                           (list +faction-type-demons+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-military-conquest-ruined-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-military-conquest-ruined-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-military-conquest-ruined-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-military-conquest-ruined-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-military-conquest-ruined-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-military-conquest-ruined-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-military-conquest-ruined-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-military-conquest-ruined-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-military-conquest-ruined-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-military-conquest-ruined-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-military-conquest-ruined-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-military-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-military-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-military-conquest-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-ruined-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-military-raid-ruined+
                                                       :name "Military raid"
                                                       :district-layout-list (list +city-layout-ruined-normal+ +city-layout-ruined-forest+ +city-layout-ruined-port+ +city-layout-ruined-island+ +city-layout-ruined-river+
                                                                                   +city-layout-ruined-lake+ +city-layout-ruined-lake-river+ +city-layout-ruined-port-river+)
                                                       :faction-list (list (list +faction-type-military+ +mission-faction-attacker+)
                                                                           (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-military-raid-ruined-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-military-raid-ruined-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-military-raid-ruined-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-military-raid-ruined-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-military-raid-ruined-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-military-raid-ruined-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-military-raid-ruined-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-military-raid-ruined-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-military-raid-ruined-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-military-raid-ruined-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-military-raid-ruined-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-military-raid-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-military-raid-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-military-raid-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-ruined-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                                       ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-conquest-corrupted+
                                                       :name "Demonic conquest"
                                                       :district-layout-list (list +city-layout-corrupted-normal+ +city-layout-corrupted-forest+ +city-layout-corrupted-port+ +city-layout-corrupted-island+ +city-layout-corrupted-river+
                                                                                   +city-layout-corrupted-lake+ +city-layout-corrupted-lake-river+ +city-layout-corrupted-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-military+ +mission-faction-absent+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-demonic-conquest-corrupted-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-demonic-conquest-corrupted-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-demonic-conquest-corrupted-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-demonic-conquest-corrupted-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-demonic-conquest-corrupted-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-demonic-conquest-corrupted-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-demonic-conquest-corrupted-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-demonic-conquest-corrupted-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-demonic-conquest-corrupted-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-demonic-conquest-corrupted-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-demonic-conquest-corrupted-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-demon-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-demon-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-demon-conquest-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-demonic-steal+
                                                                           +mission-sf-ruined-district+
                                                                           +mission-sf-irradiated-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                                       ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-military-conquest-corrupted+
                                                       :name "Military conquest"
                                                       :district-layout-list (list +city-layout-corrupted-normal+ +city-layout-corrupted-forest+ +city-layout-corrupted-port+ +city-layout-corrupted-island+ +city-layout-corrupted-river+
                                                                                   +city-layout-corrupted-lake+ +city-layout-corrupted-lake-river+ +city-layout-corrupted-port-river+)
                                                       :faction-list (list (list +faction-type-military+ +mission-faction-attacker+)
                                                                           (list +faction-type-demons+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-military-conquest-corrupted-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-military-conquest-corrupted-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-military-conquest-corrupted-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-military-conquest-corrupted-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-military-conquest-corrupted-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-military-conquest-corrupted-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-military-conquest-corrupted-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-military-conquest-corrupted-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-military-conquest-corrupted-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-military-conquest-corrupted-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-military-conquest-corrupted-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-military-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-military-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-military-conquest-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-ruined-district+ +mission-sf-irradiated-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-angelic-conquest-corrupted+
                                                       :name "Celestial purge"
                                                       :district-layout-list (list +city-layout-corrupted-normal+ +city-layout-corrupted-forest+ +city-layout-corrupted-port+ +city-layout-corrupted-island+ +city-layout-corrupted-river+
                                                                                   +city-layout-corrupted-lake+ +city-layout-corrupted-lake-river+ +city-layout-corrupted-port-river+)
                                                       :faction-list (list (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-military+ +mission-faction-absent+)
                                                                           (list +faction-type-demons+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-attacker+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-angelic-conquest-corrupted-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-angelic-conquest-corrupted-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-angelic-conquest-corrupted-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-angelic-conquest-corrupted-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-angelic-conquest-corrupted-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-angelic-conquest-corrupted-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-angelic-conquest-corrupted-demon-malseraph+)
                                                                                    (list +specific-faction-type-military-chaplain+ +sf-faction-angelic-conquest-corrupted-military-chaplain+)
                                                                                    (list +specific-faction-type-military-scout+ +sf-faction-angelic-conquest-corrupted-military-scout+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-angelic-conquest-corrupted-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-angelic-conquest-corrupted-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-military-conquest-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-military-conquest-win-for-angels+)
                                                                                 (list +faction-type-military+ +game-event-military-conquest-win-for-military+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-ruined-district+ +mission-sf-irradiated-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                     ))

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-angelic-steal-corrupted+
                                                       :name "Celestial retrieval"
                                                       :district-layout-list (list +city-layout-corrupted-steal-normal+ +city-layout-corrupted-steal-forest+ +city-layout-corrupted-steal-port+ +city-layout-corrupted-steal-island+
                                                                                   +city-layout-corrupted-steal-river+ +city-layout-corrupted-steal-lake+ +city-layout-corrupted-steal-lake-river+
                                                                                   +city-layout-corrupted-steal-port-river+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-present+)
                                                                           (list +faction-type-angels+ +mission-faction-attacker+)
                                                                           )
                                                       :scenario-faction-list (list (list +specific-faction-type-player+ +sf-faction-angelic-steal-player+)
                                                                                    (list +specific-faction-type-dead-player+ +sf-faction-angelic-steal-dead-player+)
                                                                                    (list +specific-faction-type-angel-chrome+ +sf-faction-angelic-steal-angel-chrome+)
                                                                                    (list +specific-faction-type-angel-trinity+ +sf-faction-angelic-steal-angel-trinity+)
                                                                                    (list +specific-faction-type-demon-crimson+ +sf-faction-angelic-steal-demon-crimson+)
                                                                                    (list +specific-faction-type-demon-shadow+ +sf-faction-angelic-steal-demon-shadow+)
                                                                                    (list +specific-faction-type-demon-malseraph+ +sf-faction-angelic-steal-demon-malseraph+)
                                                                                    (list +specific-faction-type-eater+ +sf-faction-angelic-steal-eater+)
                                                                                    (list +specific-faction-type-skinchanger+ +sf-faction-angelic-steal-skinchanger+)
                                                                                    )
                                                       :objective-list (list (list +faction-type-demons+ (list +ai-package-patrol-district+))
                                                                             (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-search-relic+ +ai-package-pick-relic+ +ai-package-escape-with-relic+))
                                                                             (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                                                             )
                                                       :win-condition-list (list (list +faction-type-demons+ +game-event-angelic-steal-win-for-demons+)
                                                                                 (list +faction-type-angels+ +game-event-angelic-steal-win-for-angels+)
                                                                                 (list +faction-type-eater+ +game-event-win-for-eater+)
                                                                                 )
                                                       :post-sf-list (list +mission-sf-ruined-district+ +mission-sf-irradiated-district+)
                                                       :angel-disguised-mob-type-id +mob-type-soldier+
                                     ))
