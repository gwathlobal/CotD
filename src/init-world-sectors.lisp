(in-package :cotd)

;;============
;; TEST
;;============

(set-world-sector-type :wtype +world-sector-test+
                       :glyph-idx +glyph-id-large-t+
                       :glyph-color sdl:*white*
                       :name "A test district"
                       :faction-list-func #'(lambda ()
                                              ())
                       :angel-disguised-mob-type-id +mob-type-man+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (declare (ignore template-level))
                                                  (create-template-test-city max-x max-y max-z))
                       )
                       

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
                                                             (push #'place-coins-on-level
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'place-civilians-on-level
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
                                                        ((find :n seaport-params)
                                                         (place-seaport-north template-level +building-city-warehouse-port-1+ +building-city-warehouse-port-2+))
                                                        ;; south
                                                        ((find :s seaport-params)
                                                         (place-seaport-south template-level +building-city-warehouse-port-1+ +building-city-warehouse-port-2+))
                                                        ;; east
                                                        ((find :e seaport-params)
                                                         (place-seaport-east template-level +building-city-warehouse-port-1+ +building-city-warehouse-port-2+))
                                                        ;; west
                                                        ((find :w seaport-params)
                                                         (place-seaport-west template-level +building-city-warehouse-port-1+ +building-city-warehouse-port-2+)))
                                                      )
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'place-civilians-on-level
                                                                   func-list)
                                                             func-list))
                       :scenario-enabled-func #'(lambda (world-map x y)
                                                  ;; choose random sides where to add a sea
                                                  (let ((side (nth (random 4) '(:n :s :e :w))))
                                                    (case side
                                                      (:n (setf (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-sea+))
                                                      (:s (setf (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-sea+))
                                                      (:w (setf (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-sea+))
                                                      (:e (setf (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-sea+)))
                                                    ))
                       :always-lvl-mods-func #'(lambda (world-sector mission-type-id world-time)
                                                 (declare (ignore world-sector mission-type-id world-time))
                                                 (list +lm-feat-sea+))
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

                                                    (place-outskirts-on-template-level template-level +building-city-normal-forest-border+ +building-city-park-3+)
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'place-civilians-on-level
                                                                   func-list)
                                                             func-list)))

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

                                                    (place-lake-on-template-level template-level +building-city-central-lake+))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'place-civilians-on-level
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
                       :template-level-gen-func #'place-island-on-template-level
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)
                                                             
                                                             ;; place civilians if they are available
                                                             (push #'place-civilians-on-level
                                                                   func-list)
                                                             func-list))
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
                        :angel-disguised-mob-type-id +mob-type-soldier+
                        :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-ruined-normal #'get-reserved-buildings-ruined-normal))
                        :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                        :overall-post-process-func-list #'(lambda ()
                                                            (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)

                                                              ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                   func-list)

                                                              ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                              ;; add demonic runes
                                                              (push #'place-demonic-runes-on-level
                                                                    func-list)
                                                              
                                                              func-list)))

