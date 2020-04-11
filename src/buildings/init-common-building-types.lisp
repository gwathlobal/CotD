(in-package :cotd)

;;=====================
;; Special Buildings
;;=====================

(set-building-type (make-building :id +building-city-free+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))
(set-building-type (make-building :id +building-city-reserved+ :grid-dim '(0 . 0) :act-dim '(0 . 0) :func nil))

;;=====================
;; River
;;=====================

(set-building-type (make-building :id +building-city-river+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-air+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Bridge
;;=====================

(set-building-type (make-building :id +building-city-bridge+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-bridge+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Pier
;;=====================

(set-building-type (make-building :id +building-city-pier-north+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-pier+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    (list (list +feature-arrival-point-north+ 2 2 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-pier-south+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-pier+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    (list (list +feature-arrival-point-south+ 2 2 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-pier-east+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-pier+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    (list (list +feature-arrival-point-east+ 2 2 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-pier-west+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-pier+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    (list (list +feature-arrival-point-west+ 2 2 z))
                                                    nil))))

;;=====================
;; Sea
;;=====================

(set-building-type (make-building :id +building-city-sea+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for x1 from 0 below 5 do
                                              (loop for y1 from 0 below 5 do
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 0)) +terrain-floor-air+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 1)) +terrain-water-liquid-nofreeze+)
                                                (setf (aref template-level (+ x x1) (+ y y1) (- z 2)) +terrain-water-liquid-nofreeze+)))
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Lakes
;;=====================

(set-building-type (make-building :id +building-city-central-lake+ :grid-dim '(4 . 4) :act-dim '(20 . 20) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level terrains)
                                              )

                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-lake-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (- z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level terrains)
                                              )
                                            (values nil nil nil))))

(set-building-type (make-building :id +building-city-lake-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-lake+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (- z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level terrains)
                                              )
                                            (values nil nil nil))))

;;=====================
;; Satanists' lair
;;=====================

