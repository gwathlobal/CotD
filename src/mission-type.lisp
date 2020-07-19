(in-package :cotd)

(defenum:defenum mission-slot-enum (:mission-slot-demons-city
                                    :mission-slot-angels-city
                                    :mission-slot-military-city
                                    :mission-slot-military-offworld
                                    :mission-slot-angels-offworld))

(defclass mission-type ()
  ((id :initform :mission-type-none :initarg :id :accessor id :type mission-type-enum)
   (name :initform "Mission type name" :initarg :name :accessor name)
   (enabled :initform t :initarg :enabled :accessor enabled)
   (mission-slot-type :initform :mission-slot-demons-city :initarg :mission-slot-type :accessor mission-slot-type :type mission-slot-enum)
   (is-available-func :initform #'(lambda (world-sector world) (declare (ignore world-sector world)) nil) :initarg :is-available-func :accessor is-available-func)
   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; the func that takes world-sector-type-id and returns a list of faction-ids
   (world-sector-for-custom-scenario :initform () :initarg :world-sector-for-custom-scenario :accessor world-sector-for-custom-scenario) ;; the list of world-sectors available for this mission, specifically for custom scenario
   (always-lvl-mods-func :initform nil :initarg :always-lvl-mods-func :accessor always-lvl-mods-func)
   
   (template-level-gen-func :initform nil :initarg :template-level-gen-func :accessor template-level-gen-func)
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)
   (terrain-post-process-func-list :initform nil :initarg :terrain-post-process-func-list :accessor terrain-post-process-func-list)
   (scenario-faction-list :initform nil :initarg :scenario-faction-list :accessor scenario-faction-list)
   (ai-package-list :initform nil :initarg :ai-package-list :accessor ai-package-list)
   (win-condition-list :initform nil :initarg :win-condition-list :accessor win-condition-list)
   (ability-list :initform () :initarg :ability-list :accessor ability-list)
   (campaign-result :initform () :initarg :campaign-result :accessor mission-type/campaign-result :type list)
   ))

(defun set-mission-type (&key id name (enabled t) mission-slot-type is-available-func faction-list-func template-level-gen-func
                              overall-post-process-func-list terrain-post-process-func-list scenario-faction-list ai-package-list
                              win-condition-list world-sector-for-custom-scenario ability-list
                              (always-lvl-mods-func #'(lambda (world-sector mission world-time)
                                                        (declare (ignore world-sector mission world-time))
                                                        nil))
                              campaign-result)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless mission-slot-type (error ":MISSION-SLOT-TYPE is an obligatory parameter!"))
  
  (setf (gethash id *mission-types*) (make-instance 'mission-type :id id :name name :enabled enabled
                                                                  :is-available-func is-available-func
                                                                  :mission-slot-type mission-slot-type
                                                                  :faction-list-func faction-list-func
                                                                  :template-level-gen-func template-level-gen-func
                                                                  :overall-post-process-func-list overall-post-process-func-list
                                                                  :terrain-post-process-func-list terrain-post-process-func-list
                                                                  :faction-list-func faction-list-func
                                                                  :scenario-faction-list scenario-faction-list
                                                                  :ai-package-list ai-package-list
                                                                  :win-condition-list win-condition-list
                                                                  :ability-list ability-list
                                                                  :world-sector-for-custom-scenario world-sector-for-custom-scenario
                                                                  :always-lvl-mods-func always-lvl-mods-func
                                                                  :campaign-result campaign-result
                                                                  )))

(defun get-mission-type-by-id (mission-type-id)
  (gethash mission-type-id *mission-types*))

(defun get-all-mission-types-list (&key (include-disabled nil))
  (loop for mission-type being the hash-values in *mission-types*
        when (or (and (not include-disabled)
                      (enabled mission-type))
                 (and include-disabled
                      (not (enabled mission-type))))
        collect mission-type))

