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
(defvar *highscores*)

;; most likely I am doing it wrong but I need a sequence of letters in alphabetical order
(defvar *char-list* (list "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"))

(defparameter *init-angel-names* (list "Barachiel" "Jegudiel" "Muriel" "Pahaliah" "Selaphiel" "Zachariel" "Adriel" "Ambriel" "Camael" "Cassiel" "Daniel" "Eremiel" "Hadraniel" "Haniel" "Hesediel" "Jehoel" "Jerahmeel" "Jophiel" 
                                       "Kushiel" "Leliel" "Metatron" "Nanael" "Nithael" "Netzach" "Ophaniel" "Puriel" "Qaphsiel" "Raziel" "Remiel" "Rikbiel" "Sachiel" "Samael" "Sandalphon" "Seraphiel" "Shamsiel" "Tzaphqiel" 
                                       "Uriel" "Uzziel" "Vehuel" "Zophiel" "Azazel" "Azrael" "Sariel" "Gabriel" "Raphael" "Michael"))

(defparameter *init-demon-names* (list "Amon" "Abaddon" "Agares" "Haborym" "Alastor" "Allocer" "Amaymon" "Amdusias" "Andras" "Amdusias" "Andromalius" "Anzu" "Asmodeus" "Astaroth" "Bael" "Balam" "Barbatos" "Bathin" "Beelzebub"
                                       "Behemoth" "Beleth" "Belial" "Belthegor" "Berith" "Bifrons" "Botis" "Buer" "Cacus" "Cerberus" "Mastema" "Melchiresus" "Moloch" "Onoskelis" "Shedim" "Xaphan" "Ornias" "Mammon" "Lix Tetrax"
                                       "Nybbas" "Focalor" "Furfur" "Gaap" "Geryon" "Haures" "Ipos" "Jezebeth" "Kasdeya" "Kobal" "Malphas" "Melchom" "Mullin" "Naberius" "Nergal" "Nicor" "Nysrogh" "Oriax" "Paymon" "Philatnus"
                                       "Pruflas" "Raum" "Rimmon" "Ronove" "Ronwe" "Shax" "Shalbriri" "Sonellion" "Stolas" "Succorbenoth" "Thamuz" "Ukobach" "Uphir" "Uvall" "Valafar" "Vepar" "Verdelet" "Verin" "Xaphan" "Zagan"
                                       "Zepar" "Ioz" "Zohadam" "Hardaz"))

(defparameter *init-human-names* (list "Afanasiy" "Andrey" "Boris" "Ivan" "Dmitry" "Alexey" "Nicolay" "Alexander" "Pyotr" "Pavel" "Vladimir" "Mikhail" "Fyodor" "Gavriil" "Vasiliy" "Denis" "Konstantin" "Sergey" "Vladislav" "Victor"
                                       "Vsevolod" "Grigoriy" "Daniil"))
(defparameter *init-human-surnames* (list "Grekov" "Plotnikov" "Strakhov" "Verkhovenskiy" "Shatov" "Stavrogin" "Kirillov" "Tushin" "Lebyadkin" "Liputin" "Virginskiy" "Lyamshin" "Tolkachenko" "Shigalev" "Karmazinov" "Nechayev"
                                          "Lebedev" "Rogozhin" "Ivolgin" "Epanchin" "Ferdishchenko" "Totskiy" "Myshkin" "Pavlishchev" "Burdovskiy" "Radomskiy" "Molovtsov" "Terentyev" "Ptitsin" "Zhadov" "Zhuravishkin"))

(defparameter *cur-demon-names* nil)
(defparameter *cur-angel-names* nil)
(defparameter *cur-human-names* nil)
(defparameter *cur-human-surnames* nil)

(defparameter *max-player-name-length* 20)

(defconstant +noun-proper+ 0)
(defconstant +noun-common+ 1)
(defconstant +noun-plural+ 2)
(defconstant +noun-singular+ 3)

