(in-package :cotd)

;;=====================
;; Runied houses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",,.#####,"
                                                                            ",....u##,"
                                                                            ",.h....#,"
                                                                            ",####|.#,"
                                                                            ",-ht...#,"
                                                                            ",#....c#,"
                                                                            ",.##+###,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            "   #-### "
                                                                            "   ..d.# "
                                                                            "  c....# "
                                                                            " ####|.# "
                                                                            " #b....# "
                                                                            " ..h..h# "
                                                                            "  ..-### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            "   ..... "
                                                                            "   ..... "
                                                                            "  ...... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            "   ..... "
                                                                            "    .... "
                                                                            "         ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil
                                                    ))))

(set-building-type (make-building :id +building-city-corrupted-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",#c...t#,"
                                                                            ",#..|...,"
                                                                            ",+..#..,,"
                                                                            ",#.u#...,"
                                                                            ",-.##ht#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ##-#### "
                                                                            " #c...b. "
                                                                            " #..|.   "
                                                                            " #..#.   "
                                                                            " #.d#..  "
                                                                            " #..#bc# "
                                                                            " ##-#### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " .....   "
                                                                            " ....    "
                                                                            " .....   "
                                                                            " ....... "
                                                                            " ....... "
                                                                            "         ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",##u#ht-,"
                                                                            ",#..#..#,"
                                                                            ",-..#..+,"
                                                                            ",#t.|..#,"
                                                                            ",.....c#,"
                                                                            ",,..####,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ####### "
                                                                            " #.d#cb# "
                                                                            " #..#..# "
                                                                            " -..#..- "
                                                                            " #..|.b# "
                                                                            "   ...c# "
                                                                            "    #### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            "   ..... "
                                                                            "    .... "
                                                                            "         ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",###..,,,"
                                                                            ",#c....,,"
                                                                            ",#......,"
                                                                            ",#.|####,"
                                                                            ",#....##,"
                                                                            ",#cb..u#,"
                                                                            ",#####-#,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ###     "
                                                                            " #c...   "
                                                                            " #....   "
                                                                            " #.|#### "
                                                                            " #.....# "
                                                                            " -th..d# "
                                                                            " ####### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....    "
                                                                            " .....   "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            "         ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined townhalls
;;=====================

(set-building-type (make-building :id +building-city-corrupted-townhall-1+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",,,##......#,,,,"
                                                                            ",,```......```,,"
                                                                            ",#```......```,,"
                                                                            ",#```......```,,"
                                                                            ",##-###..###-##,"
                                                                            ",#|..#c..c#..|.,"
                                                                            ",#...+....+...,,"
                                                                            ",##u.#|..|#...,,"
                                                                            ",###-##--##.,,,,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                "
                                                                            "   ..      .    "
                                                                            "                "
                                                                            " .              "
                                                                            " .              "
                                                                            " ##-###-###.... "
                                                                            " #..|#|...#...  "
                                                                            " #...+....+..   "
                                                                            " #.d.#c.ht#..   "
                                                                            " ###-##-###.    "
                                                                            "                "))

                                                  (build-template-z-4 (list "                "
                                                                            "                "
                                                                            "                "
                                                                            "                "
                                                                            "                "
                                                                            " ..........     "
                                                                            " ..........     "
                                                                            " ..........     "
                                                                            " ..........     "
                                                                            " ..........     "
                                                                            "                ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-2+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",###-##--##-###,"
                                                                            ",#ht.#|..|#.u##,"
                                                                            ",#...+....+...,,"
                                                                            ",#|..#c..c#...,,"
                                                                            ",##-###..###..,,"
                                                                            ",#```......```,,"
                                                                            ",#```......```#,"
                                                                            ",,```......```#,"
                                                                            ",,,##......####,"
                                                                            ",,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                "
                                                                            " ....###-##-### "
                                                                            " ....#th.c#.d.# "
                                                                            " ....+....+...  "
                                                                            " ....#...|#|.   "
                                                                            " ....###-###    "
                                                                            " .              "
                                                                            " .            . "
                                                                            "              . "
                                                                            "   ..      .... "
                                                                            "                "))

                                                  (build-template-z-4 (list "                "
                                                                            "     .......... "
                                                                            "     .......... "
                                                                            "     .......... "
                                                                            "     .......... "
                                                                            "     .......... "
                                                                            "                "
                                                                            "                "
                                                                            "                "
                                                                            "                "
                                                                            "                ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-3+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",#########,"
                                                                            ",##..#```#,"
                                                                            ",#u..-```#,"
                                                                            ",-..|#```#,"
                                                                            ",##+##....,"
                                                                            ",....#....,"
                                                                            ",.........,"
                                                                            ",.........,"
                                                                            ",....#....,"
                                                                            ",##+##....,"
                                                                            ",-..|#```#,"
                                                                            ",#t..-```#,"
                                                                            ",#h..#```#,"
                                                                            ",#########,"
                                                                            ",,,,,,,,,,,"))

                                                  (build-template-z-3 (list "           "
                                                                            " #####.... "
                                                                            " #..|#   . "
                                                                            " #d..-   . "
                                                                            " -...#   . "
                                                                            " ##+##     "
                                                                            "   ..#     "
                                                                            "    .-     "
                                                                            "    .#     "
                                                                            "   ..#     "
                                                                            " ##+##     "
                                                                            " .....   . "
                                                                            " .....   . "
                                                                            " .....   . "
                                                                            " ......... "
                                                                            "           "))
                                                  
                                                  (build-template-z-4 (list "           "
                                                                            " .....     "
                                                                            " .....     "
                                                                            " .....     "
                                                                            " .....     "
                                                                            "  ....     "
                                                                            "   ...     "
                                                                            "  ....     "
                                                                            " .....     "
                                                                            " .....     "
                                                                            " .....     "
                                                                            "           "
                                                                            "           "
                                                                            "           "
                                                                            "           "
                                                                            "           ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-4+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",,,,,,..##,"
                                                                            ",,```...h#,"
                                                                            ",,```...t#,"
                                                                            ",,```#...#,"
                                                                            ",....##+##,"
                                                                            ",....#c.|#,"
                                                                            ",........-,"
                                                                            ",........-,"
                                                                            ",....#c.|#,"
                                                                            ",....##+##,"
                                                                            ",#```#...-,"
                                                                            ",#```-..u#,"
                                                                            ",#```#|.##,"
                                                                            ",#########,"
                                                                            ",,,,,,,,,,,"))

                                                  (build-template-z-3 (list "           "
                                                                            "        .. "
                                                                            "       ... "
                                                                            "      .... "
                                                                            "     ..... "
                                                                            "     ##+## "
                                                                            "     #..t# "
                                                                            "     #..h# "
                                                                            "     -...- "
                                                                            "     #|.c# "
                                                                            "     ##+## "
                                                                            " .   #|..- "
                                                                            " .   -..d# "
                                                                            " .   #...# "
                                                                            " ....##### "
                                                                            "           "))

                                                  (build-template-z-4 (list "           "
                                                                            "           "
                                                                            "           "
                                                                            "           "
                                                                            "           "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "     ..... "
                                                                            "           ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined parks
;;=====================

(set-building-type (make-building :id +building-city-corrupted-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template (list ",,```,,```"
                                                                        "```T````T`"
                                                                        "`T```T````"
                                                                        "``````T`,,"
                                                                        "``T`````,,"
                                                                        ",````T````"
                                                                        ",```````T`"
                                                                        ",`````````"
                                                                        ",,`T``T`,,"
                                                                        ",,``````,,")))
                                              
                                              (translate-build-to-template x y z build-template template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


(set-building-type (make-building :id +building-city-corrupted-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template (list ",,```,```,"
                                                                        "```T```T`,"
                                                                        "`T```T````"
                                                                        "```T``````"
                                                                        "`T````T```"
                                                                        "````T```,,"
                                                                        ",`T```T`,,"
                                                                        ",`````````"
                                                                        ",`T`T`,`T`"
                                                                        ",`````,```")))
                                              
                                              (translate-build-to-template x y z build-template template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+))))

                                            ;; make sure that each tree has no more than one adjacent tree
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y z) +terrain-tree-twintube+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 1)
                                                         (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-creep+))))

                                            ;; place a large twintube tree
                                            (let ((dx (random 8))
                                                  (dy (random 8))
                                                  (r (random 5)))
                                              (cond
                                                ((= r 4) (level-place-twintube-corrupted-4 template-level (+ dx x) (+ dy y) z))
                                                ((= r 3) (level-place-twintube-corrupted-3 template-level (+ dx x) (+ dy y) z))
                                                ((= r 2) (level-place-twintube-corrupted-2 template-level (+ dx x) (+ dy y) z))
                                                ((= r 1) (level-place-twintube-corrupted-1 template-level (+ dx x) (+ dy y) z))
                                                (t nil))
                                              )
                                            
                                            ;; place grass around trees
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (setf (aref template-level x y z) +terrain-floor-creep+))))))
                                            
                                            ;; find a place to position citizens
                                            (values nil
                                                    nil
                                                    nil)
                                            )))

