(in-package :cotd)

;;---------------------------------
;; Weather level modifiers
;;---------------------------------

(set-level-modifier :id +lm-weather-rain+ :type +level-mod-weather+
                    :name "Rain"
                    :is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                  (declare (ignore world-sector mission-type-id))
                                                  (multiple-value-bind (year month day hour min sec) (get-current-date-time world-time)
                                                    (declare (ignore year day hour min sec))
                                                    (if (and (> month 1) (< month 11))
                                                      t
                                                      nil))
                                                  )
                    :random-available-for-mission #'(lambda ()
                                                      (if (< (random 100) 25)
                                                        t
                                                        nil))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))

                                                                    (pushnew +game-event-rain-falls+ (game-events level))
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-weather-snow+ :type +level-mod-weather+
                    :name "Snow"
                    :is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                  (declare (ignore world-sector mission-type-id))
                                                  (multiple-value-bind (year month day hour min sec) (get-current-date-time world-time)
                                                    (declare (ignore year day hour min sec))
                                                    (if (or (= month 11) (= month 0) (= month 1))
                                                      t
                                                      nil))))
