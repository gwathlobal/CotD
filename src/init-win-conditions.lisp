(in-package :cotd)

(set-win-condition :id :win-cond-demonic-attack
                   :win-formula 60
                   :win-func #'(lambda (world win-condition)
                                 (- (truncate (* (initial-civilians (level world)) (/ (win-condition/win-formula win-condition) 100)))
                                    (lost-civilians (level world))))
                   )

(set-win-condition :id :win-cond-demonic-raid
                   :win-formula 200
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )

(set-win-condition :id :win-cond-thief
                   :win-formula 1500
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )
