(in-package :cotd)

(set-building-type (make-building :id +building-city-free+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))
(set-building-type (make-building :id +building-city-reserved+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))
(set-building-type (make-building :id +building-city-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",#-#####,"
                                                                        ",#t..bc#,"
                                                                        ",#h....#,"
                                                                        ",#####.#,"
                                                                        ",-ht...#,"
                                                                        ",#....c#,"
                                                                        ",###.###,"
                                                                        ",,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 5)
                                                          (list +mob-type-woman+ 3 2)
                                                          (list +mob-type-child+ 5 3))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",#######,"
                                                                        ",#c...b#,"
                                                                        ",#..#.c#,"
                                                                        ",...#..-,"
                                                                        ",#.t#..#,"
                                                                        ",-.h#ht#,"
                                                                        ",#######,"
                                                                        ",,,,,,,,,")))
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 3)
                                                          (list +mob-type-woman+ 4 2)
                                                          (list +mob-type-child+ 5 4))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",#######,"
                                                                        ",#ht#ht-,"
                                                                        ",#..#..#,"
                                                                        ",-..#...,"
                                                                        ",#b.#..#,"
                                                                        ",#c...c#,"
                                                                        ",#######,"
                                                                        ",,,,,,,,,")))
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 5 4)
                                                          (list +mob-type-woman+ 2 2)
                                                          (list +mob-type-child+ 2 4))
                                                    nil))))

(set-building-type (make-building :id +building-city-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-house+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",###.###,"
                                                                        ",#c...h#,"
                                                                        ",#....t-,"
                                                                        ",#.#####,"
                                                                        ",#....h#,"
                                                                        ",#cb..t#,"
                                                                        ",#####-#,"
                                                                        ",,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 2)
                                                          (list +mob-type-woman+ 2 4)
                                                          (list +mob-type-child+ 4 5))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-1+ :grid-dim '(4 . 2) :act-dim '(16 . 9) :type +building-type-townhall+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,"
                                                                        ",####......####,"
                                                                        ",#```......```#,"
                                                                        ",#```......```#,"
                                                                        ",##-###..###-##,"
                                                                        ",#...#c..c#...#,"
                                                                        ",#ht........th#,"
                                                                        ",###-##--##-###,"
                                                                        ",,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 3 5)
                                                          (list +mob-type-clerk+ 7 6)
                                                          (list +mob-type-clerk+ 12 5))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-2+ :grid-dim '(4 . 2) :act-dim '(16 . 9) :type +building-type-townhall+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,"
                                                                        ",###-##--##-###,"
                                                                        ",#ht........th#,"
                                                                        ",#...#c..c#...#,"
                                                                        ",##-###..###-##,"
                                                                        ",#```......```#,"
                                                                        ",#```......```#,"
                                                                        ",####......####,"
                                                                        ",,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 3 3)
                                                          (list +mob-type-clerk+ 12 3)
                                                          (list +mob-type-clerk+ 8 2))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-3+ :grid-dim '(2 . 4) :act-dim '(9 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",#######,"
                                                                        ",#h.#``#,"
                                                                        ",#t.-``#,"
                                                                        ",-..#``#,"
                                                                        ",#.##...,"
                                                                        ",#.c#...,"
                                                                        ",-......,"
                                                                        ",-......,"
                                                                        ",#.c#...,"
                                                                        ",#.##...,"
                                                                        ",-..#``#,"
                                                                        ",#t.-``#,"
                                                                        ",#h.#``#,"
                                                                        ",#######,"
                                                                        ",,,,,,,,,"
                                                                       )))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 2 2)
                                                          (list +mob-type-clerk+ 2 13)
                                                          (list +mob-type-clerk+ 2 8))
                                                    nil))))

(set-building-type (make-building :id +building-city-townhall-4+ :grid-dim '(2 . 4) :act-dim '(9 . 16) :type +building-type-townhall+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,"
                                                                        ",#######,"
                                                                        ",#``#.h#,"
                                                                        ",#``-.t#,"
                                                                        ",#``#..#,"
                                                                        ",...##.#,"
                                                                        ",...#c.#"
                                                                        ",......-,"
                                                                        ",......-,"
                                                                        ",...#c.#,"
                                                                        ",...##.#,"
                                                                        ",#``#..-,"
                                                                        ",#``-.t#,"
                                                                        ",#``#.h#,"
                                                                        ",#######,"
                                                                        ",,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-clerk+ 5 2)
                                                          (list +mob-type-clerk+ 5 13)
                                                          (list +mob-type-clerk+ 5 8))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y template-level)
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
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 1)
                                                          (list +mob-type-woman+ 7 4))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y template-level)
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
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 4 6)
                                                          (list +mob-type-woman+ 4 1))
                                                    nil))))

(set-building-type (make-building :id +building-city-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y template-level)
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy)) +terrain-tree-birch+))))

                                            ;; make sure that each tree has no more than one adjacent tree
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y) +terrain-tree-birch+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 1)
                                                         (setf (aref template-level (+ x dx) (+ y dy)) +terrain-floor-dirt+))))

                                            ;; place grass around trees
                                            (loop for dx from 1 to 8 do
                                              (loop for dy from 1 to 8 do
                                                (when (= (aref template-level (+ x dx) (+ y dy)) +terrain-tree-birch+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (setf (aref template-level x y) +terrain-floor-grass+))))))
                                            
                                            ;; find a place to position citizens
                                            (values (loop repeat 2
                                                          collect (loop with rx = (random 10)
                                                                        with ry = (random 10)
                                                                        until (not (= (aref template-level (+ x rx) (+ y ry)) +terrain-tree-birch+))
                                                                        finally (return (list +mob-type-man+ rx ry))
                                                                        do
                                                                           (setf rx (random 10))
                                                                           (setf ry (random 10))
                                                                        ))
                                                    nil)
                                            
                                            
                                            )))

(set-building-type (make-building :id +building-city-park-tiny+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            ;; populate the area with trees, leaving the border untouched
                                            (loop for dx from 1 to 3 do
                                              (loop for dy from 1 to 3 do
                                                (when (zerop (random 3))
                                                  (setf (aref template-level (+ x dx) (+ y dy)) +terrain-tree-birch+))))

                                            ;; make sure that each tree has no more than two adjacent trees
                                            (loop for dx from 1 to 3 do
                                              (loop for dy from 1 to 3
                                                    with tree-num
                                                    do
                                                       (setf tree-num 0)
                                                       (check-surroundings (+ x dx) (+ y dy) nil
                                                                           #'(lambda (x y)
                                                                               (when (= (aref template-level x y) +terrain-tree-birch+)
                                                                                 (incf tree-num))))
                                                       (when (> tree-num 2)
                                                         (setf (aref template-level (+ x dx) (+ y dy)) +terrain-floor-dirt+))))

                                            ;; place grass around trees
                                            (loop for dx from 1 to 3 do
                                              (loop for dy from 1 to 3 do
                                                (when (= (aref template-level (+ x dx) (+ y dy)) +terrain-tree-birch+)
                                                  (check-surroundings (+ x dx) (+ y dy) nil
                                                                      #'(lambda (x y)
                                                                          (if (= (aref template-level x y) +terrain-border-floor+)
                                                                            (setf (aref template-level x y) +terrain-border-grass+)
                                                                            (setf (aref template-level x y) +terrain-floor-grass+)))))))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-lake-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",```````,,"
                                                                        "``_`___``,"
                                                                        "`_______`,"
                                                                        "`______``,"
                                                                        "``_____``,"
                                                                        "``______``"
                                                                        "`________`"
                                                                        "`________`"
                                                                        "```_____``"
                                                                        ",,```````,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values nil nil))))

(set-building-type (make-building :id +building-city-lake-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",````````,"
                                                                        "``___`__``"
                                                                        "`________`"
                                                                        "`_______``"
                                                                        "`______```"
                                                                        "``_____`T`"
                                                                        ",`_____```"
                                                                        ",`______`,"
                                                                        ",``__`__`,"
                                                                        ",,```````,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values nil nil))))

(set-building-type (make-building :id +building-city-prison-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-prison+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,,"
                                                                        ",#######.#######,"
                                                                        ",#.....-.#.....#,"
                                                                        ",#.....-.#htc-.#,"
                                                                        ",#.....-.#####.#,"
                                                                        ",#.....-.#htc-.#,"
                                                                        ",#.....-.#.....#,"
                                                                        ",#.....-.#####.#,"
                                                                        ",#.....-.......#,"
                                                                        ",#.#####h..#####,"
                                                                        ",#.....###.#...#,"
                                                                        ",#.............#,"
                                                                        ",#-.#-.#-.#-.#.#,"
                                                                        ",#..#..#..#..#.#,"
                                                                        ",#.b#.b#.b#.b#.#,"
                                                                        ",###############,"
                                                                        ",,,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-criminal+ 2 14)
                                                          (list +mob-type-criminal+ 5 14)
                                                          (list +mob-type-criminal+ 8 14)
                                                          (list +mob-type-criminal+ 11 14)
                                                          (list +mob-type-policeman+ 10 2)
                                                          (list +mob-type-policeman+ 10 6)
                                                          (list +mob-type-policeman+ 8 9))
                                                    nil))))

(set-building-type (make-building :id +building-city-church-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-church+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list "```,,,,,,,,,,```,"
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
                                                                        ",,,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-priest+ 8 2)
                                                          (list +mob-type-priest+ 3 4)
                                                          (list +mob-type-priest+ 12 4)
                                                          (list +mob-type-man+ 6 7)
                                                          (list +mob-type-woman+ 10 7)
                                                          (list +mob-type-man+ 10 11)
                                                          (list +mob-type-woman+ 6 11))
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-warehouse+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,,,,,"
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
                                                                        ",,,,,,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 2 2)
                                                          (list +mob-type-man+ 17 2)
                                                          (list +mob-type-man+ 2 17)
                                                          (list +mob-type-man+ 17 17))
                                                    nil))))

(set-building-type (make-building :id +building-city-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 12) :type +building-type-library+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,,,,,"
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
                                                                        )))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 3 2)
                                                          (list +mob-type-woman+ 10 6)
                                                          (list +mob-type-woman+ 13 8)
                                                          (list +mob-type-woman+ 16 10))
                                                    nil))))

(set-building-type (make-building :id +building-city-satan-lair-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-satanists+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,,,,,,,,"
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
                                                                        ",,,,,,,,,,,,,,,,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-satanist+ 3 2)
                                                          (list +mob-type-satanist+ 6 2)
                                                          (list +mob-type-satanist+ 9 2)
                                                          (list +mob-type-satanist+ 8 10))
                                                    (list (list +feature-blood-stain+ 8 10)
                                                          (list +feature-blood-stain+ 8 8)
                                                          (list +feature-blood-stain+ 6 10)
                                                          (list +feature-blood-fresh+ 8 7)
                                                          (list +feature-blood-fresh+ 9 7)
                                                          (list +feature-blood-old+ 7 7)
                                                          (list +feature-blood-old+ 7 8)
                                                          (list +feature-blood-fresh+ 6 9)
                                                          (list +feature-blood-fresh+ 9 8)
                                                          (list +feature-blood-fresh+ 6 8)
                                                          (list +feature-blood-stain+ 10 10)
                                                          (list +feature-blood-old+ 9 10)
                                                          (list +feature-blood-fresh+ 7 10)
                                                          (list +feature-blood-old+ 8 11)
                                                          (list +feature-blood-fresh+ 8 9)
                                                          (list +feature-blood-old+ 9 11)
                                                          (list +feature-blood-old+ 7 11)
                                                          (list +feature-blood-fresh+ 9 9)
                                                          (list +feature-blood-old+ 7 9)
                                                          (list +feature-blood-fresh+ 5 10)
                                                          (list +feature-blood-old+ 11 10)
                                                          (list +feature-blood-old+ 12 10)
                                                          (list +feature-blood-fresh+ 11 11)
                                                          (list +feature-blood-fresh+ 11 9)
                                                          (list +feature-blood-fresh+ 10 9)
                                                          (list +feature-blood-old+ 10 11)
                                                          (list +feature-blood-old+ 4 10)
                                                          (list +feature-blood-fresh+ 5 9)
                                                          (list +feature-blood-fresh+ 6 9)
                                                          (list +feature-blood-fresh+ 6 11)
                                                          (list +feature-blood-old+ 5 9)
                                                          (list +feature-blood-fresh+ 8 12)
                                                          (list +feature-blood-fresh+ 7 12)
                                                          (list +feature-blood-fresh+ 9 12)
                                                          (list +feature-blood-old+ 9 13))))))

(set-building-type (make-building :id +building-city-river+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1)) +terrain-water-river+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-bridge+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-bridge+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-pier+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-pier+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-sea+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1)) +terrain-water-sea+)))
                                            (values nil
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,"
                                                                        ",########,"
                                                                        ",#CCCCCC#,"
                                                                        ",.......,"
                                                                        ",#.CCCC.#,"
                                                                        ",#.CCCC.#,"
                                                                        ",........,"
                                                                        ",#CCCCCC#,"
                                                                        ",########,"
                                                                        ",,,,,,,,,,")))
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 3 3)
                                                          (list +mob-type-man+ 6 6))
                                                    nil))))

(set-building-type (make-building :id +building-city-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,,,,,,,,,"
                                                                        ",##.##.##,"
                                                                        ",#C....C#,"
                                                                        ",#C.CC.C#,"
                                                                        ",#C.CC.C#,"
                                                                        ",#C.CC.C#,"
                                                                        ",#C.CC.C#,"
                                                                        ",#C....C#,"
                                                                        ",##.##.##,"
                                                                        ",,,,,,,,,,")))
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (values (list (list +mob-type-man+ 3 6)
                                                          (list +mob-type-man+ 6 3))
                                                    nil))))

(set-building-type (make-building :id +building-city-island-ground-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            ;; randomly place the ground and sea tiles 
                                            (loop for dx from 0 to 4 do
                                              (loop for dy from 0 to 4 do
                                                (if (zerop (random 2))
                                                  (progn
                                                    (if (zerop (random 4))
                                                      (setf (aref template-level (+ x dx) (+ y dy)) +terrain-floor-dirt-bright+)
                                                      (setf (aref template-level (+ x dx) (+ y dy)) +terrain-floor-dirt+)))
                                                  (progn
                                                    (setf (aref template-level (+ x dx) (+ y dy)) +terrain-water-sea+)))))

                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-ns+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dy from 0 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-we+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dx from 0 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-se+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3)) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-sw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3)) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-nw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3)) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-ne+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y template-level)
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3)) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy)) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy)) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))
