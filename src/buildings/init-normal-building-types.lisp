(in-package :cotd)

;;=====================
;; Houses
;;=====================

(set-building-type (make-building :id +building-city-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#-#####,"
                                                                            ",#t..u##,"
                                                                            ",#h....#,"
                                                                            ",####|.#,"
                                                                            ",-ht...#,"
                                                                            ",#....c#,"
                                                                            ",###+###,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ###-### "
                                                                            " #b..d.# "
                                                                            " #c....# "
                                                                            " ####|.# "
                                                                            " #b....# "
                                                                            " #ch..h# "
                                                                            " ###-### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
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
                                            (values (list (list +mob-type-man+ 4 5 z)
                                                          (list +mob-type-woman+ 3 2 (+ z 1))
                                                          (list +mob-type-child+ 5 5 (+ z 1)))
                                                    (list (list +feature-start-gold-small+ 3 2 (+ z 1)))
                                                    nil
                                                    ))))

(set-building-type (make-building :id +building-city-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",#c...t#,"
                                                                            ",#..|.h#,"
                                                                            ",+..#..-,"
                                                                            ",#.u#..#,"
                                                                            ",-.##ht#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ##-#### "
                                                                            " #c...b# "
                                                                            " #..|.c# "
                                                                            " #..#..- "
                                                                            " #.d#..# "
                                                                            " #..#bc# "
                                                                            " ##-#### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
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
                                            (values (list (list +mob-type-man+ 2 3 z)
                                                          (list +mob-type-woman+ 4 2 (+ z 1))
                                                          (list +mob-type-child+ 5 4 (+ z 1)))
                                                    (list (list +feature-start-gold-small+ 4 2 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",##u#ht-,"
                                                                            ",#..#..#,"
                                                                            ",-..#..+,"
                                                                            ",#t.|..#,"
                                                                            ",#h...c#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ####### "
                                                                            " #.d#cb# "
                                                                            " #..#..# "
                                                                            " -..#..- "
                                                                            " #..|.b# "
                                                                            " #c...c# "
                                                                            " ####### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
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
                                            (values (list (list +mob-type-man+ 5 4 z)
                                                          (list +mob-type-woman+ 2 2 (+ z 1))
                                                          (list +mob-type-child+ 2 4 (+ z 1)))
                                                    (list (list +feature-start-gold-small+ 2 2 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",###+###,"
                                                                            ",#c...h#,"
                                                                            ",#....t-,"
                                                                            ",#.|####,"
                                                                            ",#....##,"
                                                                            ",#cb..u#,"
                                                                            ",#####-#,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ####### "
                                                                            " #c...c# "
                                                                            " #....b- "
                                                                            " #.|#### "
                                                                            " #.....# "
                                                                            " -th..d# "
                                                                            " ####### "
                                                                            "         "))

                                                  (build-template-z-4 (list "         "
                                                                            " ....... "
                                                                            " ....... "
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
                                            (values (list (list +mob-type-man+ 4 2 z)
                                                          (list +mob-type-woman+ 2 4 (+ z 1))
                                                          (list +mob-type-child+ 4 5 (+ z 1)))
                                                    (list (list +feature-start-gold-small+ 2 4 (+ z 1)))
                                                    nil))))

;;=====================
;; Townhalls
;;=====================

(set-building-type (make-building :id +building-city-townhall-1+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",####......####,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",##-###..###-##,"
                                                                            ",#|..#c..c#..|#,"
                                                                            ",#...+....+...#,"
                                                                            ",##u.#|..|#.th#,"
                                                                            ",###-##--##-###,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                "
                                                                            " ....      .... "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " ##-###-###.... "
                                                                            " #..|#|...#.... "
                                                                            " #...+....+.... "
                                                                            " #.d.#c.ht#.... "
                                                                            " ###-##-###.... "
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
                                            (values (list (list +mob-type-clerk+ 7 8 (+ z 1))
                                                          (list +mob-type-clerk+ 7 8 z)
                                                          (list +mob-type-clerk+ 12 7 z))
                                                    (list (list +feature-start-gold-small+ 7 8 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-2+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",###-##--##-###,"
                                                                            ",#ht.#|..|#.u##,"
                                                                            ",#...+....+...#,"
                                                                            ",#|..#c..c#..|#,"
                                                                            ",##-###..###-##,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",####......####,"
                                                                            ",,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                "
                                                                            " ....###-##-### "
                                                                            " ....#th.c#.d.# "
                                                                            " ....+....+...# "
                                                                            " ....#...|#|..# "
                                                                            " ....###-###-## "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " ....      .... "
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
                                            (values (list (list +mob-type-clerk+ 3 3 z)
                                                          (list +mob-type-clerk+ 8 3 (+ z 1))
                                                          (list +mob-type-clerk+ 8 2 z))
                                                    (list (list +feature-start-gold-small+ 8 3 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-3+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",#########,"
                                                                            ",##..#```#,"
                                                                            ",#u..-```#,"
                                                                            ",-..|#```#,"
                                                                            ",##+##....,"
                                                                            ",#|.c#....,"
                                                                            ",-........,"
                                                                            ",-........,"
                                                                            ",#|.c#....,"
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
                                                                            " #|.c#     "
                                                                            " -...-     "
                                                                            " #h..#     "
                                                                            " #t..#     "
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
                                                                            " .....     "
                                                                            " .....     "
                                                                            " .....     "
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
                                            (values (list (list +mob-type-clerk+ 2 8 (+ z 1))
                                                          (list +mob-type-clerk+ 2 13 z)
                                                          (list +mob-type-clerk+ 2 8 z))
                                                    (list (list +feature-start-gold-small+ 2 8 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-4+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",#########,"
                                                                            ",#```#|.h#,"
                                                                            ",#```-..t#,"
                                                                            ",#```#...#,"
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
                                                                            " ......... "
                                                                            " .   ..... "
                                                                            " .   ..... "
                                                                            " .   ..... "
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
                                            (values (list (list +mob-type-clerk+ 7 2 z)
                                                          (list +mob-type-clerk+ 7 8 (+ z 1))
                                                          (list +mob-type-clerk+ 7 8 z))
                                                    (list (list +feature-start-gold-small+ 7 8 (+ z 1)))
                                                    nil))))

;;=====================
;; Parks
;;=====================

(set-building-type (make-building :id +building-city-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template (list ",,```,,```"
                                                                        "```T````T`"
                                                                        "`T```T````"
                                                                        "``````T`,,"
                                                                        "``T`````,,"
                                                                        ",````T````"
                                                                        ",`|`````T`"
                                                                        ",`````````"
                                                                        ",,`T``T`,,"
                                                                        ",,``````,,")))
                                              
                                              (translate-build-to-template x y z build-template template-level terrains)
                                              )
                                            (values (list (list +mob-type-man+ 2 1 z)
                                                          (list +mob-type-woman+ 7 4 z))
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template (list ",,```,```,"
                                                                        "```T```T`,"
                                                                        "`T```T````"
                                                                        "```T````|`"
                                                                        "`T````T```"
                                                                        "````T```,,"
                                                                        ",`T```T`,,"
                                                                        ",`````````"
                                                                        ",`T`T`,`T`"
                                                                        ",`````,```")))
                                              
                                              (translate-build-to-template x y z build-template template-level terrains)
                                              )
                                            (values (list (list +mob-type-man+ 4 6 z)
                                                          (list +mob-type-woman+ 4 1 z))
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+))))

                                            ;; make sure that each tree has no more than one adjacent tree
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y z) +terrain-tree-birch+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 1)
                                                         (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt+))))

                                            ;; place a large birch tree
                                            (let ((dx (random 8))
                                                  (dy (random 8))
                                                  (r (random 5)))
                                              (cond
                                                ((= r 4) (level-place-birch-mature-4 template-level (+ dx x) (+ dy y) z))
                                                ((= r 3) (level-place-birch-mature-3 template-level (+ dx x) (+ dy y) z))
                                                ((= r 2) (level-place-birch-mature-2 template-level (+ dx x) (+ dy y) z))
                                                ((= r 2) (level-place-birch-mature-1 template-level (+ dx x) (+ dy y) z))
                                                (t nil))
                                              )
                                            
                                            ;; place grass around trees
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (setf (aref template-level x y z) +terrain-floor-grass+))))))
                                            
                                            ;; find a place to position citizens
                                            (values (loop repeat 2
                                                          collect (loop with rx = (random 10)
                                                                        with ry = (random 10)
                                                                        until (and (not (= (aref template-level (+ x rx) (+ y ry) z) +terrain-tree-birch+))
                                                                                   (not (= (aref template-level (+ x rx) (+ y ry) z) +terrain-tree-birch-trunk+)))
                                                                        finally (return (list +mob-type-man+ rx ry z))
                                                                        do
                                                                           (setf rx (random 10))
                                                                           (setf ry (random 10))
                                                                        ))
                                                    nil
                                                    nil)
                                            
                                            
                                            )))

