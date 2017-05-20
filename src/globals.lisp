(in-package :cotd)

(declaim (type fixnum *max-x-level* *max-y-level*))
(declaim (ftype (function (fixnum fixnum fixnum fixnum) single-float) get-distance))

(defvar *time-at-end-of-player-turn* 0)

(defparameter *max-x-level* 100)
(defparameter *max-y-level* 100)
(defparameter *max-z-level* 9)
(defparameter *max-x-view* 25)
(defparameter *max-y-view* 25)

(defvar *options*)

(defparameter *init-angel-names* (list "Barachiel" "Jegudiel" "Muriel" "Pahaliah" "Selaphiel" "Zachariel" "Adriel" "Ambriel" "Camael" "Cassiel" "Daniel" "Eremiel" "Hadraniel" "Haniel" "Hesediel" "Jehoel" "Jerahmeel" "Jophiel" 
                                       "Kushiel" "Leliel" "Metatron" "Nanael" "Nithael" "Netzach" "Ophaniel" "Puriel" "Qaphsiel" "Raziel" "Remiel" "Rikbiel" "Sachiel" "Samael" "Sandalphon" "Seraphiel" "Shamsiel" "Tzaphqiel" 
                                       "Uriel" "Uzziel" "Vehuel" "Zophiel" "Azazel" "Azrael" "Sariel" "Gabriel" "Raphael" "Michael"))

(defparameter *init-demon-names* (list "Amon" "Abaddon" "Agares" "Haborym" "Alastor" "Allocer" "Amaymon" "Amdusias" "Andras" "Amdusias" "Andromalius" "Anzu" "Asmodeus" "Astaroth" "Bael" "Balam" "Barbatos" "Bathin" "Beelzebub"
                                       "Behemoth" "Beleth" "Belial" "Belthgor" "Berith" "Bifrons" "Botis" "Buer" "Cacus" "Cerberus" "Mastema" "Melchiresus" "Moloch" "Onoskelis" "Shedim" "Xaphan" "Ornias" "Mammon" "Lix Tetrax"
                                       "Nybbas" "Focalor" "Furfur" "Gaap" "Geryon" "Haures" "Ipos" "Jezebeth" "Kasdeya" "Kobal" "Malphas" "Melchom" "Mullin" "Naberius" "Nergal" "Nicor" "Nysrogh" "Oriax" "Paymon" "Philatnus"
                                       "Pruflas" "Raum" "Rimmon" "Ronove" "Ronwe" "Shax" "Shalbriri" "Sonellion" "Stolas" "Succorbenoth" "Thamuz" "Ukobach" "Uphir" "Uvall" "Valafar" "Vepar" "Verdelet" "Verin" "Xaphan" "Zagan"
                                       "Zepar"))

(defparameter *cur-demon-names* nil)
(defparameter *cur-angel-names* nil)

;;--------------------
;; MOB-TEMPLATE Constants
;;-------------------- 

(defconstant +base-accuracy+ 100)

(defconstant +mob-type-player+ 0)
(defconstant +mob-type-human+ 1)
(defconstant +mob-type-angel+ 2)
(defconstant +mob-type-demon+ 3)
(defconstant +mob-type-archangel+ 4)
(defconstant +mob-type-imp+ 5)
(defconstant +mob-type-archdemon+ 6)
(defconstant +mob-type-man+ 7)
(defconstant +mob-type-woman+ 8)
(defconstant +mob-type-child+ 9)
(defconstant +mob-type-clerk+ 10)
(defconstant +mob-type-criminal+ 11)
(defconstant +mob-type-policeman+ 12)
(defconstant +mob-type-priest+ 13)
(defconstant +mob-type-satanist+ 14)
(defconstant +mob-type-soldier+ 15)
(defconstant +mob-type-sergeant+ 16)
(defconstant +mob-type-chaplain+ 17)
(defconstant +mob-type-gunner+ 18)
(defconstant +mob-type-horse+ 19)
(defconstant +mob-type-fiend+ 20)
(defconstant +mob-type-scout+ 21)
(defconstant +mob-type-gargantaur+ 22)
(defconstant +mob-type-thief+ 23)
(defconstant +mob-type-reanimated-pwr-1+ 24)
(defconstant +mob-type-reanimated-pwr-2+ 25)
(defconstant +mob-type-reanimated-pwr-3+ 26)
(defconstant +mob-type-reanimated-pwr-4+ 27)