(set-building-type (make-building :id +building-city-corrupted-park-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+))))

                                            ;; make sure that each tree has no more than one adjacent tree
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y z) +terrain-tree-twintube+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 1)
                                                         (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-creep+))))

                                            ;; place grass around trees
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (setf (aref template-level x y z) +terrain-floor-creep+))))))

                                            ;; place a large oak tree
                                            (let ((dx (random 8))
                                                  (dy (random 8)))
                                              (cond
                                                (t (level-place-twintube-mutated-1 template-level (+ dx x) (+ dy y) z)))
                                              )
                                            
                                            ;; find a place to position citizens
                                            (values nil
                                                    nil
                                                    nil)
                                            )))

(set-building-type (make-building :id +building-city-corrupted-park-tiny+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (if (zerop (random 5))
                                              (progn
                                                ;; place a large birch tree
                                                (let ((r (random 4)))
                                                  (cond
                                                    ((= r 3) (level-place-twintube-corrupted-4 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 2) (level-place-twintube-corrupted-3 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 1) (level-place-twintube-corrupted-2 template-level (+ 1 x) (+ 1 y) z))
                                                    (t (level-place-twintube-corrupted-1 template-level (+ 1 x) (+ 1 y) z)))
                                                  )
                                                (values nil nil)
                                                )
                                              (progn
                                                ;; populate the area with trees, leaving the border untouched
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (zerop (random 3))
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+))))
                                                
                                                ;; make sure that each tree has no more than two adjacent trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3
                                                        with tree-num
                                                        do
                                                           (setf tree-num 0)
                                                           (check-surroundings (+ x dx) (+ y dy) nil
                                                                               #'(lambda (x y)
                                                                                   (when (= (aref template-level x y z) +terrain-tree-twintube+)
                                                                                     (incf tree-num))))
                                                           (when (> tree-num 2)
                                                             (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-creep+))))
                                                
                                                ;; place grass around trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+)
                                                      (check-surroundings (+ x dx) (+ y dy) nil
                                                                          #'(lambda (x y)
                                                                              (if (or (= (aref template-level x y z) +terrain-border-floor+)
                                                                                      (= (aref template-level x y z) +terrain-border-grass+)
                                                                                      (= (aref template-level x y z) +terrain-border-creep+))
                                                                                (setf (aref template-level x y z) +terrain-border-creep+)
                                                                                (setf (aref template-level x y z) +terrain-floor-creep+)))))))
                                                
                                                (values nil nil nil))))
                                  ))