(set-building-type (make-building :id +building-city-park-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+))))

                                            ;; make sure that each tree has no more than one adjacent tree
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y z) +terrain-tree-birch+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 1)
                                                         (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt+))))

                                            ;; place grass around trees
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (setf (aref template-level x y z) +terrain-floor-grass+))))))

                                            ;; place a large oak tree
                                            (let ((dx (random 7))
                                                  (dy (random 7)))
                                              (cond
                                                (t (level-place-oak-mature-1 template-level (+ dx x) (+ dy y) z)))
                                              )
                                            
                                            ;; find a place to position citizens
                                            (values (loop repeat 2
                                                          collect (loop with rx = (random 10)
                                                                        with ry = (random 10)
                                                                        until (not (get-terrain-type-trait (aref template-level (+ x rx) (+ y ry) z) +terrain-trait-blocks-move+))
                                                                        finally (return (list +mob-type-man+ rx ry z))
                                                                        do
                                                                           (setf rx (random 10))
                                                                           (setf ry (random 10))
                                                                        ))
                                                    nil
                                                    nil)
                                            
                                            
                                            )))

(set-building-type (make-building :id +building-city-park-tiny+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (if (zerop (random 5))
                                              (progn
                                                ;; place a large birch tree
                                                (let ((r (random 4)))
                                                  (cond
                                                    ((= r 3) (level-place-birch-mature-4 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 2) (level-place-birch-mature-3 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 1) (level-place-birch-mature-2 template-level (+ 1 x) (+ 1 y) z))
                                                    (t (level-place-birch-mature-1 template-level (+ 1 x) (+ 1 y) z)))
                                                  )
                                                (values nil nil)
                                                )
                                              (progn
                                                ;; populate the area with trees, leaving the border untouched
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (zerop (random 3))
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+))))
                                                
                                                ;; make sure that each tree has no more than two adjacent trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3
                                                        with tree-num
                                                        do
                                                           (setf tree-num 0)
                                                           (check-surroundings (+ x dx) (+ y dy) nil
                                                                               #'(lambda (x y)
                                                                                   (when (= (aref template-level x y z) +terrain-tree-birch+)
                                                                                     (incf tree-num))))
                                                           (when (> tree-num 2)
                                                             (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt+))))
                                                
                                                ;; place grass around trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+)
                                                      (check-surroundings (+ x dx) (+ y dy) nil
                                                                          #'(lambda (x y)
                                                                              (if (or (= (aref template-level x y z) +terrain-border-floor+)
                                                                                      (= (aref template-level x y z) +terrain-border-grass+))
                                                                                (setf (aref template-level x y z) +terrain-border-grass+)
                                                                                (setf (aref template-level x y z) +terrain-floor-grass+)))))))
                                                
                                                (values nil nil nil))))
                                  ))

