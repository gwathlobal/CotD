(in-package :cotd)

;;===========================
;; WIN EVENTS
;;===========================

(set-game-event (make-instance 'game-event :id +game-event-campaign-satanists-move+
                                           :descr-func #'(lambda ()
                                                           (format nil "Each day, move satanists to a location nearby."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (declare (ignore world))
                                                         t)
                                           :on-trigger #'(lambda (world)
                                                           (let ((world-sector)
                                                                 (cur-lair)
                                                                 (lair-list-init ())
                                                                 (lair-list-final ()))
                                                             (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                               (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                                 (setf world-sector (aref (cells (world-map world)) x y))
                                                                 (setf cur-lair (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
                                                                 (when cur-lair
                                                                   (push (list cur-lair x y) lair-list-init))))

                                                             (loop with select-sector = nil
                                                                   for (lair x y) in lair-list-init
                                                                   for avail-sectors = ()
                                                                   do
                                                                      (check-surroundings x y nil #'(lambda (dx dy)
                                                                                                      (when (and (>= dx 0) (>= dy 0) (< dx (array-dimension (cells (world-map world)) 0)) (< dy (array-dimension (cells (world-map world)) 1))
                                                                                                                 (setf world-sector (aref (cells (world-map world)) dx dy))
                                                                                                                 (not (eq (wtype world-sector) :world-sector-normal-sea))
                                                                                                                 (not (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
                                                                                                                 (not (find-if #'(lambda (a)
                                                                                                                                   (if (and (= (second a) dx)
                                                                                                                                            (= (third a) dx))
                                                                                                                                     t
                                                                                                                                     nil))
                                                                                                                               lair-list-final)))
                                                                                                        (push (list dx dy) avail-sectors))))
                                                                      (when avail-sectors
                                                                        (setf select-sector (nth (random (length avail-sectors)) avail-sectors))
                                                                        (push (list lair (first select-sector) (second select-sector)) lair-list-final)))

                                                             (loop for (lair x y) in lair-list-init do
                                                               (setf world-sector (aref (cells (world-map world)) x y))
                                                               (setf (feats world-sector) (remove +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a)))))

                                                             (loop for (lair x y) in lair-list-final do
                                                               (setf world-sector (aref (cells (world-map world)) x y))
                                                               (push lair (feats world-sector))))
                                                           )))

