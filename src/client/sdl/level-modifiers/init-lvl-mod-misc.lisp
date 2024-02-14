(in-package :cotd-sdl)

(set-level-modifier :id +lm-misc-eater-incursion+ :type :level-mod-misc
                    :name "Primordial incursion"
                    :faction-list-func #'(lambda (sector-type-id)
                                           (declare (ignore sector-type-id))
                                           (list (list +faction-type-eater+ :mission-faction-present)))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore world-time))
                                                  (if (and (not (world-sector-hell-p (get-world-sector-type-by-id world-sector-type-id)))
                                                           (not (eql mission-type-id :mission-type-eliminate-satanists)))
                                                    t
                                                    nil))
                    :random-available-for-mission #'(lambda ()
                                                      (if (< (random 100) 20)
                                                        t
                                                        nil))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          
                                                          ;; place mass eaters of the dead
                                                          (push #'place-mass-primordials-on-level
                                                                func-list)

                                                          func-list)))

(set-level-modifier :id +lm-misc-malseraphs-blessing+ :type :level-mod-misc
                    :name "Malseraph's blessing"
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore world-sector-type-id mission-type-id world-time))
                                                  t)
                    :random-available-for-mission #'(lambda ()
                                                      (if (< (random 100) 20)
                                                        t
                                                        nil))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          
                                                          ;; place mass eaters of the dead
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))
                                                                    (pushnew +game-event-malseraphs-power-infusion+ (game-events level)))
                                                                func-list)

                                                          func-list)))