(defconstant +article-none+ 0)
(defconstant +article-a+ 1)
(defconstant +article-the+ 2)

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
(defconstant +mob-type-reanimated-empowered+ 28)
(defconstant +mob-type-wisp+ 29)
(defconstant +mob-type-shadow-imp+ 30)
(defconstant +mob-type-shadow-demon+ 31)
(defconstant +mob-type-shadow-devil+ 32)
(defconstant +mob-type-star-singer+ 33)
(defconstant +mob-type-star-gazer+ 34)
(defconstant +mob-type-star-mender+ 35)
(defconstant +mob-type-star-singer-mender+ 36)
(defconstant +mob-type-star-singer-gazer+ 37)
(defconstant +mob-type-star-gazer-mender+ 38)
(defconstant +mob-type-star-singer-gazer-mender+ 39)
(defconstant +mob-type-angel-image+ 40)
(defconstant +mob-type-eater-of-the-dead+ 41)
(defconstant +mob-type-malseraph-puppet+ 42)
(defconstant +mob-type-sheep+ 43)
(defconstant +mob-type-locust+ 44)
(defconstant +mob-type-scarab+ 45)
(defconstant +mob-type-acid-locust+ 46)
(defconstant +mob-type-fast-scarab+ 47)
(defconstant +mob-type-seeker-larva+ 48)
(defconstant +mob-type-spore-colony+ 49)
(defconstant +mob-type-ghost+ 50)
(defconstant +mob-type-tree+ 51)
(defconstant +mob-type-satanist-empowered+ 52)

(defconstant +faction-type-none+ 0)
(defconstant +faction-type-humans+ 1)
(defconstant +faction-type-angels+ 2)
(defconstant +faction-type-demons+ 3)
(defconstant +faction-type-military+ 4)
(defconstant +faction-type-animals+ 5)
(defconstant +faction-type-outsider-beasts+ 6)
(defconstant +faction-type-criminals+ 7)
(defconstant +faction-type-outsider-wisps+ 8)
(defconstant +faction-type-eater+ 9)
(defconstant +faction-type-ghost+ 10)

(defconstant +ai-package-coward+ 0)
(defconstant +ai-package-horde+ 1)
(defconstant +ai-package-wants-bless+ 2)
(defconstant +ai-package-takes-valuable-items+ 3)
(defconstant +ai-package-curious+ 4)
(defconstant +ai-package-kleptomaniac+ 5)
(defconstant +ai-package-cautious+ 6)
(defconstant +ai-package-trinity-mimic+ 7)
(defconstant +ai-package-split-soul+ 8)
(defconstant +ai-package-cannibal+ 9)
(defconstant +ai-package-use-ability+ 10)
(defconstant +ai-package-use-item+ 11)
(defconstant +ai-package-reload-ranged-weapon+ 12)
(defconstant +ai-package-shoot-enemy+ 13)
(defconstant +ai-package-follow-leader+ 14)
(defconstant +ai-package-approach-target+ 15)
(defconstant +ai-package-attack-nearest-enemy+ 16)
(defconstant +ai-package-find-random-location+ 17)

(defconstant +ai-priority-never+ 0)
(defconstant +ai-priority-always+ 10)

