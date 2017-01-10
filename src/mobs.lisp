(in-package :cotd)

(defgeneric get-weapon-name (mob))

(defgeneric get-weapon-dmg-min (mob))

(defgeneric get-weapon-dmg-max (mob))

(defgeneric get-weapon-speed (mob))

(defgeneric get-weapon-descr-line (mob))

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
   
   (max-hp :initform 1 :initarg :max-hp :accessor max-hp)
   (max-fp :initform 1 :initarg :max-fp :accessor max-fp)

   (strength :initform 0 :initarg :strength :accessor strength) ;; relative mob strength for AI to assess its chances
   (ai-prefs :initform (make-hash-table) :accessor ai-prefs)
   ;; The following keys may be used in make-instance
   ;;   :ai-coward - mob will flee if there are enemies in sight
   ;;   :ai-horde  - mob will attack only if the relative strength of allies in sight is more than the relative strength of enemies, otherwise it will flee
   ;;   :ai-wants-bless - mob will get to the nearest ally and bless it
      
   (abilities :initform (make-hash-table) :accessor abilities)
   ;; The following keys may be used in make-instance
   ;;   :abil-heal-self - +mob-abil-heal-self+
   ;;   :abil-conceal-divine - +mob-abil-conceal-divine+
   ;;   :abil-reveal-divine - +mob-abil-reveal-divine+
   ;;   :abil-detect-good - +mob-abil-detect-evil+
   ;;   :abil-detect-evil - +mob-abil-detect-evil+
   ;;   :abil-can-possess - +mob-abil-can-possess+
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
   
   (weapon :initform nil :initarg :weapon :accessor weapon) ;; of type (<weapon name> <dmg min> <dmg max> <attack speed>)
   (base-sight :initform 6 :initarg :base-sight :accessor base-sight)
   (base-dodge :initform 5 :initarg :base-dodge :accessor base-dodge)
   (base-armor :initform 0 :initarg :base-armor :accessor base-armor)
   (move-spd :initform +normal-ap+ :initarg :move-spd :accessor move-spd)
   ))

(defmethod initialize-instance :after ((mob-type mob-type) &key ai-coward ai-horde ai-wants-bless 
                                                                abil-can-possess abil-possessable abil-purging-touch abil-blessing-touch abil-can-be-blessed abil-unholy 
                                                                abil-heal-self abil-conseal-divine abil-reveal-divine abil-detect-good abil-detect-evil
                                                                abil-human abil-demon abil-angel abil-see-all abil-lifesteal abil-call-for-help abil-answer-the-call
                                                                abil-loves-infighting)
  (when ai-coward
    (setf (gethash +ai-pref-coward+ (ai-prefs mob-type)) t))
  (when ai-horde
    (setf (gethash +ai-pref-horde+ (ai-prefs mob-type)) t))
  (when ai-wants-bless
    (setf (gethash +ai-pref-wants-bless+ (ai-prefs mob-type)) t))

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
  )

(defun get-mob-type-by-id (mob-type-id)
  (gethash mob-type-id *mob-types*))

(defun set-mob-type (mob-type)
  (setf (gethash (mob-type mob-type) *mob-types*) mob-type))

(defmethod get-weapon-name ((mob-type mob-type))
  (nth 0 (weapon mob-type)))

(defmethod get-weapon-dmg-min ((mob-type mob-type))
  (nth 1 (weapon mob-type)))

(defmethod get-weapon-dmg-max ((mob-type mob-type))
  (nth 2 (weapon mob-type)))

(defmethod get-weapon-speed ((mob-type mob-type))
  (nth 3 (weapon mob-type)))

