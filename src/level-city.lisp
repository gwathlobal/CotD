(in-package :cotd)

(defconstant +level-template-city-free+ 0)
(defconstant +level-template-city-reserved+ 1)
(defconstant +level-template-city-house-1+ 2)
(defconstant +level-template-city-house-2+ 3)
(defconstant +level-template-city-house-3+ 4)
(defconstant +level-template-city-house-4+ 5)
(defconstant +level-template-city-townhall+ 6)
(defconstant +level-template-city-park-1+ 7)
(defconstant +level-template-city-lake-1+ 8)
(defconstant +level-template-city-park-2+ 9)
(defconstant +level-template-city-prison-1+ 10)
(defconstant +level-template-city-church-1+ 11)
(defconstant +level-template-city-warehouse-1+ 12)
(defconstant +level-template-city-library-1+ 13)


(defparameter *level-grid-size* 5)

;; dimensions may not exceed (- *level-grid-size* 2), as 1 from each side must be free so that building do not stand immediately adjacent to each other
(defparameter *level-template-building-dimensions* (list '(0 . 0)
                                                         '(0 . 0)
                                                         '(7 . 7)
                                                         '(7 . 7)
                                                         '(7 . 7)
                                                         '(7 . 7)
                                                         '(16 . 9)
                                                         '(8 . 8)
                                                         '(10 . 10)
                                                         '(8 . 8)
                                                         '(17 . 17)
                                                         '(17 . 17)
                                                         '(18 . 18)
                                                         '(18 . 10)))

(defparameter *level-grid-building-dimensions* (list '(0 . 0)
                                                     '(0 . 0)
                                                     '(2 . 2)
                                                     '(2 . 2)
                                                     '(2 . 2)
                                                     '(2 . 2)
                                                     '(4 . 3)
                                                     '(2 . 2)
                                                     '(3 . 3)
                                                     '(2 . 2)
                                                     '(4 . 4)
                                                     '(4 . 4)
                                                     '(4 . 4)
                                                     '(4 . 3)))

(defun create-template-city (max-x max-y entrance)
  (declare (ignore entrance))
  
  (logger (format nil "CREATE-TEMPLATE-CITY~%"))

  (setf max-x *max-x-level*)
  (setf max-y *max-y-level*)

  ;; make a template level
  ;; and an enlarged grid with scale 1 to 10 cells of template level
  ;; grid will be used to make reservations for buildings
  ;; once all places on grid are reserved, put actual buildings to the template level in places that were reserved 
  (let* ((reserv-max-x (truncate max-x *level-grid-size*)) (reserv-max-y (truncate max-y *level-grid-size*))
         (template-level (make-array (list max-x max-y) :element-type 'fixnum :initial-element +terrain-border-floor+))
         (reserved-level (make-array (list reserv-max-x reserv-max-y) :element-type 'fixnum :initial-element +level-template-city-reserved+))
         (feature-list)
         (mob-list nil)
         (build-list nil)
         (max-building-types (make-hash-table))
         )

    ;; set up maximum building types for this kind of map
    (setf (gethash +level-template-city-church-1+ max-building-types) 1)
    (setf (gethash +level-template-city-warehouse-1+ max-building-types) 1)
    (setf (gethash +level-template-city-library-1+ max-building-types) 1)
    (setf (gethash +level-template-city-prison-1+ max-building-types) 1)
    
    ;; all grid cells along the borders are reserved, while everything inised is free for claiming
    (loop for y from 1 below (1- reserv-max-y) do
      (loop for x from 1 below (1- reserv-max-x) do
        (setf (aref reserved-level x y) +level-template-city-free+)))
        
    ;; make reservations for buildings of the grid level
    (loop for y from 0 below reserv-max-y do
      (loop for x from 0 below reserv-max-x 
            with build-id-list = (list +level-template-city-house-1+ +level-template-city-house-2+ +level-template-city-house-3+ +level-template-city-house-4+ 
                                       +level-template-city-townhall+ 
                                       +level-template-city-park-1+ +level-template-city-park-2+
                                       +level-template-city-lake-1+
                                       +level-template-city-prison-1+
                                       +level-template-city-church-1+
                                       +level-template-city-warehouse-1+
                                       +level-template-city-library-1+)
            with build-picked = nil
            with build-cur-list = nil
            do
               ;; copy the list of available buildings 
               (setf build-cur-list (copy-list build-id-list))
               
               ;; randomly pick a building and remove it from the list if it does not fit or the maximum number of this buildings have been reached
               ;; until we find a building that fits or nothing is left 
               (loop initially (setf build-picked (nth (random (length build-cur-list)) build-cur-list))
                               (setf build-cur-list (remove build-picked build-cur-list))
                     until (or (and (gethash build-picked max-building-types)
                                    (> (gethash build-picked max-building-types) 0)
                                    (level-city-can-place-build-on-grid build-picked x y reserved-level))
                               (and (not (gethash build-picked max-building-types))
                                    (level-city-can-place-build-on-grid build-picked x y reserved-level)))
                     do
                        (unless build-cur-list
                          (setf build-picked nil)
                          (loop-finish))
                        (setf build-picked (nth (random (length build-cur-list)) build-cur-list))
                        (setf build-cur-list (remove build-picked build-cur-list))
                        )
               
               ;;  check if there was a building picked
               (when build-picked
                 ;; if yes, add the building to the building list
                 (setf build-list (append build-list (list (list build-picked x y))))
                 
                 ;; reserve the tiles for the building
                 (level-city-reserve-build-on-grid build-picked x y reserved-level)

                 ;; decrease the maximum available number of buildings of this type
                 (when (gethash build-picked max-building-types)
                   (decf (gethash build-picked max-building-types)))
                 )
               ;;(format t "(X,Y) = ~A, ~A~%" x y)
               ;;(print-reserved-level reserved-level)
            ))
    
    
    
    (loop for y from 1 below (1- max-y) do
      (loop for x from 1 below (1- max-x) do
        (if (< (random 100) 20)
          (setf (aref template-level x y) +terrain-floor-dirt-bright+)
          (setf (aref template-level x y) +terrain-floor-dirt+))))
    
    (print-reserved-level reserved-level)
    
    ;; take buildings from the building list and actually place them on the template level
    (loop for (build-type-id gx gy) in build-list 
          with px = 0
          with py = 0
          with building-mobs = nil
          do
             ;; find a random position within the grid on the template level so that the building does not violate the grid boundaries
             (multiple-value-bind (adx ady) (level-city-get-actual-building-dimensions build-type-id)
               (multiple-value-bind (gdx gdy) (level-city-get-grid-building-dimensions build-type-id)
                 (setf px (1+ (random (- (1- (* *level-grid-size* gdx)) adx))))
                 (setf py (1+ (random (- (1- (* *level-grid-size* gdy)) ady))))))
             
             ;; place the actual building
             (cond 
                 ((= build-type-id +level-template-city-house-1+) (setf building-mobs (level-city-place-house-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-house-2+) (setf building-mobs (level-city-place-house-2 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-house-3+) (setf building-mobs (level-city-place-house-3 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-house-4+) (setf building-mobs (level-city-place-house-4 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-townhall+) (setf building-mobs (level-city-place-townhall (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-park-1+) (setf building-mobs (level-city-place-park-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-park-2+) (setf building-mobs (level-city-place-park-2 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-lake-1+) (setf building-mobs (level-city-place-lake-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-prison-1+) (setf building-mobs (level-city-place-prison-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-church-1+) (setf building-mobs (level-city-place-church-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-warehouse-1+) (setf building-mobs (level-city-place-warehouse-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level)))
                 ((= build-type-id +level-template-city-library-1+) (setf building-mobs (level-city-place-library-1 (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) template-level))))
             
             ;; add mobs to the mob-list
             (when building-mobs
               (loop for (mob-id lx ly) in building-mobs do
                 (pushnew (list mob-id (+ (* gx *level-grid-size*) px lx) (+ (* gy *level-grid-size*) py ly)) 
                          mob-list)))
          )
               
    (values template-level feature-list mob-list)
    ))





(defun level-city-place-house-1 (x y template-level)
  (let ((build-template (list "#-#####"
                              "#t..bc#"
                              "#h....#"
                              "#####.#"
                              "-ht...#"
                              "#....c#"
                              "###.###")))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 3 4)
        (list +mob-type-woman+ 3 2)
        (list +mob-type-child+ 5 3)))

(defun level-city-place-house-2 (x y template-level)
  (let ((build-template (list "#######"
                              "#c...b#"
                              "#..#.c#"
                              "...#..-"
                              "#.t#..#"
                              "-.h#ht#"
                              "#######")))
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 2 3)
        (list +mob-type-woman+ 4 2)
        (list +mob-type-child+ 5 4)))

(defun level-city-place-house-3 (x y template-level)
  (let ((build-template (list "#######"
                              "#ht#ht-"
                              "#..#..#"
                              "-..#..."
                              "#b.#..#"
                              "#c...c#"
                              "#######")))
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 4 4)
        (list +mob-type-woman+ 1 2)
        (list +mob-type-child+ 2 4)))

(defun level-city-place-house-4 (x y template-level)
  (let ((build-template (list "###.###"
                              "#c...h#"
                              "#....t-"
                              "#.#####"
                              "#....h#"
                              "#cb..t#"
                              "#####-#")))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 4 2)
        (list +mob-type-woman+ 3 4)
        (list +mob-type-child+ 4 5)))

(defun level-city-place-townhall (x y template-level)
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
        (list +mob-type-clerk+ 12 5)))

(defun level-city-place-park-1 (x y template-level)
  (let ((build-template (list "```,```,"
                              "`T```T``"
                              "``````T`"
                              "``T`````"
                              ",````T``"
                              ",`T````,"
                              ",```,,,,")))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 2 1)
        (list +mob-type-woman+ 7 4)))

(defun level-city-place-park-2 (x y template-level)
  (let ((build-template (list "```,```,"
                              "`T```T`,"
                              "```T````"
                              "`T````T`"
                              "````T```"
                              ",`T```T`"
                              ",```,```")))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 4 5)
        (list +mob-type-woman+ 4 1)))

(defun level-city-place-lake-1 (x y template-level)
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
  nil)

(defun level-city-place-prison-1 (x y template-level)
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
        (list +mob-type-policeman+ 8 9)))

(defun level-city-place-church-1 (x y template-level)
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
        (list +mob-type-woman+ 6 11)))

(defun level-city-place-warehouse-1 (x y template-level)
  (let ((build-template (list "##-#####..#####-##"
                              "#................#"
                              "#..CCCCCCCCCCCC..#"
                              "#..############..#"
                              "#..CCCCCCCCCCCC..#"
                              "-................-"
                              "#..CCCCCCCCCCCC..#"
                              "#..############..#"
                              ".................."
                              ".................."
                              "#..############..#"
                              "#..CCCCCCCCCCCC..#"
                              "-................-"
                              "#..CCCCCCCCCCCC..#"
                              "#..############..#"
                              "#..CCCCCCCCCCCC..#"
                              "#................#"
                              "##-#####..#####-##")))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 1 1)
        (list +mob-type-man+ 16 1)
        (list +mob-type-man+ 1 16)
        (list +mob-type-man+ 16 16)
        ))

(defun level-city-place-library-1 (x y template-level)
  (let ((build-template (list "##-####-###-###-##"
                              "#.h..#...........#"
                              "-.t.....B..B..B..-"
                              "#....#..B..B..B..#"
                              "##..##..B..B..B..#"
                              "`````-..B..B..B..-"
                              "`````#..B..B..B..#"
                              "`T```#..B..B..B..#"
                              "`````-..B..B..B..-"
                              ",``T`#...........#"
                              ",,```##-###-###-##"
                             )))
    
    (translate-build-to-template x y build-template template-level)
    )
  (list (list +mob-type-man+ 2 1)
        (list +mob-type-woman+ 9 5)
        (list +mob-type-woman+ 12 7)
        (list +mob-type-woman+ 15 9)
        ))

(defun translate-build-to-template (x y build-template template-level)
  (loop for y1 from 0 below (length build-template) do
    (loop for c across (nth y1 build-template) 
          with x1 = 0
          do
             (cond
               ((char= c #\.) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-stone+))
               ((char= c #\#) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-wall-stone+))
               ((char= c #\T) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-tree-birch+))
               ((char= c #\,) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-dirt+))
               ((char= c #\_) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-water-lake+))
               ((char= c #\`) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-grass+))
               ((char= c #\-) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-wall-window+))
               ((char= c #\h) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-chair+))
               ((char= c #\t) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-table+))
               ((char= c #\b) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-bed+))
               ((char= c #\c) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-cabinet+))
               ((char= c #\C) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-crate+))
               ((char= c #\B) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-bookshelf+))
               )
             (incf x1)
          )))

(defun level-city-get-actual-building-dimensions (template-building-id)
  (values (car (nth template-building-id *level-template-building-dimensions*)) 
          (cdr (nth template-building-id *level-template-building-dimensions*))))

(defun level-city-get-grid-building-dimensions (template-building-id)
  (values (car (nth template-building-id *level-grid-building-dimensions*)) 
          (cdr (nth template-building-id *level-grid-building-dimensions*))))


(defun level-city-can-place-build-on-grid (template-building-id gx gy reserved-level)
  (multiple-value-bind (dx dy) (level-city-get-grid-building-dimensions template-building-id)
    ;; if the staring point of the building + its dimensions) is more than level dimensions - fail
    (when (or (> (+ gx dx) (array-dimension reserved-level 0))
              (> (+ gy dy) (array-dimension reserved-level 1)))
      (return-from level-city-can-place-build-on-grid nil))
    
    ;; if any of the grid tiles that the building is going to occupy are already reserved - fail
    (loop for y1 from 0 below dy do
      (loop for x1 from 0 below dx do
        (when (/= (aref reserved-level (+ gx x1) (+ gy y1)) +level-template-city-free+)
          (return-from level-city-can-place-build-on-grid nil))
            ))
    ;; all checks done - success
    t
    ))

(defun level-city-reserve-build-on-grid (template-building-id gx gy reserved-level)
  (multiple-value-bind (dx dy) (level-city-get-grid-building-dimensions template-building-id)
    (loop for y1 from 0 below dy do
      (loop for x1 from 0 below dx do
        (setf (aref reserved-level (+ gx x1) (+ gy y1)) template-building-id)))
    ))

(defun print-reserved-level (reserved-level)
  (logger (format nil "RESERVED-LEVEL:~%"))
  (loop for y from 0 below (array-dimension reserved-level 1) do
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (logger (format nil "~2@A " (aref reserved-level x y))))
    (logger (format nil "~%"))))
