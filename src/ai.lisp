(in-package :cotd)

(defgeneric ai-function (mob))

(defun check-move-for-ai (mob dx dy)
  (declare (optimize (speed 3))
           (type fixnum dx dy))
  (let ((sx 0) (sy 0)
        (map-size (if (riding-mob-id mob)
                    (map-size (get-mob-by-id (riding-mob-id mob)))
                    (map-size mob))))
    (declare (type fixnum sx sy map-size))
    ;; calculate the coords of the mob's NE corner
    (setf sx (- dx (truncate (1- map-size) 2)))
    (setf sy (- dy (truncate (1- map-size) 2)))

    (loop for nx from sx below (+ sx map-size) do
      (loop for ny from sy below (+ sy map-size) do
        ;; cant move beyond level borders 
        (when (or (< nx 0) (< ny 0) (>= nx *max-x-level*) (>= ny *max-y-level*))
          (return-from check-move-for-ai nil))
        
        ;; checking for terrain obstacle
        (when (get-terrain-type-trait (get-terrain-* (level *world*) nx ny) +terrain-trait-blocks-move+) 
          (return-from check-move-for-ai nil))))

    t))

(defun ai-find-move-around (mob tx ty)
  (declare (optimize (speed 3))
           (type fixnum tx ty))
  (let* ((cell-list)
         (map-size (map-size mob))
         (half-size (truncate (1- map-size) 2)))
    (declare (type list cell-list)
             (type fixnum map-size half-size))
    ;; collect all cells that constitute the perimeter of the mob around the target cell
    (loop for off of-type fixnum from (- half-size) to (+ half-size)
          for x of-type fixnum = (+ tx off)
          for y-up of-type fixnum = (- ty half-size)
          for y-down of-type fixnum = (+ ty half-size)
          for y of-type fixnum = (+ ty off)
          for x-up of-type fixnum = (- tx half-size)
          for x-down of-type fixnum = (+ tx half-size)
          do
             (push (cons x y-up) cell-list)
             (push (cons x y-down) cell-list)
             (push (cons x-up y) cell-list)
             (push (cons x-down y) cell-list))

    ;(format t "AI-FIND-MOVE-AROUND: Cell list with duplicates ~A~%" cell-list)
    
    ;; remove all duplicates from the list
    (setf cell-list (remove-duplicates cell-list :test #'(lambda (a b)
                                                           (let ((x1 (car a))
                                                                 (x2 (car b))
                                                                 (y1 (cdr a))
                                                                 (y2 (cdr b)))
                                                             (declare (type fixnum x1 x2 y1 y2))
                                                             (if (and (= x1 x2)
                                                                      (= y1 y2))
                                                               t
                                                               nil)))))

    ;(format t "AI-FIND-MOVE-AROUND: Cell list without duplicates ~A~%" cell-list)
    
    ;; sort them so that the closest to the mob are checked first
    (setf cell-list (stable-sort cell-list #'(lambda (a b)
                                               (if (< (get-distance tx ty (car a) (cdr a))
                                                      (get-distance tx ty (car b) (cdr b)))
                                                 t
                                                 nil))))

    ;(format t "AI-FIND-MOVE-AROUND: Cell list sorted ~A~%" cell-list)
    
    ;; check each cell for passability
    (loop for (dx . dy) in cell-list
          for connect-d of-type fixnum = (aref (aref (connect-map (level *world*)) map-size) dx dy)
          for connect-mob of-type fixnum = (aref (aref (connect-map (level *world*)) map-size) (x mob) (y mob))
          do
      (when (and (= connect-d connect-mob)
                 (check-move-for-ai mob dx dy))
        ;(format t "AI-FIND-MOVE-AROUND: Return value ~A~%" (cons dx dy))
        (return-from ai-find-move-around (cons dx dy))))

    ;(format t "AI-FIND-MOVE-AROUND: Return value ~A~%" nil)
    nil))

(defun ai-mob-flee (mob nearest-enemy)
  (unless nearest-enemy
    (return-from ai-mob-flee nil))
  
  (logger (format nil "AI-FUNCTION: ~A [~A] tries to flee away from ~A [~A].~%" (name mob) (id mob) (name nearest-enemy) (id nearest-enemy)))
  
  (let ((step-x 0) 
        (step-y 0))

    (setf (path mob) nil)
    (setf (path-dst mob) nil)
    (setf step-x (if (> (x nearest-enemy) (x mob)) -1 1))
    (setf step-y (if (> (y nearest-enemy) (y mob)) -1 1))

    (when (and (zerop (random 10))
               (mob-ability-p mob +mob-abil-human+))
      (print-visible-message (x mob) (y mob) (level *world*) (format nil "~A cries: \"Help! Help!\" " (visible-name mob))))
    
    ;; if can't move away - try any random direction
    (unless (move-mob mob (x-y-into-dir step-x step-y))
      (logger (format nil "AI-FUNCTION: ~A [~A] could not flee. Try to move randomly.~%" (name mob) (id mob)))
      (ai-mob-random-dir mob))
    ))

