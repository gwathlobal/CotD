(in-package :cotd)

;;---------------------------------
;; Sector Feat level modifiers
;;---------------------------------


(set-level-modifier :id +lm-feat-river+ :type :level-mod-sector-feat
                    :priority 10
                    :name "River"
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT RIVER~%")
                                                 
                                                 (let ((river-params (second (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))))
                                                   (when (find :n river-params)
                                                     (loop with max-y = (1- (truncate (array-dimension template-level 1) 2))
                                                           with min-y = 0
                                                           with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for y from min-y below max-y
                                                           for building-type-id = (if (and (zerop (mod (1+ y) 4))
                                                                                           (/= y (1- max-y)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           for building-at-point-1 = (aref template-level center-x y 2)
                                                           for building-at-point-2 = (aref template-level (1- center-x) y 2)
                                                           do
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id center-x y 2 template-level))
                                                              (when (or (eq building-at-point-2 nil)
                                                                        (eq building-at-point-2 t)
                                                                        (and (listp building-at-point-2)
                                                                             (/= (first building-at-point-2) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id (1- center-x) y 2 template-level))
                                                              ))

                                                   (when (find :s river-params)
                                                     (loop with max-y = (array-dimension template-level 1)
                                                           with min-y = (1- (truncate (array-dimension template-level 1) 2))
                                                           with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for y from (+ min-y 2) below max-y
                                                           for building-type-id = (if (and (zerop (mod (1+ (- y min-y)) 4))
                                                                                           (/= y (1- max-y)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           for building-at-point-1 = (aref template-level center-x y 2)
                                                           for building-at-point-2 = (aref template-level (1- center-x) y 2)
                                                           do
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id center-x y 2 template-level))
                                                              (when (or (eq building-at-point-2 nil)
                                                                        (eq building-at-point-2 t)
                                                                        (and (listp building-at-point-2)
                                                                             (/= (first building-at-point-2) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id (1- center-x) y 2 template-level))
                                                           ))

                                                   (when (find :e river-params)
                                                     (loop with max-x = (array-dimension template-level 0)
                                                           with min-x = (1- (truncate (array-dimension template-level 0) 2))
                                                           with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for x from (+ min-x 2) below max-x
                                                           for building-type-id = (if (and (zerop (mod (1+ (- x min-x)) 4))
                                                                                           (/= x (1- max-x)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           for building-at-point-1 = (aref template-level x (1- center-y) 2)
                                                           for building-at-point-2 = (aref template-level x center-y 2)
                                                           do
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id x (1- center-y) 2 template-level))
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id x center-y 2 template-level))
                                                           ))

                                                   (when (find :w river-params)
                                                     (loop with max-x = (1- (truncate (array-dimension template-level 0) 2))
                                                           with min-x = 0
                                                           with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for x from min-x below max-x
                                                           for building-type-id = (if (and (zerop (mod (1+ x) 4))
                                                                                           (/= x (1- max-x)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           for building-at-point-1 = (aref template-level x (1- center-y) 2)
                                                           for building-at-point-2 = (aref template-level x center-y 2)
                                                           do
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id x (1- center-y) 2 template-level))
                                                              (when (or (eq building-at-point-1 nil)
                                                                        (eq building-at-point-1 t)
                                                                        (and (listp building-at-point-1)
                                                                             (/= (first building-at-point-1) +building-city-central-lake+)))
                                                                (level-city-reserve-build-on-grid building-type-id x center-y 2 template-level))
                                                              
                                                           ))

                                                   (let ((x (1- (truncate (array-dimension template-level 0) 2)))
                                                         (y (1- (truncate (array-dimension template-level 1) 2))))

                                                     (loop for off-x from 0 to 1 do
                                                       (loop for off-y from 0 to 1
                                                             for building-at-point = (aref template-level (+ x off-x) (+ y off-y) 2)
                                                             do
                                                                (when (or (eq building-at-point nil)
                                                                          (eq building-at-point t)
                                                                          (and (listp building-at-point)
                                                                               (/= (first building-at-point) +building-city-central-lake+)))
                                                                  (level-city-reserve-build-on-grid +building-city-river+ (+ x off-x) (+ y off-y) 2 template-level))
                                                             ))
                                                     )
                                                   ))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  ;; is not available for islands
                                                  (if (or (eq world-sector-type-id :world-sector-normal-island)
                                                          (eq world-sector-type-id :world-sector-abandoned-island)
                                                          (eq world-sector-type-id :world-sector-corrupted-island)
                                                          (eq world-sector-type-id :world-sector-hell-jungle))
                                                    nil
                                                    t))
                    :scenario-disabled-func #'(lambda (world-map x y)
                                                ;; remove all surrounding rivers (if any)
                                                 (setf (feats (aref (cells world-map) x (1- y))) (remove +lm-feat-river+ (feats (aref (cells world-map) x (1- y))) :key #'(lambda (a) (first a))))
                                                 (setf (feats (aref (cells world-map) x (1+ y))) (remove +lm-feat-river+ (feats (aref (cells world-map) x (1+ y))) :key #'(lambda (a) (first a))))
                                                 (setf (feats (aref (cells world-map) (1- x) y)) (remove +lm-feat-river+ (feats (aref (cells world-map) (1- x) y)) :key #'(lambda (a) (first a))))
                                                 (setf (feats (aref (cells world-map) (1+ x) y)) (remove +lm-feat-river+ (feats (aref (cells world-map) (1+ x) y)) :key #'(lambda (a) (first a)))))
                    :scenario-enabled-func #'(lambda (world-map x y)
                                               (let ((river-list ()))
                                                 
                                                 ;; choose random sides where to add a river
                                                 (when (zerop (random 4))
                                                   (push :n river-list))
                                                 (when (zerop (random 4))
                                                   (push :s river-list))
                                                 (when (zerop (random 4))
                                                   (push :w river-list))
                                                 (when (zerop (random 4))
                                                   (push :e river-list))
                                                 (unless river-list
                                                   (push (nth (random 4) '(:n :s :e :w))
                                                         river-list))
                                                 ;; add rivers to the chosen sides
                                                 (loop for side in river-list 
                                                       when (eq side :n) do
                                                         (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) x (1- y))))
                                                       when (eq side :s) do
                                                         (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) x (1+ y))))
                                                       when (eq side :w) do
                                                         (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) (1- x) y)))
                                                       when (eq side :e) do
                                                         (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) (1+ x) y))))
                                                 )))

