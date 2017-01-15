(in-package :cotd)

(defgeneric ai-function (mob))

(defun check-move-for-ai (mob dx dy)
  ;; cant move beyond level borders 
  (when (or (< dx 0) (< dy 0) (>= dx *max-x-level*) (>= dy *max-y-level*)) (return-from check-move-for-ai nil))
  
  ;; checking for terrain obstacle
  (when (get-terrain-type-trait (get-terrain-* (level *world*) dx dy) +terrain-trait-blocks-move+) 
    (return-from check-move-for-ai nil))
  
  ;; checking for mobs
  (let ((target (get-mob-* (level *world*) dx dy)))
    (cond
      ;; if self - can move
      ((eq mob target) (return-from check-move-for-ai t))
      ;; allied faction & does not give blessings - need to go around
      ;((and target
      ;      (get-faction-relation (faction mob) (faction target))
      ;      (not (mob-ai-wants-bless-p mob))) (return-from check-move-for-ai nil))
      ;; otherwise (enemies, etc) - can move
      (t (return-from check-move-for-ai t))))
  )



(defun ai-mob-flee (mob nearest-enemy)
  (unless nearest-enemy
    (return-from ai-mob-flee nil))
  
  (logger (format nil "AI-FUNCTION: ~A [~A] tries to flee away from ~A [~A].~%" (name mob) (id mob) (name nearest-enemy) (id nearest-enemy)))
  
  (let ((step-x 0) 
        (step-y 0))

    (setf (path mob) nil)
    (setf step-x (if (> (x nearest-enemy) (x mob)) -1 1))
    (setf step-y (if (> (y nearest-enemy) (y mob)) -1 1))
    (move-mob mob (x-y-into-dir step-x step-y))
    
    ;; if can't move away - try any random direction
    (when (<= (action-delay mob) 0)
      (logger (format nil "AI-FUNCTION: ~A [~A] could not flee. Try to move randomly.~%" (name mob) (id mob)))
      (ai-mob-random-dir mob))
    ))

(defun ai-mob-random-dir (mob)
  (loop while (<= (action-delay mob) 0) do
    (let ((dir (+ (random 9) 1)))
      (logger (format nil "AI-FUNCTION: ~A [~A] tries to move randomly.~%" (name mob) (id mob)))
      (move-mob mob dir))))

