(in-package :cotd)

;;=====================
;; Runied houses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil
                                                    ))))

(set-building-type (make-building :id +building-city-corrupted-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-corrupted-house+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined townhalls
;;=====================

(set-building-type (make-building :id +building-city-corrupted-townhall-1+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-2+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-3+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-townhall-4+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-corrupted-townhall+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined parks
;;=====================

(set-building-type (make-building :id +building-city-corrupted-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level)
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
                                              
                                              (translate-build-to-corrupted-template x y z build-template template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


(set-building-type (make-building :id +building-city-corrupted-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level)
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
                                              
                                              (translate-build-to-corrupted-template x y z build-template template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-park+
                                  :func #'(lambda (x y z template-level)
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
                                                ((= r 2) (level-place-twintube-corrupted-1 template-level (+ dx x) (+ dy y) z))
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
                                  :func #'(lambda (x y z template-level)
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
                                  :func #'(lambda (x y z template-level)
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
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )

                                            (setf (aref template-level (+ x 7) (+ y 0) z) +terrain-floor-sign-prison+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined warehouses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-corrupted-warehouse+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined libraries
;;=====================

(set-building-type (make-building :id +building-city-corrupted-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 13) :type +building-type-corrupted-library+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              )

                                            (setf (aref template-level (+ x 2) (+ y 6) z) +terrain-floor-sign-library+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined port warehouses
;;=====================

(set-building-type (make-building :id +building-city-corrupted-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined mansions
;;=====================

(set-building-type (make-building :id +building-city-corrupted-mansion-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-mansion+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-mansion-2+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-mansion+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


;;=====================
;; Ruined banks
;;=====================

(set-building-type (make-building :id +building-city-corrupted-bank-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-corrupted-bank+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z -1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            
                                            (setf (aref template-level (+ x 6) (+ y 12) z) +terrain-floor-sign-bank+)

                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Sigil posts
;;=====================

(set-building-type (make-building :id +building-city-corrupted-sigil-post+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",uuuuuuu,"
                                                                            ",u00000u,"
                                                                            ",u00000u,"
                                                                            ",u00000u,"
                                                                            ",u00000u,"
                                                                            ",u00000u,"
                                                                            ",uuuuuuu,"
                                                                            ",,,,,,,,,"
                                                                            ))
                                                  (build-template-z-3 (list "         "
                                                                            " ddddddd "
                                                                            " d,,,,,d "
                                                                            " d,,,,,d "
                                                                            " d,,.,,d "
                                                                            " d,,,,,d "
                                                                            " d,,,,,d "
                                                                            " ddddddd "
                                                                            "         "
                                                                            ))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    (list (list +feature-start-sigil-point+ 4 4 (+ z 1)))
                                                    nil))))


;;=====================
;; Graveyards
;;=====================

(set-building-type (make-building :id +building-city-corrupted-graveyard-1+ :grid-dim '(4 . 4) :act-dim '(16 . 16) :type +building-type-corrupted-graveyard+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Lakes
;;=====================

(set-building-type (make-building :id +building-city-corrupted-lake-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-lake+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",```````,,"
                                                                            "`` `   ``,"
                                                                            "`       `,"
                                                                            "`      ``,"
                                                                            "``     ``,"
                                                                            "``      ``"
                                                                            "`        `"
                                                                            "`        `"
                                                                            "```     ``"
                                                                            ",,```````,"))
                                                  
                                                  (build-template-z-1 (list "0000000000"
                                                                            "00_0___000"
                                                                            "0_______00"
                                                                            "0______000"
                                                                            "00_____000"
                                                                            "00______00"
                                                                            "0________0"
                                                                            "0________0"
                                                                            "000_____00"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-0 (list "0000000000"
                                                                            "0000000000"
                                                                            "000___0000"
                                                                            "00_____000"
                                                                            "00_____000"
                                                                            "00______00"
                                                                            "00______00"
                                                                            "00p_____00"
                                                                            "0000___000"
                                                                            "0000000000")))
                                              ;; we assume that z is always 2
                                              (translate-build-to-corrupted-template x y (- z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-template x y (- z 2) build-template-z-0 template-level)
                                              )
                                            (values nil nil nil))))

(set-building-type (make-building :id +building-city-corrupted-lake-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-lake+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",````````,"
                                                                            "``   `  ``"
                                                                            "`        `"
                                                                            "`       ``"
                                                                            "`      ```"
                                                                            "``     `T`"
                                                                            ",`     ```"
                                                                            ",`      `,"
                                                                            ",``  `  `,"
                                                                            ",,```````,"))

                                                  (build-template-z-1 (list "0000000000"
                                                                            "00___0__00"
                                                                            "0________0"
                                                                            "0_______00"
                                                                            "0______000"
                                                                            "00_____000"
                                                                            "00_____000"
                                                                            "00______00"
                                                                            "000__0__00"
                                                                            "0000000000"))

                                                  (build-template-z-0 (list "0000000000"
                                                                            "0000000000"
                                                                            "000___0000"
                                                                            "00_____000"
                                                                            "00_____000"
                                                                            "00_____000"
                                                                            "00_____000"
                                                                            "000___0000"
                                                                            "0000000000"
                                                                            "0000000000")))
                                              ;; we assume that z is always 2
                                              (translate-build-to-corrupted-template x y (- z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-template x y (- z 2) build-template-z-0 template-level)
                                              )
                                            (values nil nil nil))))

(set-building-type (make-building :id +building-city-corrupted-central-lake+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list "`````          `````"
                                                                            "``               ```"
                                                                            "`                 ``"
                                                                            "`                  `"
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "                    "
                                                                            "`                  `"
                                                                            "`                 ``"
                                                                            "`                  `"
                                                                            "``                ``"
                                                                            "`````            ```"))
                                                  
                                                  (build-template-z-1 (list "00000__________00000"
                                                                            "00_______________000"
                                                                            "0_________________00"
                                                                            "0__________________0"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "0__________________0"
                                                                            "0_________________00"
                                                                            "0__________________0"
                                                                            "00________________00"
                                                                            "00000____________000"))

                                                  (build-template-z-0 (list "000000________000000"
                                                                            "00000__________00000"
                                                                            "0000_____________000"
                                                                            "00________________00"
                                                                            "00_________________0"
                                                                            "0___________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "____________________"
                                                                            "0__________________0"
                                                                            "00________________00"
                                                                            "00_______________000"
                                                                            "000_____________0000"
                                                                            "00000__________00000"
                                                                            "000000________000000")))
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-template x y (- z 2) build-template-z-0 template-level)
                                              )

                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Army posts
;;=====================

(set-building-type (make-building :id +building-city-army-post-corrupted+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",,,,,,,,,,"
                                                                            ",,##,,##,,"
                                                                            ",,#,,,,#,,"
                                                                            ",,,,,|,,,,"
                                                                            ",,,,,,,,,,"
                                                                            ",,#,,,,#,,"
                                                                            ",,##,,##,,"
                                                                            ",,,,,,,,,,"
                                                                            ",,,,,,,,,,"))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-template x y (+ z 0) build-template-z-2 template-level)
                                              (setf (aref template-level (+ x 2) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y 3) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 6) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 7) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 7) (+ y 3) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y 6) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y 7) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y 7) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 6) (+ y 7) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 7) (+ y 7) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 7) (+ y 6) z) +terrain-wall-barricade+)
                                              )
                                            (values nil
                                                    (list (list +feature-start-repel-demons+ 5 5 z)
                                                          (list +feature-start-military-point+ 5 5 z))
                                                    nil))))

