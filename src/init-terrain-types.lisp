(in-package :cotd)

;;--------------------
;; TERRAIN-TEMPLATE Declarations
;;-------------------- 

;;--------------------
;; Borders
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor+ :name "Dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound t :trait-blocks-sound-floor t :trait-not-climable t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor-snow+ :name "Snow"
                                               :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-water+ :name "Water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-sound 10 :trait-blocks-sound-floor 10 :trait-not-climable t :trait-water t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-grass+ :name "Grass"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-opaque-floor t :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-air+ :name "Air"
                                               :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-not-climable t :trait-blocks-sound t :trait-blocks-sound-floor t))


;;--------------------
;; Floors
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-stone+ :name "Stone floor"
                                               :glyph-idx 99 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-grass+ :name "Grass"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt+ :name "Dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt-bright+ :name "Dirt"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow+ :name "Snow"
                                               :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore mob))
                                                            (set-terrain-* (level *world*) x y z +terrain-floor-snow-prints+))
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow-prints+ :name "Snow"
                                               :glyph-idx 95 :glyph-color (sdl:color :r 80 :g 80 :b 155) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bridge+ :name "Bridge"
                                               :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-pier+ :name "Pier"
                                               :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black*
                                               :trait-opaque-floor t :trait-blocks-sound-floor 10))

;;--------------------
;; Walls
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-stone+ :name "Stone wall"
                                               :glyph-idx 96 :glyph-color sdl:*white* :back-color sdl:*white* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-sound 25 :trait-blocks-sound-floor 20 :trait-opaque-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-barricade+ :name "Barricade"
                                               :glyph-idx 3 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-earth+ :name "Earth"
                                               :glyph-idx 96 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color (sdl:color :r 185 :g 83 :b 43)
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t :trait-blocks-sound 40 :trait-blocks-sound-floor 40))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-bush+ :name "Bush"
                                               :glyph-idx 3 :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 20))

;;--------------------
;; Trees
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch+ :name "Young birch tree"
                                               :glyph-idx 52 :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-blocks-sound-floor 20 :trait-opaque-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch-snow+ :name "Snow-covered birch tree"
                                               :glyph-idx 52 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-branches+ :name "Tree branch"
                                               :glyph-idx 3 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-opaque-floor t))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-leaves+ :name "Tree leaves"
                                               :glyph-idx 3 :glyph-color sdl:*green* :back-color sdl:*black* 
                                               :trait-blocks-vision 60))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-leaves-snow+ :name "Snow-covered tree leaves"
                                               :glyph-idx 3 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-blocks-vision 60))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch-trunk+ :name "Mature birch"
                                               :glyph-idx 16 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-move t :trait-blocks-vision t :trait-blocks-sound 10 :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-nw+ :name "Mature oak"
                                               :glyph-idx 104 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-vision t :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-ne+ :name "Mature oak"
                                               :glyph-idx 105 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-vision t :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-se+ :name "Mature oak"
                                               :glyph-idx 106 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-vision t :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-oak-trunk-sw+ :name "Mature oak"
                                               :glyph-idx 107 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-vision t :trait-blocks-sound 15 :trait-blocks-sound-floor 15))

;;--------------------
;; Furniture
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-chair+ :name "Chair"
                                               :glyph-idx 100 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-table+ :name "Table"
                                               :glyph-idx 101 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bed+ :name "Bed"
                                               :glyph-idx 102 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-cabinet+ :name "Cabinet"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-crate+ :name "Crate"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 112 :g 128 :b 144) :back-color sdl:*black*
                                               :trait-blocks-move t :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bookshelf+ :name "Bookshelf"
                                               :glyph-idx 103 :glyph-color (sdl:color :r 165 :g 42 :b 42) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t :trait-blocks-sound-floor 20))

;;--------------------
;; Doors & Windows
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window+ :name "Window"
                                               :glyph-idx 13 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-blocks-sound 20 :trait-blocks-sound-floor 20 :trait-blocks-vision 30 :trait-opaque-floor t :trait-openable-window t
                                               :on-use #'(lambda (mob x y z)
                                                           ;; TODO: add connections change for size 3 
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-window-opened+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-walk+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-climb+))
                                                           )
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-open-close-window+)
                                                                               (can-invoke-ability mob mob +mob-abil-open-close-window+)
                                                                               (= (get-terrain-* (level *world*) x y z) +terrain-wall-window+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-open-close-window+)
                                                                        t)
                                                                      nil))))

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window-opened+ :name "Opened window"
                                               :glyph-idx 15 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-blocks-sound-floor 10 :trait-openable-window t
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-window+)
                                                           
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  +connect-room-none+)
                                                           )))