(set-level-modifier :id +lm-feat-sea+ :type :level-mod-sector-feat
                    :name "Pier"
                    :priority 0
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  ;; is not available for everybody other than seaports
                                                  (if (or (eq world-sector-type-id :world-sector-normal-port)
                                                          (eq world-sector-type-id :world-sector-abandoned-port)
                                                          (eq world-sector-type-id :world-sector-corrupted-port))
                                                    t
                                                    nil))
                    :always-present-func #'(lambda (world-sector mission world-time)
                                             (declare (ignore mission world-time))
                                             (if (or (eq (wtype world-sector) :world-sector-normal-port)
                                                     (eq (wtype world-sector) :world-sector-abandoned-port)
                                                     (eq (wtype world-sector) :world-sector-corrupted-port))
                                               t
                                               nil)))

(set-level-modifier :id +lm-feat-barricade+ :type :level-mod-sector-feat
                    :name "Barricade"
                    :priority 20
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT BARRICADE~%")
                                                 
                                                 (let ((x1 1)
                                                       (x2 (- (array-dimension template-level 0) 2))
                                                       (y1 1)
                                                       (y2 (- (array-dimension template-level 1) 2))
                                                       (barricade-params (second (find +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))))
                                                   (flet ((place-barricade (barricade-build-id x y)
                                                            (when (or (null (aref template-level x y 2))
                                                                      (/= (first (aref template-level x y 2)) +building-city-sea+))
                                                              (level-city-reserve-build-on-grid barricade-build-id x y 2 template-level))))
                                                     
                                                     ;; set up barricade lines & entrances
                                                     (when (find :n barricade-params)
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for x from x1 below (- center-x 2)
                                                             do
                                                                (place-barricade +building-city-barricade-we+ x y1))
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for x from (+ center-x 2) to x2
                                                             do
                                                                (place-barricade +building-city-barricade-we+ x y1))
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for off-x from -2 below 2
                                                             when (eq (aref template-level (+ center-x off-x) y1 2) nil)
                                                               do
                                                                  (setf (aref template-level (+ center-x off-x) y1 2) t)))

                                                     (when (find :s barricade-params)
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for x from x1 below (- center-x 2)
                                                             do
                                                                (place-barricade +building-city-barricade-we+ x y2))
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for x from (+ center-x 2) to x2
                                                             do
                                                                (place-barricade +building-city-barricade-we+ x y2))
                                                       (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                             for off-x from -2 below 2
                                                             when (eq (aref template-level (+ center-x off-x) y2 2) nil)
                                                               do
                                                                  (setf (aref template-level (+ center-x off-x) y2 2) t)))
                                                     
                                                     (when (find :w barricade-params)
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for y from y1 below (- center-y 2)
                                                             do
                                                                (place-barricade +building-city-barricade-ns+ x1 y))
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for y from (+ center-y 2) to y2
                                                             do
                                                                (place-barricade +building-city-barricade-ns+ x1 y))
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for off-y from -2 below 2
                                                             when (eq (aref template-level x1 (+ center-y off-y) 2) nil)
                                                               do
                                                                  (setf (aref template-level x1 (+ center-y off-y) 2) t)))
                                                     
                                                     (when (find :e barricade-params)
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for y from y1 below (- center-y 2)
                                                             do
                                                                (place-barricade +building-city-barricade-ns+ x2 y))
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for y from (+ center-y 2) to y2
                                                             do
                                                                (place-barricade +building-city-barricade-ns+ x2 y))
                                                       (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                             for off-y from -2 below 2
                                                             when (eq (aref template-level x2 (+ center-y off-y) 2) nil)
                                                               do
                                                                  (setf (aref template-level x2 (+ center-y off-y) 2) t)))

                                                     ;; set up barricade corners
                                                     (when (and (find :n barricade-params)
                                                                (find :w barricade-params))
                                                       (place-barricade +building-city-barricade-se+ x1 y1))

                                                     (when (and (find :n barricade-params)
                                                                (find :e barricade-params))
                                                       (place-barricade +building-city-barricade-sw+ x2 y1))
                                                     
                                                     (when (and (find :s barricade-params)
                                                                (find :w barricade-params))
                                                       (place-barricade +building-city-barricade-ne+ x1 y2))

                                                     (when (and (find :s barricade-params)
                                                                (find :e barricade-params))
                                                       (place-barricade +building-city-barricade-nw+ x2 y2))
                                                     
                                                     )))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  ;; is not available for islands & corrupted & abandoned districts
                                                  (if (or (eq world-sector-type-id :world-sector-normal-forest)
                                                          (eq world-sector-type-id :world-sector-normal-port)
                                                          (eq world-sector-type-id :world-sector-normal-residential)
                                                          (eq world-sector-type-id :world-sector-normal-lake))
                                                    t
                                                    nil))
                    :scenario-disabled-func #'(lambda (world-map x y)
                                                (when (= (controlled-by (aref (cells world-map) x (1- y))) +lm-controlled-by-demons+)
                                                  (setf (controlled-by (aref (cells world-map) x (1- y))) +lm-controlled-by-none+))
                                                (when (= (controlled-by (aref (cells world-map) x (1+ y))) +lm-controlled-by-demons+)
                                                  (setf (controlled-by (aref (cells world-map) x (1+ y))) +lm-controlled-by-none+))
                                                (when (= (controlled-by (aref (cells world-map) (1- x) y)) +lm-controlled-by-demons+)
                                                  (setf (controlled-by (aref (cells world-map) (1- x) y)) +lm-controlled-by-none+))
                                                (when (= (controlled-by (aref (cells world-map) (1+ x) y)) +lm-controlled-by-demons+)
                                                  (setf (controlled-by (aref (cells world-map) (1+ x) y)) +lm-controlled-by-none+)))
                    :scenario-enabled-func #'(lambda (world-map x y)
                                               (let ((demon-list ())
                                                     (side-list (list :n :s :w :e)))
                                                 ;; remove a side where the sea or island is
                                                 (loop for (side dx dy) in '((:n 0 -1) (:s 0 1) (:w -1 0) (:e 1 0)) do
                                                   (when (or (eq (wtype (aref (cells world-map) (+ x dx) (+ y dy))) :world-sector-normal-sea)
                                                             (eq (wtype (aref (cells world-map) (+ x dx) (+ y dy))) :world-sector-normal-island)
                                                             (eq (wtype (aref (cells world-map) (+ x dx) (+ y dy))) :world-sector-abandoned-island)
                                                             (eq (wtype (aref (cells world-map) (+ x dx) (+ y dy))) :world-sector-corrupted-island))
                                                     (setf side-list (remove side side-list))))
                                                 ;; choose random sides where to add a controlled by demons lvl-mod
                                                 (loop repeat 4
                                                       when (zerop (random 2))
                                                         do
                                                            (pushnew (nth (random (length side-list)) side-list) demon-list)
                                                       finally
                                                          (when (null demon-list)
                                                            (pushnew (nth (random (length side-list)) side-list) demon-list)))
                                                 ;; add controlled by demon lvl-mod to the chosen sides
                                                 (loop for side in demon-list 
                                                       when (eq side :n) do
                                                         (setf (controlled-by (aref (cells world-map) x (1- y))) +lm-controlled-by-demons+)
                                                       when (eq side :s) do
                                                         (setf (controlled-by (aref (cells world-map) x (1+ y))) +lm-controlled-by-demons+)
                                                       when (eq side :w) do
                                                         (setf (controlled-by (aref (cells world-map) (1- x) y)) +lm-controlled-by-demons+)
                                                       when (eq side :e) do
                                                         (setf (controlled-by (aref (cells world-map) (1+ x) y)) +lm-controlled-by-demons+))
                                                 )))