(set-game-event (make-instance 'game-event :id +game-event-campaign-flesh-gathered+
                                           :descr-func #'(lambda ()
                                                           (format nil "Each day, gather the flesh from missions."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (and (getf (world/post-mission-results world) :flesh-points)
                                                                  (> (getf (world/post-mission-results world) :flesh-points) 0))
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (let ((flesh-points (getf (world/post-mission-results world) :flesh-points)))
                                                             (add-message (format nil "Demons managed to gather ") sdl:*white* `(,(world/sitrep-message-box world)))
                                                             (add-message (format nil "~A flesh ~A" flesh-points (if (= flesh-points 1) "point" "points")) sdl:*yellow* `(,(world/sitrep-message-box *world*)))
                                                             (add-message (format nil " recently.~%") sdl:*white* `(,(world/sitrep-message-box *world*)))
                                                             
                                                             (incf (world/flesh-points *world*) flesh-points)
                                                           
                                                             ))))

(set-game-event (make-instance 'game-event :id +game-event-campaign-move-military+
                                           :descr-func #'(lambda ()
                                                           (format nil "Each day, move military towards enemy."))
                                           :disabled nil
                                           :on-check #'(lambda (world)
                                                         (if (> (calc-all-military-on-world-map (world-map world)) 0)
                                                           t
                                                           nil))
                                           :on-trigger #'(lambda (world)
                                                           (multiple-value-bind (military-num military-sectors) (calc-all-military-on-world-map (world-map world))
                                                             (declare (ignore military-num))
                                                             (loop for military-sector in military-sectors do
                                                               (let ((world-sector nil)
                                                                     (nearest-sector nil)
                                                                     (message-box-list `(,(world/sitrep-message-box *world*))))
                                                                 ;; find nearest corrupted or abandoned sector
                                                                 (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                                   (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                                     (setf world-sector (aref (cells (world-map world)) x y))
                                                                     (when (or (eq (wtype world-sector) :world-sector-abandoned-forest)
                                                                               (eq (wtype world-sector) :world-sector-abandoned-lake)
                                                                               (eq (wtype world-sector) :world-sector-abandoned-residential)
                                                                               (eq (wtype world-sector) :world-sector-abandoned-island)
                                                                               (eq (wtype world-sector) :world-sector-abandoned-port)
                                                                               (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                                               (eq (wtype world-sector) :world-sector-corrupted-lake)
                                                                               (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                                               (eq (wtype world-sector) :world-sector-corrupted-island)
                                                                               (eq (wtype world-sector) :world-sector-corrupted-port))
                                                                       (unless nearest-sector
                                                                         (setf nearest-sector world-sector))
                                                                       (when (< (get-distance (x military-sector) (y military-sector) (x world-sector) (y world-sector))
                                                                                (get-distance (x military-sector) (y military-sector) (x nearest-sector) (y nearest-sector)))
                                                                         (setf nearest-sector world-sector)))))
                                                                 ;; move the military towards that sector
                                                                 (when nearest-sector
                                                                   (loop with correct-dirs = ()
                                                                         with x = (x military-sector)
                                                                         with y = (y military-sector)
                                                                         for dir from 1 to 9
                                                                         for (dx dy) = (multiple-value-list (x-y-dir dir))
                                                                         when (and (>= (+ dx x) 0) (>= (+ dy y) 0) (< (+ dx x) (array-dimension (cells (world-map world)) 0)) (< (+ dy y) (array-dimension (cells (world-map world)) 1))
                                                                                   (< (get-distance (+ dx x) (+ dy y) (x nearest-sector) (y nearest-sector))
                                                                                      (get-distance x y (x nearest-sector) (y nearest-sector)))
                                                                                   (or (eq (wtype (aref (cells (world-map world)) (+ dx x) (+ dy y))) :world-sector-normal-forest)
                                                                                       (eq (wtype (aref (cells (world-map world)) (+ dx x) (+ dy y))) :world-sector-normal-lake)
                                                                                       (eq (wtype (aref (cells (world-map world)) (+ dx x) (+ dy y))) :world-sector-normal-residential)
                                                                                       (eq (wtype (aref (cells (world-map world)) (+ dx x) (+ dy y))) :world-sector-normal-island)
                                                                                       (eq (wtype (aref (cells (world-map world)) (+ dx x) (+ dy y))) :world-sector-normal-port))
                                                                                   (eq (controlled-by (aref (cells (world-map world)) (+ dx x) (+ dy y))) +lm-controlled-by-none+))
                                                                           do
                                                                              (push dir correct-dirs)
                                                                         finally (when correct-dirs
                                                                                   (multiple-value-bind (dx dy) (x-y-dir (nth (random (length correct-dirs)) correct-dirs))
                                                                                     (setf (controlled-by military-sector) +lm-controlled-by-none+)
                                                                                     (setf (controlled-by (aref (cells (world-map world)) (+ dx x) (+ dy y))) +lm-controlled-by-military+)
                                                                                     
                                                                                     (add-message (format nil "The ") sdl:*white* message-box-list)
                                                                                     (add-message (format nil "military") sdl:*yellow* message-box-list)
                                                                                     (add-message (format nil " moved from ") sdl:*white* message-box-list)
                                                                                     (add-message (format nil "~(~A~)" (name military-sector)) sdl:*yellow* message-box-list)
                                                                                     (add-message (format nil " to ") sdl:*white* message-box-list)
                                                                                     (add-message (format nil "~(~A~)" (name (aref (cells (world-map world)) (+ dx x) (+ dy y)))) sdl:*yellow* message-box-list)
                                                                                     (add-message (format nil ".~%") sdl:*white* message-box-list))))))
                                                                   )))
                                                           ))








