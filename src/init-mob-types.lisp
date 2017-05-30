(in-package :cotd)

;;--------------------
;; MOB-TEMPLATE Declarations
;;-------------------- 

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-player+ 
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 20 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 1 3 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :abil-see-all t :abil-open-close-door t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-human+ 
                                       :name "Human"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-man+ 
                                       :name "Man"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-woman+ 
                                       :name "Woman"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-child+ 
                                       :name "Child"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 5 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 0 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 3
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-clerk+ 
                                       :name "Clerk"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-criminal+ 
                                       :name "Criminal"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-criminals+
                                       :weapon (list "Knife" (list +weapon-dmg-iron+ 0 2 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-policeman+ 
                                       :name "Police officer"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Police baton" (list +weapon-dmg-iron+ 0 2 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-priest+ 
                                       :name "Priest"
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Cross" (list +weapon-dmg-iron+ 0 0 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-can-be-blessed t :abil-detect-evil t :abil-human t
                                       :abil-toggle-light t  :abil-prayer-bless t :abil-prayer-shield t :abil-open-close-door t
                                       :ai-stop t
                             ))
(set-mob-type (make-instance 'mob-type :mob-type +mob-type-satanist+ 
                                       :name "Satanist"
                                       :glyph-idx 32 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-hp 7 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Burning touch" (list +weapon-dmg-fire+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :armor (list (list +weapon-dmg-vorpal+ 3 0))
                                       :strength 1
                                       :base-light-radius 4
                                       :abil-detect-good t :abil-human t :abil-unholy t
                                       :abil-free-call t :abil-curse t :abil-toggle-light t :abil-open-close-door t :abil-reanimate-corpse t
                             ))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-thief+ 
                                       :name "Thief"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-criminals+
                                       :weapon (list "Knife" (list +weapon-dmg-iron+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 30
                                       :strength 1
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-human t :abil-death-from-above t :abil-climbing t :abil-possessable t :abil-can-be-blessed t :abil-toggle-light t :abil-open-close-door t :abil-open-close-window t :abil-smoke-bomb t
                                       :ai-kleptomaniac t :ai-cautious t
                             ))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-soldier+ 
                                       :name "Soldier"
                                       :glyph-idx 32 :glyph-color sdl:*green* :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Rifle" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 4 +normal-ap+ 1 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-sergeant+ 
                                       :name "Sergeant"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-chaplain+ 
                                       :name "Chaplain"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 85 :g 107 :b 47) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-can-be-blessed t :abil-human t :abil-keen-senses t :abil-prayer-reveal t :abil-prayer-shield t :abil-military-follow-me t
                                       :abil-detect-good t :abil-detect-evil t :abil-horseback-riding t :abil-dismount t :abil-independent t :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-gunner+ 
                                       :name "Machine-gunner"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 50 :g 150 :b 50) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Light machine gun" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 6 70 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t
                                       :abil-toggle-light t :abil-open-close-door t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-scout+ 
                                       :name "Scout"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 60 :g 179 :b 113) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Rifle" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 4 6 +normal-ap+ 1 1 120 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-starts-with-horse t
                                       :abil-independent t :abil-detect-good t :abil-detect-evil t :abil-eagle-eye t :abil-open-close-door t
                             ))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-angel+
                                       :name "Chrome Angel"
                                       :glyph-idx 65 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 18 :max-fp 32
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 6 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 1 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-heal-self 1 :abil-conseal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-avatar-of-brilliance t
                                       :ai-wants-bless t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archangel+
                                       :name "Avatar of Brilliance"
                                       :glyph-idx 33 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 36 :max-fp 32
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 6 9 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 4
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-heal-self 2 :abil-detect-evil t :abil-blindness t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t
                                       :abil-toggle-light t :abil-open-close-door t :abil-ignite-the-fire t
                                       :ai-wants-bless t :ai-curious t))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-imp+
                                       :name "Imp"
                                       :glyph-idx 73 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 12 :max-fp 5
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-demon+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 3 5 +normal-ap+ 100 ()) nil) :base-dodge 35 :move-spd (truncate (* +normal-ap+ 0.8))
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-can-possess 1 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t :abil-can-possess-toggle t :abil-sacrifice-host t
                                       :ai-horde t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-demon+
                                       :name "Demon"
                                       :glyph-idx 68 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 18 :max-fp 12
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-archdemon+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 4 7 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 3
                                       :base-light-radius 0
                                       :abil-can-possess 2 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 3 :abil-no-breathe t :abil-toggle-light t
                                       :abil-dominate-fiend t :abil-dismount t :abil-open-close-door t :abil-can-possess-toggle t :abil-sacrifice-host t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archdemon+
                                       :name "Archdemon"
                                       :glyph-idx 36 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 40 :max-fp 16
                                       :faction +faction-type-demons+
                                       :weapon (list "Chains of Shattering" (list +weapon-dmg-vorpal+ 5 10 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 5
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 4 :abil-charge t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-1+
                                       :name "Reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 1 3 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-2+
                                       :name "Reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 7 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-3+
                                       :name "Reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 2 4 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-4+
                                       :name "Reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 9 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 3 4 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                                       ))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-horse+ 
                                       :name "Horse"
                                       :glyph-idx 72 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :max-hp 12 :max-fp 0
                                       :faction +faction-type-animals+
                                       :weapon (list "Hooves" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 0
                                       :abil-animal t :abil-momentum 2 :abil-horse-can-be-ridden t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-fiend+ 
                                       :name "Fiend"
                                       :glyph-idx 70 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 12 :max-fp 0
                                       :faction +faction-type-outsider-beasts+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 3 4 +normal-ap+ 100 ()) nil) :base-dodge 35
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 2
                                       :base-light-radius 0
                                       :abil-animal t :abil-demon t :abil-unholy t :abil-detect-good t :abil-lifesteal t :abil-momentum 2 :abil-fiend-can-be-ridden t :abil-loves-infighting t :abil-no-breathe t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-gargantaur+ 
                                       :name "Gargantaur"
                                       :glyph-idx 39 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 25 :max-fp 2
                                       :faction +faction-type-outsider-beasts+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 6 10 +normal-ap+ 100 ()) nil) :base-dodge 0
                                       :armor (list (list +weapon-dmg-flesh+ 4 0) (list +weapon-dmg-iron+ 2 0) (list +weapon-dmg-vorpal+ 4 0) (list +weapon-dmg-fire+ 4 0))
                                       :strength 8 :base-sight 7
                                       :map-size 3
                                       :abil-animal t :abil-angel t :abil-facing t :abil-immovable t :abil-loves-infighting t :abil-mind-burn t :abil-heal-self 1 :abil-gargantaur-teleport t :abil-detect-evil t :abil-no-breathe t
                                       :ai-curious t))


(set-faction-relations +faction-type-humans+
                       (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t) (cons +faction-type-military+ t)
                       (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil))
(set-faction-relations +faction-type-angels+
                       (cons +faction-type-angels+ t) (cons +faction-type-humans+ t) (cons +faction-type-animals+ t) (cons +faction-type-criminals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil))
(set-faction-relations +faction-type-demons+
                       (cons +faction-type-demons+ t)
                       (cons +faction-type-angels+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-beasts+ nil)
                       (cons +faction-type-criminals+ nil))
(set-faction-relations +faction-type-military+
                       (cons +faction-type-military+ t) (cons +faction-type-humans+ t) (cons +faction-type-animals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil))
(set-faction-relations +faction-type-animals+
                       (cons +faction-type-animals+ t) (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-military+ t) (cons +faction-type-criminals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil))
(set-faction-relations +faction-type-outsider-beasts+
                       (cons +faction-type-outsider-beasts+ nil)
                       (cons +faction-type-animals+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil))
(set-faction-relations +faction-type-criminals+
                       (cons +faction-type-criminals+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t)
                       (cons +faction-type-humans+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil))
