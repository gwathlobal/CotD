(in-package :cotd)

;;---------------------------------
;; Time of Day level modifiers
;;---------------------------------

(set-level-modifier :id +lm-tod-morning+ :type +level-mod-time-of-day+
                    :name "Morning"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission))

                                                                    (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
                                                                      (setf hour 7)
                                                                      (setf min (random 45))
                                                                      (setf sec (random 60))

                                                                      (setf (world-game-time world) (set-current-date-time year month day hour min sec)))

                                                                    (set-up-outdoor-light level 50)
                                                                    )
                                                                func-list)
                                                          (reverse func-list))))

(set-level-modifier :id +lm-tod-noon+ :type +level-mod-time-of-day+
                    :name "Afternoon"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission))

                                                                    (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
                                                                      (setf hour 12)
                                                                      (setf min (random 45))
                                                                      (setf sec (random 60))

                                                                      (setf (world-game-time world) (set-current-date-time year month day hour min sec)))

                                                                    (set-up-outdoor-light level 100)
                                                                    
                                                                    )
                                                                func-list)
                                                          (reverse func-list))))

(set-level-modifier :id +lm-tod-evening+ :type +level-mod-time-of-day+
                    :name "Evening"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission))

                                                                    (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
                                                                      (setf hour 19)
                                                                      (setf min (random 45))
                                                                      (setf sec (random 60))

                                                                      (setf (world-game-time world) (set-current-date-time year month day hour min sec)))

                                                                    (set-up-outdoor-light level 50)
                                                                    )
                                                                func-list)
                                                          (reverse func-list))))

(set-level-modifier :id +lm-tod-night+ :type +level-mod-time-of-day+
                    :name "Midnight"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission))

                                                                    (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
                                                                      (setf hour 0)
                                                                      (setf min (random 45))
                                                                      (setf sec (random 60))

                                                                      (setf (world-game-time world) (set-current-date-time year month day hour min sec)))

                                                                    (set-up-outdoor-light level 0)
                                                                    )
                                                                func-list)
                                                          (reverse func-list))))
