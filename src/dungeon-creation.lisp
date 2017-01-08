(in-package :cotd)

(defparameter *dungeon-loot-lvled-table* (make-hash-table))
(defparameter *dungeon-mobs-lvled-table* (make-hash-table))
(defparameter *dungeon-dung-lvled-table* (make-hash-table))

(defun create-level ()
  (let ((level))
    (setf level (make-instance 'level))
    (setf (terrain level) (make-array (list *max-x-level* *max-y-level*) :initial-element +terrain-floor-stone+))
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



(defun create-world (world)
  
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

    (format t "Creating actual level ~A~%" 0)
    (setf  (level world) (create-level-from-template result-template)) 
                        
      
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
      
    
    (dolist (feature feature-list)
	(format t "Feature to be placed: ~A~%" (name feature))
	(add-feature-to-level-list (level world) feature))
    
    (create-mobs-from-template (level world) mob-template-result)
    
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

    (format t "Creating actual level ~A~%" 0)
    (setf  (level world) (create-level-from-template result-template)) 
                        
      
    ;; adjusting the progress bar
    (incf *cur-progress-bar*)
    (funcall *update-screen-closure*)
      
    
    (dolist (feature feature-list)
	(format t "Feature to be placed: ~A~%" (name feature))
	(add-feature-to-level-list (level world) feature))
    
    world))
