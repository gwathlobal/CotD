(in-package :cotd)

;;--------------------
;; TERRAIN-TEMPLATE Declarations
;;-------------------- 

;;--------------------
;; Borders
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor+ :name "dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision t :trait-blocks-vision-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound t :trait-blocks-sound-floor t :trait-not-climable t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor-snow+ :name "snow"
                                               :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision t :trait-blocks-vision-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-water+ :name "water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 10 :trait-blocks-sound-floor 10 :trait-not-climable t :trait-water t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-grass+ :name "grass"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision t :trait-blocks-vision-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-air+ :name "air"
                                               :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-creep+ :name "creep"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 100 :g 0 :b 100) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision t :trait-blocks-vision-floor t :trait-blocks-projectiles t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound t :trait-blocks-sound-floor t :trait-not-climable t))


;;--------------------
;; Floors
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-stone+ :name "stone floor"
                                               :glyph-idx +glyph-id-solid-floor+ :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-glass+ :name "transparent floor"
                                               :glyph-idx +glyph-id-solid-floor+ :glyph-color sdl:*cyan* :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-grass+ :name "grass"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 3))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt+ :name "dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt-bright+ :name "dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow+ :name "snow"
                                               :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :on-step #'(lambda (mob x y z)
                                                            (when (not (mob-ability-p mob +mob-abil-float+))
                                                              (set-terrain-* (level *world*) x y z +terrain-floor-snow-prints+)))
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow-prints+ :name "snow"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 80 :g 80 :b 155) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bridge+ :name "bridge"
                                               :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-pier+ :name "pier"
                                               :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black*
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-ash+ :name "ash"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 70 :g 70 :b 70) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-sign-church-catholic+ :name "sign \"The Catholic Church of the One\""
                                               :glyph-idx 122 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-sign-church-orthodox+ :name "sign \"The Orthodox Church of the One\""
                                               :glyph-idx 122 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-sign-library+ :name "sign \"The Library of His Imperial Majesty\""
                                               :glyph-idx 122 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-sign-prison+ :name "sign \"City Prison\""
                                               :glyph-idx 122 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-sign-bank+ :name "sign \"Bank of Morozov and Sons\""
                                               :glyph-idx 122 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep+ :name "creep"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 100 :g 0 :b 100) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep-bright+ :name "creep"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 255 :g 0 :b 255) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep-dreadtubes+ :name "dreadtubes"
                                               :glyph-idx 129 :glyph-color (sdl:color :r 105 :g 50 :b 255) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20
                                               :on-step #'(lambda (mob x y z)
                                                            (when (< (random 100) 20)
                                                              (generate-sound mob (x mob) (y mob) (z mob) 100 #'(lambda (str)
                                                                                                                  (format nil "You hear an eerie howl~A. " str)))
                                                              (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                     (format nil "Dreadtubes give off an eerie howl under ~A. " (prepend-article +article-the+ (visible-name mob)))
                                                                                     :color sdl:*white*
                                                                                     :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                   :singlemind)))
                                                              (let ((mob))
                                                                (check-surroundings x y t #'(lambda (dx dy)
                                                                                              (when (and (>= dx 0)
                                                                                                         (>= dy 0)
                                                                                                         (< dx (array-dimension (terrain (level *world*)) 0))
                                                                                                         (< dy (array-dimension (terrain (level *world*)) 1))
                                                                                                         (get-mob-* (level *world*) dx dy z))
                                                                                                (setf mob (get-mob-* (level *world*) dx dy z))
                                                                                                (if (> (random (+ (strength mob) 5)) (strength mob))
                                                                                                  (progn
                                                                                                    (set-mob-effect mob :effect-type-id +mob-effect-fear+ :actor-id (id mob) :cd 4)
                                                                                                    (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                                                           (format nil "~A is feared. " (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                                                           :observed-mob mob
                                                                                                                           :color sdl:*white*
                                                                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                                         :singlemind))))
                                                                                                  (progn
                                                                                                    (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                                                           (format nil "~A resists fear. " (capitalize-name (prepend-article +article-the+ (visible-name mob))))
                                                                                                                           :observed-mob mob
                                                                                                                           :color sdl:*white*
                                                                                                                           :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                                                         :singlemind))))))
                                                                                              )))
                                                              ))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep-spores+ :name "sludgeshrooms"
                                               :glyph-idx 130 :glyph-color (sdl:color :r 155 :g 50 :b 0) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20
                                               :on-step #'(lambda (mob x y z)
                                                            (when (< (random 100) 20)
                                                              (generate-sound mob (x mob) (y mob) (z mob) 100 #'(lambda (str)
                                                                                                                  (format nil "You hear a hissing sound~A. " str)))
                                                              (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                     (format nil "Sludgeshrooms release spores under ~A. " (prepend-article +article-the+ (visible-name mob)))
                                                                                     :color sdl:*white*
                                                                                     :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                   :singlemind)))
                                                              (check-surroundings x y t #'(lambda (dx dy)
                                                                                              (when (and (>= dx 0)
                                                                                                         (>= dy 0)
                                                                                                         (< dx (array-dimension (terrain (level *world*)) 0))
                                                                                                         (< dy (array-dimension (terrain (level *world*)) 1))
                                                                                                         (and (not (get-terrain-type-trait (get-terrain-* (level *world*) dx dy z) +terrain-trait-blocks-move+))
                                                                                                              (not (get-terrain-type-trait (get-terrain-* (level *world*) dx dy z) +terrain-trait-blocks-projectiles+))))
                                                                                                (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-corrupted-spores+ :x dx :y dy :z z
                                                                                                                                                           :counter 2))
                                                                                                )
                                                                                            ))))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep-irradiated+ :name "glowing creep"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 200 :g 50 :b 100) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore x y z))
                                                            (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                   (format nil "Sinister glow irradiates ~A. " (prepend-article +article-the+ (visible-name mob)))
                                                                                   :color sdl:*white*
                                                                                   :tags (list (when (if-cur-mob-seen-through-shared-vision *player*)
                                                                                                 :singlemind)))
                                                            (if (mob-effect-p mob +mob-effect-irradiated+)
                                                              (progn
                                                                (let ((effect (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+))))
                                                                  (when (<= (param1 effect) 5)
                                                                    (incf (param1 effect) (+ 2 (random 2))))))
                                                              (progn
                                                                (set-mob-effect mob :effect-type-id +mob-effect-irradiated+ :actor-id nil :cd t :param1 (+ 2 (random 3))))))))

