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
      (format t "GENERATE-LEVEL: Placing standard items~%")
      (loop for (item-type-id x y z qty) in item-template-result 
            do
               (add-item-to-level-list level (make-instance 'item :item-type item-type-id :x x :y y :z z :qty qty)))
      
      ;; populate world with features
      (format t "GENERATE-LEVEL: Placing standard features~%")
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
    (let* ((out *standard-output*)
           (size-1-thread (bt:make-thread #'(lambda ()
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-walk level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (logger (format nil "TIME-ELAPSED AFTER WALK 1: ~A~%" (- (get-internal-real-time) start-time)) out)
                                                )

                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-climb level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (logger (format nil "TIME-ELAPSED AFTER CLIMB 1: ~A~%" (- (get-internal-real-time) start-time)) out)
                                                )

                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-fly level 1)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (logger (format nil "TIME-ELAPSED AFTER FLY 1: ~A~%" (- (get-internal-real-time) start-time)) out)
                                                )
                                              )
                                        :name "Connectivity map (size 1) thread"))
           (size-3-thread (bt:make-thread #'(lambda ()
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-walk level 3)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (logger (format nil "TIME-ELAPSED AFTER WALK 3: ~A~%" (- (get-internal-real-time) start-time)) out)
                                                )
                                              
                                              (let ((start-time (get-internal-real-time)))
                                                (create-connect-map-climb level 3)
                                                (incf *cur-progress-bar*)
                                                (funcall *update-screen-closure* nil)
                                                (logger (format nil "TIME-ELAPSED AFTER CLIMB 3: ~A~%" (- (get-internal-real-time) start-time)) out)
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
      (logger (format nil "SIZE 1 CREATION FINISHED~%"))
      (bt:join-thread size-3-thread)
      (logger (format nil "SIZE 3 CREATION FINISHED~%"))
      )

    ;; adjusting the progress bar : 10
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure* "Finalizing")
    
    (push +game-event-adjust-outdoor-light+ (game-events level))

    ;; populate world with standard mobs (from actual level template)
    (format t "GENERATE-LEVEL: Placing standard mobs~%")
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
    
    ;; add win conditions

    
    
   ) 
  )

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
