(in-package :cotd)

;;=====================
;; Runied houses
;;=====================

(set-building-type (make-building :id +building-city-ruined-house-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-ruined-house+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil
                                                    ))))

(set-building-type (make-building :id +building-city-ruined-house-2+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-ruined-house+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-house-3+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-ruined-house+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-house-4+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-ruined-house+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined townhalls
;;=====================

(set-building-type (make-building :id +building-city-ruined-townhall-1+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-ruined-townhall+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,"
                                                                            ",####......####,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",#```......```#,"
                                                                            ",##-###..###-##,"
                                                                            ",#|..#c..c#..|.,"
                                                                            ",#...+....+...,,"
                                                                            ",##u.#|..|#...,,"
                                                                            ",###-##--##.,,,,"
                                                                            ",,,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "                "
                                                                            " ....      .... "
                                                                            " .            . "
                                                                            " .            . "
                                                                            " .            . "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-townhall-2+ :grid-dim '(4 . 3) :act-dim '(16 . 11) :type +building-type-ruined-townhall+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-townhall-3+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-ruined-townhall+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-townhall-4+ :grid-dim '(3 . 4) :act-dim '(11 . 16) :type +building-type-ruined-townhall+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined parks
;;=====================

(set-building-type (make-building :id +building-city-ruined-park-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-ruined-park+
                                  :func #'(lambda (x y z template-level)
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
                                              
                                              (translate-build-to-template x y z build-template template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


(set-building-type (make-building :id +building-city-ruined-park-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-ruined-park+
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
                                              
                                              (translate-build-to-template x y z build-template template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-park-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-ruined-park+
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
                                            (values nil
                                                    nil
                                                    nil)
                                            )))

(set-building-type (make-building :id +building-city-ruined-park-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-ruined-park+
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

                                            ;; place a large oak tree
                                            (let ((dx (random 7))
                                                  (dy (random 7)))
                                              (cond
                                                (t (level-place-oak-mature-1 template-level (+ dx x) (+ dy y) z)))
                                              )
                                            
                                            ;; find a place to position citizens
                                            (values nil
                                                    nil
                                                    nil)
                                            )))

;;=====================
;; Ruined prisons
;;=====================

(set-building-type (make-building :id +building-city-ruined-prison-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-ruined-prison+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )

                                            (setf (aref template-level (+ x 7) (+ y 0) z) +terrain-floor-sign-prison+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined warehouses
;;=====================

(set-building-type (make-building :id +building-city-ruined-warehouse-1+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-ruined-warehouse+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined libraries
;;=====================

(set-building-type (make-building :id +building-city-ruined-library-1+ :grid-dim '(4 . 3) :act-dim '(20 . 13) :type +building-type-ruined-library+
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
                                                                            ",|,```##-###-##....,"
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
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )

                                            (setf (aref template-level (+ x 2) (+ y 6) z) +terrain-floor-sign-library+)
                                            
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined port warehouses
;;=====================

(set-building-type (make-building :id +building-city-ruined-warehouse-port-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
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

(set-building-type (make-building :id +building-city-ruined-warehouse-port-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Ruined mansions
;;=====================

(set-building-type (make-building :id +building-city-ruined-mansion-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-ruined-mansion+
                                  :func #'(lambda (x y z template-level)
                                            (let ((build-template-z-2 (list ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,,,,,"
                                                                            ",,###-#-###-#-.,,,,"
                                                                            ",,#B..#.|#|.#...,,,"
                                                                            ",,#B..+..u..+....,,"
                                                                            ",,#B..#c...c#...,,,"
                                                                            ",,##+####-####.,,,,"
                                                                            ",,#|..#`````````*,,"
                                                                            ",,#...+`````````*,,"
                                                                            ",,#...#`````````,,,"
                                                                            ",,#...#`````````,,,"
                                                                            ",,##+##****,,,,,,,,"
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-ruined-mansion-2+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-ruined-mansion+
                                  :func #'(lambda (x y z template-level)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


;;=====================
;; Ruined banks
;;=====================

(set-building-type (make-building :id +building-city-ruined-bank-1+ :grid-dim '(4 . 3) :act-dim '(19 . 14) :type +building-type-ruined-bank+
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
                                              (translate-build-to-template x y (+ z -1) build-template-z-1 template-level)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            
                                            (setf (aref template-level (+ x 6) (+ y 12) z) +terrain-floor-sign-bank+)

                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Sigil posts
;;=====================

(set-building-type (make-building :id +building-city-sigil-post+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-none+
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
                                                                            " d,,,,,d "
                                                                            " d,,,,,d "
                                                                            " d,,,,,d "
                                                                            " ddddddd "
                                                                            "         "
                                                                            ))
                                                  )
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level)
                                              )
                                            (values nil
                                                    (list (list +feature-start-sigil-point+ 4 4 (+ z 1)))
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