(defconstant +mob-abil-heal-self+ 0)
(defconstant +mob-abil-conceal-divine+ 1)
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
(defconstant +mob-abil-empower-undead+ 56)
(defconstant +mob-abil-ignite-the-fire+ 57)
(defconstant +mob-abil-avatar-of-brilliance+ 58)
(defconstant +mob-abil-gravity-chains+ 59)
(defconstant +mob-abil-flying+ 60)
(defconstant +mob-abil-no-corpse+ 61)
(defconstant +mob-abil-smite+ 62)
(defconstant +mob-abil-slow+ 63)
(defconstant +mob-abil-prayer-wrath+ 64)
(defconstant +mob-abil-shadow-step+ 65)
(defconstant +mob-abil-extinguish-light+ 66)
(defconstant +mob-abil-umbral-aura+ 67)
(defconstant +mob-abil-trinity-mimic+ 68)
(defconstant +mob-abil-merge+ 69)
(defconstant +mob-abil-unmerge+ 70)
(defconstant +mob-abil-heal-other+ 71)
(defconstant +mob-abil-righteous-fury+ 72)
(defconstant +mob-abil-pain-link+ 73)
(defconstant +mob-abil-soul-reinforcement+ 74)
(defconstant +mob-abil-silence+ 75)
(defconstant +mob-abil-confuse+ 76)
(defconstant +mob-abil-split-soul+ 77)
(defconstant +mob-abil-restore-soul+ 78)
(defconstant +mob-abil-resurrection+ 79)
(defconstant +mob-abil-sprint+ 80)
(defconstant +mob-abil-jump+ 81)
(defconstant +mob-abil-bend-space+ 82)
(defconstant +mob-abil-cast-shadow+ 83)
(defconstant +mob-abil-cannibalize+ 84)
(defconstant +mob-abil-primordial+ 85)
(defconstant +mob-abil-make-disguise+ 86)
(defconstant +mob-abil-remove-disguise+ 87)
(defconstant +mob-abil-constriction+ 88)
(defconstant +mob-abil-irradiate+ 89)
(defconstant +mob-abil-fission+ 90)
(defconstant +mob-abil-adrenal-gland+ 91)
(defconstant +mob-abil-mutate-acid-spit+ 92)
(defconstant +mob-abil-mutate-corroding-secretion+ 93)
(defconstant +mob-abil-acid-spit+ 94)
(defconstant +mob-abil-corroding-secretion+ 95)
(defconstant +mob-abil-mutate-corrosive-bile+ 96)
(defconstant +mob-abil-mutate-accurate-bile+ 97)
(defconstant +mob-abil-corrosive-bile+ 98)
(defconstant +mob-abil-accurate-bile+ 99)
(defconstant +mob-abil-mutate-clawed-tentacle+ 100)
(defconstant +mob-abil-mutate-piercing-needles+ 101)
(defconstant +mob-abil-clawed-tentacle+ 102)
(defconstant +mob-abil-piercing-needles+ 103)
(defconstant +mob-abil-mutate-chitinous-plating+ 104)
(defconstant +mob-abil-mutate-thick-carapace+ 105)
(defconstant +mob-abil-chitinous-plating+ 106)
(defconstant +mob-abil-thick-carapace+ 107)
(defconstant +mob-abil-mutate-metabolic-boost+ 108)
(defconstant +mob-abil-mutate-jump+ 109)
(defconstant +mob-abil-metabolic-boost+ 110)
(defconstant +mob-abil-mutate-retracting-spines+ 111)
(defconstant +mob-abil-mutate-acidic-tips+ 112)
(defconstant +mob-abil-retracting-spines+ 113)
(defconstant +mob-abil-acidic-tips+ 114)
(defconstant +mob-abil-mutate-ovipositor+ 115)
(defconstant +mob-abil-oviposit+ 116)
(defconstant +mob-abil-create-parasites+ 117)
(defconstant +mob-abil-mutate-spawn-locusts+ 118)
(defconstant +mob-abil-spawn-locusts+ 119)
(defconstant +mob-abil-mutate-spawn-scarabs+ 120)
(defconstant +mob-abil-spawn-scarabs+ 121)
(defconstant +mob-abil-acid-explosion+ 122)
(defconstant +mob-abil-mutate-acid-locusts+ 123)
(defconstant +mob-abil-mutate-fast-scarabs+ 124)
(defconstant +mob-abil-mutate-oviposit-more-eggs+ 125)
(defconstant +mob-abil-mutate-tougher-locusts+ 126)
(defconstant +mob-abil-oviposit-more-eggs+ 127)
(defconstant +mob-abil-tougher-locusts+ 128)
(defconstant +mob-abil-acid-locusts+ 129)
(defconstant +mob-abil-fast-scarabs+ 130)
(defconstant +mob-abil-regenerate+ 131)
(defconstant +mob-abil-casts-light+ 132)
(defconstant +mob-abil-vulnerable-to-vorpal+ 133)
(defconstant +mob-abil-vulnerable-to-fire+ 134)
(defconstant +mob-abil-cure-mutation+ 135)
(defconstant +mob-abil-mutate-hooks-and-suckers+ 136)
(defconstant +mob-abil-mutate-disguise-as-human+ 137)
(defconstant +mob-abil-disguise-as-human+ 138)
(defconstant +mob-abil-mutate-spawn-larva+ 139)
(defconstant +mob-abil-spawn-larva+ 140)
(defconstant +mob-abil-mutate-spore-colony+ 141)
(defconstant +mob-abil-spore-colony+ 142)
(defconstant +mob-abil-immobile+ 143)
(defconstant +mob-abil-float+ 144)
(defconstant +mob-abil-ghost-possess+ 145)
(defconstant +mob-abil-invisibility+ 146)
(defconstant +mob-abil-passwall+ 147)
(defconstant +mob-abil-ghost-release+ 148)
(defconstant +mob-abil-decipher-rune+ 149)
(defconstant +mob-abil-demon-word-flesh+ 150)
(defconstant +mob-abil-demon-word-knockback+ 151)
(defconstant +mob-abil-demon-word-invasion+ 152)
(defconstant +mob-abil-demon-word-darkness+ 153)
(defconstant +mob-abil-demon-word-plague+ 154)
(defconstant +mob-abil-demon-word-power+ 155)
(defconstant +mob-abil-soul+ 156)