;;=====================
;; Ruined prisons
;;=====================

(set-building-type (make-building :id +building-city-corrupted-prison-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-corrupted-prison+
                                  :func #'(lambda (x y z template-level terrains)
                                            
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,"
                                                                            ",,.#####.#######,"
                                                                            ",......-.#...+.#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#|###.#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#...+.#,"
                                                                            ",#.....-.#####.#,"
                                                                            ",#.....-........,"
                                                                            ",#+#####h..###.,,"
                                                                            ",#....|###+##u..,"
                                                                            ",#..............,"
                                                                            ",#-+#-+#-+#-+#.#,"
                                                                            ",...#..#..#..#.#,"
                                                                            ",...#.b#.b#.b#.#,"
                                                                            ",,..############,"
                                                                            ",,,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                 "
                                                                            "   ############# "
                                                                            "       #|...+.b# "
                                                                            " #     #....-..# "
                                                                            " #     -....#### "
                                                                            " #     #h...+.b# "
                                                                            " #     -....-..# "
                                                                            " #     #....#### "
                                                                            " #     #|.....h  "
                                                                            " #-###-####...   "
                                                                            " #.....|.....d.  "
                                                                            " #.............# "
                                                                            " #-+#-+#-+#-+#.# "
                                                                            "  ..#..#..#..#.# "
                                                                            "    #.b#.b#.b#.# "
                                                                            "    ############ "
                                                                            "                 "))

                                                  (build-template-z-4 (list "                 "
                                                                            "   ............. "
                                                                            "       ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ........  "
                                                                            " .............   "
                                                                            " ..............  "
                                                                            " ............... "
                                                                            " ............... "
                                                                            "  .............. "
                                                                            "    ............ "
                                                                            "    ............ "
                                                                            "                 ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 7) (+ y 0) z) +terrain-floor-sign-prison+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Corrupted warehouses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-corrupted-warehouse+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,,"
                                                                            ",##-#####..#####-##,"
                                                                            ",#|..............|#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#..############..#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",-................-,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#..####....####..#,"
                                                                            ",..................,"
                                                                            ",..................,"
                                                                            ",#..####....####..#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",-................-,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#..############..#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#|..............|#,"
                                                                            ",##-#####..#####-##,"
                                                                            ",,,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                    "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .......    ....... "
                                                                            " ......      ...... "
                                                                            " ......      ...... "
                                                                            " .......    ....... "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            "                    ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined libraries
;;=====================

(set-building-type (make-building :id +building-city-corrupted-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 13) :type +building-type-corrupted-library+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "00000000000000000000"
                                                                            "00000000000000000000"
                                                                            "00000000000000000000"
                                                                            "00000000000000000000"
                                                                            "00000000000000000000"
                                                                            "000000000000#######0"
                                                                            "000000000000#BB.BB#0"
                                                                            "000000000000#.....#0"
                                                                            "000000000000#|....#0"
                                                                            "000000000000#####.#0"
                                                                            "0000000000000000#u#0"
                                                                            "0000000000000000###0"
                                                                            "00000000000000000000"
                                                                            ))
                                                  (build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,,"
                                                                            ",,..####-###-###-##,"
                                                                            ",..h.|#..........|#,"
                                                                            ",..t..+..B..B..B..-,"
                                                                            ",#....#..B..B..B..#,"
                                                                            ",##..##..B..B..B..#,"
                                                                            ",`````-..B..B..B..-,"
                                                                            ",`````#..B..B..B..#,"
                                                                            ",`T```#..B..B..B..#,"
                                                                            ",`````-..B..B..#...,"
                                                                            ",,``T`#|.........d.,"
                                                                            ",,,```##-###-##....,"
                                                                            ",,,,,,,,,,,,,,,,,,,,"
                                                                            ))
                                                  (build-template-z-3 (list "                    "
                                                                            "    ............... "
                                                                            "   ................ "
                                                                            "  ................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ...........   "
                                                                            "      ..........    "
                                                                            "      ..........    "
                                                                            "                    "
                                                                        )))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 2) (+ y 6) z) +terrain-floor-sign-library+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Corrupted port warehouses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",########,"
                                                                            ",#|CCCCC#,"
                                                                            ",+......+,"
                                                                            ",#.CCCC.#,"
                                                                            ",#.CCCC.#,"
                                                                            ",+......+,"
                                                                            ",#CCCCC|#,"
                                                                            ",########,"
                                                                            ",,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            "          ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",##+##+##,"
                                                                            ",#C....|#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#|....C#,"
                                                                            ",##+##+##,"
                                                                            ",,,,,,,,,,"))

                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            " ........ "
                                                                            "          ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Corrupted mansions
