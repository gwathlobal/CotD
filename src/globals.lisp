(in-package :cotd)

(eval-when (:compile-toplevel :load-toplevel :execute)
  ;; A trait spec is one of
  ;;   NAME                 - define the id constant and an initarg
  ;;   (NAME DEFAULT)       - as above, with a default value for the initarg
  ;;   (NAME :no-initarg)   - define the id constant only, for ids that are
  ;;                          granted some other way (mutations, missions,
  ;;                          effects) and are not settable on the type
  (defun trait-spec-name (spec)
    (if (consp spec) (first spec) spec))

  (defun trait-spec-initarg-p (spec)
    (not (and (consp spec) (eq (second spec) :no-initarg))))

  (defun trait-spec-default-p (spec)
    (and (consp spec) (not (eq (second spec) :no-initarg))))

  (defun trait-id-constant (prefix spec)
    "Constant naming SPEC's id, e.g. TERRAIN-TRAIT + BLOCKS-MOVE
=> +TERRAIN-TRAIT-BLOCKS-MOVE+."
    (intern (format nil "+~A-~A+" (symbol-name prefix)
                    (symbol-name (trait-spec-name spec)))
            :cotd))

  (defun trait-initarg-var (prefix spec)
    "Keyword parameter carrying SPEC's value into an initializer,
e.g. TRAIT + BLOCKS-MOVE => TRAIT-BLOCKS-MOVE, supplied as :trait-blocks-move."
    (intern (format nil "~A-~A" (symbol-name prefix)
                    (symbol-name (trait-spec-name spec)))
            :cotd))

  (defvar *trait-id-spaces* (make-hash-table)
    "Maps each id space's spec-list variable to (CONST-PREFIX PARAM-PREFIX).
Filled in by define-trait-ids so that define-trait-initializer can derive the
constant and initarg names itself, rather than having them restated at every
initializer and left to agree by hand.")

  (defun trait-id-space (list-name)
    "The (CONST-PREFIX PARAM-PREFIX) registered for LIST-NAME."
    (or (gethash list-name *trait-id-spaces*)
        (error "No id space is registered for ~S. Define it with ~
                define-trait-ids before generating an initializer from it."
               list-name))))

(defmacro define-trait-ids (const-prefix param-prefix count-name list-name &body specs)
  "Define an id space from SPECS (see trait-spec-name above for their forms).

Defines +CONST-PREFIX-NAME+ per spec holding its position in the list,
COUNT-NAME as how many there are, and LIST-NAME as the spec list. Both
prefixes and the list are recorded at compile time, so define-trait-initializer
derives the :PARAM-PREFIX-NAME initargs and the constants to store them under
from this one form - they are not restated at the initializer.

One list therefore defines the ids, the size of the id space and the initargs,
so appending a name to it is the whole change needed to add one. Order is the
numbering, and for mob abilities the ids are keys in saved games, so append
rather than insert."
  `(progn
     (eval-when (:compile-toplevel :load-toplevel :execute)
       (defparameter ,list-name ',specs)
       (setf (gethash ',list-name *trait-id-spaces*)
             '(,const-prefix ,param-prefix)))
     ,@(loop for spec in specs
             for index from 0
             collect `(defconstant ,(trait-id-constant const-prefix spec) ,index))
     (defconstant ,count-name ,(length specs))))