(defconstant +mob-effect-possessed+ 0)
(defconstant +mob-effect-blessed+ 1)
(defconstant +mob-effect-reveal-true-form+ 2)
(defconstant +mob-effect-divine-concealed+ 3)
(defconstant +mob-effect-calling-for-help+ 4)
(defconstant +mob-effect-called-for-help+ 5)
(defconstant +mob-effect-divine-shield+ 6)
(defconstant +mob-effect-cursed+ 7)
(defconstant +mob-effect-blind+ 8)
(defconstant +mob-effect-fear+ 9)
(defconstant +mob-effect-climbing-mode+ 10)
(defconstant +mob-effect-alertness+ 11)
(defconstant +mob-effect-ready-to-possess+ 12)
(defconstant +mob-effect-avatar-of-brilliance+ 13)
(defconstant +mob-effect-empowered-undead+ 14)
(defconstant +mob-effect-necrolink+ 15)
(defconstant +mob-effect-gravity-pull+ 16)
(defconstant +mob-effect-flying+ 17)
(defconstant +mob-effect-slow+ 18)
(defconstant +mob-effect-holy-touch+ 19)
(defconstant +mob-effect-extinguished-light+ 20)
(defconstant +mob-effect-merged+ 21)
(defconstant +mob-effect-righteous-fury+ 22)
(defconstant +mob-effect-wet+ 23)
(defconstant +mob-effect-pain-link-source+ 24)
(defconstant +mob-effect-pain-link-target+ 25)
(defconstant +mob-effect-soul-reinforcement+ 26)
(defconstant +mob-effect-silence+ 27)
(defconstant +mob-effect-confuse+ 28)
(defconstant +mob-effect-split-soul-source+ 29)
(defconstant +mob-effect-split-soul-target+ 30)
(defconstant +mob-effect-sprint+ 31)
(defconstant +mob-effect-exerted+ 32)
(defconstant +mob-effect-casting-shadow+ 33)
(defconstant +mob-effect-disguised+ 34)
(defconstant +mob-effect-constriction-source+ 35)
(defconstant +mob-effect-constriction-target+ 36)
(defconstant +mob-effect-irradiated+ 37)
(defconstant +mob-effect-polymorph-sheep+ 38)
(defconstant +mob-effect-glowing+ 39)
(defconstant +mob-effect-parasite+ 40)
(defconstant +mob-effect-evolving+ 41)
(defconstant +mob-effect-adrenaline+ 42)
(defconstant +mob-effect-metabolic-boost+ 43)
(defconstant +mob-effect-spines+ 44)
(defconstant +mob-effect-mortality+ 45)
(defconstant +mob-effect-laying-eggs+ 46)
(defconstant +mob-effect-regenerate+ 47)
(defconstant +mob-effect-corroded+ 48)
(defconstant +mob-effect-primordial-transfer+ 49)
(defconstant +mob-effect-rest-in-peace+ 50)
(defconstant +mob-effect-polymorph-tree+ 51)
(defconstant +mob-effect-life-guard+ 52)
(defconstant +mob-effect-invisibility+ 53)
(defconstant +mob-effect-soul-sickness+ 54)
(defconstant +mob-effect-demonic-power+ 55)

(defconstant +mob-order-follow+ 0)
(defconstant +mob-order-target+ 1)

(defconstant +weapon-dmg-flesh+ 0)
(defconstant +weapon-dmg-iron+ 1)
(defconstant +weapon-dmg-fire+ 2)
(defconstant +weapon-dmg-vorpal+ 3)
(defconstant +weapon-dmg-mind+ 4)
(defconstant +weapon-dmg-radiation+ 5)
(defconstant +weapon-dmg-acid+ 6)

;;--------------------
;; ITEM-TYPE Constants
;;-------------------- 

(defconstant +item-abil-corpse+ 0)
(defconstant +item-abil-card+ 1)

(defconstant +item-type-body-part-limb+ 0)
(defconstant +item-type-body-part-half+ 1)
(defconstant +item-type-body-part-body+ 2)
(defconstant +item-type-body-part-full+ 3)
(defconstant +item-type-coin+ 4)
(defconstant +item-type-medkit+ 5)
(defconstant +item-type-smoke-bomb+ 6)
(defconstant +item-type-clothing+ 7)
(defconstant +item-type-disguise+ 8)
(defconstant +item-type-deck-of-war+ 9)
(defconstant +item-type-deck-of-escape+ 10)
(defconstant +item-type-eater-parasite+ 11)
(defconstant +item-type-signal-flare+ 12)
(defconstant +item-type-eater-scarab-egg+ 13)
(defconstant +item-type-eater-locust-egg+ 14)
(defconstant +item-type-eater-larva-egg+ 15)
(defconstant +item-type-eater-colony-egg+ 16)
(defconstant +item-type-book-of-rituals+ 17)
(defconstant +item-type-scroll-demonic-rune-flesh+ 18)
(defconstant +item-type-scroll-demonic-rune-invite+ 19)
(defconstant +item-type-scroll-demonic-rune-away+ 20)
(defconstant +item-type-scroll-demonic-rune-transform+ 21)
(defconstant +item-type-scroll-demonic-rune-barrier+ 22)
(defconstant +item-type-scroll-demonic-rune-all+ 23)
(defconstant +item-type-scroll-demonic-rune-decay+ 24)
 
