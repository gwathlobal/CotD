(in-package :cotd)

(set-card-type (make-instance 'card-type :id +item-card-blink+
                                         :name "Card of Bend Space"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-bend-space actor))))

(set-card-type (make-instance 'card-type :id +item-card-teleport+
                                         :name "Card of Teleporting"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-teleport-self actor 30 (z actor)))))

(set-card-type (make-instance 'card-type :id +item-card-disguise+
                                         :name "Card of Disguises"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-disguise actor))))

(set-card-type (make-instance 'card-type :id +item-card-sprint+
                                         :name "Card of Sprinting"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (set-mob-effect actor :effect-type-id +mob-effect-sprint+ :actor-id (id actor) :cd 5))))

(set-card-type (make-instance 'card-type :id +item-card-flying+
                                         :name "Card of Flying"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (set-mob-effect actor :effect-type-id +mob-effect-flying+ :actor-id (id actor) :cd 5))))

(set-card-type (make-instance 'card-type :id +item-card-curse-other+
                                         :name "Card of Curses"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-curse actor))))

(set-card-type (make-instance 'card-type :id +item-card-blindness-other+
                                         :name "Card of Blindness"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; blind nearby mobs
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for mob = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (set-mob-effect mob :effect-type-id +mob-effect-blind+ :actor-id (id actor) :cd 2)
                                                              (if (eq *player* mob)
                                                                (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                                (setf (visible-mobs mob) nil))
                                                              (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                     (format nil "~A is blind. " (capitalize-name (prepend-article +article-the+ (visible-name mob)))))
                                                           ))))

(set-card-type (make-instance 'card-type :id +item-card-fear-other+
                                         :name "Card of Fear"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-fear actor 3))))

(set-card-type (make-instance 'card-type :id +item-card-slow-other+
                                         :name "Card of Slowness"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; slow nearby mobs
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (set-mob-effect target :effect-type-id +mob-effect-slow+ :actor-id (id actor) :cd 5)
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A is slown. " (capitalize-name (prepend-article +article-the+ (visible-name target)))))
                                                           )
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-silence-other+
                                         :name "Card of Silence"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; silence nearby mobs
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (set-mob-effect target :effect-type-id +mob-effect-silence+ :actor-id (id actor) :cd 5)
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A is silenced. " (capitalize-name (prepend-article +article-the+ (visible-name target)))))
                                                           ))))

(set-card-type (make-instance 'card-type :id +item-card-confuse-other+
                                         :name "Card of Confusion"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; confuse nearby mobs
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (if (> (1+ (random 6)) (strength target))
                                                                (progn
                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                         (format nil "~A is confused. "
                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name target)))
                                                                                                 ))
                                                                  
                                                                  (set-mob-effect target :effect-type-id +mob-effect-confuse+ :actor-id (id actor) :cd 4))
                                                                (progn
                                                                  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                         (format nil "~A resists confusion. "
                                                                                                 (capitalize-name (prepend-article +article-the+ (visible-name target)))))))
                                                           ))))

(set-card-type (make-instance 'card-type :id +item-card-polymorph-other+
                                         :name "Card of the Sheep"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; polymorph nearby mobs
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           when (not (get-faction-relation (faction actor) (faction target)))
                                                             do
                                                                (if (> (1+ (random 6)) (strength target))
                                                                  (progn
                                                                    (set-mob-effect target :effect-type-id +mob-effect-polymorph-sheep+ :actor-id (id actor) :cd 5 :param1 (list (mob-type target) (max-hp target))))
                                                                  (progn
                                                                    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                           (format nil "~A resists polymorph. "
                                                                                                   (capitalize-name (prepend-article +article-the+ (visible-name target)))))))
                                                           ))))

(set-card-type (make-instance 'card-type :id +item-card-polymorph-self+
                                         :name "Card of the Sheep"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (if (> (1+ (random 6)) (strength actor))
                                                       (progn
                                                         (set-mob-effect actor :effect-type-id +mob-effect-polymorph-sheep+ :actor-id (id actor) :cd 5 :param1 (list (mob-type actor) (max-hp actor))))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A resists polymorph. "
                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor)))))))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-irradiate-other+
                                         :name "Card of Radiation"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (if (mob-effect-p target +mob-effect-irradiated+)
                                                                (progn
                                                                  (let ((effect (get-effect-by-id (mob-effect-p target +mob-effect-irradiated+))))
                                                                    (incf (param1 effect) (+ 2 (random 3)))))
                                                                (progn
                                                                  (set-mob-effect target :effect-type-id +mob-effect-irradiated+ :actor-id (id actor) :cd t :param1 (+ 2 (random 3)))))
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A is irradiated. " (capitalize-name (prepend-article +article-the+ (visible-name target)))))
                                                           ))))

