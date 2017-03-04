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
      
   (abilities :initform (make-hash-table) :accessor abilities)
   ;; The following keys may be used in make-instance
   ;;   :abil-heal-self - +mob-abil-heal-self+ (takes fixnum)
   ;;   :abil-conceal-divine - +mob-abil-conceal-divine+
   ;;   :abil-reveal-divine - +mob-abil-reveal-divine+
   ;;   :abil-detect-good - +mob-abil-detect-evil+
   ;;   :abil-detect-evil - +mob-abil-detect-evil+
   ;;   :abil-can-possess - +mob-abil-can-possess+ (takes fixnum)
   ;;   :abil-possessable - +mob-abil-possessable+
   ;;   :abil-purging-touch - +mob-abil-purging-touch+
   ;;   :abil-blessing-touch - +mob-abil-blessing-touch+
   ;;   :abil-can-be-blessed - +mob-abil-can-be-blessed+
   ;;   :abil-unholy - +mob-abil-unholy+
   ;;   :abil-detect-evil - +mob-abil-detect-evil+
   ;;   :abil-human - +mob-abil-human+
   ;;   :abil-demon - +mob-abil-demon+
   ;;   :abil-angel - +mob-abil-angel+
   ;;   :abil-see-all - +mob-abil-see-all+
   ;;   :abil-lifesteal - +mob-abil-lifesteal+
   ;;   :abil-call-for-help - +mob-abil-call-for-help+
   ;;   :abil-answer-the-call - +mob-abil-answer-the-call+
   ;;   :abil-loves-infighting - +mob-abil-loves-infighting+
   ;;   :abil-prayer-bless - +mob-abil-prayer-bless+
   ;;   :abil-free-call - +mob-abil-free-call+
   ;;   :abil-prayer-shield - +mob-abil-prayer-shield+
   ;;   :abil-curse - +mob-abil-curse+
   ;;   :abil-keen-senses - +mob-abil-keen-senses+
   ;;   :abil-prayer-reveal - +mob-abil-prayer-reveal+
   ;;   :abil-military-follow-me - +mob-abil-military-follow-me+
   ;;   :abil-blindness - +mob-abil-blindness+
   ;;   :abil-instill-fear - +mob-abil-instill-fear+
   ;;   :abil-charge - +mob-abil-charge+
   ;;   :abil-momentum - +mob-abil-momentum+ (takes fixnum)
   ;;   :abil-animal - +mob-abil-animal+
   ;;   :abil-horseback-riding - +mob-abil-horseback-riding+
   ;;   :abil-horse-can-be-ridden - +mob-abil-horse-can-be-ridden+
   ;;   :abil-dismount - +mob-abil-dismount+
   ;;   :abil-dominate-fiend - +mob-abil-dominate-fiend+
   ;;   :abil-fiend-can-be-ridden - +mob-abil-fiend-can-be-ridden+
   ;;   :abil-starts-with-horse - +mob-abil-starts-with-horse+
   ;;   :abil-independent - +mob-abil-independent+
   ;;   :abil-eagle-eye - +mob-abil-eagle-eye+
   ;;   :abil-facing - +mob-abil-facing+
   
   (weapon :initform nil :initarg :weapon :accessor weapon)
   ;; of type (<weapon name> (<dmg-type> <dmg min> <dmg max> <attack speed> <accuracy> <list of aux params>)
   ;;                        (<dmg-type> <dmg min> <dmg max> <attack speed> <max charges> <rate of fire> <accuracy> <list of aux params>))
   ;; <list of aux params> may contain
   ;;   :chops-body-parts
   
   (armor :initform nil :accessor armor) ;; for initarg - ((<dmg-type> <direct-reduct> <%-reduct>) ...), while inside it is an array of lists
   (base-sight :initform 6 :initarg :base-sight :accessor base-sight)
   (base-dodge :initform 5 :initarg :base-dodge :accessor base-dodge)
   (base-armor :initform 0 :initarg :base-armor :accessor base-armor)
   (move-spd :initform +normal-ap+ :initarg :move-spd :accessor move-spd)
   ))

