(in-package :cotd)

(set-building-type (make-building :id +building-city-free+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))
(set-building-type (make-building :id +building-city-reserved+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))
(set-building-type (make-building :id +building-city-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#-#####,"
                                                                            ",#t..u##,"
                                                                            ",#h....#,"
                                                                            ",#####.#,"
                                                                            ",-ht...#,"
                                                                            ",#....c#,"
                                                                            ",###.###,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ###-### "
                                                                            " #b..d.# "
                                                                            " #c....# "
                                                                            " #####.# "
                                                                            " #b....# "
                                                                            " #c...h# "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 5 z)
                                                          (list +mob-type-woman+ 3 2 (+ z 1))
                                                          (list +mob-type-child+ 5 5 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",#c...t#,"
                                                                            ",#..#.h#,"
                                                                            ",...#..-,"
                                                                            ",#.u#..#,"
                                                                            ",-.##ht#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ##-#### "
                                                                            " #c...b# "
                                                                            " #..#.c# "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 3 z)
                                                          (list +mob-type-woman+ 4 2 (+ z 1))
                                                          (list +mob-type-child+ 5 4 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",##u#ht-,"
                                                                            ",#..#..#,"
                                                                            ",-..#...,"
                                                                            ",#t.#..#,"
                                                                            ",#h...c#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ####### "
                                                                            " #.d#cb# "
                                                                            " #..#..# "
                                                                            " -..#..- "
                                                                            " #..#.b# "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 5 4 z)
                                                          (list +mob-type-woman+ 2 2 (+ z 1))
                                                          (list +mob-type-child+ 2 4 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,"
                                                                            ",###.###,"
                                                                            ",#c...h#,"
                                                                            ",#....t-,"
                                                                            ",#.#####,"
                                                                            ",#....##,"
                                                                            ",#cb..u#,"
                                                                            ",#####-#,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ####### "
                                                                            " #c...c# "
                                                                            " #....b- "
                                                                            " #.##### "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 2 z)
                                                          (list +mob-type-woman+ 2 4 (+ z 1))
                                                          (list +mob-type-child+ 4 5 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-1+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",####......####,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",##-###..###-##,"
                                                                            ",#...#c..c#...#,"
                                                                            ",#............#,"
                                                                            ",##u.#....#.th#,"
                                                                            ",###-##--##-###,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                "
                                                                            " ....      .... "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " ##-###-###.... "
                                                                            " #...#....#.... "
                                                                            " #............. "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 7 8 (+ z 1))
                                                          (list +mob-type-clerk+ 7 8 z)
                                                          (list +mob-type-clerk+ 12 7 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-2+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",###-##--##-###,"
                                                                            ",#ht.#....#.u##,"
                                                                            ",#............#,"
                                                                            ",#...#c..c#...#,"
                                                                            ",##-###..###-##,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",####......####,"
                                                                            ",,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                "
                                                                            " ....###-##-### "
                                                                            " ....#th.c#.d.# "
                                                                            " .............# "
                                                                            " ....#....#...# "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 3 3 z)
                                                          (list +mob-type-clerk+ 8 3 (+ z 1))
                                                          (list +mob-type-clerk+ 8 2 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-3+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",#########,"
                                                                            ",##..#```#,"
                                                                            ",#u..-```#,"
                                                                            ",-...#```#,"
                                                                            ",##.##....,"
                                                                            ",#..c#....,"
                                                                            ",-........,"
                                                                            ",-........,"
                                                                            ",#..c#....,"
                                                                            ",##.##....,"
                                                                            ",-...#```#,"
                                                                            ",#t..-```#,"
                                                                            ",#h..#```#,"
                                                                            ",#########,"
                                                                            ",,,,,,,,,,,"))

                                                  (build-template-z-3 (list "           "
                                                                            " #####.... "
                                                                            " #...#   . "
                                                                            " #d..-   . "
                                                                            " -...#   . "
                                                                            " ##.##     "
                                                                            " #..c#     "
                                                                            " -...-     "
                                                                            " #h..#     "
                                                                            " #t..#     "
                                                                            " ##.##     "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 2 8 (+ z 1))
                                                          (list +mob-type-clerk+ 2 13 z)
                                                          (list +mob-type-clerk+ 2 8 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-4+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,"
                                                                            ",#########,"
                                                                            ",#```#..h#,"
                                                                            ",#```-..t#,"
                                                                            ",#```#...#,"
                                                                            ",....##.##,"
                                                                            ",....#c..#,"
                                                                            ",........-,"
                                                                            ",........-,"
                                                                            ",....#c..#,"
                                                                            ",....##.##,"
                                                                            ",#```#...-,"
                                                                            ",#```-..u#,"
                                                                            ",#```#..##,"
                                                                            ",#########,"
                                                                            ",,,,,,,,,,,"))

                                                  (build-template-z-3 (list "           "
                                                                            " ......... "
                                                                            " .   ..... "
                                                                            " .   ..... "
                                                                            " .   ..... "
                                                                            "     ##.## "
                                                                            "     #..t# "
                                                                            "     #..h# "
                                                                            "     -...- "
                                                                            "     #..c# "
                                                                            "     ##.## "
                                                                            " .   #...- "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 7 2 z)
                                                          (list +mob-type-clerk+ 7 8 (+ z 1))
                                                          (list +mob-type-clerk+ 7 8 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template (list ",,```,,```"
                                                                        "```T````T`"
                                                                        "`T```T````"
                                                                        "``````T`,,"
                                                                        "``T`````,,"
                                                                        ",````T````"
                                                                        ",`T`````T`"
                                                                        ",`````````"
                                                                        ",,`T``T`,,"
                                                                        ",,``````,,")))
                                              
                                              (translate-build-to-template x y z build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 1 z)
                                                          (list +mob-type-woman+ 7 4 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template (list ",,```,```,"
                                                                        "```T```T`,"
                                                                        "`T```T````"
                                                                        "```T````T`"
                                                                        "`T````T```"
                                                                        "````T```,,"
                                                                        ",`T```T`,,"
                                                                        ",`````````"
                                                                        ",`T`T`,`T`"
                                                                        ",`````,```")))
                                              
                                              (translate-build-to-template x y z build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 6 z)
                                                          (list +mob-type-woman+ 4 1 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y z template-level)
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
                                            
                                            ;; find a place to position citizens
                                            (values (loop repeat 2
                                                          collect (loop with rx = (random 10)
                                                                        with ry = (random 10)
                                                                        until (not (= (aref template-level (+ x rx) (+ y ry) z) +terrain-tree-birch+))
                                                                        finally (return (list +mob-type-man+ rx ry z))
                                                                        do
                                                                           (setf rx (random 10))
                                                                           (setf ry (random 10))
                                                                        ))
                                                    nil)
                                            
                                            
                                            )))