;;--------------------
;; Walls
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-stone+ :name "stone wall"
                                               :glyph-idx +glyph-id-wall+ :glyph-color sdl:*white* :back-color sdl:*white* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 25 :trait-blocks-sound-floor 20 :trait-blocks-move-floor t
                                               :trait-can-have-rune t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-barricade+ :name "barricade"
                                               :glyph-idx +glyph-id-hash+ :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 10  :trait-can-jump-over t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-earth+ :name "earth"
                                               :glyph-idx +glyph-id-wall+ :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color (sdl:color :r 185 :g 83 :b 43)
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 40 :trait-blocks-sound-floor 40))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-compressed-bones+ :name "compressed bones"
                                               :glyph-idx +glyph-id-wall+ :glyph-color (sdl:color :r 189 :g 183 :b 107) :back-color (sdl:color :r 189 :g 183 :b 107)
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 40 :trait-blocks-sound-floor 40))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-raw-flesh+ :name "raw flesh"
                                               :glyph-idx +glyph-id-percent+ :glyph-color sdl:*magenta* :back-color sdl:*black*
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 20 :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-bush+ :name "bush"
                                               :glyph-idx +glyph-id-hash+ :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 3 :trait-can-jump-over t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-grave+ :name "grave"
                                               :glyph-idx 121 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-can-jump-over t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-gloomtwigs+ :name "gloomtwigs"
                                               :glyph-idx +glyph-id-hash+ :glyph-color (sdl:color :r 255 :g 0 :b 255) :back-color sdl:*black* 
                                               :trait-blocks-vision 60 :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-corrupted+ :name "bone wall"
                                               :glyph-idx +glyph-id-wall+ :glyph-color (sdl:color :r 189 :g 183 :b 107) :back-color (sdl:color :r 189 :g 183 :b 107) 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 25 :trait-blocks-sound-floor 20 :trait-can-have-rune t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-razorthorns+ :name "razorthorns"
                                               :glyph-idx +glyph-id-hash+ :glyph-color (sdl:color :r 100 :g 0 :b 0) :back-color sdl:*black* 
                                               :trait-blocks-vision 60 :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore x y z))
                                                            (inflict-damage mob :min-dmg 1 :max-dmg 1 :dmg-type +weapon-dmg-acid+
                                                                                :att-spd nil :weapon-aux () :acc 100 :add-blood t :no-dodge t
                                                                                :actor nil :no-hit-message t
                                                                                :specific-hit-string-func #'(lambda (cur-dmg)
                                                                                                              (format nil "~A takes ~A damage from razorthorns. " (capitalize-name (name mob)) cur-dmg))
                                                                                :specific-no-dmg-string-func #'(lambda ()
                                                                                                                 (format nil "~A takes no damage from razorthorns. " (capitalize-name (name mob)))))
                                                            
                                                            (when (check-dead mob)
                                                              (when (eq mob *player*)
                                                                (setf (killed-by *player*) "razorthorns"))))))