(defmacro define-trait-initializer (class groups extra-keys &body body)
  "Generate CLASS's initialize-instance :after method from id spaces.

Each group is (SPECS-VAR TABLE-ACCESSOR), where SPECS-VAR is an id space
defined by define-trait-ids. Every spec in it that takes an initarg becomes a
keyword parameter, and when that argument is truthy its value is stored in
(TABLE-ACCESSOR CLASS) under the spec's id constant. Both names come from the
prefixes SPECS-VAR was registered with, so they cannot drift from it.

EXTRA-KEYS are further keyword parameters the method needs, and BODY runs
before the generated stores. The instance is bound to CLASS, matching the
hand-written methods this replaces."
  (flet ((initarg-specs (specs-var)
           "(spec . param-prefix) for each spec in SPECS-VAR taking an initarg."
           (let ((param-prefix (second (trait-id-space specs-var))))
             (loop for spec in (symbol-value specs-var)
                   when (trait-spec-initarg-p spec)
                     collect (cons spec param-prefix)))))
    `(defmethod initialize-instance :after ((,class ,class)
                                            &key ,@extra-keys
                                              ,@(loop for (specs-var nil) in groups
                                                      append (loop for (spec . param-prefix) in (initarg-specs specs-var)
                                                                   collect (if (trait-spec-default-p spec)
                                                                             (list (trait-initarg-var param-prefix spec)
                                                                                   (second spec))
                                                                             (trait-initarg-var param-prefix spec)))))
       ,@body
       ,@(loop for (specs-var table) in groups
               append (let ((const-prefix (first (trait-id-space specs-var))))
                        (loop for (spec . param-prefix) in (initarg-specs specs-var)
                              collect (let ((var (trait-initarg-var param-prefix spec)))
                                        `(when ,var
                                           (setf (gethash ,(trait-id-constant const-prefix spec)
                                                          (,table ,class))
                                                 ,var)))))))))

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

(defparameter *scenario-hints* (list (format nil "In the beginning, there was Nothing. Then from Nothing came Something and it was the One, the Unborn, the Creator.")
                                     (format nil "Those whom we call demons were the first to be created. They call themselves the Firstborn and take great pride in their primacy.")
                                     (format nil "The Creator was not satisfied with Its first creation for the Firstborn were a mass of multiplying mingling flesh lacking any divine spark. So, the Creator confined them into a Prison Dimension as they were a disgrace to Its will.")
                                     (format nil "The humankind was created the second. They were given flesh as their shell and a soul as their core. But the flesh corrupted the Secondborn nonetheless and they forgot their origin.")
                                     (format nil "The Creator gave the Secondborn a world of their own and let them be. From time to time, it sent spoke to some of the humankind so that they did not go astray. Those humans were declared Prophets by their brethren.")
                                     (format nil "The Creator installed the Font from where a human soul comes when a human is born and where it returns to when a human dies. The number of souls is finite but they are infinitely divisible. Yet as humans multiplied, their divine spark wore thinner and thinner in them.")
                                     (format nil "Those Secondborn souls that were not blemished by sinful flesh during their mortal life remain in the Font free from any corrupting action. The souls stained by sin are torn and reforged to feed the demand of the ever-spawning humanity in new souls.")
                                     (format nil "The One takes great pity in humans for they are the Secondborn and possess the divine spark. Yet their fleshly shells make them akin to demons who were imprisoned in Hell for their misguided ways.")
                                     (format nil "We are the Thirdborn, the pinnacle of creation, the ultimate design of the One. We reject the malign flesh and exist as pure spirits. Our numbers are constant and our self can never be reduced.")
                                     (format nil "We, the Thirdborn, are the host of the Creator and allowed into Its inner circle. We serve as guards of the Prison Dimension and Its personal messengers. The One confides Its secrets in us and we are granted the privilege to speak to It orderly.")))

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
(defconstant +mob-type-demon-sigil+ 53)
(defconstant +mob-type-skinchanger-melee+ 54)
(defconstant +mob-type-skinchanger-ranged+ 55)
(defconstant +mob-type-skinchanger-flyer+ 56)
(defconstant +mob-type-skinchanger-turret+ 57)
(defconstant +mob-type-demon-machine+ 58)
(defconstant +mob-type-military-bomb-1+ 59)
(defconstant +mob-type-military-bomb-2+ 60)
(defconstant +mob-type-military-bomb-3+ 61)

(defconstant +faction-type-none+ 0)
(defconstant +faction-type-civilians+ 1)
(defconstant +faction-type-angels+ 2)
(defconstant +faction-type-demons+ 3)
(defconstant +faction-type-military+ 4)
(defconstant +faction-type-animals+ 5)
(defconstant +faction-type-outsider-beasts+ 6)
(defconstant +faction-type-criminals+ 7)
(defconstant +faction-type-outsider-wisps+ 8)
(defconstant +faction-type-eater+ 9)
(defconstant +faction-type-ghost+ 10)
(defconstant +faction-type-satanists+ 11)
(defconstant +faction-type-church+ 12)

