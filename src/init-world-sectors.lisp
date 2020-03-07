(in-package :cotd)

;;============
;; NORMAL
;;============

(set-world-sector-type :wtype +world-sector-normal-residential+
                       :glyph-idx 40
                       :glyph-color sdl:*white*
                       :name "An ordinary district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-civilians+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)
                                                    (list +faction-type-criminals+ +mission-faction-present+)
                                                    (list +faction-type-criminals+ +mission-faction-absent+)
                                                    (list +faction-type-ghost+ +mission-faction-present+)
                                                    (list +faction-type-ghost+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-normal #'get-reserved-buildings-normal))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore world-sector mission world))
                                                                       (let ((total-gold-items (loop for feature-id in (feature-id-list level)
                                                                                                     for lvl-feature = (get-feature-by-id feature-id)
                                                                                                     when (= (feature-type lvl-feature) +feature-start-gold-small+)
                                                                                                       count lvl-feature)))
                                                                         
                                                                         (loop for feature-id in (feature-id-list level)
                                                                               for lvl-feature = (get-feature-by-id feature-id)
                                                                               when (= (feature-type lvl-feature) +feature-start-gold-small+)
                                                                                 do
                                                                                    (add-item-to-level-list level (make-instance 'item :item-type +item-type-coin+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature)
                                                                                                                                       :qty (+ (round 1250 total-gold-items) (random 51))))
                                                                                    (remove-feature-from-level-list level lvl-feature)
                                                                               )
                                                                         ))
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore world-sector world))

                                                                       (format t "OVERALL-POST-PROCESS-FUNC: Place civilians~%~%")
                                                                       (loop with civilians-present = nil
                                                                             for (faction-type faction-presence) in (faction-list mission)
                                                                             when (and (= faction-type +faction-type-civilians+)
                                                                                       (= faction-presence +mission-faction-present+))
                                                                               do
                                                                                  (setf civilians-present t)
                                                                             finally
                                                                                (unless civilians-present (return))
                                                                                
                                                                                ;; find all civilian start points and place civilians there
                                                                                (loop for feature-id in (feature-id-list level)
                                                                                      for lvl-feature = (get-feature-by-id feature-id)
                                                                                      for x = (x lvl-feature)
                                                                                      for y = (y lvl-feature)
                                                                                      for z = (z lvl-feature)
                                                                                      when (= (feature-type lvl-feature) +feature-start-place-civilian-man+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-man+
                                                                                                                                            :x x :y y :z z))
                                                                                      when (= (feature-type lvl-feature) +feature-start-place-civilian-woman+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-woman+
                                                                                                                                            :x x :y y :z z))
                                                                                      when (= (feature-type lvl-feature) +feature-start-place-civilian-child+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-child+
                                                                                                                                            :x x :y y :z z)))
                                                                             ))
                                                                   func-list)
                                                             func-list))
                       )

(set-world-sector-type :wtype +world-sector-normal-port+
                       :glyph-idx 48
                       :glyph-color sdl:*white*
                       :name "A seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-civilians+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)
                                                    (list +faction-type-criminals+ +mission-faction-present+)
                                                    (list +faction-type-criminals+ +mission-faction-absent+)
                                                    (list +faction-type-ghost+ +mission-faction-present+)
                                                    (list +faction-type-ghost+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-port #'get-reserved-buildings-port))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world mission))

                                                     (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR SEAPORT~%")

                                                     (let ((seaport-params (second (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a))))))

                                                       (cond
                                                         ;; north
                                                         ((find :n seaport-params) (place-seaport-north template-level))
                                                         ;; south
                                                         ((find :s seaport-params) (place-seaport-south template-level))
                                                         ;; east
                                                         ((find :e seaport-params) (place-seaport-east template-level))
                                                         ;; west
                                                         ((find :w seaport-params) (place-seaport-west template-level)))
                                                       )
                                                     )
                       )

(set-world-sector-type :wtype +world-sector-normal-forest+
                       :glyph-idx 38
                       :glyph-color sdl:*white*
                       :name "The outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-civilians+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)
                                                    (list +faction-type-criminals+ +mission-faction-present+)
                                                    (list +faction-type-criminals+ +mission-faction-absent+)
                                                    (list +faction-type-ghost+ +mission-faction-present+)
                                                    (list +faction-type-ghost+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-normal #'get-reserved-buildings-normal))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))

                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR OUTSKIRTS~%")

                                                    ;; place +building-city-park-tiny+ and +building-city-park-3+ along the borders
                                                    (loop with y1 = 0
                                                          with y2 = (array-dimension template-level 1)
                                                          for x from 0 below (array-dimension template-level 0)
                                                          do
                                                             (level-city-reserve-build-on-grid +building-city-forest-border+ x y1 2 template-level)
                                                             (level-city-reserve-build-on-grid +building-city-forest-border+ x (- y2 1) 2 template-level)
                                                             
                                                             (when (level-city-can-place-build-on-grid +building-city-park-3+ x (+ y1 1) 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-park-3+ x (+ y1 1) 2 template-level))
                                                             (when (level-city-can-place-build-on-grid +building-city-park-3+ x (- y2 3) 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-park-3+ x (- y2 3) 2 template-level)))
                                                    
                                                    (loop with x1 = 0
                                                          with x2 = (array-dimension template-level 0)
                                                          for y from 0 below (array-dimension template-level 1)
                                                          do
                                                             (level-city-reserve-build-on-grid +building-city-forest-border+ x1 y 2 template-level)
                                                             (level-city-reserve-build-on-grid +building-city-forest-border+ (- x2 1) y 2 template-level)
                                                             
                                                             (when (level-city-can-place-build-on-grid +building-city-park-3+ (+ x1 1) y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-park-3+ (+ x1 1) y 2 template-level))
                                                             (when (level-city-can-place-build-on-grid +building-city-park-3+ (- x2 3) y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-park-3+ (- x2 3) y 2 template-level)))
                                                    
                                                    ))

