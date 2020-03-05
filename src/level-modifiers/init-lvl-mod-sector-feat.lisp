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
                                                 
                                                 (let ((build-list)
                                                       (river-params (second (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))))
                                                   (when (find :n river-params)
                                                     (loop with max-y = (1- (truncate (array-dimension template-level 1) 2))
                                                           with min-y = 0
                                                           with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for y from min-y below max-y
                                                           for building-type-id = (if (and (zerop (mod (1+ y) 4))
                                                                                           (/= y (1- max-y)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           do
                                                              (setf (aref template-level center-x y 2) building-type-id)
                                                              (setf (aref template-level (1- center-x) y 2) building-type-id)))
                                                   
                                                   (when (find :s river-params)
                                                     (loop with max-y = (array-dimension template-level 1)
                                                           with min-y = (1- (truncate (array-dimension template-level 1) 2))
                                                           with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for y from (+ min-y 2) below max-y
                                                           for building-type-id = (if (and (zerop (mod (1+ (- y min-y)) 4))
                                                                                           (/= y (1- max-y)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           do
                                                              (setf (aref template-level center-x y 2) building-type-id)
                                                              (setf (aref template-level (1- center-x) y 2) building-type-id)))
                                                   
                                                   (when (find :e river-params)
                                                     (loop with max-x = (array-dimension template-level 0)
                                                           with min-x = (1- (truncate (array-dimension template-level 0) 2))
                                                           with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for x from (+ min-x 2) below max-x
                                                           for building-type-id = (if (and (zerop (mod (1+ (- x min-x)) 4))
                                                                                           (/= x (1- max-x)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           do
                                                              (setf (aref template-level x (1- center-y) 2) building-type-id)
                                                              (setf (aref template-level x center-y 2) building-type-id)))

                                                   (when (find :w river-params)
                                                     (loop with max-x = (1- (truncate (array-dimension template-level 0) 2))
                                                           with min-x = 0
                                                           with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for x from min-x below max-x
                                                           for building-type-id = (if (and (zerop (mod (1+ x) 4))
                                                                                           (/= x (1- max-x)))
                                                                                    +building-city-bridge+
                                                                                    +building-city-river+)
                                                           do
                                                              (setf (aref template-level x (1- center-y) 2) building-type-id)
                                                              (setf (aref template-level x center-y 2) building-type-id)))
                                                   
                                                   (let ((x (1- (truncate (array-dimension template-level 0) 2)))
                                                         (y (1- (truncate (array-dimension template-level 1) 2))))
    
                                                     (setf (aref template-level (+ x 0) (+ y 0) 2) +building-city-river+)
                                                     (setf (aref template-level (+ x 1) (+ y 0) 2) +building-city-river+)
                                                     (setf (aref template-level (+ x 0) (+ y 1) 2) +building-city-river+)
                                                     (setf (aref template-level (+ x 1) (+ y 1) 2) +building-city-river+))
                                                   
                                                   (loop for x from 0 below (array-dimension template-level 0) do
                                                     (loop for y from 0 below (array-dimension template-level 1) do
                                                       (when (or (= (aref template-level x y 2) +building-city-river+)
                                                                 (= (aref template-level x y 2) +building-city-bridge+)
                                                                 (= (aref template-level x y 2) +building-city-land-border+))
                                                         (push (list (aref template-level x y 2) x y 2) build-list))))
                                                   build-list)))

(set-level-modifier :id +lm-feat-sea+ :type +level-mod-sector-feat+
                    :name "Sea")

(set-level-modifier :id +lm-feat-barricade+ :type +level-mod-sector-feat+
                    :name "Barricade"
                    :priority 20
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT BARRICADE~%")
                                                 
                                                 (let ((build-list)
                                                       (x1 1)
                                                       (x2 (- (array-dimension template-level 0) 2))
                                                       (y1 1)
                                                       (y2 (- (array-dimension template-level 1) 2))
                                                       (barricade-params (second (find +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))))

                                                   ;; set up barricade corners
                                                   (when (and (find :n barricade-params)
                                                              (find :w barricade-params))
                                                     (when (= (aref template-level x1 y1 2) +building-city-free+)
                                                       (setf (aref template-level x1 y1 2) +building-city-barricade-se+)))

                                                   (when (and (find :n barricade-params)
                                                              (find :e barricade-params))
                                                     (when (= (aref template-level x2 y1 2) +building-city-free+)
                                                       (setf (aref template-level x2 y1 2) +building-city-barricade-sw+)))

                                                   (when (and (find :s barricade-params)
                                                              (find :w barricade-params))
                                                     (when (= (aref template-level x1 y2 2) +building-city-free+)
                                                       (setf (aref template-level x1 y2 2) +building-city-barricade-ne+)))

                                                   (when (and (find :s barricade-params)
                                                              (find :e barricade-params))
                                                     (when (= (aref template-level x2 y2 2) +building-city-free+)
                                                       (setf (aref template-level x2 y2 2) +building-city-barricade-nw+)))

                                                   ;; set up barricade lines & entrances
                                                   (when (find :n barricade-params)
                                                     (loop for x from x1 to x2
                                                           when (= (aref template-level x y1 2) +building-city-free+)
                                                           do
                                                              (setf (aref template-level x y1 2) +building-city-barricade-we+))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for off-x from -2 below 2
                                                           when (= (aref template-level (+ center-x off-x) y1 2) +building-city-barricade-we+)
                                                             do
                                                                (setf (aref template-level (+ center-x off-x) y1 2) +building-city-reserved+)))

                                                   (when (find :s barricade-params)
                                                     (loop for x from x1 to x2
                                                           when (= (aref template-level x y2 2) +building-city-free+)
                                                           do
                                                              (setf (aref template-level x y2 2) +building-city-barricade-we+))
                                                     (loop with center-x = (truncate (array-dimension template-level 0) 2)
                                                           for off-x from -2 below 2
                                                           when (= (aref template-level (+ center-x off-x) y2 2) +building-city-barricade-we+)
                                                             do
                                                                (setf (aref template-level (+ center-x off-x) y2 2) +building-city-reserved+)))

                                                   (when (find :w barricade-params)
                                                     (loop for y from y1 to y2
                                                           when (= (aref template-level x1 y 2) +building-city-free+)
                                                           do
                                                              (setf (aref template-level x1 y 2) +building-city-barricade-ns+))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for off-y from -2 below 2
                                                           when (= (aref template-level x1 (+ center-y off-y) 2) +building-city-barricade-ns+)
                                                             do
                                                                (setf (aref template-level x1 (+ center-y off-y) 2) +building-city-reserved+)))

                                                   (when (find :e barricade-params)
                                                     (loop for y from y1 to y2
                                                           when (= (aref template-level x2 y 2) +building-city-free+)
                                                           do
                                                              (setf (aref template-level x2 y 2) +building-city-barricade-ns+))
                                                     (loop with center-y = (truncate (array-dimension template-level 1) 2)
                                                           for off-y from -2 below 2
                                                           when (= (aref template-level x2 (+ center-y off-y) 2) +building-city-barricade-ns+)
                                                             do
                                                                (setf (aref template-level x2 (+ center-y off-y) 2) +building-city-reserved+)))
                                                   
                                                   ;; set up buildings
                                                   (loop for x from 0 below (array-dimension template-level 0) do
                                                     (loop for y from 0 below (array-dimension template-level 1) do
                                                       (when (or (= (aref template-level x y 2) +building-city-barricade-ns+)
                                                                 (= (aref template-level x y 2) +building-city-barricade-we+)
                                                                 (= (aref template-level x y 2) +building-city-barricade-ne+)
                                                                 (= (aref template-level x y 2) +building-city-barricade-se+)
                                                                 (= (aref template-level x y 2) +building-city-barricade-sw+)
                                                                 (= (aref template-level x y 2) +building-city-barricade-nw+)
                                                                 (= (aref template-level x y 2) +building-city-land-border+))
                                                         (push (list (aref template-level x y 2) x y 2) build-list))))
                                                   build-list)))

(set-level-modifier :id +lm-feat-library+ :type +level-mod-sector-feat+
                    :name "Library"
                    :priority 30
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT LIBRARY~%")
                                                 
                                                 (loop with library-types = (prepare-spec-build-id-list +building-type-library+)
                                                       with build-list = () 
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-library-type = (nth (random (length library-types)) library-types)
                                                       until (level-city-can-place-build-on-grid selected-library-type x y 2 template-level)
                                                       finally
                                                          (setf build-list (list (list selected-library-type x y 2)))
                                                          (level-city-reserve-build-on-grid selected-library-type x y 2 template-level)
                                                          (return build-list))
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

                                                 (format t "TEMPLATE LEVEL FUNC: LM FEAT CHURCH~%")
                                                 
                                                 (loop with church-types = (prepare-spec-build-id-list +building-type-church+)
                                                       with build-list = () 
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-church-type = (nth (random (length church-types)) church-types)
                                                       until (level-city-can-place-build-on-grid selected-church-type x y 2 template-level)
                                                       finally
                                                          (setf build-list (list (list selected-church-type x y 2)))
                                                          (level-city-reserve-build-on-grid selected-church-type x y 2 template-level)
                                                          (return build-list))
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
                                                       with build-list = () 
                                                       for x = (random (array-dimension template-level 0))
                                                       for y = (random (array-dimension template-level 1))
                                                       for selected-lair-type = (nth (random (length lair-types)) lair-types)
                                                       until (level-city-can-place-build-on-grid selected-lair-type x y 2 template-level)
                                                       finally
                                                          (setf build-list (list (list selected-lair-type x y 2)))
                                                          (level-city-reserve-build-on-grid selected-lair-type x y 2 template-level)
                                                          (return build-list))
                                                 )
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          ;; add demonic runes
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))
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
                                                                        (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z))
                                                                            )))
                                                                func-list)
                                                          func-list))
                    )
