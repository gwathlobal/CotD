(in-package :cotd)

(set-level-modifier :id +lm-misc-eater-incursion+ :type :level-mod-misc
                    :name "Primordial incursion"
                    :faction-list-func #'(lambda (sector-type-id)
                                           (declare (ignore sector-type-id))
                                           (list (list +faction-type-eater+ :mission-faction-present)))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  (if (not (eql world-sector-type-id :world-sector-hell-jungle))
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

