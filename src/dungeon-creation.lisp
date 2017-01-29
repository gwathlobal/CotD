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

(defun create-world (world layout-id weather-id faction-id)
  
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
    (setf *max-progress-bar* 2)
    (setf *cur-progress-bar* 0)
    (funcall *update-screen-closure*)

    (multiple-value-setq (layout-func post-processing-func-list mob-func-list game-event-list) (return-scenario-functions weather city-layout player-faction))

    ;; apply city layout function, if any
    (when layout-func
      (multiple-value-setq (result-template feature-template-result mob-template-result) (funcall layout-func)))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    ;; apply the post-processing function, if any
    (loop for post-processing-func in post-processing-func-list do
      (setf result-template (funcall post-processing-func result-template)))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    (logger (format nil "Creating actual level ~A~%" 0))
    (setf (level world) (create-level-from-template result-template))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    ;; set up features
    (create-features-from-template (level world) feature-template-result)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    ;; set up mobs
    (loop for mob-func in mob-func-list do
      (funcall mob-func world mob-template-result))

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    ;; set the game events
    (setf (game-events world) game-event-list)

    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
    
    world))

(defun create-features-from-template (level feature-template-list)
  (loop for (feature-type-id x y) in feature-template-list 
        do
           (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y))))

(defun create-level ()
  (let ((level))
    (setf level (make-instance 'level))
    (setf (terrain level) (make-array (list *max-x-level* *max-y-level*) :initial-element +terrain-floor-stone+))
    (setf (mobs level) (make-array (list *max-x-level* *max-y-level*) :initial-element nil))
    (setf (memo level) (make-array (list *max-x-level* *max-y-level*) :initial-element (create-single-memo 0 sdl:*white* sdl:*black* nil nil)))
    level))

(defun create-level-from-template (template-level)
  ;; legend - ( (<id of a tile in the template> <type of the tile> <real object template id>) ... )
  ;; <type of the tile>
  ;;   :terrain
  ;;   :obstacle
  (let ((level (create-level)))
    (loop for x from 0 to (1- *max-x-level*) do
	 (loop for y from 0 to (1- *max-y-level*) do
	      (set-terrain-* level x y (aref template-level x y))))
    level))
