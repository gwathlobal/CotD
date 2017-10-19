(in-package :cotd)

;;--------------------
;; MOB-TEMPLATE Declarations
;;-------------------- 

;;--------------------
;; CITIZENS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-player+ 
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 20 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 1 3 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :abil-see-all t :abil-open-close-door t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-human+ 
                                       :name "human"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-man+ 
                                       :name "man"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-coin+ #'(lambda () (+ 5 (random 10)))) (list +item-type-clothing+ #'(lambda () (random 2))))
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-woman+ 
                                       :name "woman"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-coin+ #'(lambda () (+ 5 (random 10)))) (list +item-type-clothing+ #'(lambda () (random 2))))
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-child+ 
                                       :name "child"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 5 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 0 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 3
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-clerk+ 
                                       :name "clerk"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Fists" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-coin+ #'(lambda () (+ 10 (random 10)))) (list +item-type-clothing+ #'(lambda () (random 2))))
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-criminal+ 
                                       :name "criminal"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-criminals+
                                       :weapon (list "Knife" (list +weapon-dmg-iron+ 0 2 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-clothing+ #'(lambda () (random 2))))
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-policeman+ 
                                       :name "police officer"
                                       :glyph-idx 32 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Police baton" (list +weapon-dmg-iron+ 0 2 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 4
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-coin+ #'(lambda () (+ 5 (random 10)))) (list +item-type-clothing+ #'(lambda () (random 2))))
                             ))

;;--------------------
;; CHURCH
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-priest+ 
                                       :name "priest"
                                       :glyph-idx 32 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-humans+
                                       :weapon (list "Cross" (list +weapon-dmg-iron+ 0 0 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :strength 1
                                       :base-light-radius 6
                                       :abil-can-be-blessed t :abil-detect-evil t :abil-human t :abil-independent t
                                       :abil-toggle-light t  :abil-prayer-bless t :abil-open-close-door t :abil-smite t :abil-slow t :abil-prayer-wrath t
                                       :ai-stop t
                             ))

;;--------------------
;; SATANISTS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-satanist+ 
                                       :name "satanist"
                                       :glyph-idx 32 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-hp 7 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Burning touch" (list +weapon-dmg-fire+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :armor (list (list +weapon-dmg-vorpal+ 3 0))
                                       :strength 1
                                       :base-light-radius 4
                                       :abil-detect-good t :abil-human t :abil-unholy t
                                       :abil-free-call t :abil-curse t :abil-toggle-light t :abil-open-close-door t :abil-reanimate-corpse t :abil-empower-undead t
                             ))

