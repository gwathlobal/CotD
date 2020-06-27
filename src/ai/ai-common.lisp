(in-package :cotd)

(defgeneric ai-function (mob))

(defparameter *ms-inside-path* 0)
(defparameter *ms-inside-path-start* 0)

(defun check-move-for-ai (mob dx dy dz cx cy cz &key (final-dst nil))
  (declare (optimize (speed 3))
           (type fixnum dx dy dz cx cy cz))
  
  (let ((sx 0) (sy 0) (move-result nil)
        (map-size (if (riding-mob-id mob)
                    (map-size (get-mob-by-id (riding-mob-id mob)))
                    (map-size mob))))
    (declare (type fixnum sx sy map-size))
    ;; calculate the coords of the mob's NE corner
    (setf sx (- dx (truncate (1- map-size) 2)))
    (setf sy (- dy (truncate (1- map-size) 2)))

    (loop for nx of-type fixnum from sx below (+ sx map-size) do
      (loop for ny of-type fixnum from sy below (+ sy map-size) do
        ;; cant move beyond level borders 
        (when (or (< nx 0) (< ny 0) (< dz 0) (>= nx (array-dimension (terrain (level *world*)) 0)) (>= ny (array-dimension (terrain (level *world*)) 1)) (>= dz (array-dimension (terrain (level *world*)) 2)))
          (return-from check-move-for-ai nil))

        (setf move-result nil)

        ;; can move if not impassable 
        (when (not (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move+))
          (setf move-result t))

        ;; can move if a door (not important if open or closed)
        (when (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-openable-door+)
          (setf move-result t))

        ;; can move if a window & you can open windows
        (when (and (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-openable-window+)
                   (mob-ability-p mob +mob-abil-open-close-window+))
          (setf move-result t))

        (unless move-result
          (return-from check-move-for-ai nil))
        
        (setf move-result nil)

        ;; can go anywhere horizontally or directly up/below if the current tile is water 
        (when (and (or (= (- cz dz) 0)
                       (and (/= (- cz dz) 0)
                            (= nx cx)
                            (= ny cy))
                       )
                   (get-terrain-type-trait (get-terrain-* (level *world*) cx cy cz) +terrain-trait-water+)
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-water+))
          (setf move-result t))
        
        ;; can go from down to up if the source tile is water and the landing tile has floor and is not directly above the source tile
        (when (and (> (- dz cz) 0)
                   (not (and (= cx nx)
                             (= cy ny)))
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move+))
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny cz) +terrain-trait-blocks-move+)
                   (get-terrain-type-trait (get-terrain-* (level *world*) cx cy cz) +terrain-trait-water+)
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) cx cy (1+ cz)) +terrain-trait-blocks-move-floor+)))
          (setf move-result t))

        ;; can go from up to down if the landing tile is water and is not directly below the source tile
        (when (and (< (- dz cz) 0)
                   (or (/= (- dx cx) 0)
                       (/= (- dy cy) 0))
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-water+)
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) nx ny cz) +terrain-trait-blocks-move-floor+))
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) nx ny cz) +terrain-trait-water+)))
          (setf move-result t))
        
        ;; can go from down to up if the source tile is slope up and the landing tile has floor and is not directly above the source tile
        (when (and (> (- dz cz) 0)
                   (not (and (= cx nx)
                             (= cy ny)))
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move-floor+)
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny cz) +terrain-trait-blocks-move+)
                   (get-terrain-type-trait (get-terrain-* (level *world*) cx cy cz) +terrain-trait-slope-up+)
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) cx cy (1+ cz)) +terrain-trait-blocks-move-floor+)))
          (setf move-result t))

        ;; can go from up to down if the landing tile is floor and is not directly below the source tile
        (when (and (< (- dz cz) 0)
                   (or (/= (- dx cx) 0)
                       (/= (- dy cy) 0))
                   (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move-floor+)
                   (not (get-terrain-type-trait (get-terrain-* (level *world*) nx ny cz) +terrain-trait-blocks-move-floor+)))
          (setf move-result t))

        ;; can go horizontally if the landing tile has opaque floor and there is no final destination
        ;; or can go horizontally if the landing tile has opaque floor and it is NOT the final distination
        ;; or can go horizontally if the landing tile is the final destination (and we do not care about the floor)
        (when (or (and (= (- dz cz) 0)
                       (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move-floor+)
                       (not final-dst))
                  (and (= (- dz cz) 0)
                       final-dst
                       (get-terrain-type-trait (get-terrain-* (level *world*) nx ny dz) +terrain-trait-blocks-move-floor+)
                       (not (and (= nx (first final-dst))
                                 (= ny (second final-dst))
                                 (= dz (third final-dst)))))
                  (and (= (- dz cz) 0)
                       final-dst
                       (and (= nx (first final-dst))
                            (= ny (second final-dst))
                            (= dz (third final-dst)))))
          (setf move-result t))

        ;; you can go anywhere horizontaly or directly up/down if you are climbing and there is a wall or floor next to you
        (when (and (not move-result)
                   (mob-effect-p mob +mob-effect-climbing-mode+)
                   (or (= (- cz dz) 0)
                       (and (/= (- cz dz) 0)
                            (= nx cx)
                            (= ny cy))
                       )
                   (check-move-along-z cx cy cz nx ny dz)
                   (funcall #'(lambda ()
                                (let ((result nil))
                                  (check-surroundings nx ny nil #'(lambda (dx dy)
                                                                    (when (and (not (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-not-climable+))
                                                                               (or (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-blocks-move-floor+)
                                                                                   (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-blocks-move+)))
                                                                      (setf result t))))
                                  result))))
          (setf move-result t))

        ;; you can go anywhere horizontaly or directly up/down if you are flying
        (when (and (not move-result)
                   (mob-effect-p mob +mob-effect-flying+)
                   (or (= (- cz dz) 0)
                       (and (/= (- cz dz) 0)
                            (= nx cx)
                            (= ny cy))
                       )
                   (check-move-along-z cx cy cz nx ny dz)
                   )
          (setf move-result t))

        (when (and (not move-result)
                   (mob-effect-p mob +mob-effect-flying+)
                   (> (map-size mob) 1)
                   (/= (- cz dz) 0)
                   (check-move-along-z nx ny cz nx ny dz)
                   )
          (setf move-result t))

        ;; you can not go directly up if the you are under effect of gravity pull
        (when (and (and (< (- cz dz) 0)
                        (= nx cx)
                        (= ny cy))
                   (mob-effect-p mob +mob-effect-gravity-pull+))
          (setf move-result nil))
        
        (unless move-result
          (return-from check-move-for-ai nil))
        
            ))

       
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
                                               (if (< (get-distance (x mob) (y mob) (car a) (cdr a))
                                                      (get-distance (x mob) (y mob) (car b) (cdr b)))
                                                 t
                                                 nil))))

    ;;(format t "AI-FIND-MOVE-AROUND: Cell list sorted ~A~%" cell-list)
    
    ;; check each cell for passability
    (loop for (dx . dy) in cell-list
          when (and (level-cells-connected-p (level *world*) dx dy (z mob) (x mob) (y mob) (z mob) map-size (get-mob-move-mode mob))
                    (check-move-for-ai mob dx dy (z mob) dx dy (z mob)))
            do
               ;;(format t "AI-FIND-MOVE-AROUND: Return value ~A~%" (cons dx dy))
               (return-from ai-find-move-around (list dx dy (z mob))))

    ;;(format t "AI-FIND-MOVE-AROUND: Return value ~A~%" nil)
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
      (if (check-mob-visible mob :observer *player* :complete-check t)
        (generate-sound mob (x mob) (y mob) (z mob) 100 #'(lambda (str)
                                                            (format nil "~A cries: \"Help! Help!\"~A. " (capitalize-name (prepend-article +article-the+ (visible-name mob))) str))
                        :force-sound t)
        (generate-sound mob (x mob) (y mob) (z mob) 100 #'(lambda (str)
                                                            (format nil "Somebody cries: \"Help! Help!\"~A. " str))
                      :force-sound t))
      ;(print-visible-message (x mob) (y mob) (z mob) (level *world*) (format nil "~A cries: \"Help! Help!\" " (visible-name mob)))
      )
    (if (mob-ability-p mob +mob-abil-immobile+)
      (move-mob mob 5)
    ;; if can't move away - try any random direction
      (unless (move-mob mob (x-y-into-dir step-x step-y))
        (logger (format nil "AI-FUNCTION: ~A [~A] could not flee. Try to move randomly.~%" (name mob) (id mob)))
        (ai-mob-random-dir mob)))
    ))