(defconstant +specific-faction-type-dead-player+ -3)
(defconstant +specific-faction-type-test+ -2)
(defconstant +specific-faction-type-player+ -1)
(defconstant +specific-faction-type-angel-chrome+ 0)
(defconstant +specific-faction-type-angel-trinity+ 1)
(defconstant +specific-faction-type-demon-crimson+ 2)
(defconstant +specific-faction-type-demon-shadow+ 3)
(defconstant +specific-faction-type-demon-malseraph+ 4)
(defconstant +specific-faction-type-military-chaplain+ 5)
(defconstant +specific-faction-type-military-scout+ 6)
(defconstant +specific-faction-type-thief+ 7)
(defconstant +specific-faction-type-satanist+ 8)
(defconstant +specific-faction-type-priest+ 9)
(defconstant +specific-faction-type-eater+ 10)
(defconstant +specific-faction-type-ghost+ 11)
(defconstant +specific-faction-type-skinchanger+ 12)

;; The AI package id space - see define-trait-ids. Appending a name here is the
;; whole change needed to add one; (name :no-initarg) is for packages granted
;; by a mission rather than set on the mob type.
(define-trait-ids ai-package ai +ai-package-count+ *ai-package-specs*
  coward
  horde
  wants-bless
  takes-valuable-items
  curious
  kleptomaniac
  cautious
  trinity-mimic
  split-soul
  search-corpses
  use-ability
  use-item
  reload-ranged-weapon
  shoot-enemy
  follow-leader
  approach-target
  attack-nearest-enemy
  find-random-location
  (patrol-district :no-initarg)
  avoid-possession
  avoid-melee
  (pick-corpses :no-initarg)
  (return-corpses-to-portal :no-initarg)
  (search-relic :no-initarg)
  (pick-relic :no-initarg)
  (return-relic-to-portal :no-initarg)
  (find-sigil :no-initarg)
  (escape-with-relic :no-initarg)
  swim-up
  (find-machine :no-initarg)
  (find-bomb-plant-location :no-initarg))

(defconstant +ai-priority-never+ 0)
(defconstant +ai-priority-always+ 10)

