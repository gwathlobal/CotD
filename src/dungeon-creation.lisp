(in-package :cotd)

(defun return-scenario-functions (weather layout player-faction)
  (let ((post-processing-func-list nil) (layout-func nil) (mob-func-list nil) (game-event-list nil))

    (when (sf-func weather)
      (multiple-value-setq (layout-func post-processing-func-list mob-func-list game-event-list) (funcall (sf-func weather) layout-func post-processing-func-list mob-func-list game-event-list)))

    (when (sf-func layout)
      (multiple-value-setq (layout-func post-processing-func-list mob-func-list game-event-list) (funcall (sf-func layout) layout-func post-processing-func-list mob-func-list game-event-list)))
    
    (when (sf-func player-faction)
      (multiple-value-setq (layout-func post-processing-func-list mob-func-list game-event-list) (funcall (sf-func player-faction) layout-func post-processing-func-list mob-func-list game-event-list)))
    
    (values layout-func post-processing-func-list mob-func-list game-event-list)))

(defun create-world (world layout-id weather-id tod-id faction-id)
  
  (let ((mob-template-result)
        (feature-template-result)
	
	(result-template)

        (weather (get-scenario-feature-by-id weather-id))
        (city-layout (get-scenario-feature-by-id layout-id))
        (player-faction (get-scenario-feature-by-id faction-id))

        (layout-func)
        (post-processing-func-list)
        (mob-func-list)
        (game-event-list)
	)
    ;; resetting the progress bar
    (setf *max-progress-bar* 11)
    (setf *cur-progress-bar* 0)
    
    (funcall *update-screen-closure* "Generating map")

    (multiple-value-setq (layout-func post-processing-func-list mob-func-list game-event-list) (return-scenario-functions weather city-layout player-faction))

    ;; remove all nils from game-event-list, if any
    (setf game-event-list (remove nil game-event-list))

    ;; apply city layout function, if any
    (when layout-func
      (multiple-value-setq (result-template feature-template-result mob-template-result) (funcall layout-func)))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    ;; apply the post-processing function, if any
    (loop for post-processing-func in post-processing-func-list do
      (setf result-template (funcall post-processing-func result-template)))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    (logger (format nil "Creating actual level ~A~%" 0))
    (setf (level world) (create-level-from-template result-template))

    ;; creating light map
    (funcall (sf-func (get-scenario-feature-by-id tod-id)) (level world))

    ;; setting up time, a bit of hardcode here
    (let ((year 1915)
          (month 7)
          (day 12)
          (hour 12)
          (min (random 45))
          (sec (random 60)))
      (when (= weather-id +weather-type-snow+)
        (setf month 1))
      (when (= tod-id +tod-type-night+)
        (setf hour 0))
      (when (= tod-id +tod-type-morning+)
        (setf hour 8))
      (when (= tod-id +tod-type-evening+)
        (setf hour 19))
      (setf (player-game-time world) (set-current-date-time year month day hour min sec)))
    (push +game-event-adjust-outdoor-ligth+ game-event-list)
    
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Adding features")
    
    ;; set up features
    (create-features-from-template (level world) feature-template-result)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Adding mobs")
    
    ;; set up mobs
    (loop for mob-func in mob-func-list do
      (funcall mob-func world mob-template-result))
    
    ;; set the game events
    (setf (game-events world) game-event-list)

    ;; check map for connectivity
    
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Creating connectivity maps (walk)")
    
    (create-connect-map-walk (level world) 1)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    (create-connect-map-walk (level world) 3)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    (create-connect-map-walk (level world) 5)

    ;(time (progn
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Creating connectivity maps (climb)")
    
    (create-connect-map-climb (level world) 1)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    (create-connect-map-climb (level world) 3)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* nil)
    
    (create-connect-map-climb (level world) 5)
    
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Finalizing")
    
    world))

(defun create-features-from-template (level feature-template-list)
  (loop for (feature-type-id x y z) in feature-template-list 
        do
           (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z))))