(defun ai-mob-random-dir (mob)
  (logger (format nil "AI-FUNCTION: ~A [~A] tries to move randomly.~%" (name mob) (id mob)))
  (if (mob-ability-p mob +mob-abil-immobile+)
    (move-mob mob 5)
    (loop for dir = (+ (random 9) 1)
          until (move-mob mob dir))))

(defun thread-path-loop (stream)
  (loop while t do
    (bt:with-lock-held ((path-lock *world*))      
      (if (and (< (cur-mob-path *world*) (length (mob-id-list (level *world*)))) (not (made-turn *player*)))
        (progn
          (when (and (not (eq *player* (get-mob-by-id (cur-mob-path *world*))))
                     (not (dead= (get-mob-by-id (cur-mob-path *world*))))
                     (not (path (get-mob-by-id (cur-mob-path *world*)))))
            (logger (format nil "~%THREAD: Mob ~A [~A] calculates paths~%" (name (get-mob-by-id (cur-mob-path *world*))) (id (get-mob-by-id (cur-mob-path *world*)))) stream)
            (let* ((mob (get-mob-by-id (cur-mob-path *world*)))
                   (rx (- (+ 10 (x mob))
                          (1+ (random 20)))) 
                   (ry (- (+ 10 (y mob))
                          (1+ (random 20))))
                   (rz (- (+ 5 (z mob))
                          (1+ (random 10))))
                   )
              (declare (type fixnum rx ry))

              ;; if the mob destination is not set, choose a random destination
              (unless (path-dst mob)
                (loop while (or (< rx 0) (< ry 0) (< rz 0) (>= rx (array-dimension (terrain (level *world*)) 0)) (>= ry (array-dimension (terrain (level *world*)) 1)) (>= rz (array-dimension (terrain (level *world*)) 2))
                                (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move+)
                                ;(not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move-floor+))
                                (and (get-terrain-type-trait (get-terrain-* (level *world*) (x mob) (y mob) (z mob)) +terrain-trait-water+)
                                     (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-water+))
                                     (not (get-terrain-type-trait (get-terrain-* (level *world*) rx ry rz) +terrain-trait-blocks-move-floor+))
                                     (not (mob-effect-p mob +mob-effect-flying+)))
                                (not (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) rx ry rz (if (riding-mob-id mob)
                                                                                                                 (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                 (map-size mob))
                                                              (get-mob-move-mode mob)))
                                )
                      do
                         (setf rx (- (+ 10 (x mob))
                                     (1+ (random 20))))
                         (setf ry (- (+ 10 (y mob))
                                     (1+ (random 20))))
                         (setf rz (- (+ 5 (z mob))
                                     (1+ (random 10)))))
                (setf (path-dst mob) (list rx ry rz)))

              (when (level-cells-connected-p (level *world*) (x mob) (y mob) (z mob) (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob)) (if (riding-mob-id mob)
                                                                                                                                                             (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                                                                                             (map-size mob))
                                             (get-mob-move-mode mob))
                (logger (format nil "THREAD: Mob (~A, ~A, ~A) wants to go to (~A, ~A, ~A)~%" (x mob) (y mob) (z mob) (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob))) stream)
                (ai-plot-path-to-dst mob (first (path-dst mob)) (second (path-dst mob)) (third (path-dst mob)))
                ))
            )
          (incf (cur-mob-path *world*))
          (logger (format nil "THREAD: cur-mob-path - ~A~%" (cur-mob-path *world*)) stream))
        (progn
          (logger (format nil "THREAD: Done calculating paths~%~%") stream)
          (setf (cur-mob-path *world*) (length (mob-id-list (level *world*))))
          (bt:condition-wait (path-cv *world*) (path-lock *world*)))
        
        ))))

