(in-package :cotd)

;; the level generation function takes the following parameters:
;;   sector-level-gen-func - main funcation to generate a level from template (for example, city level)
;;      takes:   (template-level set-max-buildings-func set-reserved-buildings-func)
;;      returns: (real-terrain mob-template-list item-template-list feature-template-list)
;;   item-process-func-list - list of functions that generate items on the level
;;      takes:   (item-template-list)
;;      returns: (list of items)
;;   feature-process-func-list - list of functions that generate features on the level
;;      takes:   (feature-template-list)
;;      returns: (list of features)
;;   mob-process-func-list - list of functions that generate mobs on the level
;;      takes:   (mob-template-list)
;;      returns: (list of mobs)
;;   level-template-pre-process-func-list - list of functions that modify the template level before the sector-level-gen-func
;;      takes:   (template-level)
;;      returns: (template-level (list of buildings))
;;   terrain-level-post-process-func-list - list of functions that modify the real terrain on the level after the sector-level-gen-func
;;      takes:   (real-terrain)
;;      returns: (real-terrain)
;;

(defun generate-level-from-sector (sector-level-gen-func &key (max-x *max-x-level*) (max-y *max-y-level*) (max-z *max-z-level*)
                                                              (overall-post-process-func-list ())
                                                              (level-template-pre-process-func-list ())
                                                              (terrain-level-post-process-func-list ())
                                                              
                                                              (world-sector nil)
                                                              (mission nil)
                                                              (world nil)
                                                              )

  (unless world-sector (error ":WORLD-SECTOR is an obligatory parameter!"))
  (unless mission (error ":MISSION is an obligatory parameter!"))
  (unless world (error ":WORLD is an obligatory parameter!"))
  
  ;; create a template level
  (let* ((level nil)
         (terrain-level nil)
         (feature-template-result nil)
         (mob-template-result nil)
         (item-template-result nil))
    (let* ((template-max-x (truncate max-x *level-grid-size*)) (template-max-y (truncate max-y *level-grid-size*)) (template-max-z max-z)
           (template-level (make-array (list template-max-x template-max-y template-max-z) :initial-element t))
           ;; the values in template-level are as follows:
           ;;   t - reserved
           ;;   nil - free
           ;;   list of (+building-type-<id>+ x y z)
           )

      (setf *max-progress-bar* 10)
      (setf *cur-progress-bar* 0)

      (funcall *update-screen-closure* "Generating map")
      
      ;; all grid cells along the borders are reserved, while everything inside is free for claiming
      (loop for y from 1 below (1- template-max-y) do
        (loop for x from 1 below (1- template-max-x) do
          (loop for z from 0 below template-max-z do
            (setf (aref template-level x y z) nil))))
      
      ;; use level template pre-process functions to place reserved buildings from sector features, factions, etc
      (loop for level-template-pre-process-func in level-template-pre-process-func-list do
        (funcall level-template-pre-process-func template-level world-sector mission world))

      ;; adjusting the progress bar : 1
      (incf *cur-progress-bar*)
      (funcall *update-screen-closure* nil)
      
      ;; produce terrain level from template using the supplied function
      (multiple-value-setq (terrain-level mob-template-result item-template-result feature-template-result) (funcall sector-level-gen-func
                                                                                                                     template-level
                                                                                                                     max-x max-y max-z))

      ;; create level with dimenision based on terrain-level dimensions
      (setf level (create-level :max-x (array-dimension terrain-level 0) :max-y (array-dimension terrain-level 1) :max-z (array-dimension terrain-level 2)))
      
      (setf (terrain level) terrain-level)
      (setf (level world) level)

      ;; adjusting the progress bar : 2
      (incf *cur-progress-bar*)
      (funcall *update-screen-closure* nil)

      (setf (mob-quadrant-map level) (make-array (list (ceiling (array-dimension (terrain level) 0) 10)
                                                       (ceiling (array-dimension (terrain level) 1) 10))
                                                 :initial-element ()))
      (setf (item-quadrant-map level) (make-array (list (ceiling (array-dimension (terrain level) 0) 10)
                                                        (ceiling (array-dimension (terrain level) 1) 10))
                                                  :initial-element ()))
      (setf (light-quadrant-map level) (make-array (list (ceiling (array-dimension (terrain level) 0) 10)
                                                         (ceiling (array-dimension (terrain level) 1) 10))
                                                   :initial-element ()))

      (setf (mission level) mission)
      (setf (world-sector level) world-sector)

      ;; populate world with items
      (log:info "Placing standard items")
      (loop for (item-type-id x y z qty) in item-template-result 
            do
               (add-item-to-level-list level (make-instance 'item :item-type item-type-id :x x :y y :z z :qty qty)))
      
      ;; populate world with features
      (log:info "Placing standard features")
      (loop for (feature-type-id x y z) in feature-template-result 
            do
               (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z)))

      ;; adjusting the progress bar : 3
      (incf *cur-progress-bar*)
      (funcall *update-screen-closure* nil)
      
      ;; post process actual level (demonic portals, blood spatter, irradiated spots, etc)
      (loop for terrain-post-process-func in terrain-level-post-process-func-list do
        (setf terrain-level (funcall terrain-post-process-func level world-sector mission world)))      
      )
    
    ;; check map for connectivity : 4
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Creating connectivity maps")

    (setf *time-at-end-of-player-turn* (get-internal-real-time))
    
    ;; generate connectivity maps
    (let* ((size-1-thread (bt:make-thread #'(lambda ()
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-walk level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (log:info "TIME-ELAPSED AFTER WALK 1: ~A" (- (get-internal-real-time) start-time))
                                                )

                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-climb level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (log:info "TIME-ELAPSED AFTER CLIMB 1: ~A" (- (get-internal-real-time) start-time))
                                                )

                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-fly level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (log:info "TIME-ELAPSED AFTER FLY 1: ~A" (- (get-internal-real-time) start-time))
                                                )
                                              )
                                        :name "Connectivity map (size 1) thread"))
           (size-3-thread (bt:make-thread #'(lambda ()
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-walk level 3)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (log:info "TIME-ELAPSED AFTER WALK 3: ~A" (- (get-internal-real-time) start-time))
                                                )
                                              
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-climb level 3)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (log:info "TIME-ELAPSED AFTER CLIMB 3: ~A" (- (get-internal-real-time) start-time))
                                                )

                                              ;;(let ((start-time (get-internal-real-time)))
                                              ;;  (create-connect-map-fly (level world) 3)
                                              ;;  (incf *cur-progress-bar*)
                                              ;;  (funcall *update-screen-closure* nil)
                                              ;;  (format out "TIME-ELAPSED AFTER FLY 3: ~A~%" (- (get-internal-real-time) start-time))
                                              ;;  )
                                              )
                                         :name "Connectivity map (size 3) thread"))
           )
      (bt:join-thread size-1-thread)
      (log:info "SIZE 1 CREATION FINISHED")
      (bt:join-thread size-3-thread)
      (log:info "SIZE 3 CREATION FINISHED")
      )

    ;; adjusting the progress bar : 10
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Finalizing")
    
    (push +game-event-adjust-outdoor-light+ (game-events level))

    ;; populate world with standard mobs (from actual level template)
    (log:info "Placing standard mobs")
    (loop for (mob-type-id x y z) in mob-template-result
          when (null (get-mob-* level x y z))
            do
               (add-mob-to-level-list level (make-instance 'mob :mob-type mob-type-id :x x :y y :z z)))

    ;; populate the world with special mobs (military in outposts, demons around portals, etc) depending on present factions
    (loop for overall-post-process-func in overall-post-process-func-list
          do
             (funcall overall-post-process-func level world-sector mission world))

    ;; setting up demonic portals so that mobs could access them directly without iterating through the whole list of features
    (loop for feature-id in (feature-id-list (level world))
          for feature = (get-feature-by-id feature-id)
          when (= (feature-type feature) +feature-demonic-portal+)
            do
               (push feature-id (demonic-portals level)))
    ) 
  )

(defun create-level (&key (max-x *max-x-level*) (max-y *max-y-level*) (max-z *max-z-level*))
  (let ((level))
    (setf level (make-instance 'level))
    (setf (terrain level) (make-array (list max-x max-y max-z) :initial-element +terrain-floor-stone+))
    (setf (mobs level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (items level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (features level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (memo level) (make-array (list max-x max-y max-z)))
    (setf (light-map level) (make-array (list max-x max-y max-z) :initial-element 0))
    (loop for x from 0 below max-x do
      (loop for y from 0 below max-y do
        (loop for z from 0 below max-z do
          (set-memo-* level x y z (create-single-memo 0 sdl:*white* sdl:*black* nil nil 0 nil)))))
    level))

(defun reserve-build-on-grid (template-building-id gx gy gz template-level)
  (destructuring-bind (dx . dy) (building-grid-dim (get-building-type template-building-id))
    (let ((building (list template-building-id gx gy gz)))
      (loop for y1 from 0 below dy do
        (loop for x1 from 0 below dx do
          (setf (aref template-level (+ gx x1) (+ gy y1) gz) building)))
      building)))

(defun can-place-build-on-grid (template-building-id gx gy gz template-level)
  (destructuring-bind (dx . dy) (building-grid-dim (get-building-type template-building-id))
    ;; if the staring point of the building + its dimensions) is more than level dimensions - fail
    (when (or (> (+ gx dx) (array-dimension template-level 0))
              (> (+ gy dy) (array-dimension template-level 1)))
      (return-from can-place-build-on-grid nil))
    
    ;; if any of the grid tiles that the building is going to occupy are already reserved - fail
    (loop for y1 from 0 below dy do
      (loop for x1 from 0 below dx do
        (unless (eq (aref template-level (+ gx x1) (+ gy y1) gz) nil)
          (return-from can-place-build-on-grid nil))
            ))
    ;; all checks done - success
    t
    ))

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

(defun flood-fill (first-cell &key (max-x *max-x-level*) (max-y *max-y-level*) (max-z *max-z-level*) check-func make-func)
  (declare (optimize (speed 3) (safety 0))
           (type function check-func make-func)
           (type fixnum max-x max-y max-z))
  
  (let ((open-list nil))
    (push first-cell open-list)
    (loop while open-list
          for c-cell of-type list = (pop open-list)
          for cx of-type fixnum = (first c-cell)
          for cy of-type fixnum = (second c-cell)
          for cz of-type fixnum = (third c-cell)
          do
             (funcall make-func cx cy cz)
             
             (loop for y-offset of-type fixnum from -1 to 1
                   for y of-type fixnum = (+ cy y-offset) do
                     (loop for x-offset of-type fixnum from -1 to 1
                           for x of-type fixnum = (+ cx x-offset) do
                           (loop for z-offset of-type fixnum from -1 to 1
                                 for z of-type fixnum = (+ cz z-offset)
                                 when (and (>= x 0) (>= y 0) (>= z 0) (< x max-x) (< y max-y) (< z max-z)
                                           (not (and (zerop x-offset) (zerop y-offset) (zerop z-offset)))
                                           (funcall check-func x y z cx cy cz))
                                   do
                                      (push (list x y z) open-list))))
                     
          )
    ))

(defun create-connect-map-walk (level mob-size)
  (declare (optimize (speed 3))
           (type fixnum mob-size))
  (let* ((max-x (array-dimension (terrain level) 0))
         (max-y (array-dimension (terrain level) 1))
         (max-z (array-dimension (terrain level) 2))
         (connect-map (if (aref (connect-map level) mob-size)
                        (aref (connect-map level) mob-size)
                        (make-array (list max-x max-y max-z) :initial-element nil)))
         (room-id 0)
         (check-func #'(lambda (x y z cx cy cz)
                         (let* ((connect-id (get-connect-map-value connect-map x y z +connect-map-move-walk+))
                                (half-size (truncate (1- mob-size) 2)))
                           (declare (type fixnum connect-id half-size cx cy cz x y z))
                           (if (and (= connect-id +connect-room-none+)
                                    (funcall #'(lambda (sx sy)
                                                 (let ((result t))
                                                   (block from-result
                                                     (loop for off-x of-type fixnum from (- half-size) to (+ half-size)
                                                           for nx of-type fixnum = (+ sx off-x) do
                                                             (loop for off-y of-type fixnum from (- half-size) to (+ half-size)
                                                                   for ny of-type fixnum = (+ sy off-y) do
                                                                     
                                                                     (when (or (< nx 0) (< ny 0) (>= nx max-x) (>= ny max-y)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-openable-door+))
                                                                       (setf result nil)
                                                                       (return-from from-result))
                                                                     
                                                                     ;; magic starts here
                                                                     (setf result nil)

                                                                     (when (and (or (= (- cz z) 0)
                                                                                    (and (/= (- cz z) 0)
                                                                                         (= nx cx)
                                                                                         (= ny cy))
                                                                                    )
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | |p| |
                                                                     ;;    floor z = 1 -> | |.| |
                                                                     ;; on floor z = 0 -> | |x| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    w - water
                                                                     ;;    . - air (no floor, no wall, no water)
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (not result)
                                                                                (< (- z cz) 0)
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                                (and (= cx nx)
                                                                                     (= cy ny))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | | |x|
                                                                     ;;    floor z = 1 -> | | |#|
                                                                     ;; on floor z = 0 -> | |p| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    . - air
                                                                     ;;    w - water
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (> (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+)
                                                                                (not (and (= cx nx)
                                                                                          (= cy ny)))
                                                                                (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+))
                                                                                (or (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)
                                                                                    (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)))
                                                                       ;(format t "FLOOD FILL HERE~%")
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | | |x|
                                                                     ;;    floor z = 1 -> | | |#|
                                                                     ;; on floor z = 0 -> | |p| |
                                                                     ;;    floor z = 0 -> | |u| |
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    . - air
                                                                     ;;    u - slope up (with floor)
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (> (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-slope-up+)
                                                                                (not (and (= cx nx)
                                                                                          (= cy ny)))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+))
                                                                       ;(format t "FLOOD FILL HERE~%")
                                                                       (setf result t))

                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | |p| |
                                                                     ;;    floor z = 1 -> | |d| |
                                                                     ;; on floor z = 0 -> | |x| |
                                                                     ;;    floor z = 0 -> | |u| |
                                                                     ;; where
                                                                     ;;    u - slope up (with floor)
                                                                     ;;    d - slope down (with air)
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (not result)
                                                                                (< (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-slope-down+)
                                                                                (and (= cx nx)
                                                                                     (= cy ny))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-slope-up+)
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+))
                                                                       (setf result t))

                                                                     ;; the following case is connected
                                                                     ;; on floor z = 0 -> | |x|p|
                                                                     ;;    floor z = 0 -> | |?|#|
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    ? - not important
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (not result)
                                                                                (= (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+)
                                                                                ;(not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+))
                                                                                )
                                                                       (setf result t))

                                                                     ;; if you are large, you can move only if all you tiles have opaque floor
                                                                     (when (and (> mob-size 1)
                                                                                (= (- z cz) 0)
                                                                                (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)))
                                                                       (setf result nil))

                                                                     ;; all other cases are disconnected 
                                                                     (unless result
                                                                       (return-from from-result))
                                                                     )))
                                                   result))
                                             x y))
                             t
                             nil))))
         (make-func #'(lambda (x y z)
                        (set-connect-map-value connect-map x y z +connect-map-move-walk+ room-id)
                        )))
    (declare (type fixnum max-x max-y max-z room-id))
    
    (loop for x of-type fixnum from 0 below max-x do
      (loop for y of-type fixnum from 0 below max-y do
        (loop for z of-type fixnum from 0 below max-z do
          (when (funcall check-func x y z x y z)
            (flood-fill (list x y z) :max-x max-x :max-y max-y :max-z max-z :check-func check-func :make-func make-func)
            (incf room-id))
              )))
    (setf (aref (connect-map level) mob-size) connect-map)
    ))

