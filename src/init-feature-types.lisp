(in-package :cotd)

;;--------------------
;; FEATURE-TYPE Declarations
;;-------------------- 

(set-feature-type (make-instance 'feature-type :id +feature-blood-old+ :glyph-idx nil :glyph-color (rgb 100 0 0) :back-color nil :name "Bloodstain"
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

(set-feature-type (make-instance 'feature-type :id +feature-blood-fresh+ :glyph-idx nil :glyph-color (rgb 250 0 0) :back-color nil :name "Bloodstain"
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

(set-feature-type (make-instance 'feature-type :id +feature-blood-stain+ :glyph-idx 97 :glyph-color (rgb 250 0 0) :back-color +color-black+ :name "Bloodstain"
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

(set-feature-type (make-instance 'feature-type :id +feature-start-satanist-player+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Player Satanist Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-arrival-point-north+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "North Delayed Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-arrival-point-south+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "South Delayed Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-arrival-point-east+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "East Delayed Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-arrival-point-west+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "West Delayed Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-military-arrival-point+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Delayed Military Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-angels-arrival-point+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Delayed Angels Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-demons-arrival-point+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Delayed Demons Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-demons+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Demons Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-small+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Small Gold Pile Placeholder"))

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-big+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Big Gold Pile Placeholder"))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thin+ :glyph-idx +glyph-id-double-tilda+ :glyph-color (rgb 200 200 200) :back-color +color-black+ :name "Smoke"
                                               :trait-blocks-vision 60 :trait-smoke +feature-smoke-thin+ :trait-no-gravity t
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

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thick+ :glyph-idx +glyph-id-double-tilda+ :glyph-color (rgb 200 200 200) :back-color +color-black+ :name "Smoke"
                                               :trait-blocks-vision 80 :trait-smoke +feature-smoke-thin+ :trait-no-gravity t
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

(set-feature-type (make-instance 'feature-type :id +feature-fire+ :glyph-idx 120 :glyph-color (rgb 255 69 0) :back-color +color-black+ :name "Fire" :trait-fire t
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
                                                                   (let ((target (get-mob-* level (x feature) (y feature) (z feature))))

                                                                     (inflict-damage target :min-dmg 1 :max-dmg (counter feature) :dmg-type +weapon-dmg-fire+
                                                                                            :att-spd nil :weapon-aux '(:is-fire) :acc 100 :add-blood nil :no-dodge t
                                                                                            :actor nil :no-hit-message t
                                                                                            :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                                          (format nil "~A takes ~A fire damage. " (capitalize-name (name target)) cur-dmg))
                                                                                            :specific-no-dmg-string-func #'(lambda ()
                                                                                                                             (format nil "~A takes no damage from fire. " (capitalize-name (name target)))))

                                                                     (when (check-dead target)
                                                                       (when (eq target *player*)
                                                                         (setf (killed-by *player*) "fire")))
                                                                     ))
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
								
(set-feature-type (make-instance 'feature-type :id +feature-start-church-player+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Player Church Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-relic+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Relic Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-book-of-rituals+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Church Book of Rituals Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-repel-demons+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Repel Demons Starting Location" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-strong-repel-demons+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Repel Demons Starting Location" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-military+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Military Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-sigil-point+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Sigil Starting Position" :trait-remove-on-dungeon-generation t :trait-no-gravity t))

(set-feature-type (make-instance 'feature-type :id +feature-start-machine-point+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Machine Starting Position" :trait-remove-on-dungeon-generation t :trait-no-gravity t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-angels+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Angel Starting Position" :trait-remove-on-dungeon-generation t :trait-no-gravity t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-church-priest+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Priest Starting Position" :trait-remove-on-dungeon-generation t :trait-no-gravity t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-man+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Man Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-woman+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Woman Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-child+ :glyph-idx 0 :glyph-color +color-black+ :back-color +color-black+ :name "Child Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-flare+ :glyph-idx +glyph-id-double-tilda+ :glyph-color +color-magenta+ :back-color +color-black+ :name "Smoke"
                                               :trait-blocks-vision 60 :trait-smoke +feature-smoke-flare+ :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    )
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
                                                                          (loop-finish)
                                                                     )
                                                               )
                                               :on-tick-func #'feature-smoke-on-tick))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-flare-final+ :glyph-idx +glyph-id-double-tilda+ :glyph-color +color-magenta+ :back-color +color-black+ :name "Smoke"
                                               :trait-blocks-vision 60 :trait-smoke +feature-smoke-flare-final+ :trait-no-gravity t
                                               :on-tick-func #'(lambda (level feature)
                                                                 (decf (counter feature))

                                                                 (when (zerop (counter feature))

                                                                   (print-visible-message (x feature) (y feature) (z feature) (level *world*) 
                                                                                          (format nil "Artillery shoots. "))
                                                                   
                                                                   (let ((x (x feature))
                                                                         (y (y feature))
                                                                         (z (z feature))
                                                                         (max-range 2)
                                                                         (killer (get-mob-by-id (param1 feature))))
                                                                     (remove-feature-from-level-list level feature)
                                                                     (remove-feature-from-world feature)
                                                                     
                                                                     (make-explosion-at-xyz level x y z max-range killer))
                                                                   )
                                                                 )))

(set-feature-type (make-instance 'feature-type :id +feature-corrosive-bile-target+ :glyph-idx 99 :glyph-color +color-yellow+ :back-color +color-black+ :name "Bile destination"
                                               :trait-no-gravity t
                                               :on-tick-func #'(lambda (level feature)
                                                                 (decf (counter feature))

                                                                 (when (zerop (counter feature))

                                                                   (print-visible-message (x feature) (y feature) (z feature) (level *world*) 
                                                                                          (format nil "Corrosive bile lands. "))

                                                                   (let ((x (x feature))
                                                                         (y (y feature))
                                                                         (z (z feature))
                                                                         (max-range 2)
                                                                         (killer (get-mob-by-id (param1 feature))))
                                                                     (remove-feature-from-level-list level feature)
                                                                     (remove-feature-from-world feature)
                                                                     
                                                                     (make-explosion-at-xyz level x y z max-range killer
                                                                                            :dmg-list `((:min-dmg 4 :max-dmg 8 :dmg-type ,+weapon-dmg-acid+ :weapon-aux ()))
                                                                                            :animation-dot-id +anim-type-acid-dot+))
                                                                   )
                                                                 )))

(set-feature-type (make-instance 'feature-type :id +feature-sacrificial-circle+ :glyph-idx +glyph-id-sacrificial-circle+ :glyph-color +color-magenta+ :back-color nil :name "Sacrificial circle"
                                 ))

(set-feature-type (make-instance 'feature-type :id +feature-bomb-plant-target+ :glyph-idx +glyph-id-target-icon+ :glyph-color (rgb 255 140 0) :back-color nil :name "Target bomb location"))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-flesh+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Un"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-flesh+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-invite+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Ged"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-invite+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-away+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Veh"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-away+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-transform+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Med"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-transform+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-barrier+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Gon"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-barrier+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-all+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Tal"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-all+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-decay+ :glyph-idx 123 :glyph-color +color-magenta+ :back-color nil :name "Demonic rune Drux"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-decay+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-portal+ :glyph-idx +glyph-id-portal+ :glyph-color (rgb 255 165 0) :back-color nil :name "Demonic portal"
                                 ))

(set-feature-type (make-instance 'feature-type :id +feature-divine-portal+ :glyph-idx +glyph-id-portal+ :glyph-color +color-cyan+ :back-color nil :name "Divine portal"
                                 ))

(set-feature-type (make-instance 'feature-type :id +feature-corrupted-spores+ :glyph-idx +glyph-id-double-tilda+ :glyph-color (rgb 100 0 0) :back-color +color-black+ :name "Spores"
                                               :trait-blocks-vision 30 :trait-smoke +feature-corrupted-spores+ :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    )
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
                                                                          (loop-finish)
                                                                     )
                                                               )
                                               :on-tick-func #'(lambda (level feature)
                                                                 (let ((target (get-mob-* level (x feature) (y feature) (z feature))))
                                                                   (when target
                                                                     (inflict-damage target :min-dmg 1 :max-dmg 2 :dmg-type +weapon-dmg-acid+
                                                                                            :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t
                                                                                            :actor nil :no-hit-message t
                                                                                            :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                                          (format nil "~A takes ~A damage from spores. " (capitalize-name (name target)) cur-dmg))
                                                                                            :specific-no-dmg-string-func #'(lambda ()
                                                                                                                             (format nil "~A takes no damage from spores. " (capitalize-name (name target)))))

                                                                     (when (check-dead target)
                                                                       (when (eq target *player*)
                                                                         (setf (killed-by *player*) "spores")))))
                                                                 (feature-smoke-on-tick level feature))))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-acid-gas+ :glyph-idx +glyph-id-double-tilda+ :glyph-color (rgb 0 200 0) :back-color +color-black+ :name "Poisoned gas"
                                               :trait-blocks-vision 60 :trait-smoke +feature-smoke-acid-gas+ :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old))
                                                                                    )
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
                                                                          (loop-finish)
                                                                     )
                                                               )
                                               :on-tick-func #'(lambda (level feature)
                                                                 (let ((target (get-mob-* level (x feature) (y feature) (z feature))))
                                                                   (when target
                                                                     (inflict-damage target :min-dmg 3 :max-dmg 6 :dmg-type +weapon-dmg-acid+
                                                                                            :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t
                                                                                            :actor nil :no-hit-message t
                                                                                            :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                                          (format nil "~A takes ~A damage from poisoned gas. " (capitalize-name (name target)) cur-dmg))
                                                                                            :specific-no-dmg-string-func #'(lambda ()
                                                                                                                             (format nil "~A takes no damage from poisoned gas. " (capitalize-name (name target)))))

                                                                     (when (check-dead target)
                                                                       (when (eq target *player*)
                                                                         (setf (killed-by *player*) "poisoned gas")))))
                                                                 (feature-smoke-on-tick level feature))))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-weak-acid-gas+ :glyph-idx +glyph-id-double-tilda+ :glyph-color +color-yellow+ :back-color +color-black+ :name "Acidic gas"
                                               :trait-blocks-vision 40 :trait-smoke +feature-smoke-weak-acid-gas+ :trait-no-gravity t
                                               :can-merge-func #'(lambda (level feature-new)
                                                                   (let ((result nil))
                                                                     (loop for feature-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                                                           for feature-old = (get-feature-by-id feature-old-id)
                                                                           when (or (= (feature-type feature-new) (feature-type feature-old)))
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
                                                                          (loop-finish)
                                                                     )
                                                               )
                                               :on-tick-func #'(lambda (level feature)
                                                                 (let ((target (get-mob-* level (x feature) (y feature) (z feature))))
                                                                   (when target
                                                                     (inflict-damage target :min-dmg 1 :max-dmg 2 :dmg-type +weapon-dmg-acid+
                                                                                            :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t
                                                                                            :actor nil :no-hit-message t
                                                                                            :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                                          (format nil "~A takes ~A damage from acidic gas. " (capitalize-name (name target)) cur-dmg))
                                                                                            :specific-no-dmg-string-func #'(lambda ()
                                                                                                                             (format nil "~A takes no damage from acidic gas. " (capitalize-name (name target)))))

                                                                     (when (check-dead target)
                                                                       (when (eq target *player*)
                                                                         (setf (killed-by *player*) "acidic gas")))))
                                                                 (feature-smoke-on-tick level feature))))