;;=====================

(set-building-type (make-building :id +building-city-corrupted-mansion-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-mansion+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,###-#-###-#-.,,,,"
                                                                            ",,#B..#.|#|.#...,,,"
                                                                            ",,#B..+..u..+....,,"
                                                                            ",,#B..#c...c#...,,,"
                                                                            ",,##+####-####.,,,,"
                                                                            ",,#|..#``````*``,,,"
                                                                            ",,#...+``*``````*,,"
                                                                            ",,#...#`*``*````,,,"
                                                                            ",,#...#```````*`,,,"
                                                                            ",,##+##***,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                   "
                                                                            "                   "
                                                                            "  ###-#####-#..    "
                                                                            "  #...#|....#..    "
                                                                            "  #ht.+..d..+..    "
                                                                            "  #|..#BB.BB#..    "
                                                                            "  ##+####-###.     "
                                                                            "  #c.|#            "
                                                                            "  #...-            "
                                                                            "  #..t-            "
                                                                            "  #b.h#            "
                                                                            "  ##-##            "
                                                                            "                   "
                                                                            "                   "))

                                                  (build-template-z-4 (list "                   "
                                                                            "                   "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "                   "
                                                                            "                   ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-mansion-2+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-mansion+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,##+##**,,,,**,,,,"
                                                                            ",,#...#`````````,,,"
                                                                            ",,#...#``*`*``*`,,,"
                                                                            ",,#...+`*```````*,,"
                                                                            ",,#|..#``````*``*,,"
                                                                            ",,##+####-####-##,,"
                                                                            ",,#B..#c...c#..c#,,"
                                                                            ",,#B..+..u..+..c-,,"
                                                                            ",,,...#.|#|.#..c#,,"
                                                                            ",,,,..#-###-#-###,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                   "
                                                                            "                   "
                                                                            "  ##-##            "
                                                                            "  #b.h#            "
                                                                            "  #..t-            "
                                                                            "  #...-            "
                                                                            "  #c.|#            "
                                                                            "  ##+####-###....  "
                                                                            "  #|..#BB.BB#..h.  "
                                                                            "  #ht.+..d..+..t.  "
                                                                            "     .#|....#..h.  "
                                                                            "      #####-#....  "
                                                                            "                   "
                                                                            "                   "))

                                                  (build-template-z-4 (list "                   "
                                                                            "                   "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  .....            "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "    .........      "
                                                                            "     ........      "
                                                                            "                   "
                                                                            "                   ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


;;=====================
;; Corrupted banks
;;=====================

(set-building-type (make-building :id +building-city-corrupted-bank-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-bank+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "000000000000000"
                                                                            "000000000000000"
                                                                            "00###########00"
                                                                            "00#h....h#u.#00"
                                                                            "00#.........#00"
                                                                            "00##+##|#,,,uu0"
                                                                            "00##.####,,,,u0"
                                                                            "00##+##|#,,,,u0"
                                                                            "00#.......,,uu0"
                                                                            "00#.........u00"
                                                                            "00###########00"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"))
                                                  
                                                  (build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,###########,,"
                                                                            ",,#|......d##,,"
                                                                            ",,#..........,,"
                                                                            ",,#+##+##   dd,"
                                                                            ",,#.#...#    d,"
                                                                            ",,#.#.h.#    d,"
                                                                            ",,#+#|t##   dd,"
                                                                            ",,#.......  d.,"
                                                                            ",,-....hhhh..,,"
                                                                            ",,##++##-####,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "               "
                                                                            "               "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ..........   "
                                                                            "  .........    "
                                                                            "  ........     "
                                                                            "  ........     "
                                                                            "  .........    "
                                                                            "  ..........   "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "               "
                                                                            "               "))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z -1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            
                                            (setf (aref template-level (+ x 6) (+ y 12) z) +terrain-floor-sign-bank+)

                                            (values nil
                                                    nil
                                                    nil))))