(defmethod ai-function ((mob mob))
  (declare (optimize (speed 3)))
  (logger (format nil "~%AI-Function Computer ~A [~A]~%" (name mob) (id mob)))
  
  ;; skip and invoke the master AI
  (when (master-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A], skipping its turn.~%" (name mob) (id mob) (name (get-mob-by-id (master-mob-id mob))) (master-mob-id mob)))
    (make-act mob +normal-ap+)
    (return-from ai-function nil))
  
  (update-visible-mobs mob)

  ;; if the mob possesses smb, there is a chance that the slave will revolt and move randomly
  (when (and (slave-mob-id mob)
             (zerop (random (* *possessed-revolt-chance* (mob-ability-p mob +mob-abil-can-possess+)))))
    (logger (format nil "AI-FUNCTION: ~A [~A] is revolting against ~A [~A].~%" (name (get-mob-by-id (slave-mob-id mob))) (slave-mob-id mob) (name mob) (id mob)))
    (print-visible-message (x mob) (y mob) (level *world*) 
                           (format nil "~A revolts against ~A.~%" (name (get-mob-by-id (slave-mob-id mob))) (name mob)))
    (setf (path mob) nil)
    (ai-mob-random-dir mob)
    (return-from ai-function nil)
    )
  
  ;; calculate a list of hostile & allied mobs
  (let ((hostile-mobs nil)
        (allied-mobs nil)
        (nearest-enemy nil)
        (nearest-ally nil)
        (nearest-target nil))
    (loop 
      for mob-id of-type fixnum in (visible-mobs mob)
      with vis-mob-type = nil
      do
         ;; inspect a mob appearance
         (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id (get-mob-by-id mob-id))))
         ;; however is you are of the same faction, you know who is who
         (when (= (faction mob) (faction (get-mob-by-id mob-id)))
           (setf vis-mob-type (get-mob-type-by-id (mob-type (get-mob-by-id mob-id)))))
                  
         (if (get-faction-relation (faction mob) (faction vis-mob-type))
           (progn
             (pushnew mob-id allied-mobs)
             ;; find the nearest allied mob
             (unless nearest-ally
               (setf nearest-ally (get-mob-by-id mob-id)))
             (when (< (get-distance (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)) (x mob) (y mob))
                      (get-distance (x nearest-ally) (y nearest-ally) (x mob) (y mob)))
               (setf nearest-ally (get-mob-by-id mob-id)))
             )
           (progn
             (pushnew mob-id hostile-mobs)
             
             ;; find the nearest hostile mob
             (unless nearest-enemy
               (setf nearest-enemy (get-mob-by-id mob-id)))
             (when (< (get-distance (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)) (x mob) (y mob))
                      (get-distance (x nearest-enemy) (y nearest-enemy) (x mob) (y mob)))
               (setf nearest-enemy (get-mob-by-id mob-id)))
             )))

    ;; by default, the target is the enemy
    (setf nearest-target nearest-enemy)
    
    ;; if the mob is coward, move away from the nearest enemy
    (when (and nearest-enemy (mob-ai-coward-p mob))
      (logger (format nil "AI-FUNCTION: ~A [~A] is a coward with an enemy ~A [~A] in sight.~%" (name mob) (id mob) (name nearest-target) (id nearest-target)))
      
      (ai-mob-flee mob nearest-enemy)      
      (return-from ai-function)
      )
    
    ;; if the mob has horde behavior, compare relative strengths of allies to relative strength of enemies
    ;; if less - flee
    (when (mob-ai-horde-p mob)
      (let ((ally-str (strength mob))
            (enemy-str 0))
        (declare (type fixnum ally-str enemy-str))
        (dolist (ally-id allied-mobs)
          (declare (type fixnum ally-id))
          (incf ally-str (strength (get-mob-by-id ally-id))))
        (dolist (enemy-id hostile-mobs)
          (incf enemy-str (strength (get-mob-type-by-id (face-mob-type-id (get-mob-by-id enemy-id))))))
      
        (logger (format nil "AI-FUNCTION: ~A [~A] has horde behavior. Ally vs. Enemy strength is ~A vs ~A.~%" (name mob) (id mob) ally-str enemy-str))

        (when (< ally-str enemy-str)
          ;; allied strength is less - flee
          (ai-mob-flee mob nearest-enemy)
          (return-from ai-function)))
      )
    
    ;; if the mob wants to give blessings, find the nearest unblessed ally
    ;; if it is closer than the enemy, go to it
    (when (mob-ai-wants-bless-p mob)
      (let ((nearest-ally nil))
        (loop 
          for mob-id in allied-mobs
          with vis-mob-type = nil
          do
             (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id (get-mob-by-id mob-id))))
              ;; when you are of the same faction, you know who is who
             (when (= (faction mob) (faction (get-mob-by-id mob-id)))
               (setf vis-mob-type (get-mob-type-by-id (mob-type (get-mob-by-id mob-id)))))
             
             ;; find the nearest allied unblessed mob mob
             (when (and (mob-ability-p vis-mob-type +mob-abil-can-be-blessed+)
                        (not (mob-effect-p (get-mob-by-id mob-id) +mob-effect-blessed+)))
               (unless nearest-ally
                 (setf nearest-ally (get-mob-by-id mob-id)))
               (when (< (get-distance (x (get-mob-by-id mob-id)) (y (get-mob-by-id mob-id)) (x mob) (y mob))
                        (get-distance (x nearest-ally) (y nearest-ally) (x mob) (y mob)))
                 (setf nearest-ally (get-mob-by-id mob-id))))
          ) 
        (logger (format nil "AI-FUNCTION: ~A [~A] wants to give blessings. Nearest unblessed ally ~A [~A]~%" (name mob) (id mob) (if nearest-ally (name nearest-ally) nil) (if nearest-ally (id nearest-ally) nil)))
        (when (or (and nearest-ally
                       (not nearest-enemy))
                  (and nearest-ally
                       nearest-enemy
                       (< (get-distance (x mob) (y mob) (x nearest-ally) (y nearest-ally))
                          (get-distance (x mob) (y mob) (x nearest-enemy) (y nearest-enemy)))))
          (logger (format nil "AI-FUNCTION: ~A [~A] changed target ~A [~A].~%" (name mob) (id mob) (name nearest-ally) (id nearest-ally)))
          (setf nearest-target nearest-ally))
        ))

    ;; if the mob wants to stop when enemy is in sight, set target to nil
    (when (mob-ai-stop-p mob)
      (when nearest-enemy
        (logger (format nil "AI-FUNCTION: ~A [~A] stop when seeing ~A [~A].~%" (name mob) (id mob) (name nearest-enemy) (id nearest-enemy)))
        (setf nearest-target nil)
        ))
    
    
    ;; got to the nearest target
    (when nearest-target
      (logger (format nil "AI-FUNCTION: Target found ~A [~A]~%" (name nearest-target) (id nearest-target)))
      (let ((path nil))
       
        (setf path (a-star (list (x mob) (y mob)) (list (x nearest-target) (y nearest-target)) 
                           #'(lambda (dx dy) 
                               ;; checking for impassable objects
                               (check-move-for-ai mob dx dy)
                               )))
        
        (logger (format nil "AI-FUNCTION: Mob - (~A ~A) Target - (~A ~A)~%" (x mob) (y mob) (x nearest-target) (y nearest-target)))
	(logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
        (pop path)
        
	(setf (path mob) path)
        
        ))
    
    ;; move to some random passable terrain 
    ;; a hack to easy the strain of pathfinding during the first turns - if you are human and there are more than 100 of you, do not pathfind
    ;(when (not (and (mob-ability-p mob +mob-abil-human+) (> (total-humans *world*) 10)))
      (unless (path mob)
        (let ((rx (- (+ 10 (x mob))
                     (1+ (random 20)))) 
              (ry (- (+ 10 (y mob))
                     (1+ (random 20))))
              (path nil))
          (declare (type integer rx ry))
          
          (loop while (or (< rx 0) (< ry 0) (>= rx *max-x-level*) (>= ry *max-y-level*)
                          (get-terrain-type-trait (get-terrain-* (level *world*) rx ry) +terrain-trait-blocks-move+)
                          (and (get-mob-* (level *world*) rx ry)
                               (not (eq (get-mob-* (level *world*) rx ry) mob))))
                do
                   (setf rx (- (+ 10 (x mob))
                               (1+ (random 20))))
                   (setf ry (- (+ 10 (y mob))
                               (1+ (random 20)))))
          (logger (format nil "AI_FUNCTION: Mob (~A, ~A) wants to go to (~A, ~A)~%" (x mob) (y mob) rx ry))
          (setf path (a-star (list (x mob) (y mob)) (list rx ry) 
                             #'(lambda (dx dy) 
                                 ;; checking for impassable objects
                                 (check-move-for-ai mob dx dy)
                                 )))
          
          (pop path)
          (logger (format nil "AI-FUNCTION: Mob goes to (~A ~A)~%" rx ry))
          (logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
          (setf (path mob) path)
          
          ))
    ;)
    
    ;; call for reinforcements if there is a threatening enemy in sight and hp < 50% and you are not the last one
    (when (and nearest-enemy
               (not (zerop (strength nearest-enemy)))
               (< (/ (cur-hp mob) (max-hp mob)) 
                  0.5)
               (mob-ability-p mob +mob-abil-call-for-help+)
               (can-invoke-ability mob mob +mob-abil-call-for-help+)
               (> (total-demons *world*) 1))
      (logger (format nil "AI-FUNCTION: ~A [~A] decides to call for help~%" (name mob) (id mob)))
      (mob-invoke-ability mob mob +mob-abil-call-for-help+)
      (return-from ai-function))

    ;; for satanists: call for reinforcements whenever there is a threatening enemy in sight and there still demons out there
    (when (and nearest-enemy
               (not (zerop (strength nearest-enemy)))
               (mob-ability-p mob +mob-abil-free-call+)
               (can-invoke-ability mob mob +mob-abil-free-call+)
               (> (total-demons *world*) 0))
      (logger (format nil "AI-FUNCTION: ~A [~A] decides to call for help~%" (name mob) (id mob)))
      (mob-invoke-ability mob mob +mob-abil-free-call+)
      (return-from ai-function))

    ;; for satanists: if able to curse - do it
    (when (and (mob-ability-p mob +mob-abil-curse+)
               (can-invoke-ability mob mob +mob-abil-curse+)
               nearest-enemy
               (zerop (random 3)))
      (logger (format nil "AI-FUNCTION: ~A [~A] decides to curse~%" (name mob) (id mob)))
      (mob-invoke-ability mob mob +mob-abil-curse+)
      (return-from ai-function))
    
    ;; answer the call if there is no enemy in sight
    (unless nearest-enemy
      (when (and (mob-ability-p mob +mob-abil-answer-the-call+)
                 (can-invoke-ability mob mob +mob-abil-answer-the-call+))
        (logger (format nil "AI-FUNCTION: ~A [~A] decides to answer the call for help~%" (name mob) (id mob)))
        (mob-invoke-ability mob mob +mob-abil-answer-the-call+)
        (return-from ai-function))
      )

    ;; if able to heal and less than 50% hp - heal
    (when (and (< (/ (cur-hp mob) (max-hp mob)) 
                  0.5)
               (mob-ability-p mob +mob-abil-heal-self+))
      (when (can-invoke-ability mob mob +mob-abil-heal-self+)
        (logger (format nil "AI-FUNCTION: ~A [~A] decides to heal itself~%" (name mob) (id mob)))
        (mob-invoke-ability mob mob +mob-abil-heal-self+)
        (return-from ai-function))
      
      ;; if able to heal and need to reveal itself - do it 
      (when (and (mob-effect-p mob +mob-effect-divine-consealed+)
                 (mob-ability-p mob +mob-abil-reveal-divine+)
                 (can-invoke-ability mob mob +mob-abil-reveal-divine+)
                 (abil-applic-cost-p +mob-abil-heal-self+ mob))
        (logger (format nil "AI-FUNCTION: ~A [~A] decides to reveal itself, in order to heal~%" (name mob) (id mob)))
        (mob-invoke-ability mob mob +mob-abil-reveal-divine+)
        (return-from ai-function)
        )
      )

    ;; if able to pray - do it
    (when (and (mob-ability-p mob +mob-abil-prayer-bless+)
               (can-invoke-ability mob mob +mob-abil-prayer-bless+)
               (or nearest-enemy
                   (zerop (random 5))))
      (logger (format nil "AI-FUNCTION: ~A [~A] decides to pray for smiting~%" (name mob) (id mob)))
      (mob-invoke-ability mob mob +mob-abil-prayer-bless+)
      (return-from ai-function))
    
    (when (and (mob-ability-p mob +mob-abil-prayer-shield+)
               (can-invoke-ability mob mob +mob-abil-prayer-shield+)
               (zerop (random 3)))
      (logger (format nil "AI-FUNCTION: ~A [~A] decides to pray for shielding~%" (name mob) (id mob)))
      (mob-invoke-ability mob mob +mob-abil-prayer-shield+)
      (return-from ai-function))
    
    ;; if the mob has its path set - move along it
    (when (path mob)
      ;; if the dst is more than 3 tiles away - stealth, if possible
      ;;(format t "AI-FUNCTION: (length (path mob)) ~A, (mob-ability-p mob +mob-abil-conseal-divine+) ~A, (can-invoke-ability mob +mob-abil-conseal-divine+) ~A~%" 
      ;;        (length (path mob)) (mob-ability-p mob +mob-abil-conseal-divine+) (can-invoke-ability mob +mob-abil-conseal-divine+))
      (when (and (> (length (path mob)) 3)
                 (mob-ability-p mob +mob-abil-conseal-divine+)
                 (can-invoke-ability mob mob +mob-abil-conseal-divine+))
        (logger (format nil "AI-FUNCTION: ~A [~A] decides to conseal its divinity~%" (name mob) (id mob)))
        (mob-invoke-ability mob mob +mob-abil-conseal-divine+)
        (return-from ai-function))

      ;; if the dst tile is less than 2 tiles away - unstealth, if possible
      (when (and (<= (length (path mob)) 1)
                 (mob-ability-p mob +mob-abil-reveal-divine+)
                 (can-invoke-ability mob mob +mob-abil-reveal-divine+))
        (logger (format nil "AI-FUNCTION: ~A [~A] decides to reveal its divinity~%" (name mob) (id mob)))
        (mob-invoke-ability mob mob +mob-abil-reveal-divine+)
        (return-from ai-function))
      
      (let ((step) (step-x) (step-y))
        
        (logger (format nil "AI-FUNCTION: Move mob along the path - ~A~%" (path mob)))
        (setf step (pop (path mob)))
        
        ;; if there is suddenly an obstacle, make the path recalculation
     	(setf step-x (- (first step) (x mob)))
	(setf step-y (- (second step) (y mob)))
	
        (unless (check-move-on-level mob (first step) (second step))
          (logger (format nil "AI-FUNCTION: Can't move to target - (~A ~A)~%" (first step) (second step)))
          (setf (path mob) nil)
          (return-from ai-function))
        
        (unless (x-y-into-dir step-x step-y)
          (logger (format nil "AI-FUNCTION: Wrong direction supplied (~A ~A)~%" (first step) (second step)))
          (setf (path mob) nil)
          (return-from ai-function))
        
	(move-mob mob (x-y-into-dir step-x step-y))
        
        
	(return-from ai-function)))
    
    ;; if there are no hostile mobs move randomly
    ;; pester the AI until it makes some meaningful action
    (ai-mob-random-dir mob)
    )
  )
  

