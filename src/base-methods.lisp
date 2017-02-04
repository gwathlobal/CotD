(in-package :cotd)



(defun find-free-id (array)
  (loop for i from 0 below (length array)
        unless (aref array i)
          do (return-from find-free-id i))
  (adjust-array array (list (1+ (length array))))
  (1- (length array)))


(defun x-y-into-dir (x y)
  (let ((xy (list x y)))
    (cond
      ((equal xy '(-1 1)) 1)
      ((equal xy '(0 1)) 2)
      ((equal xy '(1 1)) 3)
      ((equal xy '(-1 0)) 4)
      ((equal xy '(0 0)) 5)
      ((equal xy '(1 0)) 6)
      ((equal xy '(-1 -1)) 7)
      ((equal xy '(0 -1)) 8)
      ((equal xy '(1 -1)) 9)
      (t nil))))

(defun x-y-dir (dir)
  "Determine the x-y coordinate change from the single number specifying direction"
  (cond
    ((eql dir 1) (values-list '(-1 1)))
    ((eql dir 2) (values-list '(0 1)))
    ((eql dir 3) (values-list '(1 1)))
    ((eql dir 4) (values-list '(-1 0)))
    ((eql dir 5) (values-list '(0 0)))
    ((eql dir 6) (values-list '(1 0)))
    ((eql dir 7) (values-list '(-1 -1)))
    ((eql dir 8) (values-list '(0 -1)))
    ((eql dir 9) (values-list '(1 -1)))
    (t (error "Wrong direction supplied!!!"))))

(defun check-surroundings (x y include-center func)
  (dotimes (x1 3)
    (dotimes (y1 3)
      (when include-center
	(funcall func (+ (1- x) x1) (+ (1- y) y1)))
      (when (and (eql include-center nil)
		 (or (/= (+ (1- x) x1) x) (/= (+ (1- y) y1) y)))
	(funcall func (+ (1- x) x1) (+ (1- y) y1))))))

(defun print-visible-message (x y level str)
  (when (get-single-memo-visibility (get-memo-* level x y))
    (add-message str)))

(defun check-move-on-level (mob dx dy)
  ;;(format t "CHECK-MOVE-ON-LEVEL: inside~%")
  ;; trying to move beyound the level border 
  (when (or (< dx 0) (< dy 0) (>= dx *max-x-level*) (>= dy *max-y-level*)) (return-from check-move-on-level nil))
  ;; checking for obstacle
  (when (get-terrain-type-trait (get-terrain-* (level *world*) dx dy) +terrain-trait-blocks-move+)
    (return-from check-move-on-level 'obstacle))
  ;; checking for mobs
  ;(format t "Obstacle = ~%")
  (when (and (get-mob-* (level *world*) dx dy)
             (not (eq (get-mob-* (level *world*) dx dy) mob)))
    (return-from check-move-on-level (get-mob-* (level *world*) dx dy)))
  
  ;; all checks passed - can move freely
  (return-from check-move-on-level t))

(defun set-mob-location (mob x y)
  (when (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) (x mob) (y mob))))
    (funcall (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) (x mob) (y mob)))) mob (x mob) (y mob)))
  (setf (aref (mobs (level *world*)) (x mob) (y mob)) nil)
  (setf (x mob) x (y mob) y)
  (setf (aref (mobs (level *world*)) x y) (id mob))
  (when (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) (x mob) (y mob))))
    (funcall (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) (x mob) (y mob)))) mob (x mob) (y mob))))

(defun move-mob (mob dir)
  ;;(format t "MOVE-MOB: inside ~A~%" dir)
  (progn
    (multiple-value-bind (dx dy) (x-y-dir dir)
      (declare (type fixnum dx dy))
      (let* ((x (+ dx (x mob))) (y (+ dy (y mob)))
	     (check-result (check-move-on-level mob x y)))
	(declare (type fixnum x y))
	(cond
	  ;; all clear - move freely
	  ((eq check-result t)

           (set-mob-location mob x y)
           
	   (make-act mob (move-spd (get-mob-type-by-id (mob-type mob))))
           (return-from move-mob t)
           )
          ;; bumped into a mob
	  ((typep check-result 'mob) 
           (logger (format nil "MOVE-MOB: ~A [~A] bumped into a mob ~A [~A]~%" (name mob) (id mob) (name check-result) (id check-result))) 
           (on-bump check-result mob)
           (return-from move-mob t))
	  ))))
  nil)

(defun make-act (mob speed)
  ;;(format t "MAKE-ACT: ~A SPD ~A~%" (name mob) speed)
  (when (zerop speed) (return-from make-act nil))
  (decf (cur-ap mob) speed)
  (setf (made-turn mob) t)
  (when (eq mob *player*)
    (incf (player-game-time *world*) speed)))

(defmethod on-bump ((target mob) (actor mob))
  (if (eql target actor)
      (progn
        (make-act actor (move-spd (get-mob-type-by-id (mob-type actor)))))
      (progn 
        (logger (format nil "ON-BUMP: ~A [~A] bumped into ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
        
        ;; if they are of the same faction and do not like infighting - do nothing
        (when (and (= (faction actor) (faction target))
                   (not (mob-ability-p actor +mob-abil-loves-infighting+)))
          (logger (format nil "ON-BUMP: ~A [~A] and ~A [~A] are of the same faction and would not attack each other~%" (name actor) (id actor) (name target) (id target)))
          (make-act actor (move-spd (get-mob-type-by-id (mob-type actor))))
          (return-from on-bump t))
        
        (let ((abil-list nil))
          ;; collect all passive non-final on-touch abilities
          (setf abil-list (loop for abil-type-id in (get-mob-all-abilities actor)
                                when (and (abil-passive-p abil-type-id)
                                          (abil-on-touch-p abil-type-id)
                                          (not (abil-final-p abil-type-id)))
                                  collect abil-type-id))
          ;; invoke all applicable abilities
          (loop for abil-type-id in abil-list
                when (can-invoke-ability actor target abil-type-id)
                  do
                     (mob-invoke-ability actor target abil-type-id))
          )
        
        (let ((abil-list nil))
          ;; collect all passive final on-touch abilities
          (setf abil-list (loop for abil-type-id in (get-mob-all-abilities actor)
                                when (and (abil-passive-p abil-type-id)
                                          (abil-on-touch-p abil-type-id)
                                          (abil-final-p abil-type-id))
                                  collect abil-type-id))
          
          ;; invoke first applicable ability 
          (loop for abil-type-id in abil-list
                when (can-invoke-ability actor target abil-type-id)
                  do
                     (mob-invoke-ability actor target abil-type-id)
                     (return-from on-bump t))
          )
        
        ;; if no abilities could be applied - melee target
        (melee-target actor target)
        ;; if the target is killed without purging - the slave mob also dies
        (when (and (check-dead target)
                   (mob-effect-p target +mob-effect-possessed+))
          (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
          (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil))
        )))
                     
(defun mob-depossess-target (actor)
  (logger (format nil "MOB-DEPOSSESS-TARGET: Master ~A [~A], slave [~A]~%" (name actor) (id actor) (slave-mob-id actor)))
  (let ((target (get-mob-by-id (slave-mob-id actor))))
    (logger (format nil "MOB-DEPOSSESS-TARGET: ~A [~A] releases its possession of ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
    (setf (x target) (x actor) (y target) (y actor))
    (add-mob-to-level-list (level *world*) target)
    
  
    (setf (master-mob-id target) nil)
    (setf (slave-mob-id actor) nil)
    (setf (face-mob-type-id actor) (mob-type actor))
    (rem-mob-effect actor +mob-effect-possessed+)
    (rem-mob-effect target +mob-effect-possessed+)
    (rem-mob-effect target +mob-effect-reveal-true-form+)
  
    (print-visible-message (x actor) (y actor) (level *world*) 
                           (format nil "~A releases its possession of ~A.~%" (name actor) (name target)))
  
    ))

(defun mob-burn-blessing (actor target)
  (let ((cur-dmg))
    (setf cur-dmg (1+ (random 2)))
    (decf (cur-hp target) cur-dmg)
    ;; place a blood spattering
    (when (> cur-dmg 0)
      (let ((dir (1+ (random 9))))
        (multiple-value-bind (dx dy) (x-y-dir dir) 				
          (when (> 50 (random 100))
            (add-feature-to-level-list (level *world*) 
                                       (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy)))))))
    
    
    (print-visible-message (x target) (y target) (level *world*) 
                           (format nil "~A is scorched by ~A for ~A damage. " (name target) (name actor) cur-dmg))
    (when (check-dead target)
      (when (mob-effect-p target +mob-effect-possessed+)
        (mob-depossess-target target))
      
      (make-dead target :splatter t :msg t :msg-newline nil :killer actor)
      )
    (print-visible-message (x target) (y target) (level *world*) (format nil "~%"))
    ))

(defun mob-can-shoot (actor)
  (unless (is-weapon-ranged actor)
    (return-from mob-can-shoot nil))

  (if (not (zerop (get-ranged-weapon-charges actor)))
    t
    nil))

(defun mob-reload-ranged-weapon (actor)
  (unless (is-weapon-ranged actor)
    (return-from mob-reload-ranged-weapon nil))

  (logger (format nil "MOB-RELOAD: ~A [~A] reloads his ~A~%" (name actor) (id actor) (get-weapon-name actor)))
  
  (set-ranged-weapon-charges actor (get-ranged-weapon-max-charges actor))
  (print-visible-message (x actor) (y actor) (level *world*) 
                         (format nil "~A reloads his ~(~A~).~%" (name actor) (get-weapon-name actor)))

  (make-act actor +normal-ap+))

(defun mob-shoot-target (actor target)
  (let ((cur-dmg 0))
    ;; reduce the number of bullets in the magazine
    (set-ranged-weapon-charges actor (1- (get-ranged-weapon-charges actor)))
    
    ;; target under protection of divine shield - consume the shield and quit
    (when (mob-effect-p target +mob-effect-divine-shield+)
      (print-visible-message (x actor) (y actor) (level *world*) 
                             (format nil "~A shoots ~A, but can not harm ~A.~%" (name actor) (name target) (name target)))
      (rem-mob-effect target +mob-effect-divine-shield+)
      (make-act actor (att-spd actor))
      (return-from mob-shoot-target nil))
    
    (when (is-weapon-ranged actor)
      (setf cur-dmg (+ (random (- (1+ (get-ranged-weapon-dmg-max actor)) (get-ranged-weapon-dmg-min actor))) 
                               (get-ranged-weapon-dmg-min actor))))

    ;; reduce damage by the amount of armor
    (decf cur-dmg (cur-armor target))

    (when (< cur-dmg 0) (setf cur-dmg 0))
    (decf (cur-hp target) cur-dmg)
    
    ;; place a blood spattering
    (if (> (accuracy actor) (random 100))
      (progn
        (when (> cur-dmg 0)
          (let ((dir (1+ (random 9))))
            (multiple-value-bind (dx dy) (x-y-dir dir) 				
              (add-feature-to-level-list (level *world*) 
                                         (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy))))))
        
        (print-visible-message (x target) (y target) (level *world*) 
                               (format nil "~A shoots ~A for ~A damage. " (name actor) (name target) cur-dmg))
        (when (check-dead target)
          (make-dead target :splatter t :msg t :msg-newline nil :killer actor)
          
          (when (mob-effect-p target +mob-effect-possessed+)
            (setf (cur-hp (get-mob-by-id (slave-mob-id target))) 0)
            (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil))
          )
        (print-visible-message (x target) (y target) (level *world*) (format nil "~%")))
      (progn
        (print-visible-message (x target) (y target) (level *world*) 
                               (format nil "~A shoots ~A, but misses.~%" (name target) (name actor)))
        ))

    
    
    (make-act actor (att-spd actor))
    ))

(defun mob-invoke-ability (actor target ability-type-id)
  (when (can-invoke-ability actor target ability-type-id)
    (let ((ability-type (get-ability-type-by-id ability-type-id)))
      (funcall (on-invoke ability-type) ability-type actor target)
      (make-act actor (spd ability-type)))))


(defun melee-target (attacker target)
  (logger (format nil "MELEE-TARGET: ~A attacks ~A~%" (name attacker) (name target)))
  ;; no weapons - no attack
  (unless (weapon attacker) (return-from melee-target nil))

  ;; target under protection of divine shield - consume the shield and quit
  (when (mob-effect-p target +mob-effect-divine-shield+)
    (print-visible-message (x attacker) (y attacker) (level *world*) 
                           (format nil "~A attacks ~A, but can not harm ~A.~%" (name attacker) (name target) (name target)))
    (rem-mob-effect target +mob-effect-divine-shield+)
    (make-act attacker (att-spd attacker))
    (return-from melee-target nil)
    )

  ;; if the target has keen senses - destroy the illusions
  (when (mob-ability-p target +mob-abil-keen-senses+)
    (when (mob-effect-p attacker +mob-effect-divine-consealed+)
      (rem-mob-effect attacker +mob-effect-divine-consealed+)
      (setf (face-mob-type-id attacker) (mob-type attacker))
      (print-visible-message (x attacker) (y attacker) (level *world*) 
                             (format nil "~A reveals the true form of ~A. " (name target) (get-qualified-name attacker))))
    (when (mob-effect-p attacker +mob-effect-possessed+)
      (unless (mob-effect-p attacker +mob-effect-reveal-true-form+)
        (print-visible-message (x attacker) (y attacker) (level *world*) 
                               (format nil "~A reveals the true form of ~A. " (name target) (get-qualified-name attacker))))
      (setf (face-mob-type-id attacker) (mob-type attacker))
      (set-mob-effect attacker +mob-effect-reveal-true-form+ 5)))
  
  (multiple-value-bind (dx dy) (x-y-dir (1+ (random 9)))
    (let* ((cur-dmg) (dodge-chance) (failed-dodge nil) 
	   (x (+ dx (x target))) (y (+ dy (y target)))
	   (check-result (check-move-on-level target x y)))
      ;; check if attacker has hit the target
      (if (> (accuracy attacker) (random 100))
        (progn
          ;; attacker hit
          ;; check if the target dodged
          (setf dodge-chance (random 100))
          (if (and (> (cur-dodge target) dodge-chance) 
                   (eq check-result t))
            ;; target dodged
            (progn
              (set-mob-location target x y)
              ;(setf (x target) x (y target) y)
              (print-visible-message (x attacker) (y attacker) (level *world*) 
                                     (format nil "~A attacks ~A, but ~A evades the attack. " (name attacker) (name target) (name target))))
            ;; target did not dodge
            (progn
              (setf failed-dodge nil)
              (when (and (> (cur-dodge target) dodge-chance) (not (eq check-result t)))
                (print-visible-message (x attacker) (y attacker) (level *world*) 
                                       (format nil "~A attacks ~A, and ~A failes to dodge. " (name attacker) (name target) (name target)))
                (setf failed-dodge t))
              ;; apply damage
              (setf cur-dmg (+ (random (- (1+ (get-melee-weapon-dmg-max attacker)) (get-melee-weapon-dmg-min attacker))) 
                               (get-melee-weapon-dmg-min attacker)))
              
              (when (= (faction attacker) (faction target))
                (setf cur-dmg (get-melee-weapon-dmg-min attacker)))

              ;; reduce damage by the amount of armor
              (decf cur-dmg (cur-armor target))
              
              (when (< cur-dmg 0) (setf cur-dmg 0))
              (decf (cur-hp target) cur-dmg)
              ;; place a blood spattering
              (unless (zerop cur-dmg)
                (let ((dir (1+ (random 9))))
                  (multiple-value-bind (dx dy) (x-y-dir dir) 				
                    (when (> 50 (random 100))
                      (add-feature-to-level-list (level *world*) 
                                                 (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy)))))))
              (if (zerop cur-dmg)
                (print-visible-message (x attacker) (y attacker) (level *world*) 
                                       (format nil "~A hits ~A, but ~A is not hurt. " (name attacker) (name target) (name target)))
                (print-visible-message (x attacker) (y attacker) (level *world*) 
                                       (format nil "~A hits ~A for ~A damage. " (name attacker) (name target) cur-dmg)))
              )))
        (progn
          ;; attacker missed
          (print-visible-message (x attacker) (y attacker) (level *world*) (format nil "~A misses ~A. " (name attacker) (name target)))
          ))
      ))
  (when (check-dead target)
    (make-dead target :splatter t :msg t :msg-newline nil :killer attacker)
    )
  (print-visible-message (x attacker) (y attacker) (level *world*) (format nil "~%"))
  (make-act attacker (att-spd attacker))
  )

(defun check-dead (mob)
  (when (<= (cur-hp mob) 0)
    (return-from check-dead t))
  nil)

(defun make-dead (mob &key (splatter t) (msg nil) (msg-newline nil) (killer nil))
  (when msg
    (print-visible-message (x mob) (y mob) (level *world*) (format nil "~A dies. " (name mob)))
    (when msg-newline (print-visible-message (x mob) (y mob) (level *world*) (format nil "~%"))))
  
  (unless (dead= mob)
    (when (mob-ability-p mob +mob-abil-human+)
      (decf (total-humans *world*)))
    (when (mob-ability-p mob +mob-abil-demon+)
      (decf (total-demons *world*)))
    (when (mob-ability-p mob +mob-abil-angel+)
      (decf (total-angels *world*)))
    (when (mob-effect-p mob +mob-effect-blessed+)
      (decf (total-blessed *world*)))

    ;; apply all on-kill abilities of the killer 
    (when killer
      
      (when (or (and (mob-ability-p killer +mob-abil-angel+)
                     (mob-ability-p mob +mob-abil-demon+))
                (and (mob-ability-p killer +mob-abil-demon+)
                     (mob-ability-p mob +mob-abil-angel+))
                (and (mob-ability-p killer +mob-abil-demon+)
                     (mob-ability-p mob +mob-abil-human+))
                (and (mob-ability-p killer +mob-abil-demon+)
                     (mob-ability-p mob +mob-abil-demon+)))
        (logger (format nil "MAKE-DEAD: ~A [~A] Real mob strength to be transferred to the killer ~A [~A] is ~A~%" (name mob) (id mob) (name killer) (id killer) (strength (get-mob-type-by-id (mob-type mob)))))
        (incf (cur-fp killer) (1+ (strength (get-mob-type-by-id (mob-type mob))))))
      
      (if (gethash (mob-type mob) (stat-kills killer))
        (incf (gethash (mob-type mob) (stat-kills killer)))
        (setf (gethash (mob-type mob) (stat-kills killer)) 1))
      
      ;;(format t "KILLER STATS: ~A [~A] killed ~A~%" (name killer) (id killer) (calculate-total-kills killer))
      
      (let ((abil-list nil))
        ;; collect all passive on-kill abilities
        (setf abil-list (loop for abil-type-id in (get-mob-all-abilities killer)
                              when (and (abil-passive-p abil-type-id)
                                        (abil-on-kill-p abil-type-id))
                                collect abil-type-id))
        ;; invoke all applicable abilities
        (loop for abil-type-id in abil-list
              when (can-invoke-ability killer mob abil-type-id)
                do
                   (mob-invoke-ability killer mob abil-type-id))
        ))

    (remove-mob-from-level-list (level *world*) mob)
    
    ;; place blood stain if req
    (when (and splatter (< (random 100) 75))
      (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-stain+ :x (x mob) :y (y mob))))
    
    (setf (dead= mob) t))
  )

(defun mob-evolve (mob)
  (print-visible-message (x mob) (y mob) (level *world*) (format nil "~A assumes a superior form of ~A! " (name mob) (name (get-mob-type-by-id (evolve-into mob)))))
  
  (setf (mob-type mob) (evolve-into mob))
  (setf (cur-hp mob) (max-hp mob))
  (setf (cur-fp mob) 0)
  
  (setf (cur-sight mob) (base-sight mob))
  
  (setf (face-mob-type-id mob) (mob-type mob))
  (when (= (mob-type mob) +mob-type-demon+) 
    (set-name mob)
    (unless (eq mob *player*)
      (print-visible-message (x mob) (y mob) (level *world*) (format nil "It will be hereby known as ~A! " (name mob)))))
  
  (set-cur-weapons mob)
  (adjust-attack-speed mob)
  (adjust-dodge mob)
  (adjust-armor mob)
  (adjust-accuracy mob)
  
  (when (mob-effect-p mob +mob-effect-possessed+)
    (setf (cur-hp (get-mob-by-id (slave-mob-id mob))) 0)
    (make-dead (get-mob-by-id (slave-mob-id mob)) :splatter nil :msg nil :msg-newline nil)
    (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-stain+ :x (x mob) :y (y mob)))
    (print-visible-message (x mob) (y mob) (level *world*) (format nil "Its ascension destroyed its vessel."))
    
    (rem-mob-effect mob +mob-effect-possessed+)
    (setf (master-mob-id mob) nil)
    (setf (slave-mob-id mob) nil)
    )
  (print-visible-message (x mob) (y mob) (level *world*) (format nil "~%")))

(defgeneric on-tick (mob))

(defmethod on-tick ((mob mob))

  ;; increase cur-ap by max-ap
  (incf (cur-ap mob) (max-ap mob))
      
  (when (< (cur-fp mob) 0)
    (setf (cur-fp mob) 0))

  (when (mob-effect-p mob +mob-effect-reveal-true-form+)
    (set-mob-effect mob +mob-effect-reveal-true-form+ (1- (mob-effect-p mob +mob-effect-reveal-true-form+)))
    (when (zerop (mob-effect-p mob +mob-effect-reveal-true-form+))
      (rem-mob-effect mob +mob-effect-reveal-true-form+)
      (when (slave-mob-id mob)
        (setf (face-mob-type-id mob) (mob-type (get-mob-by-id (slave-mob-id mob)))))))

  (when (mob-effect-p mob +mob-effect-divine-shield+)
    (set-mob-effect mob +mob-effect-divine-shield+ (1- (mob-effect-p mob +mob-effect-divine-shield+)))
    (when (zerop (mob-effect-p mob +mob-effect-divine-shield+))
      (rem-mob-effect mob +mob-effect-divine-shield+)))

  (when (mob-effect-p mob +mob-effect-cursed+)
    (set-mob-effect mob +mob-effect-cursed+ (1- (mob-effect-p mob +mob-effect-cursed+)))
    (when (zerop (mob-effect-p mob +mob-effect-cursed+))
      (rem-mob-effect mob +mob-effect-cursed+)))
  
  (when (mob-effect-p mob +mob-effect-called-for-help+)
    (if (= (mob-effect-p mob +mob-effect-called-for-help+) 2)
      (set-mob-effect mob +mob-effect-called-for-help+ 1)
      (rem-mob-effect mob +mob-effect-called-for-help+)))
  (when (mob-effect-p mob +mob-effect-calling-for-help+)
    (if (= (mob-effect-p mob +mob-effect-calling-for-help+) 2)
      (set-mob-effect mob +mob-effect-calling-for-help+ 1)
      (rem-mob-effect mob +mob-effect-calling-for-help+)))

  (adjust-attack-speed mob)
  (adjust-dodge mob)
  (adjust-armor mob)
  (adjust-accuracy mob)
  
  (when (and (evolve-into mob)
             (>= (cur-fp mob) (max-fp mob)))
    (mob-evolve mob))
  )
  

(defun get-current-mob-glyph-idx (mob)
  (cond
    ((and (mob-effect-p mob +mob-effect-possessed+)
          (mob-effect-p mob +mob-effect-reveal-true-form+))
     (glyph-idx (get-mob-type-by-id (mob-type (get-mob-by-id (slave-mob-id mob))))))
    (t (glyph-idx (get-mob-type-by-id (face-mob-type-id mob))))))

(defun get-current-mob-glyph-color (mob)
  (cond
    ((and (mob-effect-p mob +mob-effect-possessed+)
          (mob-effect-p mob +mob-effect-reveal-true-form+))
     (glyph-color (get-mob-type-by-id (mob-type mob)))
     )
    ((and (mob-effect-p mob +mob-effect-possessed+)
          (= (faction *player*) (faction mob)))
     (glyph-color (get-mob-type-by-id (mob-type mob))))
    ((and (mob-ability-p *player* +mob-abil-angel+)
          (= (faction *player*) (faction mob)))
     (glyph-color (get-mob-type-by-id (mob-type mob))))
    ((mob-effect-p mob +mob-effect-blessed+)
     sdl:*blue*)
    (t (glyph-color (get-mob-type-by-id (face-mob-type-id mob))))))

(defun get-current-mob-back-color (mob)
  (back-color (get-mob-type-by-id (face-mob-type-id mob))))

(defun get-current-mob-name (mob)
  (cond
    ;; player always knows himself
    ((eq mob *player*)
     (get-qualified-name mob))
    ;; revealed demons show their true name
    ((and (mob-effect-p mob +mob-effect-possessed+)
          (mob-effect-p mob +mob-effect-reveal-true-form+))
     (get-qualified-name mob))
    ;; demons know true names of each other
    ((and (mob-ability-p mob +mob-abil-demon+)
          (mob-ability-p *player* +mob-abil-demon+))
     (get-qualified-name mob))
    ;; angels know true names of each other
    ((and (mob-ability-p mob +mob-abil-angel+)
          (mob-ability-p *player* +mob-abil-angel+))
     (get-qualified-name mob))
    ;; in all other cases see current appearence name
    (t (name (get-mob-type-by-id (face-mob-type-id mob))))))


(defgeneric on-bump (target actor))

(defun sense-evil ()
  (setf (sense-evil-id *player*) nil)
  (let ((nearest-enemy))
    (setf nearest-enemy (loop for mob-id in (mob-id-list (level *world*))
                              for mob = (get-mob-by-id mob-id)
                              with nearest-mob = nil
                              when (and (not (check-dead mob))
                                        (mob-ability-p mob +mob-abil-demon+))
                                do
                                   (unless nearest-mob (setf nearest-mob mob))
                                   (when (< (get-distance (x *player*) (y *player*) (x mob) (y mob))
                                            (get-distance (x *player*) (y *player*) (x nearest-mob) (y nearest-mob)))
                                     (setf nearest-mob mob))
                              finally (return nearest-mob)))
    (when nearest-enemy
      (setf (sense-evil-id *player*) (id nearest-enemy)))))

(defun sense-good ()
  (let ((nearest-enemy))
    (setf nearest-enemy (loop for mob-id in (mob-id-list (level *world*))
                              for mob = (get-mob-by-id mob-id)
                              with nearest-mob = nil
                              when (and (not (check-dead mob))
                                        (mob-ability-p mob +mob-abil-angel+))
                                do
                                   (unless nearest-mob (setf nearest-mob mob))
                                   (when (< (get-distance (x *player*) (y *player*) (x mob) (y mob))
                                            (get-distance (x *player*) (y *player*) (x nearest-mob) (y nearest-mob)))
                                     (setf nearest-mob mob))
                              finally (return nearest-mob)))
    (when nearest-enemy
      (setf (sense-good-id *player*) (id nearest-enemy)))))