(defun create-level (&key (max-x *max-x-level*) (max-y *max-y-level*) (max-z *max-z-level*))
  (let ((level))
    (setf level (make-instance 'level))
    (setf (terrain level) (make-array (list max-x max-y max-z) :initial-element +terrain-floor-stone+))
    (setf (mobs level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (items level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (features level) (make-array (list max-x max-y max-z) :initial-element nil))
    (setf (memo level) (make-array (list max-x max-y max-z) :initial-element (create-single-memo 0 sdl:*white* sdl:*black* nil nil)))
    (setf (light-map level) (make-array (list max-x max-y max-z) :initial-element 0))
    level))

(defun create-level-from-template (template-level)
  ;; legend - ( (<id of a tile in the template> <type of the tile> <real object template id>) ... )
  ;; <type of the tile>
  ;;   :terrain
  ;;   :obstacle
  (let* ((max-x (array-dimension template-level 0))
         (max-y (array-dimension template-level 1))
         (max-z (array-dimension template-level 2))
         (level (create-level :max-x max-x :max-y max-y :max-z max-z)))
    (loop for x from 0 to (1- max-x) do
      (loop for y from 0 to (1- max-y) do
        (loop for z from 0 to (1- max-z) do
          (set-terrain-* level x y z (aref template-level x y z)))))
    level))

(defun flood-fill (first-cell &key (max-x *max-x-level*) (max-y *max-y-level*) (max-z *max-z-level*) check-func make-func)
  (declare (optimize (speed 3))
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
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+))
                                                                       (setf result nil)
                                                                       (return-from from-result))
                                                                     
                                                                     ;; magic starts here
                                                                     (setf result nil)

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
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-opaque-floor+)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-slope-up+)
                                                                                (not (and (= cx nx)
                                                                                          (= cy ny)))
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-opaque-floor+))
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
                                                                                (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-opaque-floor+))
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
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-opaque-floor+)
                                                                                ;(not (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-opaque-floor+))
                                                                                )
                                                                       (setf result t))

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
    
    (loop for x from 0 below max-x do
      (loop for y from 0 below max-y do
        (loop for z from 0 below max-z do
          (when (funcall check-func x y z x y z)
            (flood-fill (list x y z) :max-x max-x :max-y max-y :max-z max-z :check-func check-func :make-func make-func)
            (incf room-id))
              )))
    (setf (aref (connect-map level) mob-size) connect-map)))

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
                                                                               (get-terrain-type-trait (get-terrain-* level nx ny z) +terrain-trait-blocks-move+))
                                                                       (setf result nil)
                                                                       (return-from from-result))
                                                                     
                                                                     ;; magic starts here
                                                                     (setf result nil)

                                                                     ;; the following case is connected
                                                                     ;; on floor z = 0 -> | |x|p|
                                                                     ;;    floor z = 0 -> | |?|#|
                                                                     ;; where
                                                                     ;;    # - floor
                                                                     ;;    ? - not important
                                                                     ;;    p - starting cell
                                                                     ;;    x - current cell
                                                                     (when (and (= (- z cz) 0)
                                                                                (get-terrain-type-trait (get-terrain-* level cx cy cz) +terrain-trait-opaque-floor+)
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
                                                                                                                                    (or (get-terrain-type-trait (get-terrain-* (level *world*) mx my z) +terrain-trait-opaque-floor+)
                                                                                                                                        (get-terrain-type-trait (get-terrain-* (level *world*) mx my z) +terrain-trait-blocks-move+)))
                                                                                                                           
                                                                                                                           (setf result t)
                                                                                                                           (return-from surround)))))
                                                                                               result))))
                                                                       (setf result t))

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
    
    (loop for x from 0 below max-x do
      (loop for y from 0 below max-y do
        (loop for z from 0 below max-z do
          (when (funcall check-func x y z x y z)
            (flood-fill (list x y z) :max-x max-x :max-y max-y :max-z max-z :check-func check-func :make-func make-func)
            (incf room-id))
              )))
    (setf (aref (connect-map level) mob-size) connect-map)))