;;=====================
;; Prisons
;;=====================

(set-building-type (make-building :id +building-city-prison-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-prison+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,"
                                                                            ",#######.#######,"
                                                                            ",#|....-.#...+.#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#|###.#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#...+.#,"
                                                                            ",#.....-.#####.#,"
                                                                            ",#.....-.......#,"
                                                                            ",#+#####h..#####,"
                                                                            ",#....|###+##u.#,"
                                                                            ",#.............#,"
                                                                            ",#-+#-+#-+#-+#.#,"
                                                                            ",#..#..#..#..#.#,"
                                                                            ",#.b#.b#.b#.b#.#,"
                                                                            ",###############,"
                                                                            ",,,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                 "
                                                                            " ############### "
                                                                            " #     #|...+.b# "
                                                                            " #     #....-..# "
                                                                            " #     -....#### "
                                                                            " #     #h...+.b# "
                                                                            " #     -....-..# "
                                                                            " #     #....#### "
                                                                            " #     #|.....h# "
                                                                            " #-###-####....# "
                                                                            " #.....|.....d.# "
                                                                            " #.............# "
                                                                            " #-+#-+#-+#-+#.# "
                                                                            " #..#..#..#..#.# "
                                                                            " #.b#.b#.b#.b#.# "
                                                                            " ############### "
                                                                            "                 "))

                                                  (build-template-z-4 (list "                 "
                                                                            " ............... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " .     ......... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            "                 ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 7) (+ y 0) z) +terrain-floor-sign-prison+)
                                            
                                            (values (list (list +mob-type-criminal+ 2 14 z)
                                                          (list +mob-type-criminal+ 5 14 z)
                                                          (list +mob-type-criminal+ 8 14 z)
                                                          (list +mob-type-criminal+ 11 14 z)
                                                          (list +mob-type-policeman+ 10 2 z)
                                                          (list +mob-type-policeman+ 10 6 z)
                                                          (list +mob-type-policeman+ 8 9 z)
                                                          (list +mob-type-criminal+ 2 14 (+ z 1))
                                                          (list +mob-type-criminal+ 5 14 (+ z 1))
                                                          (list +mob-type-criminal+ 8 14 (+ z 1))
                                                          (list +mob-type-criminal+ 11 14 (+ z 1))
                                                          (list +mob-type-criminal+ 14 3 (+ z 1))
                                                          (list +mob-type-criminal+ 14 6 (+ z 1))
                                                          (list +mob-type-policeman+ 8 5 (+ z 1))
                                                          (list +mob-type-policeman+ 14 8 (+ z 1)))
                                                    nil
                                                    nil))))