(defun get-ai-based-on-faction (faction-id mission-type-id)
  (if (find faction-id (ai-package-list (get-mission-type-by-id mission-type-id)) :key #'(lambda (a) (first a)))
    (progn
      (second (find faction-id (ai-package-list (get-mission-type-by-id mission-type-id)) :key #'(lambda (a) (first a)))))
    nil))

(defun get-abilities-based-on-faction (faction-id mission-type-id)
  (let ((faction-abilities (find faction-id (ability-list (get-mission-type-by-id mission-type-id)) :key #'(lambda (a) (first a)))))
    (if faction-abilities
      (second faction-abilities)
      nil)))

(defun setup-win-conditions (mission level)
  (loop for (faction-id game-event-id) in (win-condition-list (get-mission-type-by-id (mission-type-id mission)))
        when (find-if #'(lambda (a)
                          (if (and (= (first a) faction-id)
                                   (or (eq (second a) :mission-faction-present)
                                       (eq (second a) :mission-faction-delayed)))
                            t
                            nil))
                      (faction-list mission))
          do
             (pushnew game-event-id (game-events level))))

(defun update-visibility-after-creation (level world-sector mission world)
  (declare (ignore world-sector mission world))
  
  (format t "OVERALL-POST-PROCESS-FUNC: Update visibility~%~%")
  
  (loop for mob-id in (mob-id-list level)
        for mob = (get-mob-by-id mob-id)
        do
           (update-visible-mobs mob)))

(defun remove-dungeon-gen-functions (level world-sector mission world)
  (declare (ignore world-sector mission world))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Remove dungeon generation features~%"))
  
  (loop for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
          do
             (remove-feature-from-level-list level lvl-feature)))

;;=======================
;; Major Placement funcs
;;=======================

(defun place-player-on-level (level world-sector mission world)
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Placing player~%"))
  (loop for overall-post-process-func in (funcall (overall-post-process-func-list (get-level-modifier-by-id (player-lvl-mod-placement-id mission))))
        do
           (funcall overall-post-process-func level world-sector mission world)))

(defun place-ai-demons-on-level (level world-sector mission world)
  (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
    (declare (ignore year month day min sec))
    (let ((demon-list (if (and (>= hour 7) (< hour 19))
                        (list (list +mob-type-archdemon+ 1 nil)
                              (list +mob-type-demon+ 15 nil)
                              (list +mob-type-imp+ *min-imps-number* nil))
                        (list (if (zerop (random 2))
                                (list +mob-type-archdemon+ 1 nil)
                                (list +mob-type-shadow-devil+ 1 nil))
                              (list +mob-type-demon+ 7 nil)
                              (list +mob-type-shadow-demon+ 8 nil)
                              (list +mob-type-imp+ (truncate *min-imps-number* 2) nil)
                              (list +mob-type-shadow-imp+ (truncate *min-imps-number* 2) nil)))))
      (when (/= (player-lvl-mod-placement-id mission) +lm-placement-demon-malseraph+)
        (push (list +mob-type-malseraph-puppet+ 1 nil) demon-list))
      
      (place-demons-on-level level world-sector mission world demon-list))))

(defun place-ai-angels-on-level (level world-sector mission world)
  
  (let ((angel-list (list (list +mob-type-angel+ *min-angels-number* nil))))
    
    (when (/= (player-lvl-mod-placement-id mission) +lm-placement-angel-trinity+)
      (push (list +mob-type-star-singer+ 1 nil) angel-list))
    
    (place-angels-on-level level world-sector mission world angel-list)))

(defun place-ai-military-on-level (level world-sector mission world)
  
  (let ((military-list (list (list (list +mob-type-chaplain+ 1 nil)
                                   (list +mob-type-sergeant+ 1 nil)
                                   (list +mob-type-scout+ 1 nil)
                                   (list +mob-type-soldier+ 3 nil)
                                   (list +mob-type-gunner+ 1 nil))
                             (list (list +mob-type-chaplain+ 1 nil)
                                   (list +mob-type-sergeant+ 1 nil)
                                   (list +mob-type-scout+ 1 nil)
                                   (list +mob-type-soldier+ 3 nil)
                                   (list +mob-type-gunner+ 1 nil))
                             (list (list +mob-type-chaplain+ 1 nil)
                                   (list +mob-type-sergeant+ 1 nil)
                                   (list +mob-type-scout+ 1 nil)
                                   (list +mob-type-soldier+ 3 nil)
                                   (list +mob-type-gunner+ 1 nil))
                             (list (list +mob-type-chaplain+ 1 nil)
                                   (list +mob-type-sergeant+ 1 nil)
                                   (list +mob-type-scout+ 1 nil)
                                   (list +mob-type-soldier+ 3 nil)
                                   (list +mob-type-gunner+ 1 nil)))))
    
    (place-military-on-level level world-sector mission world military-list t))
  )

(defun place-ai-ghost-on-level (level world-sector mission world)
  (declare (ignore world-sector world))
  
  (when (and (/= (player-lvl-mod-placement-id mission) +lm-placement-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (eq (second a) :mission-faction-present))
                            t
                            nil))
                      (faction-list mission)))
    (populate-level-with-mobs level (list (list +mob-type-ghost+ 1 nil))
                              #'find-unoccupied-place-inside))
  )

(defun place-ai-primordial-on-level (level world-sector mission world)
  (declare (ignore world world-sector))
  
  (when (and (/= (player-lvl-mod-placement-id mission) +lm-placement-eater+)
             (/= (player-lvl-mod-placement-id mission) +lm-placement-skinchanger+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (eq (second a) :mission-faction-present))
                            t
                            nil))
                      (faction-list mission)))
    (populate-level-with-mobs level (if (zerop (random 2))
                                      (list (list +mob-type-eater-of-the-dead+ 1 nil))
                                      (list (list +mob-type-skinchanger-melee+ 1 nil)))
                              #'find-unoccupied-place-water))
  )

(defun place-mass-primordials-on-level (level world-sector mission world)
  (declare (ignore world world-sector mission))
  (loop repeat 20
        do
           (populate-level-with-mobs level (if (zerop (random 2))
                                             (list (list +mob-type-eater-of-the-dead+ 1 nil))
                                             (list (list +mob-type-skinchanger-melee+ 1 nil)))
                                     #'find-unoccupied-place-water)))

(defun place-ai-thief-on-level (level world-sector mission world)
  (declare (ignore world-sector world))
  
  (when (and (/= (player-lvl-mod-placement-id mission) +specific-faction-type-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (eq (second a) :mission-faction-present))
                            t
                            nil))
                      (faction-list mission)))
    (populate-level-with-mobs level (list (list +mob-type-thief+ 1 nil))
                              #'find-unoccupied-place-on-top))
  )

(defun place-delayed-arrival-points-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))
  
  (loop for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        for x = (x lvl-feature)
        for y = (y lvl-feature)
        for z = (z lvl-feature)
        when (= (feature-type lvl-feature) +feature-delayed-military-arrival-point+)
          do
             (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
                        (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+)))
               (push (list x y z) (delayed-military-arrival-points level)))
        when (= (feature-type lvl-feature) +feature-delayed-angels-arrival-point+)
          do
             (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
                        (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+)))
               (push (list x y z) (delayed-angels-arrival-points level)))
        when (= (feature-type lvl-feature) +feature-delayed-demons-arrival-point+)
          do
             (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
                        (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+)))
               (push (list x y z) (delayed-demons-arrival-points level)))))

