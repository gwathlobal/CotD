(in-package :cotd)

(defclass mission ()
  ((mission-type-id :initarg :mission-type-id :accessor mission-type-id)
   (x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (faction-list :initform () :initarg :faction-list :accessor faction-list) ;; list of faction-type-id
   (level-modifier-list :initform () :initarg :level-modifier-list :accessor level-modifier-list) ;; list of level-modifier-id
   (player-lvl-mod-placement-id :initarg :player-lvl-mod-placement-id :accessor player-lvl-mod-placement-id) ;; serves as a specific faction designation and the id of this faction placement function
   ))

(defmethod name ((mission mission))
  (name (get-mission-type-by-id (mission-type-id mission))))


;;=======================
;; Placement funcs
;;=======================

(defun place-demons-on-level (level world-sector mission world demon-list)
  (declare (ignore world world-sector))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place demons function~%"))
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (= (second a) +mission-faction-present+))
                       t
                       nil))
                 (faction-list mission))
    
    (logger (format nil "   PLACE-DEMONS-ON-LEVEL: Place at the borders~%"))
    (loop for (demon-type demon-number is-player) in demon-list do
      (loop repeat demon-number do
        (loop with arrival-point-list = (remove-if-not #'(lambda (a)
                                                           (= (feature-type a) +feature-demons-arrival-point+))
                                                       (feature-id-list level)
                                                       :key #'(lambda (b)
                                                                (get-feature-by-id b)))
              while (> (length arrival-point-list) 0) 
              for random-arrival-point-id = (nth (random (length arrival-point-list)) arrival-point-list)
              for lvl-feature = (get-feature-by-id random-arrival-point-id)
              for x = (x lvl-feature)
              for y = (y lvl-feature)
              for z = (z lvl-feature)
              do
                 (setf arrival-point-list (remove random-arrival-point-id arrival-point-list))
                 (if is-player
                   (progn
                     (setf *player* (make-instance 'player :mob-type demon-type))
                     (find-unoccupied-place-around level *player* x y z))
                   (find-unoccupied-place-around level (make-instance 'mob :mob-type demon-type) x y z))
                 
                 (loop-finish)))))
  )

(defun place-angels-on-level (level world-sector mission world angel-list)
  (declare (ignore world-sector world))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place angels function~%"))
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-present+))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place present angels~%"))
    
    (loop for (angel-type angel-number is-player) in angel-list do
      (loop repeat angel-number do
        (if (or (= angel-type +mob-type-star-singer+)
                (= angel-type +mob-type-star-gazer+)
                (= angel-type +mob-type-star-mender+))
          (progn
            (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place trinity mimics~%"))
            (loop with is-free = t
                  with mob1 = (if is-player (make-instance 'player :mob-type +mob-type-star-singer+) (make-instance 'mob :mob-type +mob-type-star-singer+))
                  with mob2 = (if is-player (make-instance 'player :mob-type +mob-type-star-gazer+) (make-instance 'mob :mob-type +mob-type-star-gazer+))
                  with mob3 = (if is-player (make-instance 'player :mob-type +mob-type-star-mender+) (make-instance 'mob :mob-type +mob-type-star-mender+))
                  with arrival-point-list = (remove-if-not #'(lambda (a)
                                                                      (= (feature-type a) +feature-start-place-angels+))
                                                                  (feature-id-list level)
                                                                  :key #'(lambda (b)
                                                                           (get-feature-by-id b)))
                         while (> (length arrival-point-list) 0) 
                         for random-arrival-point-id = (nth (random (length arrival-point-list)) arrival-point-list)
                         for lvl-feature = (get-feature-by-id random-arrival-point-id)
                         for x = (x lvl-feature)
                         for y = (y lvl-feature)
                         for z = (z lvl-feature)
                         do
                            (setf arrival-point-list (remove random-arrival-point-id arrival-point-list))
                            (setf is-free t)
                            (check-surroundings x y t #'(lambda (dx dy)
                                                          (when (or (not (eq (check-move-on-level mob1 dx dy z) t))
                                                                    (not (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-opaque-floor+)))
                                                            (setf is-free nil))))
                            (when is-free
                              
                              (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                              (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                              (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                              (setf (name mob2) (name mob1) (name mob3) (name mob1))
                              
                              (setf (x mob1) (1- x) (y mob1) (1- y) (z mob1) z)
                              (add-mob-to-level-list level mob1)
                              (setf (x mob2) (1+ x) (y mob2) (1- y) (z mob2) z)
                              (add-mob-to-level-list level mob2)
                              (setf (x mob3) x (y mob3) (1+ y) (z mob3) z)
                              (add-mob-to-level-list level mob3)
                              
                              (when is-player
                                (setf *player* mob1))
                              
                              (loop-finish))))
                 (progn
                   (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place chrome angels~%"))
                   
                   (loop with arrival-point-list = (remove-if-not #'(lambda (a)
                                                                      (= (feature-type a) +feature-start-place-angels+))
                                                                  (feature-id-list level)
                                                                  :key #'(lambda (b)
                                                                           (get-feature-by-id b)))
                         while (> (length arrival-point-list) 0) 
                         for random-arrival-point-id = (nth (random (length arrival-point-list)) arrival-point-list)
                         for lvl-feature = (get-feature-by-id random-arrival-point-id)
                         for x = (x lvl-feature)
                         for y = (y lvl-feature)
                         for z = (z lvl-feature)
                         do
                            (setf arrival-point-list (remove random-arrival-point-id arrival-point-list))
                            
                            (if is-player
                              (progn
                                (setf *player* (make-instance 'player :mob-type angel-type))
                                (find-unoccupied-place-around level *player* x y z))
                              (find-unoccupied-place-around level (make-instance 'mob :mob-type angel-type) x y z))
                            
                            (loop-finish))))
                   )))

    (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 (faction-list mission))
      (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Add game event for delayed angels~%"))
      
      (pushnew +game-event-delayed-arrival-angels+ (game-events level))
      
      ;; add a player to game but do not add him to the level
      (when (or (= (player-lvl-mod-placement-id mission) +lm-placement-angel-trinity+)
                (= (player-lvl-mod-placement-id mission) +lm-placement-angel-chrome+))
        (loop for (mob-type-id mob-num is-player) in angel-list do
          (when is-player
            (if (or (= mob-type-id +mob-type-star-singer+)
                    (= mob-type-id +mob-type-star-gazer+)
                    (= mob-type-id +mob-type-star-mender+))
              (progn
                (let ((mob1 (make-instance 'player :mob-type +mob-type-star-singer+))
                      (mob2 (make-instance 'player :mob-type +mob-type-star-gazer+))
                      (mob3 (make-instance 'player :mob-type +mob-type-star-mender+)))
                  (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                  (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                  (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                  (setf (name mob2) (name mob1) (name mob3) (name mob1))
                  (setf *player* mob1)))
              (progn
                (setf *player* (make-instance 'player :mob-type mob-type-id))))
            (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Add delayed player to the game~%"))
            (setf (player-outside-level *player*) t))))
      )
  )
  

(defun place-military-on-level (level world-sector mission world military-list remove-arrival-points)
  (declare (ignore world-sector world))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place military function~%"))

  ;; if the player is present as a chaplain then we need only three squads
  (when (and (= (player-lvl-mod-placement-id mission) +lm-placement-military-chaplain+)
             (> (length military-list) 1))
    (setf military-list (remove (first military-list) military-list)))
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-present+))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Place present military~%"))
    
    (loop for squad-list in military-list do
      (destructuring-bind (mob-type-id mob-num is-player) (first squad-list)
        (declare (ignore mob-num))
        (let ((leader (if is-player (make-instance 'player :mob-type mob-type-id) (make-instance 'mob :mob-type mob-type-id))))
          (loop with arrival-point-list = (remove-if-not #'(lambda (a)
                                                             (= (feature-type a) +feature-start-military-point+))
                                                         (feature-id-list level)
                                                         :key #'(lambda (b)
                                                                  (get-feature-by-id b)))
                while (> (length arrival-point-list) 0) 
                for random-arrival-point-id = (nth (random (length arrival-point-list)) arrival-point-list)
                for lvl-feature = (get-feature-by-id random-arrival-point-id)
                for x = (x lvl-feature)
                for y = (y lvl-feature)
                for z = (z lvl-feature)
                do
                   (setf arrival-point-list (remove random-arrival-point-id arrival-point-list))
                   
                   (find-unoccupied-place-around level leader x y z)
                   
                   (when is-player
                     (setf *player* leader))
                   (when remove-arrival-points
                     (remove-feature-from-level-list level lvl-feature)
                     (remove-feature-from-world lvl-feature))
                   
                   (loop-finish))
          
          (setf squad-list (remove (first squad-list) squad-list))
          
          (when squad-list
            (populate-level-with-mobs level squad-list
                                      #'(lambda (level mob)
                                          (find-unoccupied-place-around level mob (x leader) (y leader) (z leader)))))))
          )
    )
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Add game event for delayed military~%"))
    
    (pushnew +game-event-delayed-arrival-military+ (game-events level))
    
    ;; add a player to game but do not add him to the level
    (when (or (= (player-lvl-mod-placement-id mission) +lm-placement-military-chaplain+)
              (= (player-lvl-mod-placement-id mission) +lm-placement-military-scout+))
      (loop for squad-list in military-list do
        (destructuring-bind (mob-type-id mob-num is-player) (first squad-list)
          (declare (ignore mob-num))
          (when is-player
            (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Add delayed player to the game~%"))
            (setf *player* (make-instance 'player :mob-type mob-type-id))
            (setf (player-outside-level *player*) t)))))
    )
  )
  

(defun place-demonic-runes-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place demonic runes~%"))
  (let ((demonic-runes ())
        (rune-list (list +feature-demonic-rune-flesh+ +feature-demonic-rune-flesh+
                         +feature-demonic-rune-invite+ +feature-demonic-rune-invite+
                         +feature-demonic-rune-away+ +feature-demonic-rune-away+
                         +feature-demonic-rune-transform+ +feature-demonic-rune-transform+
                         +feature-demonic-rune-barrier+ +feature-demonic-rune-barrier+
                         +feature-demonic-rune-all+ +feature-demonic-rune-all+
                         +feature-demonic-rune-decay+ +feature-demonic-rune-decay+)))
    (loop with max-x = (array-dimension (terrain level) 0)
          with max-y = (array-dimension (terrain level) 1)
          with max-z = (array-dimension (terrain level) 2)
          with cur-rune = 0
          for x = (random max-x)
          for y = (random max-y)
          for z = (random max-z)
          while (< (length demonic-runes) (length rune-list)) do
            (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-can-have-rune+)
                       (null (find (list x y z) demonic-runes :test #'(lambda (a b)
                                                                        (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 6)
                                                                          t
                                                                          nil)
                                                                        ))))
              (push (list x y z (nth cur-rune rune-list)) demonic-runes)
              (incf cur-rune)))
    (loop for (x y z feature-type-id) in demonic-runes do
      ;;(format t "PLACE RUNE ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id feature-type-id)) x y z)
      (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z)))))

;;=======================
;; Auxiliary funcs
;;=======================

(defun populate-level-with-mobs (level mob-template-list placement-func)
  (loop for (mob-template-id num is-player) in mob-template-list do
    (loop repeat num do
      (if is-player
        (progn
          (setf *player* (make-instance 'player :mob-type mob-template-id))
          (funcall placement-func level *player*))
        (funcall placement-func level (make-instance 'mob :mob-type mob-template-id))))))

(defun find-unoccupied-place-on-top (level mob)
  (loop with max-x = (array-dimension (terrain level) 0)
        with max-y = (array-dimension (terrain level) 1)
        with nz = nil
        for x = (random max-x)
        for y = (random max-y)
        for z = (1- (array-dimension (terrain level) 2))
        do
           (setf (x mob) x (y mob) y (z mob) z)
           (setf nz (apply-gravity mob)) 
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (get-terrain-type-trait (get-terrain-* level x y nz) +terrain-trait-opaque-floor+)
                   nz
                   (> nz 2)
                   (not (get-mob-* level x y nz))
                   (eq (check-move-on-level mob x y nz) t)
                   (/= (get-level-connect-map-value level x y nz (if (riding-mob-id mob)
                                                                   (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                   (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (not (mob-ability-p mob +mob-abil-demon+))
                       (and (mob-ability-p mob +mob-abil-demon+)
                            (loop for feature-id in (feature-id-list level)
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) 15))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) nz)
                (add-mob-to-level-list level mob)))

(defun find-unoccupied-place-water (level mob)
  (let ((water-cells nil)
        (r-cell))
    (loop for x from 0 below (array-dimension (terrain level) 0) do
      (loop for y from 0 below (array-dimension (terrain level) 1) do
        (loop for z from 0 below (array-dimension (terrain level) 2)
              when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-water+)
                        (eq (check-move-on-level mob x y z) t))
                do
                   (push (list x y z) water-cells))))
    (if water-cells
      (progn
        (setf r-cell (nth (random (length water-cells)) water-cells))
        (setf (x mob) (first r-cell) (y mob) (second r-cell) (z mob) (third r-cell))
        (add-mob-to-level-list level mob))
      (progn
        (find-unoccupied-place-outside level mob)))
    )
  )

(defun find-unoccupied-place-outside (level mob)
  (loop with max-x = (array-dimension (terrain level) 0)
        with max-y = (array-dimension (terrain level) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (not (and (> x 7) (< x (- max-x 7)) (> y 7) (< y (- max-y 7))))
                   (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* level x y z))
                   (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value level x y z (if (riding-mob-id mob)
                                                                  (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                  (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (not (mob-ability-p mob +mob-abil-demon+))
                       (and (mob-ability-p mob +mob-abil-demon+)
                            (loop for feature-id in (feature-id-list level)
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list level mob)))

(defun find-unoccupied-place-inside (level mob)
  (loop with max-x = (array-dimension (terrain level) 0)
        with max-y = (array-dimension (terrain level) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* level x y z))
                   (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value level x y z (if (riding-mob-id mob)
                                                                  (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                  (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (and (not (mob-ability-p mob +mob-abil-demon+))
                            (not (mob-ability-p mob +mob-abil-angel+)))
                       (and (or (mob-ability-p mob +mob-abil-demon+)
                                (mob-ability-p mob +mob-abil-angel+))
                            (loop for feature-id in (feature-id-list level)
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                    do
                                       
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (get-feature-type-trait feature +feature-trait-remove-on-dungeon-generation+)
                                            (< (get-distance x y (x feature) (y feature)) 2))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list level mob)))

(defun find-unoccupied-place-around (level mob sx sy sz)
  (loop with min-x = sx
        with max-x = sx
        with min-y = sy
        with max-y = sy
        with max-x-level = (array-dimension (terrain level) 0)
        with max-y-level = (array-dimension (terrain level) 1)
        for cell-list = nil
        do
           ;; prepare the list of cells
           ;; north 
           (setf cell-list (append cell-list (loop with y = min-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; east
           (setf cell-list (append cell-list (loop with x = max-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))
           ;; south
           (setf cell-list (append cell-list (loop with y = max-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; west
           (setf cell-list (append cell-list (loop with x = min-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))

           ;; iterate through the list of cells
           (loop for (x . y) in cell-list
                 when (and (>= x 0) (< x max-x-level) (>= y 0) (< y max-y-level)
                           (eq (check-move-on-level mob x y sz) t)
                           (get-terrain-type-trait (get-terrain-* level x y sz) +terrain-trait-opaque-floor+)
                           (/= (get-level-connect-map-value level x y sz (if (riding-mob-id mob)
                                                                           (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                           (map-size mob))
                                                            (get-mob-move-mode mob))
                               +connect-room-none+))
                   do
                      (setf (x mob) x (y mob) y (z mob) sz)
                      (add-mob-to-level-list level mob)
                      (return-from find-unoccupied-place-around mob))

           ;; if the loop is not over - increase the boundaries
           (decf min-x)
           (decf min-y)
           (incf max-x)
           (incf max-y)
           ))

(defun find-unoccupied-place-mimic (level mob1 mob2 mob3 &key (inside nil))
  ;; function specifically for mimics
  (loop with max-x = (array-dimension (terrain level) 0)
        with max-y = (array-dimension (terrain level) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (if inside
                     (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                     (not (and (> x 7) (< x (- max-x 7)) (> y 7) (< y (- max-y 7)))))
                     
                   (eq (check-move-on-level mob1 (1- x) (1- y) z) t)
                   (eq (check-move-on-level mob2 (1+ x) (1- y) z) t)
                   (eq (check-move-on-level mob3 x (1+ y) z) t)

                   (not (get-mob-* level (1- x) (1- y) z))
                   (not (get-mob-* level (1+ x) (1- y) z))
                   (not (get-mob-* level x (1+ y) z))

                   (get-terrain-type-trait (get-terrain-* level (1- x) (1- y) z) +terrain-trait-opaque-floor+)
                   (get-terrain-type-trait (get-terrain-* level (1+ x) (1- y) z) +terrain-trait-opaque-floor+)
                   (get-terrain-type-trait (get-terrain-* level x (1+ y) z) +terrain-trait-opaque-floor+)

                   (/= (get-level-connect-map-value level (1- x) (1- y) z (if (riding-mob-id mob1)
                                                                            (map-size (get-mob-by-id (riding-mob-id mob1)))
                                                                            (map-size mob1))
                                                    (get-mob-move-mode mob1))
                       +connect-room-none+)
                   (/= (get-level-connect-map-value level (1+ x) (1- y) z (if (riding-mob-id mob2)
                                                                            (map-size (get-mob-by-id (riding-mob-id mob2)))
                                                                            (map-size mob2))
                                                    (get-mob-move-mode mob2))
                       +connect-room-none+)
                   (/= (get-level-connect-map-value level x (1+ y) z (if (riding-mob-id mob3)
                                                                       (map-size (get-mob-by-id (riding-mob-id mob3)))
                                                                       (map-size mob3))
                                                    (get-mob-move-mode mob3))
                       +connect-room-none+)
                   )
        finally (setf (x mob1) (1- x) (y mob1) (1- y) (z mob1) z)
                (add-mob-to-level-list level mob1)
                (setf (x mob2) (1+ x) (y mob2) (1- y) (z mob2) z)
                (add-mob-to-level-list level mob2)
                (setf (x mob3) x (y mob3) (1+ y) (z mob3) z)
                (add-mob-to-level-list level mob3)
        ))

(defun find-player-start-position (level mob feature-type-id)
  (loop for feature-id in (feature-id-list level)
        for feature = (get-feature-by-id feature-id)
        when (= (feature-type feature) feature-type-id)
          do
             (setf (x mob) (x feature) (y mob) (y feature) (z mob) (z feature))
             (add-mob-to-level-list level mob)
             (loop-finish)))
