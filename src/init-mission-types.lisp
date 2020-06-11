(in-package :cotd)

;;----------------------------------------
;; MISSION-TYPES
;;----------------------------------------

(set-mission-type :id :mission-type-test
                  :name "Test"
                  :enabled nil
                  :faction-list-func #'(lambda (world-sector)
                                         (declare (ignore world-sector))
                                         (let ((faction-list (list (list +faction-type-none+ :mission-faction-present)
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

(set-mission-type :id :mission-type-demonic-attack
                  :name "Demonic attack"
                  :is-available-func #'(lambda (world-map x y)
                                         (let ((near-demons nil))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells world-map) 0))
                                                                                      (< dy (array-dimension (cells world-map) 1))
                                                                                      (or (= (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-demons+)
                                                                                          (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-forest)
                                                                                          (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-port)
                                                                                          (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-residential)
                                                                                          (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-lake)))
                                                                             (setf near-demons t))))
                                           (if (and near-demons
                                                    (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-forest)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-residential)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (unless (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake)
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
                  :campaign-result (list (list :game-over-angels-won nil)
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-abandoned))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-abandoned))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned)))
                  )

(set-mission-type :id :mission-type-demonic-raid
                  :name "Demonic raid"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-forest)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-island)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-residential)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (unless (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake
                                                          :world-sector-normal-island)
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
                                                        (push #'place-demonic-portals
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
                  :campaign-result (list (list :game-over-angels-won nil)
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-abandoned))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-abandoned))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned)))
                  )

(set-mission-type :id :mission-type-demonic-conquest
                  :name "Demonic conquest"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-forest)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-island)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-residential)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-forest)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-port)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-island)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-residential)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-lake))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake
                                                          :world-sector-normal-island
                                                          :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
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
                                                        (push #'place-demonic-portals
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
                  :campaign-result (list (list :game-over-angels-won nil)
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-corrupted #'transform-abandoned-sector-to-corrupted))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-corrupted #'transform-abandoned-sector-to-corrupted))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned)))
                  )

(set-mission-type :id :mission-type-demonic-thievery
                  :name "Demonic thievery"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (and (loop with corrupted-district-present = nil
                                                        for dx from 0 below (array-dimension (cells world-map) 0) do
                                                          (loop for dy from 0 below (array-dimension (cells world-map) 1) do
                                                            (when (or (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-forest)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-lake)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-residential)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-island)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-port))
                                                              (setf corrupted-district-present t)))
                                                        finally (return corrupted-district-present))
                                                  (find +lm-feat-church+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
                                                  (find +item-type-church-reliс+ (items (aref (cells world-map) x y)))
                                                  (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-forest)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-island)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-residential)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-forest)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-port)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-island)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-residential)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-lake)))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake
                                                          :world-sector-normal-island
                                                          :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
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
                                                        (push #'place-demonic-portals
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
                  :ai-package-list (list (list +faction-type-demons+ (list +ai-package-search-relic+ +ai-package-pick-relic+ +ai-package-return-relic-to-portal+ +ai-package-patrol-district+))
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
                  )

(set-mission-type :id :mission-type-military-conquest
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
                                                    (or (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-forest)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-port)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-island)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-residential)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-lake)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-military+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake)
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
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                         (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                         (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-military-conquest-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-military-conquest-win-for-angels+)
                                            (list +faction-type-military+ +game-event-military-conquest-win-for-military+)
                                            (list +faction-type-satanists+ +game-event-military-conquest-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            )
                  :campaign-result (list (list :game-over-angels-won (list #'transform-corrupted-sector-to-residential))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-corrupted-sector-to-residential))
                                         (list :game-over-church-won (list #'transform-corrupted-sector-to-residential))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won nil))
                  )

(set-mission-type :id :mission-type-military-raid
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
                                                    (or (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-forest)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-port)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-island)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-residential)
                                                        (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-lake)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-military+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
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
                                         (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-military-raid-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-military-raid-win-for-angels+)
                                            (list +faction-type-military+ +game-event-military-raid-win-for-military+)
                                            (list +faction-type-satanists+ +game-event-military-raid-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            )
                  :campaign-result (list (list :game-over-angels-won (list #'transform-abandoned-sector-to-residential))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-abandoned-sector-to-residential))
                                         (list :game-over-church-won (list #'transform-abandoned-sector-to-residential))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won nil))
                  )

(set-mission-type :id :mission-type-celestial-purge
                  :name "Celestial purge"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (or (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-forest)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-port)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-island)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-residential)
                                                 (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-lake))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake)
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
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                         (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-sigil+))
                                         (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-military-conquest-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-military-conquest-win-for-angels+)
                                            (list +faction-type-military+ +game-event-military-conquest-win-for-military+)
                                            (list +faction-type-satanists+ +game-event-military-conquest-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            )
                  :campaign-result (list (list :game-over-angels-won (list #'transform-corrupted-sector-to-abandoned))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-corrupted-sector-to-abandoned))
                                         (list :game-over-church-won (list #'transform-corrupted-sector-to-abandoned))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won nil))
                  )

(set-mission-type :id :mission-type-celestial-retrieval
                  :name "Celestial retrieval"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (and (not (find +lm-feat-church+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a))))
                                                  (find +item-type-church-reliс+ (items (aref (cells world-map) x y)))
                                                  (or (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-forest)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-port)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-island)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-residential)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-corrupted-lake)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-forest)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-port)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-island)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-residential)
                                                      (eq (wtype (aref (cells world-map) x y)) :world-sector-abandoned-lake)))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake
                                                          :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
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
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-search-relic+ +ai-package-pick-relic+ +ai-package-escape-with-relic+))
                                         (list +faction-type-military+ (list +ai-package-patrol-district+))
                                         (list +faction-type-satanists+ (list +ai-package-patrol-district+))
                                         (list +faction-type-eater+ (list +ai-package-patrol-district+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-angelic-steal-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-angelic-steal-win-for-angels+)
                                            (list +faction-type-military+ +game-event-angelic-steal-win-for-military+)
                                            (list +faction-type-satanists+ +game-event-angelic-steal-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            )
                  )

(set-mission-type :id :mission-type-eliminate-satanists
                  :name "Satanist elimination"
                  :is-available-func #'(lambda (world-map x y)
                                         (if (find +lm-feat-lair+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
                                           t
                                           nil)
                                         )
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   (list +faction-type-military+ :mission-faction-present)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake
                                                          :world-sector-normal-island
                                                          :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake
                                                          :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
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
                  :win-condition-list (list (list +faction-type-demons+ +game-event-eliminate-satanists-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-eliminate-satanists-win-for-angels+)
                                            (list +faction-type-military+ +game-event-eliminate-satanists-win-for-military+)
                                            (list +faction-type-church+ +game-event-eliminate-satanists-win-for-church+)
                                            (list +faction-type-satanists+ +game-event-eliminate-satanists-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            (list +faction-type-criminals+ +game-event-win-for-thief+)
                                            (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                            )
                  :campaign-result (list (list :game-over-angels-won (list #'remove-satanist-lair-from-map))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'remove-satanist-lair-from-map))
                                         (list :game-over-church-won (list #'remove-satanist-lair-from-map))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won (list #'remove-satanist-lair-from-map)))
                  )