;; The mob ability id space - see define-trait-ids. Appending a name here is
;; the whole change needed to add an ability; (name :no-initarg) is for
;; abilities granted by a mutation, mission or effect rather than set on the
;; mob type. These ids are hash keys inside saved games, so APPEND, never
;; insert or reorder.
(define-trait-ids mob-abil abil +mob-abil-count+ *mob-abil-specs*
  heal-self
  conceal-divine
  reveal-divine
  detect-good
  detect-evil
  possessable
  can-possess
  purging-touch
  blessing-touch
  can-be-blessed
  unholy
  angel
  demon
  human
  see-all
  lifesteal
  call-for-help
  answer-the-call
  loves-infighting
  prayer-bless
  free-call
  prayer-shield
  curse
  keen-senses
  prayer-reveal
  military-follow-me
  blindness
  instill-fear
  charge
  momentum
  animal
  horseback-riding
  horse-can-be-ridden
  dismount
  dominate-fiend
  fiend-can-be-ridden
  starts-with-horse
  independent
  eagle-eye
  facing
  immovable
  mind-burn
  gargantaur-teleport
  dominate-gargantaur
  gargantaurs-mind-burn
  death-from-above
  climbing
  no-breathe
  open-close-door
  toggle-light
  open-close-window
  can-possess-toggle
  sacrifice-host
  reanimate-corpse
  undead
  shared-minds
  empower-undead
  ignite-the-fire
  avatar-of-brilliance
  gravity-chains
  flying
  no-corpse
  smite
  slow
  prayer-wrath
  shadow-step
  extinguish-light
  umbral-aura
  trinity-mimic
  merge
  unmerge
  heal-other
  righteous-fury
  pain-link
  soul-reinforcement
  silence
  confuse
  split-soul
  restore-soul
  resurrection
  sprint
  jump
  bend-space
  cast-shadow
  cannibalize
  primordial
  make-disguise
  remove-disguise
  constriction
  irradiate
  fission
  adrenal-gland
  mutate-acid-spit
  mutate-corroding-secretion
  acid-spit
  corroding-secretion
  mutate-corrosive-bile
  mutate-accurate-bile
  corrosive-bile
  accurate-bile
  mutate-clawed-tentacle
  mutate-piercing-needles
  clawed-tentacle
  piercing-needles
  mutate-chitinous-plating
  mutate-thick-carapace
  chitinous-plating
  thick-carapace
  mutate-metabolic-boost
  mutate-jump
  metabolic-boost
  mutate-retracting-spines
  mutate-acidic-tips
  retracting-spines
  acidic-tips
  mutate-ovipositor
  oviposit
  create-parasites
  mutate-spawn-locusts
  spawn-locusts
  mutate-spawn-scarabs
  spawn-scarabs
  acid-explosion
  mutate-acid-locusts
  mutate-fast-scarabs
  mutate-oviposit-more-eggs
  mutate-tougher-locusts
  oviposit-more-eggs
  tougher-locusts
  acid-locusts
  fast-scarabs
  (regenerate :no-initarg)
  (casts-light :no-initarg)
  (vulnerable-to-vorpal :no-initarg)
  (vulnerable-to-fire :no-initarg)
  cure-mutation
  mutate-hooks-and-suckers
  mutate-disguise-as-human
  disguise-as-human
  mutate-spawn-larva
  spawn-larva
  mutate-spore-colony
  spore-colony
  immobile
  float
  ghost-possess
  invisibility
  passwall
  ghost-release
  decipher-rune
  demon-word-flesh
  demon-word-knockback
  demon-word-invasion
  demon-word-darkness
  demon-word-plague
  demon-word-power
  soul
  detect-unnatural
  throw-corpse-into-portal
  throw-relic-into-portal
  create-demon-sigil
  skinchange-to-melee
  skinchange-to-ranged
  skinchange-to-flyer
  mutate-skin-ranged-to-turret
  (skinchange-to-turret :no-initarg)
  mutate-charge
  mutate-explosive-glands
  (explosive-glands :no-initarg)
  mutate-poisoning-glands
  (poisoning-glands :no-initarg)
  purge-rune
  civilian
  deep-breath
  nameless
  strength-in-numbers
  coward)

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
(defconstant +mob-effect-demonic-sigil+ 56)
(defconstant +mob-effect-deep-breath+ 57)
(defconstant +mob-effect-demonic-machine+ 58)
(defconstant +mob-effect-bomb-ticking+ 59)
(defconstant +mob-effect-reduce-resitances+ 60)
(defconstant +mob-effect-strength-in-numbers+ 61)

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
(defconstant +item-type-church-reliс+ 25)
(defconstant +item-type-bomb+ 26)
 
;;--------------------
;; FEATURE-TYPE Constants
;;-------------------- 

;; The feature trait space - see define-trait-ids. Appending a name here is the
;; whole change needed to add a feature trait.
(define-trait-ids feature-trait trait +feature-trait-count+ *feature-trait-specs*
  blocks-vision
  smoke
  no-gravity
  fire
  remove-on-dungeon-generation
  demonic-rune)

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
(defconstant +feature-demonic-portal+ 22)
(defconstant +feature-start-place-relic+ 23)
(defconstant +feature-start-strong-repel-demons+ 24)
(defconstant +feature-start-sigil-point+ 25)
(defconstant +feature-corrupted-spores+ 26)
(defconstant +feature-smoke-acid-gas+ 27)
(defconstant +feature-start-place-church-priest+ 28)
(defconstant +feature-start-place-civilian-man+ 29)
(defconstant +feature-start-place-civilian-woman+ 30)
(defconstant +feature-start-place-civilian-child+ 31)
(defconstant +feature-start-place-book-of-rituals+ 32)
(defconstant +feature-arrival-point-north+ 33)
(defconstant +feature-arrival-point-south+ 34)
(defconstant +feature-arrival-point-west+ 35)
(defconstant +feature-arrival-point-east+ 36)
(defconstant +feature-start-place-demons+ 37)
(defconstant +feature-start-place-angels+ 38)
(defconstant +feature-start-place-military+ 39)
(defconstant +feature-delayed-demons-arrival-point+ 40)
(defconstant +feature-delayed-angels-arrival-point+ 41)
(defconstant +feature-delayed-military-arrival-point+ 42)
(defconstant +feature-start-machine-point+ 43)
(defconstant +feature-bomb-plant-target+ 44)
(defconstant +feature-smoke-weak-acid-gas+ 45)
(defconstant +feature-divine-portal+ 46)