(defconstant +faction-type-none+ 0)
(defconstant +faction-type-humans+ 1)
(defconstant +faction-type-angels+ 2)
(defconstant +faction-type-demons+ 3)
(defconstant +faction-type-military+ 4)
(defconstant +faction-type-animals+ 5)
(defconstant +faction-type-outsider-beasts+ 6)
(defconstant +faction-type-criminals+ 7)

(defconstant +ai-pref-coward+ 0)
(defconstant +ai-pref-horde+ 1)
(defconstant +ai-pref-wants-bless+ 2)
(defconstant +ai-pref-stop+ 3)
(defconstant +ai-pref-curious+ 4)
(defconstant +ai-pref-kleptomaniac+ 5)
(defconstant +ai-pref-cautious+ 6)

(defconstant +mob-abil-heal-self+ 0)
(defconstant +mob-abil-conseal-divine+ 1)
(defconstant +mob-abil-reveal-divine+ 2)
(defconstant +mob-abil-detect-good+ 3)
(defconstant +mob-abil-detect-evil+ 4)
(defconstant +mob-abil-possessable+ 5)
(defconstant +mob-abil-can-possess+ 6)
(defconstant +mob-abil-purging-touch+ 7)
(defconstant +mob-abil-blessing-touch+ 8)
(defconstant +mob-abil-can-be-blessed+ 9)
(defconstant +mob-abil-unholy+ 10)
(defconstant +mob-abil-angel+ 11)
(defconstant +mob-abil-demon+ 12)
(defconstant +mob-abil-human+ 13)
(defconstant +mob-abil-see-all+ 14)
(defconstant +mob-abil-lifesteal+ 15)
(defconstant +mob-abil-call-for-help+ 16)
(defconstant +mob-abil-answer-the-call+ 17)
(defconstant +mob-abil-loves-infighting+ 18)
(defconstant +mob-abil-prayer-bless+ 19)
(defconstant +mob-abil-free-call+ 20)
(defconstant +mob-abil-prayer-shield+ 21)
(defconstant +mob-abil-curse+ 22)
(defconstant +mob-abil-keen-senses+ 23)
(defconstant +mob-abil-prayer-reveal+ 24)
(defconstant +mob-abil-military-follow-me+ 25)
(defconstant +mob-abil-blindness+ 26)
(defconstant +mob-abil-instill-fear+ 27)
(defconstant +mob-abil-charge+ 28)
(defconstant +mob-abil-momentum+ 29)
(defconstant +mob-abil-animal+ 30)
(defconstant +mob-abil-horseback-riding+ 31)
(defconstant +mob-abil-horse-can-be-ridden+ 32)
(defconstant +mob-abil-dismount+ 33)
(defconstant +mob-abil-dominate-fiend+ 34)
(defconstant +mob-abil-fiend-can-be-ridden+ 35)
(defconstant +mob-abil-starts-with-horse+ 36)
(defconstant +mob-abil-independent+ 37)
(defconstant +mob-abil-eagle-eye+ 38)
(defconstant +mob-abil-facing+ 39)
(defconstant +mob-abil-immovable+ 40)
(defconstant +mob-abil-mind-burn+ 41)
(defconstant +mob-abil-gargantaur-teleport+ 42)
(defconstant +mob-abil-dominate-gargantaur+ 43)
(defconstant +mob-abil-gargantaurs-mind-burn+ 44)
(defconstant +mob-abil-death-from-above+ 45)
(defconstant +mob-abil-climbing+ 46)
(defconstant +mob-abil-no-breathe+ 47)
(defconstant +mob-abil-open-close-door+ 48)
(defconstant +mob-abil-toggle-light+ 49)
(defconstant +mob-abil-open-close-window+ 50)
(defconstant +mob-abil-can-possess-toggle+ 51)
(defconstant +mob-abil-sacrifice-host+ 52)
(defconstant +mob-abil-reanimate-corpse+ 53)
(defconstant +mob-abil-undead+ 54)
(defconstant +mob-abil-shared-minds+ 55)
(defconstant +mob-abil-smoke-bomb+ 56)

