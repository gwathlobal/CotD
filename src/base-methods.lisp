(in-package :cotd)

(defun get-distance (sx sy tx ty)
  (declare (type fixnum sx sy tx ty))
  (sqrt (+ (* (- sx tx) (- sx tx)) (* (- sy ty) (- sy ty)))))

(defun find-free-id (hash-table)
  (do ((id 0 (+ id 1)))
      ((eql (gethash id hash-table) nil) id)))

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

(defun update-visible-mobs-normal-1 (mob)
  (draw-fov (x mob) (y mob) (cur-sight mob) #'(lambda (dx dy)
                                         (let ((terrain) (exit-result t))
                                           (block nil
                                             (when (or (< dx 0) (>= dx *max-x-level*)
                                                       (< dy 0) (>= dy *max-y-level*))
                                               (setf exit-result 'exit)
					       (return))
					 
                                             ;; checking for impassable objects
                                             (setf terrain (get-terrain-* (level *world*) dx dy))
                                             (unless terrain
                                               (setf exit-result 'exit)
					       (return))
					     (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
					       (setf exit-result 'exit)
					       (return))
                                             (when (and (get-mob-* (level *world*) dx dy) 
                                                        (not (eq (get-mob-* (level *world*) dx dy) mob))
                                                        )
                                               (pushnew (id (get-mob-* (level *world*) dx dy)) (visible-mobs mob)))
					     )
					   exit-result))))

(defun update-visible-mobs-normal-2 (mob)
  (loop 
    for mob-id in (mob-id-list (level *world*))
    with vmob = nil
    do
       (setf vmob (get-mob-by-id mob-id))
       ;(format t "LOS ~A dist ~A to (~A, ~A) vs sight ~A~%" (name mob) (get-distance (x mob) (y mob) (x vmob) (y mob)) (x vmob) (y vmob) (cur-sight mob))
       (when (and (not (check-dead vmob))
                  (not (eq mob vmob))
                  (<= (get-distance (x mob) (y mob) (x vmob) (y mob)) (cur-sight mob)))
         (let ((r 0))
                      
           ;;(format t "LOS ~A (~A, ~A) to (~A, ~A)~%" (name mob) (x mob) (y mob) (x vmob) (y vmob))
           
           
           (line-of-sight (x mob) (y mob) (x vmob) (y vmob) #'(lambda (dx dy)
                                                    (let ((terrain) (exit-result t))
                                                      (block nil
                                                        (when (or (< dx 0) (>= dx *max-x-level*)
                                                                  (< dy 0) (>= dy *max-y-level*))
                                                          (setf exit-result 'exit)
                                                          (return))
                                                        
                                                        (incf r)
                                                        
                                                        
                                                        ;; checking for impassable objects
                                                        (setf terrain (get-terrain-* (level *world*) dx dy))
                                                        (unless terrain
                                                          (setf exit-result 'exit)
                                                          (return))
                                                        (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
                                                          (setf exit-result 'exit)
                                                          (return))
                                                        (when (and (= dx (x vmob)) (= dy (y vmob)))
                                                          (pushnew (id vmob) (visible-mobs mob))
                                                          )
                                                                                                                
                                                        (when (> r (cur-sight mob))
                                                          (setf exit-result 'exit)
                                                          (return))
                                                        )
                                                      exit-result)))
           ))
    )
  )

(defun update-visible-mobs-normal (mob)
  (loop 
    for mob-id in (mob-id-list (level *world*))
    with vmob = nil
    do
       (setf vmob (get-mob-by-id mob-id))
       (when (and (not (check-dead vmob))
                  (not (eq mob vmob))
                  (<= (get-distance (x mob) (y mob) (x vmob) (y vmob)) (cur-sight mob)))
         (pushnew mob-id (visible-mobs mob)))
    )
  )

(defun update-visible-mobs-all (mob)
  (loop 
    for mob-id in (mob-id-list (level *world*))
    do
       (when (/= mob-id (id mob))
         (pushnew mob-id (visible-mobs mob)))))

(defun update-visible-mobs (mob)
  (setf (visible-mobs mob) nil)
  
  
  (if (mob-ability-p mob +mob-abil-see-all+)
    (update-visible-mobs-all mob)
    (update-visible-mobs-normal-2 mob))
  
  
  (when (eq mob *player*)
    (setf (view-x *player*) (x *player*))
    (setf (view-y *player*) (y *player*)))
  (logger (format nil "UPDATE-VISIBLE-MOBS: ~A [~A] sees ~A~%" (name mob) (id mob) (visible-mobs mob)))
  )


(defun check-move-on-level (mob dx dy)
  ;;(format t "CHECK-MOVE-ON-LEVEL: inside~%")
  ;; trying to move beyound the level border 
  (when (or (< dx 0) (< dy 0) (>= dx *max-x-level*) (>= dy *max-y-level*)) (return-from check-move-on-level nil))
  ;; checking for obstacle
  (when (get-terrain-type-trait (get-terrain-* (level *world*) dx dy) +terrain-trait-blocks-move+)
    (return-from check-move-on-level 'obstacle))
  ;; checking for mobs
  ;(format t "Obstacle = ~%")
  (dolist (mob-id (mob-id-list (level *world*)))
    
    (when (and (= dx (x (get-mob-by-id mob-id))) 
               (= dy (y (get-mob-by-id mob-id)))
	       (if (slave-mob-id (get-mob-by-id mob-id))
                 (/= (id mob) (slave-mob-id (get-mob-by-id mob-id)))
                 t))
      (return-from check-move-on-level (get-mob-by-id mob-id)))
    )
  ;; all checks passed - can move freely
  (return-from check-move-on-level t))

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
           (setf (x mob) x (y mob) y)
	   
	   (make-act mob (move-spd (get-mob-type-by-id (mob-type mob))))
           )
          ;; bumped into a mob
	  ((typep check-result 'mob) 
           (logger (format nil "MOVE-MOB: ~A [~A] bumped into a mob ~A [~A]~%" (name mob) (id mob) (name check-result) (id check-result))) 
           (on-bump check-result mob))
	  )))))

(defun make-act (mob speed)
  ;;(format t "MAKE-ACT: ~A SPD ~A~%" (name mob) speed)
  (when (mob-effect-p mob +mob-effect-reveal-true-form+)
    (set-mob-effect mob +mob-effect-reveal-true-form+ (1- (mob-effect-p mob +mob-effect-reveal-true-form+)))
    (when (zerop (mob-effect-p mob +mob-effect-reveal-true-form+))
      (rem-mob-effect mob +mob-effect-reveal-true-form+)
      (when (slave-mob-id mob)
        (setf (face-mob-type-id mob) (mob-type (get-mob-by-id (slave-mob-id mob)))))))
  (incf (action-delay mob) speed))

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

(defun mob-invoke-ability (actor target ability-type-id)
  (when (can-invoke-ability actor target ability-type-id)
    (let ((ability-type (get-ability-type-by-id ability-type-id)))
      (funcall (on-invoke ability-type) ability-type actor target)
      (make-act actor (spd ability-type)))))


(defun melee-target (attacker target)
  (logger (format nil "MELEE-TARGET: ~A attacks ~A~%" (name attacker) (name target)))
  ;; no weapons - no attack
  (unless (weapon attacker) (return-from melee-target nil))
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
              (setf (x target) x (y target) y)
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
              (setf cur-dmg (+ (random (- (1+ (get-weapon-dmg-max attacker)) (get-weapon-dmg-min attacker))) 
                               (get-weapon-dmg-min attacker)))
              
              (when (= (faction attacker) (faction target))
                (setf cur-dmg (get-weapon-dmg-min attacker)))
              
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
  (adjust-attack-speed mob)
  (adjust-dodge mob)
  (adjust-armor mob)
      
  (when (< (cur-fp mob) 0)
    (setf (cur-fp mob) 0))
  
  (when (mob-effect-p mob +mob-effect-called-for-help+)
    (if (= (mob-effect-p mob +mob-effect-called-for-help+) 2)
      (set-mob-effect mob +mob-effect-called-for-help+ 1)
      (rem-mob-effect mob +mob-effect-called-for-help+)))
  (when (mob-effect-p mob +mob-effect-calling-for-help+)
    (if (= (mob-effect-p mob +mob-effect-calling-for-help+) 2)
      (set-mob-effect mob +mob-effect-calling-for-help+ 1)
      (rem-mob-effect mob +mob-effect-calling-for-help+)))
  
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

(defun draw-fov (cx cy r func)
  (funcall func cx cy)
  (loop for i from 0 to 360 by 1 do
    (line-of-sight cx cy (+ cx (round (* r (cos (* i (/ pi 180)))))) (- cy (round (* r (sin (* i (/ pi 180 )))))) func)))

(defun line-of-sight (sx sy tx ty func)
  ;; stop at once if the starting point = target point
  (when (and (= sx tx) (= sy ty))
    (funcall func sx sy)
    (return-from line-of-sight nil))
 
   (let ((x 0) (y 0) (nx (1+ (abs (- sx tx)))) (ny (1+ (abs (- sy ty))))
	(px 1) (py 1) (slope) (ix) (iy))
    ;; determine the direction where to draw the line
    (cond
      ((> sx tx) (setf ix -1))
      ((= sx tx) (setf ix 0))
      (t (setf ix 1)))
    (cond
      ((> sy ty) (setf iy -1))
      ((= sy ty) (setf iy 0))
      (t (setf iy 1)))
    (if (>= nx ny) (setf slope (/ nx ny)) (setf slope (/ ny nx)))
    
    (if (>= nx ny)
	(progn (loop while (< (abs x) nx) do
		    (when (>= (abs x) (round (* slope py)))
		      (incf y iy)
		      (incf py))
		    
		    (when (eql (funcall func (+ sx x) (+ sy y)) 'exit) ;(format t "RET!~%") 
		      (return-from line-of-sight nil))
		    
		    (incf x ix)
		    ))
	(progn (loop while (< (abs y) ny) do
		    (when (>= (abs y) (round (* slope px)))
		      (incf x ix)
		      (incf px))
		    
		    (when (eql (funcall func (+ sx x) (+ sy y)) 'exit) ;(format t "RET!~%") 
			  (return-from line-of-sight nil))
		    
		    (incf y iy)
		    ))))
  t)

(defun update-visible-area-normal (level x y)
  (draw-fov x y (cur-sight *player*) #'(lambda (dx dy)
                                         (let ((terrain) (exit-result t))
                                           (block nil
                                             (when (or (< dx 0) (>= dx *max-x-level*)
                                                       (< dy 0) (>= dy *max-y-level*))
                                               (setf exit-result 'exit)
					       (return))
					 (when (<= (get-distance x y dx dy) (cur-sight *player*))
                                           ;; drawing terrain
                                           (set-single-memo-* level dx dy 
                                                              :glyph-idx (glyph-idx (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :glyph-color (glyph-color (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :back-color (back-color (get-terrain-type-by-id (aref (terrain level) dx dy)))
                                                              :visibility t
                                                              :revealed t)
                                           		
                                           ;; then feature, if any
                                           (when (get-features-* level dx dy)
                                             (let ((ftr (first (last (get-features-* level dx dy)))))
                                               
                                               (set-single-memo-* level 
                                                                  (x ftr) (y ftr) 
                                                                  :glyph-idx (if (glyph-idx (get-feature-type-by-id (feature-type ftr)))
                                                                               (glyph-idx (get-feature-type-by-id (feature-type ftr)))
                                                                               (get-single-memo-glyph-idx (get-memo-* level (x ftr) (y ftr))))
                                                                  :glyph-color (if (glyph-color (get-feature-type-by-id (feature-type ftr)))
                                                                                 (glyph-color (get-feature-type-by-id (feature-type ftr)))
                                                                                 (get-single-memo-glyph-color (get-memo-* level (x ftr) (y ftr))))
                                                                  :back-color (if (back-color (get-feature-type-by-id (feature-type ftr)))
                                                                                (back-color (get-feature-type-by-id (feature-type ftr)))
                                                                                (get-single-memo-back-color (get-memo-* level (x ftr) (y ftr))))
                                                                  :visibility t
                                                                  :revealed t)))
                                           ;; then mob, if any
                                           (when (get-mob-* level dx dy)
                                             (let ((vmob (get-mob-* level dx dy)))
                                               (set-single-memo-* level 
                                                                  (x vmob) (y vmob) 
                                                                  :glyph-idx (get-current-mob-glyph-idx vmob)
                                                                  :glyph-color (get-current-mob-glyph-color vmob)
                                                                  :back-color (get-current-mob-back-color vmob)
                                                                  :visibility t
                                                                  :revealed t))
                                             ))
					 ;; checking for impassable objects
					 					   	
					     (setf terrain (get-terrain-* level dx dy))
                                             (unless terrain
                                               (setf exit-result 'exit)
					       (return))
					     (when (get-terrain-type-trait terrain +terrain-trait-blocks-vision+)
                                               (setf exit-result 'exit)
					       (return))
                                             (when (and (get-mob-* level dx dy) 
                                                        (not (eq (get-mob-* level dx dy) *player*))
                                                        (get-single-memo-visibility (get-memo-* level dx dy)))
                                               (pushnew (id (get-mob-* level dx dy)) (visible-mobs *player*)))
					     )
					   exit-result))))

(defun update-visible-area-all (level x y)
  (declare (ignore x y))
  ;; update visible area
  (dotimes (x1 *max-x-level*)
    (dotimes (y1 *max-y-level*)
      (set-single-memo-* level x1 y1 
			 :glyph-idx (glyph-idx (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :glyph-color (glyph-color (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :back-color (back-color (get-terrain-type-by-id (aref (terrain level) x1 y1)))
			 :visibility t)
      ))
  (dolist (feature-id (feature-id-list level))
    (set-single-memo-* level 
		       (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)) 
		       :glyph-idx (if (glyph-idx (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				      (glyph-idx (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				      (get-single-memo-glyph-idx (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :glyph-color (if (glyph-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
					(glyph-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
					(get-single-memo-glyph-color (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :back-color (if (back-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				       (back-color (get-feature-type-by-id (feature-type (get-feature-by-id feature-id))))
				       (get-single-memo-back-color (get-memo-* level (x (get-feature-by-id feature-id)) (y (get-feature-by-id feature-id)))))
		       :visibility t))
  
  (dolist (mob-id (mob-id-list level))
    ;;(format t "MOB NAME ~A, MOB ID ~A, MOB X ~A, MOB Y ~A~%" (name (get-mob-by-id mob-id)) mob-id (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)))
    (set-single-memo-* level 
		       (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)) 
		       :glyph-idx (get-current-mob-glyph-idx (get-mob-by-id mob-id))
		       :glyph-color (get-current-mob-glyph-color (get-mob-by-id mob-id))
		       :back-color (get-current-mob-back-color (get-mob-by-id mob-id))
		       :visibility t)

    ))

(defun update-visible-area (level x y)
  ;; make the the whole level invisible
  (dotimes (x1 *max-x-level*)
    (dotimes (y1 *max-y-level*)
      (if (get-single-memo-revealed (get-memo-* level x1 y1))
        (set-single-memo-* level x1 y1 :glyph-color (sdl:color :r 100 :g 100 :b 100) :visibility nil)
        (set-single-memo-* level x1 y1 :visibility nil))
      ))

  
  (setf (visible-mobs *player*) nil)
  (if (mob-ability-p *player* +mob-abil-see-all+)
    (update-visible-area-all level x y)
    (update-visible-area-normal level x y))
  
  (logger (format nil "PLAYER-VISIBLE-MOBS: ~A~%" (visible-mobs *player*)))
  )


(defgeneric on-bump (target actor))