(defun create-connect-map-climb (level mob-size)
  (declare (optimize (speed 3))
           (type fixnum mob-size))
  (let* ((max-x (array-dimension (terrain level) 0))
         (max-y (array-dimension (terrain level) 1))
         (max-z (array-dimension (terrain level) 2))
         (connect-map (if (aref (connect-map level) mob-size)
                        (aref (connect-map level) mob-size)
                        (make-array (list max-x max-y max-z) :initial-element nil)))
         (room-id 0)
         (check-func #'(lambda (x y z cx cy cz)
                         (let* ((connect-id (get-connect-map-value connect-map x y z +connect-map-move-climb+))
                                (half-size (truncate (1- mob-size) 2)))
                           (declare (type fixnum connect-id half-size cx cy cz x y z))
                           (if (and (= connect-id +connect-room-none+)
                                    (funcall #'(lambda (sx sy)
                                                 (let ((result t))
                                                   (block from-result
                                                     (loop for off-x of-type fixnum from (- half-size) to (+ half-size)
                                                           for nx of-type fixnum = (+ sx off-x) do
                                                             (loop for off-y of-type fixnum from (- half-size) to (+ half-size)
                                                                   for ny of-type fixnum = (+ sy off-y) do
                                                                     (when (or (< nx 0) (< ny 0) (>= nx max-x) (>= ny max-y)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-openable-door+))
                                                                       (setf result nil)
                                                                       (return-from from-result))
                                                                     
                                                                     ;; magic starts here
                                                                     (setf result nil)

                                                                     (when (and (or (= (- cz z) 0)
                                                                                    (and (/= (- cz z) 0)
                                                                                         (= nx cx)
                                                                                         (= ny cy))
                                                                                    )
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | |p| |
                                                                     ;;    floor z = 1 -> | |.| |
                                                                     ;; on floor z = 0 -> | |x| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    w - water
                                                                     ;;    . - air (no floor, no wall, no water)
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (not result)
                                                                                (< (- z cz) 0)
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                                (and (= cx nx)
                                                                                     (= cy ny))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | | |x|
                                                                     ;;    floor z = 1 -> | | |#|
                                                                     ;; on floor z = 0 -> | |p| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    . - air
                                                                     ;;    w - water
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (> (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+)
                                                                                (not (and (= cx nx)
                                                                                          (= cy ny)))
                                                                                (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+))
                                                                                (or (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)
                                                                                    (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)))
                                                                       ;(format t "FLOOD FILL HERE~%")
                                                                       (setf result t))

                                                                     ;; the following case is connected
                                                                     ;; on floor z = 0 -> | |x|p|
                                                                     ;;    floor z = 0 -> | |?|#|
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    ? - not important
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (= (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+)
                                                                                )
                                                                       (setf result t))

                                                                     (when (and (not result)
                                                                                (or (= (- cz z) 0)
                                                                                    (and (/= (- cz z) 0)
                                                                                         (= nx cx)
                                                                                         (= ny cy)))
                                                                                (check-move-along-z cx cy cz nx ny z)
                                                                                (funcall #'(lambda ()
                                                                                             (let ((result nil))
                                                                                               (block surround
                                                                                                 (check-surroundings nx ny nil
                                                                                                                     #'(lambda (mx my)
                                                                                                                         (when (and (get-terrain-* (level *world*) mx my z)
                                                                                                                                    (not (get-terrain-type-trait (get-terrain-* (level *world*) mx my z) +terrain-trait-not-climable+))
                                                                                                                                    (or (get-terrain-type-trait (get-terrain-* (level *world*) mx my z) +terrain-trait-blocks-move-floor+)
                                                                                                                                        (get-terrain-type-trait (get-terrain-* (level *world*) mx my z) +terrain-trait-blocks-move+)))
                                                                                                                           
                                                                                                                           (setf result t)
                                                                                                                           (return-from surround)))))
                                                                                               result))))
                                                                       (setf result t))

                                                                     ;; if you are large, you can move only if all you tiles have opaque floor
                                                                     (when (and (> mob-size 1)
                                                                                (= (- z cz) 0)
                                                                                (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)))
                                                                       (setf result nil))
                                                                     
                                                                     ;; all other cases are disconnected 
                                                                     (unless result
                                                                       (return-from from-result))
                                                                   )))
                                                   result))
                                             x y))
                             t
                             nil))))
         (make-func #'(lambda (x y z)
                        (set-connect-map-value connect-map x y z +connect-map-move-climb+ room-id)
                        )))
    (declare (type fixnum max-x max-y max-z room-id))
    
    (loop for x of-type fixnum from 0 below max-x do
      (loop for y of-type fixnum from 0 below max-y do
        (loop for z of-type fixnum from 0 below max-z do
          (when (funcall check-func x y z x y z)
            (flood-fill (list x y z) :max-x max-x :max-y max-y :max-z max-z :check-func check-func :make-func make-func)
            (incf room-id))
              )))
    
    (setf (aref (connect-map level) mob-size) connect-map)))

