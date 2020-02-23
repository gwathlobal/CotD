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
                       :sector-level-gen-func #'(lambda (template-level building-list max-x max-y max-z)
                                                  (create-template-city template-level building-list max-x max-y max-z
                                                                        #'get-max-buildings-normal #'get-reserved-buildings-normal))
                       :terrain-post-process-func-list #'(lambda ()
                                                           (let ((func-list ()))
                                                             ;; add arrival points for military
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore mission))
                                                                       (terrain-post-process-add-arrival-points level world-sector (world-map world)
                                                                                                                +feature-delayed-military-arrival-point+
                                                                                                                #'(lambda (x y)
                                                                                                                    (if (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-military+)
                                                                                                                      t
                                                                                                                      nil)))                                                                                      
                                                                       )
                                                                   func-list)
                                                             ;; add arrival points for angels
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore mission))
                                                                       (terrain-post-process-add-arrival-points level world-sector (world-map world)
                                                                                                                +feature-delayed-angels-arrival-point+
                                                                                                                #'(lambda (x y)
                                                                                                                    (declare (ignore x y))
                                                                                                                    t))                                                                                      
                                                                       )
                                                                   func-list)
                                                             ;; add arrival points for demons
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore mission))
                                                                       (terrain-post-process-add-arrival-points level world-sector (world-map world)
                                                                                                                +feature-demons-arrival-point+
                                                                                                                #'(lambda (x y)
                                                                                                                    (if (or (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-demons+)
                                                                                                                            (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-forest+)
                                                                                                                            (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-port+)
                                                                                                                            (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-residential+)
                                                                                                                            (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-lake+))
                                                                                                                      t
                                                                                                                      nil)))                                                                                      
                                                                       )
                                                                   func-list)
                                                             (reverse func-list)))
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
                                                                                      when (= feature-id +feature-start-place-civilian-man+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-man+
                                                                                                                                            :x x :y y :z z))
                                                                                      when (= feature-id +feature-start-place-civilian-woman+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-woman+
                                                                                                                                            :x x :y y :z z))
                                                                                      when (= feature-id +feature-start-place-civilian-child+)
                                                                                        do
                                                                                           (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-child+
                                                                                                                                            :x x :y y :z z)))
                                                                             ))
                                                                   func-list)
                                                             (reverse func-list))))

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
                                                    (list +faction-type-ghost+ +mission-faction-absent+))))

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
                                                    (list +faction-type-ghost+ +mission-faction-absent+))))

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
                                                    (list +faction-type-ghost+ +mission-faction-absent+))))

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
                                                    (list +faction-type-ghost+ +mission-faction-absent+))))

;;============
;; ABANDONED
;;============

(set-world-sector-type  :wtype +world-sector-abandoned-residential+
                        :glyph-idx 40
                        :glyph-color (sdl:color :r 150 :g 150 :b 150)
                        :name "An abandoned district"
                        :faction-list-func #'(lambda ()
                                               (list (list +faction-type-eater+ +mission-faction-present+)
                                                     (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-abandoned-port+
                       :glyph-idx 48
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-abandoned-forest+
                       :glyph-idx 38
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "The abandoned outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-abandoned-lake+
                       :glyph-idx 44
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-abandoned-island+
                       :glyph-idx 41
                       :glyph-color (sdl:color :r 150 :g 150 :b 150)
                       :name "An abandoned island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

;;============
;; CORRUPTED
;;============

(set-world-sector-type :wtype +world-sector-corrupted-residential+
                       :glyph-idx 40
                       :glyph-color sdl:*magenta*
                       :name "A corrupted district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-corrupted-port+
                       :glyph-idx 48
                       :glyph-color sdl:*magenta*
                       :name "A corrupted seaport district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-corrupted-forest+
                       :glyph-idx 38
                       :glyph-color sdl:*magenta*
                       :name "The corrupted outskirts of the city"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-corrupted-lake+
                       :glyph-idx 44
                       :glyph-color sdl:*magenta*
                       :name "A corrupted district upon a lake"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                                   (list +faction-type-eater+ +mission-faction-absent+))))

(set-world-sector-type :wtype +world-sector-corrupted-island+
                       :glyph-idx 41
                       :glyph-color sdl:*magenta*
                       :name "A corrupted island district"
                       :faction-list-func #'(lambda ()
                                              (list (list +faction-type-eater+ +mission-faction-present+)
                                                    (list +faction-type-eater+ +mission-faction-absent+))))