;;--------------------
;; TERRAIN-TEMPLATE Constants
;;-------------------- 

(defconstant +level-city-park+ 0)
(defconstant +level-city-terrain-border+ 1)
(defconstant +level-city-terrain-dirt+ 2)
(defconstant +level-city-terrain-grass+ 3)
(defconstant +level-city-terrain-tree+ 4)
(defconstant +level-city-terrain-bush+ 5)
(defconstant +level-city-terrain-earth+ 6)

;; The terrain trait space. This list is its single definition: it generates the
;; +terrain-trait-*+ id constants, +terrain-trait-count+ (the second axis of
;; *terrain-trait-table*), and terrain-type's :trait-* initargs. Appending a
;; name here is the whole change needed to add a trait. A (name default) pair
;; gives that initarg a default value.
(define-trait-ids terrain-trait trait +terrain-trait-count+ *terrain-trait-specs*
  blocks-move
  blocks-vision
  blocks-projectiles
  blocks-move-floor
  slope-up
  slope-down
  not-climable
  light-source
  blocks-sound
  blocks-sound-floor
  water
  (move-cost-factor 1)
  openable-door
  openable-window
  flammable
  can-jump-over
  can-have-rune
  can-switch-light
  blocks-projectiles-floor
  blocks-vision-floor)

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
(defconstant +terrain-border-creep+ 52)
(defconstant +terrain-floor-creep+ 53)
(defconstant +terrain-floor-creep-bright+ 54)
(defconstant +terrain-tree-twintube+ 55)
(defconstant +terrain-tree-twintube-trunk+ 56)
(defconstant +terrain-floor-twintube-branches+ 57)
(defconstant +terrain-wall-gloomtwigs+ 58)
(defconstant +terrain-wall-corrupted+ 59)
(defconstant +terrain-floor-creep-dreadtubes+ 60)
(defconstant +terrain-floor-creep-spores+ 61)
(defconstant +terrain-wall-razorthorns+ 62)
(defconstant +terrain-floor-creep-glowshroom+ 63)
(defconstant +terrain-floor-creep-irradiated+ 64)
(defconstant +terrain-wall-compressed-bones+ 65)
(defconstant +terrain-floor-glass+ 66)
(defconstant +terrain-wall-raw-flesh+ 67)
(defconstant +terrain-floor-slime+ 68)
(defconstant +terrain-wall-ice+ 69)

;;--------------------
;; GOD Constants
;;--------------------

(defconstant +god-entity-malseraph+ 0)

;;--------------------
;; OBJECTIVE-TYPE Constants
;;--------------------

(defconstant +objective-demon-attack-attacker+ 0)
(defconstant +objective-demon-attack-defender+ 1)
(defconstant +objective-demon-attack-eater+ 2)
(defconstant +objective-demon-attack-thief+ 3)
(defconstant +objective-demon-attack-ghost+ 4)
(defconstant +objective-demon-attack-scout+ 5)

;;--------------------
;; Template Globals
;;--------------------

(defparameter *faction-table* (make-hash-table))
(defparameter *specific-faction-names* (make-hash-table))
(defparameter *ability-types* (make-array (list 0) :adjustable t))
(defparameter *feature-types* (make-array (list 0) :adjustable t))
(defparameter *terrain-types* (make-array (list 0) :adjustable t))

