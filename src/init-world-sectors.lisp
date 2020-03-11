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

                                                    (place-outskirts-on-template-level template-level +building-city-park-3+)
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
                                                             
                                                              func-list)))

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

                                                    (place-outskirts-on-template-level template-level +building-city-ruined-park-3+)
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; place coins to always enable thief's victory
                                                             (push #'place-coins-on-level
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
                                                             
                                                             func-list)))

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
                       :angel-disguised-mob-type-id +mob-type-soldier+
                       :sector-level-gen-func #'(lambda (template-level max-x max-y max-z)
                                                  (create-template-city template-level max-x max-y max-z
                                                                        #'get-max-buildings-corrupted-normal #'get-reserved-buildings-corrupted-normal
                                                                        (list +level-city-border+ +terrain-border-creep+
                                                                              +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-floor+ +terrain-floor-creep+
                                                                              +level-city-floor-bright+ +terrain-floor-creep-bright+)))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             
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
                                                                        (list +level-city-border+ +terrain-border-creep+
                                                                              +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-floor+ +terrain-floor-creep+
                                                                              +level-city-floor-bright+ +terrain-floor-creep-bright+)))
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
                                                     )
                       :overall-post-process-func-list #'(lambda ()
                                                            (let ((func-list ()))
                                                                                                                          
                                                              func-list)))

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
                                                                        (list +level-city-border+ +terrain-border-creep+
                                                                              +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-floor+ +terrain-floor-creep+
                                                                              +level-city-floor-bright+ +terrain-floor-creep-bright+)))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))

                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR OUTSKIRTS~%")

                                                    (place-outskirts-on-template-level template-level +building-city-corrupted-park-3+)
                                                    )
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                                                                                          
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
                                                                        (list +level-city-border+ +terrain-border-creep+
                                                                              +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-floor+ +terrain-floor-creep+
                                                                              +level-city-floor-bright+ +terrain-floor-creep-bright+)))
                       :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                    (declare (ignore mission world world-sector))
                                                    (format t "TEMPLATE LEVEL FUNC: WORLD SECTOR LAKE~%")

                                                    (place-lake-on-template-level template-level +building-city-corrupted-central-lake+))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                                                                                          
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
                                                                        (list +level-city-border+ +terrain-border-creep+
                                                                              +level-city-park+ +building-city-corrupted-park-tiny+
                                                                              +level-city-floor+ +terrain-floor-creep+
                                                                              +level-city-floor-bright+ +terrain-floor-creep-bright+)))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'add-arrival-points-on-level
                                                                   func-list)
                                                             func-list))
                       :template-level-gen-func #'place-island-on-template-level
                       :overall-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             
                                                             func-list)))
