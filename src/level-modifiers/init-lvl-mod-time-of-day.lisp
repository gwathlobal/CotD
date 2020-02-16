(in-package :cotd)

;;---------------------------------
;; Time of Day level modifiers
;;---------------------------------

(set-level-modifier :id +lm-tod-morning+ :type +level-mod-time-of-day+
                    :name "Morning")

(set-level-modifier :id +lm-tod-noon+ :type +level-mod-time-of-day+
                    :name "Afternoon")

(set-level-modifier :id +lm-tod-evening+ :type +level-mod-time-of-day+
                    :name "Evening")

(set-level-modifier :id +lm-tod-night+ :type +level-mod-time-of-day+
                    :name "Midnight")
