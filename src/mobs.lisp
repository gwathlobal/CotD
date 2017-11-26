(in-package :cotd)

;;----------------------
;; MOB-TYPE
;;----------------------

(defclass mob-type ()
  ((glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name mob" :initarg :name :accessor name)
   
   (faction :initform +faction-type-none+ :initarg :faction :accessor faction)
   (mob-type :initarg :mob-type :accessor mob-type)
   (evolve-mob-id :initform nil :initarg :evolve-mob-id :accessor evolve-mob-id)
   (map-size :initform 1 :initarg :map-size :accessor map-size)  ;; can take odd mumbers only, because there should always be a center
   
   (max-hp :initform 1 :initarg :max-hp :accessor max-hp)
   (max-fp :initform 1 :initarg :max-fp :accessor max-fp)
   (max-ap :initform +normal-ap+ :initarg :max-ap :accessor max-ap)

   (strength :initform 0 :initarg :strength :accessor strength) ;; relative mob strength for AI to assess its chances
   (ai-prefs :initform (make-hash-table) :accessor ai-prefs)
   ;; The following keys may be used in make-instance
   ;;   :ai-coward - mob will flee if there are enemies in sight
   ;;   :ai-horde  - mob will attack only if the relative strength of allies in sight is more than the relative strength of enemies, otherwise it will flee
   ;;   :ai-wants-bless - mob will get to the nearest ally and bless it
   ;;   :ai-stop   - mob will stop all movement whenever it see an enemy
   ;;   :ai-curious - mob will try to investigate sounds if it has nothing to do
   ;;   :ai-kleptomaniac - mob will try to collect as much valuable items as possible
   ;;   :ai-cautious - mob will not attack smb of higher strength
   ;;   :ai-simple-pathfinding - mob will not use Astar pathfinding and will move in the general direction towards the target
   ;;   :ai-cannibal - mob will try to go to the nearest corpse
   ;;   :ai-trinity-mimic
   ;;   :ai-split-soul
      
   (abilities :initform (make-hash-table) :accessor abilities)
   ;; The pattern of naming keys that may be used in make-instance is like <name of mob ability constant> minus the 'mob-' part
   ;; For example,
   ;;   :abil-conceal-divine - +mob-abil-conceal-divine+
   ;; Usually the key takes a boolean parameter with the exception of the following cases
   ;;   :abil-heal-self - +mob-abil-heal-self+ (takes fixnum)
   ;;   :abil-can-possess - +mob-abil-can-possess+ (takes fixnum)
   ;;   :abil-momentum - +mob-abil-momentum+ (takes fixnum)
   ;;   :abil-instill-fear - +mob-abil-instill-fear+ (takes fixnum)
   ;;   :abil-heal-other - +mob-abil-heal-other+ (takes fixnum)
   
   (weapon :initform nil :initarg :weapon :accessor weapon)
   ;; of type (<weapon name> (<dmg-type> <dmg min> <dmg max> <attack speed> <accuracy> <list of aux params>)
   ;;                        (<dmg-type> <dmg min> <dmg max> <attack speed> <max charges> <rate of fire> <accuracy> <shoot str> <list of aux params>))
   ;; <list of aux params> may contain
   ;;   :chops-body-parts
   ;;   :is-fire
   ;;   :constricts
   ;;   :no-charges
   ;;   :corrodes
   
   (armor :initform nil :accessor armor) ;; for initarg - ((<dmg-type> <direct-reduct> <%-reduct>) ...), while inside it is an array of lists
   (base-sight :initform *base-mob-sight* :initarg :base-sight :accessor base-sight)
   (base-dodge :initform 5 :initarg :base-dodge :accessor base-dodge)
   (base-armor :initform 0 :initarg :base-armor :accessor base-armor)
   (move-spd :initform +normal-ap+ :initarg :move-spd :accessor move-spd)
   (base-light-radius :initform *base-light-radius* :initarg :base-light-radius :accessor base-light-radius)
   (base-stealth :initform 0 :initarg :base-stealth :accessor base-stealth)

   (init-items :initform nil :initarg :init-items :accessor init-items)  ;; for initarg - ((<item-type-id> <item-qty>) ...)
   ))

(defmethod initialize-instance :after ((mob-type mob-type) &key armor
                                                                ai-coward ai-horde ai-wants-bless ai-stop ai-curious ai-kleptomaniac ai-cautious ai-simple-pathfinding ai-trinity-mimic ai-split-soul ai-cannibal
                                                                abil-can-possess abil-possessable abil-purging-touch abil-blessing-touch abil-can-be-blessed abil-unholy 
                                                                abil-heal-self abil-conceal-divine abil-reveal-divine abil-detect-good abil-detect-evil
                                                                abil-human abil-demon abil-angel abil-see-all abil-lifesteal abil-call-for-help abil-answer-the-call
                                                                abil-loves-infighting abil-prayer-bless abil-free-call abil-prayer-shield abil-curse
                                                                abil-keen-senses abil-prayer-reveal abil-military-follow-me abil-blindness abil-instill-fear abil-charge
                                                                abil-momentum abil-animal abil-horseback-riding abil-horse-can-be-ridden abil-dismount abil-dominate-fiend abil-fiend-can-be-ridden
                                                                abil-starts-with-horse abil-independent abil-eagle-eye abil-facing abil-immovable abil-mind-burn abil-gargantaur-teleport abil-dominate-gargantaur
                                                                abil-gargantaurs-mind-burn abil-death-from-above abil-climbing abil-no-breathe abil-open-close-door abil-toggle-light abil-open-close-window
                                                                abil-can-possess-toggle abil-sacrifice-host abil-reanimate-corpse abil-undead abil-shared-minds abil-ignite-the-fire abil-avatar-of-brilliance
                                                                abil-empower-undead abil-gravity-chains abil-flying abil-no-corpse abil-smite abil-slow abil-prayer-wrath abil-shadow-step abil-extinguish-light abil-umbral-aura
                                                                abil-trinity-mimic abil-merge abil-unmerge abil-heal-other abil-righteous-fury abil-pain-link abil-soul-reinforcement abil-silence abil-confuse
                                                                abil-split-soul abil-restore-soul abil-resurrection abil-sprint abil-jump abil-bend-space abil-cast-shadow abil-cannibalize abil-primordial
                                                                abil-make-disguise abil-remove-disguise abil-constriction abil-irradiate abil-fission abil-create-parasites abil-mutate-acid-spit abil-acid-spit
                                                                abil-adrenal-gland abil-mutate-corrosive-bile abil-corrosive-bile abil-mutate-clawed-tentacle abil-clawed-tentacle abil-mutate-chitinous-plating abil-chitinous-plating
                                                                abil-mutate-metabolic-boost abil-metabolic-boost abil-mutate-retracting-spines abil-retracting-spines abil-spawn-locusts abil-mutate-spawn-locusts
                                                                abil-mutate-ovipositor abil-oviposit abil-acid-explosion abil-mutate-acid-locusts abil-acid-locusts abil-mutate-fast-scarabs abil-fast-scarabs
                                                                abil-mutate-oviposit-more-eggs abil-oviposit-more-eggs abil-mutate-tougher-locusts abil-tougher-locusts abil-cure-mutation abil-mutate-thick-carapace abil-thick-carapace
                                                                abil-mutate-acidic-tips abil-acidic-tips abil-mutate-jump abil-mutate-piercing-needles abil-piercing-needles abil-mutate-corroding-secretion abil-corroding-secretion
                                                                abil-mutate-accurate-bile abil-accurate-bile abil-mutate-hooks-and-suckers abil-mutate-disguise-as-human abil-disguise-as-human abil-spawn-scarabs
                                                                abil-mutate-spawn-scarabs)
  ;; set up armor
  (setf (armor mob-type) (make-array (list 7) :initial-element nil))
  (loop for (dmg-type dir-resist %-resist) in armor do
    (setf (aref (armor mob-type) dmg-type) (list dir-resist %-resist)))
  
  ;; set up AI prefs
  (when ai-coward
    (setf (gethash +ai-pref-coward+ (ai-prefs mob-type)) t))
  (when ai-horde
    (setf (gethash +ai-pref-horde+ (ai-prefs mob-type)) t))
  (when ai-wants-bless
    (setf (gethash +ai-pref-wants-bless+ (ai-prefs mob-type)) t))
  (when ai-stop
    (setf (gethash +ai-pref-stop+ (ai-prefs mob-type)) t))
  (when ai-curious
    (setf (gethash +ai-pref-curious+ (ai-prefs mob-type)) t))
  (when ai-kleptomaniac
    (setf (gethash +ai-pref-kleptomaniac+ (ai-prefs mob-type)) t))
  (when ai-cautious
    (setf (gethash +ai-pref-cautious+ (ai-prefs mob-type)) t))
  (when ai-simple-pathfinding
    (setf (gethash +ai-pref-simple-pathfinding+ (ai-prefs mob-type)) t))
  (when ai-trinity-mimic
    (setf (gethash +ai-pref-trinity-mimic+ (ai-prefs mob-type)) t))
  (when ai-split-soul
    (setf (gethash +ai-pref-split-soul+ (ai-prefs mob-type)) t))
  (when ai-cannibal
    (setf (gethash +ai-pref-cannibal+ (ai-prefs mob-type)) t))

  ;; set up abilities
  (when abil-can-possess
    (setf (gethash +mob-abil-can-possess+ (abilities mob-type)) abil-can-possess))
  (when abil-possessable
    (setf (gethash +mob-abil-possessable+ (abilities mob-type)) t))
  (when abil-purging-touch
    (setf (gethash +mob-abil-purging-touch+ (abilities mob-type)) t))
  (when abil-blessing-touch
    (setf (gethash +mob-abil-blessing-touch+ (abilities mob-type)) t))
  (when abil-can-be-blessed
    (setf (gethash +mob-abil-can-be-blessed+ (abilities mob-type)) t))
  (when abil-unholy
    (setf (gethash +mob-abil-unholy+ (abilities mob-type)) t))
  (when abil-heal-self
    (setf (gethash +mob-abil-heal-self+ (abilities mob-type)) abil-heal-self))
  (when abil-conceal-divine
    (setf (gethash +mob-abil-conceal-divine+ (abilities mob-type)) t))
  (when abil-reveal-divine
    (setf (gethash +mob-abil-reveal-divine+ (abilities mob-type)) t))
  (when abil-detect-good
    (setf (gethash +mob-abil-detect-good+ (abilities mob-type)) t))
  (when abil-detect-evil
    (setf (gethash +mob-abil-detect-evil+ (abilities mob-type)) t))
  (when abil-human
    (setf (gethash +mob-abil-human+ (abilities mob-type)) t))
  (when abil-angel
    (setf (gethash +mob-abil-angel+ (abilities mob-type)) t))
  (when abil-demon
    (setf (gethash +mob-abil-demon+ (abilities mob-type)) t))
  (when abil-see-all
    (setf (gethash +mob-abil-see-all+ (abilities mob-type)) t))
  (when abil-lifesteal
    (setf (gethash +mob-abil-lifesteal+ (abilities mob-type)) t))
  (when abil-call-for-help
    (setf (gethash +mob-abil-call-for-help+ (abilities mob-type)) t))
  (when abil-answer-the-call
    (setf (gethash +mob-abil-answer-the-call+ (abilities mob-type)) t))
  (when abil-loves-infighting
    (setf (gethash +mob-abil-loves-infighting+ (abilities mob-type)) t))
  (when abil-prayer-bless
    (setf (gethash +mob-abil-prayer-bless+ (abilities mob-type)) t))
  (when abil-free-call
    (setf (gethash +mob-abil-free-call+ (abilities mob-type)) t))
  (when abil-prayer-shield
    (setf (gethash +mob-abil-prayer-shield+ (abilities mob-type)) t))
  (when abil-curse
    (setf (gethash +mob-abil-curse+ (abilities mob-type)) t))
  (when abil-keen-senses
    (setf (gethash +mob-abil-keen-senses+ (abilities mob-type)) t))
  (when abil-prayer-reveal
    (setf (gethash +mob-abil-prayer-reveal+ (abilities mob-type)) t))
  (when abil-military-follow-me
    (setf (gethash +mob-abil-military-follow-me+ (abilities mob-type)) t))
  (when abil-blindness
    (setf (gethash +mob-abil-blindness+ (abilities mob-type)) t))
  (when abil-instill-fear
    (setf (gethash +mob-abil-instill-fear+ (abilities mob-type)) abil-instill-fear))
  (when abil-charge
    (setf (gethash +mob-abil-charge+ (abilities mob-type)) t))
  (when abil-momentum
    (setf (gethash +mob-abil-momentum+ (abilities mob-type)) abil-momentum))
  (when abil-animal
    (setf (gethash +mob-abil-animal+ (abilities mob-type)) t))
  (when abil-horseback-riding
    (setf (gethash +mob-abil-horseback-riding+ (abilities mob-type)) t))
  (when abil-horse-can-be-ridden
    (setf (gethash +mob-abil-horse-can-be-ridden+ (abilities mob-type)) t))
  (when abil-dismount
    (setf (gethash +mob-abil-dismount+ (abilities mob-type)) t))
  (when abil-dominate-fiend
    (setf (gethash +mob-abil-dominate-fiend+ (abilities mob-type)) t))
  (when abil-fiend-can-be-ridden
    (setf (gethash +mob-abil-fiend-can-be-ridden+ (abilities mob-type)) t))
  (when abil-starts-with-horse
    (setf (gethash +mob-abil-starts-with-horse+ (abilities mob-type)) t))
  (when abil-independent
    (setf (gethash +mob-abil-independent+ (abilities mob-type)) t))
  (when abil-eagle-eye
    (setf (gethash +mob-abil-eagle-eye+ (abilities mob-type)) t))
  (when abil-facing
    (setf (gethash +mob-abil-facing+ (abilities mob-type)) t))
  (when abil-immovable
    (setf (gethash +mob-abil-immovable+ (abilities mob-type)) t))
  (when abil-mind-burn
    (setf (gethash +mob-abil-mind-burn+ (abilities mob-type)) t))
  (when abil-gargantaur-teleport
    (setf (gethash +mob-abil-gargantaur-teleport+ (abilities mob-type)) t))
  (when abil-dominate-gargantaur
    (setf (gethash +mob-abil-dominate-gargantaur+ (abilities mob-type)) t))
  (when abil-gargantaurs-mind-burn
    (setf (gethash +mob-abil-gargantaurs-mind-burn+ (abilities mob-type)) t))
  (when abil-death-from-above
    (setf (gethash +mob-abil-death-from-above+ (abilities mob-type)) t))
  (when abil-climbing
    (setf (gethash +mob-abil-climbing+ (abilities mob-type)) t))
  (when abil-no-breathe
    (setf (gethash +mob-abil-no-breathe+ (abilities mob-type)) t))
  (when abil-open-close-door
    (setf (gethash +mob-abil-open-close-door+ (abilities mob-type)) t))
  (when abil-toggle-light
    (setf (gethash +mob-abil-toggle-light+ (abilities mob-type)) t))
  (when abil-open-close-window
    (setf (gethash +mob-abil-open-close-window+ (abilities mob-type)) t))
  (when abil-can-possess-toggle
    (setf (gethash +mob-abil-can-possess-toggle+ (abilities mob-type)) t))
  (when abil-sacrifice-host
    (setf (gethash +mob-abil-sacrifice-host+ (abilities mob-type)) t))
  (when abil-reanimate-corpse
    (setf (gethash +mob-abil-reanimate-corpse+ (abilities mob-type)) t))
  (when abil-undead
    (setf (gethash +mob-abil-undead+ (abilities mob-type)) t))
  (when abil-shared-minds
    (setf (gethash +mob-abil-shared-minds+ (abilities mob-type)) t))
  (when abil-ignite-the-fire
    (setf (gethash +mob-abil-ignite-the-fire+ (abilities mob-type)) t))
  (when abil-avatar-of-brilliance
    (setf (gethash +mob-abil-avatar-of-brilliance+ (abilities mob-type)) t))
  (when abil-empower-undead
    (setf (gethash +mob-abil-empower-undead+ (abilities mob-type)) t))
  (when abil-gravity-chains
    (setf (gethash +mob-abil-gravity-chains+ (abilities mob-type)) t))
  (when abil-flying
    (setf (gethash +mob-abil-flying+ (abilities mob-type)) t))
  (when abil-no-corpse
    (setf (gethash +mob-abil-no-corpse+ (abilities mob-type)) t))
  (when abil-smite
    (setf (gethash +mob-abil-smite+ (abilities mob-type)) t))
  (when abil-slow
    (setf (gethash +mob-abil-slow+ (abilities mob-type)) t))
  (when abil-prayer-wrath
    (setf (gethash +mob-abil-prayer-wrath+ (abilities mob-type)) t))
  (when abil-shadow-step
    (setf (gethash +mob-abil-shadow-step+ (abilities mob-type)) t))
  (when abil-extinguish-light
    (setf (gethash +mob-abil-extinguish-light+ (abilities mob-type)) t))
  (when abil-umbral-aura
    (setf (gethash +mob-abil-umbral-aura+ (abilities mob-type)) t))
  (when abil-trinity-mimic
    (setf (gethash +mob-abil-trinity-mimic+ (abilities mob-type)) t))
  (when abil-merge
    (setf (gethash +mob-abil-merge+ (abilities mob-type)) t))
  (when abil-unmerge
    (setf (gethash +mob-abil-unmerge+ (abilities mob-type)) t))
  (when abil-heal-other
    (setf (gethash +mob-abil-heal-other+ (abilities mob-type)) abil-heal-other))
  (when abil-righteous-fury
    (setf (gethash +mob-abil-righteous-fury+ (abilities mob-type)) t))
  (when abil-pain-link
    (setf (gethash +mob-abil-pain-link+ (abilities mob-type)) t))
  (when abil-soul-reinforcement
    (setf (gethash +mob-abil-soul-reinforcement+ (abilities mob-type)) t))
  (when abil-silence
    (setf (gethash +mob-abil-silence+ (abilities mob-type)) t))
  (when abil-confuse
    (setf (gethash +mob-abil-confuse+ (abilities mob-type)) t))
  (when abil-split-soul
    (setf (gethash +mob-abil-split-soul+ (abilities mob-type)) t))
  (when abil-restore-soul
    (setf (gethash +mob-abil-restore-soul+ (abilities mob-type)) t))
  (when abil-resurrection
    (setf (gethash +mob-abil-resurrection+ (abilities mob-type)) t))
  (when abil-sprint
    (setf (gethash +mob-abil-sprint+ (abilities mob-type)) t))
  (when abil-jump
    (setf (gethash +mob-abil-jump+ (abilities mob-type)) t))
  (when abil-bend-space
    (setf (gethash +mob-abil-bend-space+ (abilities mob-type)) t))
  (when abil-cast-shadow
    (setf (gethash +mob-abil-cast-shadow+ (abilities mob-type)) t))
  (when abil-cannibalize
    (setf (gethash +mob-abil-cannibalize+ (abilities mob-type)) t))
  (when abil-primordial
    (setf (gethash +mob-abil-primordial+ (abilities mob-type)) t))
  (when abil-make-disguise
    (setf (gethash +mob-abil-make-disguise+ (abilities mob-type)) t))
  (when abil-remove-disguise
    (setf (gethash +mob-abil-remove-disguise+ (abilities mob-type)) t))
  (when abil-constriction
    (setf (gethash +mob-abil-constriction+ (abilities mob-type)) t))
  (when abil-irradiate
    (setf (gethash +mob-abil-irradiate+ (abilities mob-type)) t))
  (when abil-fission
    (setf (gethash +mob-abil-fission+ (abilities mob-type)) t))
  (when abil-create-parasites
    (setf (gethash +mob-abil-create-parasites+ (abilities mob-type)) t))
  (when abil-adrenal-gland
    (setf (gethash +mob-abil-adrenal-gland+ (abilities mob-type)) t))
  (when abil-mutate-acid-spit
    (setf (gethash +mob-abil-mutate-acid-spit+ (abilities mob-type)) t))
  (when abil-acid-spit
    (setf (gethash +mob-abil-acid-spit+ (abilities mob-type)) t))
  (when abil-mutate-corrosive-bile
    (setf (gethash +mob-abil-mutate-corrosive-bile+ (abilities mob-type)) t))
  (when abil-corrosive-bile
    (setf (gethash +mob-abil-corrosive-bile+ (abilities mob-type)) t))
  (when abil-mutate-clawed-tentacle
    (setf (gethash +mob-abil-mutate-clawed-tentacle+ (abilities mob-type)) t))
  (when abil-clawed-tentacle
    (setf (gethash +mob-abil-clawed-tentacle+ (abilities mob-type)) t))
  (when abil-mutate-chitinous-plating
    (setf (gethash +mob-abil-mutate-chitinous-plating+ (abilities mob-type)) t))
  (when abil-chitinous-plating
    (setf (gethash +mob-abil-chitinous-plating+ (abilities mob-type)) t))
  (when abil-mutate-metabolic-boost
    (setf (gethash +mob-abil-mutate-metabolic-boost+ (abilities mob-type)) t))
  (when abil-metabolic-boost
    (setf (gethash +mob-abil-metabolic-boost+ (abilities mob-type)) t))
  (when abil-mutate-retracting-spines
    (setf (gethash +mob-abil-mutate-retracting-spines+ (abilities mob-type)) t))
  (when abil-retracting-spines
    (setf (gethash +mob-abil-retracting-spines+ (abilities mob-type)) t))
  (when abil-mutate-spawn-locusts
    (setf (gethash +mob-abil-mutate-spawn-locusts+ (abilities mob-type)) t))
  (when abil-spawn-locusts
    (setf (gethash +mob-abil-spawn-locusts+ (abilities mob-type)) t))
  (when abil-mutate-ovipositor
    (setf (gethash +mob-abil-mutate-ovipositor+ (abilities mob-type)) t))
  (when abil-oviposit
    (setf (gethash +mob-abil-oviposit+ (abilities mob-type)) t))
  (when abil-acid-explosion
    (setf (gethash +mob-abil-acid-explosion+ (abilities mob-type)) t))
  (when abil-mutate-acid-locusts
    (setf (gethash +mob-abil-mutate-acid-locusts+ (abilities mob-type)) t))
  (when abil-acid-locusts
    (setf (gethash +mob-abil-acid-locusts+ (abilities mob-type)) t))
  (when abil-mutate-fast-scarabs
    (setf (gethash +mob-abil-mutate-fast-scarabs+ (abilities mob-type)) t))
  (when abil-fast-scarabs
    (setf (gethash +mob-abil-fast-scarabs+ (abilities mob-type)) t))
  (when abil-mutate-oviposit-more-eggs
    (setf (gethash +mob-abil-mutate-oviposit-more-eggs+ (abilities mob-type)) t))
  (when abil-oviposit-more-eggs
    (setf (gethash +mob-abil-oviposit-more-eggs+ (abilities mob-type)) t))
  (when abil-mutate-tougher-locusts
    (setf (gethash +mob-abil-mutate-tougher-locusts+ (abilities mob-type)) t))
  (when abil-tougher-locusts
    (setf (gethash +mob-abil-tougher-locusts+ (abilities mob-type)) t))
  (when abil-cure-mutation
    (setf (gethash +mob-abil-cure-mutation+ (abilities mob-type)) t))
  (when abil-mutate-thick-carapace
    (setf (gethash +mob-abil-mutate-thick-carapace+ (abilities mob-type)) t))
  (when abil-thick-carapace
    (setf (gethash +mob-abil-thick-carapace+ (abilities mob-type)) t))
  (when abil-mutate-acidic-tips
    (setf (gethash +mob-abil-mutate-acidic-tips+ (abilities mob-type)) t))
  (when abil-acidic-tips
    (setf (gethash +mob-abil-acidic-tips+ (abilities mob-type)) t))
  (when abil-mutate-jump
    (setf (gethash +mob-abil-mutate-jump+ (abilities mob-type)) t))
  (when abil-mutate-piercing-needles
    (setf (gethash +mob-abil-mutate-piercing-needles+ (abilities mob-type)) t))
  (when abil-piercing-needles
    (setf (gethash +mob-abil-piercing-needles+ (abilities mob-type)) t))
  (when abil-mutate-corroding-secretion
    (setf (gethash +mob-abil-mutate-corroding-secretion+ (abilities mob-type)) t))
  (when abil-corroding-secretion
    (setf (gethash +mob-abil-corroding-secretion+ (abilities mob-type)) t))
  (when abil-mutate-accurate-bile
    (setf (gethash +mob-abil-mutate-accurate-bile+ (abilities mob-type)) t))
  (when abil-accurate-bile
    (setf (gethash +mob-abil-accurate-bile+ (abilities mob-type)) t))
  (when abil-mutate-hooks-and-suckers
    (setf (gethash +mob-abil-mutate-hooks-and-suckers+ (abilities mob-type)) t))
  (when abil-mutate-disguise-as-human
    (setf (gethash +mob-abil-mutate-disguise-as-human+ (abilities mob-type)) t))
  (when abil-disguise-as-human
    (setf (gethash +mob-abil-disguise-as-human+ (abilities mob-type)) t))
  (when abil-spawn-scarabs
    (setf (gethash +mob-abil-spawn-scarabs+ (abilities mob-type)) t))
  (when abil-mutate-spawn-scarabs
    (setf (gethash +mob-abil-mutate-spawn-scarabs+ (abilities mob-type)) t))
  )

(defun get-mob-type-by-id (mob-type-id)
  (aref *mob-types* mob-type-id))

(defun set-mob-type (mob-type)
  (when (>= (mob-type mob-type) (length *mob-types*))
    (adjust-array *mob-types* (list (1+ (mob-type mob-type)))))
  (setf (aref *mob-types* (mob-type mob-type)) mob-type))

(defmethod get-weapon-name ((mob-type mob-type))
  (get-weapon-name-simple (weapon mob-type)))

(defun get-weapon-name-simple (weapon)
  (first weapon))

(defmethod is-weapon-melee ((mob-type mob-type))
  (is-weapon-melee-simple (weapon mob-type)))

(defun is-weapon-melee-simple (weapon)
  (if (second weapon)
    t
    nil))

(defmethod get-melee-weapon-dmg-type ((mob-type mob-type))
  (get-melee-weapon-dmg-type-simple (weapon mob-type)))

(defun get-melee-weapon-dmg-type-simple (weapon)
  (when (second weapon)
    (nth 0 (second weapon))))

(defmethod get-melee-weapon-dmg-min ((mob-type mob-type))
  (get-melee-weapon-dmg-min-simple (weapon mob-type)))

(defun get-melee-weapon-dmg-min-simple (weapon)
  (when (second weapon)
    (nth 1 (second weapon))))

(defmethod get-melee-weapon-dmg-max ((mob-type mob-type))
  (get-melee-weapon-dmg-max-simple (weapon mob-type)))

(defun get-melee-weapon-dmg-max-simple (weapon)
  (when (second weapon)
    (nth 2 (second weapon))))

(defmethod get-melee-weapon-speed ((mob-type mob-type))
  (get-melee-weapon-speed-simple (weapon mob-type)))

(defun get-melee-weapon-speed-simple (weapon)
  (when (second weapon)
    (nth 3 (second weapon))))

(defmethod get-melee-weapon-acc ((mob-type mob-type))
  (get-melee-weapon-acc-simple (weapon mob-type)))

(defun get-melee-weapon-acc-simple (weapon)
  (when (second weapon)
    (nth 4 (second weapon))))

(defmethod get-melee-weapon-aux ((mob-type mob-type))
  (get-melee-weapon-aux-simple (weapon mob-type)))

(defun get-melee-weapon-aux-simple (weapon)
  (when (second weapon)
    (nth 5 (second weapon))))

(defmethod get-melee-weapon-aux-param ((mob-type mob-type) aux-feature)
  (get-melee-weapon-aux-param-simple (weapon mob-type) aux-feature))

(defun get-melee-weapon-aux-param-simple (weapon aux-feature)
  (when (second weapon)
    (find aux-feature (nth 5 (second weapon)))))

(defmethod is-weapon-ranged ((mob-type mob-type))
  (is-weapon-ranged-simple (weapon mob-type)))

(defun is-weapon-ranged-simple (weapon)
  (if (third weapon)
    t
    nil))

(defmethod get-ranged-weapon-dmg-type ((mob-type mob-type))
  (get-ranged-weapon-dmg-type-simple (weapon mob-type)))

(defun get-ranged-weapon-dmg-type-simple (weapon)
  (when (third weapon)
    (nth 0 (third weapon))))

(defmethod get-ranged-weapon-dmg-min ((mob-type mob-type))
  (get-ranged-weapon-dmg-min-simple (weapon mob-type)))

(defun get-ranged-weapon-dmg-min-simple (weapon)
  (when (third weapon)
    (nth 1 (third weapon))))

(defmethod get-ranged-weapon-dmg-max ((mob-type mob-type))
  (get-ranged-weapon-dmg-max-simple (weapon mob-type)))

(defun get-ranged-weapon-dmg-max-simple (weapon)
  (when (third weapon)
    (nth 2 (third weapon))))

(defmethod get-ranged-weapon-speed ((mob-type mob-type))
  (get-ranged-weapon-speed-simple (weapon mob-type)))

(defun get-ranged-weapon-speed-simple (weapon)
  (when (third weapon)
    (nth 3 (third weapon))))

(defmethod get-ranged-weapon-charges ((mob-type mob-type))
  (get-ranged-weapon-charges-simple (weapon mob-type)))

(defun get-ranged-weapon-charges-simple (weapon)
  (when (third weapon)
    (nth 4 (third weapon))))

(defmethod get-ranged-weapon-rof ((mob-type mob-type))
  ;; rate of fire - the number of charges the weapon consumes per shoot 
  (get-ranged-weapon-rof-simple (weapon mob-type)))

(defun get-ranged-weapon-rof-simple (weapon)
  ;; rate of fire - the number of charges the weapon consumes per shoot 
  (when (third weapon)
    (nth 5 (third weapon))))

(defmethod get-ranged-weapon-acc ((mob-type mob-type))
  (get-ranged-weapon-acc-simple (weapon mob-type)))

(defun get-ranged-weapon-acc-simple (weapon)
  (when (third weapon)
    (nth 6 (third weapon))))

(defmethod get-ranged-weapon-shoot-str ((mob-type mob-type))
  (get-ranged-weapon-shoot-str-simple (weapon mob-type)))

(defun get-ranged-weapon-shoot-str-simple (weapon)
  (when (third weapon)
    (nth 7 (third weapon))))

(defmethod get-ranged-weapon-aux ((mob-type mob-type))
  (get-ranged-weapon-aux-simple (weapon mob-type)))

(defun get-ranged-weapon-aux-simple (weapon)
  (when (third weapon)
    (nth 8 (third weapon))))

(defmethod get-ranged-weapon-aux-param ((mob-type mob-type) aux-feature)
  (get-ranged-weapon-aux-param-simple (weapon mob-type) aux-feature))

(defun get-ranged-weapon-aux-param-simple (weapon aux-feature)
  (when (third weapon)
    (find aux-feature (nth 8 (third weapon)))))

(defmethod get-weapon-descr-line ((mob-type mob-type))
  (let ((str (create-string)))
    (format str "~A" (get-weapon-name mob-type))
    (when (is-weapon-melee mob-type)
      (format str "~% M: (dmg: ~A-~A) (spd: ~A) (acc: ~A%)" (get-melee-weapon-dmg-min mob-type) (get-melee-weapon-dmg-max mob-type) (get-melee-weapon-speed mob-type) (get-melee-weapon-acc mob-type)))
    (when (is-weapon-ranged mob-type)
      (format str "~% R: (dmg: ~A-~A~A) (spd: ~A) (acc: ~A%)~A"
              (get-ranged-weapon-dmg-min mob-type) (get-ranged-weapon-dmg-max mob-type)
              (if (= (get-ranged-weapon-rof mob-type) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob-type)))
              (get-ranged-weapon-speed mob-type)
              (get-ranged-weapon-acc mob-type)
              (if (not (find :no-charges (get-ranged-weapon-aux mob-type)))
                (format nil " ~A/~A" (get-ranged-weapon-charges mob-type) (get-ranged-weapon-charges mob-type))
                "")))
    str))

