(in-package :cotd)

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



(defun create-world (world menu-result)
  
  (let ((mob-template-result)
        (feature-template-result)
	
	(result-template) 
	)
    ;; resetting the progress bar
    (setf *max-progress-bar* 2)
    (setf *cur-progress-bar* 0)
    (funcall *update-screen-closure*)

    ;; if test level is used, create a special test level
    (if (or (eql menu-result 'test-level) (eql menu-result 'test-level-all-see))
      (multiple-value-setq (result-template feature-template-result mob-template-result) (create-template-test-city *max-x-level* *max-y-level* nil))
      (multiple-value-setq (result-template feature-template-result mob-template-result) (create-template-city *max-x-level* *max-y-level* nil)))
        
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)

    (logger (format nil "Creating actual level ~A~%" 0))
    (setf  (level world) (create-level-from-template result-template)) 
                        
      
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)

    (create-features-from-template (level world) feature-template-result)
    (create-mobs-from-template (level world) mob-template-result)

    ;; if test level is used, place mobs through a special test function and quit
    (when (or (eql menu-result 'test-level) (eql menu-result 'test-level-all-see))
      (test-level-place-mobs (level world))
      (return-from create-world world))
    
    ;; populate the world with demons
    (loop repeat (truncate (total-humans world) 4)
          with cur-archdemons = 1
          with cur-demons = 15
          with mob-type-id = nil
          do
             (cond
               ((> cur-archdemons 0) (setf mob-type-id +mob-type-archdemon+) (decf cur-archdemons))
               ((> cur-demons 0) (setf mob-type-id +mob-type-demon+) (decf cur-demons))
               (t (setf mob-type-id +mob-type-imp+)))
             
             ;; find an unoccupied place
             (loop with x = (random *max-x-level*)
                   with y = (random *max-y-level*)
                   until (and (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10)))
                              (not (get-mob-* (level world) x y))
                              (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                   finally (add-mob-to-level-list (level world) (make-instance 'mob :mob-type mob-type-id :x x :y y))
                   do
                      (setf x (random *max-x-level*))
                      (setf y (random *max-y-level*))))

    
    ;; populate the world with angels
    (loop repeat (truncate (total-humans world) 10)
          with cur-archangels = 1
          with mob-type-id = nil
          do
             (cond
               ((> cur-archangels 0) (setf mob-type-id +mob-type-archangel+) (decf cur-archangels))
               (t (setf mob-type-id +mob-type-angel+)))
             
             ;; find an unoccupied place
             (loop with x = (random *max-x-level*)
                   with y = (random *max-y-level*)
                   until (and (not (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10))))
                              (not (get-mob-* (level world) x y))
                              (not (get-terrain-type-trait (get-terrain-* (level world) x y) +terrain-trait-blocks-move+)))
                   finally (add-mob-to-level-list (level world) (make-instance 'mob :mob-type mob-type-id :x x :y y))
                   do
                      (setf x (random *max-x-level*))
                      (setf y (random *max-y-level*)))
             )
    world))

(defun create-mobs-from-template (level mob-template-list)
  (loop for (mob-type-id x y) in mob-template-list 
        do
           (add-mob-to-level-list level (make-instance 'mob :mob-type mob-type-id :x x :y y))))

(defun create-features-from-template (level feature-template-list)
  (loop for (feature-type-id x y) in feature-template-list 
        do
           (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y))))

(defun create-test-world (world)
  (let (
	(feature-list)
        (mob-template-result)
        (feature-template-result)
	
	(result-template) 
	)
    ;; resetting the progress bar
    (setf *max-progress-bar* 2)
    (setf *cur-progress-bar* 0)
    (funcall *update-screen-closure*)

    

    (multiple-value-setq (result-template feature-template-result mob-template-result) (create-template-city *max-x-level* *max-y-level* nil))
        
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)

    (logger (format nil "Creating actual level ~A~%" 0))
    (setf  (level world) (create-level-from-template result-template)) 
                        
      
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
      
    
    (dolist (feature feature-list)
	(logger (format nil "Feature to be placed: ~A~%" (name feature)))
	(add-feature-to-level-list (level world) feature))
    
    world))