;;--------------------
;; CRIMINALS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-thief+ 
                                       :name "thief"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-criminals+
                                       :weapon (list "Knife" (list +weapon-dmg-iron+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 30
                                       :strength 1
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-human t :abil-death-from-above t :abil-climbing t :abil-possessable t :abil-can-be-blessed t :abil-independent t
                                       :abil-toggle-light t :abil-open-close-door t :abil-open-close-window t :abil-sprint t :abil-jump t :abil-make-disguise t :abil-remove-disguise t
                                       :ai-kleptomaniac t :ai-cautious t
                                       :init-items (list (list +item-type-smoke-bomb+ #'(lambda () 3)))
                             ))

;;--------------------
;; MILITARY
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-soldier+ 
                                       :name "soldier"
                                       :glyph-idx 32 :glyph-color sdl:*green* :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Rifle" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 4 +normal-ap+ 1 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-medkit+ #'(lambda () 3)))
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-sergeant+ 
                                       :name "sergeant"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 0 :g 100 :b 0) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t
                                       :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-medkit+ #'(lambda () 3)))
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-chaplain+ 
                                       :name "chaplain"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 85 :g 107 :b 47) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Revolver" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 1 100 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-can-be-blessed t :abil-human t :abil-keen-senses t :abil-prayer-reveal t :abil-prayer-shield t :abil-military-follow-me t
                                       :abil-detect-good t :abil-detect-evil t :abil-horseback-riding t :abil-dismount t :abil-independent t :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-medkit+ #'(lambda () 3)))
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-gunner+ 
                                       :name "machine-gunner"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 50 :g 150 :b 50) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Light machine gun" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 2 3 +normal-ap+ 6 6 70 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t
                                       :abil-toggle-light t :abil-open-close-door t
                                       :init-items (list (list +item-type-medkit+ #'(lambda () 3)))
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-scout+ 
                                       :name "scout"
                                       :glyph-idx 32 :glyph-color (sdl:color :r 60 :g 179 :b 113) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-military+
                                       :weapon (list "Rifle" (list +weapon-dmg-iron+ 1 2 +normal-ap+ 100 ()) (list +weapon-dmg-iron+ 4 6 +normal-ap+ 1 1 120 ())) :base-dodge 25
                                       :strength 1
                                       :ai-curious t
                                       :abil-possessable t :abil-can-be-blessed t :abil-human t :abil-keen-senses t :abil-horseback-riding t :abil-dismount t :abil-starts-with-horse t
                                       :abil-independent t :abil-detect-good t :abil-detect-evil t :abil-eagle-eye t :abil-open-close-door t
                                       :init-items (list (list +item-type-medkit+ #'(lambda () 3)))
                             ))

;;--------------------
;; ANGELS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-angel+
                                       :name "chrome angel"
                                       :glyph-idx 65 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 18 :max-fp 32
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 6 +normal-ap+ 100 (list :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 1 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-heal-self 1 :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-avatar-of-brilliance t :abil-split-soul t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archangel+
                                       :name "Avatar of Brilliance"
                                       :glyph-idx 33 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 36 :max-fp 32
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 6 9 +normal-ap+ 100 (list :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 4
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-heal-self 2 :abil-detect-evil t :abil-blindness t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t
                                       :abil-toggle-light t :abil-open-close-door t :abil-ignite-the-fire t :abil-split-soul t :abil-resurrection t :abil-remove-disguise t
                                       :ai-wants-bless t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-singer+
                                       :name "star singer"
                                       :glyph-idx 65 :glyph-color (sdl:color :r 0 :g 128 :b 128) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 1 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-righteous-fury t :abil-pain-link t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-gazer+
                                       :name "star gazer"
                                       :glyph-idx 65 :glyph-color (sdl:color :r 32 :g 170 :b 170) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-silence t :abil-confuse t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-mender+
                                       :name "star mender"
                                       :glyph-idx 65 :glyph-color (sdl:color :r 127 :g 255 :b 200) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-heal-other 1 :abil-soul-reinforcement t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-singer-mender+
                                       :name "amalgamated angel"
                                       :glyph-idx 33 :glyph-color (sdl:color :r 127 :g 255 :b 200) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-heal-other 1 :abil-righteous-fury t :abil-pain-link t 
                                       :abil-soul-reinforcement t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-singer-gazer+
                                       :name "amalgamated angel"
                                       :glyph-idx 33 :glyph-color (sdl:color :r 127 :g 255 :b 200) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-righteous-fury t :abil-pain-link t :abil-silence t :abil-confuse t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-gazer-mender+
                                       :name "amalgamated angel"
                                       :glyph-idx 33 :glyph-color (sdl:color :r 127 :g 255 :b 200) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-heal-other 1 :abil-soul-reinforcement t :abil-silence t :abil-confuse t
                                       :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t :ai-trinity-mimic t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-star-singer-gazer-mender+
                                       :name "amalgamated angel"
                                       :glyph-idx 33 :glyph-color (sdl:color :r 0 :g 128 :b 128) :back-color sdl:*black* :max-hp 14 :max-fp 12
                                       :faction +faction-type-angels+
                                       :weapon (list "Flaming sword" (list +weapon-dmg-fire+ 3 5 +normal-ap+ 100 (list :chops-body-parts :is-fire)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 0 0) (list +weapon-dmg-fire+ 3 50))
                                       :strength 2
                                       :abil-purging-touch t :abil-blessing-touch t :abil-angel t :abil-no-breathe t :abil-shared-minds t
                                       :abil-conceal-divine t :abil-reveal-divine t :abil-detect-evil t :abil-dismount t :abil-dominate-gargantaur t :abil-gargantaurs-mind-burn t :abil-toggle-light t
                                       :abil-open-close-door t :abil-ignite-the-fire t :abil-trinity-mimic t :abil-merge t :abil-unmerge t :abil-heal-other 1 :abil-righteous-fury t :abil-pain-link t
                                       :abil-soul-reinforcement t :abil-silence t :abil-confuse t :abil-resurrection t
                                       :ai-wants-bless t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-angel-image+
                                       :name "stellar image"
                                       :glyph-idx 65 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 1 :max-fp 0
                                       :faction +faction-type-angels+
                                       :weapon (list "Illusory fire" nil nil) :base-dodge 35
                                       :armor (list (list +weapon-dmg-flesh+ 0 100) (list +weapon-dmg-fire+ 0 100))
                                       :strength 0
                                       :abil-angel t :abil-no-breathe t :abil-restore-soul t
                                       :ai-split-soul t))

;;--------------------
;; DEMONS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-imp+
                                       :name "crimson imp"
                                       :glyph-idx 73 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 12 :max-fp 5
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-demon+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 3 5 +normal-ap+ 100 ()) nil) :base-dodge 35 :move-spd (truncate (* +normal-ap+ 0.8))
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-can-possess 1 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t :abil-can-possess-toggle t :abil-sacrifice-host t :abil-bend-space t
                                       :ai-horde t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-demon+
                                       :name "crimson demon"
                                       :glyph-idx 68 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 20 :max-fp 12
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-archdemon+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 4 7 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 3
                                       :base-light-radius 0
                                       :abil-can-possess 2 :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 3 :abil-no-breathe t :abil-toggle-light t
                                       :abil-dominate-fiend t :abil-dismount t :abil-open-close-door t :abil-can-possess-toggle t :abil-sacrifice-host t :abil-bend-space t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-archdemon+
                                       :name "archdemon"
                                       :glyph-idx 36 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 40 :max-fp 16
                                       :faction +faction-type-demons+
                                       :weapon (list "Chains of Shattering" (list +weapon-dmg-vorpal+ 5 10 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 5
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-instill-fear 4 :abil-charge t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t :abil-gravity-chains t :abil-bend-space t
                                       :ai-curious t))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-shadow-imp+
                                       :name "shadow imp"
                                       :glyph-idx 73 :glyph-color (sdl:color :r 100 :g 100 :b 100) :back-color sdl:*black* :max-hp 14 :max-fp 5
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-shadow-demon+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 3 5 +normal-ap+ 100 ()) nil) :base-dodge 35 :move-spd (truncate (* +normal-ap+ 0.9))
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t :abil-shadow-step t :abil-cast-shadow t
                                       :ai-horde t :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-shadow-demon+
                                       :name "shadow demon"
                                       :glyph-idx 68 :glyph-color (sdl:color :r 100 :g 100 :b 100) :back-color sdl:*black* :max-hp 22 :max-fp 12
                                       :faction +faction-type-demons+ :evolve-mob-id +mob-type-shadow-devil+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 4 7 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 3
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-no-breathe t :abil-toggle-light t
                                       :abil-dominate-fiend t :abil-dismount t :abil-open-close-door t :abil-shadow-step t :abil-extinguish-light t :abil-cast-shadow t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-shadow-devil+
                                       :name "shadow devil"
                                       :glyph-idx 36 :glyph-color (sdl:color :r 100 :g 100 :b 100) :back-color sdl:*black* :max-hp 32 :max-fp 16
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 5 8 +normal-ap+ 100 ()) nil) :base-dodge 20
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 5 
                                       :base-light-radius -4 :base-stealth 10
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-charge t :abil-no-breathe t
                                       :abil-dominate-fiend t :abil-dismount t :abil-toggle-light t :abil-open-close-door t :abil-shadow-step t :abil-extinguish-light t :abil-umbral-aura t :abil-cast-shadow t
                                       :ai-curious t))


