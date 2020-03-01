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
                                                             ;; add arrival points for angels, demons & military
                                                             (push #'(lambda (level world-sector mission world)
                                                                       (declare (ignore mission))
                                                                       (let* ((sides-hash (make-hash-table))
                                                                             (demon-test-func #'(lambda (x y)
                                                                                                  (if (or (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-demons+)
                                                                                                          (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-forest+)
                                                                                                          (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-port+)
                                                                                                          (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-residential+)
                                                                                                          (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-lake+))
                                                                                                    t
                                                                                                    nil)))
                                                                             (military-test-func #'(lambda (x y)
                                                                                                     (if (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-military+)
                                                                                                       t
                                                                                                       nil)))
                                                                             (hash-print-func #'(lambda ()
                                                                                                  (loop initially (format t "~%SIDES-HASH: ")
                                                                                                        for side being the hash-keys in sides-hash do
                                                                                                          (format t "   ~A : (~A)~%" side (gethash side sides-hash))
                                                                                                        finally (format t "~%")))))
                                                                         ;; find all sides from which demons can arrive
                                                                         (world-find-sides-for-world-sector world-sector (world-map world)
                                                                                                            demon-test-func
                                                                                                            demon-test-func
                                                                                                            demon-test-func
                                                                                                            demon-test-func
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :n sides-hash)
                                                                                                                  (push :demons (gethash :n sides-hash))
                                                                                                                  (setf (gethash :n sides-hash) (list :demons))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :s sides-hash)
                                                                                                                  (push :demons (gethash :s sides-hash))
                                                                                                                  (setf (gethash :s sides-hash) (list :demons))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :w sides-hash)
                                                                                                                  (push :demons (gethash :w sides-hash))
                                                                                                                  (setf (gethash :w sides-hash) (list :demons))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :e sides-hash)
                                                                                                                  (push :demons (gethash :e sides-hash))
                                                                                                                  (setf (gethash :e sides-hash) (list :demons)))))

                                                                         ;; find all sides from which military can arrive
                                                                         (world-find-sides-for-world-sector world-sector (world-map world)
                                                                                                            military-test-func
                                                                                                            military-test-func
                                                                                                            military-test-func
                                                                                                            military-test-func
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :n sides-hash)
                                                                                                                  (push :military (gethash :n sides-hash))
                                                                                                                  (setf (gethash :n sides-hash) (list :military))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :s sides-hash)
                                                                                                                  (push :military (gethash :s sides-hash))
                                                                                                                  (setf (gethash :s sides-hash) (list :military))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :w sides-hash)
                                                                                                                  (push :military (gethash :w sides-hash))
                                                                                                                  (setf (gethash :w sides-hash) (list :military))))
                                                                                                            #'(lambda ()
                                                                                                                (if (gethash :e sides-hash)
                                                                                                                  (push :military (gethash :e sides-hash))
                                                                                                                  (setf (gethash :e sides-hash) (list :military)))))

                                                                         ;; fill the all sides with angels
                                                                         (if (gethash :n sides-hash)
                                                                           (push :angels (gethash :n sides-hash))
                                                                           (setf (gethash :n sides-hash) (list :angels)))
                                                                         (if (gethash :s sides-hash)
                                                                           (push :angels (gethash :s sides-hash))
                                                                           (setf (gethash :s sides-hash) (list :angels)))
                                                                         (if (gethash :w sides-hash)
                                                                           (push :angels (gethash :w sides-hash))
                                                                           (setf (gethash :w sides-hash) (list :angels)))
                                                                         (if (gethash :e sides-hash)
                                                                           (push :angels (gethash :e sides-hash))
                                                                           (setf (gethash :e sides-hash) (list :angels)))

                                                                         ;; PRINT
                                                                         (funcall hash-print-func)

                                                                         ;; if all sides have only one party, we are good to go, otherwise we need rearrangements
                                                                         (loop with demons-num = 0
                                                                               with military-num = 0
                                                                               with angels-num = 0
                                                                               with has-overlapped = nil
                                                                               with count-nums-func = #'(lambda ()
                                                                                                          (loop initially (setf demons-num 0
                                                                                                                                military-num 0
                                                                                                                                angels-num 0
                                                                                                                                has-overlapped nil)
                                                                                                                for side being the hash-keys in sides-hash
                                                                                                                when (find :demons (gethash side sides-hash))
                                                                                                                  do
                                                                                                                     (incf demons-num)
                                                                                                                when (find :military (gethash side sides-hash))
                                                                                                                  do
                                                                                                                     (incf military-num)
                                                                                                                when (find :angels (gethash side sides-hash))
                                                                                                                  do
                                                                                                                     (incf angels-num)
                                                                                                                when (> (length (gethash side sides-hash)) 1)
                                                                                                                  do
                                                                                                                     (setf has-overlapped t)
                                                                                                                finally (format t "Counts:~%   Demons: ~A~%   Angels: ~A~%   Military:~A~%   Overlapped: ~A~%" demons-num angels-num military-num has-overlapped)))
                                                                               with reduce-nums-func = #'(lambda ()
                                                                                                           (format t "Reduce angels:~%")
                                                                                                           ;; reduce angels
                                                                                                           (loop while (and has-overlapped (> angels-num 1)) do
                                                                                                             (loop for side being the hash-keys in sides-hash
                                                                                                                   when (and (> (length (gethash side sides-hash)) 1)
                                                                                                                             (find :angels (gethash side sides-hash)))
                                                                                                                     do
                                                                                                                        (setf (gethash side sides-hash)
                                                                                                                              (remove :angels (gethash side sides-hash)))
                                                                                                                        (funcall count-nums-func)
                                                                                                                        (loop-finish)))
                                                                                                           (funcall hash-print-func)
                                                                                                           (format t "Reduce military:~%")
                                                                                                           ;; reduce military
                                                                                                           (loop while (and has-overlapped (> military-num 1)) do
                                                                                                             (loop for side being the hash-keys in sides-hash
                                                                                                                   when (and (> (length (gethash side sides-hash)) 1)
                                                                                                                        (find :military (gethash side sides-hash)))
                                                                                                                     do
                                                                                                                        (setf (gethash side sides-hash)
                                                                                                                              (remove :military (gethash side sides-hash)))
                                                                                                                        (funcall count-nums-func)
                                                                                                                        (loop-finish)))
                                                                                                           (funcall hash-print-func)
                                                                                                           (format t "Reduce demons:~%")
                                                                                                           ;; reduce demons
                                                                                                           (loop while (and has-overlapped (> demons-num 1)) do
                                                                                                             (loop for side being the hash-keys in sides-hash
                                                                                                                   when (and (> (length (gethash side sides-hash)) 1)
                                                                                                                             (find :demons (gethash side sides-hash)))
                                                                                                                     do
                                                                                                                        (setf (gethash side sides-hash)
                                                                                                                              (remove :demons (gethash side sides-hash)))
                                                                                                                        (funcall count-nums-func)
                                                                                                                        (loop-finish)))
                                                                                                           (funcall hash-print-func)
                                                                                                           
                                                                                                           )
                                                                               initially (funcall count-nums-func)
                                                                               while has-overlapped do
                                                                                 ;; reduce all parties to a minimum
                                                                                 (funcall reduce-nums-func)
                                                                                 (format t "After reduce:~%")
                                                                                 (funcall hash-print-func)
                                                                                 (unless has-overlapped (loop-finish))
                                                                                 ;; if it still does not help, add a random party to a free side
                                                                                 (loop with party-list = (list :angels :military :demons)
                                                                                       with selected-pick = (nth (random (length party-list)) party-list)
                                                                                       for side being the hash-keys in sides-hash
                                                                                       when (= (length (gethash side sides-hash)) 0)
                                                                                         do
                                                                                            (setf (gethash side sides-hash) (list selected-pick))
                                                                                            (loop-finish))
                                                                                 ;; on the next iteration we reduce again and see if it helped
                                                                                 (format t "After addition:~%")
                                                                                 (funcall hash-print-func)
                                                                               )

                                                                         (format t "FINALLY")
                                                                         ;; once we fixed everything - we can place arrival points
                                                                         (loop with party-list = (list (list :demons +feature-demons-arrival-point+)
                                                                                                       (list :military +feature-delayed-military-arrival-point+)
                                                                                                       (list :angels +feature-delayed-angels-arrival-point+))
                                                                               for (party arrival-point-feature-type-id) in party-list
                                                                               ;; north
                                                                               when (find party (gethash :n sides-hash)) do
                                                                                 (loop with y = 2
                                                                                       with z = 2
                                                                                       for x from 0 below (array-dimension (terrain level) 0) by (+ 7 (random 4))
                                                                                       when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                                                                                                 (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                                                                                         do
                                                                                            (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
                                                                                
                                                                                 ;; south
                                                                               when (find party (gethash :s sides-hash)) do
                                                                                 (loop with y = (- (array-dimension (terrain level) 1) 3)
                                                                                       with z = 2
                                                                                       for x from 0 below (array-dimension (terrain level) 0) by (+ 7 (random 4))
                                                                                       when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                                                                                                 (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                                                                                         do
                                                                                            (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
                                                                                 ;; west
                                                                               when (find party (gethash :w sides-hash)) do
                                                                                 (loop with x = 2
                                                                                       with z = 2
                                                                                       for y from 0 below (array-dimension (terrain level) 1) by (+ 7 (random 4))
                                                                                       when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                                                                                                 (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                                                                                         do
                                                                                            (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
                                                                                 ;; east
                                                                               when (find party (gethash :e sides-hash)) do
                                                                                 (loop with x = (- (array-dimension (terrain level) 1) 3)
                                                                                       with z = 2
                                                                                       for y from 0 below (array-dimension (terrain level) 1) by (+ 7 (random 4))
                                                                                       when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                                                                                                 (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                                                                                         do
                                                                                            (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
                                                                               )
                                                                         
                                                                         
                                                                         
                                                                         )
                                                                       
                                                                       )
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