(set-terrain-type (make-instance 'terrain-type :id +terrain-door-open+ :name "Open door"
                                               :glyph-idx 7 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black*
                                               :trait-opaque-floor t :trait-blocks-sound-floor 10 :trait-openable-door t
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-door-closed+)
                                                           
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  +connect-room-none+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  +connect-room-none+)
                                                           )))

(set-terrain-type (make-instance 'terrain-type :id +terrain-door-closed+ :name "Closed door"
                                               :glyph-idx 11 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* 
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-blocks-vision t :trait-opaque-floor t :trait-blocks-sound 15 :trait-blocks-sound-floor 20 :trait-openable-door t
                                               :on-use #'(lambda (mob x y z)
                                                           ;; TODO: add connections change for size 3 
                                                           (set-terrain-* (level *world*) x y z +terrain-door-open+)
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-walk+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-walk+))
                                                           (set-connect-map-value (aref (connect-map (level *world*)) 1) x y z +connect-map-move-climb+
                                                                                  (get-connect-map-value (aref (connect-map (level *world*)) 1) (x mob) (y mob) (z mob) +connect-map-move-climb+))
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

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-liquid+ :name "Water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-not-climable t :trait-blocks-sound-floor 10 :trait-blocks-sound 10 :trait-water t :trait-move-cost-factor *water-move-factor*))

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-ice+ :name "Ice"
                                               :glyph-idx 94 :glyph-color (sdl:color :r 0 :g 100 :b 255) :back-color sdl:*black*
                                               :trait-opaque-floor t :trait-blocks-sound-floor 20))

(set-terrain-type (make-instance 'terrain-type :id +terrain-water-liquid-nofreeze+ :name "Water"
                                               :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* 
                                               :trait-blocks-sound-floor 10 :trait-blocks-sound 10 :trait-water t :trait-move-cost-factor *water-move-factor*))

;;--------------------
;; Air
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-air+ :name "Air"
                                               :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* ))


;;--------------------
;; Slopes
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-up+ :name "Slope up"
                                               :glyph-idx 118 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-opaque-floor t :trait-slope-up t :trait-blocks-sound-floor 10))

(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-down+ :name "Slope down"
                                               :glyph-idx 119 :glyph-color sdl:*white* :back-color sdl:*black* 
                                               :trait-slope-down t))

;;--------------------
;; Light sources
;;--------------------

(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-lantern+ :name "Lantern"
                                               :glyph-idx 92 :glyph-color sdl:*yellow* :back-color sdl:*black*
                                               :trait-blocks-move t :trait-opaque-floor t :trait-light-source 6 :trait-blocks-sound 20 :trait-blocks-sound-floor 20
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-lantern-off+)
                                                           (loop for (nx ny nz light-radius) across (light-sources (level *world*))
                                                                 for i from 0 below (length (light-sources (level *world*)))
                                                                 when (and (= x nx) (= y ny) (= z nz))
                                                                   do
                                                                      (setf (fourth (aref (light-sources (level *world*)) i)) (get-terrain-type-trait +terrain-wall-lantern-off+ +terrain-trait-light-source+))
                                                                      (loop-finish)))
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-toggle-light+)
                                                                             (can-invoke-ability mob mob +mob-abil-toggle-light+)
                                                                             (= (get-terrain-* (level *world*) x y z) +terrain-wall-lantern+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-toggle-light+)
                                                                        t)
                                                                      nil))))

;; light sources that are off, but can be toggled on - should have the +terrain-trait-light-source+ set to 0, as opposed to non-light-sources, where it is set to nil
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-lantern-off+ :name "Lantern (off)"
                                               :glyph-idx 92 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black*
                                               :trait-blocks-move t :trait-opaque-floor t :trait-light-source 0 :trait-blocks-sound 20 :trait-blocks-sound-floor 20
                                               :on-use #'(lambda (mob x y z)
                                                           (declare (ignore mob))
                                                           (set-terrain-* (level *world*) x y z +terrain-wall-lantern+)
                                                           (loop for (nx ny nz light-radius) across (light-sources (level *world*))
                                                                 for i from 0 below (length (light-sources (level *world*)))
                                                                 when (and (= x nx) (= y ny) (= z nz))
                                                                   do
                                                                      (setf (fourth (aref (light-sources (level *world*)) i)) (get-terrain-type-trait +terrain-wall-lantern+ +terrain-trait-light-source+))
                                                                      (loop-finish)))
                                               :on-bump-terrain #'(lambda (mob x y z)
                                                                    (if (and (mob-ability-p mob +mob-abil-toggle-light+)
                                                                             (can-invoke-ability mob mob +mob-abil-toggle-light+)
                                                                             (= (get-terrain-* (level *world*) x y z) +terrain-wall-lantern-off+))
                                                                      (progn
                                                                        (mob-invoke-ability mob (list x y z) +mob-abil-toggle-light+)
                                                                        t)
                                                                      nil))))