(set-level-modifier :id +lm-feat-library+ :type :level-mod-sector-feat
                    :name "Library"
                    :priority 30
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT LIBRARY~%")
                                                                                                  
                                                 (loop with library-types = (prepare-spec-build-id-list (cond
                                                                                                          ((or (eq (wtype world-sector) :world-sector-normal-residential)
                                                                                                               (eq (wtype world-sector) :world-sector-normal-island)
                                                                                                               (eq (wtype world-sector) :world-sector-normal-port)
                                                                                                               (eq (wtype world-sector) :world-sector-normal-lake)
                                                                                                               (eq (wtype world-sector) :world-sector-normal-forest))
                                                                                                           +building-type-library+)
                                                                                                          ((or (eq (wtype world-sector) :world-sector-abandoned-residential)
                                                                                                               (eq (wtype world-sector) :world-sector-abandoned-island)
                                                                                                               (eq (wtype world-sector) :world-sector-abandoned-port)
                                                                                                               (eq (wtype world-sector) :world-sector-abandoned-lake)
                                                                                                               (eq (wtype world-sector) :world-sector-abandoned-forest))
                                                                                                           +building-type-ruined-library+)
                                                                                                          ((or (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                                                                               (eq (wtype world-sector) :world-sector-corrupted-island)
                                                                                                               (eq (wtype world-sector) :world-sector-corrupted-port)
                                                                                                               (eq (wtype world-sector) :world-sector-corrupted-lake)
                                                                                                               (eq (wtype world-sector) :world-sector-corrupted-forest))
                                                                                                           +building-type-corrupted-library+)))
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-library-type = (nth (random (length library-types)) library-types)
                                                       until (level-city-can-place-build-on-grid selected-library-type x y 2 template-level)
                                                       finally
                                                          (level-city-reserve-build-on-grid selected-library-type x y 2 template-level))
                                                 )
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  ;; is not available for hell districts
                                                  (if (or (eq world-sector-type-id :world-sector-hell-jungle))
                                                    nil
                                                    t)))