;;--------------------
;; FEATURE-TYPE Constants
;;-------------------- 

(defconstant +feature-trait-blocks-vision+ 0)
(defconstant +feature-trait-smoke+ 1)
(defconstant +feature-trait-no-gravity+ 2)
(defconstant +feature-trait-fire+ 3)
(defconstant +feature-trait-remove-on-dungeon-generation+ 4)
(defconstant +feature-trait-demonic-rune+ 5)

(defconstant +feature-blood-fresh+ 0)
(defconstant +feature-blood-old+ 1)
(defconstant +feature-blood-stain+ 2)
(defconstant +feature-start-satanist-player+ 3)
(defconstant +feature-smoke-thin+ 4)
(defconstant +feature-smoke-thick+ 5)
(defconstant +feature-fire+ 6)
(defconstant +feature-start-gold-small+ 7)
(defconstant +feature-start-gold-big+ 8)
(defconstant +feature-start-church-player+ 9)
(defconstant +feature-start-repel-demons+ 10)
(defconstant +feature-smoke-flare+ 11)
(defconstant +feature-smoke-flare-final+ 12)
(defconstant +feature-corrosive-bile-target+ 13)
(defconstant +feature-sacrificial-circle+ 14)
(defconstant +feature-demonic-rune-flesh+ 15)
(defconstant +feature-demonic-rune-invite+ 16)
(defconstant +feature-demonic-rune-away+ 17)
(defconstant +feature-demonic-rune-transform+ 18)
(defconstant +feature-demonic-rune-barrier+ 19)
(defconstant +feature-demonic-rune-all+ 20)
(defconstant +feature-demonic-rune-decay+ 21)

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
(defconstant +terrain-trait-flammable+ 14)
(defconstant +terrain-trait-can-jump-over+ 15)
(defconstant +terrain-trait-can-have-rune+ 16)

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
(defconstant +terrain-floor-ash+ 45)
(defconstant +terrain-wall-grave+ 46)
(defconstant +terrain-floor-sign-church-catholic+ 47)
(defconstant +terrain-floor-sign-library+ 48)
(defconstant +terrain-floor-sign-prison+ 49)
(defconstant +terrain-floor-sign-bank+ 50)
(defconstant +terrain-floor-sign-church-orthodox+ 51)

;;--------------------
;; GOD Constants
;;--------------------

(defconstant +god-entity-malseraph+ 0)

(defparameter *faction-table* (make-hash-table))

(defparameter *ability-types* (make-array (list 0) :adjustable t))
(defparameter *feature-types* (make-array (list 0) :adjustable t))
(defparameter *terrain-types* (make-array (list 0) :adjustable t))
(defparameter *mob-types* (make-array (list 0) :adjustable t))
(defparameter *item-types* (make-array (list 0) :adjustable t))
(defparameter *effect-types* (make-array (list 0) :adjustable t))
(defparameter *card-types* (make-array (list 0) :adjustable t))
(defparameter *gods* (make-array (list 0) :adjustable t))
(defparameter *ai-packages* (make-array (list 0) :adjustable t))

(defparameter *lvl-features* (make-array (list 0) :adjustable t))
(defparameter *mobs* (make-array (list 0) :adjustable t))
(defparameter *items* (make-array (list 0) :adjustable t))
(defparameter *effects* (make-array (list 0) :adjustable t))

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
(defparameter *dark-power-faloff* 12)
(defparameter *mob-visibility-threshold* 50)

(defparameter *mob-motion-order* 20)
(defparameter *mob-motion-move* 40)
(defparameter *mob-motion-stand* 0)
(defparameter *mob-motion-melee* 60)
(defparameter *mob-motion-shoot* 30)
(defparameter *mob-motion-reload* 40)
(defparameter *mob-motion-ascend* 100)
(defparameter *mob-motion-pick-drop* 30)
(defparameter *mob-motion-use-item* 30)

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
(defconstant +connect-map-move-fly+ 2)

;;---------------------------
;; Multithreading parameters
;;--------------------------- 

(defparameter *path-thread* nil)
(defparameter *fov-thread* nil)

#+windows
(defun new-line (&optional (on-screen nil))
  (if on-screen
    ""
    #\return))

#+unix
(defun new-line (&optional (on-screen nil))
  (if on-screen
    ""
    #\return))
