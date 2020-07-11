(in-package :cotd)

;;=====================
;; Structure
;;=====================

(set-building-type (make-building :id +building-city-hell-structure-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-structure+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,XX,,````"
                                                                            ",X,,X,,,,`"
                                                                            ",,,,,,,X,,"
                                                                            "````,,,,X,"
                                                                            "````,XXX,,"
                                                                            "``,,,,,,,`"
                                                                            "`,,XX,,X,`"
                                                                            "`,X,,XX,,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "  ``      "
                                                                            " X  X     "
                                                                            "       X  "
                                                                            "        ` "
                                                                            "     X``  "
                                                                            "          "
                                                                            "   ``  X  "
                                                                            "  X  ``   "
                                                                            "          "))
                                                   
                                                  (build-template-z-4 (list "          "
                                                                            "          "
                                                                            " ,  ,     "
                                                                            "       ,  "
                                                                            "          "
                                                                            "     ,    "
                                                                            "          "
                                                                            "       ,  "
                                                                            "  ,       "
                                                                            "          ")))
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-structure-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-structure+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "00000u0000"
                                                                            "0000,,,000"
                                                                            "0000,,,000"
                                                                            "00000u0000"
                                                                            "0000000000"
                                                                            "000,,00000"
                                                                            "00u,,u0000"
                                                                            "000,,00000"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "```````,,,"
                                                                            "``,,,d`,X,"
                                                                            ",,,X   ,,,"
                                                                            ",XX,   ```"
                                                                            ",X,,`d,,,`"
                                                                            ",X,,``,X,,"
                                                                            ",,X  `,,X,"
                                                                            "`,d  d,,,,"
                                                                            "```  `,X,`"
                                                                            "``````,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "        X "
                                                                            "   X      "
                                                                            " ,X       "
                                                                            " ,        "
                                                                            " ,     ,  "
                                                                            "  ,     , "
                                                                            "          "
                                                                            "       X  "
                                                                            "          "))

                                                  (build-template-z-4 (list "          "
                                                                            "        , "
                                                                            "   ,      "
                                                                            "  ,       "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "       ,  "
                                                                            "          ")))

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-structure-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-structure+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "````,,,```"
                                                                            "`,,,,X,,``"
                                                                            "`,X,,,X,,`"
                                                                            "`,X,,,XX,,"
                                                                            "`,,X,X,,X,"
                                                                            "`,X,X,,,,,"
                                                                            "`,,X,X,,,,"
                                                                            ",,X,,XX,X,"
                                                                            ",X,`,,XX,,"
                                                                            ",,,``,,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "     ,    "
                                                                            "  ,   ,   "
                                                                            "  ,   ,,  "
                                                                            "   , ,  , "
                                                                            "  , ,     "
                                                                            "   , ,    "
                                                                            "  ,  ,, , "
                                                                            " ,    ,,  "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-structure-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-structure+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "000,,00000"
                                                                            "00,,,,0000"
                                                                            "0u,,,,,000"
                                                                            "00,,,u0000"
                                                                            "000,,00000"
                                                                            "0000000000"
                                                                            "0000000000"
                                                                            "0000000000"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "``````,,,,"
                                                                            "```  `,XX,"
                                                                            "``    ,X,,"
                                                                            "`d     ,,,"
                                                                            "``   d`,X,"
                                                                            "`,,  `,,X,"
                                                                            "`,X,,`,XX,"
                                                                            "`,,X,,X,,,"
                                                                            "``,,XXX,``"
                                                                            "```,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "       ,, "
                                                                            "       ,  "
                                                                            "          "
                                                                            "        , "
                                                                            "        , "
                                                                            "  ,    ,, "
                                                                            "   ,  ,   "
                                                                            "    ,,,   "
                                                                            "          "))
                                                  )

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))


;;=====================
;; Growth
;;=====================