(defun ai-mob-random-dir (mob)
  (logger (format nil "AI-FUNCTION: ~A [~A] tries to move randomly.~%" (name mob) (id mob)))
  (loop for dir = (+ (random 9) 1)
        until (move-mob mob dir)))

(defmethod ai-function ((mob mob))
  (declare (optimize (speed 3)))
  (logger (format nil "~%AI-Function Computer ~A [~A]~%" (name mob) (id mob)))
  
  ;; skip and invoke the master AI
  (when (master-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A], skipping its turn.~%" (name mob) (id mob) (name (get-mob-by-id (master-mob-id mob))) (master-mob-id mob)))
    (make-act mob +normal-ap+)
    (return-from ai-function nil))

  (when (and (path-dst mob)
             (= (x mob) (car (path-dst mob)))
             (= (y mob) (cdr (path-dst mob))))
    (setf (path-dst mob) nil))
  
  ;; skip turn if being ridden
  (when (mounted-by-mob-id mob)
    (if (made-turn (get-mob-by-id (mounted-by-mob-id mob)))
      (progn
        (logger (format nil "AI-FUNCTION: ~A [~A] is being ridden by ~A [~A], moving according to the direction.~%" (name mob) (id mob) (name (get-mob-by-id (mounted-by-mob-id mob))) (mounted-by-mob-id mob)))
        (move-mob mob (x-y-into-dir 0 0))
        (return-from ai-function nil))
      (progn
        (logger (format nil "AI-FUNCTION: ~A [~A] is being ridden by ~A [~A], waiting for the rider's command.~%" (name mob) (id mob) (name (get-mob-by-id (mounted-by-mob-id mob))) (mounted-by-mob-id mob)))
        (setf (made-turn mob) t)
        (return-from ai-function nil))))
    
  
  (update-visible-mobs mob)

  ;; if the mob is blind - move in random direction
  (when (mob-effect-p mob +mob-effect-blind+)
    (ai-mob-random-dir mob)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob possesses smb, there is a chance that the slave will revolt and move randomly
  (when (and (slave-mob-id mob)
             (zerop (random (* *possessed-revolt-chance* (mob-ability-p mob +mob-abil-can-possess+)))))
    (logger (format nil "AI-FUNCTION: ~A [~A] is revolting against ~A [~A].~%" (name (get-mob-by-id (slave-mob-id mob))) (slave-mob-id mob) (name mob) (id mob)))
    (when (or (mob-effect-p mob +mob-effect-reveal-true-form+)
              (get-faction-relation (faction mob) (faction *player*)))
      (print-visible-message (x mob) (y mob) (level *world*) 
                             (format nil "~A revolts against ~A. " (name (get-mob-by-id (slave-mob-id mob))) (name mob))))
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
                  
         (if (or (get-faction-relation (faction mob) (faction vis-mob-type))
                 (and (mounted-by-mob-id (get-mob-by-id mob-id))
                      (get-faction-relation (faction mob) (faction (get-mob-by-id (mounted-by-mob-id (get-mob-by-id mob-id)))))))
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
      (return-from ai-function))
      

    ;; if the mob is feared, move away from the nearest enemy
    (when (and nearest-enemy (mob-effect-p mob +mob-effect-fear+))
      (logger (format nil "AI-FUNCTION: ~A [~A] is in fear with an enemy ~A [~A] in sight.~%" (name mob) (id mob) (name nearest-target) (id nearest-target)))
      (ai-mob-flee mob nearest-enemy)      
      (return-from ai-function))
      
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
    
    ;; invoke abilities if any
    (let ((ability-list) (r 0))
      (declare (type fixnum r)
               (type list ability-list))
               
      ;; find all applicable abilities
      (setf ability-list (loop for ability-id being the hash-key in (abilities mob)
                               for ability = (get-ability-type-by-id ability-id)
                               for func of-type function = (on-check-ai ability)
                               when (and func
                                         (funcall func ability mob nearest-enemy nearest-ally))
                                 collect ability))

      
      ;; randomly choose one of them and invoke it
      (when ability-list
        (setf r (random (length ability-list)))
        (let ((ai-invoke-func (on-invoke-ai (nth r ability-list))))
          (declare (type function ai-invoke-func))
          (logger (format nil "AI-FUNCTION: ~A [~A] decides to invoke ability ~A~%" (name mob) (id mob) (name (nth r ability-list))))
          (funcall ai-invoke-func (nth r ability-list) mob nearest-enemy nearest-ally))
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
      (let ((tx 0) (ty 0)
            (ex (x nearest-enemy)) (ey (y nearest-enemy)))
        (declare (type fixnum tx ty ex ey))
        (line-of-sight (x mob) (y mob) (x nearest-enemy) (y nearest-enemy) #'(lambda (dx dy)
                                                                               (declare (type fixnum dx dy))
                                                                               (let ((terrain) (exit-result t))
                                                                                 (block nil
                                                                                   (setf tx dx ty dy)
                                                                                   (when (or (< dx 0) (>= dx *max-x-level*)
                                                                                             (< dy 0) (>= dy *max-y-level*))
                                                                                     (setf exit-result 'exit)
                                                                                     (return))
                                                                                   
                                                                                   (setf terrain (get-terrain-* (level *world*) dx dy))
                                                                                   (unless terrain
                                                                                     (setf exit-result 'exit)
                                                                                     (return))
                                                                                   (when (get-terrain-type-trait terrain +terrain-trait-blocks-projectiles+)
                                                                                     (setf exit-result 'exit)
                                                                                     (return))
                                                                                   )
                                                                                 exit-result)))
        (when (and (= tx ex)
                   (= ty ey))
          (mob-shoot-target mob nearest-enemy)
          (return-from ai-function))))

    ;; if no enemy in sight and the magazine is not full - reload it
    (when (and (is-weapon-ranged mob)
               (not nearest-enemy)
               (< (get-ranged-weapon-charges mob) (get-ranged-weapon-max-charges mob)))
      (mob-reload-ranged-weapon mob)
      (return-from ai-function))

    ;; follow the leader
    (when (and (order mob)
               (= (first (order mob)) +mob-order-follow+))
      ;; if the leader is nearby, plot the path to it
      (let ((leader (get-mob-by-id (second (order mob))))
            (connect-map (aref (connect-map (level *world*)) (if (riding-mob-id mob)
                                                               (map-size (get-mob-by-id (riding-mob-id mob)))
                                                               (map-size mob))))
            (target-pos)
            (path))
        
        (cond
          ((= (aref connect-map (x mob) (y mob))
              (aref connect-map (x leader) (y leader)))
           (setf target-pos (cons (x leader) (y leader))))
          ((and (> (map-size mob) 1)
                (ai-find-move-around mob (x leader) (y leader)))
           (setf target-pos (ai-find-move-around mob (x leader) (y leader)))))
        
        (if (and (< (get-distance (x mob) (y mob) (x leader) (y leader)) 8)
                 (> (get-distance (x mob) (y mob) (x leader) (y leader)) 2)
                 target-pos)
          (progn
            (logger (format nil "AI-FUNCTION: Mob (~A, ~A) wants to follow the leader to (~A, ~A)~%" (x mob) (y mob) (x leader) (y leader)))
            (setf path (a-star (list (x mob) (y mob)) (list (car target-pos) (cdr target-pos)) 
                               #'(lambda (dx dy) 
                                   ;; checking for impassable objects
                                   (check-move-for-ai mob dx dy)
                                   )))
            
            (pop path)
            (logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
            (setf (path mob) path)
            (setf (path-dst mob) target-pos))
          (progn
            (setf (path-dst mob) nil)))))
          

    ;; got to the nearest target
    (when nearest-target
      (logger (format nil "AI-FUNCTION: Target found ~A [~A]~%" (name nearest-target) (id nearest-target)))
      (let ((path nil)
            (connect-map (aref (connect-map (level *world*)) (if (riding-mob-id mob)
                                                               (map-size (get-mob-by-id (riding-mob-id mob)))
                                                               (map-size mob))))
            (target-pos nil))

        (cond
          ((= (aref connect-map (x mob) (y mob))
              (aref connect-map (x nearest-target) (y nearest-target)))
           (setf target-pos (cons (x nearest-target) (y nearest-target))))
          ((and (> (map-size mob) 1)
                (ai-find-move-around mob (x nearest-target) (y nearest-target)))
           (setf target-pos (ai-find-move-around mob (x nearest-target) (y nearest-target)))))

        (when target-pos

          (setf path (a-star (list (x mob) (y mob)) (list (car target-pos) (cdr target-pos)) 
                             #'(lambda (dx dy) 
                                 ;; checking for impassable objects
                                 (check-move-for-ai mob dx dy)
                                 )))
          
          (logger (format nil "AI-FUNCTION: Mob - (~A ~A) Target - (~A ~A)~%" (x mob) (y mob) (car target-pos) (cdr target-pos)))
          (logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
          (pop path)
          
          (setf (path mob) path)
          (setf (path-dst mob) target-pos)
          
        )))
    
    ;; move to some random passable terrain 
    (when (or (not (path mob))
              (mob-ability-p mob +mob-abil-momentum+))
      (let ((rx (- (+ 10 (x mob))
                   (1+ (random 20)))) 
            (ry (- (+ 10 (y mob))
                   (1+ (random 20))))
            (path nil)
            (connect-map (aref (connect-map (level *world*)) (if (riding-mob-id mob)
                                                               (map-size (get-mob-by-id (riding-mob-id mob)))
                                                               (map-size mob)))))
        (declare (type fixnum rx ry))

        (logger (format nil "AI-FUNCTION: Mob (~A, ~A) wants to go to a random nearby place~%" (x mob) (y mob)))
        
        ;; if the mob destination is not set, choose some random location
        (unless (path-dst mob)
          (loop while (or (< rx 0) (< ry 0) (>= rx *max-x-level*) (>= ry *max-y-level*)
                          (get-terrain-type-trait (get-terrain-* (level *world*) rx ry) +terrain-trait-blocks-move+)
                          (and (get-mob-* (level *world*) rx ry)
                               (not (eq (get-mob-* (level *world*) rx ry) mob)))
                          (/= (aref connect-map (x mob) (y mob))
                              (aref connect-map rx ry)))
                do
                   (setf rx (- (+ 10 (x mob))
                               (1+ (random 20))))
                   (setf ry (- (+ 10 (y mob))
                               (1+ (random 20)))))
          (setf (path-dst mob) (cons rx ry))
          (logger (format nil "AI-FUNCTION: Mob's destination is randomly set to (~A, ~A)~%" (car (path-dst mob)) (cdr (path-dst mob)))))
        (when (= (aref connect-map (x mob) (y mob))
                 (aref connect-map (car (path-dst mob)) (cdr (path-dst mob))))
          
          (logger (format nil "AI-FUNCTION: Mob (~A, ~A) wants to go to (~A, ~A)~%" (x mob) (y mob) (car (path-dst mob)) (cdr (path-dst mob))))
          (setf path (a-star (list (x mob) (y mob)) (list (car (path-dst mob)) (cdr (path-dst mob))) 
                             #'(lambda (dx dy) 
                                 ;; checking for impassable objects
                                 (check-move-for-ai mob dx dy)
                                 )))
          
          (pop path)
          (logger (format nil "AI-FUNCTION: Set mob path - ~A~%" path))
          (setf (path mob) path)
          )))
    
    ;; if the mob has its path set - move along it
    (when (path mob)

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

          (logger (format nil "AI-FUNCTION: PATH-DST ~A, MOB (~A ~A)~%" (path-dst mob) (x mob) (y mob)))
          
          (when (and (path-dst mob)
                     (= (x mob) (car (path-dst mob)))
                     (= (y mob) (cdr (path-dst mob))))
            (setf (path-dst mob) nil))
          
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

  ;; find the nearest enemy
  (when (mob-ability-p *player* +mob-abil-detect-good+)
    (sense-good))
  (when (mob-ability-p *player* +mob-abil-detect-evil+)
    (sense-evil))
  
  (make-output *current-window*) 

  ;; if player is fearing somebody & there is an enemy nearby
  ;; wait for a meaningful action and move randomly instead
  (when (mob-effect-p *player* +mob-effect-fear+)
    (logger (format nil "AI-FUNCTION: ~A [~A] is under effects of fear.~%" (name player) (id player)))
    (let ((nearest-enemy nil))
      (loop for mob-id of-type fixnum in (visible-mobs *player*)
            for mob = (get-mob-by-id mob-id)
            with vis-mob-type = nil
            do
               ;; inspect a mob appearance
               (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id mob)))
               ;; however is you are of the same faction, you know who is who
               (when (= (faction *player*) (faction mob))
                 (setf vis-mob-type (get-mob-type-by-id (mob-type mob))))
                  
               (when (not (get-faction-relation (faction *player*) (faction vis-mob-type)))
                 ;; find the nearest hostile mob
                 (unless nearest-enemy
                   (setf nearest-enemy mob))
                 (when (< (get-distance (x mob) (y mob) (x *player*) (y *player*))
                          (get-distance (x nearest-enemy) (y nearest-enemy) (x *player*) (y *player*)))
                   (setf nearest-enemy mob))
                 ))
      
      (when nearest-enemy
        (logger (format nil "AI-FUNCTION: ~A [~A] fears ~A [~A].~%" (name player) (id player) (name nearest-enemy) (id nearest-enemy)))
        (setf (can-move-if-possessed player) t)
        (loop while (can-move-if-possessed player) do
          (get-input-player))
        (ai-mob-flee *player* nearest-enemy)
        (return-from ai-function nil))))
  
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
                               (format nil "~A revolts against ~A. " (name player) (name (get-mob-by-id (master-mob-id player))) ))
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
                             (format nil "~A revolts against ~A. " (name (get-mob-by-id (slave-mob-id player))) (name player)))
      (ai-mob-random-dir player)
      (return-from ai-function nil)
    ))
  
  ;; player is able to move freely
  ;; pester the player until it makes some meaningful action that can trigger the event chain
  (loop until (made-turn player) do
    (setf (can-move-if-possessed player) nil)
    (get-input-player))
  (setf *time-at-end-of-player-turn* (get-internal-real-time)))


