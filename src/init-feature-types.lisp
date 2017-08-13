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

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-small+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Small Gold Pile Placeholder"))

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-big+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Big Gold Pile Placeholder"))

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
                                                               )
                                               :on-tick-func #'feature-smoke-on-tick))

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
                                                               )
                                               :on-tick-func #'feature-smoke-on-tick))

(set-feature-type (make-instance 'feature-type :id +feature-fire+ :glyph-idx 120 :glyph-color (sdl:color :r 255 :g 69 :b 0) :back-color sdl:*black* :name "Fire" :trait-fire t
                                               :merge-func #'(lambda (level feature-new)
                                                               (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                     for feature-old = (get-feature-by-id feature-old-id)
                                                                     when (= (feature-type feature-new) (feature-type feature-old))
                                                                       do
                                                                          (remove-feature-from-level-list level feature-new)
                                                                          (remove-feature-from-world feature-new)
                                                                          (incf (counter feature-old))
                                                                          (loop-finish)
                                                                     )
                                                               )
                                               :on-tick-func #'(lambda (level feature)
                                                                 ;; damage mobs
                                                                 (when (get-mob-* level (x feature) (y feature) (z feature))
                                                                   (let ((cur-dmg (1+ (random (counter feature))))
                                                                         (target (get-mob-* level (x feature) (y feature) (z feature))))

                                                                     ;; reduce damage by the amount of risistance to this damage type
                                                                     ;; first reduce the damage directly
                                                                     ;; then - by percent
                                                                     (when (get-armor-resist target +weapon-dmg-fire+)
                                                                       (decf cur-dmg (get-armor-d-resist target +weapon-dmg-fire+))
                                                                       (setf cur-dmg (truncate (* cur-dmg (- 100 (get-armor-%-resist target +weapon-dmg-fire+))) 100)))
                                                                     (when (< cur-dmg 0) (setf cur-dmg 0))
                                                                     
                                                                     ;; target under protection of divine shield - consume the shield and do not harm
                                                                     (when (mob-effect-p target +mob-effect-divine-shield+)
                                                                       (setf cur-dmg 0)
                                                                       (rem-mob-effect target +mob-effect-divine-shield+))
                                                                     
                                                                     (decf (cur-hp target) cur-dmg)
                                                                     (if (zerop cur-dmg)
                                                                       (progn
                                                                         (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                (format nil "~@(~A~) is not harmed by fire.~%" (visible-name target))))
                                                                       (progn
                                                                         (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                (format nil "~@(~A~) takes ~A fire damage.~%" (visible-name target) cur-dmg))))
                                                                     (when (check-dead target)
                                                                       (when (eq target *player*)
                                                                         (setf (killed-by *player*) "fire"))
                                                                       (if (mob-effect-p target +mob-effect-possessed+)
                                                                         (make-dead target :splatter t :msg t :msg-newline nil :killer nil :corpse nil :aux-params '(:is-fire))
                                                                         (make-dead target :splatter t :msg t :msg-newline nil :killer nil :corpse t :aux-params '(:is-fire)))
                                                                                                   
                                                                       )))
                                                                 ;; spread fire
                                                                 (let ((dir (1+ (random 9)))
                                                                       (dx) (dy))
                                                                   (multiple-value-setq (dx dy) (x-y-dir dir))
                                                                   (setf dx (+ (x feature) dx) dy (+ (y feature) dy))
                                                                   (ignite-tile level dx dy (z feature) (x feature) (y feature) (z feature)))
                                                                 ;; produce smoke
                                                                 (when (<= (random 3) 1)
                                                                   (add-feature-to-level-list level (make-instance 'feature :feature-type +feature-smoke-thin+ :x (x feature) :y (y feature) :z (z feature))))
                                                                 ;; decrease counter and die out
                                                                 (decf (counter feature))
                                                                 (when (<= (counter feature) 0)
                                                                   (remove-feature-from-level-list level feature)
                                                                   (remove-feature-from-world feature))
                                                                 )))
								
