(in-package :cotd)

(set-win-condition :id :win-cond-demonic-attack
                   :win-formula 60
                   :win-func #'(lambda (world win-condition)
                                 (- (truncate (* (initial-civilians (level world)) (/ (win-condition/win-formula win-condition) 100)))
                                    (lost-civilians (level world))))
                   )

(set-win-condition :id :win-cond-demonic-raid
                   :win-formula 300
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

(set-win-condition :id :win-cond-demonic-conquest
                   :win-formula (list 4 100)
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )

(set-win-condition :id :win-cond-military-conquest
                   :win-formula 4
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )

(set-win-condition :id :win-cond-celestial-sabotage
                   :win-formula 4
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )

(set-win-condition :id :win-cond-military-sabotage
                   :win-formula 0
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore world win-condition))
                                 ;; do not do anything
                                 nil)
                   )

(set-win-condition :id :win-cond-demon-campaign
                   :win-formula 2000
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore win-condition))
                                 (let ((cells (cells (world-map world)))
                                       (world-sector nil)
                                       (normal-sum 0))
                                   (loop for x from 0 below (array-dimension cells 0) do
                                     (loop for y from 0 below (array-dimension cells 1) do
                                       (setf world-sector (aref cells x y))
                                       (when (world-sector-normal-p world-sector)
                                         (incf normal-sum))))
                                   normal-sum)
                                 )
                   )

(set-win-condition :id :win-cond-military-campaign
                   :win-formula 0
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore win-condition))
                                 (let ((cells (cells (world-map world)))
                                       (world-sector nil)
                                       (corrupted-sum 0)
                                       (satanists-num 0))
                                   (loop for x from 0 below (array-dimension cells 0) do
                                     (loop for y from 0 below (array-dimension cells 1) do
                                       (setf world-sector (aref cells x y))
                                       (when (world-sector-corrupted-p world-sector)
                                         (incf corrupted-sum))
                                       (when (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a)))
                                         (incf satanists-num))))
                                   (values corrupted-sum satanists-num))
                                 )
                   )

(set-win-condition :id :win-cond-angels-campaign
                   :win-formula 4
                   :win-func #'(lambda (world win-condition)
                                 (- (win-condition/win-formula win-condition) (world/machine-destroyed world)))
                   )

(set-win-condition :id :win-cond-eater-cosnume
                   :win-formula 0
                   :win-func #'(lambda (world win-condition)
                                 (declare (ignore win-condition))
                                 (truncate (+ (initial-angels (level world))
                                              (initial-humans (level world))
                                              (initial-demons (level world)))
                                           3)))