(set-mob-type (make-instance 'mob-type :mob-type +mob-type-malseraph-puppet+
                                       :name "Malseraph's puppet"
                                       :glyph-idx 68 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-hp 22 :max-fp 12
                                       :faction +faction-type-demons+
                                       :weapon (list "Falchion" (list +weapon-dmg-vorpal+ 4 7 +normal-ap+ 100 (list :chops-body-parts)) nil) :base-dodge 25
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 3
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-loves-infighting t :abil-no-breathe t
                                       :abil-detect-good t :abil-lifesteal t :abil-call-for-help t :abil-answer-the-call t :abil-toggle-light t
                                       :abil-dominate-fiend t :abil-dismount t :abil-open-close-door t :abil-remove-disguise t :abil-irradiate t :abil-fission t
                                       :ai-curious t))

;;--------------------
;; UNDEAD
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-1+
                                       :name "reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 6 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 1 3 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-2+
                                       :name "reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 7 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-3+
                                       :name "reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 8 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 2 4 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-pwr-4+
                                       :name "reanimated body"
                                       :glyph-idx 90 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 9 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 3 4 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.2))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 1
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                             ))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-reanimated-empowered+
                                       :name "empowered corpse"
                                       :glyph-idx 58 :glyph-color (sdl:color :r 150 :g 150 :b 150) :back-color sdl:*black* :max-hp 15 :max-fp 0
                                       :faction +faction-type-demons+
                                       :weapon (list "Claws & fangs" (list +weapon-dmg-flesh+ 4 6 +normal-ap+ 100 ()) nil) :base-dodge 0 :move-spd (truncate (* +normal-ap+ 1.1))
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 2
                                       :base-light-radius 0
                                       :abil-unholy t :abil-demon t :abil-detect-good t :abil-no-breathe t :abil-answer-the-call t :abil-undead t
                                       ))