;;--------------------
;; Trees
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch+ :name "young birch tree"
                                               :glyph-idx 52 :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch-snow+ :name "snow-covered birch tree"
                                               :glyph-idx 52 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-branches+ :name "tree branch"
                                               :glyph-idx 3 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-projectiles-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-leaves+ :name "tree leaves"
                                               :glyph-idx 3 :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-vision 60))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-leaves-snow+ :name "snow-covered tree leaves"
                                               :glyph-idx 3 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-vision 60))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch-trunk+ :name "mature birch"
                                               :glyph-idx 16 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 10 :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-nw+ :name "mature oak"
                                               :glyph-idx 104 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-ne+ :name "mature oak"
                                               :glyph-idx 105 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-se+ :name "mature oak"
                                               :glyph-idx 106 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-sw+ :name "mature oak"
                                               :glyph-idx 107 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-twintube+ :name "young twintube"
                                               :glyph-idx 57 :glyph-color (sdl:color :r 255 :g 0 :b 255) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound-floor 20 :trait-blocks-move-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-twintube-trunk+ :name "mature twintube"
                                               :glyph-idx 16 :glyph-color (sdl:color :r 100 :g 0 :b 100) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound 10 :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-twintube-branches+ :name "twintube branch"
                                               :glyph-idx 3 :glyph-color (sdl:color :r 100 :g 0 :b 100) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-projectiles-floor t))

;;--------------------
;; Furniture
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-chair+ :name "chair"
                                               :glyph-idx 100 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 6))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-table+ :name "table"
                                               :glyph-idx 101 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 10  :trait-can-jump-over t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bed+ :name "bed"
                                               :glyph-idx 102 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 12 :trait-can-jump-over t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-cabinet+ :name "cabinet"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20 :trait-flammable 8))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-crate+ :name "crate"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 112 :g 128 :b 144) :back-color sdl:*black*
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bookshelf+ :name "bookshelf"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 165 :g 42 :b 42) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound-floor 20 :trait-flammable 8))

;;--------------------
;; Doors & Windows
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window+ :name "window"
                                               :glyph-idx 13 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-blocks-vision 30 :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-blocks-sound 20 :trait-blocks-sound-floor 20 :trait-openable-window t
                                               :on-use #'(lambda (mob x y z)
                                                           ;; TODO: add connections change for size 3 
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-window-opened+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-walk+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-climb+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-fly+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-fly+))
                                                           )
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-open-close-window+)
                                                                               (can-invoke-ability mob mob +mob-abil-open-close-window+)
                                                                               (= (get-terrain-* (level *world*) x y z) +terrain-wall-window+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-open-close-window+)
                                                                        t)
                                                                      nil))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window-opened+ :name "opened window"
                                               :glyph-idx 15 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 10 :trait-openable-window t
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-window+)
                                                           
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-fly+
                                                                                  +connect-room-none+)
                                                           )))

(set-terrain-type (make-instance 'terrain-type :id +terrain-door-open+ :name "open door"
                                               :glyph-idx 7 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black*
                                              :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 10 :trait-openable-door t
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-door-closed+)
                                                           
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-fly+
                                                                                  +connect-room-none+)
                                                           )))

