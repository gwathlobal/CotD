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

(defun x-y-into-str (xy-cons)
  (cond
    ((equal xy-cons '(-1 . 1)) "SW")
    ((equal xy-cons '(0 . 1)) "S")
    ((equal xy-cons '(1 . 1)) "SE")
    ((equal xy-cons '(-1 . 0)) "W")
    ((equal xy-cons '(0 . 0)) "None")
    ((equal xy-cons '(1 . 0)) "E")
    ((equal xy-cons '(-1 . -1)) "NW")
    ((equal xy-cons '(0 . -1)) "N")
    ((equal xy-cons '(1 . -1)) "NE")
    (t "ERR")))

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

(defun dir-neighbours (dir)
  ;; find the neighbours of the direction
  ;; the result is <along the direction> <not along the direction> <to the left from the direction> <to the right from the direction> <near the opposite direction> <opposite the direction>
  ;; for more info see the move-mob func
  (cond
    ((eql dir 1) (values-list '((4 1 2) (3 6 7 8) (3 6) (7 8) (8 6) (9))))
    ((eql dir 2) (values-list '((1 2 3) (4 6 7 9) (6 9) (4 7) (7 9) (8))))
    ((eql dir 3) (values-list '((2 3 6) (1 4 8 9) (9 8) (1 4) (4 8) (7))))
    ((eql dir 4) (values-list '((1 4 7) (8 2 9 3) (2 3) (8 9) (9 3) (6))))
    ((eql dir 5) (values-list '((1 2 3 4 5 6 7 8 9) () () () () ())))
    ((eql dir 6) (values-list '((9 6 3) (8 2 7 1) (8 7) (2 1) (7 1) (4))))
    ((eql dir 7) (values-list '((4 7 8) (1 9 2 6) (1 2) (9 3) (6 2) (3))))
    ((eql dir 8) (values-list '((7 8 9) (4 6 1 3) (4 1) (6 3) (1 3) (2))))
    ((eql dir 9) (values-list '((8 9 6) (7 3 4 2) (7 4) (3 2) (4 2) (1))))
    (t (error "Wrong direction supplied!!!"))))

(defun check-surroundings (x y include-center func)
  (dotimes (x1 3)
    (dotimes (y1 3)
      (when include-center
	(funcall func (+ (1- x) x1) (+ (1- y) y1)))
      (when (and (eql include-center nil)
		 (or (/= (+ (1- x) x1) x) (/= (+ (1- y) y1) y)))
	(funcall func (+ (1- x) x1) (+ (1- y) y1))))))

(defun check-surroundings-3d (x y z include-center func)
  (loop for dx from -1 to 1 do
    (loop for dy from -1 to 1 do
      (loop for dz from -1 to 1 do
        (cond
          ((and include-center
                (= dx dy dz 0))
           (funcall func (+ x dx) (+ y dy) (+ z dz)))
          ((and (not include-center)
                (= dx dy dz 0))
           nil)
          (t (funcall func (+ x dx) (+ y dy) (+ z dz))))))))
  

(defun print-visible-message (x y z level str)
  (when (get-single-memo-visibility (get-memo-* level x y z))
    (set-message-this-turn t)
    (add-message str)))

(defun place-visible-animation (x y z level animation-type-id &key (params nil))
  (when (get-single-memo-visibility (get-memo-* level x y z))
    (push (make-animation :id animation-type-id :x x :y y :z z :params params) (animation-queue *world*))))

(defun check-move-on-level (mob dx dy dz)
  (let ((sx) (sy)
        (mob-list nil))
    ;; calculate the coords of the mob's NE corner
    (setf sx (- dx (truncate (1- (map-size mob)) 2)))
    (setf sy (- dy (truncate (1- (map-size mob)) 2)))

    (loop for nx from sx below (+ sx (map-size mob)) do
      (loop for ny from sy below (+ sy (map-size mob)) do
        ;; trying to move beyound the level border 
        (when (or (< nx 0) (< ny 0) (>= nx *max-x-level*) (>= ny *max-y-level*))
          (return-from check-move-on-level nil))
        
        ;; checking for obstacle
        (when (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move+)
          (return-from check-move-on-level nil)
          ;(return-from check-move-on-level (list :obstacles ()))
          )
        
        ;; checking for mobs
        (when (and (get-mob-* (level *world*) nx ny dz)
                   (not (eq (get-mob-* (level *world*) nx ny dz) mob))
                   (or (eq (mounted-by-mob-id mob) nil)
                       (not (eq (mounted-by-mob-id mob) (id (get-mob-* (level *world*) nx ny dz))))))
          (pushnew (get-mob-* (level *world*) nx ny dz) mob-list)
          )))

    (when mob-list
      (return-from check-move-on-level (list :mobs mob-list)))
    
    ;; all checks passed - can move freely
    (return-from check-move-on-level t)))


(defmethod apply-gravity ((mob mob))
  (let ((result nil))
    (loop for z from (z mob) downto 0 
          for check-result = (check-move-on-level mob (x mob) (y mob) z)
          do
             ;(format t "Z ~A FLOOR ~A~%" z (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) z) +terrain-trait-opaque-floor+))
             (when (eq check-result t)
               (setf result z))
             (when (or (not (eq check-result t))
                       (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) z) +terrain-trait-opaque-floor+))
               (loop-finish)))
    (when (eq result (z mob))
      (setf result nil))

    result))

(defmethod apply-gravity ((feature feature))
  (let ((result nil))
    (loop for z from (z feature) downto 0 
          do
             (when (get-terrain-type-trait (get-terrain-* (level *world*) (x feature) (y feature) z) +terrain-trait-opaque-floor+)
               (setf result z)
               (loop-finish)))
    (when (eq result (z feature))
      (setf result nil))
    result))

(defmethod apply-gravity ((item item))
  (let ((result nil))
    (loop for z from (z item) downto 0 
          do
             (when (get-terrain-type-trait (get-terrain-* (level *world*) (x item) (y item) z) +terrain-trait-opaque-floor+)
               (setf result z)
               (loop-finish)))
    (when (eq result (z item))
      (setf result nil))
    result))
      

(defun set-mob-location (mob x y z)
  (let ((place-func #'(lambda (nmob)
                        (let ((sx) (sy))
                          ;; calculate the coords of the mob's NE corner
                          (setf sx (- (x nmob) (truncate (1- (map-size nmob)) 2)))
                          (setf sy (- (y nmob) (truncate (1- (map-size nmob)) 2)))
                          
                          ;; remove the mob from the orignal position
                          ;; for size 1 (standard) mobs the loop executes only once, so it devolves into traditional movement 
                          (loop for nx from sx below (+ sx (map-size nmob)) do
                            (loop for ny from sy below (+ sy (map-size nmob)) do
                              (when (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) nx ny (z nmob))))
                                (funcall (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) nx ny (z nmob)))) nmob nx ny (z nmob)))
                              (setf (aref (mobs (level *world*)) nx ny (z nmob)) nil)))
                          
                          ;; change the coords of the center of the mob
                          (setf (x nmob) x (y nmob) y (z nmob) z)
                          
                          ;; calculate the new coords of the mob's NE corner
                          (setf sx (- (x nmob) (truncate (1- (map-size nmob)) 2)))
                          (setf sy (- (y nmob) (truncate (1- (map-size nmob)) 2)))
                          
                          ;; place the mob to the new position
                          ;; for size 1 (standard) mobs the loop executes only once, so it devolves into traditional movement
                          (loop for nx from sx below (+ sx (map-size nmob)) do
                            (loop for ny from sy below (+ sy (map-size nmob)) do
                              (setf (aref (mobs (level *world*)) nx ny z) (id nmob))
                              
                              (when (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) nx ny z)))
                                (funcall (on-step (get-terrain-type-by-id (get-terrain-* (level *world*) nx ny z))) nmob nx ny z)))))))
        (orig-x (x mob))
        (orig-y (y mob))
        (orig-z (z mob)))

    ;; we have 3 cases of movement:
    ;; 1) the mob moves while is riding someone (currently available if the mob teleports somewhere with a mount, as normally the rider does not move, only gives directions to the mount)
    ;; 2) the mob moves while being ridden by someone (all kinds of mounted movement)
    ;; 3) the mob moves by itself
    (cond
      ((riding-mob-id mob)
       (progn
         ;; it is imperative the a 1-tile mob rides a multi-tile mob and not vice versa

         (funcall place-func (get-mob-by-id (riding-mob-id mob)))

         ;; place the rider
         (setf (x mob) x (y mob) y (z mob) z)
         (setf (aref (mobs (level *world*)) x y z) (id mob))
         ))
      ((mounted-by-mob-id mob)
       (progn
         ;; it is imperative the a 1-tile mob rides a multi-tile mob and not vice versa

         (funcall place-func mob)
         
         ;; place the rider
         (setf (x (get-mob-by-id (mounted-by-mob-id mob))) x
               (y (get-mob-by-id (mounted-by-mob-id mob))) y
               (z (get-mob-by-id (mounted-by-mob-id mob))) z)
         (setf (aref (mobs (level *world*)) (x mob) (y mob) (z mob)) (mounted-by-mob-id mob))
         ))
      (t
       (progn
         (funcall place-func mob))))

    ;; apply gravity
    (when (apply-gravity mob)
      (let ((init-z (z mob)) (cur-dmg 0))
        (set-mob-location mob (x mob) (y mob) (apply-gravity mob))
        (setf cur-dmg (* 5 (1- (- init-z (z mob)))))
        (decf (cur-hp mob) cur-dmg)
        (when (> cur-dmg 0)
          (print-visible-message (x mob) (y mob) (z mob) (level *world*)
                                 (format nil "~A falls and takes ~A damage. " (visible-name mob) cur-dmg)))
        (when (check-dead mob)
          (make-dead mob :splatter t :msg t :msg-newline nil :killer nil :corpse t :aux-params ()))))
    
    ;; apply gravity to the mob, standing on your head, if any
    (when (and (get-terrain-* (level *world*) orig-x orig-y (1+ orig-z))
               (not (get-terrain-type-trait (get-terrain-* (level *world*) orig-x orig-y (1+ orig-z)) +terrain-trait-opaque-floor+))
               (get-mob-* (level *world*) orig-x orig-y (1+ orig-z)))
      (set-mob-location (get-mob-* (level *world*) orig-x orig-y (1+ (z mob))) orig-x orig-y (1+ orig-z)))
    ))

(defun move-mob (mob dir &key (push nil))
  (let ((dx 0)
        (dy 0)
        (sx (x mob))
        (sy (y mob))
        (along-dir)
        (opposite-dir)
        (not-along-dir)
        (near-opposite-dir)
        (to-the-left-dir)
        (to-the-right-dir)
        (c-dir))
    (declare (type fixnum dx dy))


    ;; if being ridden - restore the direction from the order being given by the rider
    (when (and (mounted-by-mob-id mob)
               (order-for-next-turn mob))
      (setf dir (order-for-next-turn mob)))
    
    (multiple-value-setq (dx dy) (x-y-dir dir))

    ;; if riding somebody, only give an order to your mount but do not move yourself
    (when (riding-mob-id mob)
      (logger (format nil "MOVE-MOB: ~A [~A] gives orders to mount ~A [~A] to move in the dir ~A~%" (name mob) (id mob) (name (get-mob-by-id (riding-mob-id mob))) (id (get-mob-by-id (riding-mob-id mob))) dir))

      ;; assign the order for the mount for its next turn
      (setf (order-for-next-turn (get-mob-by-id (riding-mob-id mob))) dir)
      
      ;; perform the attack in the chosen direction (otherwise it will be only the mount that attacks)
      (let ((check-result (check-move-on-level mob (+ (x mob) dx) (+ (y mob) dy) (z mob))))
        ;; right now multi-tile mobs can not ride other multitile mobs and I intend to leave it this way
        ;; this means that there will always be only one mob in the affected mob list
        (when (and check-result
                   (not (eq check-result t))
                   (eq (first check-result) :mobs)
                   (not (eq (get-mob-by-id (riding-mob-id mob))
                            (first (second check-result)))))
          (on-bump (first (second check-result)) mob)
          (return-from move-mob check-result))

        (when (or (eq check-result nil)
                  (and (eq (check-move-on-level (get-mob-by-id (riding-mob-id mob)) (+ (x mob) dx) (+ (y mob) dy) (z mob)) nil)
                       (= dir (x-y-into-dir (car (momentum-dir (get-mob-by-id (riding-mob-id mob)))) (cdr (momentum-dir (get-mob-by-id (riding-mob-id mob))))))))
          (logger (format nil "MOVE-MOB: ~A [~A] is unable to move to give order (CHECK = ~A, MOUNT DIR ~A)~%" (name mob) (id mob) check-result
                          (x-y-into-dir (car (momentum-dir (get-mob-by-id (riding-mob-id mob)))) (cdr (momentum-dir (get-mob-by-id (riding-mob-id mob)))))))
          (return-from move-mob nil)))

      (make-act mob (move-spd (get-mob-type-by-id (mob-type mob))))
      (return-from move-mob t))

    (setf c-dir (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))))
    (multiple-value-setq (along-dir not-along-dir to-the-left-dir to-the-right-dir near-opposite-dir opposite-dir) (dir-neighbours c-dir))

    (when (mob-ability-p mob +mob-abil-momentum+)
      (setf push t))

    (logger (format nil "MOVE-MOB: ~A - spd ~A, c-dir ~A, dir ~A, ALONG-DIRS ~A, NOT-ALONG-DIRS ~A, OPPOSITE-DIRS ~A~%" (name mob) (momentum-spd mob) c-dir dir along-dir not-along-dir opposite-dir))
    (cond
      ;; NB: all this is necessary to introduce movement with momentum (for horses and the like)
      ;; (-1.-1) ( 0.-1) ( 1.-1)
      ;; (-1. 0) ( 0. 0) ( 1. 0)
      ;; (-1. 1) ( 0. 1) ( 1. 1)
      ;; if mob already moving in the direction ( 1. 1), then the chosen direction can be
      ;;   "opposite direction" which is (-1.-1)
      ;;   "along the direction" which is ( 1. 1), ( 0. 1) or ( 1. 0)
      ;;   "not along the direction" which is (-1. 1), (-1. 0), ( 1.-1) or ( 0.-1)
      ;;   "direction to the left" which is ( 1. -1) or ( 0.-1), note that mob's direction will be set to ( 1.-1) when the mob tries to change its direction abruptly
      ;;   "direction to the right" which is (-1. 1) or (-1. 0), note that mob's direction will be set to (-1. 1) when the mob tries to change its direction abruptly
      ;;   "near the opposite direction" which is (-1. 0) or ( 0.-1)
      ;; if speed is 0 or moving along the direction - increase spead and set the movement dir to chosen dir
      ((or (and (not (mob-ability-p mob +mob-abil-facing+))
                (zerop (momentum-spd mob))
                (/= dir 5))
           (and (/= dir 5)
                (find dir along-dir)))
       (progn
         (incf (momentum-spd mob))
         (setf (car (momentum-dir mob)) dx)
         (setf (cdr (momentum-dir mob)) dy)
         (logger (format nil "MOVE-MOB ALONG - SPD ~A DIR ~A DX ~A DY ~A~%" (momentum-spd mob) (momentum-dir mob) dx dy))))
      ;; if moving in the opposite direction - reduce speed 
      ((find dir opposite-dir)
       (progn
         (decf (momentum-spd mob))
         ;; if the mob is has facing, choose one of the directions neighbouring the opposite one, so that he turns around using this direction 
         (when (mob-ability-p mob +mob-abil-facing+)
           (multiple-value-setq (along-dir not-along-dir to-the-left-dir to-the-right-dir near-opposite-dir opposite-dir) (dir-neighbours dir))
           (if (zerop (random 2))
             (multiple-value-setq (dx dy) (x-y-dir (first near-opposite-dir)))
             (multiple-value-setq (dx dy) (x-y-dir (second near-opposite-dir))))
           (setf (car (momentum-dir mob)) dx)
           (setf (cdr (momentum-dir mob)) dy)
           (setf dx 0 dy 0))
         (logger (format nil "MOVE-MOB OPPOSITE - SPD ~A DIR ~A DX ~A DY ~A~%" (momentum-spd mob) (momentum-dir mob) dx dy))))
      ;; if moving not along the direction - reduce spead and change the direction
      ((find dir not-along-dir)
       (progn
         (decf (momentum-spd mob))
         ;; change direction either to the left or to the right depending on where the proposed direction lies
         (if (find dir to-the-left-dir)
           (multiple-value-setq (dx dy) (x-y-dir (first to-the-left-dir)))
           (multiple-value-setq (dx dy) (x-y-dir (first to-the-right-dir))))
         (setf (car (momentum-dir mob)) dx)
         (setf (cdr (momentum-dir mob)) dy)
         (when (mob-ability-p mob +mob-abil-facing+)
           (setf dx 0 dy 0))
         (logger (format nil "MOVE-MOB NOT ALONG - SPD ~A DIR ~A DX ~A DY ~A~%" (momentum-spd mob) (momentum-dir mob) dx dy))))
      )

    ;; normalize direction
    ;; for x axis
    (when (> (car (momentum-dir mob)) 1)
      (setf (car (momentum-dir mob)) 1))
    (when (< (car (momentum-dir mob)) -1)
      (setf (car (momentum-dir mob)) -1))
    ;; for y axis
    (when (> (cdr (momentum-dir mob)) 1)
      (setf (cdr (momentum-dir mob)) 1))
    (when (< (cdr (momentum-dir mob)) -1)
      (setf (cdr (momentum-dir mob)) -1))

    ;; limit max speed
    (when (and (mob-ability-p mob +mob-abil-momentum+)
               (> (momentum-spd mob) (mob-ability-p mob +mob-abil-momentum+)))
      (setf (momentum-spd mob) (mob-ability-p mob +mob-abil-momentum+)))
    (when (not (mob-ability-p mob +mob-abil-momentum+))
      (setf (momentum-spd mob) 0))
    (when (< (momentum-spd mob) 0)
      (setf (momentum-spd mob) 0))  

    (when (mob-ability-p mob +mob-abil-momentum+)
      (setf dx (car (momentum-dir mob)))
      (setf dy (cdr (momentum-dir mob))))
    
    (loop repeat (if (zerop (momentum-spd mob))
                   1
                   (momentum-spd mob))
          for move-result = nil
          for x = (+ (x mob) dx)
          for y = (+ (y mob) dy)
          for z = (cond
                    ;; if the current cell is slope up and the cell along the direction is a wall - increase the target z level, so that the mob can go up
                    ((and (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) (z mob)) +terrain-trait-slope-up+)
                          (get-terrain-type-trait (get-terrain-* (level *world*) x y (z mob)) +terrain-trait-blocks-move+))
                     (1+ (z mob)))
                    ;; if the target cell is slope down - decrease the target z level, so that the mob can go down
                    ((get-terrain-type-trait (get-terrain-* (level *world*) x y (z mob)) +terrain-trait-slope-down+)
                     (1- (z mob)))
                    ;; otherwise the z level in unchanged
                    (t (z mob)))
          for check-result = (check-move-on-level mob x y z)
          do
             (logger (format nil "MOVE-MOB: CHECK-MOVE ~A~%" check-result))
             (cond
               ;; all clear - move freely
               ((eq check-result t)
                
                (set-mob-location mob x y z)
                (setf move-result t)
                )
               ;; bumped into an obstacle or the map border
               ((or (eq check-result nil) (eq (first check-result) :obstacles))

                (when (mob-ability-p mob +mob-abil-momentum+)
                  (setf (momentum-spd mob) 0)
                  (setf (momentum-dir mob) (cons 0 0)))
                (setf (order-for-next-turn mob) 5)

                ;; a precaution so that horses finish their turn when they made a move and bumped into an obstacle
                ;; while not finishing their turn if they try to move into an obstacle standing next to it
                (when (or (/= sx (x mob))
                          (/= sy (y mob))
                          (and (mob-ability-p mob +mob-abil-facing+)
                               (/= c-dir (x-y-into-dir dx dy)))
                          )
                  (make-act mob (move-spd (get-mob-type-by-id (mob-type mob)))))
                (setf move-result nil)
                (loop-finish)
                )
               ;; bumped into a mob
               ((eq (first check-result) :mobs) 
                (logger (format nil "MOVE-MOB: ~A [~A] bumped into mobs (~A)~%" (name mob) (id mob) (loop named nil
                                                                                                          with str = (create-string)
                                                                                                          for tmob in (second check-result)
                                                                                                          do
                                                                                                             (format str "~A [~A], " (name tmob) (id tmob))
                                                                                                          finally
                                                                                                             (return-from nil str))))

                (loop with cur-ap = (cur-ap mob) 
                      for target-mob in (second check-result) do
                        ;; if the mount bumps into its rider - do nothing
                        (if (and (mounted-by-mob-id mob)
                                 (eq target-mob (get-mob-by-id (mounted-by-mob-id mob))))
                          (progn 
                            (setf move-result t))
                          (progn
                            (when (and push
                                       (not (mob-ability-p target-mob +mob-abil-immovable+)))
                              ;; check if you can push the mob farther
                              (let* ((nx (+ (car (momentum-dir mob)) (x target-mob)))
                                     (ny (+ (cdr (momentum-dir mob)) (y target-mob)))
                                     (check-result-n (check-move-on-level target-mob nx ny z)))
                                (when (eq check-result-n t)
                                  (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                         (format nil "~A pushes ~A. " (visible-name mob) (visible-name target-mob)))
                                  (set-mob-location target-mob nx ny z)
                                  (set-mob-location mob x y z))
                                ))
                            (on-bump target-mob mob)))
                      finally
                         (when (> (map-size mob) 1)
                           (setf (cur-ap mob) cur-ap)
                           (make-act mob (get-melee-weapon-speed mob))))

                (when (eq move-result t)
                  (loop-finish))
                                
                
                (when (mob-ability-p mob +mob-abil-momentum+)
                  (setf (momentum-spd mob) 0)
                  (setf (momentum-dir mob) (cons 0 0)))
                (setf move-result check-result)
                (loop-finish))
               )
          finally
             (setf (order-for-next-turn mob) nil)
             (cond
               ((mob-ability-p mob +mob-abil-momentum+) (when (zerop (momentum-spd mob))
                                                          (setf (momentum-dir mob) (cons 0 0))))
               ((mob-ability-p mob +mob-abil-facing+) nil)
               (t (setf (momentum-dir mob) (cons 0 0))))
             
             (when (eq move-result t)
               (make-act mob (move-spd (get-mob-type-by-id (mob-type mob)))))
             
             (return-from move-mob move-result))
    )
  nil)

(defun make-act (mob speed)
  (logger (format nil "MAKE-ACT: ~A SPD ~A~%" (name mob) speed))
  (when (zerop speed) (return-from make-act nil))
  (decf (cur-ap mob) speed)
  (setf (made-turn mob) t)
  (when (eq mob *player*)
    (incf (player-game-time *world*) (truncate (* speed +normal-ap+) (max-ap mob)))))

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

        ;; if the target is mounted, 50% chance that the actor will bump target's mount
        (when (riding-mob-id target)
          (when (zerop (random 2))
            (setf target (get-mob-by-id (riding-mob-id target)))))
        
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
          (make-dead (get-mob-by-id (slave-mob-id target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params nil))
        )))
                     
(defun mob-depossess-target (actor)
  (logger (format nil "MOB-DEPOSSESS-TARGET: Master ~A [~A], slave [~A]~%" (name actor) (id actor) (slave-mob-id actor)))
  (let ((target (get-mob-by-id (slave-mob-id actor))))
    (logger (format nil "MOB-DEPOSSESS-TARGET: ~A [~A] releases its possession of ~A [~A]~%" (name actor) (id actor) (name target) (id target)))
    (setf (x target) (x actor) (y target) (y actor) (z target) (z actor))
    (add-mob-to-level-list (level *world*) target)
    
    (setf (master-mob-id target) nil)
    (setf (slave-mob-id actor) nil)
    (setf (face-mob-type-id actor) (mob-type actor))
    (rem-mob-effect actor +mob-effect-possessed+)
    (rem-mob-effect target +mob-effect-possessed+)
    (rem-mob-effect target +mob-effect-reveal-true-form+)

    ;; if the master is riding something - put slave as the rider
    (when (riding-mob-id actor)
      (setf (riding-mob-id target) (riding-mob-id actor))
      (setf (mounted-by-mob-id (get-mob-by-id (riding-mob-id target))) (id target)))
    
    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                           (format nil "~A releases its possession of ~A. " (name actor) (name target)))
  
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
                                       (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy) :z (z target)))))))
    
    
    (print-visible-message (x target) (y target) (z target) (level *world*) 
                           (format nil "~A is scorched by ~A for ~A damage. " (name target) (name actor) cur-dmg))
    (when (check-dead target)
      (when (mob-effect-p target +mob-effect-possessed+)
        (mob-depossess-target target))
      
      (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params nil)
      )
    
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
  (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                         (format nil "~A reloads his ~(~A~). " (visible-name actor) (get-weapon-name actor)))

  (make-act actor +normal-ap+))

(defun mob-shoot-target (actor target)
  (let ((cur-dmg 0) (bullets-left) (affected-targets nil) (completely-missed t))
    (unless (is-weapon-ranged actor)
      (return-from mob-shoot-target nil))

     ;; reduce the number of bullets in the magazine
    (if (> (get-ranged-weapon-charges actor) (get-ranged-weapon-rof actor))
      (progn
        (setf bullets-left (get-ranged-weapon-rof actor))
        (set-ranged-weapon-charges actor (- (get-ranged-weapon-charges actor) (get-ranged-weapon-rof actor))))
      (progn
        (setf bullets-left (get-ranged-weapon-charges actor))
        (set-ranged-weapon-charges actor 0)))
    
    ;; target under protection of divine shield - consume the shield and quit
    (when (mob-effect-p target +mob-effect-divine-shield+)
      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                             (format nil "~A shoots ~A. ~A takes no harm. " (visible-name actor) (visible-name target) (visible-name target)))
      (rem-mob-effect target +mob-effect-divine-shield+)
      (make-act actor (get-ranged-weapon-speed actor))
      (return-from mob-shoot-target nil))

    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                           (format nil "~A shoots ~A. " (visible-name actor) (visible-name target)))
    
    (loop repeat bullets-left
          with rx
          with ry
          with target1
          with tx
          with ty
          with tz
          do
             (setf rx 0 ry 0)
             ;; disperse ammo depending on the distance to the target
             (let ((dist (get-distance (x actor) (y actor) (x target) (y target))))
               (when (and (>= dist 2)
                          (< (- (r-acc actor) (* dist *acc-loss-per-tile*)) (random 100)))
                 (setf rx (- (random (+ 3 (* 2 (truncate dist (r-acc actor))))) 
                             (+ 1 (truncate dist (r-acc actor)))))
                 (setf ry (- (random (+ 3 (* 2 (truncate dist (r-acc actor))))) 
                             (+ 1 (truncate dist (r-acc actor)))))))
      
             ;; trace a line to the target so if we encounter an obstacle along the path we hit it
             (line-of-sight (x actor) (y actor) (z actor) (+ (x target) rx) (+ (y target) ry) (z target)
                            #'(lambda (dx dy dz prev-cell)
                                (declare (type fixnum dx dy dz))
                                (let ((exit-result t))
                                  (block nil
                                    (setf tx dx ty dy tz dz)

                                    (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                      (setf exit-result 'exit)
                                      (return))
                                    )
                                  exit-result)))
             ;; place a fire dot if the dest point is visible
             (place-visible-animation tx ty tz (level *world*) +anim-type-fire-dot+ :params ())
             
             (setf target1 (get-mob-* (level *world*) tx ty tz))


             ;; if the target is mounted, 50% chance that the actor will hit target's mount
             (when (and target1
                        (riding-mob-id target1))
               (when (zerop (random 2))
                 (setf target1 (get-mob-by-id (riding-mob-id target1)))))
             
             (setf cur-dmg (+ (random (- (1+ (get-ranged-weapon-dmg-max actor)) (get-ranged-weapon-dmg-min actor))) 
                              (get-ranged-weapon-dmg-min actor)))
             
             (when target1
               (setf completely-missed nil)
               
               ;; reduce damage by the amount of risistance to this damage type
               ;; first reduce the damage directly
               ;; then - by percent
               (when (get-armor-resist target1 (get-ranged-weapon-dmg-type actor))
                 (decf cur-dmg (get-armor-d-resist target1 (get-ranged-weapon-dmg-type actor)))
                 (setf cur-dmg (truncate (* cur-dmg (- 100 (get-armor-%-resist target1 (get-ranged-weapon-dmg-type actor)))) 100)))
               (when (< cur-dmg 0) (setf cur-dmg 0))
               
               (decf (cur-hp target1) cur-dmg)
               
               ;; place a blood spattering
               (when (> cur-dmg 0)
                 (let ((dir (1+ (random 9))))
                   (multiple-value-bind (dx dy) (x-y-dir dir) 				
                     (add-feature-to-level-list (level *world*) 
                                                (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target1) dx) :y (+ (y target1) dy) :z (z target))))))
               
               (if (find target1 affected-targets :key #'(lambda (n) (car n)))
                 (incf (cdr (find target1 affected-targets :key #'(lambda (n) (car n)))) cur-dmg)
                 (push (cons target1 cur-dmg) affected-targets))
               
               )
          )
    
    (loop for (a-target . dmg) in affected-targets do
      (if (zerop dmg)
          (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                 (format nil "~A is not hurt. " (visible-name a-target)))
          (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                 (format nil "~A is hit for ~A damage. " (visible-name a-target) dmg)))
      (when (check-dead a-target)
        (make-dead a-target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params (get-ranged-weapon-aux actor))
          
        (when (mob-effect-p a-target +mob-effect-possessed+)
          (setf (cur-hp (get-mob-by-id (slave-mob-id a-target))) 0)
          (make-dead (get-mob-by-id (slave-mob-id a-target)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ()))
        ))
    
    (when completely-missed
      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                             (format nil "~A misses. " (visible-name actor)))
      )
    (make-act actor (get-ranged-weapon-speed actor))
    ))

(defun mob-invoke-ability (actor target ability-type-id)
  (when (can-invoke-ability actor target ability-type-id)
    (let ((ability-type (get-ability-type-by-id ability-type-id)))
      (funcall (on-invoke ability-type) ability-type actor target)
      (set-abil-cur-cd actor ability-type-id (abil-max-cd-p ability-type-id))
      (make-act actor (spd ability-type)))))

(defun make-melee-attack (actor target &key (weapon nil) (acc 100) (no-dodge nil) (make-act t))
  (logger (format nil "MAKE-MELEE-ATTACK: ~A attacks ~A~%" (name actor) (name target)))

  ;; no weapons - no attack
  (unless weapon (return-from make-melee-attack nil))

   ;; target under protection of divine shield - consume the shield and quit
  (when (mob-effect-p target +mob-effect-divine-shield+)
    (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                           (format nil "~@(~A~) attacks ~A, but can not harm ~A. " (visible-name actor) (visible-name target) (visible-name target)))
    (rem-mob-effect target +mob-effect-divine-shield+)
    (when make-act (make-act actor (get-melee-weapon-speed actor)))
    (return-from make-melee-attack nil))

  ;; if the target has keen senses - destroy the illusions
  (when (mob-ability-p target +mob-abil-keen-senses+)
    (when (mob-effect-p actor +mob-effect-divine-consealed+)
      (rem-mob-effect actor +mob-effect-divine-consealed+)
      (setf (face-mob-type-id actor) (mob-type actor))
      (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                             (format nil "~A reveals the true form of ~A. " (visible-name target) (get-qualified-name actor))))
    (when (mob-effect-p actor +mob-effect-possessed+)
      (unless (mob-effect-p actor +mob-effect-reveal-true-form+)
        (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                               (format nil "~A reveals the true form of ~A. " (visible-name target) (get-qualified-name actor))))
      (setf (face-mob-type-id actor) (mob-type actor))
      (set-mob-effect actor +mob-effect-reveal-true-form+ 5)))

  (multiple-value-bind (dx dy) (x-y-dir (1+ (random 9)))
    (let* ((cur-dmg) (dodge-chance) (failed-dodge nil) 
	   (x (+ dx (x target))) (y (+ dy (y target)))
           (dodge-target (cur-dodge target))
	   (check-result (check-move-on-level target x y (z target))))
      ;; check if attacker has hit the target
      (if (> acc (random 100))
        (progn
          ;; attacker hit
          ;; check if the target dodged
          (setf dodge-chance (random 100))

          (when no-dodge (setf dodge-target 0))
          
          (if (and (> dodge-target dodge-chance) 
                   (eq check-result t))
            ;; target dodged
            (progn
              (set-mob-location target x y (z target))

              ;; reduce the momentum to zero
              (setf (momentum-dir target) (cons 0 0))
              (setf (momentum-spd target) 0)

              (cond
                ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                      (get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target))))
                 (progn
                   (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                          (format nil "~@(~A~) attacks ~A, but ~A evades the attack. " (visible-name actor) (visible-name target) (visible-name target)))))
                ((get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                 (progn
                   (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                          (format nil "~@(~A~) attacks somebody, but it evades the attack. " (visible-name actor)))))
                ((get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target)))
                 (progn
                   (print-visible-message (x target) (y target) (z target) (level *world*) 
                                          (format nil "Somebody attacks ~A, but ~A evades the attack. " (visible-name target) (visible-name target))))))
              )
            ;; target did not dodge
            (progn
              (setf failed-dodge nil)
              (when (and (> dodge-target dodge-chance) (not (eq check-result t)))
                (cond
                  ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                        (get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target))))
                   (progn
                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                            (format nil "~@(~A~) attacks ~A, and ~A failes to dodge. " (visible-name actor) (visible-name target) (visible-name target)))))
                  ((get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                   (progn
                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                            (format nil "~@(~A~) attacks somebody, and it failes to dodge. " (visible-name actor)))))
                  ((get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target)))
                   (progn
                     (print-visible-message (x target) (y target) (z target) (level *world*) 
                                            (format nil "Somebody attacks ~A, and ~A failes to dodge. " (visible-name target) (visible-name target))))))
                
                (setf failed-dodge t))
              ;; apply damage
              (setf cur-dmg (+ (random (- (1+ (get-melee-weapon-dmg-max-simple weapon)) (get-melee-weapon-dmg-min-simple weapon))) 
                               (get-melee-weapon-dmg-min-simple weapon)))
              
              (when (= (faction actor) (faction target))
                (setf cur-dmg (get-melee-weapon-dmg-min-simple weapon)))

              ;; reduce damage by the amount of risistance to this damage type
              ;; first reduce the damage directly
              ;; then - by percent
              (when (get-armor-resist target (get-melee-weapon-dmg-type-simple weapon))
                (decf cur-dmg (get-armor-d-resist target (get-melee-weapon-dmg-type-simple weapon)))
                (setf cur-dmg (truncate (* cur-dmg (- 100 (get-armor-%-resist target (get-melee-weapon-dmg-type-simple weapon)))) 100)))
              (when (< cur-dmg 0) (setf cur-dmg 0))

              (decf (cur-hp target) cur-dmg)
              ;; place a blood spattering
              (unless (zerop cur-dmg)
                (let ((dir (1+ (random 9))))
                  (multiple-value-bind (dx dy) (x-y-dir dir) 				
                    (when (> 50 (random 100))
                      (add-feature-to-level-list (level *world*) 
                                                 (make-instance 'feature :feature-type +feature-blood-fresh+ :x (+ (x target) dx) :y (+ (y target) dy) :z (z target)))))))
              (if (zerop cur-dmg)
                (progn
                  (cond
                    ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                          (get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target))))
                     (progn
                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                              (format nil "~@(~A~) hits ~A, but ~A is not hurt. " (visible-name actor) (visible-name target) (visible-name target)))))
                    ((get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                     (progn
                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                              (format nil "~@(~A~) hits somebody, but it is not hurt. " (visible-name actor)))))
                    ((get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target)))
                     (progn
                       (print-visible-message (x target) (y target) (z target) (level *world*) 
                                              (format nil "Somebody hits ~A, but ~A is not hurt. " (visible-name target) (visible-name target)))))))
                (progn
                  (cond
                    ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                          (get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target))))
                     (progn
                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                              (format nil "~@(~A~) hits ~A for ~A damage. " (visible-name actor) (visible-name target) cur-dmg))))
                    ((get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                     (progn
                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                              (format nil "~@(~A~) hits somebody for ~A damage. " (visible-name actor) cur-dmg))))
                    ((get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target)))
                     (progn
                       (print-visible-message (x target) (y target) (z target) (level *world*) 
                                              (format nil "Somebody hits ~A for ~A damage. " (visible-name target) cur-dmg))))))
                )
              )))
        (progn
          ;; attacker missed
          (cond
            ((and (get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
                  (get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target))))
             (progn
               (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                      (format nil "~@(~A~) misses ~A. " (visible-name actor) (visible-name target)))))
            ((get-single-memo-visibility (get-memo-* (level *world*) (x actor) (y actor) (z actor)))
             (progn
               (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                      (format nil "~@(~A~) misses somebody. " (visible-name actor)))))
            ((get-single-memo-visibility (get-memo-* (level *world*) (x target) (y target) (z target)))
             (progn
               (print-visible-message (x target) (y target) (z target) (level *world*) 
                                      (format nil "Somebody misses ~A. " (visible-name target))))))
          
          ))
      ))

  (when (check-dead target)
    (if (mob-effect-p target +mob-effect-possessed+)
      (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse nil :aux-params ())
      (make-dead target :splatter t :msg t :msg-newline nil :killer actor :corpse t :aux-params (get-melee-weapon-aux-simple weapon)))
                                                                                                   
    )
  
  (when make-act (make-act actor (get-melee-weapon-speed-simple weapon)))
  
  )