(defun create-connect-map-fly (level mob-size)
  (declare (optimize (speed 3))
           (type fixnum mob-size))
  (let* ((max-x (array-dimension (terrain level) 0))
         (max-y (array-dimension (terrain level) 1))
         (max-z (array-dimension (terrain level) 2))
         (connect-map (if (aref (connect-map level) mob-size)
                        (aref (connect-map level) mob-size)
                        (make-array (list max-x max-y max-z) :initial-element nil)))
         (room-id 0)
         (check-func #'(lambda (x y z cx cy cz)
                         (let* ((connect-id (get-connect-map-value connect-map x y z +connect-map-move-fly+))
                                (half-size (truncate (1- mob-size) 2)))
                           (declare (type fixnum connect-id half-size cx cy cz x y z))
                           (if (and (= connect-id +connect-room-none+)
                                    (funcall #'(lambda (sx sy)
                                                 (let ((result t))
                                                   (block from-result
                                                     (loop for off-x of-type fixnum from (- half-size) to (+ half-size)
                                                           for nx of-type fixnum = (+ sx off-x) do
                                                             (loop for off-y of-type fixnum from (- half-size) to (+ half-size)
                                                                   for ny of-type fixnum = (+ sy off-y) do
                                                                     (when (or (< nx 0) (< ny 0) (>= nx max-x) (>= ny max-y)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+)
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-openable-door+))
                                                                       (setf result nil)
                                                                       (return-from from-result))
                                                                     
                                                                     ;; magic starts here
                                                                     (setf result nil)

                                                                     (when (and (or (= (- cz z) 0)
                                                                                    (and (/= (- cz z) 0)
                                                                                         (= nx cx)
                                                                                         (= ny cy))
                                                                                    )
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | |p| |
                                                                     ;;    floor z = 1 -> | |.| |
                                                                     ;; on floor z = 0 -> | |x| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    w - water
                                                                     ;;    . - air (no floor, no wall, no water)
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (not result)
                                                                                (< (- z cz) 0)
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move+))
                                                                                (not (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+))
                                                                                (and (= cx nx)
                                                                                     (= cy ny))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+))
                                                                       (setf result t))
                                                                     
                                                                     ;; the following case is connected
                                                                     ;; on floor z = 1 -> | | |x|
                                                                     ;;    floor z = 1 -> | | |#|
                                                                     ;; on floor z = 0 -> | |p| |
                                                                     ;;    floor z = 0 -> | |w| |
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    . - air
                                                                     ;;    w - water
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (> (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-water+)
                                                                                (not (and (= cx nx)
                                                                                          (= cy ny)))
                                                                                (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+))
                                                                                (or (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)
                                                                                    (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-water+)))
                                                                       ;(format t "FLOOD FILL HERE~%")
                                                                       (setf result t))

                                                                     ;; the following case is connected
                                                                     ;; on floor z = 0 -> | |x|p|
                                                                     ;;    floor z = 0 -> | |?|#|
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    ? - not important
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (= (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-blocks-move-floor+)
                                                                                )
                                                                       (setf result t))

                                                                     ;; check small mobs connectivity via flight
                                                                     (when (and (not result)
                                                                                (or (= (- cz z) 0)
                                                                                    (and (/= (- cz z) 0)
                                                                                         (= nx cx)
                                                                                         (= ny cy))
                                                                                    )
                                                                                (check-move-along-z cx cy cz nx ny z)
                                                                                )
                                                                       (setf result t))

                                                                     ;; check large mobs connectivity via flight
                                                                     (when (and (not result)
                                                                                (> mob-size 1)
                                                                                (/= (- cz z) 0)
                                                                                (check-move-along-z nx ny cz nx ny z))
                                                                       (setf result t))

                                                                     ;; if you are large, you can move only if all you tiles have opaque floor
                                                                     ;(when (and (> mob-size 1)
                                                                     ;           (= (- z cz) 0)
                                                                     ;           (not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move-floor+)))
                                                                     ;  (setf result nil))
                                                                     
                                                                     ;; all other cases are disconnected 
                                                                     (unless result
                                                                       (return-from from-result))
                                                                   )))
                                                   result))
                                             x y))
                             t
                             nil))))
         (make-func #'(lambda (x y z)
                        (set-connect-map-value connect-map x y z +connect-map-move-fly+ room-id)
                        )))
    (declare (type fixnum max-x max-y max-z room-id))
    
    (loop for x of-type fixnum from 0 below max-x do
      (loop for y of-type fixnum from 0 below max-y do
        (loop for z of-type fixnum from 0 below max-z do
          (when (funcall check-func x y z x y z)
            (flood-fill (list x y z) :max-x max-x :max-y max-y :max-z max-z :check-func check-func :make-func make-func)
            (incf room-id))
              )))
    
    (setf (aref (connect-map level) mob-size) connect-map)))