(defun setup-turns-for-delayed-arrival (level world-sector mission world)
  (declare (ignore mission))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Set up turns for delayed arrival~%"))

  ;; set up delayed arrival for demons
  (setf (turns-for-delayed-demons level) 130)

  (when (find-campaign-effects-by-id world :campaign-effect-demons-delayed)
    (incf (turns-for-delayed-demons level) 30))
  
  ;; set up delayed arrival for angels
  (setf (turns-for-delayed-angels level) 150)

  (when (find-campaign-effects-by-id world :campaign-effect-angels-hastened)
    (decf (turns-for-delayed-angels level) 30))
  
  ;; set up delayed arrival for military depending on the distance from the nearest military-controlled sector
  (let ((first t)
        (nearest-military-sector nil))
    (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
      (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
        (when (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-military+)
          (when first
            (setf nearest-military-sector (aref (cells (world-map world)) x y))
            (setf first nil))
          (when (< (get-distance x y (x world-sector) (y world-sector))
                   (get-distance (x nearest-military-sector) (y nearest-military-sector) (x world-sector) (y world-sector)))
            (setf nearest-military-sector (aref (cells (world-map world)) x y))))))
    
    (if nearest-military-sector
      (setf (turns-for-delayed-military level) (+ 120 (* (truncate (get-distance (x nearest-military-sector) (y nearest-military-sector) (x world-sector) (y world-sector))) 20)))
      (setf (turns-for-delayed-military level) 220)))
  )