(set-building-type (make-building :id +building-city-satan-lair-1+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-satanists+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-0 (list "000000000"
                                                                            "0#######0"
                                                                            "0#|#u#|#0"
                                                                            "0#.....#0"
                                                                            "0#.....#0"
                                                                            "0##...##0"
                                                                            "0###.###0"
                                                                            "0#######0"
                                                                            "000000000"))

                                                  (build-template-z-1 (list "000000000"
                                                                            "0#######0"
                                                                            "0##ud.|#0"
                                                                            "0#.....#0"
                                                                            "0#..####0"
                                                                            "0#..+.b#0"
                                                                            "0##u#.h#0"
                                                                            "0#######0"
                                                                            "000000000"))
                                                  
                                                  (build-template-z-2 (list ",,,,,,,,,"
                                                                            ",#######,"
                                                                            ",#.d#.h#,"
                                                                            ",#..+.b#,"
                                                                            ",+.|####,"
                                                                            ",#..+.b#,"
                                                                            ",#.d#.h#,"
                                                                            ",#######,"
                                                                            ",,,,,,,,,"))

                                                  (build-template-z-3 (list "         "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            " ....... "
                                                                            "         ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z -2) build-template-z-0 template-level terrains)
                                              (translate-build-to-template x y (+ z -1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values (list (list +mob-type-satanist+ 5 2 (+ z 0))
                                                          (list +mob-type-satanist+ 5 5 (+ z 0))
                                                          (list +mob-type-satanist+ 5 2 (+ z -1))
                                                          (list +mob-type-satanist+ 5 5 (+ z -1)))
                                                    (list (list +feature-sacrificial-circle+ 4 4 (+ z -2))
                                                          (list +feature-blood-stain+ 4 6 (+ z -2))
                                                          (list +feature-blood-stain+ 2 4 (+ z -2))
                                                          (list +feature-blood-stain+ 6 4 (+ z -2))
                                                          (list +feature-blood-fresh+ 4 5 (+ z -2))
                                                          (list +feature-blood-fresh+ 4 7 (+ z -2))
                                                          (list +feature-blood-fresh+ 3 6 (+ z -2))
                                                          (list +feature-blood-fresh+ 5 6 (+ z -2))
                                                          (list +feature-blood-old+ 3 4 (+ z -2))
                                                          (list +feature-blood-old+ 2 3 (+ z -2))
                                                          (list +feature-blood-fresh+ 1 4 (+ z -2))
                                                          (list +feature-blood-fresh+ 2 5 (+ z -2))
                                                          (list +feature-blood-old+ 6 4 (+ z -2))
                                                          (list +feature-blood-fresh+ 7 4 (+ z -2))
                                                          (list +feature-blood-old+ 5 4 (+ z -2))
                                                          (list +feature-blood-old+ 6 3 (+ z -2))
                                                          (list +feature-blood-fresh+ 6 5 (+ z -2))
                                                          (list +feature-blood-fresh+ 4 4 (+ z -2))
                                                          (list +feature-blood-old+ 3 5 (+ z -2))
                                                          (list +feature-blood-old+ 5 5 (+ z -2))
                                                          (list +feature-blood-fresh+ 3 7 (+ z -2))
                                                          (list +feature-blood-fresh+ 5 7 (+ z -2))
                                                          (list +feature-start-satanist-player+ 4 4 (+ z -2))
                                                          )
                                                    nil))))

;;=====================
;; Churches
;;=====================

(set-building-type (make-building :id +building-city-church-1+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-church+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "```,,,,,,,,,,```,"
                                                                            "`T````#-#-#```T`,"
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
                                                                            ",#..+.......+..#,"
                                                                            ",##-#-#+#+#-#-##,"
                                                                            ",,,,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                 "
                                                                            "      #####      "
                                                                            "     ##   ##     "
                                                                            " #####     ##### "
                                                                            " #|           |# "
                                                                            " -             - "
                                                                            " #             # "
                                                                            " ##-#|     |#-## "
                                                                            "    -       -    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    -       -    "
                                                                            " ####|     |#### "
                                                                            " #  #       #  # "
                                                                            " #  #       #  # "
                                                                            " ####-#####-#### "
                                                                            "                 "))

                                                  (build-template-z-4 (list "                 "
                                                                            "      .....      "
                                                                            "     ..###..     "
                                                                            " .....##|##..... "
                                                                            " .#####   #####. "
                                                                            " .#|         |#. "
                                                                            " .####     ####. "
                                                                            " ....#|   |#.... "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            "    .#     #.    "
                                                                            " ....#|   |#.... "
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 8) (+ y 16) z) +terrain-floor-sign-church-catholic+)
                                            
                                            (values nil
                                                    (list (list +feature-start-church-player+ 8 2 z)
                                                          (list +feature-start-place-church-priest+ 8 4 z)
                                                          (list +feature-start-place-church-priest+ 3 4 z)
                                                          (list +feature-start-place-church-priest+ 12 4 z)
                                                          (list +feature-start-place-civilian-man+ 6 7 z)
                                                          (list +feature-start-place-civilian-man+ 10 11 z)
                                                          (list +feature-start-place-civilian-woman+ 10 7 z)
                                                          (list +feature-start-place-civilian-woman+ 6 11 z)
                                                          (list +feature-start-place-church-relic+ 8 2 z)
                                                          (list +feature-start-strong-repel-demons+ 8 9 z)
                                                          (list +feature-start-place-angels+ 8 5 z)
                                                          (list +feature-start-place-angels+ 8 8 z)
                                                          (list +feature-start-place-angels+ 8 11 z)
                                                          (list +feature-start-place-angels+ 8 14 z))
                                                    nil))))

