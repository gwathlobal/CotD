(in-package :cotd)

;;---------------------------------
;; Weather level modifiers
;;---------------------------------

(set-level-modifier :id +lm-weather-rain+ :type :level-mod-weather
                    :name "Rain"
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id))
                                                  (multiple-value-bind (year month day hour min sec) (get-current-date-time world-time)
                                                    (declare (ignore year day hour min sec))
                                                    (if (and (not (eq world-sector-type-id :world-sector-hell-plain))
                                                             (and (> month 1) (< month 11)))
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

                                                                    (logger (format nil "OVERALL-POST-PROCESS-FUNC: Add rain weather~%~%"))

                                                                    (pushnew +game-event-rain-falls+ (game-events level))
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-weather-acid-rain+ :type :level-mod-weather
                    :name "Acid rain"
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  (if (and (eq world-sector-type-id :world-sector-hell-plain))
                                                    t
                                                    nil)
                                                  )
                    :random-available-for-mission #'(lambda ()
                                                      (if (< (random 100) 25)
                                                        t
                                                        nil))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))

                                                                    (logger (format nil "OVERALL-POST-PROCESS-FUNC: Add poison rain weather~%~%"))

                                                                    (pushnew +game-event-acid-falls+ (game-events level))
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-weather-snow+ :type :level-mod-weather
                    :name "Snow"
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id))
                                                  (multiple-value-bind (year month day hour min sec) (get-current-date-time world-time)
                                                    (declare (ignore year day hour min sec))
                                                    (if (and (not (eq world-sector-type-id :world-sector-hell-plain))
                                                             (or (= month 11) (= month 0) (= month 1)))
                                                      t
                                                      nil)))
                    :terrain-post-process-func-list (lambda ()
                                                      (let ((func-list ()))
                                                        
                                                        (push #'change-level-to-snow func-list)
                                                                                                                
                                                        func-list))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))

                                                                    (logger (format nil "OVERALL-POST-PROCESS-FUNC: Add snow weather~%~%"))
                                                                    
                                                                    (pushnew +game-event-snow-falls+ (game-events level))
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))