(defun thread-path-loop (stream)
  (loop while t do
    (bt:with-lock-held ((path-lock *world*))      
      (if (and (< (cur-mob-path *world*) (length (mob-id-list (level *world*)))) (not (made-turn *player*)))
        (progn
          (when (and (not (dead= (get-mob-by-id (cur-mob-path *world*))))
                     (not (path (get-mob-by-id (cur-mob-path *world*)))))
            (logger (format nil "~%THREAD: Mob ~A [~A] calculates paths~%" (name (get-mob-by-id (cur-mob-path *world*))) (id (get-mob-by-id (cur-mob-path *world*)))) stream)
            (let* ((mob (get-mob-by-id (cur-mob-path *world*)))
                   (rx (- (+ 10 (x mob))
                          (1+ (random 20)))) 
                   (ry (- (+ 10 (y mob))
                          (1+ (random 20))))
                   (path nil)
                   (connect-map (aref (connect-map (level *world*)) (map-size mob))))
              (declare (type fixnum rx ry))

              ;; if the mob destination is not set, choose a random destination
              (unless (path-dst mob)
                (loop while (or (< rx 0) (< ry 0) (>= rx *max-x-level*) (>= ry *max-y-level*)
                                (get-terrain-type-trait (get-terrain-* (level *world*) rx ry) +terrain-trait-blocks-move+)
                                (and (get-mob-* (level *world*) rx ry)
                                     (not (eq (get-mob-* (level *world*) rx ry) mob)))
                                (/= (aref connect-map (x mob) (y mob))
                                    (aref connect-map rx ry)))
                      do
                         (setf rx (- (+ 10 (x mob))
                                     (1+ (random 20))))
                         (setf ry (- (+ 10 (y mob))
                                     (1+ (random 20)))))
                (setf (path-dst mob) (cons rx ry)))

               (when (= (aref connect-map (x mob) (y mob))
                        (aref connect-map (car (path-dst mob)) (cdr (path-dst mob))))
                 (logger (format nil "THREAD: Mob (~A, ~A) wants to go to (~A, ~A)~%" (x mob) (y mob) (car (path-dst mob)) (cdr (path-dst mob))) stream)
                 (setf path (a-star (list (x mob) (y mob)) (list (car (path-dst mob)) (cdr (path-dst mob))) 
                                    #'(lambda (dx dy) 
                                        ;; checking for impassable objects
                                        (check-move-for-ai mob dx dy)
                                        )))
                 
                 (pop path)
                 (logger (format nil "THREAD: Set mob path - ~A~%" path) stream)
                 (setf (path mob) path)
                 ))
            )
          (incf (cur-mob-path *world*))
          (logger (format nil "THREAD: cur-mob-path - ~A~%" (cur-mob-path *world*)) stream))
        (progn
          (logger (format nil "THREAD: Done calculating paths~%~%") stream)
          (setf (cur-mob-path *world*) (length (mob-id-list (level *world*))))
          (bt:condition-wait (path-cv *world*) (path-lock *world*)))
        
        ))))
