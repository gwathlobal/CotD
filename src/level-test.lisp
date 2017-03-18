(in-package :cotd)

(defun create-template-test-city (max-x max-y max-z entrance)
  (declare (ignore entrance))
  
  (logger (format nil "CREATE-TEMPLATE-TEST-CITY~%"))

  ;(setf max-x *max-x-level*)
  ;(setf max-y *max-y-level*)
  ;(setf max-z *max-z-level*)
  (setf max-x 90)
  (setf max-y 30)
  (setf max-z 10)

  (let ((template-level (make-array (list max-x max-y max-z) :element-type 'fixnum :initial-element +terrain-border-floor+))
	(feature-list)
        (level-template-z-0 (list ".............................................................................."
                                  ".............................................................................."
                                  "...#######..#######.############..........................######.....######..."
                                  "...#.....#..#.....#.#....#.....#..........................#....#.....#....#..."
                                  "...#.....#..#.....#.#..........#..........................#..........#....#..."
                                  "...#.....#..#.....#.#....#.....#..........................#....#.....#....#..."
                                  "...###+###..###+###.########+###..........................######.....######..."
                                  ".............................................................................."
                                  "..........................................................######.....######..."
                                  "..........................................................#....#..........#..."
                                  "...###+###................................................#...............#..."
                                  "...#.....#................................................#....#..........#..."
                                  "...#.....#................................................######.....######..."
                                  "...#.....#............#####.......#####......................................."
                                  "...#######............#...............#......................................."
                                  "......................#...............-......................................."
                                  "...#######...........u########'########u..................######.....######..."
                                  "...#.....#............#....#.....#....#...................#...............#..."
                                  "...#.....+............#....+.....+....-...................#...............#..."
                                  "...#.....#............#....#.....#....#...................#...............#..."
                                  "...#######............#################...................#################..."
                                  ".............................................................................."
                                  ".............................................................................."))
        
        (level-template-z-1 (list "                                                                              "
                                  "                                                                              "
                                  "   .......  ....... ............                          ......     ......   "
                                  "   .......  ....... ............                          ......     ......   "
                                  "   .......  ....... ............                          ......     ......   "
                                  "   .......  ....... ............                          ......     ......   "
                                  "   .......  ....... ............                          ......     ......   "
                                  "                                                                              "
                                  "                                                          ......     ......   "
                                  "                                                          ......     ......   "
                                  "   .......                                                ......     ......   "
                                  "   .......                                                ......     ......   "
                                  "   .......                                                ......     ......   "
                                  "   .......            .....       .....                                       "
                                  "   .......            .....       .....                                       "
                                  "                      .....       .....                                       "
                                  "   .......           d.................d                  .................   "
                                  "   .......            ....u.......u....                   .................   "
                                  "   .......            ..#####...#####..                   .................   "
                                  "   .......            ..#...........#..                   .................   "
                                  "   .......            ..#############..                   .................   "
                                  "                                                                              "
                                  "                                                                              "))
        
        (level-template-z-2 (list "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                          d       d                                           "
                                  "                        .............                                         "
                                  "                        .............                                         "
                                  "                        .............                                         "
                                  "                                                                              "
                                  "                                                                              "))
        )

    (loop for y from 0 below max-y do
      (loop for x from 0 below max-x do
        (loop for z from 1 below max-z do
          (setf (aref template-level x y z) +terrain-border-air+))))

    (loop for y from 1 below (1- max-y) do
      (loop for x from 1 below (1- max-x) do
        (loop for z from 1 below max-z do
          (setf (aref template-level x y z) +terrain-floor-air+))))
    
    (loop for y from 1 below (1- max-y) do
      (loop for x from 1 below (1- max-x) do
        (setf (aref template-level x y 0) +terrain-floor-stone+)))

    (loop for level in (list level-template-z-0 level-template-z-1 level-template-z-2)
          for z from 0 to 2 do
            (loop for y from 0 below (length level) do
              (loop for c across (nth y level)
                    with x = 0
                      do
                         (cond
                           ((char= c #\.) (setf (aref template-level (1+ x) (1+ y) z) +terrain-floor-stone+))
                           ((char= c #\#) (setf (aref template-level (1+ x) (1+ y) z) +terrain-wall-stone+))
                           ((char= c #\-) (setf (aref template-level (1+ x) (1+ y) z) +terrain-wall-window+))
                           ((char= c #\+) (setf (aref template-level (1+ x) (1+ y) z) +terrain-door-closed+))
                           ((char= c #\') (setf (aref template-level (1+ x) (1+ y) z) +terrain-door-open+))
                           ((char= c #\Space) (setf (aref template-level (1+ x) (1+ y) z) +terrain-floor-air+))
                           ((char= c #\u) (setf (aref template-level (1+ x) (1+ y) z) +terrain-slope-stone-up+))
                           ((char= c #\d) (setf (aref template-level (1+ x) (1+ y) z) +terrain-slope-stone-down+))
                           )
                         (incf x)
                      )))
    
    
    
    
    (values template-level feature-list nil)
    ))

(defun test-level-place-mobs (world mob-template-list)
  (declare (ignore mob-template-list))
  (setf *player* (make-instance 'player :mob-type +mob-type-chaplain+ :x 40 :y 16 :z 0))
  (add-mob-to-level-list (level world) *player*)
  (let (;(soldier (make-instance 'mob :mob-type +mob-type-man+ :x (+ (x *player*) 4) :y (- (y *player*) 0) :z 0))
        ;(demon (make-instance 'mob :mob-type +mob-type-man+ :x (+ (x *player*) 3) :y (+ (y *player*) 0) :z 0))
        )
    (setf (cur-fp *player*) 10)
    ;(set-mob-effect *player* +mob-effect-divine-shield+ 100)
    ;(set-mob-effect *player* +mob-effect-called-for-help+ 10)
    ;(set-mob-effect demon +mob-effect-calling-for-help+ 100)
    ;(setf (cur-hp soldier) 15)
    ;(add-mob-to-level-list (level world) soldier)
    ;(add-mob-to-level-list (level world) demon)

    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part+ :x (+ (x *player*) 0) :y (+ (y *player*) 1)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 0) :y (+ (y *player*) 3)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-fiend+ :x (- (x *player*) 2) :y (+ (y *player*) 0)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 2) :y (+ (y *player*) 3)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 3) :y (+ (y *player*) 5)))
    ))