(defmethod initialize-instance :after ((mob-type mob-type) &key armor
                                                                ai-coward ai-horde ai-wants-bless ai-stop
                                                                abil-can-possess abil-possessable abil-purging-touch abil-blessing-touch abil-can-be-blessed abil-unholy 
                                                                abil-heal-self abil-conseal-divine abil-reveal-divine abil-detect-good abil-detect-evil
                                                                abil-human abil-demon abil-angel abil-see-all abil-lifesteal abil-call-for-help abil-answer-the-call
                                                                abil-loves-infighting abil-prayer-bless abil-free-call abil-prayer-shield abil-curse
                                                                abil-keen-senses abil-prayer-reveal abil-military-follow-me abil-blindness abil-instill-fear abil-charge
                                                                abil-momentum abil-animal abil-horseback-riding abil-horse-can-be-ridden abil-dismount abil-dominate-fiend abil-fiend-can-be-ridden
                                                                abil-starts-with-horse abil-independent abil-eagle-eye abil-facing)
  ;; set up armor
  (setf (armor mob-type) (make-array (list 4) :initial-element nil))
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
  (when abil-conseal-divine
    (setf (gethash +mob-abil-conseal-divine+ (abilities mob-type)) t))
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
  )

(defun get-mob-type-by-id (mob-type-id)
  (aref *mob-types* mob-type-id))

(defun set-mob-type (mob-type)
  (when (>= (mob-type mob-type) (length *mob-types*))
    (adjust-array *mob-types* (list (1+ (mob-type mob-type)))))
  (setf (aref *mob-types* (mob-type mob-type)) mob-type))

(defmethod get-weapon-name ((mob-type mob-type))
  (first (weapon mob-type)))

(defmethod is-weapon-melee ((mob-type mob-type))
  (if (second (weapon mob-type))
    t
    nil))

(defmethod get-melee-weapon-dmg-type ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 0 (second (weapon mob-type)))))

(defmethod get-melee-weapon-dmg-min ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 1 (second (weapon mob-type)))))

(defmethod get-melee-weapon-dmg-max ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 2 (second (weapon mob-type)))))

(defmethod get-melee-weapon-speed ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 3 (second (weapon mob-type)))))

(defmethod get-melee-weapon-acc ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 4 (second (weapon mob-type)))))

(defmethod get-melee-weapon-aux ((mob-type mob-type))
  (when (second (weapon mob-type))
    (nth 5 (second (weapon mob-type)))))

(defmethod get-melee-weapon-aux-param ((mob-type mob-type) aux-feature)
  (when (second (weapon mob-type))
    (find aux-feature (nth 5 (second (weapon mob-type))))))

(defmethod is-weapon-ranged ((mob-type mob-type))
  (if (third (weapon mob-type))
    t
    nil))

