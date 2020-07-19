(in-package :cotd)

;;----------------------------------------
;; MISSION-TYPES
;;----------------------------------------

(set-mission-type :id :mission-type-test
                  :name "Test"
                  :enabled nil
                  :mission-slot-type :mission-slot-demons-city
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
                  :mission-slot-type :mission-slot-demons-city
                  :is-available-func #'(lambda (world-sector world)
                                         (let ((near-demons nil)
                                               (x (x world-sector))
                                               (y (y world-sector)))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells (world-map world)) 0))
                                                                                      (< dy (array-dimension (cells (world-map world)) 1))
                                                                                      (= (controlled-by (aref (cells (world-map world)) dx dy)) +lm-controlled-by-demons+))
                                                                             (setf near-demons t))))
                                           (if (and near-demons
                                                    (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                        (eq (wtype world-sector) :world-sector-normal-port)
                                                        (eq (wtype world-sector) :world-sector-normal-residential)
                                                        (eq (wtype world-sector) :world-sector-normal-lake)))
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
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake)
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic)))
                  )

(set-mission-type :id :mission-type-demonic-raid
                  :name "Demonic raid"
                  :mission-slot-type :mission-slot-demons-city
                  :is-available-func #'(lambda (world-sector world)
                                         (declare (ignore world))
                                         (if (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                 (eq (wtype world-sector) :world-sector-normal-port)
                                                 (eq (wtype world-sector) :world-sector-normal-island)
                                                 (eq (wtype world-sector) :world-sector-normal-residential)
                                                 (eq (wtype world-sector) :world-sector-normal-lake))
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
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-normal-forest
                                                          :world-sector-normal-port
                                                          :world-sector-normal-residential
                                                          :world-sector-normal-lake
                                                          :world-sector-normal-island)
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                  :ability-list (list (list +faction-type-demons+ (list +mob-abil-throw-corpse-into-portal+)))
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
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic)))
                  )

