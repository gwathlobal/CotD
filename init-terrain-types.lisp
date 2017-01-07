(in-package :cotd)

;;--------------------
;; TERRAIN-TEMPLATE Declarations
;;-------------------- 

(set-terrain-type (make-instance 'terrain-type :id +terrain-border-floor+ :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* :name "Grass" :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-stone+ :glyph-idx 99 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Stone floor"))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-stone+ :glyph-idx 96 :glyph-color sdl:*white* :back-color sdl:*white* :name "Stone wall" :trait-blocks-move t :trait-blocks-vision t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-tree-birch+ :glyph-idx 52 :glyph-color sdl:*green* :back-color sdl:*black* :name "Birch tree" :trait-blocks-move t :trait-blocks-vision t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-grass+ :glyph-idx 95 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :name "Grass"))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt+ :glyph-idx 95 :glyph-color (sdl:color :r 205 :g 103 :b 63) :back-color sdl:*black* :name "Dirt"))
(set-terrain-type (make-instance 'terrain-type :id +terrain-floor-dirt-bright+ :glyph-idx 95 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :name "Dirt"))
(set-terrain-type (make-instance 'terrain-type :id +terrain-water-lake+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "Lake" :trait-blocks-move t))
(set-terrain-type (make-instance 'terrain-type :id +terrain-wall-window+ :glyph-idx 13 :glyph-color (sdl:color :r 0 :g 0 :b 200) :back-color sdl:*black* :name "Window" :trait-blocks-move t))

;(set-terrain-template +terrain-stone-floor+ :glyph-idx 95 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :name "Stone floor");
;(set-terrain-template +terrain-stone-wall+ :glyph-idx 96 :glyph-color sdl:*white* :back-color sdl:*white* :name "Stone wall" :aux `((:obstacle ,t) (:blocks-vision ,t)))
;(set-terrain-template +terrain-stairs-up+ :glyph-idx 28 :glyph-color sdl:*white* :back-color sdl:*black* :name "Stairs up" :aux `((:way-up ,t)))
;(set-terrain-template +terrain-stairs-down+ :glyph-idx 30 :glyph-color sdl:*white* :back-color sdl:*black* :name "Stairs down" :aux `((:way-down ,t)))
;(set-terrain-template +terrain-stairs-up-down+ :glyph-idx 110 :glyph-color sdl:*white* :back-color sdl:*black* :name "Stairs up/down" :aux `((:way-up ,t) (:way-down ,t)))

;(set-terrain-template +terrain-border-wall+ :glyph-idx 96 :glyph-color sdl:*white* :back-color sdl:*white* :name "Stone wall" :aux `((:obstacle ,t) (:blocks-vision ,t)))
;(set-terrain-template +terrain-border-snow+ :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow" :aux `((:obstacle ,t)))
;(set-terrain-template +terrain-border-water+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "Water" :aux `((:obstacle ,t)))

;(set-terrain-template +terrain-floor-snow+ :glyph-idx 95 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow")
;(set-terrain-template +terrain-floor-water+ :glyph-idx 94 :glyph-color sdl:*blue* :back-color sdl:*black* :name "Water" :aux `((:obstacle ,t)))
;(set-terrain-template +terrain-floor-fossil-white+ :glyph-idx 5 :glyph-color sdl:*white* :back-color sdl:*black* :name "Snow-covered bones")
;(set-terrain-template +terrain-floor-fossil-grey+ :glyph-idx 5 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :name "Weather-battered remains")

;(set-terrain-template +terrain-floor-rune-covered+ :glyph-idx 99 :glyph-color sdl:*cyan* :back-color sdl:*black* :name "Rune-covered floor")