(defconstant +mob-effect-possessed+ 0)
(defconstant +mob-effect-blessed+ 1)
(defconstant +mob-effect-reveal-true-form+ 2)
(defconstant +mob-effect-divine-consealed+ 3)
(defconstant +mob-effect-calling-for-help+ 4)
(defconstant +mob-effect-called-for-help+ 5)
(defconstant +mob-effect-divine-shield+ 6)
(defconstant +mob-effect-cursed+ 7)
(defconstant +mob-effect-blind+ 8)
(defconstant +mob-effect-fear+ 9)
(defconstant +mob-effect-climbing-mode+ 10)
(defconstant +mob-effect-alertness+ 11)
(defconstant +mob-effect-ready-to-possess+ 12)

(defconstant +mob-order-follow+ 0)

(defconstant +weapon-dmg-flesh+ 0)
(defconstant +weapon-dmg-iron+ 1)
(defconstant +weapon-dmg-fire+ 2)
(defconstant +weapon-dmg-vorpal+ 3)

;;--------------------
;; ITEM-TYPE Constants
;;-------------------- 

(defconstant +item-abil-corpse+ 0)

(defconstant +item-type-body-part-limb+ 0)
(defconstant +item-type-body-part-half+ 1)
(defconstant +item-type-body-part-body+ 2)
(defconstant +item-type-body-part-full+ 3)
(defconstant +item-type-coin+ 4)

;;--------------------
;; FEATURE-TYPE Constants
;;-------------------- 

(defconstant +feature-trait-blocks-vision+ 0)
(defconstant +feature-trait-smoke+ 1)
(defconstant +feature-trait-no-gravity+ 2)

(defconstant +feature-blood-fresh+ 0)
(defconstant +feature-blood-old+ 1)
(defconstant +feature-blood-stain+ 2)
(defconstant +feature-start-satanist-player+ 3)
(defconstant +feature-smoke-thin+ 4)
(defconstant +feature-smoke-thick+ 5)

;;--------------------
;; TERRAIN-TEMPLATE Constants
;;-------------------- 

(defconstant +terrain-trait-blocks-move+ 0)
(defconstant +terrain-trait-blocks-vision+ 1)
(defconstant +terrain-trait-blocks-projectiles+ 2)
(defconstant +terrain-trait-opaque-floor+ 3)
(defconstant +terrain-trait-slope-up+ 4)
(defconstant +terrain-trait-slope-down+ 5)
(defconstant +terrain-trait-not-climable+ 6)
(defconstant +terrain-trait-light-source+ 7)
(defconstant +terrain-trait-blocks-sound+ 8)
(defconstant +terrain-trait-blocks-sound-floor+ 9)
(defconstant +terrain-trait-water+ 10)
(defconstant +terrain-trait-move-cost-factor+ 11)
(defconstant +terrain-trait-openable-door+ 12)
(defconstant +terrain-trait-openable-window+ 13)