(defun melee-target (attacker target)
  (logger (format nil "MELEE-TARGET: ~A attacks ~A~%" (name attacker) (name target)))
  ;; no weapons - no attack
  (unless (weapon attacker) (return-from melee-target nil))

  (make-melee-attack attacker target :weapon (weapon attacker) :acc (m-acc attacker) :make-act t)

  )

(defun check-dead (mob)
  (when (<= (cur-hp mob) 0)
    (return-from check-dead t))
  nil)

(defun make-dead (mob &key (splatter t) (msg nil) (msg-newline nil) (killer nil) (corpse t) (aux-params ()))
  (let ((dead-msg-str (format nil "~A dies. " (visible-name mob))))
    
    (unless (dead= mob)
      (when (mob-ability-p mob +mob-abil-human+)
      (decf (total-humans *world*)))
    (when (mob-ability-p mob +mob-abil-demon+)
      (decf (total-demons *world*)))
    (when (mob-ability-p mob +mob-abil-angel+)
      (decf (total-angels *world*)))
    (when (mob-effect-p mob +mob-effect-blessed+)
      (decf (total-blessed *world*)))

    ;; place the corpse
    (when corpse
      (let ((item) (r) (left-body-str))
        (setf r 0)

        ;; determine which body part to sever (if any)
        (when (and aux-params
                   (find :chops-body-parts aux-params))
          (setf r (random 4)))

        (cond
          ;; sever head
          ((= r 1) (progn
                     (place-visible-animation (x mob) (y mob) (z mob) (level *world*) +anim-type-severed-body-part+ :params (list mob "head"))
                     (setf left-body-str "multilated body")
                     (when killer
                       (setf dead-msg-str (format nil "~@(~A~) chops off ~A's head. " (visible-name killer) (visible-name mob))))))
          ;; sever limb
          ((= r 2) (progn
                     (place-visible-animation (x mob) (y mob) (z mob) (level *world*) +anim-type-severed-body-part+ :params (list mob "limb"))
                     (setf left-body-str "multilated body")
                     (when killer
                       (setf dead-msg-str (format nil "~@(~A~) severs ~A's limb. " (visible-name killer) (visible-name mob))))))
          ;; sever torso
          ((= r 3) (progn
                     (place-visible-animation (x mob) (y mob) (z mob) (level *world*) +anim-type-severed-body-part+ :params (list mob "upper body"))
                     (setf left-body-str "lower body")
                     (when killer
                       (setf dead-msg-str (format nil "~@(~A~) cuts ~A in half. " (visible-name killer) (visible-name mob))))))
          ;; do not sever anything
          (t (setf left-body-str "body")))

        (setf item (make-instance 'item :item-type +item-type-body-part+ :x (x mob) :y (y mob) :z (z mob)))
        (setf (name item) (format nil "~@(~A~)'s ~A" (name mob) left-body-str))
        (add-item-to-level-list (level *world*) item)
        (logger (format nil "MAKE-DEAD: ~A [~A] leaves ~A [~A] at (~A ~A)~%" (name mob) (id mob) (name item) (id item) (x mob) (y mob)))
        
        ))

    (when msg
      (print-visible-message (x mob) (y mob) (z mob) (level *world*) dead-msg-str)
      (when msg-newline (print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "~%"))))
    
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

    ;; if the target is being ridden, dismount the rider
    (when (mounted-by-mob-id mob)
      (setf (riding-mob-id (get-mob-by-id (mounted-by-mob-id mob))) nil)
      (adjust-dodge (get-mob-by-id (mounted-by-mob-id mob)))
      (add-mob-to-level-list (level *world*) (get-mob-by-id (mounted-by-mob-id mob))))
    ;; if the target is riding something, place back the mount on map
    (when (riding-mob-id mob)
      (setf (mounted-by-mob-id (get-mob-by-id (riding-mob-id mob))) nil)
      (setf (x (get-mob-by-id (riding-mob-id mob))) (x mob)
            (y (get-mob-by-id (riding-mob-id mob))) (y mob))
      (add-mob-to-level-list (level *world*) (get-mob-by-id (riding-mob-id mob))))
    
    ;; place blood stain if req
    (when (and splatter (< (random 100) 75))
      (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-stain+ :x (x mob) :y (y mob) :z (z mob))))
    
    (setf (dead= mob) t)))
  )