;;=====================
;; Warehouses
;;=====================

(set-building-type (make-building :id +building-city-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-warehouse+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,,"
                                                                            ",##-#####..#####-##,"
                                                                            ",#|..............|#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#..############..#,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",-................-,"
                                                                            ",#..CCCCCCCCCCCC..#,"
                                                                            ",#..############..#,"
                                                                            ",..................,"
                                                                            ",..................,"
                                                                            ",#..############..#,"
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
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
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
                                            (values (list (list +mob-type-man+ 3 3 z)
                                                          (list +mob-type-man+ 16 3 z)
                                                          (list +mob-type-man+ 3 16 z)
                                                          (list +mob-type-man+ 16 16 z))
                                                    nil
                                                    nil))))

;;=====================
;; Libraries
;;=====================

(set-building-type (make-building :id +building-city-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 13) :type +building-type-library+
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
                                                                            ",##-####-###-###-##,"
                                                                            ",#.h.|#..........|#,"
                                                                            ",-.t..+..B..B..B..-,"
                                                                            ",#....#..B..B..B..#,"
                                                                            ",##..##..B..B..B..#,"
                                                                            ",`````-..B..B..B..-,"
                                                                            ",`````#..B..B..B..#,"
                                                                            ",`T```#..B..B..B..#,"
                                                                            ",`````-..B..B..####,"
                                                                            ",,``T`#|.......+.d#,"
                                                                            ",|,```##-###-######,"
                                                                            ",,,,,,,,,,,,,,,,,,,,"
                                                                            ))
                                                  (build-template-z-3 (list "                    "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            " .................. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "      ............. "
                                                                            "                    "
                                                                        )))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 2) (+ y 6) z) +terrain-floor-sign-library+)
                                            
                                            (values nil
                                                    (list (list +feature-start-place-book-of-rituals+ 15 6 (- z 1) 1)
                                                          (list +feature-start-place-civilian-man+ 3 2 z)
                                                          (list +feature-start-place-civilian-woman+ 10 6 z)
                                                          (list +feature-start-place-civilian-woman+ 13 8 z)
                                                          (list +feature-start-place-civilian-woman+ 16 8 z))
                                                    nil))))

;;=====================
;; Port warehouses
;;=====================