(set-building-type (make-building :id +building-city-hell-outgrowth-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-growth+
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


(set-building-type (make-building :id +building-city-hell-outgrowth-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-growth+
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

(set-building-type (make-building :id +building-city-hell-outgrowth-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-growth+
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

(set-building-type (make-building :id +building-city-hell-outgrowth-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-growth+
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

;;=====================
;; Border
;;=====================

(set-building-type (make-building :id +building-city-hell-border+ :grid-dim '(1 . 1) :act-dim '(5 . 5) :type +building-type-none+
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
;; Structure-Growth
;;=====================

(set-building-type (make-building :id +building-city-hell-struct-growth-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-struct-growth+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,``,,````"
                                                                            ",,`,X,,,,`"
                                                                            ",,,X,,X`,,"
                                                                            "````X,,,`,"
                                                                            "```X,```,,"
                                                                            "``,,,,,,,`"
                                                                            "`T,``,T`,`"
                                                                            "`,`,T``,,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "          "
                                                                            "    ,     "
                                                                            "   ,  ,   "
                                                                            "    ,     "
                                                                            "   ,      "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-struct-growth-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-struct-growth+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,``,,````"
                                                                            ",,`,X,,,,`"
                                                                            ",,,X,,X`,,"
                                                                            "````X,,,`,"
                                                                            "```X,```,,"
                                                                            "``,,,,,,,`"
                                                                            "`T,``,T`,`"
                                                                            "`,`,T``,,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "          "
                                                                            "    ,     "
                                                                            "   ,  ,   "
                                                                            "    ,     "
                                                                            "   ,      "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-struct-growth-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-struct-growth+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,``,,T```"
                                                                            ",,`T`,,,,`"
                                                                            ",,,`,,``T,"
                                                                            "`````,,,`,"
                                                                            "````X```,,"
                                                                            "``,XX,,,,`"
                                                                            "``X``XX`,`"
                                                                            "`,`,```X,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "          "
                                                                            "    ,     "
                                                                            "   ,,     "
                                                                            "  ,  ,,   "
                                                                            "       ,  "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-struct-growth-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-struct-growth+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,`T,,````"
                                                                            ",,```,,,,`"
                                                                            ",,,`,,`X`,"
                                                                            "`T```,X,X,"
                                                                            "````````X,"
                                                                            "``,T`,,,,`"
                                                                            "``````X`,`"
                                                                            "`T`,````,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "       ,  "
                                                                            "      , , "
                                                                            "        , "
                                                                            "          "
                                                                            "      ,   "
                                                                            "          "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-struct-growth-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-struct-growth+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "`,,,,`````"
                                                                            ",,``,,````"
                                                                            ",X`X`,,T,`"
                                                                            ",,X`,,```,"
                                                                            "``X``,`,T,"
                                                                            "`````````,"
                                                                            "``X``,T,,`"
                                                                            "````````,`"
                                                                            "```X````,`"
                                                                            "`,,,,,,,``"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            "          "
                                                                            " , ,      "
                                                                            "  ,       "
                                                                            "  ,       "
                                                                            "          "
                                                                            "  ,       "
                                                                            "          "
                                                                            "   ,      "
                                                                            "          "))
                                                   
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

;;=====================
;; Machine
;;=====================

(set-building-type (make-building :id +building-city-hell-machine-1+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-machine+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "0XXXXXXXX0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0X..uu..X0"
                                                                            "0X..XX..X0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0XXXXXXXX0"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "```````,,,"
                                                                            "`XXXXXXXX,"
                                                                            ",X......X,"
                                                                            ",X......X`"
                                                                            ",X..dd..X`"
                                                                            ",XX....XX,"
                                                                            ",X......X,"
                                                                            "`X......X,"
                                                                            "`XXX..XXX`"
                                                                            "``````,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " .XXXXXX. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .XXXXXX. "
                                                                            " ........ "
                                                                            "          "))

                                                  (build-template-z-4 (list "          "
                                                                            "          "
                                                                            "  ......  "
                                                                            "  .XXXX.  "
                                                                            "  .X  X.  "
                                                                            "  .X  X.  "
                                                                            "  .XXXX.  "
                                                                            "  ......  "
                                                                            "          "
                                                                            "          "))

                                                  (build-template-z-5 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "          "
                                                                            "          "
                                                                            "          ")))

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              )
                                            (values nil
                                                    (list (list +feature-start-machine-point+ 4 7 (- z 1))
                                                          (list +feature-start-sigil-point+ 4 2 (- z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-machine-2+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-machine+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "0XXXXXXXX0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0X..XX..X0"
                                                                            "0X..uu..X0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0XXXXXXXX0"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "```````,,,"
                                                                            "`XXX..XXX,"
                                                                            ",X......X,"
                                                                            ",X......X`"
                                                                            ",XX....XX`"
                                                                            ",X..dd..X,"
                                                                            ",X......X,"
                                                                            "`X......X,"
                                                                            "`XXXXXXXX`"
                                                                            "``````,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " .XXXXXX. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .XXXXXX. "
                                                                            " ........ "
                                                                            "          "))

                                                  (build-template-z-4 (list "          "
                                                                            "          "
                                                                            "  ......  "
                                                                            "  .XXXX.  "
                                                                            "  .X  X.  "
                                                                            "  .X  X.  "
                                                                            "  .XXXX.  "
                                                                            "  ......  "
                                                                            "          "
                                                                            "          "))

                                                  (build-template-z-5 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "          "
                                                                            "          "
                                                                            "          ")))

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              )
                                            (values nil
                                                    (list (list +feature-start-machine-point+ 4 2 (- z 1))
                                                          (list +feature-start-sigil-point+ 4 7 (- z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-machine-3+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-machine+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "0XXXXXXXX0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0X..uX..X0"
                                                                            "0X..uX..X0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0XXXXXXXX0"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "```````,,,"
                                                                            "`XXXXXXXX,"
                                                                            ",X......X,"
                                                                            ",X......X`"
                                                                            ",X..d....`"
                                                                            ",X..d....,"
                                                                            ",X......X,"
                                                                            "`X......X,"
                                                                            "`XXXXXXXX`"
                                                                            "``````,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " .XXXXXX. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .XXXXXX. "
                                                                            " ........ "
                                                                            "          "))

                                                  (build-template-z-4 (list "          "
                                                                            "          "
                                                                            "  ......  "
                                                                            "  .XXXX.  "
                                                                            "  .X  X.  "
                                                                            "  .X  X.  "
                                                                            "  .XXXX.  "
                                                                            "  ......  "
                                                                            "          "
                                                                            "          "))

                                                  (build-template-z-5 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "          "
                                                                            "          "
                                                                            "          ")))

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              )
                                            (values nil
                                                    (list (list +feature-start-machine-point+ 7 4 (- z 1))
                                                          (list +feature-start-sigil-point+ 2 4 (- z 1)))
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-machine-4+ :grid-dim '(2 . 2) :act-dim '(10 . 10) :type +building-type-hell-machine+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-1 (list "0000000000"
                                                                            "0XXXXXXXX0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0X..Xu..X0"
                                                                            "0X..Xu..X0"
                                                                            "0X......X0"
                                                                            "0X......X0"
                                                                            "0XXXXXXXX0"
                                                                            "0000000000"))
                                                  
                                                  (build-template-z-2 (list "```````,,,"
                                                                            "`XXXXXXXX,"
                                                                            ",X......X,"
                                                                            ",X......X`"
                                                                            ",....d..X`"
                                                                            ",....d..X,"
                                                                            ",X......X,"
                                                                            "`X......X,"
                                                                            "`XXXXXXXX`"
                                                                            "``````,,,`"))
                                                  
                                                  (build-template-z-3 (list "          "
                                                                            " ........ "
                                                                            " .XXXXXX. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .X    X. "
                                                                            " .XXXXXX. "
                                                                            " ........ "
                                                                            "          "))

                                                  (build-template-z-4 (list "          "
                                                                            "          "
                                                                            "  ......  "
                                                                            "  .XXXX.  "
                                                                            "  .X  X.  "
                                                                            "  .X  X.  "
                                                                            "  .XXXX.  "
                                                                            "  ......  "
                                                                            "          "
                                                                            "          "))

                                                  (build-template-z-5 (list "          "
                                                                            "          "
                                                                            "          "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "   ....   "
                                                                            "          "
                                                                            "          "
                                                                            "          ")))

                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              )
                                            (values nil
                                                    (list (list +feature-start-machine-point+ 2 4 (- z 1))
                                                          (list +feature-start-sigil-point+ 7 4 (- z 1)))
                                                    nil))))