(defun mob-evolve (mob)
  (print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "~A assumes a superior form of ~A! " (name mob) (name (get-mob-type-by-id (evolve-into mob)))))
  
  (setf (mob-type mob) (evolve-into mob))
  (setf (cur-hp mob) (max-hp mob))
  (setf (cur-fp mob) 0)
  
  (setf (cur-sight mob) (base-sight mob))
  
  (setf (face-mob-type-id mob) (mob-type mob))
  (when (= (mob-type mob) +mob-type-demon+) 
    (set-name mob)
    (unless (eq mob *player*)
      (print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "It will be hereby known as ~A! " (name mob)))))
  
  (set-cur-weapons mob)
  (adjust-dodge mob)
  (adjust-armor mob)
  (adjust-m-acc mob)
  (adjust-r-acc mob)
  (adjust-sight mob)
  
  (when (mob-effect-p mob +mob-effect-possessed+)
    (setf (cur-hp (get-mob-by-id (slave-mob-id mob))) 0)
    (make-dead (get-mob-by-id (slave-mob-id mob)) :splatter nil :msg nil :msg-newline nil :corpse nil :aux-params ())
    (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-blood-stain+ :x (x mob) :y (y mob)))
    (print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "Its ascension destroyed its vessel."))
    
    (rem-mob-effect mob +mob-effect-possessed+)
    (setf (master-mob-id mob) nil)
    (setf (slave-mob-id mob) nil)
    )
  (print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "~%")))

