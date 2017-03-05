(in-package :cotd)

(defun create-template-test-city (max-x max-y entrance)
  (declare (ignore entrance))
  
  (logger (format nil "CREATE-TEMPLATE-TEST-CITY~%"))

  (setf max-x *max-x-level*)
  (setf max-y *max-y-level*)

  (let ((template-level (make-array (list max-x max-y) :element-type 'fixnum :initial-element +terrain-border-floor+))
	(feature-list)
        (level-template (list ".............................................................................."
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
                              "...#######............########'########...................######.....######..."
                              "...#.....#............#....#.....#....#...................#...............#..."
                              "...#.....+............#....+.....+....-...................#...............#..."
                              "...#.....#............#....#.....#....#...................#...............#..."
                              "...#######............#################...................#################..."
                              ".............................................................................."
                              ".............................................................................."))
        )
    
    (loop for y from 1 below (1- max-y) do
      (loop for x from 1 below (1- max-y) do
        (setf (aref template-level x y) +terrain-floor-stone+)))
    
    (loop for y from 0 below (length level-template) do
      (loop for c across (nth y level-template) 
            with x = 0
            do
               (cond
                 ((char= c #\.) (setf (aref template-level (1+ x) (1+ y)) +terrain-floor-stone+))
                 ((char= c #\#) (setf (aref template-level (1+ x) (1+ y)) +terrain-wall-stone+))
                 ((char= c #\-) (setf (aref template-level (1+ x) (1+ y)) +terrain-wall-window+))
                 ((char= c #\+) (setf (aref template-level (1+ x) (1+ y)) +terrain-door-closed+))
                 ((char= c #\') (setf (aref template-level (1+ x) (1+ y)) +terrain-door-open+))
                 )
               (incf x)
            ))
    
    
    (values template-level feature-list nil)
    ))

(defun test-level-place-mobs (world mob-template-list)
  (declare (ignore mob-template-list))
  (setf *player* (make-instance 'player :mob-type +mob-type-horse+ :x 45 :y 15))
  (add-mob-to-level-list (level world) *player*)
  (let ((soldier (make-instance 'mob :mob-type +mob-type-demon+ :x (- (x *player*) 5) :y (- (y *player*) 0)))
        (demon (make-instance 'mob :mob-type +mob-type-gargantaur+ :x (- (x *player*) 3) :y (+ (y *player*) 0)))
        )
    (setf (cur-fp *player*) 10)
    ;(set-mob-effect *player* +mob-effect-divine-shield+ 100)
    ;(set-mob-effect *player* +mob-effect-called-for-help+ 10)
    ;(set-mob-effect demon +mob-effect-calling-for-help+ 100)
    ;(setf (cur-hp soldier) 15)
    (add-mob-to-level-list (level world) soldier)
    (add-mob-to-level-list (level world) demon)

    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part+ :x (+ (x *player*) 0) :y (+ (y *player*) 1)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 5) :y (+ (y *player*) 5)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 6) :y (+ (y *player*) 5)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 4) :y (+ (y *player*) 5)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x (+ (x *player*) 3) :y (+ (y *player*) 5)))
    ))
