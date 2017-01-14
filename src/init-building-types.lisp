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
                                            (list (list +mob-type-man+ 4 5)
                                                  (list +mob-type-woman+ 3 2)
                                                  (list +mob-type-child+ 5 3)))))

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
                                            (list (list +mob-type-man+ 2 3)
                                                  (list +mob-type-woman+ 4 2)
                                                  (list +mob-type-child+ 5 4)))))

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
                                            (list (list +mob-type-man+ 5 4)
                                                  (list +mob-type-woman+ 2 2)
                                                  (list +mob-type-child+ 2 4)))))

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
                                            (list (list +mob-type-man+ 4 2)
                                                  (list +mob-type-woman+ 2 4)
                                                  (list +mob-type-child+ 4 5)))))

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
                                            (list (list +mob-type-clerk+ 3 5)
                                                  (list +mob-type-clerk+ 7 6)
                                                  (list +mob-type-clerk+ 12 5)))))

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
                                            (list (list +mob-type-clerk+ 3 3)
                                                  (list +mob-type-clerk+ 12 3)
                                                  (list +mob-type-clerk+ 8 2)))))

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
                                            (list (list +mob-type-clerk+ 2 2)
                                                  (list +mob-type-clerk+ 2 13)
                                                  (list +mob-type-clerk+ 2 8)))))

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
                                            (list (list +mob-type-clerk+ 5 2)
                                                  (list +mob-type-clerk+ 5 13)
                                                  (list +mob-type-clerk+ 5 8)))))

(set-building-type (make-building :id +building-city-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-park+
                                  :func #'(lambda (x y template-level)
                                            (let ((build-template (list ",,```,,```"
                                                                        "```T````T`"
                                                                        "`T```T````"
                                                                        "``````T`,,"
                                                                        "``T`````,,"
                                                                        ",````T````"
                                                                        ",`T`````T`"
                                                                        ",``````````"
                                                                        ",,`T``T`,,"
                                                                        ",,``````,,")))
                                              
                                              (translate-build-to-template x y build-template template-level)
                                              )
                                            (list (list +mob-type-man+ 2 1)
                                                  (list +mob-type-woman+ 7 4)))))

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
                                            (list (list +mob-type-man+ 4 6)
                                                  (list +mob-type-woman+ 4 1)))))

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
                                            (loop repeat 2
                                                  collect (loop with rx = (random 10)
                                                            with ry = (random 10)
                                                            until (not (= (aref template-level (+ x rx) (+ y ry)) +terrain-tree-birch+))
                                                            finally (return (list +mob-type-man+ rx ry))
                                                            do
                                                               (setf rx (random 10))
                                                               (setf ry (random 10))
                                                                ))
                                            
                                            
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
                                                                          (setf (aref template-level x y) +terrain-floor-grass+))))))
                                            
                                            nil
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
                                            nil)))

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
                                            nil)))

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
                                            (list (list +mob-type-criminal+ 2 14)
                                                  (list +mob-type-criminal+ 5 14)
                                                  (list +mob-type-criminal+ 8 14)
                                                  (list +mob-type-criminal+ 11 14)
                                                  (list +mob-type-policeman+ 10 2)
                                                  (list +mob-type-policeman+ 10 6)
                                                  (list +mob-type-policeman+ 8 9)))))

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
                                            (list (list +mob-type-priest+ 8 2)
                                                  (list +mob-type-priest+ 3 4)
                                                  (list +mob-type-priest+ 12 4)
                                                  (list +mob-type-man+ 6 7)
                                                  (list +mob-type-woman+ 10 7)
                                                  (list +mob-type-man+ 10 11)
                                                  (list +mob-type-woman+ 6 11)))))

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
                                            (list (list +mob-type-man+ 2 2)
                                                  (list +mob-type-man+ 17 2)
                                                  (list +mob-type-man+ 2 17)
                                                  (list +mob-type-man+ 17 17)
                                                  ))))

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
                                            (list (list +mob-type-man+ 3 2)
                                                  (list +mob-type-woman+ 10 6)
                                                  (list +mob-type-woman+ 13 8)
                                                  (list +mob-type-woman+ 16 10)
                                                  ))))