;;=====================
;; Corrupted shrine
;;=====================

(set-building-type (make-building :id +building-city-corrupted-shrine-1+ :grid-dim '(3 . 3) :act-dim '(15 . 15) :type +building-type-corrupted-shrine+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,#########,,,"
                                                                            ",,*,,,,,,,,,*,,"
                                                                            ",#,,,#####,,,#,"
                                                                            ",#,,*,,,,,*,,#,"
                                                                            ",#,#,##,##,#,#,"
                                                                            ",#,#,#,,,#,#,#,"
                                                                            ",#,#,,,.,,,#,#,"
                                                                            ",#,#,#,,,#,#,#,"
                                                                            ",#,#,##,##,#,#,"
                                                                            ",#,,*,,,,,*,,#,"
                                                                            ",#,,,#####,,,#,"
                                                                            ",,*,,,,,,,,,*,,"
                                                                            ",,,#########,,,"
                                                                            ",,,,,,,,,,,,,,,"))
                                                  (build-template-z-3 (list "               "
                                                                            "   .........   "
                                                                            "  ###########  "
                                                                            " ##  #####  ## "
                                                                            " #           # "
                                                                            " # # ## ## # # "
                                                                            " # # #   # # # "
                                                                            " # #       # # "
                                                                            " # # #   # # # "
                                                                            " # # ## ## # # "
                                                                            " #           # "
                                                                            " ##  #####  ## "
                                                                            "  ###########  "
                                                                            "   .........   "
                                                                            "               "))
                                                  (build-template-z-4 (list "               "
                                                                            "               "
                                                                            "  ...........  "
                                                                            " ..#########.. "
                                                                            " .##       ##. "
                                                                            " .## ## ## ##. "
                                                                            " .## #   # ##. "
                                                                            " .##       ##. "
                                                                            " .## #   # ##. "
                                                                            " .## ## ## ##. "
                                                                            " .##       ##. "
                                                                            " ..#########.. "
                                                                            "  ...........  "
                                                                            "               "
                                                                            "               "))
                                                  (build-template-z-5 (list "               "
                                                                            "               "
                                                                            "               "
                                                                            "   .........   "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "   .........   "
                                                                            "               "
                                                                            "               "
                                                                            "               "))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-step-2-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (+ z 2) build-template-z-4 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (+ z 3) build-template-z-5 template-level)
                                              
                                              )
                                            (values nil
                                                    (list (list +feature-start-place-church-relic+ 7 7 z)
                                                          (list +feature-start-demon-point+ 7 7 z)
                                                          (list +feature-start-demon-point+ 7 5 z)
                                                          (list +feature-start-demon-point+ 7 9 z)
                                                          (list +feature-start-demon-point+ 5 7 z)
                                                          (list +feature-start-demon-point+ 9 7 z)
                                                          (list +feature-start-demon-point+ 4 4 z)
                                                          (list +feature-start-demon-point+ 10 4 z)
                                                          (list +feature-start-demon-point+ 4 10 z)
                                                          (list +feature-start-demon-point+ 10 10 z)
                                                          (list +feature-start-demon-point+ 9 7 z)
                                                          (list +feature-start-demon-point+ 2 2 z)
                                                          (list +feature-start-demon-point+ 12 2 z)
                                                          (list +feature-start-demon-point+ 2 12 z)
                                                          (list +feature-start-demon-point+ 12 12 z))
                                                    nil))))