;;--------------------
;; EATER OF THE DEAD
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-eater-of-the-dead+
                                       :name "eater of the dead"
                                       :glyph-idx 69 :glyph-color (sdl:color :r 255 :g 165 :b 0) :back-color sdl:*black* :max-hp 12 :max-fp 24
                                       :faction +faction-type-eater+
                                       :weapon (list "Tentacles" (list +weapon-dmg-flesh+ 2 3 +normal-ap+ 100 (list :constricts)) nil) :base-dodge 15
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 1 0) (list +weapon-dmg-fire+ 1 0))
                                       :strength 2
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-detect-good t :abil-detect-evil t :abil-no-breathe t  :abil-primordial t :abil-constriction t
                                       :abil-open-close-door t :abil-cannibalize t :abil-primordial-power t :abil-sprint t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-eater-of-the-dead-rage+
                                       :name "eater of the dead"
                                       :glyph-idx 37 :glyph-color (sdl:color :r 255 :g 165 :b 0) :back-color sdl:*black* :max-hp 12 :max-fp 24
                                       :faction +faction-type-eater+
                                       :weapon (list "Clawed tentacles" (list +weapon-dmg-flesh+ 6 10 (truncate (* +normal-ap+ 0.75)) 100 (list :constricts)) nil) :base-dodge 75
                                       :armor (list (list +weapon-dmg-flesh+ 3 0) (list +weapon-dmg-iron+ 3 0) (list +weapon-dmg-vorpal+ 3 0) (list +weapon-dmg-fire+ 3 0))
                                       :strength 3
                                       :base-light-radius 0 :base-stealth 10
                                       :abil-detect-good t :abil-detect-evil t :abil-no-breathe t :abil-primordial t :abil-constriction t
                                       :abil-open-close-door t :abil-cannibalize t :abil-sprint t
                                       :ai-curious t))

