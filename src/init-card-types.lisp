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

(set-card-type (make-instance 'card-type :id +item-card-curse+
                                         :name "Card of Curses"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
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

(set-card-type (make-instance 'card-type :id +item-card-blindness+
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

(set-card-type (make-instance 'card-type :id +item-card-fear+
                                         :name "Card of Fear"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     (invoke-fear actor 3))))

(set-card-type (make-instance 'card-type :id +item-card-slow+
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

(set-card-type (make-instance 'card-type :id +item-card-silence+
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

(set-card-type (make-instance 'card-type :id +item-card-confuse+
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

(set-card-type (make-instance 'card-type :id +item-card-polymorph+
                                         :name "Card of the Sheep"
                                         :on-use #'(lambda (card-type actor)
                                                     (logger (format nil "INVOKE-CARD: ~A [~A] invokes card: ~A.~%" (name actor) (id actor) (name card-type)))
                                                     ;; confuse nearby mobs
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