;;=====================
;; Borders
;;=====================

(set-building-type (make-building :id +building-city-corrupted-forest-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
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
                                                        (list (list +feature-delayed-arrival-point+ 2 2 z))
                                                        nil))))
                                  ))

;;=====================
;; Craters
;;=====================

(set-building-type (make-building :id +building-city-corrupted-crater-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-corrupted-crater+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",,dddddd,,"
                                                                            ",dd    dd,"
                                                                            ",d      d,"
                                                                            ",d      d,"
                                                                            ",d      d,"
                                                                            ",d      d,"
                                                                            ",dd    dd,"
                                                                            ",,dddddd,,"
                                                                            ",,,,,,,,,,"))
                                                  
                                                  (build-template-z-1 (list "0000000000"
                                                                            "00uuuuuu00"
                                                                            "0uudddduu0"
                                                                            "0udd  ddu0"
                                                                            "0ud    du0"
                                                                            "0ud    du0"
                                                                            "0udd  ddu0"
                                                                            "0uudddduu0"
                                                                            "00uuuuuu00"
                                                                            "0000000000"))

                                                  (build-template-z-0 (list "0000000000"
                                                                            "0000000000"
                                                                            "000uuuu000"
                                                                            "00uu,,uu00"
                                                                            "00u,,,,u00"
                                                                            "00u,,,,u00"
                                                                            "00uu,,uu00"
                                                                            "000uuuu000"
                                                                            "0000000000"
                                                                            "0000000000"))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-step-2-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (- z 2) build-template-z-0 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-crater-2+ :grid-dim '(2 . 2) :act-dim '(8 . 8) :type +building-type-corrupted-crater+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,"
                                                                            ",,dddd,,"
                                                                            ",dd  dd,"
                                                                            ",d    d,"
                                                                            ",d    d,"
                                                                            ",dd  dd,"
                                                                            ",,dddd,,"
                                                                            ",,,,,,,,"))

                                                  (build-template-z-1 (list "00000000"
                                                                            "00uuuu00"
                                                                            "0uu,,uu0"
                                                                            "0u,,,,u0"
                                                                            "0u,,,,u0"
                                                                            "0uu,,uu0"
                                                                            "00uuuu00"
                                                                            "00000000"))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-step-2-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (- z 1) build-template-z-1 template-level)
                                              
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-corrupted-crater-large+ :grid-dim '(3 . 3) :act-dim '(15 . 15) :type +building-type-corrupted-crater-large+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-3 (list "               "
                                                                            "   ddddddddd   "
                                                                            "  dd,,,,,,,dd  "
                                                                            " dd,,ddddd,,dd "
                                                                            " d,,dd   dd,,d "
                                                                            " d,dd     dd,d "
                                                                            " d,d       d,d "
                                                                            " d,d       d,d "
                                                                            " d,d       d,d "
                                                                            " d,dd     dd,d "
                                                                            " d,,dd   dd,,d "
                                                                            " dd,,ddddd,,dd "
                                                                            "  dd,,,,,,,dd  "
                                                                            "   ddddddddd   "
                                                                            "               "))
                                                  
                                                  (build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,uuuuuuuuu,,,"
                                                                            ",,uu0000000uu,,"
                                                                            ",uu00uuuuu00uu,"
                                                                            ",u00uuddduu00u,"
                                                                            ",u0uudd dduu0u,"
                                                                            ",u0udd   ddu0u,"
                                                                            ",u0ud     du0u,"
                                                                            ",u0udd   ddu0u,"
                                                                            ",u0uudd dduu0u,"
                                                                            ",u00uuddduu00u,"
                                                                            ",uu00uuuuu00uu,"
                                                                            ",,uu0000000uu,,"
                                                                            ",,,uuuuuuuuu,,,"
                                                                            ",,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-1 (list "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000uuu000000"
                                                                            "00000uu,uu00000"
                                                                            "0000uu,,,uu0000"
                                                                            "0000u,,,,,u0000"
                                                                            "0000uu,,,uu0000"
                                                                            "00000uu,uu00000"
                                                                            "000000uuu000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"))

                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-corrupted-step-2-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-corrupted-step-2-template x y (- z 1) build-template-z-1 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))