(defun place-custom-portals (level portal-feature-id &key (map-margin 30) (distance 6) (max-portals 1) (test-mob-free t) (test-repel-demons nil) (move-type +connect-map-move-walk+))
  (let ((portals ()))
    ;; find place for portals
    (loop with max-x = (- (array-dimension (terrain level) 0) (* map-margin 2))
          with max-y = (- (array-dimension (terrain level) 1) (* map-margin 2))
          for free-place = t
          with z = 2
          for x = (+ (random max-x) map-margin)
          for y = (+ (random max-y) map-margin)
          while (< (length portals) max-portals) do
            (check-surroundings x y t #'(lambda (dx dy)
                                          (when (or (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-blocks-move+)
                                                    (not (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-blocks-move-floor+))
                                                    (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-water+))
                                            (setf free-place nil))))
            (when (and free-place
                       (/= (get-level-connect-map-value level x y z 1 move-type) +connect-room-none+)
                       (not (find (list x y 2) portals :test #'(lambda (a b)
                                                                 (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) distance)
                                                                   t
                                                                   nil)
                                                                 )))
                       ;; test if the portal dst place has no mob
                       (if (or (null test-mob-free)
                               (not (get-mob-* level x y z)))
                         t
                         nil)
                       ;; test if the portal dst place is far from repel-demons feature
                       (if (or (null test-repel-demons)
                               (loop for feature-id in (feature-id-list level)
                                     for feature = (get-feature-by-id feature-id)
                                     with result = t
                                     when (and (= (feature-type feature) +feature-start-repel-demons+)
                                               (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                       do
                                          (setf result nil)
                                          (loop-finish)
                                     when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                               (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                       do
                                          (setf result nil)
                                          (loop-finish)
                                     finally (return result)))
                         t
                         nil)
                       )
              (push (list x y z) portals)))
    ;; place portals
    (loop for (x y z) in portals do
      ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id portal-feature-id)) x y z)
      (add-feature-to-level-list level (make-instance 'feature :feature-type portal-feature-id :x x :y y :z z)))
    portals))

