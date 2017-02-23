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
                              "...#.....#..#.....#.#..........#..........................#...............#..."
                              "...#.....#..#.....#.#....#.....#..........................#....#.....#....#..."
                              "...###.###..###.###.########.###..........................######.....######..."
                              ".............................................................................."
                              "..........................................................######.....######..."
                              "..........................................................#....#.....#....#..."
                              "...###.###................................................#...............#..."
                              "...#.....#................................................#....#.....#....#..."
                              "...#.....#................................................######.....######..."
                              "...#.....#............#####.......#####......................................."
                              "...#######............#...............#......................................."
                              "......................#...............-......................................."
                              "...#######............########.########...................######.....######..."
                              "...#.....#............#....#.....#....#...................#...............#..."
                              "...#..................#...............-...................#...............#..."
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
                 )
               (incf x)
            ))
    
    
    (values template-level feature-list nil)
    ))

(defun test-level-place-mobs (world mob-template-list)
  (declare (ignore mob-template-list))
  (setf *player* (make-instance 'player :mob-type +mob-type-imp+ :x 43 :y 15))
  (add-mob-to-level-list (level world) *player*)
  (let ((soldier (make-instance 'mob :mob-type +mob-type-fiend+ :x (+ (x *player*) 0) :y (- (y *player*) 1)))
        ;(demon (make-instance 'mob :mob-type +mob-type-man+ :x (+ (x *player*) 3) :y (+ (y *player*) 3)))
        )
    ;(setf (cur-hp demon) 1)
    ;(set-mob-effect *player* +mob-effect-divine-shield+ 100)
    (set-mob-effect *player* +mob-effect-reveal-true-form+ 5)
    (set-mob-effect *player* +mob-effect-calling-for-help+ 100)
    ;(setf (cur-fp *player*) (1- (max-fp *player*)))
    (add-mob-to-level-list (level world) soldier)
    ;(add-mob-to-level-list (level world) demon)

    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part+ :x (+ (x *player*) 0) :y (+ (y *player*) 1)))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-man+ :x (+ (x *player*) 3) :y (+ (y *player*) 4)))
    ))