(set-mission-type :id :mission-type-demonic-conquest
                  :name "Demonic conquest"
                  :mission-slot-type :mission-slot-demons-city
                  :is-available-func #'(lambda (world-sector world)
                                         (declare (ignore world))
                                         (if (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                 (eq (wtype world-sector) :world-sector-normal-port)
                                                 (eq (wtype world-sector) :world-sector-normal-island)
                                                 (eq (wtype world-sector) :world-sector-normal-residential)
                                                 (eq (wtype world-sector) :world-sector-normal-lake)
                                                 (eq (wtype world-sector) :world-sector-abandoned-forest)
                                                 (eq (wtype world-sector) :world-sector-abandoned-port)
                                                 (eq (wtype world-sector) :world-sector-abandoned-island)
                                                 (eq (wtype world-sector) :world-sector-abandoned-residential)
                                                 (eq (wtype world-sector) :world-sector-abandoned-lake))
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
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
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

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                  :ability-list (list (list +faction-type-demons+ (list +mob-abil-create-demon-sigil+)))
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
                                         (list :game-over-demons-won (list #'transform-residential-sector-to-corrupted #'transform-abandoned-sector-to-corrupted #'move-relic-to-corrupted-district #'move-military-to-free-sector #'demons-capture-book-of-rituals
                                                                           #'demons-capture-relic))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'transform-residential-sector-to-corrupted #'transform-abandoned-sector-to-corrupted #'move-relic-to-corrupted-district #'move-military-to-free-sector #'demons-capture-book-of-rituals
                                                                              #'demons-capture-relic))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic)))
                  )

(set-mission-type :id :mission-type-demonic-thievery
                  :name "Demonic thievery"
                  :mission-slot-type :mission-slot-demons-city
                  :is-available-func #'(lambda (world-sector world)
                                         ;; mission available only if
                                         ;; - there is a corrupted district on the map
                                         ;; - this sector has a church and a relic in it
                                         ;; - the sector is not corrupted
                                         (let ((x (x world-sector))
                                               (y (y world-sector)))
                                           (if (and (loop with corrupted-district-present = nil
                                                          for dx from 0 below (array-dimension (cells (world-map world)) 0) do
                                                            (loop for dy from 0 below (array-dimension (cells (world-map world)) 1) do
                                                              (when (or (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-forest)
                                                                        (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-lake)
                                                                        (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-residential)
                                                                        (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-island)
                                                                        (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-port))
                                                                (setf corrupted-district-present t)))
                                                          finally (return corrupted-district-present))
                                                    (find +lm-feat-church+ (feats (aref (cells (world-map world)) x y)) :key #'(lambda (a) (first a)))
                                                    (find +lm-item-holy-relic+ (items (aref (cells (world-map world)) x y)))
                                                    (not (eq (wtype world-sector) :world-sector-corrupted-forest))
                                                    (not (eq (wtype world-sector) :world-sector-corrupted-lake))
                                                    (not (eq (wtype world-sector) :world-sector-corrupted-residential))
                                                    (not (eq (wtype world-sector) :world-sector-corrupted-island))
                                                    (not (eq (wtype world-sector) :world-sector-corrupted-port)))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-demons+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-present)
                                                                   (list +faction-type-angels+ :mission-faction-delayed)
                                                                   (list +faction-type-angels+ :mission-faction-absent)
                                                                   )))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
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

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                  :ability-list (list (list +faction-type-demons+ (list +mob-abil-throw-relic-into-portal+)))
                  :win-condition-list (list (list +faction-type-demons+ +game-event-demon-steal-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-demon-steal-win-for-angels+)
                                            (list +faction-type-military+ +game-event-demon-steal-win-for-military+)
                                            (list +faction-type-church+ +game-event-demon-steal-win-for-church+)
                                            (list +faction-type-satanists+ +game-event-demon-steal-win-for-satanists+)
                                            (list +faction-type-eater+ +game-event-win-for-eater+)
                                            (list +faction-type-criminals+ +game-event-win-for-thief+)
                                            (list +faction-type-ghost+ +game-event-win-for-ghost+)
                                            )
                  :campaign-result (list (list :game-over-angels-won nil)
                                         (list :game-over-demons-won (list #'move-relic-to-corrupted-district))
                                         (list :game-over-military-won nil)
                                         (list :game-over-church-won nil)
                                         (list :game-over-satanists-won (list #'move-relic-to-corrupted-district))
                                         (list :game-over-eater-won (list #'transform-residential-sector-to-abandoned #'move-military-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic)))
                  )

(set-mission-type :id :mission-type-military-conquest
                  :name "Military conquest"
                  :mission-slot-type :mission-slot-military-city
                  :is-available-func #'(lambda (world-sector world)
                                         (let ((near-military nil)
                                               (x (x world-sector))
                                               (y (y world-sector)))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells (world-map world)) 0))
                                                                                      (< dy (array-dimension (cells (world-map world)) 1))
                                                                                      (= (controlled-by (aref (cells (world-map world)) dx dy)) +lm-controlled-by-military+))
                                                                             (setf near-military t))))
                                           (if (and near-military
                                                    (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                        (eq (wtype world-sector) :world-sector-corrupted-port)
                                                        (eq (wtype world-sector) :world-sector-corrupted-island)
                                                        (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                        (eq (wtype world-sector) :world-sector-corrupted-lake)))
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
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake)
                  :overall-post-process-func-list #'(lambda ()
                                                      (let ((func-list ()))

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                  :campaign-result (list (list :game-over-angels-won (list #'transform-corrupted-sector-to-residential #'move-relic-to-church #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-corrupted-sector-to-residential #'move-relic-to-church #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-church-won (list #'transform-corrupted-sector-to-residential #'move-relic-to-church #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won (list #'move-demons-to-free-sector)))
                  )

(set-mission-type :id :mission-type-military-raid
                  :name "Military raid"
                  :mission-slot-type :mission-slot-military-city
                  :is-available-func #'(lambda (world-sector world)
                                         (let ((near-military nil)
                                               (x (x world-sector))
                                               (y (y world-sector)))
                                           (check-surroundings x y nil #'(lambda (dx dy)
                                                                           (when (and (>= dx 0) (>= dy 0)
                                                                                      (< dx (array-dimension (cells (world-map world)) 0))
                                                                                      (< dy (array-dimension (cells (world-map world)) 1))
                                                                                      (= (controlled-by (aref (cells (world-map world)) dx dy)) +lm-controlled-by-military+))
                                                                             (setf near-military t))))
                                           (if (and near-military
                                                    (or (eq (wtype world-sector) :world-sector-abandoned-forest)
                                                        (eq (wtype world-sector) :world-sector-abandoned-port)
                                                        (eq (wtype world-sector) :world-sector-abandoned-island)
                                                        (eq (wtype world-sector) :world-sector-abandoned-residential)
                                                        (eq (wtype world-sector) :world-sector-abandoned-lake)))
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
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-abandoned-forest
                                                          :world-sector-abandoned-port
                                                          :world-sector-abandoned-island
                                                          :world-sector-abandoned-residential
                                                          :world-sector-abandoned-lake)
                   :overall-post-process-func-list #'(lambda ()
                                                       (let ((func-list ()))

                                                         ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                         
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
                  :campaign-result (list (list :game-over-angels-won (list #'transform-abandoned-sector-to-residential #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-abandoned-sector-to-residential #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-church-won (list #'transform-abandoned-sector-to-residential #'move-demons-to-free-sector #'humans-capture-book-of-rituals #'humans-capture-relic))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won nil))
                  )

(set-mission-type :id :mission-type-celestial-purge
                  :name "Celestial purge"
                  :mission-slot-type :mission-slot-angels-city
                  :is-available-func #'(lambda (world-sector world)
                                         (declare (ignore world))
                                         (if (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                 (eq (wtype world-sector) :world-sector-corrupted-port)
                                                 (eq (wtype world-sector) :world-sector-corrupted-island)
                                                 (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                 (eq (wtype world-sector) :world-sector-corrupted-lake))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-corrupted-forest
                                                          :world-sector-corrupted-port
                                                          :world-sector-corrupted-island
                                                          :world-sector-corrupted-residential
                                                          :world-sector-corrupted-lake)
                  :overall-post-process-func-list #'(lambda ()
                                                       (let ((func-list ()))

                                                         ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                         
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
                  :campaign-result (list (list :game-over-angels-won (list #'transform-corrupted-sector-to-abandoned #'move-demons-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'transform-corrupted-sector-to-abandoned #'move-demons-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-church-won (list #'transform-corrupted-sector-to-abandoned #'move-demons-to-free-sector #'neutrals-capture-book-of-rituals #'neutrals-capture-relic))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won (list #'move-demons-to-free-sector)))
                  )

(set-mission-type :id :mission-type-celestial-retrieval
                  :name "Celestial retrieval"
                  :mission-slot-type :mission-slot-angels-city
                  :is-available-func #'(lambda (world-sector world)
                                         (if (and (find +lm-item-holy-relic+ (items world-sector))
                                                  (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                      (eq (wtype world-sector) :world-sector-corrupted-port)
                                                      (eq (wtype world-sector) :world-sector-corrupted-island)
                                                      (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                      (eq (wtype world-sector) :world-sector-corrupted-lake)
                                                      (eq (wtype world-sector) :world-sector-abandoned-forest)
                                                      (eq (wtype world-sector) :world-sector-abandoned-port)
                                                      (eq (wtype world-sector) :world-sector-abandoned-island)
                                                      (eq (wtype world-sector) :world-sector-abandoned-residential)
                                                      (eq (wtype world-sector) :world-sector-abandoned-lake))
                                                  (loop with free-church-present = nil
                                                        for dx from 0 below (array-dimension (cells (world-map world)) 0) do
                                                          (loop for dy from 0 below (array-dimension (cells (world-map world)) 1) do
                                                            (when (and (or (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-forest)
                                                                           (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-lake)
                                                                           (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-residential)
                                                                           (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-island)
                                                                           (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-port))
                                                                       (find +lm-feat-church+ (feats (aref (cells (world-map world)) dx dy)) :key #'(lambda (a) (first a))))
                                                              (setf free-church-present t)))
                                                        finally (return free-church-present)))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-military+)
                                             (push (list +faction-type-military+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-military+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
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

                                                         ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                         
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
                  :campaign-result (list (list :game-over-angels-won (list #'move-relic-to-church))
                                         (list :game-over-demons-won nil)
                                         (list :game-over-military-won (list #'move-relic-to-church))
                                         (list :game-over-church-won (list #'move-relic-to-church))
                                         (list :game-over-satanists-won nil)
                                         (list :game-over-eater-won nil))
                  )

(set-mission-type :id :mission-type-eliminate-satanists
                  :name "Satanist elimination"
                  :mission-slot-type :mission-slot-military-city
                  :is-available-func #'(lambda (world-sector world)
                                         (if (and (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a)))
                                                  (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible))
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
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list))
                                           (when (or (not (mission world-sector))
                                                     (not (find +lm-misc-eater-incursion+ (level-modifier-list (mission world-sector)))))
                                             (push (list +faction-type-eater+ :mission-faction-absent) faction-list))
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

                                                        ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                        
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
                                         (list :game-over-eater-won (list #'remove-satanist-lair-from-map #'move-military-to-free-sector #'move-demons-to-free-sector)))
                  )

(set-mission-type :id :mission-type-celestial-sabotage
                  :name "Celestial sabotage"
                  :mission-slot-type :mission-slot-angels-offworld
                  :is-available-func #'(lambda (world-sector world)
                                         (let* ((angels-win-cond (get-win-condition-by-id :win-cond-angels-campaign))
                                                (machines-left (funcall (win-condition/win-func angels-win-cond) world angels-win-cond)))
                                           (if (and (or (eq (wtype world-sector) :world-sector-hell-jungle))
                                                    (> machines-left 0))
                                             t
                                             nil)))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-angels+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-hell-jungle
                                                          )
                  :overall-post-process-func-list #'(lambda ()
                                                       (let ((func-list ()))

                                                         ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                         
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
                                         (list +faction-type-angels+ (list +ai-package-patrol-district+ +ai-package-find-machine+))
                                         )
                  :ability-list (list (list +faction-type-angels+ (list +mob-abil-detect-machines+)))
                  :win-condition-list (list (list +faction-type-demons+ +game-event-angelic-sabotage-win-for-demons+)
                                            (list +faction-type-angels+ +game-event-angelic-sabotage-win-for-angels+)
                                            )
                  :campaign-result (list (list :game-over-angels-won (list #'remove-hell-engine #'throw-hell-in-turmoil))
                                         (list :game-over-demons-won nil))
                  )

(set-mission-type :id :mission-type-military-sabotage
                  :name "Military sabotage"
                  :mission-slot-type :mission-slot-military-offworld
                  :is-available-func #'(lambda (world-sector world)
                                         (if (and (or (eq (wtype world-sector) :world-sector-hell-jungle))
                                                  (> (world/flesh-points world) 0))
                                           t
                                           nil))
                  :faction-list-func #'(lambda (world-sector)
                                         (let ((faction-list (list (list +faction-type-military+ :mission-faction-present))))
                                           (if (= (controlled-by world-sector) +lm-controlled-by-demons+)
                                             (push (list +faction-type-demons+ :mission-faction-present) faction-list)
                                             (push (list +faction-type-demons+ :mission-faction-delayed) faction-list)
                                             )
                                           faction-list))
                  :world-sector-for-custom-scenario (list :world-sector-hell-jungle
                                                          )
                  :overall-post-process-func-list #'(lambda ()
                                                       (let ((func-list ()))

                                                         ;; set up initial power
                                                        (push #'set-up-inital-power
                                                              func-list)
                                                         
                                                         ;; add lose condition on death & all other win conditions
                                                         (push #'add-lose-and-win-coditions-to-level
                                                               func-list)

                                                         ;; remove signal flares from military
                                                         (push #'remove-signal-flares-from-military
                                                               func-list)

                                                         ;; add bombs to military
                                                         (push #'add-bombs-to-military
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
                                                         
                                                         ;; add military
                                                         (push #'place-ai-military-on-level
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
                                         (list +faction-type-military+ (list +ai-package-patrol-district+ +ai-package-find-bomb-plant-location+))
                                         )
                  :win-condition-list (list (list +faction-type-demons+ +game-event-military-sabotage-win-for-demons+)
                                            (list +faction-type-military+ +game-event-military-sabotage-win-for-military+)
                                            )
                  :campaign-result (list (list :game-over-military-won (list #'remove-raw-flesh-from-demons #'throw-hell-in-turmoil))
                                         (list :game-over-demons-won nil))
                  )