;;=====================
;; Flesh Storage
;;=====================

(set-building-type (make-building :id +building-city-hell-storage-1+ :grid-dim '(3 . 3) :act-dim '(15 . 15) :type +building-type-hell-storage+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-0 (list "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "0000XXXXXXX0000"
                                                                            "000XX%%%%%XX000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000XX%%%%%XX000"
                                                                            "0000XXXXXXX0000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"))

                                                  (build-template-z-1 (list "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "0000XXXXXXX0000"
                                                                            "000XX%%%%%XX000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000X%%%%%%%X000"
                                                                            "000XX%%%%%XX000"
                                                                            "0000XXXXXXX0000"
                                                                            "000000000000000"
                                                                            "000000000000000"
                                                                            "000000000000000"))
                                                  
                                                  (build-template-z-2 (list ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,XXXXXXX,,,,"
                                                                            ",,,XX%%%%%XX,,,"
                                                                            ",,,X%%%%%%%X,,,"
                                                                            ",uuX%%%%%%%X,,,"
                                                                            ",XXX%%%%%%%X,,,"
                                                                            ",,,X%%%%%%%X,,,"
                                                                            ",,,X%%%%%%%X,,,"
                                                                            ",,,XX%%%%%XX,,,"
                                                                            ",,,,XXXXXXX,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"
                                                                            ",,,,,,,,,,,,,,,"))
                                                  
                                                  (build-template-z-3 (list "               "
                                                                            "               "
                                                                            "               "
                                                                            "    XXXXXXX    "
                                                                            "   XX%%%%%XX   "
                                                                            "   X%%%%%%%X   "
                                                                            " ddX%%%%%%%X   "
                                                                            " ..X%%%%%%%X   "
                                                                            " ..X%%%%%%%X   "
                                                                            " ..X%%%%%%%X   "
                                                                            " ..XX%%%%%XX   "
                                                                            "  ..XXXXXXX    "
                                                                            "   ....uX      "
                                                                            "    ...uX      "
                                                                            "               "))

                                                  (build-template-z-4 (list "               "
                                                                            "               "
                                                                            "               "
                                                                            "    XXXXXXX    "
                                                                            "   XX%%%%%XX   "
                                                                            "   X%%%%%%%X   "
                                                                            "   X%%%%%%%XXX "
                                                                            "   X%%%%%%%Xuu "
                                                                            "   X%%%%%%%X.. "
                                                                            "   X%%%%%%%X.. "
                                                                            "   XX%%%%%XX.. "
                                                                            "    XXXXXXX..  "
                                                                            "       d....   "
                                                                            "       d...    "
                                                                            "               "))

                                                  (build-template-z-5 (list "               "
                                                                            "      Xu...    "
                                                                            "      Xu....   "
                                                                            "    XXXXXXX..  "
                                                                            "   XX%%%%%XX.. "
                                                                            "   X%%%%%%%X.. "
                                                                            "   X%%%%%%%X.. "
                                                                            "   X%%%%%%%Xdd "
                                                                            "   X%%%%%%%X   "
                                                                            "   X%%%%%%%X   "
                                                                            "   XX%%%%%XX   "
                                                                            "    XXXXXXX    "
                                                                            "               "
                                                                            "               "
                                                                            "               "))

                                                  (build-template-z-6 (list "               "
                                                                            "    ...d       "
                                                                            "   ....d       "
                                                                            "  ..XXXXXXX    "
                                                                            " ..XX%%%%%XX   "
                                                                            " ..X%%%%%%%X   "
                                                                            " ..X%%%%%%%X   "
                                                                            " uuX%%%%%%%X   "
                                                                            " XXX%%%%%%%X   "
                                                                            "   X%%%%%%%X   "
                                                                            "   XX%%%%%XX   "
                                                                            "    XXXXXXX    "
                                                                            "               "
                                                                            "               "
                                                                            "               "))

                                                  (build-template-z-7 (list "               "
                                                                            "    .......    "
                                                                            "   .........   "
                                                                            "  ...........  "
                                                                            " ....ggggg.... "
                                                                            " ...ggggggg... "
                                                                            " ...ggggggg... "
                                                                            " dd.ggggggg... "
                                                                            " ...ggggggg... "
                                                                            " ...ggggggg... "
                                                                            " ....ggggg.... "
                                                                            "  ...........  "
                                                                            "   .........   "
                                                                            "    .......    "
                                                                            "               ")))

                                              (translate-build-to-template x y (- z 2) build-template-z-0 template-level terrains)
                                              (translate-build-to-template x y (- z 1) build-template-z-1 template-level terrains)
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              (translate-build-to-template x y (+ z 1) build-template-z-3 template-level terrains)
                                              (translate-build-to-template x y (+ z 2) build-template-z-4 template-level terrains)
                                              (translate-build-to-template x y (+ z 3) build-template-z-5 template-level terrains)
                                              (translate-build-to-template x y (+ z 4) build-template-z-6 template-level terrains)
                                              (translate-build-to-template x y (+ z 5) build-template-z-7 template-level terrains)

                                              )
                                            (values nil
                                                    (list (list +feature-bomb-plant-target+ 7 7 7)
                                                          (list +feature-start-sigil-point+ 7 2 7)
                                                          (list +feature-start-sigil-point+ 7 12 7))
                                                    nil)
                                            )))

