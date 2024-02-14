
(in-package :cotd-sdl)

(defun create-template-city (template-level max-x max-y max-z set-max-buildings-func set-reserved-buildings-func
                             &optional (terrains (list +level-city-park+ +building-city-park-tiny+
                                                       +level-city-terrain-border+ #'(lambda ()
                                                                                       +terrain-border-floor+)
                                                       +level-city-terrain-dirt+ #'(lambda ()
                                                                                      (if (< (random 100) 20)
                                                                                        +terrain-floor-dirt-bright+
                                                                                        +terrain-floor-dirt+))
                                                       +level-city-terrain-grass+ #'(lambda ()
                                                                                     +terrain-floor-grass+)
                                                       +level-city-terrain-tree+ #'(lambda ()
                                                                                     +terrain-tree-birch+)
                                                       +level-city-terrain-bush+ #'(lambda ()
                                                                                     +terrain-wall-bush+)
                                                       +level-city-terrain-earth+ #'(lambda ()
                                                                                      +terrain-wall-earth+))))
  
  (log:info "Start")

  ;; make a template level
  ;; and an enlarged grid with scale 1 to 10 cells of template level
  ;; grid will be used to make reservations for buildings
  ;; once all places on grid are reserved, put actual buildings to the template level in places that were reserved 
  (let* ((reserv-max-x (array-dimension template-level 0)) (reserv-max-y (array-dimension template-level 1)) ;(reserv-max-z max-z)
         (terrain-level (make-array (list max-x max-y max-z) :element-type 'fixnum :initial-element (funcall (getf terrains +level-city-terrain-border+))))
         (feature-list ())
         (mob-list ())
         (item-list ())
         (build-list ())
         (max-building-types (make-hash-table))
         (reserved-building-types (make-hash-table))
         )

    ;; set up maximum building types for this kind of map
    (when set-max-buildings-func
      (setf max-building-types (funcall set-max-buildings-func)))

    ;; set up reserved building types for this kind of map
    (when set-reserved-buildings-func
      (setf reserved-building-types (funcall set-reserved-buildings-func)))

    (print-reserved-level template-level)

    ;; make reservations from reserved buildings on the grid level
    (loop for gen-building-type-id being the hash-key in reserved-building-types do
      (loop repeat (gethash gen-building-type-id reserved-building-types)
            with build-cur-list = nil
            with build-picked = nil
            with x = 0
            with y = 0
            for avail-cells-list = (loop with result = ()
                                         for x1 from 0 below reserv-max-x do
                                           (loop for y1 from 0 below reserv-max-y do
                                             (push (list x1 y1) result))
                                         finally (return result))
            do
               ;; prepare a list of buildings of this reserved type
               (setf build-cur-list (prepare-spec-build-id-list gen-building-type-id))
               
               ;; pick a specific building type
               (setf build-picked (nth (random (length build-cur-list)) build-cur-list))
               
               ;; try to pick an unoccupied place
               (loop for cell-pick = (nth (random (length avail-cells-list)) avail-cells-list)
                     
                     until (level-city-can-place-build-on-grid build-picked (first cell-pick) (second cell-pick) 2 template-level)
                     do
                        (setf avail-cells-list (remove cell-pick avail-cells-list))
                        (when (null avail-cells-list)
                          (log:info "Could not place reserved building ~A" build-picked)
                          (print-reserved-level template-level)
                          (return-from create-template-city (values nil nil nil nil)))
                     finally (setf x (first cell-pick) y (second cell-pick)))

               ;; if an unoccupied place is found, place the building
               (when build-picked
                 ;; add the building to the building list and reserve the tiles for the bilding
                 (level-city-reserve-build-on-grid build-picked x y 2 template-level)
                 
                 ;; decrease the maximum available number of buildings of this type
                 (when (and (gethash (building-type (get-building-type build-picked)) max-building-types)
                            (not (eq (gethash (building-type (get-building-type build-picked)) max-building-types) t)))
                   (decf (gethash (building-type (get-building-type build-picked)) max-building-types))))
            ))
    
    ;; make reservations for random buildings of the grid level
    (loop for y from 0 below reserv-max-y do
      (loop for x from 0 below reserv-max-x 
            with build-picked = nil
            with build-cur-list = nil
            do
               ;; prepare the list of buildings
               ;; so that it becomes ((1 2 3) (4) (5 6) ...)
               (setf build-cur-list (prepare-gen-build-id-list max-building-types +building-type-house+))
               
               ;; randomly pick a building and remove it from the list if it does not fit or the maximum number of this kind of buildings have been reached
               ;; until we find a building that fits or nothing is left 
               (loop initially (multiple-value-setq (build-picked build-cur-list) (pick-building-randomly build-cur-list))
                     until (or (and (gethash (building-type (get-building-type build-picked)) max-building-types)
                                    (or (eq (gethash (building-type (get-building-type build-picked)) max-building-types) t)
                                        (> (gethash (building-type (get-building-type build-picked)) max-building-types) 0))
                                    (level-city-can-place-build-on-grid build-picked x y 2 template-level))
                               )
                     do
                        (unless build-cur-list
                          (setf build-picked nil)
                          (loop-finish))
                        (multiple-value-setq (build-picked build-cur-list) (pick-building-randomly build-cur-list))
                     )
               
               ;;  check if there was a building picked
               (when build-picked
                 ;; if yes, add the building to the building list and reserve the tiles for the building
                 (level-city-reserve-build-on-grid build-picked x y 2 template-level)
                 
                 ;; decrease the maximum available number of buildings of this type
                 (when (and (gethash (building-type (get-building-type build-picked)) max-building-types)
                            (not (eq (gethash (building-type (get-building-type build-picked)) max-building-types) t)))
                   (decf (gethash (building-type (get-building-type build-picked)) max-building-types)))
                 )
            ))
    
    ;; fill all free spaces left with +level-city-park+
    (loop for y from 0 below reserv-max-y do
      (loop for x from 0 below reserv-max-x 
            do
               ;;  check if you can place a tiny park
               (when (level-city-can-place-build-on-grid (getf terrains +level-city-park+) x y 2 template-level)
                 ;; if yes, add the building to the building list & reserve the tiles for the building
                 (level-city-reserve-build-on-grid (getf terrains +level-city-park+) x y 2 template-level)
                 )
            ))

    (loop for y from 0 below max-y do
      (loop for x from 0 below max-x do
        (loop for z from 3 below max-z do
          (setf (aref terrain-level x y z) +terrain-border-air+))))

    (loop for y from 0 below max-y do
      (loop for x from 0 below max-x do
        (loop for z from 0 below 2 do
          (setf (aref terrain-level x y z) (if (getf terrains +level-city-terrain-earth+)
                                             (funcall (getf terrains +level-city-terrain-earth+))
                                             +terrain-wall-earth+)))))
    
    (loop for y from 1 below (1- max-y) do
      (loop for x from 1 below (1- max-x) do
       
        (setf (aref terrain-level x y 2) (funcall (getf terrains +level-city-terrain-dirt+)))
        
        (loop for z from 3 below max-z do
          (setf (aref terrain-level x y z) +terrain-floor-air+))))
    
    (print-reserved-level template-level)

     ;; create a building list from template-level
    (loop for x from 0 below reserv-max-x do
      (loop for y from 0 below reserv-max-y
            for building = (aref template-level x y 2)
            when (and (not (eq building t))
                      (not (eq building nil))
                      (not (find building build-list)))
              do
                 (push building build-list)))
    
    ;; take buildings from the building list and actually place them on the template level
    (loop for (build-type-id gx gy gz) in build-list 
          with px = 0
          with py = 0
          for building-mobs = nil
          for building-features = nil
          for building-items = nil
          do
             ;; find a random position within the grid on the template level so that the building does not violate the grid boundaries
             (destructuring-bind (adx . ady) (building-act-dim (get-building-type build-type-id))
               (destructuring-bind (gdx . gdy) (building-grid-dim (get-building-type build-type-id))
                 (setf px (random (1+ (- (* *level-grid-size* gdx) adx))))
                 (setf py (random (1+ (- (* *level-grid-size* gdy) ady))))))
             
             ;; place the actual building
             (when (building-func (get-building-type build-type-id))
               (multiple-value-setq (building-mobs building-features building-items) (funcall (building-func (get-building-type build-type-id))
                                                                                              (+ (* gx *level-grid-size*) px) (+ (* gy *level-grid-size*) py) gz
                                                                                              terrain-level
                                                                                              terrains)))

             ;(log:info (format nil "CREATE-TEMPLATE-CITY: Building type ~A, mob list ~A~%" build-type-id building-mobs))
             ;; add mobs to the mob-list
             (when building-mobs
               (loop for (mob-id lx ly lz) in building-mobs do
                 (pushnew (list mob-id (+ (* gx *level-grid-size*) px lx) (+ (* gy *level-grid-size*) py ly) lz) 
                          mob-list)))

             ;; add features to the feature list
             (when building-features
               (loop for (feature-id lx ly lz) in building-features do
                 (pushnew (list feature-id (+ (* gx *level-grid-size*) px lx) (+ (* gy *level-grid-size*) py ly) lz) 
                          feature-list)))

             ;; add items to the item list
             (when building-items
               (loop for (item-id lx ly lz qty) in building-items do
                 (pushnew (list item-id (+ (* gx *level-grid-size*) px lx) (+ (* gy *level-grid-size*) py ly) lz qty) 
                          item-list)))
          )

    ;; restore borders
    (loop for x from 0 below max-x do
      (loop for z from 0 below max-z
            for y-0 = 0
            for y-max = (1- (array-dimension terrain-level 1))
            do
        (cond
          ((= (aref terrain-level x y-0 z) +terrain-floor-air+) (setf (aref terrain-level x y-0 z) +terrain-border-air+))
          ((= (aref terrain-level x y-0 z) +terrain-water-liquid+) (setf (aref terrain-level x y-0 z) +terrain-border-water+))
          ((= (aref terrain-level x y-0 z) +terrain-water-liquid-nofreeze+) (setf (aref terrain-level x y-0 z) +terrain-border-water+)))
        (cond
          ((= (aref terrain-level x y-max z) +terrain-floor-air+) (setf (aref terrain-level x y-max z) +terrain-border-air+))
          ((= (aref terrain-level x y-max z) +terrain-water-liquid+) (setf (aref terrain-level x y-max z) +terrain-border-water+))
          ((= (aref terrain-level x y-max z) +terrain-water-liquid-nofreeze+) (setf (aref terrain-level x y-max z) +terrain-border-water+)))))
    (loop for y from 0 below max-y do
      (loop for z from 0 below max-z
            for x-0 = 0
            for x-max = (1- (array-dimension terrain-level 0))
            do
        (cond
          ((= (aref terrain-level x-0 y z) +terrain-floor-air+) (setf (aref terrain-level x-0 y z) +terrain-border-air+))
          ((= (aref terrain-level x-0 y z) +terrain-water-liquid+) (setf (aref terrain-level x-0 y z) +terrain-border-water+))
          ((= (aref terrain-level x-0 y z) +terrain-water-liquid-nofreeze+) (setf (aref terrain-level x-0 y z) +terrain-border-water+)))
        (cond
          ((= (aref terrain-level x-max y z) +terrain-floor-air+) (setf (aref terrain-level x-max y z) +terrain-border-air+))
          ((= (aref terrain-level x-max y z) +terrain-water-liquid+) (setf (aref terrain-level x-max y z) +terrain-border-water+))
          ((= (aref terrain-level x-max y z) +terrain-water-liquid-nofreeze+) (setf (aref terrain-level x-max y z) +terrain-border-water+)))))
    
    (values terrain-level mob-list item-list feature-list)
    ))

(defun print-reserved-level (reserved-level)
  (let ((str (create-string)))
    (format str "~%")
    (loop for y from 0 below (array-dimension reserved-level 1) do
      (loop for x from 0 below (array-dimension reserved-level 0) do
        (format str "~3@A " (cond
                              ((null (aref reserved-level x y 2)) "F")
                              ((eq (aref reserved-level x y 2) t) "R")
                              (t (first (aref reserved-level x y 2))))))
      (format str "~%"))
    (log:info str)))

(defun pick-building-randomly (build-cur-list)
  (let ((building-picked nil) (type-picked nil))
    ;; first pick a general building type
    (setf type-picked (random (length build-cur-list)))

    ;; within a general building type pick a specific building type
    (setf building-picked (nth (random (length (nth type-picked build-cur-list))) (nth type-picked build-cur-list)))
    
    ;; remove the specific building type from the list
    (setf (nth type-picked build-cur-list) (remove building-picked (nth type-picked build-cur-list)))
    
    ;; remove the general building type if no specific ones are left
    (unless (nth type-picked build-cur-list)
      (setf build-cur-list (remove nil build-cur-list)))
    
    (values building-picked build-cur-list)))

(defun prepare-gen-build-id-list (max-building-types &optional increased-build-type-id)
  ;; a hack to make houses appear 3 times more frequently
  (append (loop repeat 3
                collect (prepare-spec-build-id-list increased-build-type-id))
          (loop for gen-build-type-id being the hash-key in max-building-types
                collect (prepare-spec-build-id-list gen-build-type-id))))

(defun prepare-spec-build-id-list (gen-build-type-id)
  (loop for spec-build-type being the hash-value in *building-types*
        when (= (building-type spec-build-type) gen-build-type-id)
          collect (building-id spec-build-type)))