(defmethod get-ranged-weapon-dmg-type ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 0 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-dmg-min ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 1 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-dmg-max ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 2 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-speed ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 3 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-charges ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 4 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-rof ((mob-type mob-type))
  ;; rate of fire - the number of charges the weapon consumes per shoot 
  (when (third (weapon mob-type))
    (nth 5 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-acc ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 6 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-aux ((mob-type mob-type))
  (when (third (weapon mob-type))
    (nth 7 (third (weapon mob-type)))))

(defmethod get-ranged-weapon-aux-param ((mob-type mob-type) aux-feature)
  (when (third (weapon mob-type))
    (find aux-feature (nth 7 (third (weapon mob-type))))))

(defmethod get-weapon-descr-line ((mob-type mob-type))
  (let ((str (create-string)))
    (format str "~A" (get-weapon-name mob-type))
    (when (is-weapon-melee mob-type)
      (format str "~% M: (dmg: ~A-~A) (spd: ~A) (acc: ~A%)" (get-melee-weapon-dmg-min mob-type) (get-melee-weapon-dmg-max mob-type) (get-melee-weapon-speed mob-type) (get-melee-weapon-acc mob-type)))
    (when (is-weapon-ranged mob-type)
      (format str "~% R: (dmg: ~A-~A~A) (spd: ~A) (acc: ~A%) ~A/~A"
              (get-ranged-weapon-dmg-min mob-type) (get-ranged-weapon-dmg-max mob-type)
              (if (= (get-ranged-weapon-rof mob-type) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob-type)))
              (get-ranged-weapon-speed mob-type)
              (get-ranged-weapon-acc mob-type)
              (get-ranged-weapon-charges mob-type) (get-ranged-weapon-charges mob-type)))
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
    str))

;;----------------------
;; MOB
;;----------------------

(defclass mob ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (name :initform nil :accessor name)
   (mob-type :initform 0 :initarg :mob-type :accessor mob-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   
   (dead= :initform nil :accessor dead=)
   (cur-ap :initform +normal-ap+ :accessor cur-ap :type fixnum)
   (made-turn :initform nil :accessor made-turn)
   
   (cur-hp :initform 0 :initarg :cur-hp :accessor cur-hp)
   (cur-fp :initform 0 :initarg :cur-fp :accessor cur-fp)
    
   (visible-mobs :initform nil :accessor visible-mobs)
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
   
   (weapon :initform nil :initarg :weapon :accessor weapon)
   ;; of type (<weapon name> (<dmg-type> <dmg min> <dmg max> <attack speed> <accuracy> <list of aux params>)
   ;;                        (<dmg-type> <dmg min> <dmg max> <attack speed> <max charges> <rate of fire> <accuracy> <list of aux params>))
   ;; <list of aux params> may contain
   ;;   :chops-body-parts
   
   (cur-sight :initform 6 :initarg :cur-sight :accessor cur-sight)
   (m-acc :initform +base-accuracy+ :initarg :m-acc :accessor m-acc)
   (r-acc :initform +base-accuracy+ :initarg :r-acc :accessor r-acc)
   (cur-dodge :initform 5 :initarg :cur-dodge :accessor cur-dodge)
   (cur-armor :initform 0 :initarg :cur-armor :accessor cur-armor)
   
   (stat-kills :initform (make-hash-table) :accessor stat-kills)
   (stat-blesses :initform 0 :accessor stat-blesses)
   (stat-calls :initform 0 :accessor stat-calls)
   (stat-answers :initform 0 :accessor stat-answers)

   ))

(defmethod initialize-instance :after ((mob mob) &key)
  (setf (id mob) (find-free-id *mobs*))
  (setf (aref *mobs* (id mob)) mob)
  
  (setf (cur-hp mob) (max-hp mob))
  (setf (cur-fp mob) 0)
  (setf (cur-ap mob) (max-ap mob))
  
  (setf (face-mob-type-id mob) (mob-type mob))

  ;; when starting with a horse - create a horse on the spot and mount it
  (when (mob-ability-p mob +mob-abil-starts-with-horse+)
    (let ((horse (make-instance 'mob :mob-type +mob-type-horse+ :x (x mob) :y (y mob))))
      (add-mob-to-level-list (level *world*) horse)
      (setf (mounted-by-mob-id horse) (id mob))
      (setf (riding-mob-id mob) (id horse))))
  
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
  
  (when (mob-ability-p mob +mob-abil-human+)
    (incf (total-humans *world*))
    (incf (initial-humans *world*)))
  (when (mob-ability-p mob +mob-abil-demon+)
    (incf (total-demons *world*))
    (incf (initial-demons *world*)))
  (when (mob-ability-p mob +mob-abil-angel+)
    (incf (total-angels *world*))
    (incf (initial-angels *world*)))

 
  )

(defun get-mob-by-id (mob-id)
  (aref *mobs* mob-id))

(defgeneric mob-ai-coward-p (mob))

(defgeneric mob-ai-horde-p (mob))

(defgeneric mob-ai-wants-bless-p (mob))

(defgeneric mob-ai-stop-p (mob))

(defmethod faction ((mob mob))
  (faction (get-mob-type-by-id (mob-type mob))))

(defmethod max-hp ((mob mob))
  (max-hp (get-mob-type-by-id (mob-type mob))))

(defmethod max-fp ((mob mob))
  (max-fp (get-mob-type-by-id (mob-type mob))))

(defmethod max-ap ((mob mob))
  (max-ap (get-mob-type-by-id (mob-type mob))))

(defmethod base-sight ((mob mob))
  (base-sight (get-mob-type-by-id (mob-type mob))))

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

(defun mob-effect-p (mob effect-id)
  (gethash effect-id (effects mob)))

(defun mob-ability-p (mob ability-type-id)
  (gethash ability-type-id (abilities mob)))

(defun set-mob-effect (mob effect-id &optional (value t))
  (setf (gethash effect-id (effects mob)) value))

(defun rem-mob-effect (mob effect-id)
  (remhash effect-id (effects mob)))

(defmethod name ((mob mob))
  (if (slot-value mob 'name)
    (slot-value mob 'name)
    (name (get-mob-type-by-id (mob-type mob)))))

(defun visible-name (mob)
  (when (and (not (eq *player* mob))
             (mob-effect-p *player* +mob-effect-blind+))
    (return-from visible-name "somebody"))
  (when (= (faction *player*) (faction mob))
    (return-from visible-name (name mob)))
  (if (= (face-mob-type-id mob) (mob-type mob))
    (name mob)
    (name (get-mob-type-by-id (face-mob-type-id mob)))))

(defmethod set-cur-weapons ((mob mob))
  (setf (weapon mob) (copy-list (weapon (get-mob-type-by-id (mob-type mob)))))
  (setf (second (weapon mob)) (copy-list (second (weapon (get-mob-type-by-id (mob-type mob))))))
  (setf (third (weapon mob)) (copy-list (third (weapon (get-mob-type-by-id (mob-type mob)))))))

(defun adjust-sight (mob)
  (let ((sight (base-sight mob)))
    (when (mob-effect-p mob +mob-effect-blind+)
      (setf sight 0))
    (setf (cur-sight mob) sight)))

(defun adjust-dodge (mob)
  (let ((dodge 0))
    (setf dodge (base-dodge (get-mob-type-by-id (mob-type mob))))

    ;; when riding - your dodge chance is reduced to zero
    (when (riding-mob-id mob)
      (setf dodge 0))
    (setf (cur-dodge mob) dodge)))

(defun adjust-armor (mob-obj)
  (let ((armor 0))
    (setf armor (base-armor (get-mob-type-by-id (mob-type mob-obj))))
    (setf (cur-armor mob-obj) armor)))

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

(defmethod get-weapon-name ((mob mob))
  (get-weapon-name (get-mob-type-by-id (mob-type mob))))

(defmethod is-weapon-melee ((mob mob))
  (is-weapon-melee (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-dmg-type ((mob mob))
  (get-melee-weapon-dmg-type (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-dmg-min ((mob mob))
  (get-melee-weapon-dmg-min (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-dmg-max ((mob mob))
  (get-melee-weapon-dmg-max (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-speed ((mob mob))
  (get-melee-weapon-speed (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-acc ((mob mob))
  (get-melee-weapon-acc (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-aux ((mob mob))
  (get-melee-weapon-aux (get-mob-type-by-id (mob-type mob))))

(defmethod get-melee-weapon-aux-param ((mob mob) aux-feature)
  (get-melee-weapon-aux-param (get-mob-type-by-id (mob-type mob)) aux-feature))

(defmethod is-weapon-ranged ((mob mob))
  (is-weapon-ranged (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-dmg-type ((mob mob))
  (get-ranged-weapon-dmg-type (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-dmg-min ((mob mob))
  (get-ranged-weapon-dmg-min (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-dmg-max ((mob mob))
  (get-ranged-weapon-dmg-max (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-speed ((mob mob))
  (get-ranged-weapon-speed (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-charges ((mob mob))
  (when (third (weapon mob))
    (nth 4 (third (weapon mob)))))

(defun set-ranged-weapon-charges (mob value)
  (when (third (weapon mob))
    (setf (nth 4 (third (weapon mob))) value)))

(defun get-ranged-weapon-max-charges (mob)
  (get-ranged-weapon-charges (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-rof ((mob mob))
  (get-ranged-weapon-rof (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-acc ((mob mob))
  (get-ranged-weapon-acc (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-aux ((mob mob))
  (get-ranged-weapon-aux (get-mob-type-by-id (mob-type mob))))

(defmethod get-ranged-weapon-aux-param ((mob mob) aux-feature)
  (get-ranged-weapon-aux-param (get-mob-type-by-id (mob-type mob)) aux-feature))

(defmethod get-weapon-descr-line ((mob mob))
  (let ((str (create-string)))
    (format str "~A" (get-weapon-name mob))
    (when (is-weapon-melee mob)
      (format str "~% M: (d: ~A-~A) (s: ~A) (a: ~A%)" (get-melee-weapon-dmg-min mob) (get-melee-weapon-dmg-max mob) (get-melee-weapon-speed mob) (get-melee-weapon-acc mob)))
    (when (is-weapon-ranged mob)
      (format str "~% R: (d: ~A-~A~A) (s: ~A) (a: ~A%) ~A/~A"
              (get-ranged-weapon-dmg-min mob) (get-ranged-weapon-dmg-max mob)
              (if (= (get-ranged-weapon-rof mob) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob)))
              (get-ranged-weapon-speed mob)
              (get-ranged-weapon-acc mob)
              (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob)))
    str))

(defun get-dmg-type-name (dmg-type)
  (cond
    ((= dmg-type +weapon-dmg-flesh+) (format nil "Flesh"))
    ((= dmg-type +weapon-dmg-fire+) (format nil "Fire"))
    ((= dmg-type +weapon-dmg-iron+) (format nil "Iron"))
    ((= dmg-type +weapon-dmg-vorpal+) (format nil "Vorpal"))))

(defmethod get-weapon-descr-long ((mob mob))
  (let ((str (create-string)))
    (format str "~A" (get-weapon-name mob))
    (when (is-weapon-melee mob)
      (format str "~% M: (dmg: ~A, ~A-~A) (spd: ~A) (acc: ~A%)"
              (get-dmg-type-name (get-melee-weapon-dmg-type mob)) (get-melee-weapon-dmg-min mob) (get-melee-weapon-dmg-max mob)
              (get-melee-weapon-speed mob)
              (get-melee-weapon-acc mob)))
    (when (is-weapon-ranged mob)
      (format str "~% R: (dmg: ~A, ~A-~A~A) (spd: ~A) (acc: ~A%) ~A/~A"
              (get-dmg-type-name (get-ranged-weapon-dmg-type mob)) (get-ranged-weapon-dmg-min mob) (get-ranged-weapon-dmg-max mob)
              (if (= (get-ranged-weapon-rof mob) 1) "" (format nil " x~A" (get-ranged-weapon-rof mob)))
              (get-ranged-weapon-speed mob)
              (get-ranged-weapon-acc mob)
              (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob)))
    str))

(defmethod get-armor-resist ((mob mob) dmg-type)
  (get-armor-resist (get-mob-type-by-id (mob-type mob)) dmg-type))

(defmethod get-armor-d-resist ((mob mob) dmg-type)
  (get-armor-d-resist (get-mob-type-by-id (mob-type mob)) dmg-type))

(defmethod get-armor-%-resist ((mob mob) dmg-type)
  (get-armor-%-resist (get-mob-type-by-id (mob-type mob)) dmg-type))

(defmethod get-armor-descr ((mob mob))
  (get-armor-descr (get-mob-type-by-id (mob-type mob))))

(defmethod calculate-total-kills ((mob mob))
  (loop for killed-mob-stat being the hash-value in (stat-kills mob) 
        sum killed-mob-stat))

(defmethod calculate-total-friendly-kills ((mob mob))
  (loop for killed-mob-stat being the hash-value in (stat-kills mob) using (hash-key killed-mob-id)
        when (get-faction-relation (faction mob) (faction (get-mob-type-by-id killed-mob-id)))
          sum killed-mob-stat))

(defmethod get-qualified-name ((mob mob))
  (if (slot-value mob 'name)
    (format nil "~A the ~A" (name mob) (name (get-mob-type-by-id (mob-type mob))))
    (format nil "nameless ~A" (name mob))))

(defun set-name (mob)
  (when (and (not (eq mob *player*))
             (not (mob-ability-p mob +mob-abil-human+))
             (not (mob-ability-p mob +mob-abil-animal+))
             (not (= (mob-type mob) +mob-type-imp+)))
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
    )))

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

;;----------------------
;; PLAYER
;;----------------------   

(defclass player (mob)
  ((name :initform "Player" :initarg :name :accessor name)
   (view-x :initform 0 :accessor view-x)
   (view-y :initform 0 :accessor view-y)
   (sense-evil-id :initform nil :accessor sense-evil-id)
   (sense-good-id :initform nil :accessor sense-good-id)
   (can-move-if-possessed :initform t :accessor can-move-if-possessed)))
 
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