;;=====================
;; Graveyards
;;=====================

(set-building-type (make-building :id +building-city-corrupted-graveyard-1+ :grid-dim '(4 . 4) :act-dim '(16 . 16) :type +building-type-corrupted-graveyard+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",*,,**,*,,**,,*,"
                                                                            ",,,,,,,,,,,,,,*,"
                                                                            ",,*G,,G,,G,,G,,,"
                                                                            ",,,,,*,,,,,,,,*,"
                                                                            ",*,,,,,,,,,*,,*,"
                                                                            ",,,G,,G,,G,,G,,,"
                                                                            ",*,,,,,,,,,,,,,,"
                                                                            ",*,,,,,*,,,,,,,,"
                                                                            ",,,G,,G,,G,,G,*,"
                                                                            ",*,,*,,,,,,,,,*,"
                                                                            ",,,,,,,,,,*,,,*,"
                                                                            ",*,G,,G,,G,,G,*,"
                                                                            ",*,,,,,,,,,,,,,,"
                                                                            ",*,****,,,***,*,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Corrupted shrine
;;=====================

(set-building-type (make-building :id +building-city-corrupted-shrine-1+ :grid-dim '(3 . 3) :act-dim '(15 . 15) :type +building-type-corrupted-shrine+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,XXXXXXXXX,,,"
                                                                            ",,*,,,,,,,,,*,,"
                                                                            ",X,,,XXXXX,,,X,"
                                                                            ",X,,*,,,,,*,,X,"
                                                                            ",X,X,XX,XX,X,X,"
                                                                            ",X,X,X,,,X,X,X,"
                                                                            ",X,X,,,.,,,X,X,"
                                                                            ",X,X,X,,,X,X,X,"
                                                                            ",X,X,XX,XX,X,X,"
                                                                            ",X,,*,,,,,*,,X,"
                                                                            ",X,,,XXXXX,,,X,"
                                                                            ",,*,,,,,,,,,*,,"
                                                                            ",,,XXXXXXXXX,,,"
                                                                            ",,,,,,,,,,,,,,,"))
                                                  (build-template-z-3 (list "               "
                                                                            "   `````````   "
                                                                            "  XXXXXXXXXXX  "
                                                                            " XX  XXXXX  XX "
                                                                            " X           X "
                                                                            " X X XX XX X X "
                                                                            " X X X   X X X "
                                                                            " X X       X X "
                                                                            " X X X   X X X "
                                                                            " X X XX XX X X "
                                                                            " X           X "
                                                                            " XX  XXXXX  XX "
                                                                            "  XXXXXXXXXXX  "
                                                                            "   `````````   "
                                                                            "               "))
                                                  (build-template-z-4 (list "               "
                                                                            "               "
                                                                            "  ```````````  "
                                                                            " ``XXXXXXXXX`` "
                                                                            " `XX       XX` "
                                                                            " `XX XX XX XX` "
                                                                            " `XX X   X XX` "
                                                                            " `XX       XX` "
                                                                            " `XX X   X XX` "
                                                                            " `XX XX XX XX` "
                                                                            " `XX       XX` "
                                                                            " ``XXXXXXXXX`` "
                                                                            "  ```````````  "
                                                                            "               "
                                                                            "               "))
                                                  (build-template-z-5 (list "               "
                                                                            "               "
                                                                            "               "
                                                                            "   `````````   "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "  ```````````  "
                                                                            "   `````````   "
                                                                            "               "
                                                                            "               "
                                                                            "               "))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              
                                              )
                                            (values nil
                                                    (list (list +feature-start-place-relic+ 7 7 z)
                                                          (list +feature-start-place-demons+ 7 7 z)
                                                          (list +feature-start-place-demons+ 7 5 z)
                                                          (list +feature-start-place-demons+ 7 9 z)
                                                          (list +feature-start-place-demons+ 5 7 z)
                                                          (list +feature-start-place-demons+ 9 7 z)
                                                          (list +feature-start-place-demons+ 4 4 z)
                                                          (list +feature-start-place-demons+ 10 4 z)
                                                          (list +feature-start-place-demons+ 4 10 z)
                                                          (list +feature-start-place-demons+ 10 10 z)
                                                          (list +feature-start-place-demons+ 9 7 z)
                                                          (list +feature-start-place-demons+ 2 2 z)
                                                          (list +feature-start-place-demons+ 12 2 z)
                                                          (list +feature-start-place-demons+ 2 12 z)
                                                          (list +feature-start-place-demons+ 12 12 z))
                                                    nil))))