(defmethod get-armor-resist ((mob-type mob-type) dmg-type)
  (if (aref (armor mob-type) dmg-type)
    (values (first (aref (armor mob-type) dmg-type)) (second (aref (armor mob-type) dmg-type)))
    nil))

(defmethod get-armor-d-resist ((mob-type mob-type) dmg-type)
  (when (aref (armor mob-type) dmg-type)
    (first (aref (armor mob-type) dmg-type))))

(defmethod get-armor-%-resist ((mob-type mob-type) dmg-type)
  (when (aref (armor mob-type) dmg-type)
    (second (aref (armor mob-type) dmg-type))))

(defmethod get-armor-descr ((mob-type mob-type))
  (let ((str (create-string)))
    (format str "Armor:~%")
    (if (get-armor-resist mob-type +weapon-dmg-flesh+)
      (format str "  Flesh: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-flesh+) (get-armor-%-resist mob-type +weapon-dmg-flesh+))
      (format str "  Flesh: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-iron+)
      (format str "   Iron: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-iron+) (get-armor-%-resist mob-type +weapon-dmg-iron+))
      (format str "   Iron: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-fire+)
      (format str "   Fire: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-fire+) (get-armor-%-resist mob-type +weapon-dmg-fire+))
      (format str "   Fire: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-vorpal+)
      (format str " Vorpal: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-vorpal+) (get-armor-%-resist mob-type +weapon-dmg-vorpal+))
      (format str " Vorpal: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-mind+)
      (format str " Mind: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-mind+) (get-armor-%-resist mob-type +weapon-dmg-mind+))
      (format str " Mind: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-radiation+)
      (format str " Radiation: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-radiation+) (get-armor-%-resist mob-type +weapon-dmg-radiation+))
      (format str " Radiation: 0, 0%~%"))
    (if (get-armor-resist mob-type +weapon-dmg-acid+)
      (format str " Acid: ~A, ~A%~%" (get-armor-d-resist mob-type +weapon-dmg-acid+) (get-armor-%-resist mob-type +weapon-dmg-acid+))
      (format str " Acid: 0, 0%~%"))
    str))

;;----------------------
;; MOB
;;----------------------

(defclass mob ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (name :initform nil :accessor name)
   (alive-name :initform nil :accessor alive-name)
   (mob-type :initform 0 :initarg :mob-type :accessor mob-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   (z :initarg :z :initform 0 :accessor z :type fixnum)
   
   (dead= :initform nil :accessor dead=)
   (cur-ap :initform +normal-ap+ :accessor cur-ap :type fixnum)
   (made-turn :initform nil :accessor made-turn)
   
   (cur-hp :initform 0 :initarg :cur-hp :accessor cur-hp)
   (max-hp :initform 0 :accessor max-hp)
   (cur-fp :initform 0 :initarg :cur-fp :accessor cur-fp)

   (worshiped-god :initform nil :initarg :worshiped-god :accessor worshiped-god) ;; when the mob worships a god, this param is (<god id> <piety> <param1>)
                                                                                 ;; for Malseraph, param1 - danger level at the end of the previous turn, param2 - cooldown for decreaseing danger level
   
   (visible-mobs :initform nil :accessor visible-mobs)
   (shared-visible-mobs :initform nil :accessor shared-visible-mobs)
   (proper-visible-mobs :initform nil :accessor proper-visible-mobs)
   (hear-range-mobs :initform nil :accessor hear-range-mobs)
   (heard-sounds :initform nil :accessor heard-sounds)
   (visible-items :initform nil :accessor visible-items)

   ;; special vars for trinity mimics
   (mimic-id-list :initform () :accessor mimic-id-list)
   (merged-id-list :initform () :accessor merged-id-list)
   (is-merged :initform nil :accessor is-merged)

   (path :initform nil :accessor path)
   (path-dst :initform nil :accessor path-dst) ;; is a actually a cons with coords (x y)

   (momentum-spd :initform 0 :accessor momentum-spd)
   (momentum-dir :initform (cons 0 0) :accessor momentum-dir)
   
   (order :initform nil :accessor order)
   
   (riding-mob-id :initform nil :accessor riding-mob-id)        ;; mob is riding this mob-id
   (mounted-by-mob-id :initform nil :accessor mounted-by-mob-id) ;; mob is being ridden by this mob-id
   (order-for-next-turn :initform nil :accessor order-for-next-turn) ;; the order for mounts where to move next turn, type fixnum (direction)
   
   (master-mob-id :initform nil :accessor master-mob-id)        ;; mob that controls this mob
   (slave-mob-id :initform nil :accessor slave-mob-id)          ;; mob that is being controlled by this mob
   (face-mob-type-id ::initform nil :accessor face-mob-type-id) ;; others see this mob as this mob type 

   (effects :initform (make-hash-table) :accessor effects)
   (abilities-cd :initform (make-hash-table) :accessor abilities-cd)
   (abilities :initform (make-hash-table) :accessor abilities)  ;; each value is (<is mutation t/nil> <power level>)
   
   (weapon :initform nil :initarg :weapon :accessor weapon)
   ;; of type (<weapon name> (<dmg-type> <dmg min> <dmg max> <attack speed> <accuracy> <list of aux params>)
   ;;                        (<dmg-type> <dmg min> <dmg max> <attack speed> <cur charges> <rate of fire> <accuracy> <shoot str> <list of aux params>))
   ;; <list of aux params> may contain
   ;;   :chops-body-parts
   ;;   :is-fire
   ;;   :constricts
   ;;   :no-charges
   
   (cur-sight :initform 6 :initarg :cur-sight :accessor cur-sight)
   (m-acc :initform +base-accuracy+ :initarg :m-acc :accessor m-acc)
   (r-acc :initform +base-accuracy+ :initarg :r-acc :accessor r-acc)
   (cur-dodge :initform 5 :initarg :cur-dodge :accessor cur-dodge)
   (armor :initform nil :initarg :armor :accessor armor)
   (cur-speed :initform 100 :initarg :cur-speed :accessor cur-speed)
   (cur-move-speed :initform 100 :initarg :cur-move-speed :accessor cur-move-speed)

   (brightness :initform 0 :accessor brightness)
   (darkness :initform 0 :accessor darkness)
   (cur-light :initform *base-light-radius* :initarg :cur-light :accessor cur-light)
   (motion :initform 0 :accessor motion)
   (motion-set-p :initform nil :accessor motion-set-p) 
   (cur-stealth :initform 0 :accessor cur-stealth)

   (cur-oxygen :initform *max-oxygen-level* :accessor cur-oxygen)
   
   (stat-kills :initform (make-hash-table) :accessor stat-kills)
   (stat-blesses :initform 0 :accessor stat-blesses)
   (stat-calls :initform 0 :accessor stat-calls)
   (stat-answers :initform 0 :accessor stat-answers)
   (stat-gold :initform 0 :accessor stat-gold)
   (stat-possess :initform 0 :accessor stat-possess)
   (stat-raised-dead :initform 0 :accessor stat-raised-dead)

   (inv :initform () :accessor inv)

   ))

(defmethod initialize-instance :after ((mob mob) &key)
  (setf (id mob) (find-free-id *mobs*))
  (setf (aref *mobs* (id mob)) mob)

  (setf (max-hp mob) (max-hp (get-mob-type-by-id (mob-type mob))))
  (setf (cur-hp mob) (max-hp mob))
  (setf (cur-fp mob) 0)
  (setf (cur-ap mob) (max-ap mob))

  (when (= (mob-type mob) +mob-type-eater-of-the-dead+)
    (setf (cur-fp mob) 2))
  
  (setf (face-mob-type-id mob) (mob-type mob))

  (adjust-abilities mob)

  ;; when starting with a horse - create a horse on the spot and mount it
    
  (when (mob-ability-p mob +mob-abil-starts-with-horse+)
    (let ((horse (make-instance 'mob :mob-type +mob-type-horse+ :x (x mob) :y (y mob) :z (z mob))))
      (setf (mounted-by-mob-id horse) (id mob))
      (setf (riding-mob-id mob) (id horse))
      (add-mob-to-level-list (level *world*) horse)))

  (loop for (item-type-id qty-func) in (init-items (get-mob-type-by-id (mob-type mob)))
        for qty = (funcall qty-func)
        when (not (zerop qty))
          do
             (mob-pick-item mob (make-instance 'item :item-type item-type-id :x (x mob) :y (y mob) :z (z mob) :qty qty)
                            :spd nil :silent t))
  
  ;; add permanent flying effect, if the mob can fly
  (when (mob-ability-p mob +mob-abil-flying+)
    (set-mob-effect mob :effect-type-id +mob-effect-flying+ :actor-id (id mob)))
  
  (set-cur-weapons mob)
  
  (adjust-dodge mob)
  (adjust-armor mob)
  (adjust-m-acc mob)
  (adjust-r-acc mob)
  (adjust-sight mob)

  ;; setting up name
  (set-name mob)

  ;; set up current abilities cooldowns
  (loop for ability-id being the hash-key in (abilities mob) do
    (setf (gethash ability-id (abilities-cd mob)) 0))

  ;; if the mob has climbing ability - start with it turned on
  (when (mob-ability-p mob +mob-abil-climbing+)
    (set-mob-effect mob :effect-type-id +mob-effect-climbing-mode+ :actor-id (id mob) :cd t))

  ;; if the mob is Malseraph's puppet - automatically worship Malseraph
  (when (= (mob-type mob) +mob-type-malseraph-puppet+)
    (set-mob-worshiped-god mob :god-id +god-entity-malseraph+ :init-piety 150 :param1 0 :param2 0))
  
  (when (mob-ability-p mob +mob-abil-human+)
    (incf (total-humans *world*))
    (incf (initial-humans *world*)))
  (when (mob-ability-p mob +mob-abil-demon+)
    (incf (total-demons *world*))
    (incf (initial-demons *world*)))
  (when (mob-ability-p mob +mob-abil-undead+)
    (incf (total-undead *world*))
    (incf (initial-undead *world*)))
  (when (and (mob-ability-p mob +mob-abil-angel+)
             (not (mob-ability-p mob +mob-abil-animal+)))
    (incf (total-angels *world*))
    (incf (initial-angels *world*)))

  )

(defun get-mob-by-id (mob-id)
  (aref *mobs* mob-id))

(defmethod faction ((mob mob))
  (faction (get-mob-type-by-id (mob-type mob))))

(defmethod max-fp ((mob mob))
  (max-fp (get-mob-type-by-id (mob-type mob))))

(defmethod max-ap ((mob mob))
  (max-ap (get-mob-type-by-id (mob-type mob))))

(defmethod base-sight ((mob mob))
  (base-sight (get-mob-type-by-id (mob-type mob))))

(defmethod base-light-radius ((mob mob))
  (base-light-radius (get-mob-type-by-id (mob-type mob))))

(defmethod base-stealth ((mob mob))
  (base-stealth (get-mob-type-by-id (mob-type mob))))

(defmethod strength ((mob mob))
  (strength (get-mob-type-by-id (mob-type mob))))

(defmethod evolve-into ((mob mob))
  (evolve-mob-id (get-mob-type-by-id (mob-type mob))))

(defmethod mob-ai-coward-p ((mob mob))
  (gethash +ai-pref-coward+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-horde-p ((mob mob))
  (gethash +ai-pref-horde+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-wants-bless-p ((mob mob))
  (gethash +ai-pref-wants-bless+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-stop-p ((mob mob))
  (gethash +ai-pref-stop+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-curious-p ((mob mob))
  (gethash +ai-pref-curious+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-kleptomaniac-p ((mob mob))
  (gethash +ai-pref-kleptomaniac+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-cautious-p ((mob mob))
  (gethash +ai-pref-cautious+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-simple-pathfinding-p ((mob mob))
  (gethash +ai-pref-simple-pathfinding+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-trinity-mimic-p ((mob mob))
  (gethash +ai-pref-trinity-mimic+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-split-soul-p ((mob mob))
  (gethash +ai-pref-split-soul+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defmethod mob-ai-cannibal-p ((mob mob))
  (gethash +ai-pref-cannibal+ (ai-prefs (get-mob-type-by-id (mob-type mob)))))

(defun mob-effect-p (mob effect-type-id)
  (gethash effect-type-id (effects mob)))

(defun mob-ability-p (mob ability-type-id)
  (gethash ability-type-id (abilities mob)))

(defun mob-is-ability-mutation (mob ability-type-id)
  (if (and (gethash ability-type-id (abilities mob))
           (first (gethash ability-type-id (abilities mob))))
    t
    nil))

(defun mob-ability-value (mob ability-type-id)
  (if (gethash ability-type-id (abilities mob))
    (second (gethash ability-type-id (abilities mob)))
    nil))

(defun mob-set-mutation (mob ability-type-id &optional (ability-value t))
  (let ((has-function nil))
    (when (and (null (gethash ability-type-id (abilities mob)))
               (on-add-mutation (get-ability-type-by-id ability-type-id)))
      (setf has-function t))
    (setf (gethash ability-type-id (abilities mob)) (list t
                                                          ability-value))
    (when has-function
      (funcall (on-add-mutation (get-ability-type-by-id ability-type-id)) (get-ability-type-by-id ability-type-id) mob))))

(defun mob-remove-mutation (mob ability-type-id)
  (when (and (on-remove-mutation (get-ability-type-by-id ability-type-id)))
    (funcall (on-remove-mutation (get-ability-type-by-id ability-type-id)) (get-ability-type-by-id ability-type-id) mob))
  (setf (gethash ability-type-id (abilities mob)) nil)
  ;; place a non-mutation ability if there is one 
  (when (gethash ability-type-id (abilities (get-mob-type-by-id (mob-type mob))))
    (setf (gethash ability-type-id (abilities mob)) (list nil
                                                          (gethash ability-type-id (abilities (get-mob-type-by-id (mob-type mob))))))))

(defun set-mob-effect (mob &key effect-type-id actor-id (cd t) (param1 nil))
  (if (mob-effect-p mob effect-type-id)
    (progn
      (setf (cd (get-effect-by-id (mob-effect-p mob effect-type-id))) cd)
      (setf (actor-id (get-effect-by-id (mob-effect-p mob effect-type-id))) actor-id))
    (progn
      (let ((effect (make-instance 'effect :effect-type effect-type-id :actor-id actor-id :target-id (id mob) :cd cd :param1 param1)))
        (setf (gethash (effect-type effect) (effects mob)) (id effect))
        (funcall (on-add (get-effect-type-by-id (effect-type effect))) effect mob))))
  )

(defun rem-mob-effect (mob effect-type-id)
  (when (mob-effect-p mob effect-type-id)
    (let ((effect (get-effect-by-id (mob-effect-p mob effect-type-id))))
      (funcall (on-remove (get-effect-type-by-id effect-type-id)) effect mob)
      (rem-mob-effect-simple mob effect-type-id))))

(defun rem-mob-effect-simple (mob effect-type-id)
  (when (mob-effect-p mob effect-type-id)
    (let ((effect (get-effect-by-id (mob-effect-p mob effect-type-id))))
      (remove-effect-from-world effect)
      (remhash effect-type-id (effects mob)))))

(defmethod name ((mob mob))
  (if (slot-value mob 'name)
    (values (slot-value mob 'name) +noun-proper+ +noun-singular+)
    (values (name (get-mob-type-by-id (mob-type mob))) +noun-common+ +noun-singular+)))

(defmethod visible-name ((mob mob))
  (when (and (not (eq *player* mob))
             (or ;(mob-effect-p *player* +mob-effect-blind+)
                 (not (check-mob-visible mob :observer *player*))))
    (return-from visible-name (values "somebody" +noun-proper+ +noun-singular+)))
  (when (= (faction *player*) (faction mob))
    (return-from visible-name (name mob)))
  (if (= (face-mob-type-id mob) (mob-type mob))
    (name mob)
    (values (name (get-mob-type-by-id (face-mob-type-id mob))) +noun-common+ +noun-singular+)))

(defmethod set-cur-weapons ((mob mob))
  (when (weapon (get-mob-type-by-id (mob-type mob)))
    (setf (weapon mob) (copy-list (weapon (get-mob-type-by-id (mob-type mob)))))
    (setf (second (weapon mob)) (copy-list (second (weapon (get-mob-type-by-id (mob-type mob))))))
    (setf (third (weapon mob)) (copy-list (third (weapon (get-mob-type-by-id (mob-type mob))))))))

(defun adjust-abilities (mob)
  ;; clear all previous non-mutation abilities
  (loop for ability-type-id being the hash-key in (abilities mob)
        when (not (mob-is-ability-mutation mob ability-type-id))
          do
             (setf (gethash ability-type-id (abilities mob)) nil))
  ;; set new abilities from mob-type if no corresponding mutation is there
  (loop for ability-type-id being the hash-key in (abilities (get-mob-type-by-id (mob-type mob))) using (hash-value ability-value)
        when (not (mob-is-ability-mutation mob ability-type-id))
          do
             (setf (gethash ability-type-id (abilities mob)) (list nil
                                                                   ability-value))))

(defun adjust-sight (mob)
  (let ((light (base-light-radius mob)))
    (when (mob-effect-p mob +mob-effect-extinguished-light+)
      (setf light 0))
    (when (mob-ability-p mob +mob-abil-casts-light+)
      (setf light 6))
    (setf (cur-light mob) light))
  
  (let ((sight (base-sight mob)))
    (when (mob-effect-p mob +mob-effect-blind+)
      (setf sight 0))
    (setf (cur-sight mob) sight)))

(defun adjust-dodge (mob)
  (let ((dodge 0))
    (setf dodge (base-dodge (get-mob-type-by-id (mob-type mob))))

    (when (mob-effect-p mob +mob-effect-metabolic-boost+)
      (incf dodge 50))

    (when (and (mob-effect-p mob +mob-effect-constriction-target+)
               (mob-ability-p (get-mob-by-id (actor-id (get-effect-by-id (mob-effect-p mob +mob-effect-constriction-target+))))
                              +mob-abil-piercing-needles+))
      (decf dodge 40))
    
    ;; when riding - your dodge chance is reduced to zero
    (when (riding-mob-id mob)
      (setf dodge 0))

    (when (< dodge 0)
      (setf dodge 0))

    (setf (cur-dodge mob) dodge)))

(defun adjust-armor (mob)
  (let ((stealth (base-stealth mob)))
    (setf (cur-stealth mob) stealth))

  (let ((armor (make-array (list (length (armor (get-mob-type-by-id (mob-type mob))))) :initial-element nil)))
    (loop for armor-type across (armor (get-mob-type-by-id (mob-type mob)))
          for i from 0 do
      (setf (aref armor i) (copy-list armor-type)))
    (setf (armor mob) armor)
    (when (mob-effect-p mob +mob-effect-wet+)
      (set-armor-%-resist mob +weapon-dmg-fire+ (+ (get-armor-%-resist mob +weapon-dmg-fire+) 25)))
    (when (mob-ability-p mob +mob-abil-chitinous-plating+)
      (set-armor-d-resist mob +weapon-dmg-flesh+ (+ (get-armor-d-resist mob +weapon-dmg-flesh+) 2))
      (set-armor-d-resist mob +weapon-dmg-fire+ (+ (get-armor-d-resist mob +weapon-dmg-fire+) 2))
      (set-armor-d-resist mob +weapon-dmg-iron+ (+ (get-armor-d-resist mob +weapon-dmg-iron+) 2))
      (set-armor-d-resist mob +weapon-dmg-vorpal+ (+ (get-armor-d-resist mob +weapon-dmg-vorpal+) 2))
      (set-armor-d-resist mob +weapon-dmg-acid+ (+ (get-armor-d-resist mob +weapon-dmg-acid+) 2)))
    (when (mob-ability-p mob +mob-abil-thick-carapace+)
      (set-armor-d-resist mob +weapon-dmg-flesh+ (+ (get-armor-d-resist mob +weapon-dmg-flesh+) 1))
      (set-armor-d-resist mob +weapon-dmg-fire+ (+ (get-armor-d-resist mob +weapon-dmg-fire+) 1))
      (set-armor-d-resist mob +weapon-dmg-iron+ (+ (get-armor-d-resist mob +weapon-dmg-iron+) 1))
      (set-armor-d-resist mob +weapon-dmg-vorpal+ (+ (get-armor-d-resist mob +weapon-dmg-vorpal+) 1))
      (set-armor-d-resist mob +weapon-dmg-acid+ (+ (get-armor-d-resist mob +weapon-dmg-acid+) 1)))
    (when (mob-effect-p mob +mob-effect-spines+)
      (set-armor-%-resist mob +weapon-dmg-flesh+ (+ (get-armor-%-resist mob +weapon-dmg-flesh+) 40))
      (set-armor-%-resist mob +weapon-dmg-fire+ (+ (get-armor-%-resist mob +weapon-dmg-fire+) 40))
      (set-armor-%-resist mob +weapon-dmg-iron+ (+ (get-armor-%-resist mob +weapon-dmg-iron+) 40))
      (set-armor-%-resist mob +weapon-dmg-vorpal+ (+ (get-armor-%-resist mob +weapon-dmg-vorpal+) 40))
      (set-armor-%-resist mob +weapon-dmg-acid+ (+ (get-armor-%-resist mob +weapon-dmg-acid+) 40)))
    (when (mob-ability-p mob +mob-abil-vulnerable-to-vorpal+)
      (set-armor-d-resist mob +weapon-dmg-vorpal+ (- (get-armor-d-resist mob +weapon-dmg-vorpal+) 2)))
    (when (mob-ability-p mob +mob-abil-vulnerable-to-fire+)
      (set-armor-d-resist mob +weapon-dmg-fire+ (- (get-armor-d-resist mob +weapon-dmg-fire+) 2)))
    (when (mob-effect-p mob +mob-effect-parasite+)
      (set-armor-d-resist mob +weapon-dmg-flesh+ (- (get-armor-d-resist mob +weapon-dmg-flesh+) 1))
      (set-armor-d-resist mob +weapon-dmg-acid+ (- (get-armor-d-resist mob +weapon-dmg-acid+) 1)))
    (when (mob-effect-p mob +mob-effect-corroded+)
      (set-armor-d-resist mob +weapon-dmg-flesh+ (- (get-armor-d-resist mob +weapon-dmg-flesh+) 1))
      (set-armor-d-resist mob +weapon-dmg-acid+ (- (get-armor-d-resist mob +weapon-dmg-acid+) 1)))
    ))

(defun adjust-m-acc (mob)
  (setf (m-acc mob) 0)
  (unless (is-weapon-melee mob)
    (return-from adjust-m-acc 0))
  (let ((accuracy (get-melee-weapon-acc mob)))
    (when (mob-effect-p mob +mob-effect-cursed+)
      (setf accuracy 75))
    (setf (m-acc mob) accuracy)))

(defun adjust-r-acc (mob)
  (setf (r-acc mob) 0)
  (unless (is-weapon-ranged mob)
    (return-from adjust-r-acc 0))
  (let ((accuracy (get-ranged-weapon-acc mob)))
    (when (mob-effect-p mob +mob-effect-cursed+)
      (decf accuracy 25))
    
    (when (riding-mob-id mob)
      (decf accuracy 20))
    
    (when (< accuracy 0)
      (setf accuracy 0))
    (setf (r-acc mob) accuracy)))

(defun adjust-speed (mob)
  (let ((speed 100))
    
    (when (mob-effect-p mob +mob-effect-metabolic-boost+)
      (decf speed 30))

    (when (mob-effect-p mob +mob-effect-slow+)
      (incf speed 50))

    (when (<= speed 10)
      (setf speed 10))
    
    (setf (cur-speed mob) speed)))

(defmethod get-weapon-name ((mob mob))
  (get-weapon-name-simple (weapon mob)))

(defmethod is-weapon-melee ((mob mob))
  (is-weapon-melee-simple (weapon mob)))

(defmethod get-melee-weapon-dmg-type ((mob mob))
  (get-melee-weapon-dmg-type-simple (weapon mob)))

(defmethod get-melee-weapon-dmg-min ((mob mob))
  (get-melee-weapon-dmg-min-simple (weapon mob)))

(defmethod get-melee-weapon-dmg-max ((mob mob))
  (get-melee-weapon-dmg-max-simple (weapon mob)))

(defmethod get-melee-weapon-speed ((mob mob))
  (get-melee-weapon-speed-simple (weapon mob)))

(defmethod get-melee-weapon-acc ((mob mob))
  (get-melee-weapon-acc-simple (weapon mob)))

(defmethod get-melee-weapon-aux ((mob mob))
  (get-melee-weapon-aux-simple (weapon mob)))

(defmethod get-melee-weapon-aux-param ((mob mob) aux-feature)
  (get-melee-weapon-aux-param-simple (weapon mob) aux-feature))

(defmethod is-weapon-ranged ((mob mob))
  (is-weapon-ranged-simple (weapon mob)))

(defmethod get-ranged-weapon-dmg-type ((mob mob))
  (get-ranged-weapon-dmg-type-simple (weapon mob)))

(defmethod get-ranged-weapon-dmg-min ((mob mob))
  (get-ranged-weapon-dmg-min-simple (weapon mob)))

(defmethod get-ranged-weapon-dmg-max ((mob mob))
  (get-ranged-weapon-dmg-max-simple (weapon mob)))

(defmethod get-ranged-weapon-speed ((mob mob))
  (get-ranged-weapon-speed-simple (weapon mob)))

(defmethod get-ranged-weapon-charges ((mob mob))
  (get-ranged-weapon-charges-simple (weapon mob)))

(defun set-ranged-weapon-charges (mob value)
  (when (third (weapon mob))
    (setf (nth 4 (third (weapon mob))) value)))

(defun get-ranged-weapon-max-charges (mob)
  (get-ranged-weapon-charges (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-rof ((mob mob))
  (get-ranged-weapon-rof-simple (weapon mob)))

(defmethod get-ranged-weapon-acc ((mob mob))
  (get-ranged-weapon-acc-simple (weapon mob)))

(defmethod get-ranged-weapon-shoot-str ((mob mob))
  (get-ranged-weapon-shoot-str-simple (weapon mob)))

(defmethod get-ranged-weapon-aux ((mob mob))
  (get-ranged-weapon-aux-simple (weapon mob)))

(defmethod get-ranged-weapon-aux-param ((mob mob) aux-feature)
  (get-ranged-weapon-aux-param-simple (weapon mob) aux-feature))

(defmethod get-weapon-descr-line ((mob mob))
  (let ((str (create-string)))
    (when (weapon mob)
      (format str "~A" (get-weapon-name mob))
      (when (is-weapon-melee mob)
        (format str "~% M: (d: ~A-~A) (s: ~A) (a: ~A%)" (get-melee-weapon-dmg-min mob) (get-melee-weapon-dmg-max mob) (get-melee-weapon-speed mob) (get-melee-weapon-acc mob)))
      (when (is-weapon-ranged mob)
        (format str "~% R: (d: ~A-~A~A) (s: ~A) (a: ~A%)~A"
                (get-ranged-weapon-dmg-min mob) (get-ranged-weapon-dmg-max mob)
                (if (= (get-ranged-weapon-rof mob) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob)))
                (get-ranged-weapon-speed mob)
                (get-ranged-weapon-acc mob)
                (if (not (find :no-charges (get-ranged-weapon-aux mob)))
                  (format nil " ~A/~A" (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob))
                  ""))))
    str))

(defun get-dmg-type-name (dmg-type)
  (cond
    ((= dmg-type +weapon-dmg-flesh+) (format nil "Flesh"))
    ((= dmg-type +weapon-dmg-fire+) (format nil "Fire"))
    ((= dmg-type +weapon-dmg-iron+) (format nil "Iron"))
    ((= dmg-type +weapon-dmg-vorpal+) (format nil "Vorpal"))
    ((= dmg-type +weapon-dmg-mind+) (format nil "Mind"))
    ((= dmg-type +weapon-dmg-radiation+) (format nil "Radiation"))
    ((= dmg-type +weapon-dmg-acid+) (format nil "Acid"))))

(defmethod get-weapon-descr-long ((mob mob))
  (let ((str (create-string)))
    (format str "~A" (get-weapon-name mob))
    (when (is-weapon-melee mob)
      (format str "~% M: (dmg: ~A, ~A-~A) (spd: ~A) (acc: ~A%)"
              (get-dmg-type-name (get-melee-weapon-dmg-type mob)) (get-melee-weapon-dmg-min mob) (get-melee-weapon-dmg-max mob)
              (get-melee-weapon-speed mob)
              (get-melee-weapon-acc mob)))
    (when (is-weapon-ranged mob)
      (format str "~% R: (dmg: ~A, ~A-~A~A) (spd: ~A) (acc: ~A%)~A"
              (get-dmg-type-name (get-ranged-weapon-dmg-type mob)) (get-ranged-weapon-dmg-min mob) (get-ranged-weapon-dmg-max mob)
              (if (= (get-ranged-weapon-rof mob) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob)))
              (get-ranged-weapon-speed mob)
              (get-ranged-weapon-acc mob)
              (if (not (find :no-charges (get-ranged-weapon-aux mob)))
                (format nil " ~A/~A" (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob))
                "")))
    str))

(defmethod get-armor-resist ((mob mob) dmg-type)
  (if (aref (armor mob) dmg-type)
    (values (first (aref (armor mob) dmg-type)) (second (aref (armor mob) dmg-type)))
    nil))

(defmethod get-armor-d-resist ((mob mob) dmg-type)
  (if (aref (armor mob) dmg-type)
    (first (aref (armor mob) dmg-type))
    0))

(defmethod get-armor-%-resist ((mob mob) dmg-type)
  (if (aref (armor mob) dmg-type)
    (second (aref (armor mob) dmg-type))
    0))

(defun set-armor-d-resist (mob dmg-type value)
  (if (aref (armor mob) dmg-type)
    (setf (first (aref (armor mob) dmg-type)) value)
    (setf (aref (armor mob) dmg-type) (list value 0))))

(defun set-armor-%-resist (mob dmg-type value)
  (if (aref (armor mob) dmg-type)
    (setf (second (aref (armor mob) dmg-type)) value)
    (setf (aref (armor mob) dmg-type) (list 0 value))))

(defmethod get-armor-descr ((mob mob))
  (let ((str (create-string)))
    (format str "Armor:~%")
    (if (get-armor-resist mob +weapon-dmg-flesh+)
      (format str "     Flesh: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-flesh+) (get-armor-%-resist mob +weapon-dmg-flesh+))
      (format str "     Flesh: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-iron+)
      (format str "      Iron: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-iron+) (get-armor-%-resist mob +weapon-dmg-iron+))
      (format str "      Iron: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-fire+)
      (format str "      Fire: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-fire+) (get-armor-%-resist mob +weapon-dmg-fire+))
      (format str "      Fire: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-vorpal+)
      (format str "    Vorpal: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-vorpal+) (get-armor-%-resist mob +weapon-dmg-vorpal+))
      (format str "    Vorpal: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-mind+)
      (format str "      Mind: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-mind+) (get-armor-%-resist mob +weapon-dmg-mind+))
      (format str "      Mind: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-radiation+)
      (format str " Radiation: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-radiation+) (get-armor-%-resist mob +weapon-dmg-radiation+))
      (format str " Radiation: 0, 0%~%"))
    (if (get-armor-resist mob +weapon-dmg-acid+)
      (format str "      Acid: ~A, ~A%~%" (get-armor-d-resist mob +weapon-dmg-acid+) (get-armor-%-resist mob +weapon-dmg-acid+))
      (format str "      Acid: 0, 0%~%"))
    str))

(defmethod calculate-total-kills ((mob mob))
  (loop for killed-mob-stat being the hash-value in (stat-kills mob) 
        sum killed-mob-stat))

(defmethod calculate-total-friendly-kills ((mob mob))
  (loop for killed-mob-stat being the hash-value in (stat-kills mob) using (hash-key killed-mob-id)
        when (get-faction-relation (faction mob) (faction (get-mob-type-by-id killed-mob-id)))
          sum killed-mob-stat))

(defmethod get-qualified-name ((mob mob))
  (if (slot-value mob 'name)
    (if (mob-ability-p mob +mob-abil-undead+)
      (name mob)
      (values (format nil "~A the ~A" (name mob) (capitalize-name (name (get-mob-type-by-id (mob-type mob))))) +noun-proper+ +noun-singular+))
    (values (format nil "nameless ~A" (name mob)) +noun-common+ +noun-singular+)))

(defun set-name (mob)
  (when (and (not (eq mob *player*))
             (not (mob-ability-p mob +mob-abil-human+))
             (not (mob-ability-p mob +mob-abil-animal+))
             (not (mob-ability-p mob +mob-abil-primordial+))
             (not (= (mob-type mob) +mob-type-imp+))
             (not (= (mob-type mob) +mob-type-shadow-imp+)))
    (let ((name-pick-n))
      (if (mob-ability-p mob +mob-abil-angel+)
        (progn
          (unless *cur-angel-names*
            (return-from set-name nil))
          (setf name-pick-n (random (length *cur-angel-names*)))
          (setf (name mob) (nth name-pick-n *cur-angel-names*))
          (setf *cur-angel-names* (remove (nth name-pick-n *cur-angel-names*) *cur-angel-names*)))
        (progn
          (unless *cur-demon-names*
            (return-from set-name nil))
          (setf name-pick-n (random (length *cur-demon-names*)))
          (setf (name mob) (nth name-pick-n *cur-demon-names*))
          (setf *cur-demon-names* (remove (nth name-pick-n *cur-demon-names*) *cur-demon-names*))))
      ))
  (when (and (not (eq mob *player*))
             (or (eq (mob-type mob) +mob-type-satanist+)
                 (eq (mob-type mob) +mob-type-priest+)))
    (let ((name-pick-n)
          (surname-pick-n))
      (unless *cur-human-names*
        (return-from set-name nil))
      (unless *cur-human-surnames*
        (return-from set-name nil))
      (setf name-pick-n (random (length *cur-human-names*)))
      (setf surname-pick-n (random (length *cur-human-surnames*)))
      (setf (name mob) (format nil "~A ~A" (nth name-pick-n *cur-human-names*) (nth surname-pick-n *cur-human-surnames*)))
      (setf *cur-human-names* (remove (nth name-pick-n *cur-human-names*) *cur-human-names*))
      (setf *cur-human-surnames* (remove (nth surname-pick-n *cur-human-surnames*) *cur-human-surnames*))))
  (setf (alive-name mob) (name mob)))

(defun get-followers-list (mob)
  (loop for mob-id in (visible-mobs mob)
        for follower = (get-mob-by-id mob-id)
        when (and (order follower)
                  (= (first (order follower)) +mob-order-follow+)
                  (= (second (order follower)) (id mob)))
          collect mob-id))

(defun count-follower-list (mob)
  (loop for mob-id in (visible-mobs mob)
        for follower = (get-mob-by-id mob-id)
        when (and (order follower)
                  (= (first (order follower)) +mob-order-follow+)
                  (= (second (order follower)) (id mob)))
          count follower))

(defmethod map-size ((mob mob))
  (map-size (get-mob-type-by-id (mob-type mob))))

(defun get-mob-move-mode (mob)
  (cond
    ((mob-effect-p mob +mob-effect-flying+) +connect-map-move-fly+)
    ((mob-effect-p mob +mob-effect-climbing-mode+) +connect-map-move-climb+)
    (t +connect-map-move-walk+)))

(defun incf-mob-motion (mob motion)
  (if (motion-set-p mob)
    (incf (motion mob) motion)
    (setf (motion mob) motion (motion-set-p mob) t)))

(defun get-mob-visibility (mob)
  (let ((visibility 0))
    (incf visibility (brightness mob))
    (incf visibility (motion mob))
    (decf visibility (cur-stealth mob))
    (when (< visibility 0)
      (setf visibility 0))
    visibility))

(defun check-mob-visible (mob &key (observer nil) (complete-check nil))
  ;; you can always see yourself
  (when (eq mob observer)
    (return-from check-mob-visible t))
  
  (when (and complete-check
             observer
             (not (find (id mob) (visible-mobs observer))))
    (return-from check-mob-visible nil))

  (when (mounted-by-mob-id mob)
    (return-from check-mob-visible (check-mob-visible (get-mob-by-id (mounted-by-mob-id mob)))))
  
  (let ((exposure (get-mob-visibility mob))
        (threshold *mob-visibility-threshold*)
        (result nil))

    (when (riding-mob-id mob)
      (incf exposure (get-mob-visibility (get-mob-by-id (riding-mob-id mob)))))

    (when (and observer
               (mob-effect-p observer +mob-effect-alertness+))
      (incf exposure *mob-exposure-alertness*))
    
    (if (>= exposure threshold)
      (setf result t)
      (setf result nil))

    ;; you always see people of you own faction
    (when (and observer
               (get-faction-relation (faction mob) (faction observer)))
      (setf result t))
    
    result))

(defun set-mob-worshiped-god (mob &key (god-id +god-entity-malseraph+) (init-piety 0) param1 param2)
  (setf (worshiped-god mob) (list god-id init-piety param1 param2)))

(defun set-mob-worshiped-god-param1 (mob new-value)
  (setf (third (worshiped-god mob)) new-value))

(defun set-mob-worshiped-god-param2 (mob new-value)
  (setf (fourth (worshiped-god mob)) new-value))

;;----------------------
;; PLAYER
;;----------------------   

(defclass player (mob)
  ((name :initform "Player" :initarg :name :accessor name)
   (view-x :initform 0 :accessor view-x)
   (view-y :initform 0 :accessor view-y)
   (view-z :initform 0 :accessor view-z)
   (sense-evil-id :initform nil :accessor sense-evil-id)
   (sense-good-id :initform nil :accessor sense-good-id)
   (can-move-if-possessed :initform t :accessor can-move-if-possessed)
   (killed-by :initform nil :accessor killed-by)
   (faction-name :initform nil :accessor faction-name)
   (cur-score :initform 0 :accessor cur-score)
   (nearby-light-mobs :initform () :accessor nearby-light-mobs)
   (nearby-light-sources :initform () :accessor nearby-light-sources)))

(defmethod name ((mob player))
  (values (slot-value mob 'name) +noun-proper+ +noun-singular+))

;;---------------------- 
;; FACTIONS
;;----------------------

;; values should be (faction . realtion)
(defun set-faction-relations (faction-type &rest values)
  (let ((faction-table (make-hash-table)))
    (loop
      for (faction . rel) in values 
      do
         (setf (gethash faction faction-table) rel))
    (setf (gethash faction-type *faction-table*) faction-table)
  ))
  
(defun get-faction-relation (faction-type-1 faction-type-2)
  (let ((faction-table))
    (setf faction-table (gethash faction-type-1 *faction-table*))
    
    ;; not a relation set for faction-type-2, which means they are enemies to everybody 
    (unless faction-table
      (return-from get-faction-relation nil))
    
    ;; return the relation for faction-type-2, if not set - then they are enemies
    (gethash faction-type-2 faction-table)
    ))

(defun get-visible-faction (mob &key (viewer *player*))
  (let ((result-faction))
    ;; see the faction of the mob's appearance
    (setf result-faction (faction (get-mob-type-by-id (face-mob-type-id mob))))

    ;; but if you are really of the same faction, you know the truth
    (when (= (faction viewer) (faction mob))
      (setf result-faction (faction mob)))

    result-faction))