;;--------------------
;; BEASTS
;;--------------------

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-horse+ 
                                       :name "horse"
                                       :glyph-idx 72 :glyph-color (sdl:color :r 139 :g 69 :b 19) :back-color sdl:*black* :max-hp 12 :max-fp 0
                                       :faction +faction-type-animals+
                                       :weapon (list "Hooves" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 0
                                       :abil-animal t :abil-momentum 2 :abil-horse-can-be-ridden t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-sheep+ 
                                       :name "sheep"
                                       :glyph-idx 72 :glyph-color sdl:*white* :back-color sdl:*black* :max-hp 12 :max-fp 0
                                       :faction +faction-type-animals+
                                       :weapon (list "Hooves" (list +weapon-dmg-flesh+ 0 1 +normal-ap+ 100 ()) nil) :base-dodge 25
                                       :strength 0
                                       :base-light-radius 0
                                       :abil-animal t
                                       :ai-coward t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-fiend+ 
                                       :name "fiend"
                                       :glyph-idx 70 :glyph-color sdl:*red* :back-color sdl:*black* :max-hp 12 :max-fp 0
                                       :faction +faction-type-outsider-beasts+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 3 4 +normal-ap+ 100 ()) nil) :base-dodge 35
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 2 0))
                                       :strength 2
                                       :base-light-radius 0
                                       :abil-animal t :abil-demon t :abil-unholy t :abil-detect-good t :abil-lifesteal t :abil-momentum 2 :abil-fiend-can-be-ridden t :abil-loves-infighting t :abil-no-breathe t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-gargantaur+ 
                                       :name "gargantaur"
                                       :glyph-idx 39 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 25 :max-fp 2
                                       :faction +faction-type-outsider-beasts+
                                       :weapon (list "Claws" (list +weapon-dmg-vorpal+ 6 10 +normal-ap+ 100 ()) nil) :base-dodge 0
                                       :armor (list (list +weapon-dmg-flesh+ 4 0) (list +weapon-dmg-iron+ 2 0) (list +weapon-dmg-vorpal+ 4 0) (list +weapon-dmg-fire+ 4 0))
                                       :strength 8 :base-sight 7
                                       :map-size 3
                                       :abil-animal t :abil-angel t :abil-facing t :abil-immovable t :abil-loves-infighting t :abil-mind-burn t :abil-heal-self 1 :abil-gargantaur-teleport t :abil-detect-evil t :abil-no-breathe t
                                       :ai-curious t))

(set-mob-type (make-instance 'mob-type :mob-type +mob-type-wisp+
                                       :name "wisp"
                                       :glyph-idx 87 :glyph-color sdl:*cyan* :back-color sdl:*black* :max-hp 12 :max-fp 5
                                       :faction +faction-type-outsider-wisps+
                                       :weapon (list "Stellar touch" (list +weapon-dmg-fire+ 2 3 +normal-ap+ 100 ()) nil) :base-dodge 40 :move-spd +normal-ap+
                                       :armor (list (list +weapon-dmg-flesh+ 1 0) (list +weapon-dmg-iron+ 1 0) (list +weapon-dmg-vorpal+ 1 0) (list +weapon-dmg-fire+ 1 0))
                                       :strength 1
                                       :base-light-radius 6 :base-sight 0
                                       :abil-animal t :abil-angel t :abil-no-breathe t :abil-shared-minds t :abil-detect-evil t :abil-flying t :abil-no-corpse t 
                                       :ai-curious t))

(set-faction-relations +faction-type-humans+
                       (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t) (cons +faction-type-military+ t)
                       (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-angels+
                       (cons +faction-type-angels+ t) (cons +faction-type-humans+ t) (cons +faction-type-animals+ t) (cons +faction-type-criminals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-wisps+ t) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-demons+
                       (cons +faction-type-demons+ t)
                       (cons +faction-type-angels+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-beasts+ nil)
                       (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-military+
                       (cons +faction-type-military+ t) (cons +faction-type-humans+ t) (cons +faction-type-animals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil)
                       (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-animals+
                       (cons +faction-type-animals+ t) (cons +faction-type-humans+ t) (cons +faction-type-angels+ t) (cons +faction-type-military+ t) (cons +faction-type-criminals+ t)
                       (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-outsider-beasts+
                       (cons +faction-type-outsider-beasts+ nil)
                       (cons +faction-type-animals+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil)
                       (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-criminals+
                       (cons +faction-type-criminals+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t)
                       (cons +faction-type-humans+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-outsider-wisps+ nil)
                       (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-outsider-wisps+
                       (cons +faction-type-angels+ t) (cons +faction-type-outsider-wisps+ t)
                       (cons +faction-type-animals+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil)
                       (cons +faction-type-criminals+ nil) (cons +faction-type-eater+ nil))
(set-faction-relations +faction-type-eater+
                       (cons +faction-type-angels+ nil) (cons +faction-type-outsider-wisps+ nil)
                       (cons +faction-type-animals+ nil) (cons +faction-type-humans+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil)
                       (cons +faction-type-criminals+ nil))