;;=====================
;; Slime Pool
;;=====================

(set-building-type (make-building :id +building-city-hell-slime-pool-1+ :grid-dim '(2 . 3) :act-dim '(10 . 15) :type +building-type-hell-slime-pool+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "``````````"
                                                                            "```~~``~~`"
                                                                            "`~~~~~~~``"
                                                                            "`~~~~~~~~`"
                                                                            "`~~~~~~~~`"
                                                                            "``~~~~~~``"
                                                                            "`~~~~~~~``"
                                                                            "``~~~~~~~`"
                                                                            "`~~~~~~~~`"
                                                                            "``~~~~~~~`"
                                                                            "`~~~~~~~``"
                                                                            "`~~~~~~~``"
                                                                            "``~~~~~~~`"
                                                                            "``~~`~~~``"
                                                                            "``````````"))
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))

(set-building-type (make-building :id +building-city-hell-slime-pool-2+ :grid-dim '(3 . 2) :act-dim '(15 . 10) :type +building-type-hell-slime-pool+
                                  :func #'(lambda (x y z template-level terrains)
                                            (let ((build-template-z-2 (list "```````````````"
                                                                            "```~~``~~~`~~``"
                                                                            "`~~~~~~~~~~~~~`"
                                                                            "`~~~~~~~~~~~~~`"
                                                                            "``~~~~~~~~~~~~`"
                                                                            "```~~~~~~~~~~``"
                                                                            "`~~~~~~~~~~~~``"
                                                                            "``~~~~~~~~~~~~`"
                                                                            "```~~~``~~~````"
                                                                            "```````````````"
                                                                            ))
                                                  )
                                              
                                              (translate-build-to-template x y (+ z 0) build-template-z-2 template-level terrains)
                                              )
                                            (values nil
                                                    nil
                                                    nil))))
