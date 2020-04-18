(in-package :cotd)

;;---------------------------------
;; Sector Feat level modifiers
;;---------------------------------


(set-level-modifier :id +lm-feat-river+ :type +level-mod-sector-feat+
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

(set-level-modifier :id +lm-feat-sea+ :type +level-mod-sector-feat+
                    :name "Sea"
                    :priority 0)

(set-level-modifier :id +lm-feat-barricade+ :type +level-mod-sector-feat+
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

                                                   ;; set up barricade lines & entrances
                                                   (when (find :n barricade-params)
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for x from x1 below (- center-x 2)
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-we+ x y1 2 template-level))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for x from (+ center-x 2) to x2
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-we+ x y1 2 template-level))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for off-x from -2 below 2
                                                           when (eq (aref template-level (+ center-x off-x) y1 2) nil)
                                                             do
                                                                (setf (aref template-level (+ center-x off-x) y1 2) t)))

                                                   (when (find :s barricade-params)
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for x from x1 below (- center-x 2)
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-we+ x y2 2 template-level))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for x from (+ center-x 2) to x2
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-we+ x y2 2 template-level))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for off-x from -2 below 2
                                                           when (eq (aref template-level (+ center-x off-x) y2 2) nil)
                                                             do
                                                                (setf (aref template-level (+ center-x off-x) y2 2) t)))

                                                   (when (find :w barricade-params)
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for y from y1 below (- center-y 2)
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-ns+ x1 y 2 template-level))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for y from (+ center-y 2) to y2
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-ns+ x1 y 2 template-level))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for off-y from -2 below 2
                                                           when (eq (aref template-level x1 (+ center-y off-y) 2) nil)
                                                             do
                                                                (setf (aref template-level x1 (+ center-y off-y) 2) t)))

                                                   (when (find :e barricade-params)
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for y from y1 below (- center-y 2)
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-ns+ x2 y 2 template-level))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                            for y from (+ center-y 2) to y2
                                                           do
                                                              (level-city-reserve-build-on-grid +building-city-barricade-ns+ x2 y 2 template-level))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for off-y from -2 below 2
                                                           when (eq (aref template-level x2 (+ center-y off-y) 2) nil)
                                                             do
                                                                (setf (aref template-level x2 (+ center-y off-y) 2) t)))

                                                   ;; set up barricade corners
                                                   (when (and (find :n barricade-params)
                                                              (find :w barricade-params))
                                                     (level-city-reserve-build-on-grid +building-city-barricade-se+ x1 y1 2 template-level))

                                                   (when (and (find :n barricade-params)
                                                              (find :e barricade-params))
                                                     (level-city-reserve-build-on-grid +building-city-barricade-sw+ x2 y1 2 template-level))

                                                   (when (and (find :s barricade-params)
                                                              (find :w barricade-params))
                                                     (level-city-reserve-build-on-grid +building-city-barricade-ne+ x1 y2 2 template-level))

                                                   (when (and (find :s barricade-params)
                                                              (find :e barricade-params))
                                                     (level-city-reserve-build-on-grid +building-city-barricade-nw+ x2 y2 2 template-level))
                                                   
                                                   ))
                    :scenario-enabled-func #'(lambda (world-map x y)
                                               (let ((demon-list ()))
                                                 ;; choose random sides where to add a controlled by demons lvl-mod
                                                 (when (zerop (random 4))
                                                   (push :n demon-list))
                                                 (when (zerop (random 4))
                                                   (push :s demon-list))
                                                 (when (zerop (random 4))
                                                   (push :w demon-list))
                                                 (when (zerop (random 4))
                                                   (push :e demon-list))
                                                 (unless demon-list
                                                   (push (nth (random 4) '(:n :s :e :w))
                                                         demon-list))
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

(set-level-modifier :id +lm-feat-library+ :type +level-mod-sector-feat+
                    :name "Library"
                    :priority 30
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT LIBRARY~%")
                                                                                                  
                                                 (loop with library-types = (prepare-spec-build-id-list (cond
                                                                                                          ((or (= (wtype world-sector) +world-sector-normal-residential+)
                                                                                                               (= (wtype world-sector) +world-sector-normal-island+)
                                                                                                               (= (wtype world-sector) +world-sector-normal-port+)
                                                                                                               (= (wtype world-sector) +world-sector-normal-lake+)
                                                                                                               (= (wtype world-sector) +world-sector-normal-forest+))
                                                                                                           +building-type-library+)
                                                                                                          ((or (= (wtype world-sector) +world-sector-abandoned-residential+)
                                                                                                               (= (wtype world-sector) +world-sector-abandoned-island+)
                                                                                                               (= (wtype world-sector) +world-sector-abandoned-port+)
                                                                                                               (= (wtype world-sector) +world-sector-abandoned-lake+)
                                                                                                               (= (wtype world-sector) +world-sector-abandoned-forest+))
                                                                                                           +building-type-ruined-library+)
                                                                                                          ((or (= (wtype world-sector) +world-sector-corrupted-residential+)
                                                                                                               (= (wtype world-sector) +world-sector-corrupted-island+)
                                                                                                               (= (wtype world-sector) +world-sector-corrupted-port+)
                                                                                                               (= (wtype world-sector) +world-sector-corrupted-lake+)
                                                                                                               (= (wtype world-sector) +world-sector-corrupted-forest+))
                                                                                                           +building-type-corrupted-library+)))
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-library-type = (nth (random (length library-types)) library-types)
                                                       until (level-city-can-place-build-on-grid selected-library-type x y 2 template-level)
                                                       finally
                                                          (level-city-reserve-build-on-grid selected-library-type x y 2 template-level))
                                                 ))

(set-level-modifier :id +lm-feat-church+ :type +level-mod-sector-feat+
                    :name "Church"
                    :priority 30
                    :faction-list-func #'(lambda (world-sector)
                                           (if (or (= (wtype world-sector) +world-sector-normal-residential+)
                                                   (= (wtype world-sector) +world-sector-normal-sea+)
                                                   (= (wtype world-sector) +world-sector-normal-island+)
                                                   (= (wtype world-sector) +world-sector-normal-port+)
                                                   (= (wtype world-sector) +world-sector-normal-lake+)
                                                   (= (wtype world-sector) +world-sector-normal-forest+))
                                             (list (list +faction-type-church+ +mission-faction-present+))
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
                                                                                    (= faction-presence +mission-faction-present+))
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
                    )

(set-level-modifier :id +lm-feat-lair+ :type +level-mod-sector-feat+
                    :name "Satanists' lair"
                    :priority 30
                    :faction-list-func #'(lambda (world-sector)
                                           (declare (ignore world-sector))
                                           (list (list +faction-type-satanists+ +mission-faction-present+)))
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
                    )