(defmethod ai-function ((player player))
  (logger (format nil "~%AI-FUnction Player~%"))
  ;(logger (format nil "TIME-ELAPSED: ~A~%" (- (get-internal-real-time) *time-at-end-of-player-turn*)))

  (format t "TIME-ELAPSED: ~A~%" (- (get-internal-real-time) *time-at-end-of-player-turn*))
  
  (update-visible-area (level *world*) (x player) (y player))
  
  (make-output *current-window*)
  
  
  

  ;; if possessed & unable to revolt - wait till the player makes a meaningful action
  ;; then skip and invoke the master AI
  (logger (format nil "AI-FUNCTION: MASTER ID ~A, SLAVE ID ~A~%" (master-mob-id player) (slave-mob-id player)))
  (when (master-mob-id player)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
    
    (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player))))
    
    (setf (can-move-if-possessed player) t)
    (loop while (can-move-if-possessed player) do
      (get-input-player))
        
    (if (zerop (random (* *possessed-revolt-chance* (mob-ability-p (get-mob-by-id (master-mob-id player)) +mob-abil-can-possess+))))
      (progn
        (logger (format nil "AI-FUNCTION: ~A [~A] revolts against ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
        
        (print-visible-message (x player) (y player) (level *world*) 
                               (format nil "~A revolts against ~A.~%" (name player) (name (get-mob-by-id (master-mob-id player))) ))
        (ai-mob-random-dir (get-mob-by-id (master-mob-id player)))
        (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player))))
        (setf (path (get-mob-by-id (master-mob-id player))) nil)
        (return-from ai-function nil)
        )
      (progn
        (logger (format nil "AI-FUNCTION: ~A [~A] was unable to revolt against ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
                
        (ai-function (get-mob-by-id (master-mob-id player)))
        
        (when (master-mob-id player)
          (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player)))))
        
        (make-act player +normal-ap+)
        (return-from ai-function nil)))
    )
  
  ;; if player possesses somebody & the slave revolts
  ;; wait for a meaningful action and move randomly instead 
  (when (slave-mob-id player)
    (when (zerop (random (* *possessed-revolt-chance* (mob-ability-p player +mob-abil-can-possess+))))
      (logger (format nil "AI-FUNCTION: ~A [~A] possesses ~A [~A], but the slave revolts.~%" (name player) (id player) (name (get-mob-by-id (slave-mob-id player))) (slave-mob-id player)))
      (setf (can-move-if-possessed player) t)
      (loop while (can-move-if-possessed player) do
        (get-input-player))
      
      (print-visible-message (x player) (y player) (level *world*) 
                             (format nil "~A revolts against ~A.~%" (name (get-mob-by-id (slave-mob-id player))) (name player)))
      (ai-mob-random-dir player)
      (return-from ai-function nil)
    ))
  
  ;; player is able to move freely
  ;; pester the player until it makes some meaningful action that can trigger the event chain
  (loop while (<= (action-delay player) 0) do
    (setf (can-move-if-possessed player) nil)
    (get-input-player))
  (setf *time-at-end-of-player-turn* (get-internal-real-time)))