(set-building-type (make-building :id +building-city-church-2+ :grid-dim '(4 . 4) :act-dim '(17 . 17) :type +building-type-church+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "```,,,,,,,,,,,,,,"
                                                                            "`T``###-#-###```,"
                                                                            "````#.......#`T`,"
                                                                            ",```#.......#```,"
                                                                            ",####.......####,"
                                                                            ",#.............#,"
                                                                            ",-.............-,"
                                                                            ",#...#.....#...#,"
                                                                            ",#.............#,"
                                                                            ",#...#.....#...#,"
                                                                            ",-.............-,"
                                                                            ",#.............#,"
                                                                            ",####.......####,"
                                                                            ",```-.......-````"
                                                                            "````#.......#``T`"
                                                                            "`T``#-#+#+#-#````"
                                                                            "```,,,,,,,,,,,,,,"))

                                                  (build-template-z-3 (list "                 "
                                                                            "    #########    "
                                                                            "    #|     |#    "
                                                                            "    #       #    "
                                                                            " ####       #### "
                                                                            " #             # "
                                                                            " -   |     |   - "
                                                                            " #   #     #   # "
                                                                            " #             # "
                                                                            " #   #     #   # "
                                                                            " -   |     |   - "
                                                                            " #             # "
                                                                            " ####       #### "
                                                                            "    -       -    "
                                                                            "    #|     |#    "
                                                                            "    ###+#+###    "
                                                                            "                 "))

                                                  (build-template-z-4 (list "                 "
                                                                            "    .........    "
                                                                            "    .........    "
                                                                            "    .........    "
                                                                            " ............... "
                                                                            " .....#####..... "
                                                                            " ....##   ##.... "
                                                                            " ....#     #.... "
                                                                            " ....#     #.... "
                                                                            " ....#     #.... "
                                                                            " ....##   ##.... "
                                                                            " .....#####..... "
                                                                            " ............... "
                                                                            "    .........    "
                                                                            "    .........    "
                                                                            "    .........    "
                                                                            "                 "))

                                                  (build-template-z-5 (list "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "     #######     "
                                                                            "    ##     ##    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    #       #    "
                                                                            "    ##     ##    "
                                                                            "     #######     "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "))
                                                  (build-template-z-6 (list "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "      #####      "
                                                                            "     ##   ##     "
                                                                            "     #     #     "
                                                                            "     #     #     "
                                                                            "     #     #     "
                                                                            "     ##   ##     "
                                                                            "      #####      "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "))
                                                  (build-template-z-7 (list "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "      .....      "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "     .......     "
                                                                            "      .....      "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 "
                                                                            "                 ")))
                                              ;; we assume that z = 2
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              (translate-build-to-template x y (+ z 4) build-template-z-6 template-level terrains)
                                              (translate-build-to-template x y (+ z 5) build-template-z-7 template-level terrains)
                                              )

                                            (setf (aref template-level (+ x 8) (+ y 16) z) +terrain-floor-sign-church-orthodox+)
                                            
                                            (values nil
                                                    (list (list +feature-start-church-player+ 8 6 z)
                                                          (list +feature-start-place-church-priest+ 8 4 z)
                                                          (list +feature-start-place-church-priest+ 5 4 z)
                                                          (list +feature-start-place-church-priest+ 11 4 z)
                                                          (list +feature-start-place-civilian-man+ 6 7 z)
                                                          (list +feature-start-place-civilian-woman+ 10 7 z)
                                                          (list +feature-start-place-civilian-man+ 10 11 z)
                                                          (list +feature-start-place-civilian-woman+ 6 11 z)
                                                          (list +feature-start-place-church-relic+ 8 2 z)
                                                          (list +feature-start-strong-repel-demons+ 8 9 z)
                                                          (list +feature-start-place-angels+ 8 5 z)
                                                          (list +feature-start-place-angels+ 8 8 z)
                                                          (list +feature-start-place-angels+ 8 11 z)
                                                          (list +feature-start-place-angels+ 8 14 z))
                                                    nil))))

;;=====================
;; Barricades
;;=====================

(set-building-type (make-building :id +building-city-barricade-ns+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dy from 0 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-we+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dx from 0 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-se+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-sw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 2 to 4 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-nw+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dx from 0 to 2 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil nil)
                                            )))

(set-building-type (make-building :id +building-city-barricade-ne+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
                                            (declare (ignore terrains))
                                            (loop for dx from 2 to 4 do
                                              (setf (aref template-level (+ x dx) (+ y 1) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 2) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x dx) (+ y 3) z) +terrain-wall-barricade+))
                                            (loop for dy from 0 to 2 do
                                              (setf (aref template-level (+ x 1) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 2) (+ y dy) z) +terrain-wall-barricade+)
                                              (setf (aref template-level (+ x 3) (+ y dy) z) +terrain-wall-barricade+))
                                            
                                            (values nil nil nil)
                                            )))

;;=====================
;; Army posts
;;=====================

(set-building-type (make-building :id +building-city-army-post+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
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
                                                          (list +feature-start-place-military+ 5 5 z))
                                                    nil))))

;;=====================
;; Sigil posts
;;=====================

(set-building-type (make-building :id +building-city-sigil-post+ :grid-dim '(2 . 2) :act-dim '(9 . 9) :type +building-type-none+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    (list (list +feature-start-sigil-point+ 4 4 (+ z 1)))
                                                    nil))))

;;=====================
;; Craters
;;=====================

(set-building-type (make-building :id +building-city-crater-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-crater+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-crater-2+ :grid-dim '(2 . 2) :act-dim '(8 . 8) :type +building-type-crater+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-crater-large+ :grid-dim '(3 . 3) :act-dim '(15 . 15) :type +building-type-crater-large+
                                  :func #'(lambda (x y z template-level terrains)
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
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))
