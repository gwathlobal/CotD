(in-package :cotd)

;;--------------------
;; TERRAIN-TEMPLATE Declarations
;;-------------------- 

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor+ :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* :name "Dirt"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-stone+ :glyph-idx 99 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Stone floor"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-stone+ :glyph-idx 96 :glyph-color sdl:*white* :back-color sdl:*white* :name "Stone wall"
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t  :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch+ :glyph-idx 52 :glyph-color sdl:*green* :back-color sdl:*black* :name "Birch tree"
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t  :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-grass+ :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :name "Grass"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt+ :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* :name "Dirt"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt-bright+ :glyph-idx 95 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Dirt"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-water-lake+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "Lake"
                                               :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window+ :glyph-idx 13 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* :name "Window"
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-chair+ :glyph-idx 100 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Chair"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-table+ :glyph-idx 101 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Table"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bed+ :glyph-idx 102 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Bed"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-cabinet+ :glyph-idx 103 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Cabinet"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-crate+ :glyph-idx 103 :glyph-color (sdl:color :r 112 :g 128 :b 144) :back-color sdl:*black* :name "Crate"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bookshelf+ :glyph-idx 103 :glyph-color (sdl:color :r 165 :g 42 :b 42) :back-color sdl:*black* :name "Bookshelf"
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor-snow+ :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow+ :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow"
                                               :on-step #'(lambda (mob x y z)
                                                            (declare (ignore mob))
                                                            (set-terrain-* (level *world*) x y z +terrain-floor-snow-prints+))
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-snow-prints+ :glyph-idx 95 :glyph-color (sdl:color :r 80 :g 80 :b 155) :back-color sdl:*black* :name "Snow"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch-snow+ :glyph-idx 52 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow-covered birch tree"
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-water-ice+ :glyph-idx 94 :glyph-color (sdl:color :r 0 :g 100 :b 255) :back-color sdl:*black* :name "Ice"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-water-river+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "River" :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-bridge+ :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :name "Bridge"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-pier+ :glyph-idx 96 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :name "Pier"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-water-sea+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "Sea"
                                               :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-border-grass+ :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :name "Grass"
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-barricade+ :glyph-idx 3 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Barricade"
                                               :trait-blocks-move t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-door-open+ :glyph-idx 7 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Open door"
                                               :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-door-closed+ :glyph-idx 11 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Closed door"
                                               :trait-blocks-move t :trait-blocks-projectiles t :trait-blocks-vision t :trait-opaque-floor t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-border-air+ :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* :name "Air" :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-air+ :glyph-idx 96 :glyph-color sdl:*cyan* :back-color sdl:*black* :name "Air" :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-up+ :glyph-idx 118 :glyph-color sdl:*white* :back-color sdl:*black* :name "Slope up"
                                               :trait-opaque-floor t :trait-slope-up t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-slope-stone-down+ :glyph-idx 119 :glyph-color sdl:*white* :back-color sdl:*black* :name "Slope down"
                                               :trait-slope-down t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-earth+ :glyph-idx 96 :glyph-color (sdl:color :r 185 :g 83 :b 43) :back-color (sdl:color :r 185 :g 83 :b 43) :name "Earth"
                                               :trait-blocks-move t :trait-blocks-vision t :trait-blocks-projectiles t :trait-opaque-floor t))
