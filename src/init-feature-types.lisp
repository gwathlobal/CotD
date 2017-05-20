(in-package :cotd)

;;--------------------
;; FEATURE-TYPE Declarations
;;-------------------- 

(set-feature-type (make-instance 'feature-type :id +feature-blood-old+ :glyph-idx nil :glyph-color (sdl:color :r 100 :b 0 :b 0) :back-color nil :name "Bloodstain"
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    (= (feature-type feature-old) +feature-blood-fresh+)
                                                                                    (= (feature-type feature-old) +feature-blood-stain+))
                                                                             do
                                                                                (setf result t)
                                                                                (loop-finish)
                                                                           )
                                                                     result))))

(set-feature-type (make-instance 'feature-type :id +feature-blood-fresh+ :glyph-idx nil :glyph-color (sdl:color :r 250 :b 0 :b 0) :back-color nil :name "Bloodstain"
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    (= (feature-type feature-old) +feature-blood-old+)
                                                                                    (= (feature-type feature-old) +feature-blood-stain+))
                                                                             do
                                                                                (setf result t)
                                                                                (loop-finish)
                                                                           )
                                                                     result))
                                               :merge-func #'(lambda (level feature-new)
                                                               (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                     for feature-old = (get-feature-by-id feature-old-id)
                                                                     when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                              (= (feature-type feature-old) +feature-blood-stain+))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (loop-finish)
                                                                     when (= (feature-type feature-old) +feature-blood-old+)
                                                                       do
                                                                          (remove-feature-from-level-list level feature-old)
                                                                          (remove-feature-from-world feature-old)
                                                                          (add-feature-to-level-list level feature-new)
                                                                          (loop-finish)
                                                                     )
                                                               )))

(set-feature-type (make-instance 'feature-type :id +feature-blood-stain+ :glyph-idx 97 :glyph-color (sdl:color :r 250 :b 0 :b 0) :back-color sdl:*black* :name "Bloodstain"
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    (= (feature-type feature-old) +feature-blood-old+)
                                                                                    (= (feature-type feature-old) +feature-blood-fresh+))
                                                                             do
                                                                                (setf result t)
                                                                                (loop-finish)
                                                                           )
                                                                     result))
                                               :merge-func #'(lambda (level feature-new)
                                                               (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                     for feature-old = (get-feature-by-id feature-old-id)
                                                                     when (= (feature-type feature-new) (feature-type feature-old))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (loop-finish)
                                                                     when (or (= (feature-type feature-old) +feature-blood-old+)
                                                                              (= (feature-type feature-old) +feature-blood-fresh+))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-old)
                                                                          (remove-feature-from-world feature-old)
                                                                          (add-feature-to-level-list level feature-new)
                                                                          (loop-finish)
                                                                     )
                                                               )))

(set-feature-type (make-instance 'feature-type :id +feature-start-satanist-player+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Player Satanist Starting Position"))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thin+ :glyph-idx 98 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Smoke" :trait-blocks-vision 60 :trait-smoke t :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    (= (feature-type feature-old) +feature-smoke-thick+))
                                                                             do
                                                                                (setf result t)
                                                                                (loop-finish)
                                                                           )
                                                                     result))
                                               :merge-func #'(lambda (level feature-new)
                                                               (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                     for feature-old = (get-feature-by-id feature-old-id)
                                                                     when (= (feature-type feature-new) (feature-type feature-old))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (incf (counter feature-old))
                                                                          (when (> (counter feature-old) 4)
                                                                            (setf (feature-type feature-old) +feature-smoke-thick+))
                                                                          (loop-finish)
                                                                     when (= (feature-type feature-old) +feature-smoke-thick+)
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (incf (counter feature-old))
                                                                          (loop-finish)
                                                                     )
                                                               )))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thick+ :glyph-idx 98 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Smoke" :trait-blocks-vision 80 :trait-smoke t :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    (= (feature-type feature-old) +feature-smoke-thin+))
                                                                             do
                                                                                (setf result t)
                                                                                (loop-finish)
                                                                           )
                                                                     result))
                                               :merge-func #'(lambda (level feature-new)
                                                               (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                     for feature-old = (get-feature-by-id feature-old-id)
                                                                     when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                              (= (feature-type feature-old) +feature-smoke-thin+))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (incf (counter feature-old))
                                                                          (loop-finish)
                                                                     )
                                                               )))
								
