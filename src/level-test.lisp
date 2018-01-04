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
        (level-template-z-0 (list "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"
                                  "##############################################################################"))
        (level-template-z-1 (list ".............................................................................."
                                  ".............................................................................."
                                  "...#######..#######.############..........................######.....######..."
                                  "...#.....#..#.....#.#....#..#..#..........................#....#.....#....#..."
                                  "...#.....#..#.....#.#.......u..#..........................#..........#....#..."
                                  "...#.....#..#.....#.#....#.....#..........................#....#.....#....#..."
                                  "...###+###..###+###.########.###..........................######.....######..."
                                  ".............................................................................."
                                  "..........................................................######.....######..."
                                  "..........................................................#....#..........#..."
                                  "...###+###................................................#...............#..."
                                  "...#.....#................................................#....#..........#..."
                                  "...#.....#................................................######.....######..."
                                  "...#.....#............#####.......#####,,,,..................................."
                                  "...#######............#...............-.,,,..................................."
                                  "......................#...............#u,,,..................................."
                                  "...#######...........u######-#+#########..................######.....######..."
                                  "...#.....#............#....#.....#_____#..................#...............#..."
                                  "...#.....+............#....+....###____#..................#...............#..."
                                  "...#.....#............#....#....###____#..................#...............#..."
                                  "...#######............##################..................#################..."
                                  ".............................................................................."
                                  ".............................................................................."))
        
        (level-template-z-2 (list "                                                                              "
                                  "                                                                              "
                                  "   .......  ....... ############                          ......     ......   "
                                  "   .......  ....... #..........#                          ......     ......   "
                                  "   .......  ....... #.......d..#                          ......     ......   "
                                  "   .......  ....... #..........#                          ......     ......   "
                                  "   .......  ....... ##########-#                          ......     ......   "
                                  "                                                       |                      "
                                  "                                                          ......     ......   "
                                  "                                                          ......     ......   "
                                  "   .......                                                ......     ......   "
                                  "   .......                                                ......     ......   "
                                  "   .......                                     |          ......     ......   "
                                  "   .......            .....       .....                                       "
                                  "   .......            .....       .bb..                                       "
                                  "                      .....      ......d                                      "
                                  "   .......           d............######|                  .................   "
                                  "   .......            ....u......u#____#                  .................   "
                                  "   .......            ..#####...###____#                  .................   "
                                  "   .......            ..#.......#_#____#                  .................   "
                                  "   .......            ..################                  .................   "
                                  "                                                                              "
                                  "                                                                              "))
        
        (level-template-z-3 (list "                                                                              "
                                  "                                                                              "
                                  "                    ............                                              "
                                  "                    ............                                              "
                                  "                    ............                                              "
                                  "                    ............                                              "
                                  "                    ............                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                                                              "
                                  "                                  ......                                      "
                                  "                          d      d.    .                                      "
                                  "                        ........... |  .                                      "
                                  "                        ......... .    .                                      "
                                  "                        ................                                      "
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

    (loop for level in (list level-template-z-0 level-template-z-1 level-template-z-2 level-template-z-3)
          for z from 0 to 3 do
            (loop for y from 0 below (length level) do
              (loop for c across (nth y level)
                    for x from 0
                    for tt = (case c
                               (#\. +terrain-floor-stone+)
                               (#\, +terrain-floor-grass+)
                               (#\# +terrain-wall-stone+)
                               (#\- +terrain-wall-window+)
                               (#\+ +terrain-door-closed+)
                               (#\b +terrain-floor-bed+)
                               (#\' +terrain-door-open+)
                               (#\Space +terrain-floor-air+)
                               (#\u +terrain-slope-stone-up+)
                               (#\d +terrain-slope-stone-down+)
                               (#\T +terrain-tree-birch+)
                               (#\| +terrain-wall-lantern+)
                               (#\_ +terrain-water-liquid+))
                           
                    when tt
                      do
                         (setf (aref template-level (1+ x) (1+ y) z) tt)
                    )))
    
    
    
    
    (values template-level feature-list nil nil)
    ))

(defun test-level-place-mobs (world mob-template-list)
  (declare (ignore mob-template-list))
  (setf *player* (make-instance 'player :mob-type +mob-type-angel+ :x 45 :y 19 :z 3))
  (add-mob-to-level-list (level world) *player*)
  
  (let ((soldier (make-instance 'mob :mob-type +mob-type-ghost+ :x 50 :y 18 :z 2))
        ;(demon (make-instance 'mob :mob-type +mob-type-man+ :x 49 :y 19 :z 3))
        ;(angel (make-instance 'mob :mob-type +mob-type-angel+ :x 49 :y 17 :z 3))
        )
    (setf (cur-fp *player*) 15)
    (setf (max-hp *player*) 50)
    (setf (cur-hp *player*) 50)
    ;(setf (cur-fp angel) 5)
   ; (setf (cur-fp demon) 2)

    ;(mob-set-mutation *player* +mob-abil-clawed-tentacle+)
    ;(mob-set-mutation *player* +mob-abil-piercing-needles+)
    ;(mob-remove-ability *player* +mob-abil-possessable+)

    ;(setf (aref (terrain (level world)) (x *player*) (y *player*) (z *player*)) +terrain-water-ice+)
    ;(set-mob-effect *player* +mob-effect-divine-shield+ 100)
    ;(set-mob-effect *player* +mob-effect-called-for-help+ 10)
    ;(set-mob-effect demon +mob-effect-calling-for-help+ 100)
    ;(setf (cur-fp soldier) 20)
    ;(set-mob-effect soldier :effect-type-id +mob-effect-blessed+ :actor-id (id soldier))
    (add-mob-to-level-list (level world) soldier)
    ;(add-mob-to-level-list (level world) demon)
    ;(add-mob-to-level-list (level world) angel)
    
    ;(setf (mimic-id-list *player*) (list (id angel) (id soldier) (id demon)))
    ;(setf (mimic-id-list soldier) (list (id angel) (id soldier) (id demon)))
    ;(setf (mimic-id-list demon) (list (id angel) (id soldier) (id demon)))

    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x 35 :y 13 :z 1))

    ;(mob-pick-item *player* (make-instance 'item :item-type +item-type-body-part+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0))
    ;               :spd nil)
    ;(mob-pick-item *player* (make-instance 'item :item-type +item-type-body-part+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0))
    ;               :spd nil)
    ;(mob-pick-item demon (make-instance 'item :item-type +item-type-coin+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 5) :spd nil :silent t)
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-coin+ :x (+ (x *player*) 1) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 105))
    (add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part-full+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    (add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part-full+ :x (+ (x *player*) 1) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-body-part-half+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-clothing+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-disguise+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-disguise+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-deck-of-war+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-deck-of-escape+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    (add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-eater-parasite+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 1))
    (add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-signal-flare+ :x (+ (x *player*) 0) :y (+ (y *player*) 0) :z (+ (z *player*) 0) :qty 3))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-fire+  :x (+ (x *player*) 1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-smoke-thin+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-smoke-thin+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-smoke-thin+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-smoke-thin+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-smoke-thin+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    ;(add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-blood-fresh+  :x (+ (x *player*) -1) :y (+ (y *player*) 0) :z (+ (z *player*) 0)))
    (add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-demonic-rune+  :x 40 :y 19 :z 1))
    ;(add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-coin+ :x (+ (x *player*) 0) :y (+ (y *player*) 1) :z (+ (z *player*) 0) :qty 75))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-imp+ :x 41 :y 18 :z 0))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-reanimated-pwr-1+ :x 41 :y 19 :z 0))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x 35 :y 19 :z 2))
    ;(add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-demon+ :x 40 :y 17 :z 2))
    ))