(set-world-sector-type :wtype +world-sector-normal-lake+
                       :glyph-idx 44
                       :glyph-color sdl:*white*
                       :name "A district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-civilians+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)
                                                    (list +faction-type-criminals+ +mission-faction-present+)
                                                    (list +faction-type-criminals+ +mission-faction-absent+)
                                                    (list +faction-type-ghost+ +mission-faction-present+)
                                                    (list +faction-type-ghost+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-normal #'get-reserved-buildings-normal))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))

                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR LAKE~%")

                                                    (let ((x (- (truncate (array-dimension template-level 0) 2) 2))
                                                          (y (- (truncate (array-dimension template-level 1) 2) 2)))

                                                      (level-city-reserve-build-on-grid +building-city-central-lake+ x y 2 template-level)
                                                      
                                                      ))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       )

(set-world-sector-type :wtype +world-sector-normal-sea+
                       :glyph-idx 51
                       :glyph-color sdl:*white*
                       :name "Sea")

(set-world-sector-type :wtype +world-sector-normal-island+
                       :glyph-idx 41
                       :glyph-color sdl:*white*
                       :name "An island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-civilians+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)
                                                    (list +faction-type-criminals+ +mission-faction-present+)
                                                    (list +faction-type-criminals+ +mission-faction-absent+)
                                                    (list +faction-type-ghost+ +mission-faction-present+)
                                                    (list +faction-type-ghost+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-port #'get-reserved-buildings-port))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world mission world-sector))

                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR ISLAND~%")

                                                    (let ((max-x (array-dimension template-level 0))
                                                          (max-y (array-dimension template-level 1)))
                                                      ;; place water along the borders
                                                      (loop for x from 0 below max-x
                                                            do
                                                               (level-city-reserve-build-on-grid +building-city-sea+ x 0 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ x 1 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ x 2 2 template-level)

                                                               (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 1) 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 2) 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 3) 2 template-level))
                                                      
                                                      (loop for y from 0 below max-y
                                                            do
                                                               (level-city-reserve-build-on-grid +building-city-sea+ 0 y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ 1 y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ 2 y 2 template-level)

                                                               (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 1) y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 2) y 2 template-level)
                                                               (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 3) y 2 template-level))
                                                    
                                                      ;; place four piers - north, south, east, west
                                                      (let ((min) (max) (r))
                                                        ;; north
                                                        (setf min 3 max (- (truncate max-x 2) 1))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-north+ r 1 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-north+ r 2 2 template-level)
                                                        (setf min (+ (truncate max-x 2) 1) max (- max-x 3))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-north+ r 1 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-north+ r 2 2 template-level)
                                                        
                                                        ;; south
                                                        (setf min 3 max (- (truncate max-x 2) 1))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 2) 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 3) 2 template-level)
                                                        (setf min (+ (truncate max-x 2) 1) max (- max-x 3))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 2) 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 3) 2 template-level)
                                                        
                                                        ;; west
                                                        (setf min 3 max (- (truncate max-y 2) 1))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-west+ 1 r 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-west+ 2 r 2 template-level)
                                                        (setf min (+ (truncate max-y 2) 1) max (- max-y 3))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-west+ 1 r 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-west+ 2 r 2 template-level)
                                                        
                                                        ;; east
                                                        (setf min 3 max (- (truncate max-y 2) 1))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 2) r 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 3) r 2 template-level)
                                                        (setf min (+ (truncate max-y 2) 1) max (- max-y 3))
                                                        (setf r (+ (random (- max min)) min))
                                                        (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 2) r 2 template-level)
                                                        (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 3) r 2 template-level))
                                                      )
                                                    )
                       )

;;============
;; ABANDONED
;;============

(set-world-sector-type  :wtype +world-sector-abandoned-residential+
                        :glyph-idx 40
                        :glyph-color (sdl:color :r 150 :g 150 :b 150)
                        :name "An abandoned district"
                        :faction-list-func #'(lambda ()
                                               (list (list +faction-type-eater+ +mission-faction-present+)
                                                     (list +faction-type-eater+ +mission-faction-absent+)))
                        :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-abandoned-port+
                       :glyph-idx 48
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-abandoned-forest+
                       :glyph-idx 38
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "The abandoned outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-abandoned-lake+
                       :glyph-idx 44
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-abandoned-island+
                       :glyph-idx 41
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

;;============
;; CORRUPTED
;;============

(set-world-sector-type :wtype +world-sector-corrupted-residential+
                       :glyph-idx 40
                       :glyph-color sdl:*magenta*
                       :name "A corrupted district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-corrupted-port+
                       :glyph-idx 48
                       :glyph-color sdl:*magenta*
                       :name "A corrupted seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-corrupted-forest+
                       :glyph-idx 38
                       :glyph-color sdl:*magenta*
                       :name "The corrupted outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-corrupted-lake+
                       :glyph-idx 44
                       :glyph-color sdl:*magenta*
                       :name "A corrupted district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)

(set-world-sector-type :wtype +world-sector-corrupted-island+
                       :glyph-idx 41
                       :glyph-color sdl:*magenta*
                       :name "A corrupted island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+)
