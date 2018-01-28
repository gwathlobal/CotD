(in-package :cotd)

(defmethod ai-function ((mob mob))
  ;(declare (optimize (speed 3)))
  (logger (format nil "~%AI-Function Computer ~A [~A] (~A ~A ~A)~%" (name mob) (id mob) (x mob) (y mob) (z mob)))
  
  ;; skip and invoke the master AI
  (when (master-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A], skipping its turn.~%" (name mob) (id mob) (name (get-mob-by-id (master-mob-id mob))) (master-mob-id mob)))
    (make-act mob +normal-ap+)
    (return-from ai-function nil))

  (when (and (path-dst mob)
             (= (x mob) (first (path-dst mob)))
             (= (y mob) (second (path-dst mob)))
             (= (z mob) (third (path-dst mob))))
            (setf (path-dst mob) nil))
  
  ;; skip turn if being ridden
  (when (mounted-by-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being ridden by ~A [~A], moving according to the direction.~%" (name mob) (id mob) (name (get-mob-by-id (mounted-by-mob-id mob))) (mounted-by-mob-id mob)))
    (move-mob mob (x-y-into-dir 0 0))
    (return-from ai-function nil)
    )
    
  
  (update-visible-mobs mob)
  (update-visible-items mob)

  ;; if the mob is blind - move in random direction
  (when (mob-effect-p mob +mob-effect-blind+)
    (logger (format nil "AI-FUNCTION: ~A [~A] is blind, moving in random direction.~%" (name mob) (id mob)))
    (ai-mob-random-dir mob)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob is confused - 33% chance to move in random direction
  (when (and (mob-effect-p mob +mob-effect-confuse+)
             (zerop (random 2)))
    (logger (format nil "AI-FUNCTION: ~A [~A] is confused, moving in random direction.~%" (name mob) (id mob)))
    (ai-mob-random-dir mob)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob is heavily irradiated - (2% * irradiation power) chance to take no action
  (when (and (mob-effect-p mob +mob-effect-irradiated+)
             (< (random 100) (* 2 (param1 (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+))))))
    (logger (format nil "AI-FUNCTION: ~A [~A] is irradiated, loses turn.~%" (name mob) (id mob)))
    (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                           (format nil "~A is sick. " (capitalize-name (prepend-article +article-the+ (name mob)))))
    (move-mob mob 5)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob possesses smb, there is a chance that the slave will revolt and move randomly
  (let ((rebel-chance-level (cond
                              ((mob-ability-value mob +mob-abil-can-possess+) (mob-ability-value mob +mob-abil-can-possess+))
                              ((mob-ability-p mob +mob-abil-ghost-possess+) (if (and (slave-mob-id mob)
                                                                                     (mob-ability-p (get-mob-by-id (slave-mob-id mob)) +mob-abil-undead+))
                                                                                  0
                                                                                  1))
                              (t 0))
                            ))
    (when (and (slave-mob-id mob)
               (not (zerop rebel-chance-level))
               (zerop (random (* *possessed-revolt-chance* rebel-chance-level))))
      (logger (format nil "AI-FUNCTION: ~A [~A] is revolting against ~A [~A].~%" (name (get-mob-by-id (slave-mob-id mob))) (slave-mob-id mob) (name mob) (id mob)))
      (when (and (check-mob-visible mob :observer *player*)
                 (or (mob-effect-p mob +mob-effect-reveal-true-form+)
                     (get-faction-relation (faction mob) (faction *player*))))
        (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                               (format nil "~A revolts against ~A. " (capitalize-name (prepend-article +article-the+ (name (get-mob-by-id (slave-mob-id mob))))) (prepend-article +article-the+ (name mob)))))
      (setf (path mob) nil)
      (ai-mob-random-dir mob)
      (return-from ai-function nil)
      )
    )
  
  ;; calculate a list of hostile & allied mobs
  (let ((hostile-mobs nil)
        (allied-mobs nil)
        (nearest-enemy nil)
        (nearest-ally nil)
        (nearest-target nil))
    
    (loop for mob-id of-type fixnum in (visible-mobs mob)
          for target-mob = (get-mob-by-id mob-id)
          with vis-mob-type = nil
          do
             
             ;; inspect a mob appearance
             (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id target-mob)))
             ;; however is you are of the same faction, you know who is who
             (when (= (faction mob) (faction target-mob))
               (setf vis-mob-type (get-mob-type-by-id (mob-type target-mob))))
             
             (if (or (get-faction-relation (faction mob) (faction vis-mob-type))
                     (and (mounted-by-mob-id target-mob)
                          (get-faction-relation (faction mob) (faction (get-mob-by-id (mounted-by-mob-id target-mob))))))
               (progn
                 (pushnew mob-id allied-mobs)
                 ;; find the nearest allied mob
                 (unless nearest-ally
                   (setf nearest-ally target-mob))
                 (when (< (get-distance (x target-mob) (y target-mob) (x mob) (y mob))
                          (get-distance (x nearest-ally) (y nearest-ally) (x mob) (y mob)))
                   (setf nearest-ally target-mob))
                 )
               (progn
                 (pushnew mob-id hostile-mobs)
                 
                 ;; find the nearest hostile mob
                 (unless nearest-enemy
                   (setf nearest-enemy target-mob))
                 (when (< (get-distance (x target-mob) (y target-mob) (x mob) (y mob))
                          (get-distance (x nearest-enemy) (y nearest-enemy) (x mob) (y mob)))
                   (setf nearest-enemy target-mob))
                 )))

    ;; by default, the target is the enemy
    (setf nearest-target nearest-enemy)
    
    ;; if the mob is feared, move away from the nearest enemy
    (when (and nearest-enemy (mob-effect-p mob +mob-effect-fear+))
      (logger (format nil "AI-FUNCTION: ~A [~A] is in fear with an enemy ~A [~A] in sight.~%" (name mob) (id mob) (name nearest-target) (id nearest-target)))
      (ai-mob-flee mob nearest-enemy)      
      (return-from ai-function))

    ;; find and apply the AI package
    (let ((ai-package-list) (r 0))
      (declare (type fixnum r)
               (type list ai-package-list))

      ;; find all applicable AI packages
      (setf ai-package-list (loop for ai-package-id being the hash-key in (ai-packages mob)
                                  for ai-package = (get-ai-package-by-id ai-package-id)
                                  for func of-type function = (on-check-ai ai-package)
                                  with check-result = nil 
                                  when (and func
                                            (setf check-result (funcall func mob nearest-enemy nearest-ally hostile-mobs allied-mobs)))
                                    collect (list ai-package check-result)))

      (when ai-package-list
        ;; find the AI package with the most priority
        (setf ai-package-list (sort ai-package-list
                                    #'(lambda (a b)
                                        (if (> (priority a)
                                               (priority b))
                                          t
                                          nil))
                                    :key #'(lambda (a)
                                             (first a))))
        (setf ai-package-list (remove-if-not #'(lambda (a)
                                                 (if (= (priority a)
                                                        (priority (first (first ai-package-list))))
                                                   t
                                                   nil))
                                             ai-package-list
                                             :key #'(lambda (a)
                                                      (first a))
                                             ))
        
        ;; if there are several of them choose one randomly
        (setf r (random (length ai-package-list)))
        (let ((ai-invoke-func (on-invoke-ai (first (nth r ai-package-list)))))
          (declare (type function ai-invoke-func))
          (setf nearest-target (funcall ai-invoke-func mob nearest-enemy nearest-ally hostile-mobs allied-mobs nearest-target)))

        ;; if the package is final - exit
        (when (final (first (nth r ai-package-list)))
          (return-from ai-function))
        )
      )    
    
    ;; invoke abilities if any
    (let ((ability-list) (r 0))
      (declare (type fixnum r)
               (type list ability-list))
               
      ;; find all applicable abilities
      (setf ability-list (loop for ability-id being the hash-key in (abilities mob)
                               for ability = (get-ability-type-by-id ability-id)
                               for func of-type function = (on-check-ai ability)
                               with check-result = nil 
                               when (and func
                                         (setf check-result (funcall func ability mob nearest-enemy nearest-ally)))
                                 collect (list ability check-result)))

      
      ;; randomly choose one of them and invoke it
      (when ability-list
        (setf r (random (length ability-list)))
        (let ((ai-invoke-func (on-invoke-ai (first (nth r ability-list)))))
          (declare (type function ai-invoke-func))
          (logger (format nil "AI-FUNCTION: ~A [~A] decides to invoke ability ~A~%" (name mob) (id mob) (name (first (nth r ability-list)))))
          (funcall ai-invoke-func (first (nth r ability-list)) mob nearest-enemy nearest-ally (second (nth r ability-list))))
        (return-from ai-function)
        )
      )

    ;; use an item if any
    (let ((item-list) (r 0))
      (declare (type fixnum r)
               (type list item-list))
               
      ;; find all applicable items
      (setf item-list (loop for item-id in (inv mob)
                            for item = (get-item-by-id item-id)
                            for ai-check-func of-type function = (on-check-ai item)
                            for use-func of-type function = (on-use item)
                            with check-result = nil 
                            when (and use-func
                                      ai-check-func
                                      (setf check-result (funcall ai-check-func mob item nearest-enemy nearest-ally)))
                              collect (list item check-result)))

      
      ;; randomly choose one of them and invoke it
      (when item-list
        (setf r (random (length item-list)))
        (let ((ai-invoke-func (ai-invoke-func (first (nth r item-list)))))
          (logger (format nil "AI-FUNCTION: ~A [~A] decides to use item ~A [~A]~%" (name mob) (id mob) (name (first (nth r item-list))) (id (first (nth r item-list)))))
          (funcall ai-invoke-func mob (first (nth r item-list)) nearest-enemy nearest-ally (second (nth r item-list))))
        (return-from ai-function)
        )
      )
    
    ;; engage in ranged combat
    ;; if no bullets in magazine - reload
    (when (and (is-weapon-ranged mob)
               (not (mob-can-shoot mob)))
      (mob-reload-ranged-weapon mob)
      (return-from ai-function))

    ;; if can shoot and there is an enemy in sight - shoot it
    (when (and (is-weapon-ranged mob)
               (mob-can-shoot mob)
               nearest-enemy)
      (let ((tx 0) (ty 0) (tz 0)
            (ex (x nearest-enemy)) (ey (y nearest-enemy)) (ez (z nearest-enemy)))
        (declare (type fixnum tx ty tz ex ey ez))
        (line-of-sight (x mob) (y mob) (z mob) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy) #'(lambda (dx dy dz prev-cell)
                                                                               (declare (type fixnum dx dy dz))
                                                                               (let ((exit-result t))
                                                                                 (block nil
                                                                                   (setf tx dx ty dy tz dz)

                                                                                   (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                     (setf exit-result 'exit)
                                                                                     (return))
                                                                                   
                                                                                   )
                                                                                 exit-result)))
        (when (and (= tx ex)
                   (= ty ey)
                   (= tz ez))
          (mob-shoot-target mob nearest-enemy)
          (return-from ai-function))))

    ;; if no enemy in sight and the magazine is not full - reload it
    (when (and (is-weapon-ranged mob)
               (not nearest-enemy)
               (get-ranged-weapon-max-charges mob)
               (< (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob)))
      (mob-reload-ranged-weapon mob)
      (return-from ai-function))
 
    ;; follow the leader
    (when (and (order mob)
               (= (first (order mob)) +mob-order-follow+))
      ;; if the leader is nearby, plot the path to it
      (let ((leader (get-mob-by-id (second (order mob)))))
        (if (check-dead leader)
          (progn
            (setf (order mob) nil))
          (progn
            (when (and (< (get-distance (x mob) (y mob) (x leader) (y leader)) 8)
                       (> (get-distance (x mob) (y mob) (x leader) (y leader)) 2)
                       (not nearest-enemy))
              (logger (format nil "AI-FUNCTION: Mob (~A, ~A, ~A) wants to follow the leader to (~A, ~A, ~A)~%" (x mob) (y mob) (z mob) (x leader) (y leader) (z leader)))
              (setf nearest-target leader))))
        ))

    ;; approach the target
    (when (and (order mob)
               (= (first (order mob)) +mob-order-target+))
      ;; if the leader is nearby, plot the path to it
      (let ((target (get-mob-by-id (second (order mob)))))
        (if (check-dead target)
          (progn
            (setf (order mob) nil))
          (progn
            (when (find (id target) (visible-mobs mob))
              (logger (format nil "AI-FUNCTION: Mob (~A, ~A, ~A) wants to go to the target to (~A, ~A, ~A)~%" (x mob) (y mob) (z mob) (x target) (y target) (z target)))
              (setf nearest-target target))))
        ))

    ;; got to the nearest target
    (when nearest-target
      (logger (format nil "AI-FUNCTION: Target found ~A [~A] (~A ~A ~A)~%" (name nearest-target) (id nearest-target) (x nearest-target) (y nearest-target) (z nearest-target)))
      (logger (format nil "LEVEL-CONNECTED-P = ~A~%" (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) (x nearest-target) (y nearest-target) (z nearest-target) (if (riding-mob-id mob)
                                                                                                                                     (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                                     (map-size mob))
                                                                    (get-mob-move-mode mob))))
      (logger (format nil "LEVEL-CONNECTED ACTOR = ~A~%" (get-level-connect-map-value (level *world*) (x mob) (y mob) (z mob) (if (riding-mob-id mob)
                                                                                                                      (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                      (map-size mob))
                                                                            (get-mob-move-mode mob))))
      (logger (format nil "LEVEL-CONNECTED TARGET = ~A~%" (get-level-connect-map-value (level *world*) (x nearest-target) (y nearest-target) (z nearest-target) (if (riding-mob-id mob)
                                                                                                                      (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                      (map-size mob))
                                                                            (get-mob-move-mode mob))))
      (cond
        ((level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) (x nearest-target) (y nearest-target) (z nearest-target) (if (riding-mob-id mob)
                                                                                                                                     (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                                     (map-size mob))
                                  (get-mob-move-mode mob))
         (setf (path-dst mob) (list (x nearest-target) (y nearest-target) (z nearest-target)))
         (setf (path mob) nil))
        ((and (> (map-size mob) 1)
              (ai-find-move-around mob (x nearest-target) (y nearest-target)))
         (setf (path-dst mob) (ai-find-move-around mob (x nearest-target) (y nearest-target)))
         (setf (path mob) nil))))
    
    ;; move to some random passable terrain
    (unless (path-dst mob)
      (let ((rx (- (+ 10 (x mob))
                   (1+ (random 20)))) 
            (ry (- (+ 10 (y mob))
                   (1+ (random 20))))
            (rz (- (+ 5 (z mob))
                   (1+ (random 10))))
            )
        (declare (type fixnum rx ry rz))
        (logger (format nil "AI-FUNCTION: Mob (~A, ~A, ~A) wants to go to a random nearby place~%" (x mob) (y mob) (z mob)))
        (logger (format nil "AI-FUNCTION: TERRAIN ~A~%" (get-terrain-* (level *world*) (x mob) (y mob) (z mob))))
        (loop while (or (< rx 0) (< ry 0) (< rz 0) (>= rx (array-dimension (terrain (level *world*)) 0)) (>= ry (array-dimension (terrain (level *world*)) 1)) (>= rz (array-dimension (terrain (level *world*)) 2))
                        (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move+)
                        (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) (z mob)) +terrain-trait-water+))
                             (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-opaque-floor+))
                             (not (mob-effect-p mob +mob-effect-flying+)))
                        
                        ;(and (get-mob-* (level *world*) rx ry rz)
                        ;     (not (eq (get-mob-* (level *world*) rx ry rz) mob)))
                        (not (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) rx ry rz (if (riding-mob-id mob)
                                                                                                         (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                         (map-size mob))
                                                      (get-mob-move-mode mob)))
                        )
              do
                 (logger (format nil "AI-FUNCTION: R (~A ~A ~A)~%TERRAIN = ~A, MOB ~A [~A], CONNECTED ~A~%"
                                 rx ry rz
                                 (get-terrain-* (level *world*) rx ry rz)
                                 (get-mob-* (level *world*) rx ry rz) (if (get-mob-* (level *world*) rx ry rz)
                                                                        (id (get-mob-* (level *world*) rx ry rz))
                                                                        nil)
                                 (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) rx ry rz (if (riding-mob-id mob)
                                                                                                             (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                             (map-size mob))
                                                          (get-mob-move-mode mob))))
                 (setf rx (- (+ 10 (x mob))
                             (1+ (random 20))))
                 (setf ry (- (+ 10 (y mob))
                             (1+ (random 20))))
                 (setf rz (- (+ 5 (z mob))
                             (1+ (random 10))))
              (logger (format nil "AI-FUNCTION: NEW R (~A ~A ~A)~%" rx ry rz)))
        (setf (path-dst mob) (list rx ry rz))
        (logger (format nil "AI-FUNCTION: Mob's destination is randomly set to (~A, ~A, ~A)~%" (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob))))))

    ;; calculate path to the destination
    (when (and (path-dst mob)
               (not (mob-ability-p mob +mob-abil-immobile+))
               (or (null (path mob))
                   (mob-ability-p mob +mob-abil-momentum+)))
      (let ((path nil))
        (when (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob)) (if (riding-mob-id mob)
                                                                                                                                                       (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                                                       (map-size mob))
                                       (get-mob-move-mode mob))
          (logger (format nil "AI-FUNCTION: Mob (~A, ~A, ~A) wants to go to (~A, ~A, ~A)~%" (x mob) (y mob) (z mob) (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob))))
          (setf path (a-star (list (x mob) (y mob) (z mob)) (list (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob))) 
                               #'(lambda (dx dy dz cx cy cz) 
                                   ;; checking for impassable objects
                                   (check-move-for-ai mob dx dy dz cx cy cz :final-dst (path-dst mob))
                                   )
                               #'(lambda (dx dy dz)
                                   ;; a magic hack here - as values of more than 10 give an unexplainable slowdown
                                   (* (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-move-cost-factor+)
                                      (move-spd (get-mob-type-by-id (mob-type mob)))
                                      1/10))))
                    
          (pop path)
          (logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
          (setf (path mob) path)
          )))
    
    ;; if the mob has its path set - move along it
    (when (path mob)

        (let ((step) (step-x) (step-y) (step-z) (move-result nil))
        
          (logger (format nil "AI-FUNCTION: Move mob along the path - ~A~%" (path mob)))
          (setf step (pop (path mob)))
          
          ;; if there is suddenly an obstacle, make the path recalculation
          (setf step-x (- (first step) (x mob)))
          (setf step-y (- (second step) (y mob)))
          (setf step-z (- (third step) (z mob)))

          (setf move-result (check-move-on-level mob (first step) (second step) (third step)))
          
          (unless move-result
            (logger (format nil "AI-FUNCTION: Can't move to target - (~A ~A ~A)~%" (first step) (second step) (third step)))
            (setf (path mob) nil)
            (setf (path-dst mob) nil)
            (return-from ai-function))
          
          (unless (x-y-into-dir step-x step-y)
            (logger (format nil "AI-FUNCTION: Wrong direction supplied (~A ~A)~%" (first step) (second step)))
            (setf (path mob) nil)
            (setf (path-dst mob) nil)
            (return-from ai-function))

          ;; check if there is somebody on the target square
          (logger (format nil
                          "AI-FUNCTION: MOVE-RESULT = ~A, NOT T = ~A, FACTION-RELATION = ~A, NOT LOVES-INFIGHTING = ~A, BLESS+BLESSED = ~A~%"
                          move-result
                          (not (eq move-result t))
                          (if (and move-result
                                   (not (eq move-result t))
                                   (eq (first move-result) :mobs))
                            (get-faction-relation (faction mob) (get-visible-faction (first (second move-result))))
                            nil)
                          (not (mob-ability-p mob +mob-abil-loves-infighting+))
                          (if (and move-result
                                   (not (eq move-result t))
                                   (eq (first move-result) :mobs))
                            (or (not (mob-ability-p mob +mob-abil-blessing-touch+))
                                (and (mob-ability-p mob +mob-abil-blessing-touch+)
                                     (mob-effect-p (first (second move-result)) +mob-effect-blessed+)
                                     (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))
                                (and (mob-ability-p mob +mob-abil-blessing-touch+)
                                     (not (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))))
                            nil)))
          ;(logger (format nil "AI-FUNCTION: MOVE-RESULT = ~A~%" move-result))
          
          (when (and move-result
                     (not (eq move-result t))
                     (eq (first move-result) :mobs)
                     (get-faction-relation (faction mob) (get-visible-faction (first (second move-result))))
                     (not (mob-ability-p mob +mob-abil-loves-infighting+))
                     (or (not (mob-ability-p mob +mob-abil-blessing-touch+))
                         (and (mob-ability-p mob +mob-abil-blessing-touch+)
                              (mob-effect-p (first (second move-result)) +mob-effect-blessed+)
                              (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))
                         (and (mob-ability-p mob +mob-abil-blessing-touch+)
                              (not (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))))
                     )
            (let ((final-cell nil))
              (when (path mob)
                (check-surroundings (x mob) (y mob) nil #'(lambda (dx dy)
                                                            (when (eq (check-move-on-level mob dx dy (z mob)) t)
                                                              (unless final-cell
                                                                (setf final-cell (list dx dy)))
                                                              (when (< (get-distance-3d dx dy (z mob)
                                                                                        (first (first (last (path mob)))) (second (first (last (path mob)))) (third (first (last (path mob)))))
                                                                       (get-distance-3d (first final-cell) (second final-cell) (z mob)
                                                                                        (first (first (last (path mob)))) (second (first (last (path mob)))) (third (first (last (path mob))))))
                                                                (setf final-cell (list dx dy)))))))
              (when final-cell
                (setf step-x (- (first final-cell) (x mob)))
                (setf step-y (- (second final-cell) (y mob))))
              ))
            
          
          (setf move-result (move-mob mob (x-y-into-dir step-x step-y) :dir-z step-z))

          (logger (format nil "AI-FUNCTION: PATH-DST ~A, MOB (~A ~A ~A), MOVE-RESULT ~A~%" (path-dst mob) (x mob) (y mob) (z mob) move-result))
          (if move-result
            (progn
              (when (and (path-dst mob)
                         (= (x mob) (first (path-dst mob)))
                         (= (y mob) (second (path-dst mob)))
                         (= (z mob) (third (path-dst mob))))
                (setf (path-dst mob) nil))
              (return-from ai-function))
            (progn
              (logger (format nil "AI-FUNCTION: Move failed ~A~%" move-result))
              (setf (path-dst mob) nil)
              (setf (path mob) nil)))
          
          ))
    
    ;; if there are no hostile mobs move randomly
    ;; pester the AI until it makes some meaningful action
    (ai-mob-random-dir mob)
    )
  )
