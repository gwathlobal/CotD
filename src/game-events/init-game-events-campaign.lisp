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