(set-building-type (make-building :id +building-city-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
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
                                            (values (list (list +mob-type-man+ 3 3 z)
                                                          (list +mob-type-man+ 6 6 z))
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
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
                                            (values (list (list +mob-type-man+ 3 6 z)
                                                          (list +mob-type-man+ 6 3 z))
                                                    nil
                                                    nil))))

;;=====================
;; Borders
;;=====================

(set-building-type (make-building :id +building-city-normal-forest-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (if (zerop (random 5))
                                              (progn
                                                ;; place a large birch tree
                                                (let ((r (random 4)))
                                                  (cond
                                                    ((= r 3) (level-place-birch-mature-4 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 2) (level-place-birch-mature-3 template-level (+ 1 x) (+ 1 y) z))
                                                    ((= r 1) (level-place-birch-mature-2 template-level (+ 1 x) (+ 1 y) z))
                                                    (t (level-place-birch-mature-1 template-level (+ 1 x) (+ 1 y) z)))
                                                  )
                                                (values nil nil)
                                                )
                                              (progn
                                                ;; populate the area with trees, leaving the border untouched
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (zerop (random 3))
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+))))
                                                
                                                ;; make sure that each tree has no more than two adjacent trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3
                                                        with tree-num
                                                        do
                                                           (setf tree-num 0)
                                                           (check-surroundings (+ x dx) (+ y dy) nil
                                                                               #'(lambda (x y)
                                                                                   (when (= (aref template-level x y z) +terrain-tree-birch+)
                                                                                     (incf tree-num))))
                                                           (when (> tree-num 2)
                                                             (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt+))))
                                                
                                                ;; place grass around trees
                                                (loop for dx from 1 to 3 do
                                                  (loop for dy from 1 to 3 do
                                                    (when (= (aref template-level (+ x dx) (+ y dy) z) +terrain-tree-birch+)
                                                      (check-surroundings (+ x dx) (+ y dy) nil
                                                                          #'(lambda (x y)
                                                                              (if (or (= (aref template-level x y z) +terrain-border-floor+)
                                                                                      (= (aref template-level x y z) +terrain-border-grass+))
                                                                                (setf (aref template-level x y z) +terrain-border-grass+)
                                                                                (setf (aref template-level x y z) +terrain-floor-grass+)))))))
                                                
                                                (values nil
                                                        nil
                                                        nil))))
                                  ))

;;=====================
;; Stables
;;=====================

(set-building-type (make-building :id +building-city-stables-1+ :grid-dim '(3 . 3) :act-dim '(14 . 15) :type +building-type-stables+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####,,#####,"
                                                                            ",-,,,,,,,,,,-,"
                                                                            ",#####--#####,"
                                                                            ",,,,,,,,,,,,,,"
                                                                            ))
                                                  (build-template-z-3 (list "              "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            " ............ "
                                                                            "              "
                                                                            )))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values (list (list +mob-type-horse+ 2 2 z)
                                                          (list +mob-type-horse+ 2 4 z)
                                                          (list +mob-type-horse+ 2 6 z)
                                                          (list +mob-type-horse+ 2 8 z)
                                                          (list +mob-type-horse+ 2 10 z)
                                                          (list +mob-type-horse+ 2 12 z)
                                                          (list +mob-type-horse+ 11 2 z)
                                                          (list +mob-type-horse+ 11 4 z)
                                                          (list +mob-type-horse+ 11 6 z)
                                                          (list +mob-type-horse+ 11 8 z)
                                                          (list +mob-type-horse+ 11 10 z)
                                                          (list +mob-type-horse+ 11 12 z))
                                                    nil
                                                    nil))))

;;=====================
;; Mansions
;;=====================

(set-building-type (make-building :id +building-city-mansion-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-mansion+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,###-#-###-#-###,,"
                                                                            ",,#B..#.|#|.#..c#,,"
                                                                            ",,#B..+..u..+..c-,,"
                                                                            ",,#B..#c...c#..c#,,"
                                                                            ",,##+####-####-##,,"
                                                                            ",,#|..#`````````*,,"
                                                                            ",,#...+`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,##+##**********,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                   "
                                                                            "                   "
                                                                            "  ###-#####-#....  "
                                                                            "  #...#|....#..h.  "
                                                                            "  #ht.+..d..+..t.  "
                                                                            "  #|..#BB.BB#..h.  "
                                                                            "  ##+####-###....  "
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
                                            (values (list (list +mob-type-man+ 4 4 z)
                                                          (list +mob-type-woman+ 9 4 z)
                                                          (list +mob-type-woman+ 14 4 z)
                                                          (list +mob-type-child+ 4 8 (+ z 1))
                                                          (list +mob-type-man+ 5 4 (+ z 1)))
                                                    nil
                                                    (list (list +item-type-coin+ 5 4 (+ z 1) (+ 150 (random 151))))))))