(set-world-sector-type :wtype +world-sector-abandoned-port+
                       :glyph-idx 48
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-ruined-port #'get-reserved-buildings-ruined-port))
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
                                                        ((find :n seaport-params)
                                                         (place-seaport-north template-level +building-city-ruined-warehouse-port-1+ +building-city-ruined-warehouse-port-2+))
                                                        ;; south
                                                        ((find :s seaport-params)
                                                         (place-seaport-south template-level +building-city-ruined-warehouse-port-1+ +building-city-ruined-warehouse-port-2+))
                                                        ;; east
                                                        ((find :e seaport-params)
                                                         (place-seaport-east template-level +building-city-ruined-warehouse-port-1+ +building-city-ruined-warehouse-port-2+))
                                                        ;; west
                                                        ((find :w seaport-params)
                                                         (place-seaport-west template-level +building-city-ruined-warehouse-port-1+ +building-city-ruined-warehouse-port-2+)))
                                                       )
                                                     )
                       :overall-post-process-func-list #'(lambda ()
                                                            (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)

                                                              ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                              ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                              ;; add demonic runes
                                                              (push #'place-demonic-runes-on-level
                                                                    func-list)
                                                              
                                                              func-list))
                       :scenario-enabled-func #'(lambda (world-map x y)
                                                  ;; choose random side where to place a sea
                                                  (let ((side (nth (random 4) '(:n :s :e :w))))
                                                    (case side
                                                      (:n (setf (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-sea+))
                                                      (:s (setf (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-sea+))
                                                      (:w (setf (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-sea+))
                                                      (:e (setf (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-sea+)))
                                                    )))

(set-world-sector-type :wtype +world-sector-abandoned-forest+
                       :glyph-idx 38
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "The abandoned outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-ruined-normal #'get-reserved-buildings-ruined-normal))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))

                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR OUTSKIRTS~%")

                                                    (place-outskirts-on-template-level template-level +building-city-normal-forest-border+ +building-city-ruined-park-3+)
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)

                                                             ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                             ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

(set-world-sector-type :wtype +world-sector-abandoned-lake+
                       :glyph-idx 44
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-ruined-normal #'get-reserved-buildings-ruined-normal))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))
                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR LAKE~%")

                                                    (place-lake-on-template-level template-level +building-city-central-lake+))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)

                                                             ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                             ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                             ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

(set-world-sector-type :wtype +world-sector-abandoned-island+
                       :glyph-idx 41
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-ruined-port #'get-reserved-buildings-ruined-port))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'place-island-on-template-level
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
                                                                   func-list)

                                                             ;; place outsider beasts
                                                             (push #'place-outsider-beasts-on-level
                                                                   func-list)

                                                             ;; place blood
                                                             (push #'place-blood-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

;;============
;; CORRUPTED
;;============

(set-world-sector-type :wtype +world-sector-corrupted-residential+
                       :glyph-idx 40
                       :glyph-color sdl:*magenta*
                       :name "A corrupted residential district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-normal #'get-reserved-buildings-corrupted-normal
                                                                        (list +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-terrain-border+ #'(lambda ()
                                                                                                              +terrain-border-creep+)
                                                                               +level-city-terrain-dirt+ #'(lambda ()
                                                                                                            (let ((r (random 100)))
                                                                                                              (cond
                                                                                                                ((< r 3) +terrain-floor-creep-dreadtubes+)
                                                                                                                ((< r 6) +terrain-floor-creep-spores+)
                                                                                                                ((< r 10) +terrain-wall-razorthorns+)
                                                                                                                ((< r 13) +terrain-floor-creep-glowshroom+)
                                                                                                                ((< r 20) +terrain-floor-creep+)
                                                                                                                (t +terrain-floor-creep-bright+)
                                                                                                                )))
                                                                              +level-city-terrain-grass+ #'(lambda ()
                                                                                                             +terrain-floor-creep+)
                                                                              +level-city-terrain-tree+ #'(lambda ()
                                                                                                            +terrain-tree-twintube+)
                                                                              +level-city-terrain-bush+ #'(lambda ()
                                                                                                            +terrain-wall-gloomtwigs+))))
                        :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: World Sector Corrupted Residential~%"))

                                                 (place-demonic-sigils-on-template-level template-level)
                                                 )
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))

                                                             ;; add demonic sigils
                                                             (push #'place-demonic-sigils-on-level
                                                                   func-list)
                                                             
                                                             ;; place outsider beasts
                                                             (push #'place-outsider-beasts-on-level
                                                                   func-list)

                                                             ;; place irradiated spots
                                                             (push #'place-irradation-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

(set-world-sector-type :wtype +world-sector-corrupted-port+
                       :glyph-idx 48
                       :glyph-color sdl:*magenta*
                       :name "A corrupted seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-port #'get-reserved-buildings-corrupted-port
                                                                        (list +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-terrain-border+ #'(lambda ()
                                                                                                              +terrain-border-creep+)
                                                                              +level-city-terrain-dirt+ #'(lambda ()
                                                                                                            (let ((r (random 100)))
                                                                                                              (cond
                                                                                                                ((< r 3) +terrain-floor-creep-dreadtubes+)
                                                                                                                ((< r 6) +terrain-floor-creep-spores+)
                                                                                                                ((< r 10) +terrain-wall-razorthorns+)
                                                                                                                ((< r 13) +terrain-floor-creep-glowshroom+)
                                                                                                                ((< r 20) +terrain-floor-creep+)
                                                                                                                (t +terrain-floor-creep-bright+)
                                                                                                                )))
                                                                              +level-city-terrain-grass+ #'(lambda ()
                                                                                                             +terrain-floor-creep+)
                                                                              +level-city-terrain-tree+ #'(lambda ()
                                                                                                            +terrain-tree-twintube+)
                                                                              +level-city-terrain-bush+ #'(lambda ()
                                                                                                            +terrain-wall-gloomtwigs+))))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world mission))

                                                     (logger (format nil "TEMPLATE LEVEL FUNC: World Sector Corrupted Seaport~%"))

                                                     (let ((seaport-params (second (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a))))))

                                                       (cond
                                                        ;; north
                                                        ((find :n seaport-params)
                                                         (place-seaport-north template-level +building-city-corrupted-warehouse-port-1+ +building-city-corrupted-warehouse-port-2+))
                                                        ;; south
                                                        ((find :s seaport-params)
                                                         (place-seaport-south template-level +building-city-corrupted-warehouse-port-1+ +building-city-corrupted-warehouse-port-2+))
                                                        ;; east
                                                        ((find :e seaport-params)
                                                         (place-seaport-east template-level +building-city-corrupted-warehouse-port-1+ +building-city-corrupted-warehouse-port-2+))
                                                        ;; west
                                                        ((find :w seaport-params)
                                                         (place-seaport-west template-level +building-city-corrupted-warehouse-port-1+ +building-city-corrupted-warehouse-port-2+)))
                                                       )
                                                     
                                                     (place-demonic-sigils-on-template-level template-level)

                                                     )
                       :overall-post-process-func-list #'(lambda ()
                                                            (let ((func-list ()))

                                                              ;; add demonic sigils
                                                             (push #'place-demonic-sigils-on-level
                                                                   func-list)
                                                              
                                                              ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                              ;; place irradiated spots
                                                              (push #'place-irradation-on-level
                                                                    func-list)

                                                              ;; add demonic runes
                                                              (push #'place-demonic-runes-on-level
                                                                    func-list)
                                                              
                                                              func-list))
                       :scenario-enabled-func #'(lambda (world-map x y)
                                                  ;; choose random side where to place a sea
                                                  (let ((side (nth (random 4) '(:n :s :e :w))))
                                                    (case side
                                                      (:n (setf (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-sea+))
                                                      (:s (setf (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-sea+))
                                                      (:w (setf (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-sea+))
                                                      (:e (setf (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-sea+)))
                                                    )))

(set-world-sector-type :wtype +world-sector-corrupted-forest+
                       :glyph-idx 38
                       :glyph-color sdl:*magenta*
                       :name "The corrupted outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-normal #'get-reserved-buildings-corrupted-normal
                                                                        (list +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-terrain-border+ #'(lambda ()
                                                                                                              +terrain-border-creep+)
                                                                              +level-city-terrain-dirt+ #'(lambda ()
                                                                                                            (let ((r (random 100)))
                                                                                                              (cond
                                                                                                                ((< r 3) +terrain-floor-creep-dreadtubes+)
                                                                                                                ((< r 6) +terrain-floor-creep-spores+)
                                                                                                                ((< r 10) +terrain-wall-razorthorns+)
                                                                                                                ((< r 13) +terrain-floor-creep-glowshroom+)
                                                                                                                ((< r 20) +terrain-floor-creep+)
                                                                                                                (t +terrain-floor-creep-bright+)
                                                                                                                )))
                                                                              +level-city-terrain-grass+ #'(lambda ()
                                                                                                             +terrain-floor-creep+)
                                                                              +level-city-terrain-tree+ #'(lambda ()
                                                                                                            +terrain-tree-twintube+)
                                                                              +level-city-terrain-bush+ #'(lambda ()
                                                                                                            +terrain-wall-gloomtwigs+))))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))

                                                    (logger (format nil "TEMPLATE LEVEL FUNC: World Sector Corrupted Outskirts~%"))

                                                    (place-outskirts-on-template-level template-level +building-city-corrupted-forest-border+ +building-city-corrupted-park-3+)

                                                    (place-demonic-sigils-on-template-level template-level)
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))

                                                             ;; add demonic sigils
                                                             (push #'place-demonic-sigils-on-level
                                                                   func-list)
                                                             
                                                             ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                             ;; place irradiated spots
                                                             (push #'place-irradation-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

(set-world-sector-type :wtype +world-sector-corrupted-lake+
                       :glyph-idx 44
                       :glyph-color sdl:*magenta*
                       :name "A corrupted district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-normal #'get-reserved-buildings-corrupted-normal
                                                                        (list +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-terrain-border+ #'(lambda ()
                                                                                                              +terrain-border-creep+)
                                                                              +level-city-terrain-dirt+ #'(lambda ()
                                                                                                            (let ((r (random 100)))
                                                                                                              (cond
                                                                                                                ((< r 3) +terrain-floor-creep-dreadtubes+)
                                                                                                                ((< r 6) +terrain-floor-creep-spores+)
                                                                                                                ((< r 10) +terrain-wall-razorthorns+)
                                                                                                                ((< r 13) +terrain-floor-creep-glowshroom+)
                                                                                                                ((< r 20) +terrain-floor-creep+)
                                                                                                                (t +terrain-floor-creep-bright+)
                                                                                                                )))
                                                                              +level-city-terrain-grass+ #'(lambda ()
                                                                                                             +terrain-floor-creep+)
                                                                              +level-city-terrain-tree+ #'(lambda ()
                                                                                                            +terrain-tree-twintube+)
                                                                              +level-city-terrain-bush+ #'(lambda ()
                                                                                                            +terrain-wall-gloomtwigs+))))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))
                                                    (logger (format nil "TEMPLATE LEVEL FUNC: World Sector Corrupted Lake~%"))

                                                    (place-lake-on-template-level template-level +building-city-central-lake+)

                                                    (place-demonic-sigils-on-template-level template-level))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))

                                                             ;; add demonic sigils
                                                             (push #'place-demonic-sigils-on-level
                                                                   func-list)
                                                             
                                                             ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                             ;; place irradiated spots
                                                             (push #'place-irradation-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))

(set-world-sector-type :wtype +world-sector-corrupted-island+
                       :glyph-idx 41
                       :glyph-color sdl:*magenta*
                       :name "A corrupted island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+)))
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-port #'get-reserved-buildings-corrupted-port
                                                                        (list +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-terrain-border+ #'(lambda ()
                                                                                                              +terrain-border-creep+)
                                                                              +level-city-terrain-dirt+ #'(lambda ()
                                                                                                            (let ((r (random 100)))
                                                                                                              (cond
                                                                                                                ((< r 3) +terrain-floor-creep-dreadtubes+)
                                                                                                                ((< r 6) +terrain-floor-creep-spores+)
                                                                                                                ((< r 10) +terrain-wall-razorthorns+)
                                                                                                                ((< r 13) +terrain-floor-creep-glowshroom+)
                                                                                                                ((< r 20) +terrain-floor-creep+)
                                                                                                                (t +terrain-floor-creep-bright+)
                                                                                                                )))
                                                                              +level-city-terrain-grass+ #'(lambda ()
                                                                                                             +terrain-floor-creep+)
                                                                              +level-city-terrain-tree+ #'(lambda ()
                                                                                                            +terrain-tree-twintube+)
                                                                              +level-city-terrain-bush+ #'(lambda ()
                                                                                                            +terrain-wall-gloomtwigs+))))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (logger (format nil "TEMPLATE LEVEL FUNC: World Sector Corrupted Island~%"))

                                                    (place-island-on-template-level template-level world-sector mission world)
                                                    
                                                    (place-demonic-sigils-on-template-level template-level))
                      
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))

                                                             ;; add demonic sigils
                                                             (push #'place-demonic-sigils-on-level
                                                                   func-list)

                                                             ;; place outsider beasts
                                                              (push #'place-outsider-beasts-on-level
                                                                    func-list)

                                                             ;; place irradiated spots
                                                             (push #'place-irradation-on-level
                                                                   func-list)

                                                             ;; add demonic runes
                                                             (push #'place-demonic-runes-on-level
                                                                   func-list)
                                                             
                                                             func-list)))
