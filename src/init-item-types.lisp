(in-package :cotd)

(set-item-type (make-instance 'item-type :id +item-type-body-part+
                                         :name "Body part"
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black*))

(set-item-type (make-instance 'item-type :id +item-type-coin+
                                         :name "Coin"
                                         :glyph-idx 4 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 5))