(set-terrain-type (make-instance 'terrain-type :id +terrain-door-closed+ :name "closed door"
                                               :glyph-idx 11 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-blocks-projectiles t :trait-blocks-vision t :trait-blocks-move-floor t
                                               :trait-blocks-sound 15 :trait-blocks-sound-floor 20 :trait-openable-door t
                                               :on-use #'(lambda (mob x y z)
                                                           ;; TODO: add connections change for size 3 
                                                           (set-terrain-* (level *world*) x y z +terrain-door-open+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-walk+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-climb+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-fly+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-fly+))
                                                           )
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-open-close-door+)
                                                                             (can-invoke-ability mob mob +mob-abil-open-close-door+)
                                                                             (= (get-terrain-* (level *world*) x y z) +terrain-door-closed+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-open-close-door+)
                                                                        t)
                                                                      nil))))

;;--------------------
;; Water & Ice
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-liquid+ :name "water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-not-climable t :trait-blocks-sound-floor 10 :trait-blocks-sound 10 :trait-water t :trait-move-cost-factor *water-move-factor*
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore x y z))
                                                            (set-mob-effect mob :effect-type-id +mob-effect-wet+ :actor-id (id mob) :cd 4))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-ice+ :name "ice"
                                               :glyph-idx 94 :glyph-color (sdl:color :r 0 :g 150 :b 255) :back-color sdl:*black*
                                               :trait-blocks-move-floor t :trait-blocks-projectiles-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-liquid-nofreeze+ :name "water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-blocks-sound-floor 10 :trait-blocks-sound 10 :trait-water t :trait-move-cost-factor *water-move-factor*
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore x y z))
                                                            (set-mob-effect mob :effect-type-id +mob-effect-wet+ :actor-id (id mob) :cd 4))))

;;--------------------
;; Air
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-air+ :name "air"
                                               :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* ))


;;--------------------
;; Slopes
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-up+ :name "slope up"
                                               :glyph-idx 118 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-slope-up t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-down+ :name "slope down"
                                               :glyph-idx 119 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-slope-down t))

;;--------------------
;; Light sources
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-lantern+ :name "lantern"
                                               :glyph-idx 92 :glyph-color sdl:*yellow* :back-color sdl:*black*
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-light-source 6 :trait-can-switch-light t :trait-blocks-sound 20 :trait-blocks-sound-floor 20
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-lantern-off+)
                                                           (loop for (nx ny nz light-radius) in (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10))
                                                                 for i from 0 below (length (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10)))
                                                                 when (and (= x nx) (= y ny) (= z nz))
                                                                   do
                                                                      (setf (fourth (nth i (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10))))
                                                                            (get-terrain-type-trait +terrain-wall-lantern-off+ +terrain-trait-light-source+))
                                                                      (loop-finish))
                                                           )
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-toggle-light+)
                                                                             (can-invoke-ability mob mob +mob-abil-toggle-light+)
                                                                             (= (get-terrain-* (level *world*) x y z) +terrain-wall-lantern+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-toggle-light+)
                                                                        t)
                                                                      nil))))

;; light sources that are off, but can be toggled on - should have the +terrain-trait-light-source+ set to 0, as opposed to non-light-sources, where it is set to nil
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-lantern-off+ :name "lantern (off)"
                                               :glyph-idx 92 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black*
                                               :trait-blocks-move t :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t
                                               :trait-light-source 0 :trait-can-switch-light t :trait-blocks-sound 20 :trait-blocks-sound-floor 20
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-lantern+)
                                                           (loop for (nx ny nz light-radius) in (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10))
                                                                 for i from 0 below (length (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10)))
                                                                 when (and (= x nx) (= y ny) (= z nz))
                                                                   do
                                                                      (setf (fourth (nth i (aref (light-quadrant-map (level *world*)) (truncate x 10) (truncate y 10))))
                                                                            (get-terrain-type-trait +terrain-wall-lantern+ +terrain-trait-light-source+))
                                                                      (loop-finish)))
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-toggle-light+)
                                                                             (can-invoke-ability mob mob +mob-abil-toggle-light+)
                                                                             (= (get-terrain-* (level *world*) x y z) +terrain-wall-lantern-off+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-toggle-light+)
                                                                        t)
                                                                      nil))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-creep-glowshroom+ :name "glowshroom"
                                               :glyph-idx 130 :glyph-color sdl:*yellow* :back-color sdl:*black*
                                               :trait-blocks-move nil :trait-blocks-move-floor t :trait-blocks-vision-floor t :trait-blocks-projectiles-floor t :trait-light-source 4 :trait-can-switch-light nil :trait-blocks-sound-floor 20))