(set-level-modifier :id +lm-feat-church+ :type :level-mod-sector-feat
                    :name "Church"
                    :priority 30
                    :faction-list-func #'(lambda (sector-type-id)
                                           (if (or (eq sector-type-id :world-sector-normal-residential)
                                                   (eq sector-type-id :world-sector-normal-sea)
                                                   (eq sector-type-id :world-sector-normal-island)
                                                   (eq sector-type-id :world-sector-normal-port)
                                                   (eq sector-type-id :world-sector-normal-lake)
                                                   (eq sector-type-id :world-sector-normal-forest))
                                             (list (list +faction-type-church+ :mission-faction-present))
                                             nil)
                                           )
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: Lvl Mod Church~%"))
                                                 
                                                 (loop with church-types = (prepare-spec-build-id-list +building-type-church+)
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-church-type = (nth (random (length church-types)) church-types)
                                                       until (level-city-can-place-build-on-grid selected-church-type x y 2 template-level)
                                                       finally
                                                          (level-city-reserve-build-on-grid selected-church-type x y 2 template-level))
                                                 )
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          ;; add priests if they are available
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector world))

                                                                    (format t "OVERALL-POST-PROCESS-FUNC: Add priests~%~%")
                                                                    
                                                                    (loop with church-present = nil
                                                                          for (faction-type faction-presence) in (faction-list mission)
                                                                          when (and (= faction-type +faction-type-church+)
                                                                                    (eq faction-presence :mission-faction-present))
                                                                            do
                                                                               (setf church-present t)
                                                                          finally
                                                                             (unless church-present (return))

                                                                             ;; find all church start points and place priests there
                                                                             (loop for feature-id in (feature-id-list level)
                                                                                   for lvl-feature = (get-feature-by-id feature-id)
                                                                                   for x = (x lvl-feature)
                                                                                   for y = (y lvl-feature)
                                                                                   for z = (z lvl-feature)
                                                                                   when (= (feature-type lvl-feature) +feature-start-place-church-priest+)
                                                                                     do
                                                                                        (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-priest+
                                                                                                                                         :x x :y y :z z)))
                                                                          )
                                                                    )
                                                                func-list)
                                                          
                                                          
                                                          func-list))
                     :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore world-time))
                                                  ;; is not available for celestial retrieval
                                                   (if (and (or (not (eq mission-type-id :mission-type-celestial-retrieval))
                                                                (and (eq mission-type-id :mission-type-celestial-retrieval)
                                                                     (or (eq world-sector-type-id :world-sector-abandoned-forest)
                                                                         (eq world-sector-type-id :world-sector-abandoned-port)
                                                                         (eq world-sector-type-id :world-sector-abandoned-residential)
                                                                         (eq world-sector-type-id :world-sector-abandoned-lake)
                                                                         (eq world-sector-type-id :world-sector-abandoned-island))))
                                                            (not (eq world-sector-type-id :world-sector-hell-jungle)))
                                                     t
                                                     nil))
                    )