(defgeneric on-tick (mob))

(defmethod on-tick ((mob mob))

  ;; increase cur-ap by max-ap
  ;(incf (cur-ap mob) (max-ap mob))
      
  (when (< (cur-fp mob) 0)
    (setf (cur-fp mob) 0))

  ;; a special case for revealing demons & angels that ride fiends & gargantaur
  (when (and (riding-mob-id mob)
             (or (mob-ability-p (get-mob-by-id (riding-mob-id mob)) +mob-abil-demon+)
                 (mob-ability-p (get-mob-by-id (riding-mob-id mob)) +mob-abil-angel+))
             (eq (mob-effect-p mob +mob-effect-reveal-true-form+) 1))
    (set-mob-effect mob +mob-effect-reveal-true-form+ 2))
             
  (loop for effect-id being the hash-key in (effects mob)
        when (and (not (eq (mob-effect-p mob effect-id) t))
                  (not (eq (mob-effect-p mob effect-id) nil)))
          do
             (set-mob-effect mob effect-id (1- (mob-effect-p mob effect-id)))

             (when (zerop (mob-effect-p mob effect-id))
               (rem-mob-effect mob effect-id)
               (when (= effect-id +mob-effect-reveal-true-form+)
                 (when (slave-mob-id mob)
                   (setf (face-mob-type-id mob) (mob-type (get-mob-by-id (slave-mob-id mob))))))))

  (loop for ability-id being the hash-key in (abilities-cd mob)
        when (not (zerop (abil-cur-cd-p mob ability-id)))
          do
             (set-abil-cur-cd mob ability-id (1- (abil-cur-cd-p mob ability-id))))
  
  (adjust-dodge mob)
  (adjust-armor mob)
  (adjust-m-acc mob)
  (adjust-r-acc mob)
  (adjust-sight mob)
  
  (when (and (evolve-into mob)
             (>= (cur-fp mob) (max-fp mob)))
    (mob-evolve mob))
  )
  