(defmethod get-weapon-descr-line ((mob-type mob-type))
  (format nil "~A (dmg: ~A-~A) (spd: ~A)" (get-weapon-name mob-type) (get-weapon-dmg-min mob-type) (get-weapon-dmg-max mob-type) (get-weapon-speed mob-type)))

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
   (action-delay :initform 0 :accessor action-delay :type fixnum)
   
   (cur-hp :initform 0 :initarg :cur-hp :accessor cur-hp)
   (cur-fp :initform 0 :initarg :cur-fp :accessor cur-fp)
    
   (visible-mobs :initform nil :accessor visible-mobs)
   (path :initform nil :accessor path)
   
   (master-mob-id :initform nil :accessor master-mob-id) ;; mob that controls this mob
   (slave-mob-id :initform nil :accessor slave-mob-id)  ;; mob that is being controlled by this mob
   (face-mob-type-id ::initform nil :accessor face-mob-type-id) ;; others see this mob as this mob type 

   (effects :initform (make-hash-table) :accessor effects)
   
   (weapon :initform nil :initarg :weapon :accessor weapon) ;; of type (<weapon name> <dmg min> <dmg max> <attack speed>)
   (cur-sight :initform 6 :initarg :cur-sight :accessor cur-sight)
   (accuracy :initform 100 :initarg :accuracy :accessor accuracy)
   (att-spd :initform 10 :initarg :att-spd :accessor att-spd)
   (cur-dodge :initform 5 :initarg :cur-dodge :accessor cur-dodge)
   (cur-armor :initform 0 :initarg :cur-armor :accessor cur-armor)
   
   (stat-kills :initform (make-hash-table) :accessor stat-kills)
   (stat-blesses :initform 0 :accessor stat-blesses)
   (stat-calls :initform 0 :accessor stat-calls)
   (stat-answers :initform 0 :accessor stat-answers)

   ))

(defmethod initialize-instance :after ((mob mob) &key)
  (setf (id mob) (find-free-id *mobs-hash*))
  (setf (gethash (id mob) *mobs-hash*) mob)
  
  (setf (cur-hp mob) (max-hp mob))
  (setf (cur-fp mob) 0)
  (setf (cur-sight mob) (base-sight mob))
  
  (setf (face-mob-type-id mob) (mob-type mob))
  
  (set-cur-weapons mob)
  (adjust-attack-speed mob)
  (adjust-dodge mob)
  (adjust-armor mob)

  ;; setting up name
  (set-name mob)
  
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
  (gethash mob-id *mobs-hash*))

(defgeneric mob-ai-coward-p (mob))

(defgeneric mob-ai-horde-p (mob))

(defgeneric mob-ai-wants-bless-p (mob))



(defmethod faction ((mob mob))
  (faction (get-mob-type-by-id (mob-type mob))))

(defmethod max-hp ((mob mob))
  (max-hp (get-mob-type-by-id (mob-type mob))))

(defmethod max-fp ((mob mob))
  (max-fp (get-mob-type-by-id (mob-type mob))))

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

(defmethod set-cur-weapons ((mob-obj mob))
  (setf (weapon mob-obj) (copy-list (weapon (get-mob-type-by-id (mob-type mob-obj))))))

(defun adjust-attack-speed (mob)
  (setf (att-spd mob) (get-weapon-speed mob)))


(defun adjust-dodge (mob-obj)
  (let ((dodge 0))
    (setf dodge (base-dodge (get-mob-type-by-id (mob-type mob-obj))))
    (setf (cur-dodge mob-obj) dodge)))

(defun adjust-armor (mob-obj)
  (let ((armor 0))
    (setf armor (base-armor (get-mob-type-by-id (mob-type mob-obj))))
    (setf (cur-armor mob-obj) armor)))

(defmethod get-weapon-name ((mob mob))
  (get-weapon-name (get-mob-type-by-id (mob-type mob))))

(defmethod get-weapon-dmg-min ((mob mob))
  (get-weapon-dmg-min (get-mob-type-by-id (mob-type mob))))

(defmethod get-weapon-dmg-max ((mob mob))
  (get-weapon-dmg-max (get-mob-type-by-id (mob-type mob))))

(defmethod get-weapon-speed ((mob mob))
  (get-weapon-speed (get-mob-type-by-id (mob-type mob))))

(defmethod get-weapon-descr-line ((mob mob))
  (get-weapon-descr-line (get-mob-type-by-id (mob-type mob))))

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
             (not (= (mob-type mob) +mob-type-imp+)))
    (let ((name-pick-n))
      (if (mob-ability-p mob +mob-abil-angel+)
        (progn
          (setf name-pick-n (random (length *cur-angel-names*)))
          (setf (name mob) (nth name-pick-n *cur-angel-names*))
          (setf *cur-angel-names* (remove (nth name-pick-n *cur-angel-names*) *cur-angel-names*)))
        (progn
          (setf name-pick-n (random (length *cur-demon-names*)))
          (setf (name mob) (nth name-pick-n *cur-demon-names*))
          (setf *cur-demon-names* (remove (nth name-pick-n *cur-demon-names*) *cur-demon-names*))))
    )))

;;----------------------
;; PLAYER
;;----------------------   

(defclass player (mob)
  ((name :initform "Player" :initarg :name :accessor name)
   (view-x :initform 0 :accessor view-x)
   (view-y :initform 0 :accessor view-y)
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
