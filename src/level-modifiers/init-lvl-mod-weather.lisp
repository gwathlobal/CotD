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
                                                      (if (< (random 100) 50)
                                                        t
                                                        nil)
                                                      nil))
                                                  ))

(set-level-modifier :id +lm-weather-snow+ :type +level-mod-weather+
                    :name "Snow"
                    :is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                  (declare (ignore world-sector mission-type-id))
                                                  (multiple-value-bind (year month day hour min sec) (get-current-date-time world-time)
                                                    (declare (ignore year day hour min sec))
                                                    (if (or (= month 11) (= month 0) (= month 1))
                                                      t
                                                      nil))))