(set-building-type (make-building :id +building-city-park-tiny+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
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
                                                                          (if (= (aref template-level x y z) +terrain-border-floor+)
                                                                            (setf (aref template-level x y z) +terrain-border-grass+)
                                                                            (setf (aref template-level x y z) +terrain-floor-grass+)))))))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-lake-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",```````,,"
                                                                            "``_`___``,"
                                                                            "`_______`,"
                                                                            "`______``,"
                                                                            "``_____``,"
                                                                            "``______``"
                                                                            "`________`"
                                                                            "`________`"
                                                                            "```_____``"
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
                                              (translate-build-to-template x y (- z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level)
                                              )
                                            (values nil nil))))

(set-building-type (make-building :id +building-city-lake-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",````````,"
                                                                            "``___`__``"
                                                                            "`________`"
                                                                            "`_______``"
                                                                            "`______```"
                                                                            "``_____`T`"
                                                                            ",`_____```"
                                                                            ",`______`,"
                                                                            ",``__`__`,"
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
                                              (translate-build-to-template x y (- z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level)
                                              )
                                            (values nil nil))))

(set-building-type (make-building :id +building-city-prison-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-prison+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,"
                                                                            ",#######.#######,"
                                                                            ",#.....-.#.....#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#####.#,"
                                                                            ",#.....-.#htc-.#,"
                                                                            ",#.....-.#.....#,"
                                                                            ",#.....-.#####.#,"
                                                                            ",#.....-.......#,"
                                                                            ",#.#####h..#####,"
                                                                            ",#.....###.##u.#,"
                                                                            ",#.............#,"
                                                                            ",#-.#-.#-.#-.#.#,"
                                                                            ",#..#..#..#..#.#,"
                                                                            ",#.b#.b#.b#.b#.#,"
                                                                            ",###############,"
                                                                            ",,,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                 "
                                                                            " ############### "
                                                                            " #     #......b# "
                                                                            " #     #....-..# "
                                                                            " #     -....#### "
                                                                            " #     #......b# "
                                                                            " #     #....-..# "
                                                                            " #     -....#### "
                                                                            " #     #h.....h# "
                                                                            " #-###-####....# "
                                                                            " #...........d.# "
                                                                            " #.............# "
                                                                            " #-.#-.#-.#-.#.# "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
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
                                                          (list +mob-type-policeman+ 8 8 (+ z 1))
                                                          (list +mob-type-policeman+ 14 8 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-church-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-church+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list "```,,,,,,,,,,```,"
                                                                            "`T````#####```T`,"
                                                                            "`````##...##````,"
                                                                            ",##-##.....##-##,"
                                                                            ",#.............#,"
                                                                            ",-.............-,"
                                                                            ",#...hhh.hhh...#,"
                                                                            ",##-#.......#-##,"
                                                                            "````-hhh.hhh-```,"
                                                                            "`T``#.......#````"
                                                                            "````#hhh.hhh#``T`"
                                                                            ",```-.......-````"
                                                                            ",####hhh.hhh####,"
                                                                            ",-ch#.......#hc-,"
                                                                            ",#.............#,"
                                                                            ",##-#-#.#.#-#-##,"
                                                                            ",,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                 "
                                                                            "      #####      "
                                                                            "     ##   ##     "
                                                                            " #####     ##### "
                                                                            " #             # "
                                                                            " -             - "
                                                                            " #             # "
                                                                            " ##-#       #-## "
                                                                            "    -       -    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    -       -    "
                                                                            " ####       #### "
                                                                            " #  #       #  # "
                                                                            " #  #       #  # "
                                                                            " ####-#####-#### "
                                                                            "                 "))

                                                  (build-template-z-4 (list "                 "
                                                                            "      .....      "
                                                                            "     ..###..     "
                                                                            " .....## ##..... "
                                                                            " .#####   #####. "
                                                                            " .#           #. "
                                                                            " .####     ####. "
                                                                            " ....#     #.... "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            " ....#     #.... "
                                                                            " ....#     #.... "
                                                                            " ....#     #.... "
                                                                            " ....#######.... "
                                                                            "                 "))

                                                  (build-template-z-5 (list "                 "
                                                                            "                 "
                                                                            "       ...       "
                                                                            "      .....      "
                                                                            "  .............  "
                                                                            "  .............  "
                                                                            "  .............  "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "                 ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level)
                                              )
                                            (values (list (list +mob-type-priest+ 8 2 z)
                                                          (list +mob-type-priest+ 3 4 z)
                                                          (list +mob-type-priest+ 12 4 z)
                                                          (list +mob-type-man+ 6 7 z)
                                                          (list +mob-type-woman+ 10 7 z)
                                                          (list +mob-type-man+ 10 11 z)
                                                          (list +mob-type-woman+ 6 11 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-warehouse+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,,"
                                                                            ",##-#####..#####-##,"
                                                                            ",#................#,"
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
                                                                            ",#................#,"
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 2 z)
                                                          (list +mob-type-man+ 17 2 z)
                                                          (list +mob-type-man+ 2 17 z)
                                                          (list +mob-type-man+ 17 17 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 13) :type +building-type-library+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,,"
                                                                            ",##-####-###-###-##,"
                                                                            ",#.h..#...........#,"
                                                                            ",-.t.....B..B..B..-,"
                                                                            ",#....#..B..B..B..#,"
                                                                            ",##..##..B..B..B..#,"
                                                                            ",`````-..B..B..B..-,"
                                                                            ",`````#..B..B..B..#,"
                                                                            ",`T```#..B..B..B..#,"
                                                                            ",`````-..B..B..B..-,"
                                                                            ",,``T`#...........#,"
                                                                            ",,,```##-###-###-##,"
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 3 2 z)
                                                          (list +mob-type-woman+ 10 6 z)
                                                          (list +mob-type-woman+ 13 8 z)
                                                          (list +mob-type-woman+ 16 10 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-satan-lair-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-satanists+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,"
                                                                            ",##-##-##-##..##,"
                                                                            ",#bh#bh#bh#....#,"
                                                                            ",-t.#t.#t.#....-,"
                                                                            ",##.##.##.#....#,"
                                                                            ",-.............-,"
                                                                            ",#.###########.#,"
                                                                            ",#.###########.#,"
                                                                            ",#.#####.#####.#,"
                                                                            ",#.####...####.#,"
                                                                            ",#.##.......##.#,"
                                                                            ",#.####...####.#,"
                                                                            ",#.#####.#####.#,"
                                                                            ",#.#####.#####.#,"
                                                                            ",#.............#,"
                                                                            ",###############,"
                                                                            ",,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                 "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            " ............... "
                                                                            "                 ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values (list (list +mob-type-satanist+ 3 2 z)
                                                          (list +mob-type-satanist+ 6 2 z)
                                                          (list +mob-type-satanist+ 9 2 z)
                                                          (list +mob-type-satanist+ 8 10 z))
                                                    (list (list +feature-blood-stain+ 8 10 z)
                                                          (list +feature-blood-stain+ 8 8 z)
                                                          (list +feature-blood-stain+ 6 10 z)
                                                          (list +feature-blood-fresh+ 8 7 z)
                                                          (list +feature-blood-fresh+ 9 7 z)
                                                          (list +feature-blood-old+ 7 7 z)
                                                          (list +feature-blood-old+ 7 8 z)
                                                          (list +feature-blood-fresh+ 6 9 z)
                                                          (list +feature-blood-fresh+ 9 8 z)
                                                          (list +feature-blood-fresh+ 6 8 z)
                                                          (list +feature-blood-stain+ 10 10 z)
                                                          (list +feature-blood-old+ 9 10 z)
                                                          (list +feature-blood-fresh+ 7 10 z)
                                                          (list +feature-blood-old+ 8 11 z)
                                                          (list +feature-blood-fresh+ 8 9 z)
                                                          (list +feature-blood-old+ 9 11 z)
                                                          (list +feature-blood-old+ 7 11 z)
                                                          (list +feature-blood-fresh+ 9 9 z)
                                                          (list +feature-blood-old+ 7 9 z)
                                                          (list +feature-blood-fresh+ 5 10 z)
                                                          (list +feature-blood-old+ 11 10 z)
                                                          (list +feature-blood-old+ 12 10 z)
                                                          (list +feature-blood-fresh+ 11 11 z)
                                                          (list +feature-blood-fresh+ 11 9 z)
                                                          (list +feature-blood-fresh+ 10 9 z)
                                                          (list +feature-blood-old+ 10 11 z)
                                                          (list +feature-blood-old+ 4 10 z)
                                                          (list +feature-blood-fresh+ 5 9 z)
                                                          (list +feature-blood-fresh+ 6 9 z)
                                                          (list +feature-blood-fresh+ 6 11 z)
                                                          (list +feature-blood-old+ 5 9 z)
                                                          (list +feature-blood-fresh+ 8 12 z)
                                                          (list +feature-blood-fresh+ 7 12 z)
                                                          (list +feature-blood-fresh+ 9 12 z)
                                                          (list +feature-blood-old+ 9 13 z))))))

