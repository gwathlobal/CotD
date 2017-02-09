(in-package :cotd)

;;--------------------
;; MOB-TEMPLATE Declarations
;;-------------------- 

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-player+ 
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 20 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 1 3 +normal-ap+) nil) :base-dodge 25
                                       :abil-see-all t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-human+ 
                                       :name "Human"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 0 1 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-man+ 
                                       :name "Man"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 0 1 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-woman+ 
                                       :name "Woman"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 0 1 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-child+ 
                                       :name "Child"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 5 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 0 0 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-clerk+ 
                                       :name "Clerk"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list 0 1 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-criminal+ 
                                       :name "Criminal"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Knife" (list 0 2 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-policeman+ 
                                       :name "Police officer"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Police baton" (list 0 2 +normal-ap+) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-priest+ 
                                       :name "Priest"
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Cross" (list 0 0 +normal-ap+) nil) :base-dodge 20
                                       :strength 0
                                       :abil-can-be-blessed t :abil-detect-evil t :abil-prayer-bless t :abil-prayer-shield t :abil-human t
                                       :ai-stop t
                             ))
(set-mob-type (make-instance 'mob-type :mob-type +mob-type-satanist+ 
                                       :name "Satanist"
                                       :glyph-idx 32 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-hp 7 :max-fp 5
                                       :faction +faction-type-demons+
                                       :weapon (list "Burning touch" (list 2 3 +normal-ap+) nil) :base-dodge 20
                                       :strength 1
                                       :abil-detect-good t :abil-human t :abil-unholy t :abil-call-for-help t :abil-free-call t :abil-curse t
                             ))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-soldier+ 
                                       :name "Soldier"
                                       :glyph-idx 32 :glyph-color sdl:*green* :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Rifle" (list 1 2 +normal-ap+) (list 2 4 +normal-ap+ 1 1)) :base-dodge 25
                                       :strength 1
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-sergeant+ 
                                       :name "Sergeant"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list 1 2 +normal-ap+) (list 1 2 +normal-ap+ 6 1)) :base-dodge 25
                                       :strength 1
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-chaplain+ 
                                       :name "Chaplain"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 85 :g 107 :b 47) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list 1 2 +normal-ap+) (list 1 2 +normal-ap+ 6 1)) :base-dodge 25
                                       :strength 1
                                       :abil-can-be-blessed t :abil-human t :abil-keen-senses t :abil-prayer-reveal t :abil-prayer-shield t :abil-military-follow-me t
                                       :abil-detect-good t :abil-detect-evil t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-gunner+ 
                                       :name "Machine-gunner"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 50 :g 150 :b 50) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Light machine gun" (list 1 2 +normal-ap+) (list 1 2 +normal-ap+ 6 6)) :base-dodge 25
                                       :strength 1
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-angel+
                                       :name "Angel"
                                       :glyph-idx 65 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 16 :max-fp 16
                                       :faction +faction-type-angels+ :evolve-mob-id +mob-type-archangel+
                                       :weapon (list "Flaming sword" (list 3 6 +normal-ap+) nil) :base-dodge 25
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t
                                       :abil-heal-self 1 :abil-conseal-divine t :abil-reveal-divine t :abil-detect-evil t
                                       :ai-wants-bless t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archangel+
                                       :name "Archangel"
                                       :glyph-idx 33 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 35 :max-fp 16
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list 5 9 +normal-ap+) nil) :base-dodge 25
                                       :strength 4
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t
                                       :abil-heal-self 2 :abil-conseal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-blindness t
                                       :ai-wants-bless t))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-imp+
                                       :name "Imp"
                                       :glyph-idx 73 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 10 :max-fp 5
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-demon+
                                       :weapon (list "Claws" (list 3 4 +normal-ap+) nil) :base-dodge 35 :move-spd (truncate (* +normal-ap+ 0.8))
                                       :strength 1
                                       :abil-can-possess 1 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t
                                       :ai-horde t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-demon+
                                       :name "Demon"
                                       :glyph-idx 68 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 16 :max-fp 12
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-archdemon+
                                       :weapon (list "Claws" (list 4 7 +normal-ap+) nil) :base-dodge 25
                                       :strength 3
                                       :abil-can-possess 2 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 3))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archdemon+
                                       :name "Archdemon"
                                       :glyph-idx 36 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 40 :max-fp 16
                                       :faction +faction-type-demons+
                                       :weapon (list "Chains of Shattering" (list 5 10 +normal-ap+) nil) :base-dodge 20 :base-armor 1
                                       :strength 4
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 4 :abil-charge t))


(set-faction-relations +faction-type-humans+ (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-demons+ nil) (cons +faction-type-military+ t))
(set-faction-relations +faction-type-angels+ (cons +faction-type-angels+ t) (cons +faction-type-humans+ t) (cons +faction-type-demons+ nil) (cons +faction-type-military+ nil))
(set-faction-relations +faction-type-demons+ (cons +faction-type-demons+ t) (cons +faction-type-angels+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-military+ nil))
(set-faction-relations +faction-type-military+ (cons +faction-type-military+ t) (cons +faction-type-demons+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-humans+ t))