(set-card-type (make-instance 'card-type :id +item-card-irradiate-self+
                                         :name "Card of Radiation"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (if (mob-effect-p actor +mob-effect-irradiated+)
                                                       (progn
                                                         (let ((effect (get-effect-by-id (mob-effect-p actor +mob-effect-irradiated+))))
                                                           (incf (param1 effect) (+ 2 (random 3)))))
                                                       (progn
                                                         (set-mob-effect actor :effect-type-id +mob-effect-irradiated+ :actor-id (id actor) :cd t :param1 (+ 2 (random 3)))))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-confuse-self+
                                         :name "Card of Confusion"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; confuse nearby mobs
                                                     (if (> (1+ (random 6)) (strength actor))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is confused. "
                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                        ))
                                                         
                                                         (set-mob-effect actor :effect-type-id +mob-effect-confuse+ :actor-id (id actor) :cd 4))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A resists confusion. "
                                                                                        (capitalize-name (prepend-article +article-the+ (visible-name actor))))))))))

(set-card-type (make-instance 'card-type :id +item-card-silence-self+
                                         :name "Card of Silence"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (set-mob-effect actor :effect-type-id +mob-effect-silence+ :actor-id (id actor) :cd 5)
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A is silenced. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-slow-self+
                                         :name "Card of Slowness"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (set-mob-effect actor :effect-type-id +mob-effect-slow+ :actor-id (id actor) :cd 5)
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A is slown. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-fear-self+
                                         :name "Card of Fear"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (if (> (random (+ (strength actor) 3)) (strength actor))
                                                       (progn
                                                         (set-mob-effect actor :effect-type-id +mob-effect-fear+ :actor-id (id actor) :cd 3)
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A is feared. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :observed-mob actor))
                                                       (progn
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A resists fear. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                                :observed-mob actor))))))

(set-card-type (make-instance 'card-type :id +item-card-blindness-self+
                                         :name "Card of Blindness"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (set-mob-effect actor :effect-type-id +mob-effect-blind+ :actor-id (id actor) :cd 2)
                                                     (if (eq *player* actor)
                                                       (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                       (setf (visible-mobs actor) nil))
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A is blind. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-curse-self+
                                         :name "Card of Curses"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (let ((protected nil))
                                                       ;; divine shield and blessings also grant one-time protection from curses
                                                       (when (and (not protected) (mob-effect-p actor +mob-effect-blessed+))
                                                         (rem-mob-effect actor +mob-effect-blessed+)
                                                         (setf protected t))
                                                       
                                                       (when (and (not protected) (mob-effect-p actor +mob-effect-divine-shield+))
                                                         (rem-mob-effect actor +mob-effect-divine-shield+)
                                                         (setf protected t))
                                                       
                                                       (if protected
                                                         (progn
                                                           (logger (format nil "MOB-CURSE: ~A [~A] was protected, so the curse removes protection only~%" (name actor) (id actor)))
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "Malseraph's curse removed divine protection from ~A. "
                                                                                          (prepend-article +article-the+ (visible-name actor))))
                                                           )
                                                         (progn
                                                           (logger (format nil "MOB-CURSE: Malseraph affects ~A [~A] with a curse~%" (name actor) (id actor)))
                                                           (set-mob-effect actor :effect-type-id +mob-effect-cursed+ :actor-id (id actor) :cd 5)
                                                           (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                  (format nil "~A is cursed. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))))
                                                       ))))

(set-card-type (make-instance 'card-type :id +item-card-give-deck+
                                         :name "Card of Gifts"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (let* ((deck-types (list +item-type-deck-of-war+ +item-type-deck-of-escape+))
                                                            (r (random (length deck-types)))
                                                            (deck-item (make-instance 'item :item-type (nth r deck-types) :x (x actor) :y (y actor) :z (z actor) :qty 1)))
                                                       (when (not (mob-effect-p actor +mob-effect-disguised+))
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "Malseraph grants ~A ~A. " (prepend-article +article-the+ (visible-name actor)) (prepend-article +article-a+ (visible-name deck-item)))))
                                                       (mob-pick-item actor deck-item :spd nil :silent t))
                                                     )))

(set-card-type (make-instance 'card-type :id +item-card-glowing-all+
                                         :name "Card of Glowing"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (loop for i from 0 below (length (visible-mobs actor))
                                                           for target = (get-mob-by-id (nth i (visible-mobs actor)))
                                                           do
                                                              (set-mob-effect target :effect-type-id +mob-effect-glowing+ :actor-id (id actor) :cd 5)
                                                              (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                     (format nil "~A is glowing. " (capitalize-name (prepend-article +article-the+ (visible-name target)))))
                                                           )
                                                     (set-mob-effect actor :effect-type-id +mob-effect-glowing+ :actor-id (id actor) :cd 5)
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A is glowing. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))
                                                     )))
