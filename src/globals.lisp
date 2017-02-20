(in-package :cotd)

(declaim (type fixnum *max-x-level* *max-y-level*))
(declaim (ftype (function (fixnum fixnum fixnum fixnum) single-float) get-distance))

(defvar *time-at-end-of-player-turn* 0)

(defparameter *max-x-level* 100)
(defparameter *max-y-level* 100)
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

(defconstant +faction-type-none+ 0)
(defconstant +faction-type-humans+ 1)
(defconstant +faction-type-angels+ 2)
(defconstant +faction-type-demons+ 3)
(defconstant +faction-type-military+ 4)

(defconstant +ai-pref-coward+ 0)
(defconstant +ai-pref-horde+ 1)
(defconstant +ai-pref-wants-bless+ 2)
(defconstant +ai-pref-stop+ 3)

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

(defconstant +mob-order-follow+ 0)

(defconstant +weapon-dmg-flesh+ 0)
(defconstant +weapon-dmg-iron+ 1)
(defconstant +weapon-dmg-fire+ 2)
(defconstant +weapon-dmg-vorpal+ 3)

;;--------------------
;; ITEM-TYPE Constants
;;-------------------- 

(defconstant +item-type-body-part+ 0)

;;--------------------
;; FEATURE-TYPE Constants
;;-------------------- 

(defconstant +feature-blood-fresh+ 0)
(defconstant +feature-blood-old+ 1)
(defconstant +feature-blood-stain+ 2)

;;--------------------
;; TERRAIN-TEMPLATE Constants
;;-------------------- 

(defconstant +terrain-trait-blocks-move+ 0)
(defconstant +terrain-trait-blocks-vision+ 1)
(defconstant +terrain-trait-blocks-projectiles+ 2)

(defconstant +terrain-border-floor+ 0)
(defconstant +terrain-floor-stone+ 1)
(defconstant +terrain-wall-stone+ 2)
(defconstant +terrain-tree-birch+ 3)
(defconstant +terrain-floor-grass+ 4)
(defconstant +terrain-water-lake+ 5)
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
(defconstant +terrain-water-river+ 20)
(defconstant +terrain-floor-bridge+ 21)
(defconstant +terrain-floor-pier+ 22)
(defconstant +terrain-water-sea+ 23)
(defconstant +terrain-border-grass+ 24)
(defconstant +terrain-wall-barricade+ 25)

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

;;---------------------------
;; Multithreading parameters
;;--------------------------- 

(defparameter *path-thread* nil)