(defun create-connect-map-aux (level)
  ;; make auxiliary links
  (let ((max-x (array-dimension (terrain level) 0))
        (max-y (array-dimension (terrain level) 1))
        (max-z (array-dimension (terrain level) 2)))
    (loop for x of-type fixnum from 1 below (1- max-x) do
      (loop for y of-type fixnum from 1 below (1- max-y) do
        (loop for z of-type fixnum from 0 below max-z do
          (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-openable-door+)
            (let ((func #'(lambda (&key map-size move-mode)
                            (let ((room-id-list nil))
                              (check-surroundings x y nil #'(lambda (dx dy)
                                                              (when (/= (get-level-connect-map-value level dx dy z map-size move-mode) +connect-room-none+)
                                                                (pushnew (get-level-connect-map-value level dx dy z map-size move-mode)
                                                                         room-id-list))))
                              (loop for room-id-start in room-id-list do
                                (loop for room-id-end in room-id-list do
                                  (when (/= room-id-start room-id-end)
                                    (set-aux-map-connection level room-id-start room-id-end map-size move-mode))))))))
              (funcall func :map-size 1 :move-mode +connect-map-move-walk+)
              (funcall func :map-size 1 :move-mode +connect-map-move-climb+)
              (funcall func :map-size 1 :move-mode +connect-map-move-fly+)
              )))))))