(defun ai-set-path-dst (actor tx ty tz)
  (logger (format nil "AI-SET-PATH-DST: level-connected-p = ~A, level-connected actor = ~A, level-connected target = ~A~%"
                  (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) tx ty tz (if (riding-mob-id actor)
                                                                                                    (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                    (map-size actor))
                                           (get-mob-move-mode actor))
                  (get-level-connect-map-value (level *world*) (x actor) (y actor) (z actor) (if (riding-mob-id actor)
                                                                                               (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                               (map-size actor))
                                               (get-mob-move-mode actor))
                  (get-level-connect-map-value (level *world*) tx ty tz (if (riding-mob-id actor)
                                                                          (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                          (map-size actor))
                                               (get-mob-move-mode actor))))
  (cond
    ((= +connect-room-none+ (get-level-connect-map-value (level *world*) (x actor) (y actor) (z actor) (if (riding-mob-id actor)
                                                                                                         (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                                         (map-size actor))
                                                         (get-mob-move-mode actor)))
     (logger (format nil "AI-SET-PATH-DST: level-connected actor = ~A, need to move randomly~%" +connect-room-none+))
     (setf (path-dst actor) nil)
     (setf (path actor) nil))
    ((level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) tx ty tz (if (riding-mob-id actor)
                                                                                       (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                       (map-size actor))
                              (get-mob-move-mode actor))
     (setf (path-dst actor) (list tx ty tz))
     (setf (path actor) nil))
    ((and (> (map-size actor) 1)
          (ai-find-move-around actor tx ty))
     (setf (path-dst actor) (ai-find-move-around actor tx ty))
     (setf (path actor) nil))
    (t
     (setf (path-dst actor) nil)
     (setf (path actor) nil))))

(defun ai-plot-path-to-dst (actor tx ty tz)
  (let ((path nil))
    (when (level-cells-connected-p (level *world*) (x actor) (y actor) (z actor) tx ty tz (if (riding-mob-id actor)
                                                                                            (map-size (get-mob-by-id (riding-mob-id actor)))
                                                                                            (map-size actor))
                                   (get-mob-move-mode actor))
      (logger (format nil "AI-PLOT-PATH-TO-DST: Mob (~A, ~A, ~A) wants to go to (~A, ~A, ~A)~%" (x actor) (y actor) (z actor) tx ty tz))
      ;;(format t "~%TIME-ELAPSED AI ~A [~A] before AI-PLOT-PATH-TO-DST:: ~A~%" (name actor) (id actor) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      (setf path (a-star (list (x actor) (y actor) (z actor)) (list tx ty tz) 
                         #'(lambda (dx dy dz cx cy cz) 
                             ;; checking for impassable objects
                             (check-move-for-ai actor dx dy dz cx cy cz :final-dst (list tx ty tz))
                             )
                         #'(lambda (dx dy dz)
                             ;; a magic hack here - as values of more than 10 give an unexplainable slowdown
                             (* (get-terrain-type-trait (get-terrain-* (level *world*) dx dy dz) +terrain-trait-move-cost-factor+)
                                (move-spd (get-mob-type-by-id (mob-type actor)))
                                1/10))))
      
      (pop path)
      (logger (format nil "AI-PLOT-PATH-TO-DST: Set mob path - ~A~%" path))
      ;;(format t "~%TIME-ELAPSED AI ~A [~A] after AI-PLOT-PATH-TO-DST:: ~A~%" (name actor) (id actor) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      (setf (path actor) path)
      )))

(defun ai-move-along-path (actor)
  (when (path actor)
    (let ((step) (step-x) (step-y) (step-z) (move-result nil))
      
      (logger (format nil "AI-MOVE-AlONG-PATH: Move mob along the path - ~A~%" (path actor)))
      (setf step (pop (path actor)))
      
      (setf step-x (- (first step) (x actor)))
      (setf step-y (- (second step) (y actor)))
      (setf step-z (- (third step) (z actor)))
      
      (setf move-result (check-move-on-level actor (first step) (second step) (third step)))
      
      (unless move-result
        (logger (format nil "AI-MOVE-AlONG-PATH: Can't move to target - (~A ~A ~A)~%" (first step) (second step) (third step)))
        (setf (path actor) nil)
        (setf (path-dst actor) nil)
        (return-from ai-move-along-path nil))
      
      (unless (x-y-into-dir step-x step-y)
        (logger (format nil "AI-MOVE-AlONG-PATH: Wrong direction supplied (~A ~A)~%" (first step) (second step)))
        (setf (path actor) nil)
        (setf (path-dst actor) nil)
        (return-from ai-move-along-path nil))
      
      ;; check if there is somebody on the target square
      (logger (format nil
                      "AI-MOVE-AlONG-PATH: MOVE-RESULT = ~A, NOT T = ~A, FACTION-RELATION = ~A, NOT LOVES-INFIGHTING = ~A, BLESS+BLESSED = ~A~%"
                      move-result
                      (not (eq move-result t))
                      (if (and move-result
                               (not (eq move-result t))
                               (eq (first move-result) :mobs))
                        (get-faction-relation (faction actor) (get-visible-faction (first (second move-result))))
                        nil)
                      (not (mob-ability-p actor +mob-abil-loves-infighting+))
                      (if (and move-result
                               (not (eq move-result t))
                               (eq (first move-result) :mobs))
                        (or (not (mob-ability-p actor +mob-abil-blessing-touch+))
                            (and (mob-ability-p actor +mob-abil-blessing-touch+)
                                 (mob-effect-p (first (second move-result)) +mob-effect-blessed+)
                                 (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))
                            (and (mob-ability-p actor +mob-abil-blessing-touch+)
                                 (not (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))))
                        nil)))
      
      ;;(format t "~%TIME-ELAPSED AI ~A [~A] before AI-MOVE-AlONG-PATH: ~A~%" (name actor) (id actor) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      (when (and move-result
                 (not (eq move-result t))
                 (eq (first move-result) :mobs)
                 (get-faction-relation (faction actor) (get-visible-faction (first (second move-result))))
                 (not (mob-ability-p actor +mob-abil-loves-infighting+))
                 (or (not (mob-ability-p actor +mob-abil-blessing-touch+))
                     (and (mob-ability-p actor +mob-abil-blessing-touch+)
                          (mob-effect-p (first (second move-result)) +mob-effect-blessed+)
                          (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))
                     (and (mob-ability-p actor +mob-abil-blessing-touch+)
                          (not (mob-ability-p (first (second move-result)) +mob-abil-can-be-blessed+))))
                 )
        (let ((final-cell nil))
          (when (and (path-dst actor)
                     (>= (get-distance-3d (x actor) (y actor) (z actor) (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor)))
                         2))
            ;;(format t "~%TIME-ELAPSED AI ~A [~A] inside AI-MOVE-AlONG-PATH: ~A~%" (name actor) (id actor) (- (get-internal-real-time) *time-at-end-of-player-turn*))
            (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                        (when (eq (check-move-on-level actor dx dy (z actor)) t)
                                                          (unless final-cell
                                                            (setf final-cell (list dx dy)))
                                                          (when (< (get-distance-3d dx dy (z actor)
                                                                                    (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor)))
                                                                   (get-distance-3d (first final-cell) (second final-cell) (z actor)
                                                                                    (first (path-dst actor)) (second (path-dst actor)) (third (path-dst actor))))
                                                            (setf final-cell (list dx dy)))))))
          (when final-cell
            (setf step-x (- (first final-cell) (x actor)))
            (setf step-y (- (second final-cell) (y actor))))
          ))
      
      
      (setf move-result (move-mob actor (x-y-into-dir step-x step-y) :dir-z step-z))
      
      (logger (format nil "AI-FUNCTION: PATH-DST ~A, MOB (~A ~A ~A), MOVE-RESULT ~A~%" (path-dst actor) (x actor) (y actor) (z actor) move-result))
      ;;(format t "~%TIME-ELAPSED AI ~A [~A] after AI-MOVE-AlONG-PATH: ~A~%" (name actor) (id actor) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      (if move-result
        (progn
          (when (and (path-dst actor)
                     (= (x actor) (first (path-dst actor)))
                     (= (y actor) (second (path-dst actor)))
                     (= (z actor) (third (path-dst actor))))
            (setf (path-dst actor) nil))
          (return-from ai-move-along-path t))
        (progn
          (logger (format nil "AI-FUNCTION: Move failed ~A~%" move-result))
          (setf (path-dst actor) nil)
          (setf (path actor) nil)
          (return-from ai-move-along-path nil)))
      
      )
    nil))