(set-level-modifier :id +lm-feat-lair+ :type :level-mod-sector-feat
                    :name "Satanists' lair"
                    :priority 30
                    :faction-list-func #'(lambda (sector-type-id)
                                           (declare (ignore sector-type-id))
                                           (list (list +faction-type-satanists+ :mission-faction-present)))
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT SATANISTS LAIR~%")
                                                 
                                                 (loop with lair-types = (prepare-spec-build-id-list +building-type-satanists+)
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-lair-type = (nth (random (length lair-types)) lair-types)
                                                       until (level-city-can-place-build-on-grid selected-lair-type x y 2 template-level)
                                                       finally
                                                          (level-city-reserve-build-on-grid selected-lair-type x y 2 template-level))
                                                 )
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          ;; add demonic runes
                                                          (push #'place-demonic-runes-on-level
                                                                func-list)
                                                          func-list))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore mission-type-id world-time))
                                                  ;; is not available for hell districts
                                                  (if (or (eq world-sector-type-id :world-sector-hell-plain))
                                                    nil
                                                    t))
                    :always-present-func #'(lambda (world-sector mission world-time)
                                             (declare (ignore world-sector world-time))
                                             (if (eq (mission-type-id mission) :mission-type-eliminate-satanists)
                                               t
                                               nil))
                    )

(set-level-modifier :id +lm-feat-hell-engine+ :type :level-mod-sector-feat
                    :name "Dimensional engine"
                    :priority 30
                    :faction-list-func #'(lambda (sector-type-id)
                                           (declare (ignore sector-type-id))
                                           nil
                                           )
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: Lvl Mod Hell Engine~%"))
                                                 
                                                 (place-demonic-machines-on-template-level template-level)
                                                 )
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          
                                                          ;; add demonic machines
                                                          (push #'place-demonic-machines-on-level
                                                                func-list)
                                                          
                                                          ;; add demonic sigils
                                                          (push #'place-demonic-sigils-on-level
                                                                func-list)
                                                          
                                                          func-list))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore world-time))
                                                  ;; is not available for everybody other than hell jungle
                                                  (if (and (or (eq world-sector-type-id :world-sector-hell-jungle))
                                                           (eq mission-type-id :mission-type-celestial-sabotage))
                                                    t
                                                    nil))
                    :always-present-func #'(lambda (world-sector mission world-time)
                                             (declare (ignore world-sector world-time))
                                             (if (eq (mission-type-id mission) :mission-type-celestial-sabotage)
                                               t
                                               nil))
                    )

(set-level-modifier :id +lm-feat-hell-flesh-storage+ :type :level-mod-sector-feat
                    :name "Flesh storage"
                    :priority 30
                    :faction-list-func #'(lambda (sector-type-id)
                                           (declare (ignore sector-type-id))
                                           nil
                                           )
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: Lvl Mod Flesh Storage~%"))
                                                 
                                                 (place-flesh-storages-on-template-level template-level)
                                                 )
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          
                                                          ;; add flesh storages
                                                          (push #'place-flesh-storages-on-level
                                                                func-list)
                                                          
                                                          ;; add demonic sigils
                                                          (push #'place-demonic-sigils-on-level
                                                                func-list)
                                                          
                                                          func-list))
                    :is-available-for-mission #'(lambda (world-sector-type-id mission-type-id world-time)
                                                  (declare (ignore world-time))
                                                  ;; is not available for everybody other than hell jungle
                                                  (if (and (or (eq world-sector-type-id :world-sector-hell-jungle))
                                                           (eq mission-type-id :mission-type-military-sabotage))
                                                    t
                                                    nil))
                    :always-present-func #'(lambda (world-sector mission world-time)
                                             (declare (ignore world-sector world-time))
                                             (if (eq (mission-type-id mission) :mission-type-military-sabotage)
                                               t
                                               nil))
                    )