(defun get-current-mob-glyph-idx (mob &key (x (x mob)) (y (y mob)) (z (z mob)))
  (declare (ignore z))
  (cond  
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 3))
     114)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 1))
     115)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 9))
     116)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 7))
     117)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 6))
     112)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 4))
     113)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 2))
     111)
    ((and (> (map-size mob) 1)
          (= (+ (x mob) (car (momentum-dir mob))) x) (= (+ (y mob) (cdr (momentum-dir mob))) y)
          (= (x-y-into-dir (car (momentum-dir mob)) (cdr (momentum-dir mob))) 8))
     110)
    ((and (> (map-size mob) 1)
          (= (- (x mob) x) (* -1 (truncate (1- (map-size mob)) 2)))
          (= (- (y mob) y) (* -1 (truncate (1- (map-size mob)) 2))))
     106)
    ((and (> (map-size mob) 1)
          (= (- (x mob) x) (* 1 (truncate (1- (map-size mob)) 2)))
          (= (- (y mob) y) (* -1 (truncate (1- (map-size mob)) 2))))
     107)
    ((and (> (map-size mob) 1)
          (= (- (x mob) x) (* -1 (truncate (1- (map-size mob)) 2)))
          (= (- (y mob) y) (* 1 (truncate (1- (map-size mob)) 2))))
     105)
    ((and (> (map-size mob) 1)
          (= (- (x mob) x) (* 1 (truncate (1- (map-size mob)) 2)))
          (= (- (y mob) y) (* 1 (truncate (1- (map-size mob)) 2))))
     104)
    ((and (> (map-size mob) 1)
          (or (= (- (x mob) x) (* 1 (truncate (1- (map-size mob)) 2)))
              (= (- (x mob) x) (* -1 (truncate (1- (map-size mob)) 2)))))
     108)
    ((and (> (map-size mob) 1)
          (or (= (- (y mob) y) (* 1 (truncate (1- (map-size mob)) 2)))
              (= (- (y mob) y) (* -1 (truncate (1- (map-size mob)) 2)))))
     109)
    ((and (> (map-size mob) 1)
          (or (/= (- (x mob) x) 0)
              (/= (- (y mob) y) 0)))
     0)
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