(defconstant +terrain-border-floor+ 0)
(defconstant +terrain-floor-stone+ 1)
(defconstant +terrain-wall-stone+ 2)
(defconstant +terrain-tree-birch+ 3)
(defconstant +terrain-floor-grass+ 4)
(defconstant +terrain-water-liquid+ 5)
(defconstant +terrain-floor-dirt+ 6)
(defconstant +terrain-wall-window+ 7)
(defconstant +terrain-floor-dirt-bright+ 8)
(defconstant +terrain-floor-chair+ 9)
(defconstant +terrain-floor-table+ 10)
(defconstant +terrain-floor-bed+ 11)
(defconstant +terrain-floor-cabinet+ 12)
(defconstant +terrain-floor-crate+ 13)
(defconstant +terrain-floor-bookshelf+ 14)
(defconstant +terrain-border-floor-snow+ 15)
(defconstant +terrain-floor-snow+ 16)
(defconstant +terrain-floor-snow-prints+ 17)
(defconstant +terrain-tree-birch-snow+ 18)
(defconstant +terrain-water-ice+ 19)
(defconstant +terrain-border-water+ 20)
(defconstant +terrain-floor-bridge+ 21)
(defconstant +terrain-floor-pier+ 22)
(defconstant +terrain-water-liquid-nofreeze+ 23)
(defconstant +terrain-border-grass+ 24)
(defconstant +terrain-wall-barricade+ 25)
(defconstant +terrain-door-closed+ 26)
(defconstant +terrain-door-open+ 27)
(defconstant +terrain-border-air+ 28)
(defconstant +terrain-floor-air+ 29)
(defconstant +terrain-slope-stone-up+ 30)
(defconstant +terrain-slope-stone-down+ 31)
(defconstant +terrain-wall-earth+ 32)
(defconstant +terrain-wall-bush+ 33)
(defconstant +terrain-floor-branches+ 34)
(defconstant +terrain-floor-leaves+ 35)
(defconstant +terrain-tree-birch-trunk+ 36)
(defconstant +terrain-floor-leaves-snow+ 37)
(defconstant +terrain-tree-oak-trunk-nw+ 38)
(defconstant +terrain-tree-oak-trunk-sw+ 39)
(defconstant +terrain-tree-oak-trunk-ne+ 40)
(defconstant +terrain-tree-oak-trunk-se+ 41)
(defconstant +terrain-wall-lantern+ 42)
(defconstant +terrain-wall-lantern-off+ 43)
(defconstant +terrain-wall-window-opened+ 44)

(defparameter *faction-table* (make-hash-table))

(defparameter *ability-types* (make-array (list 0) :adjustable t))
(defparameter *feature-types* (make-array (list 0) :adjustable t))
(defparameter *terrain-types* (make-array (list 0) :adjustable t))
(defparameter *mob-types* (make-array (list 0) :adjustable t))
(defparameter *item-types* (make-array (list 0) :adjustable t))

(defparameter *lvl-features* (make-array (list 0) :adjustable t))
(defparameter *mobs* (make-array (list 0) :adjustable t))
(defparameter *items* (make-array (list 0) :adjustable t))

(defparameter *world* nil)
(defparameter *player* nil)

(defvar *update-screen-closure*)
(defvar *cur-progress-bar*)
(defvar *max-progress-bar*)

(defparameter *current-dir* (asdf:system-source-directory :cotd))

(defconstant +normal-ap+ 10)
(defparameter *possessed-revolt-chance* 12)
(defparameter *acc-loss-per-tile* 5)
(defparameter *max-mob-sight* 10)
(defparameter *base-mob-sight* 8)

(defparameter *base-light-radius* 6)
(defparameter *light-power-faloff* 17)
(defparameter *mob-visibility-threshold* 50)

(defparameter *mob-motion-order* 20)
(defparameter *mob-motion-move* 40)
(defparameter *mob-motion-stand* 0)
(defparameter *mob-motion-melee* 60)
(defparameter *mob-motion-shoot* 30)
(defparameter *mob-motion-reload* 40)
(defparameter *mob-motion-ascend* 100)
(defparameter *mob-motion-pick-drop* 30)

(defparameter *mob-exposure-alertness* 30)

(defparameter *max-hearing-range* 12)
(defparameter *sound-power-falloff* 10)

(defparameter *vision-power-falloff* 1)

(defparameter *mob-sound-move* 50)
(defparameter *mob-sound-stand* 0)
(defparameter *mob-sound-melee* 80)
(defparameter *mob-sound-reload* 50)
(defparameter *mob-sound-shoot* 200)
(defparameter *mob-sound-ascend* 60)
(defparameter *mob-sound-pick-drop* 40)

(defparameter *thief-win-value* 1500)

(defparameter *max-oxygen-level* 5)
(defparameter *lack-oxygen-dmg* 5)

(defparameter *water-move-factor* 1.5)

(defconstant +connect-room-none+ -1)

;; Connect map indices for various movement types
(defconstant +connect-map-move-walk+ 0)
(defconstant +connect-map-move-climb+ 1)

;;---------------------------
;; Multithreading parameters
;;--------------------------- 

(defparameter *path-thread* nil)
(defparameter *fov-thread* nil)