;;=====================
;; Borders
;;=====================

(set-building-type (make-building :id +building-city-corrupted-forest-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (if (zerop (random 5))
                                              (progn
                                                ;; place a large birch tree
                                                (let ((r (random 4)))
                                                  (cond
                                                    ((= r 3) (level-place-twintube-corrupted-4 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 2) (level-place-twintube-corrupted-3 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 1) (level-place-twintube-corrupted-2 template-level (+ 1 x) (+ 1 y) z))
                                                    (t (level-place-twintube-corrupted-1 template-level (+ 1 x) (+ 1 y) z)))
                                                  )
                                                (values nil nil)
                                                )
                                              (progn
                                                ;; populate the area with trees, leaving the border untouched
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (zerop (random 3))
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+))))
                                                
                                                ;; make sure that each tree has no more than two adjacent trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3
                                                        with tree-num
                                                        do
                                                           (setf tree-num 0)
                                                           (check-surroundings (+ x dx) (+ y dy) nil
                                                                               #'(lambda (x y)
                                                                                   (when (= (aref template-level x y z) +terrain-tree-twintube+)
                                                                                     (incf tree-num))))
                                                           (when (> tree-num 2)
                                                             (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-creep+))))
                                                
                                                ;; place grass around trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-twintube+)
                                                      (check-surroundings (+ x dx) (+ y dy) nil
                                                                          #'(lambda (x y)
                                                                              (if (or (= (aref template-level x y z) +terrain-border-floor+)
                                                                                      (= (aref template-level x y z) +terrain-border-grass+)
                                                                                      (= (aref template-level x y z) +terrain-border-creep+))
                                                                                (setf (aref template-level x y z) +terrain-border-creep+)
                                                                                (setf (aref template-level x y z) +terrain-floor-creep+)))))))
                                                
                                                (values nil
                                                        nil
                                                        nil))))
                                  ))

