(in-package :cotd)

(defclass mission ()
  ((mission-type-id :initarg :mission-type-id :accessor mission-type-id)
   (x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (world-sector :initarg :world-sector :accessor world-sector)
   (faction-list :initform () :initarg :faction-list :accessor faction-list) ;; list of faction-type-id
   (level-modifier-list :initform () :initarg :level-modifier-list :accessor level-modifier-list) ;; list of level-modifier-id
   (player-lvl-mod-placement-id :initarg :player-lvl-mod-placement-id :accessor player-lvl-mod-placement-id) ;; serves the id of the player specific faction placement function
   (player-specific-faction :initarg :player-specific-faction :accessor player-specific-faction)
   ))

(defmethod name ((mission mission))
  (name (get-mission-type-by-id (mission-type-id mission))))

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
                   (get-terrain-type-trait (get-terrain-* level x y nz) +terrain-trait-blocks-move-floor+)
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
                   (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
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
                   (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
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

(defun find-unoccupied-place-around (level mob sx sy sz &key (no-center nil))
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
                           (get-terrain-type-trait (get-terrain-* level x y sz) +terrain-trait-blocks-move-floor+)
                           (/= (get-level-connect-map-value level x y sz (if (riding-mob-id mob)
                                                                           (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                           (map-size mob))
                                                            (get-mob-move-mode mob))
                               +connect-room-none+)
                           (or (null no-center)
                               (and no-center
                                    (or (/= x sx) (/= y sy)))))
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

                   (get-terrain-type-trait (get-terrain-* level (1- x) (1- y) z) +terrain-trait-blocks-move-floor+)
                   (get-terrain-type-trait (get-terrain-* level (1+ x) (1- y) z) +terrain-trait-blocks-move-floor+)
                   (get-terrain-type-trait (get-terrain-* level x (1+ y) z) +terrain-trait-blocks-move-floor+)

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

(defun set-up-outdoor-light (level light-power)
  (setf (outdoor-light level) light-power)

  ;; propagate light from above to determine which parts of the map are outdoor and which are "inside"
  ;; also set up all stationary light sources
  (loop for x from 0 below (array-dimension (light-map level) 0) do
    (loop for y from 0 below (array-dimension (light-map level) 1)
          for light-pwr = 100
          do
             (loop for z from (1- (array-dimension (light-map level) 2)) downto 0
                   do
                      (setf (aref (light-map level) x y z) light-pwr)
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
                        (setf light-pwr 0))
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+)
                        (add-light-source level (make-light-source x y z (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+))))
                   )))

  )