;; Flat [terrain-type-id][trait-id] mirror of every terrain type's trait table,
;; maintained by set-terrain-type and read by get-terrain-type-trait. A simple
;; array rather than a slot on terrain-type reached through *terrain-types*:
;; *terrain-types* is adjustable, so an aref on it cannot be open-coded, and
;; that lookup dominated the trait read. ~360 call sites, all of them inside
;; the FOV, pathfinding and connectivity-map loops.
(defparameter *terrain-trait-table* (make-array (list 0 0)))
(defparameter *mob-types* (make-array (list 0) :adjustable t))
(defparameter *item-types* (make-array (list 0) :adjustable t))
(defparameter *effect-types* (make-array (list 0) :adjustable t))
(defparameter *card-types* (make-array (list 0) :adjustable t))
(defparameter *gods* (make-array (list 0) :adjustable t))
(defparameter *ai-packages* (make-array (list 0) :adjustable t))
(defparameter *faction-types* (make-array (list 0) :initial-element nil :adjustable t))
(defparameter *objective-types* (make-array (list 0) :adjustable t))

;;--------------------
;; Actual Game Globals
;;--------------------

(defparameter *lvl-features* (make-array (list 0) :adjustable t))
(defparameter *mobs* (make-array (list 0) :adjustable t))
(defparameter *items* (make-array (list 0) :adjustable t))
(defparameter *effects* (make-array (list 0) :adjustable t))
(defparameter *world* nil)
(defparameter *player* nil)
(defparameter *game-manager* nil)
(defparameter *player-name* nil)
(defparameter *player-title* nil)

(defvar *update-screen-closure*)
(defvar *cur-progress-bar*)
(defvar *max-progress-bar*)

;; *cur-progress-bar* is bumped from the connectivity-map worker threads during
;; level generation, so the increment needs guarding - two unsynchronised incfs
;; lose updates. The workers must not draw: SDL 1.2 rendering is not
;; thread-safe, so only the thread that owns the screen calls
;; *update-screen-closure*.
(defparameter *progress-bar-lock* (bt:make-lock "progress bar"))

(defun bump-progress-bar ()
  "Advance the loading progress bar by one step. Safe to call from any thread."
  (bt:with-lock-held (*progress-bar-lock*)
    (incf *cur-progress-bar*)))

(defparameter *current-dir* (asdf:system-source-directory :cotd))
(defparameter *campaign-saves-pathlist* (list "saves" "campaign"))
(defparameter *scenario-saves-pathlist* (list "saves" "scenario"))
(defparameter *save-final-base-dirname* "save")
(defparameter *save-descr-filename* "descr")
(defparameter *save-game-filename* "game")
(defparameter *highscores-filename* "scenario-highscores")

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
(defparameter *demonic-conquest-win-sigils-dist* 35)

(defparameter *max-oxygen-level* 5)
(defparameter *lack-oxygen-dmg* 5)

(defparameter *repel-demons-dist* 5)
(defparameter *repel-demons-dist-strong* 15)

(defparameter *min-angels-number* 10)
(defparameter *min-imps-number* 10)
(defparameter *max-imps-number* 26)

(defparameter *shared-mind-msg-color* (sdl:color :r 0 :g 128 :b 128))

;; Colours used per-cell while updating the player's field of view. These are
;; read-only and shared: sdl:color is a CLOS object wrapping a CFFI-allocated
;; SDL_Color with a finalizer, so constructing them inline once per cell per
;; sweep (update-visible-area walks the entire memo array) was pure garbage.
(defparameter *fov-deep-water-color* (sdl:color :r 0 :g 0 :b 128))
(defparameter *fov-dim-light-color* (sdl:color :r 25 :g 25 :b 112))
(defparameter *memo-remembered-color* (sdl:color :r 50 :g 50 :b 50))

(defparameter *water-move-factor* 1.5)

(defconstant +connect-room-none+ -1)

(defparameter *previous-scenario* nil)

;; Connect map indices for various movement types
;; Movement modes. These index the fourth axis of a connect map, so the count
;; comes from the list - see define-trait-ids.
(define-trait-ids connect-map-move move +connect-map-move-count+ *connect-map-move-specs*
  walk
  climb
  fly)

(defenum:defenum log-options-enum (:log-option-all
                                   :log-option-file
                                   :log-option-none))

(defvar *cotd-release* nil)
(defparameter *cotd-logging* :log-option-all)
(defparameter *cotd-log-level* :info)

;;---------------------------
;; Multithreading parameters
;;--------------------------- 


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

(defparameter *start-map-x* 190)
