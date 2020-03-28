(in-package :cotd)

(set-win-condition :id :win-cond-demonic-attack
                   :win-formula 60
                   :win-func #'(lambda (world win-condition)
                                 (- (truncate (* (initial-civilians (level world)) (/ (win-condition/win-formula win-condition) 100)))
                                    (lost-civilians (level world))))
                   )
