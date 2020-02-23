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

(set-feature-type (make-instance 'feature-type :id +feature-start-satanist-player+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Player Satanist Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-arrival-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Delayed Arrival Point"))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-military-arrival-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Delayed Military Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-delayed-angels-arrival-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Delayed Angels Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-demons-arrival-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Demons Arrival Point" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-small+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Small Gold Pile Placeholder"))

(set-feature-type (make-instance 'feature-type :id +feature-start-gold-big+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Big Gold Pile Placeholder"))

(set-feature-type (make-instance 'feature-type :id +feature-start-demon-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Demon Point Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thin+ :glyph-idx 98 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Smoke"
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

(set-feature-type (make-instance 'feature-type :id +feature-smoke-thick+ :glyph-idx 98 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Smoke"
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
								
(set-feature-type (make-instance 'feature-type :id +feature-start-church-player+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Player Church Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-church-relic+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Church Relic Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-repel-demons+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Repel Demons Starting Location" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-strong-repel-demons+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Repel Demons Starting Location" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-military-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Military Defender Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-sigil-point+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Sigil Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-church-angels+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Angel Defender Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-church-priest+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Priest Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-man+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Man Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-woman+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Woman Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-start-place-civilian-child+ :glyph-idx 0 :glyph-color sdl:*black* :back-color sdl:*black* :name "Child Starting Position" :trait-remove-on-dungeon-generation t))

(set-feature-type (make-instance 'feature-type :id +feature-smoke-flare+ :glyph-idx 98 :glyph-color sdl:*magenta* :back-color sdl:*black* :name "Smoke"
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

(set-feature-type (make-instance 'feature-type :id +feature-smoke-flare-final+ :glyph-idx 98 :glyph-color sdl:*magenta* :back-color sdl:*black* :name "Smoke"
                                               :trait-blocks-vision 60 :trait-smoke +feature-smoke-flare-final+ :trait-no-gravity t
                                               :on-tick-func #'(lambda (level feature)
                                                                 (decf (counter feature))

                                                                 (when (zerop (counter feature))

                                                                   (print-visible-message (x feature) (y feature) (z feature) (level *world*) 
                                                                                          (format nil "Artillery shoots. "))
                                                                   
                                                                   (let ((targets nil)
                                                                         ;;(cell-targets nil)
                                                                         (max-range 2))
                                                                     (draw-fov (x feature) (y feature) (z feature) max-range
                                                                               #'(lambda (dx dy dz prev-cell)
                                                                                   (let ((exit-result t))
                                                                                     (block nil
                                                                                       (when (> (get-distance-3d (x feature) (y feature) (z feature) dx dy dz) (1+ max-range))
                                                                                         (setf exit-result 'exit)
                                                                                         (return))
                                                                                       
                                                                                       (when (eq (check-LOS-propagate dx dy dz prev-cell :check-move t) nil)
                                                                                         (setf exit-result 'exit)
                                                                                         (return))

                                                                                       (place-animation dx dy dz +anim-type-fire-dot+ :params ())

                                                                                       ;;(when (and (get-terrain-* level dx dy dz)
                                                                                       ;;           (get-terrain-type-trait (get-terrain-* level dx dy dz) +terrain-trait-flammable+))
                                                                                       ;;  (push (list dx dy dz) cell-targets))
                                                                                       
                                                                                       (when (and (get-mob-* level dx dy dz) 
                                                                                                  )
                                                                                         (pushnew (get-mob-* level dx dy dz) targets)
                                                                                         )
                                                                                       )
                                                                                     exit-result)))

                                                                     ;; inflict damage to mobs
                                                                     (loop for target in targets
                                                                           for cur-dmg = 0
                                                                           do
                                                                              (incf cur-dmg (inflict-damage target :min-dmg 3 :max-dmg 6 :dmg-type +weapon-dmg-fire+
                                                                                                                   :att-spd nil :weapon-aux (list :is-fire) :acc 100 :add-blood t :no-dodge t :no-hit-message t :no-check-dead t
                                                                                                                   :actor (get-mob-by-id (param1 feature))))
                                                                              (incf cur-dmg (inflict-damage target :min-dmg 5 :max-dmg 7 :dmg-type +weapon-dmg-iron+
                                                                                                                   :att-spd nil :weapon-aux (list :is-fire) :acc 100 :add-blood t :no-dodge t :no-hit-message t :no-check-dead t
                                                                                                                   :actor (get-mob-by-id (param1 feature))))
                                                                              
                                                                              (if (zerop cur-dmg)
                                                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                       (format nil "~A is not hurt. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                                                       :color sdl:*white*
                                                                                                       :tags (list (when (and (find (id target) (shared-visible-mobs *player*))
                                                                                                                              (not (find (id target) (proper-visible-mobs *player*))))
                                                                                                                     :singlemind)))
                                                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                       (format nil "~A takes ~A damage. " (capitalize-name (prepend-article +article-the+ (visible-name target))) cur-dmg)
                                                                                                       :color sdl:*white*
                                                                                                       :tags (list (when (and (find (id target) (shared-visible-mobs *player*))
                                                                                                                              (not (find (id target) (proper-visible-mobs *player*))))
                                                                                                                     :singlemind))))
                                                                              (when (check-dead target)
                                                                                (make-dead target :splatter t :msg t :msg-newline nil :killer (get-mob-by-id (param1 feature)) :corpse t :aux-params (list :is-fire))
                                                                                
                                                                                (when (mob-effect-p target +mob-effect-possessed+)
                                                                                  (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                                                  (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                                                        (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                                                        (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                                                  (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))))

                                                                     ;; place fires
                                                                     ;; TODO: should not be implemented until ignite-tile properly sets ignited tile connectivity
                                                                     ;;(loop for (dx dy dz) in cell-targets
                                                                     ;;      when (and (zerop (random 5))
                                                                     ;;                (get-terrain-type-trait (get-terrain-* level dx dy dz) +terrain-trait-flammable+))
                                                                     ;;        do
                                                                     ;;           (ignite-tile level dx dy dz dx dy dz)
                                                                     ;;      )

                                                                     (remove-feature-from-level-list level feature)
                                                                     (remove-feature-from-world feature)
                                                                     
                                                                     ;; process animations for this turn if any
                                                                     (when (animation-queue *world*)
                                                                       
                                                                       (loop for animation in (animation-queue *world*)
                                                                             do
                                                                                (play-animation animation))
                                                                       (sdl:update-display)
                                                                       (sdl-cffi::sdl-delay 100)
                                                                       (setf (animation-queue *world*) nil)
                                                                       (update-map-area))
                                                                   
                                                                   ))
                                                                 )))

(set-feature-type (make-instance 'feature-type :id +feature-corrosive-bile-target+ :glyph-idx 99 :glyph-color sdl:*yellow* :back-color sdl:*black* :name "Bile destination"
                                               :trait-no-gravity t
                                               :on-tick-func #'(lambda (level feature)
                                                                 (decf (counter feature))

                                                                 (when (zerop (counter feature))

                                                                   (print-visible-message (x feature) (y feature) (z feature) (level *world*) 
                                                                                          (format nil "Corrosive bile lands. "))
                                                                   
                                                                   (let ((targets nil)
                                                                         (max-range 1))
                                                                     (draw-fov (x feature) (y feature) (z feature) max-range
                                                                               #'(lambda (dx dy dz prev-cell)
                                                                                   (let ((exit-result t))
                                                                                     (block nil
                                                                                       (when (> (get-distance-3d (x feature) (y feature) (z feature) dx dy dz) (1+ max-range))
                                                                                         (setf exit-result 'exit)
                                                                                         (return))
                                                                                       
                                                                                       (when (eq (check-LOS-propagate dx dy dz prev-cell :check-move t) nil)
                                                                                         (setf exit-result 'exit)
                                                                                         (return))

                                                                                       (place-animation dx dy dz +anim-type-acid-dot+ :params ())
                                                                                       
                                                                                       (when (and (get-mob-* level dx dy dz) 
                                                                                                  )
                                                                                         (pushnew (get-mob-* level dx dy dz) targets)
                                                                                         )
                                                                                       )
                                                                                     exit-result)))

                                                                     (loop for target in targets
                                                                           for cur-dmg = 0
                                                                           do
                                                                              (incf cur-dmg (inflict-damage target :min-dmg 4 :max-dmg 8 :dmg-type +weapon-dmg-acid+
                                                                                                                   :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t :no-hit-message t :no-check-dead t
                                                                                                                   :actor (get-mob-by-id (param1 feature))))
                                                                              (if (zerop cur-dmg)
                                                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                       (format nil "~A is not hurt. " (capitalize-name (prepend-article +article-the+ (visible-name target))))
                                                                                                       :color sdl:*white*
                                                                                                       :tags (list (when (and (find (id target) (shared-visible-mobs *player*))
                                                                                                                              (not (find (id target) (proper-visible-mobs *player*))))
                                                                                                                     :singlemind)))
                                                                                (print-visible-message (x target) (y target) (z target) (level *world*) 
                                                                                                       (format nil "~A takes ~A damage. " (capitalize-name (prepend-article +article-the+ (visible-name target))) cur-dmg)
                                                                                                       :color sdl:*white*
                                                                                                       :tags (list (when (and (find (id target) (shared-visible-mobs *player*))
                                                                                                                              (not (find (id target) (proper-visible-mobs *player*))))
                                                                                                                     :singlemind))))
                                                                              (when (check-dead target)
                                                                                (make-dead target :splatter t :msg t :msg-newline nil :killer (get-mob-by-id (param1 feature)) :corpse t :aux-params (list :is-fire))
                                                                                
                                                                                (when (mob-effect-p target +mob-effect-possessed+)
                                                                                  (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
                                                                                  (setf (x (get-mob-by-id (slave-mob-id target))) (x target)
                                                                                        (y (get-mob-by-id (slave-mob-id target))) (y target)
                                                                                        (z (get-mob-by-id (slave-mob-id target))) (z target))
                                                                                  (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))))

                                                                     (remove-feature-from-level-list level feature)
                                                                     (remove-feature-from-world feature)
                                                                     
                                                                     ;; process animations for this turn if any
                                                                     (when (animation-queue *world*)
                                                                       
                                                                       (loop for animation in (animation-queue *world*)
                                                                             do
                                                                                (play-animation animation))
                                                                       (sdl:update-display)
                                                                       (sdl-cffi::sdl-delay 100)
                                                                       (setf (animation-queue *world*) nil)
                                                                       (update-map-area))
                                                                   
                                                                   ))
                                                                 )))

(set-feature-type (make-instance 'feature-type :id +feature-sacrificial-circle+ :glyph-idx +glyph-id-sacrificial-circle+ :glyph-color sdl:*magenta* :back-color nil :name "Sacrificial circle"
                                 ))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-flesh+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Un"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-flesh+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-invite+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Ged"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-invite+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-away+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Veh"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-away+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-transform+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Med"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-transform+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-barrier+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Gon"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-barrier+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-all+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Tal"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-all+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-rune-decay+ :glyph-idx 123 :glyph-color sdl:*magenta* :back-color nil :name "Demonic rune Drux"
                                               :trait-demonic-rune +item-type-scroll-demonic-rune-decay+))

(set-feature-type (make-instance 'feature-type :id +feature-demonic-portal+ :glyph-idx 126 :glyph-color (sdl:color :r 255 :g 165 :b 0) :back-color nil :name "Demonic portal"
                                 ))

(set-feature-type (make-instance 'feature-type :id +feature-corrupted-spores+ :glyph-idx 98 :glyph-color (sdl:color :r 100 :g 0 :b 0) :back-color sdl:*black* :name "Spores"
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

(set-feature-type (make-instance 'feature-type :id +feature-smoke-acid-gas+ :glyph-idx 98 :glyph-color (sdl:color :r 0 :g 200 :b 0) :back-color sdl:*black* :name "Poisoned gas"
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