(set-building-type (make-building :id +building-city-river+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-water-river+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-river+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-river+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-bridge+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-bridge+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-river+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-river+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-pier+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-pier+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-sea+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-sea+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-sea+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-water-sea+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-sea+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-sea+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",########,"
                                                                            ",#CCCCCC#,"
                                                                            ",.......,"
                                                                            ",#.CCCC.#,"
                                                                            ",#.CCCC.#,"
                                                                            ",........,"
                                                                            ",#CCCCCC#,"
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
                                            (values (list (list +mob-type-man+ 3 3 z)
                                                          (list +mob-type-man+ 6 6 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,"
                                                                            ",##.##.##,"
                                                                            ",#C....C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C.CC.C#,"
                                                                            ",#C....C#,"
                                                                            ",##.##.##,"
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
                                            (values (list (list +mob-type-man+ 3 6 z)
                                                          (list +mob-type-man+ 6 3 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-island-ground-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            ;; randomly place the ground and sea tiles 
                                            (loop for dx from 0 to 4 do
                                              (loop for dy from 0 to 4 do
                                                (if (zerop (random 2))
                                                  (progn
                                                    (if (zerop (random 4))
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt-bright+)
                                                      (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-floor-dirt+)))
                                                  (progn
                                                    (setf (aref template-level (+ x dx) (+ y dy) z) +terrain-water-sea+)))))

                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-ns+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dy from 0 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-we+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dx from 0 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-se+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-sw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-nw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-ne+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level)
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-stables-1+ :grid-dim '(3 . 3) :act-dim '(14 . 15) :type +building-type-stables+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
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
                                                    nil))))

(set-building-type (make-building :id +building-city-mansion-1+ :grid-dim '(4 . 3) :act-dim '(18 . 14) :type +building-type-mansion+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,###-#-###-#-###,,"
                                                                            ",,#B..#.c#c.#..c#,,"
                                                                            ",,#B.....u.....c-,,"
                                                                            ",,#B..#c...c#..c#,,"
                                                                            ",,##.####-####-##,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#....`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,##.##**********,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                   "
                                                                            "                   "
                                                                            "  ###-#-###-#....  "
                                                                            "  #...#.....#..h.  "
                                                                            "  #ht....d.....t.  "
                                                                            "  #...#BB.BB#..h.  "
                                                                            "  ##.####-###....  "
                                                                            "  #c..#            "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 4 z)
                                                          (list +mob-type-woman+ 9 4 z)
                                                          (list +mob-type-woman+ 14 4 z)
                                                          (list +mob-type-child+ 4 8 (+ z 1))
                                                          (list +mob-type-man+ 5 4 (+ z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-mansion-2+ :grid-dim '(4 . 3) :act-dim '(18 . 14) :type +building-type-mansion+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,##.##**********,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,#....`````````*,,"
                                                                            ",,#...#`````````*,,"
                                                                            ",,##.####-####-##,,"
                                                                            ",,#B..#c...c#..c#,,"
                                                                            ",,#B.....u.....c-,,"
                                                                            ",,#B..#.c#c.#..c#,,"
                                                                            ",,###-#-###-#-###,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                   "
                                                                            "                   "
                                                                            "  ##-##            "
                                                                            "  #b.h#            "
                                                                            "  #..t-            "
                                                                            "  #...-            "
                                                                            "  #c..#            "
                                                                            "  ##.####-###....  "
                                                                            "  #...#BB.BB#..h.  "
                                                                            "  #ht....d.....t.  "
                                                                            "  #...#.....#..h.  "
                                                                            "  ###-#-###-#....  "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 9 z)
                                                          (list +mob-type-woman+ 9 9 z)
                                                          (list +mob-type-woman+ 14 9 z)
                                                          (list +mob-type-child+ 4 4 (+ z 1))
                                                          (list +mob-type-man+ 5 9 (+ z 1)))
                                                    nil))))