(set-building-type (make-building :id +building-city-mansion-2+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-mansion+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,##+##**********,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#...+`````````*,,"
                                                                            ",,#|..#`````````*,,"
                                                                            ",,##+####-####-##,,"
                                                                            ",,#B..#c...c#..c#,,"
                                                                            ",,#B..+..u..+..c-,,"
                                                                            ",,#B..#.|#|.#..c#,,"
                                                                            ",,###-#-###-#-###,,"
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
                                                                            "  #...#|....#..h.  "
                                                                            "  ###-#####-#....  "
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
                                                                            "  ...........      "
                                                                            "  ...........      "
                                                                            "                   "
                                                                            "                   ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values (list (list +mob-type-man+ 4 9 z)
                                                          (list +mob-type-woman+ 9 9 z)
                                                          (list +mob-type-woman+ 14 9 z)
                                                          (list +mob-type-child+ 4 4 (+ z 1))
                                                          (list +mob-type-man+ 5 9 (+ z 1)))
                                                    nil
                                                    (list (list +item-type-coin+ 5 9 (+ z 1) (+ 100 (random 101))))))))

;;=====================
;; Banks
;;=====================

(set-building-type (make-building :id +building-city-bank-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-bank+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "000000000000000"
                                                                            "000000000000000"
                                                                            "00###########00"
                                                                            "00#h....h#u.#00"
                                                                            "00#.........#00"
                                                                            "00##+##|##|##00"
                                                                            "00##.########00"
                                                                            "00##+##|##|##00"
                                                                            "00#.........#00"
                                                                            "00#.........#00"
                                                                            "00###########00"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"))
                                                  
                                                  (build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,###########,,"
                                                                            ",,#|......d##,,"
                                                                            ",,#........|#,,"
                                                                            ",,#+##+###+##,,"
                                                                            ",,#.#...#...#,,"
                                                                            ",,#.#.h.#.h.#,,"
                                                                            ",,#+#|t##|t##,,"
                                                                            ",,#.........-,,"
                                                                            ",,-....hhhhh#,,"
                                                                            ",,##++##-####,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "               "
                                                                            "               "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
                                                                            "  ...........  "
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

                                            (values (list (list +mob-type-clerk+ 6 7 z)
                                                          (list +mob-type-clerk+ 10 7 z)
                                                          
                                                          (list +mob-type-policeman+ 3 3 (- z 1))
                                                          (list +mob-type-policeman+ 8 3 (- z 1)))
                                                    nil
                                                    (list (list +item-type-coin+ 3 9 (- z 1) (+ 50 (random 251)))
                                                          
                                                          (list +item-type-coin+ 5 9 (- z 1) (+ 50 (random 251)))
                                                          
                                                          (list +item-type-coin+ 7 9 (- z 1) (+ 50 (random 251)))
                                                          
                                                          (list +item-type-coin+ 9 9 (- z 1) (+ 50 (random 251)))
                                                          
                                                          (list +item-type-coin+ 11 9 (- z 1) (+ 50 (random 251)))
                                                          
                                                          )))))

;;=====================
;; Graveyards
;;=====================

(set-building-type (make-building :id +building-city-graveyard-1+ :grid-dim '(4 . 4) :act-dim '(16 . 16) :type +building-type-graveyard+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",*****,,,,*****,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",*,G,,G,,G,,G,*,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",,,G,,G,,G,,G,,,"
                                                                            ",,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,"
                                                                            ",,,G,,G,,G,,G,,,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",*,G,,G,,G,,G,*,"
                                                                            ",*,,,,,,,,,,,,*,"
                                                                            ",*****,,,,*****,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))
