(in-package :cotd)

;;--------------------
;; MOB-TEMPLATE Declarations
;;-------------------- 

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-player+ 
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 20 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 1 3 +normal-ap+) :base-dodge 25
                                       :abil-see-all t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-human+ 
                                       :name "Human"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 0 1 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-man+ 
                                       :name "Man"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 0 1 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-woman+ 
                                       :name "Woman"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 0 1 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-child+ 
                                       :name "Child"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 5 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 0 0 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-clerk+ 
                                       :name "Clerk"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" 0 1 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-criminal+ 
                                       :name "Criminal"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Knife" 0 2 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-policeman+ 
                                       :name "Police officer"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Police baton" 0 2 +normal-ap+) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-priest+ 
                                       :name "Priest"
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Cross" 0 0 +normal-ap+) :base-dodge 20
                                       :strength 0
                                       :abil-can-be-blessed t :abil-purging-touch t :abil-detect-evil t :abil-human t
                                       ))



(set-mob-type (make-instance 'mob-type :mob-type +mob-type-angel+
                                       :name "Angel"
                                       :glyph-idx 65 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 20 :max-fp 16
                                       :faction +faction-type-angels+ :evolve-mob-id +mob-type-archangel+
                                       :weapon (list "Flaming sword" 3 6 +normal-ap+) :base-dodge 25
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t
                                       :abil-heal-self 1 :abil-conseal-divine t :abil-reveal-divine t :abil-detect-evil t
                                       :ai-wants-bless t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archangel+
                                       :name "Archangel"
                                       :glyph-idx 33 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 40 :max-fp 16
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" 5 9 +normal-ap+) :base-dodge 25
                                       :strength 4
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t
                                       :abil-heal-self 2 :abil-conseal-divine t :abil-reveal-divine t :abil-detect-evil t
                                       :ai-wants-bless t))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-imp+
                                       :name "Imp"
                                       :glyph-idx 73 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 10 :max-fp 5
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-demon+
                                       :weapon (list "Claws" 3 4 +normal-ap+) :base-dodge 35 :move-spd (truncate (* +normal-ap+ 0.8))
                                       :strength 1
                                       :abil-can-possess 1 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t
                                       :ai-horde t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-demon+
                                       :name "Demon"
                                       :glyph-idx 68 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 16 :max-fp 12
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-archdemon+
                                       :weapon (list "Claws" 4 7 +normal-ap+) :base-dodge 25
                                       :strength 3
                                       :abil-can-possess 2 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archdemon+
                                       :name "Archdemon"
                                       :glyph-idx 36 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 40 :max-fp 16
                                       :faction +faction-type-demons+
                                       :weapon (list "Chains of Shattering" 5 10 +normal-ap+) :base-dodge 20
                                       :strength 4
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t))


(set-faction-relations +faction-type-humans+ (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-demons+ nil))
(set-faction-relations +faction-type-angels+ (cons +faction-type-angels+ t) (cons +faction-type-humans+ t) (cons +faction-type-demons+ nil))
(set-faction-relations +faction-type-demons+ (cons +faction-type-demons+ t) (cons +faction-type-angels+ nil) (cons +faction-type-humans+ nil))