(defun place-demonic-portals (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Placing demonic portals~%"))
  
  ;; remove standard demon arrival points
  (loop for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        when (= (feature-type lvl-feature) +feature-start-place-demons+) do
          (remove-feature-from-level-list level lvl-feature))
  
  ;; add portals
  (let ((portals ()))
    (setf portals (place-custom-portals level +feature-demonic-portal+ :max-portals 6 :distance 10 :test-mob-free t :test-repel-demons t))

    (loop for (x y z) in portals do
      (add-feature-to-level-list level (make-instance 'feature :feature-type +feature-start-place-demons+ :x x :y y :z z)))))

;;=======================
;; Minor Placement funcs
;;=======================

(defun place-mobs-on-level-immediate (level &key start-point-list create-player mob-list no-center)
  (loop for (mob-type mob-number is-player) in mob-list do
    (loop repeat mob-number do
      (loop with arrival-point-list = (copy-list start-point-list)
            with mob = (cond
                         ((and is-player create-player) (make-instance 'player :mob-type mob-type))
                         ((and is-player (not create-player)) (progn (setf (player-outside-level *player*) nil) *player*))
                         (t (make-instance 'mob :mob-type mob-type)))
            while (> (length arrival-point-list) 0) 
            for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
            for x = (first random-arrival-point)
            for y = (second random-arrival-point)
            for z = (third random-arrival-point)
            do
               (setf arrival-point-list (remove random-arrival-point arrival-point-list))

               (when is-player
                 (setf *player* mob))
               
               (find-unoccupied-place-around level mob x y z :no-center no-center)
               
               (loop-finish)))))

(defun place-demons-on-level (level world-sector mission world demon-list)
  (declare (ignore world world-sector))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place demons function~%"))
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (eq (second a) :mission-faction-present))
                       t
                       nil))
                 (faction-list mission))
    
    (logger (format nil "   PLACE-DEMONS-ON-LEVEL: Place present demons~%"))

    (place-mobs-on-level-immediate level
                                   :start-point-list (loop for lvl-feature-id in (remove-if-not #'(lambda (a)
                                                                                                    (eql (feature-type (get-feature-by-id a)) +feature-start-place-demons+))
                                                                                                (feature-id-list level))
                                                           for lvl-feature = (get-feature-by-id lvl-feature-id)
                                                           collect (list (x lvl-feature) (y lvl-feature) (z lvl-feature)))
                                   :create-player t
                                   :mob-list demon-list
                                   :no-center t))

  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (eq (second a) :mission-faction-delayed))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-DEMONS-ON-LEVEL: Add game event for delayed demons~%"))
    
    (pushnew +game-event-delayed-arrival-demons+ (game-events level))
    
    ;; add a player to game but do not add him to the level
    (when (or (= (player-lvl-mod-placement-id mission) +lm-placement-demon-malseraph+)
              (= (player-lvl-mod-placement-id mission) +lm-placement-demon-crimson+)
              (= (player-lvl-mod-placement-id mission) +lm-placement-demon-shadow+))
        (loop for (mob-type-id mob-num is-player) in demon-list do
          (when is-player
            (logger (format nil "   PLACE-DEMONS-ON-LEVEL: Add delayed player to the game~%"))
            (setf *player* (make-instance 'player :mob-type mob-type-id))
            (setf (player-outside-level *player*) t))))
    )
  )

(defun place-angels-on-level-immediate (level &key start-point-list create-player angel-list)
  (loop for (angel-type angel-number is-player) in angel-list do
    (loop repeat angel-number do
      (if (or (= angel-type +mob-type-star-singer+)
              (= angel-type +mob-type-star-gazer+)
              (= angel-type +mob-type-star-mender+))
        (progn
          (logger (format nil "   PLACE-ANGELS-ON-LEVEL-IMMEDIATE: Place trinity mimics~%"))
          (loop with is-free = t
                with mob1 = (cond
                              ((and is-player create-player) (make-instance 'player :mob-type +mob-type-star-singer+))
                              ((and is-player (not create-player)) (progn (setf (player-outside-level *player*) nil) *player*))
                              (t (make-instance 'mob :mob-type +mob-type-star-singer+)))
                with mob2 = (cond
                              ((and is-player create-player) (make-instance 'player :mob-type +mob-type-star-gazer+))
                              ((and is-player (not create-player)) (get-mob-by-id (second (mimic-id-list *player*))))
                              (t (make-instance 'mob :mob-type +mob-type-star-gazer+)))
                with mob3 = (cond
                              ((and is-player create-player) (make-instance 'player :mob-type +mob-type-star-mender+))
                              ((and is-player (not create-player)) (get-mob-by-id (third (mimic-id-list *player*))))
                              (t (make-instance 'mob :mob-type +mob-type-star-mender+)))
                with arrival-point-list = (copy-list start-point-list)
                while (> (length arrival-point-list) 0) 
                for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                for x = (first random-arrival-point)
                for y = (second random-arrival-point)
                for z = (third random-arrival-point)
                do
                   (setf arrival-point-list (remove random-arrival-point arrival-point-list))
                   (setf is-free t)
                   (check-surroundings x y t #'(lambda (dx dy)
                                                 (when (or (not (eq (check-move-on-level mob1 dx dy z) t))
                                                           (not (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-blocks-move-floor+)))
                                                   (setf is-free nil))))
                   (when is-free
                     
                     (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                     (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                     (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                     (setf (name mob2) (name mob1) (name mob3) (name mob1))
                     
                     (when is-player
                       (setf *player* mob1))
                     
                     (setf (x mob1) (1- x) (y mob1) (1- y) (z mob1) z)
                     (add-mob-to-level-list level mob1)
                     (setf (x mob2) (1+ x) (y mob2) (1- y) (z mob2) z)
                     (add-mob-to-level-list level mob2)
                     (setf (x mob3) x (y mob3) (1+ y) (z mob3) z)
                     (add-mob-to-level-list level mob3)
                     
                     (loop-finish))))
        (progn
          (logger (format nil "   PLACE-ANGELS-ON-LEVEL-IMMEDIATE: Place chrome angels~%"))
          
          (loop with arrival-point-list = (copy-list start-point-list)
                with angel = (cond
                              ((and is-player create-player) (make-instance 'player :mob-type angel-type))
                              ((and is-player (not create-player)) (progn (setf (player-outside-level *player*) nil) *player*))
                              (t (make-instance 'mob :mob-type angel-type)))
                while (> (length arrival-point-list) 0) 
                for random-arrival-point = (nth (random (length arrival-point-list)) arrival-point-list)
                for x = (first random-arrival-point)
                for y = (second random-arrival-point)
                for z = (third random-arrival-point)
                do
                   (setf arrival-point-list (remove random-arrival-point arrival-point-list))

                   (when is-player
                     (setf *player* angel))
                   
                   (find-unoccupied-place-around level angel x y z :no-center t)
                   
                   (loop-finish))))
          )))

(defun place-angels-on-level (level world-sector mission world angel-list)
  (declare (ignore world-sector world))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place angels function~%"))
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (eq (second a) :mission-faction-present))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Place present angels~%"))

    (place-angels-on-level-immediate level
                                     :start-point-list (loop for lvl-feature-id in (remove-if-not #'(lambda (a)
                                                                                                   (= (feature-type a) +feature-start-place-angels+))
                                                                                               (feature-id-list level)
                                                                                               :key #'(lambda (b)
                                                                                                        (get-feature-by-id b)))
                                                             for lvl-feature = (get-feature-by-id lvl-feature-id)
                                                             collect (list (x lvl-feature) (y lvl-feature) (z lvl-feature)))
                                     :create-player t
                                     :angel-list angel-list))

  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (eq (second a) :mission-faction-delayed))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Add game event for delayed angels~%"))
    
    (pushnew +game-event-delayed-arrival-angels+ (game-events level))
    
    ;; add a player to game but do not add him to the level
    (when (or (= (player-lvl-mod-placement-id mission) +lm-placement-angel-trinity+)
              (= (player-lvl-mod-placement-id mission) +lm-placement-angel-chrome+))
      (loop for (mob-type-id mob-num is-player) in angel-list do
        (when is-player
          (if (or (= mob-type-id +mob-type-star-singer+)
                  (= mob-type-id +mob-type-star-gazer+)
                  (= mob-type-id +mob-type-star-mender+))
            (progn
              (let ((mob1 (make-instance 'player :mob-type +mob-type-star-singer+))
                    (mob2 (make-instance 'player :mob-type +mob-type-star-gazer+))
                    (mob3 (make-instance 'player :mob-type +mob-type-star-mender+)))
                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                (setf *player* mob1)))
            (progn
              (setf *player* (make-instance 'player :mob-type mob-type-id))))
          (logger (format nil "   PLACE-ANGELS-ON-LEVEL: Add delayed player to the game~%"))
          (setf (player-outside-level *player*) t))))
    )
  )
  

(defun place-military-on-level (level world-sector mission world military-list remove-arrival-points)
  (declare (ignore world-sector world))
  
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place military function~%"))

  ;; if the player is present as a chaplain then we need only three squads
  (when (and (= (player-lvl-mod-placement-id mission) +lm-placement-military-chaplain+)
             (> (length military-list) 1))
    (setf military-list (remove (first military-list) military-list)))
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (eq (second a) :mission-faction-present))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Place present military~%"))
    
    (loop for squad-list in military-list do
      (destructuring-bind (mob-type-id mob-num is-player) (first squad-list)
        (declare (ignore mob-num))
        (let ((leader (if is-player (make-instance 'player :mob-type mob-type-id) (make-instance 'mob :mob-type mob-type-id))))
          (loop with arrival-point-list = (remove-if-not #'(lambda (a)
                                                             (= (feature-type a) +feature-start-place-military+))
                                                         (feature-id-list level)
                                                         :key #'(lambda (b)
                                                                  (get-feature-by-id b)))
                while (> (length arrival-point-list) 0) 
                for random-arrival-point-id = (nth (random (length arrival-point-list)) arrival-point-list)
                for lvl-feature = (get-feature-by-id random-arrival-point-id)
                for x = (x lvl-feature)
                for y = (y lvl-feature)
                for z = (z lvl-feature)
                do
                   (setf arrival-point-list (remove random-arrival-point-id arrival-point-list))
                   (when is-player
                     (setf *player* leader))
                   
                   (find-unoccupied-place-around level leader x y z)
                   
                   (when remove-arrival-points
                     (remove-feature-from-level-list level lvl-feature)
                     (remove-feature-from-world lvl-feature))
                   
                   (loop-finish))
          
          (setf squad-list (remove (first squad-list) squad-list))
          
          (when squad-list
            (populate-level-with-mobs level squad-list
                                      #'(lambda (level mob)
                                          (find-unoccupied-place-around level mob (x leader) (y leader) (z leader)))))))
          )
    )
  
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (eq (second a) :mission-faction-delayed))
                       t
                       nil))
                 (faction-list mission))
    (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Add game event for delayed military~%"))
    
    (pushnew +game-event-delayed-arrival-military+ (game-events level))
    
    ;; add a player to game but do not add him to the level
    (when (or (= (player-lvl-mod-placement-id mission) +lm-placement-military-chaplain+)
              (= (player-lvl-mod-placement-id mission) +lm-placement-military-scout+))
      (loop for squad-list in military-list do
        (destructuring-bind (mob-type-id mob-num is-player) (first squad-list)
          (declare (ignore mob-num))
          (when is-player
            (logger (format nil "   PLACE-MILITARY-ON-LEVEL: Add delayed player to the game~%"))
            (setf *player* (make-instance 'player :mob-type mob-type-id))
            (setf (player-outside-level *player*) t)))))
    )
  )
  

(defun place-demonic-runes-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (logger (format nil "OVERALL-POST-PROCESS-FUNC: Place demonic runes~%"))
  (let ((demonic-runes ())
        (rune-list (list +feature-demonic-rune-flesh+ +feature-demonic-rune-flesh+
                         +feature-demonic-rune-invite+ +feature-demonic-rune-invite+
                         +feature-demonic-rune-away+ +feature-demonic-rune-away+
                         +feature-demonic-rune-transform+ +feature-demonic-rune-transform+
                         +feature-demonic-rune-barrier+ +feature-demonic-rune-barrier+
                         +feature-demonic-rune-all+ +feature-demonic-rune-all+
                         +feature-demonic-rune-decay+ +feature-demonic-rune-decay+)))
    (loop with max-x = (array-dimension (terrain level) 0)
          with max-y = (array-dimension (terrain level) 1)
          with max-z = (array-dimension (terrain level) 2)
          with cur-rune = 0
          for x = (random max-x)
          for y = (random max-y)
          for z = (random max-z)
          while (< (length demonic-runes) (length rune-list)) do
            (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-can-have-rune+)
                       (null (find (list x y z) demonic-runes :test #'(lambda (a b)
                                                                        (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 6)
                                                                          t
                                                                          nil)
                                                                        ))))
              (push (list x y z (nth cur-rune rune-list)) demonic-runes)
              (incf cur-rune)))
    (loop for (x y z feature-type-id) in demonic-runes do
      ;;(format t "PLACE RUNE ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id feature-type-id)) x y z)
      (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z)))))

(defun add-lose-and-win-coditions-to-level (level world-sector mission world)
  (declare (ignore world-sector world))
  
  ;; make the game continue even after the players dies
  (push +game-event-player-died+ (game-events level))

  (when (/= (player-lvl-mod-placement-id mission) +specific-faction-type-player+)
    (setup-win-conditions mission level)))

(defun set-up-inital-power (level world-sector mission world)
  (declare (ignore mission))
  (logger (format nil "SET-UP-INITIAL-POWER: Set up power for demons and angels~%"))
  
  (let ((demon-power 0)
        (angel-power 0))
    ;; in hell, demon always start with at least 2
    (when (or (eql (wtype world-sector) :world-sector-hell-plain))
      (incf demon-power 2))

    ;; if the relic is captured, add 1 to demons
    ;; if the relic is in church, add 1 to angels
    (loop for dx from 0 below (array-dimension (cells (world-map world)) 0) do
            (loop for dy from 0 below (array-dimension (cells (world-map world)) 1) do
              (when (and (or (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-forest)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-lake)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-residential)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-island)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-normal-port))
                         (find +lm-feat-church+ (feats (aref (cells (world-map world)) dx dy)) :key #'(lambda (a) (first a)))
                         (find +lm-item-holy-relic+ (items (aref (cells (world-map world)) dx dy))))
                (incf angel-power 1))
              
              (when (and (or (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-forest)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-lake)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-residential)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-island)
                             (eq (wtype (aref (cells (world-map world)) dx dy)) :world-sector-corrupted-port))
                         (find +lm-item-holy-relic+ (items (aref (cells (world-map world)) dx dy))))
                (incf demon-power 1))))

    (loop for mob-id in (mob-id-list level)
          for mob = (get-mob-by-id mob-id)
          when (and (mob-ability-p mob +mob-abil-demon+)
                    (eql (faction mob) +faction-type-demons+))
            do
               (setf (cur-fp mob) demon-power)
               (when (> (cur-fp mob) (max-fp mob))
                 (setf (cur-fp mob) (max-fp mob)))
          when (and (mob-ability-p mob +mob-abil-angel+)
                    (eql (faction mob) +faction-type-angels+))
            do
               (setf (cur-fp mob) angel-power)
               (when (> (cur-fp mob) (max-fp mob))
                 (setf (cur-fp mob) (max-fp mob))))))

(defun remove-signal-flares-from-military (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (logger (format nil "REMOVE-SIGNAL-FLARES-FROM-MILITARY: Remove flares~%"))
  (loop for mob-id in (mob-id-list level)
        for mob = (get-mob-by-id mob-id)
        when (eq (faction mob) +faction-type-military+)
          do
             (loop for item in (get-inv-items-by-type (inv mob) +item-type-signal-flare+) do
               (setf (inv mob) (remove-from-inv item (inv mob))))
        )
  )

(defun add-bombs-to-military (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (logger (format nil "ADD-BOMBS-TO-MILITARY: Add bombs~%"))
  (loop for mob-id in (mob-id-list level)
        for mob = (get-mob-by-id mob-id)
        when (eq (faction mob) +faction-type-military+)
          do
             (mob-pick-item mob (make-instance 'item :item-type +item-type-bomb+ :x (x mob) :y (y mob) :z (z mob) :qty 1)
                            :spd nil :silent t)
             (mob-pick-item mob (make-instance 'item :item-type +item-type-bomb+ :x (x mob) :y (y mob) :z (z mob) :qty 1)
                            :spd nil :silent t)
             (mob-pick-item mob (make-instance 'item :item-type +item-type-bomb+ :x (x mob) :y (y mob) :z (z mob) :qty 1)
                            :spd nil :silent t)
        )
  )
