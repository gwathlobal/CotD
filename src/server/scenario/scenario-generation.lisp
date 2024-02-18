;;;; scenario-generation.lisp

(in-package :cotd/scenario)

(defclass scenario-generator ()
  ((scenario :initform (make-instance 'cotd::scenario-gen-class) :accessor scenario :type cotd::scenario-gen-class)
   (months-list :initform (list "January" "February" "March" "April" "May" "June" "July" "August" "September" 
                                "October" "November" "December") 
                :accessor months-list :type list)
   
   (cur-mission-type-id :initform nil :accessor cur-mission-type-id) ;; of type mission-type-id (keyword)
   (cur-sector-id :initform nil :accessor cur-sector-id) ;; of type wtype (keyword)
   (cur-month :initform 0 :accessor cur-month :type fixnum)
   (cur-specific-faction-id :initform 0 :accessor cur-specific-faction-id :type fixnum)
   ))

(defun create-scenario-generator (&key mission-type world-sector-type month feats factions specific-faction)
  (let ((gen (make-instance 'scenario-generator)))
    (with-slots (scenario cur-mission-type-id cur-month cur-sector-id cur-specific-faction-id) gen
      (with-slots (cotd::avail-mission-type-list cotd::avail-world-sector-type-list
                                                 cotd::select-lvl-mods-list
                                                 cotd::cur-faction-list) scenario
        ;; set up supporting world
        (cotd::scenario-create-world scenario)
        
        (if month
            (setf cur-month month)
            (setf cur-month (random 12)))
        (cotd::scenario-set-world-date scenario 1915 cur-month (random 30) 0 0 0)
        
        ;; find all available missions
        (cotd::scenario-set-avail-mission-types scenario)
        
        (if mission-type
            (setf cur-mission-type-id mission-type)
            (setf cur-mission-type-id (cotd::id (alexandria:random-elt cotd::avail-mission-type-list))))

        (when world-sector-type
          (setf cur-sector-id world-sector-type))

        (when feats
          (loop for feat-id in feats
                for lvl-mod = (cotd::get-level-modifier-by-id feat-id)
                do
                   (pushnew lvl-mod cotd::select-lvl-mods-list)))

        (when factions
          (loop for faction in factions
                do
                   (pushnew faction cotd::cur-faction-list)))

        (when specific-faction
          (setf cur-specific-faction-id specific-faction))
        
        (adjust-mission-after-change gen)))
    gen))

(defun adjust-mission-after-change (gen)
  (with-slots (scenario cur-mission-type-id) gen
    (with-slots (cotd::avail-mission-type-list) scenario
      ;; create the mission
      (cotd::scenario-create-mission scenario cur-mission-type-id)
      
      (readjust-sectors-after-mission-change gen))))

(defun readjust-sectors-after-mission-change (gen)
  (with-slots (scenario cur-sector-id) gen
    (with-slots (cotd::avail-world-sector-type-list) scenario
      ;; find all available sectors for the selected mission
      (cotd::scenario-set-avail-world-sector-types scenario)
      
      (let ((cur-world-sector-type (if cotd::avail-world-sector-type-list
                                         (cotd::get-world-sector-type-by-id cur-sector-id)
                                         nil)))
        
        ;; do not change the selection if there is a previously selected world-sector in the new selection
        (when (not (and cur-world-sector-type
                        (find cur-world-sector-type cotd::avail-world-sector-type-list)))
          (setf cur-sector-id (cotd::wtype (alexandria:random-elt cotd::avail-world-sector-type-list))))
        
        (adjust-world-sector-after-change gen)))))

(defun adjust-months-before-feats (gen)
  (with-slots (scenario cur-month) gen
    (with-slots (cotd::world) scenario
      (multiple-value-bind (year month day hour min sec) 
          (cotd::get-current-date-time (cotd::world-game-time cotd::world))
        (declare (ignore month))
        (cotd::scenario-set-world-date scenario year cur-month day hour min sec))

      (adjust-world-sector-after-change gen))))

(defun adjust-world-sector-after-change (gen)
  (with-slots (scenario cur-sector-id) gen
    (with-slots (cotd::avail-world-sector-type-list) scenario
      ;; create the world sector
      (cotd::scenario-create-sector scenario cur-sector-id)
      
      (readjust-feats-after-sector-change gen))))

(defun readjust-feats-after-sector-change (gen)
  (with-slots (scenario) gen
    (with-slots (cotd::world cotd::world-sector cotd::avail-controlled-list cotd::avail-feats-list 
                             cotd::avail-items-list cotd::avail-tod-list cotd::avail-weather-list
                             cotd::overall-lvl-mods-list cotd::select-lvl-mods-list)
        scenario

      (let ((orig-selected-lvl-mods (copy-list cotd::select-lvl-mods-list)))
        (cotd::scenario-set-avail-lvl-mods scenario)

        (if orig-selected-lvl-mods
            (progn
              (loop for lvl-mod in orig-selected-lvl-mods
                    when (find lvl-mod cotd::overall-lvl-mods-list)
                    do
                       (cotd::scenario-add/remove-lvl-mod scenario lvl-mod :add-general t)))
            (progn
              ;; set a random controlled-by lvl-mod
              (cotd::scenario-add/remove-lvl-mod scenario (nth (random (length cotd::avail-controlled-list)) 
                                                               cotd::avail-controlled-list) 
                                                 :add-general t)        
              ;; add random feats lvl-mods
              (loop for lvl-mod in cotd::avail-feats-list
                    when (zerop (random 4)) do
                       (cotd::scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))
              
              ;; add random items lvl-mods
              (loop for lvl-mod in cotd::avail-items-list
                    when (zerop (random 4)) do
                       (cotd::scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))
              
              (cotd::generate-feats-for-world-sector cotd::world-sector (cotd::world-map cotd::world))
              
              ;; set a random time-of-day lvl-mod
              (cotd::scenario-add/remove-lvl-mod scenario (nth (random (length cotd::avail-tod-list)) 
                                                               cotd::avail-tod-list)
                                                 :add-general t)
        
              ;; add random weather lvl-mods
              (loop for lvl-mod in cotd::avail-weather-list
                    when (or (not (cotd::random-available-for-mission lvl-mod))
                             (funcall (cotd::random-available-for-mission lvl-mod)))
                    do
                       (cotd::scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))))
        
        (cotd::scenario-adjust-lvl-mods-after-sector-regeneration scenario)

        
        (cotd::scenario-sort-select-lvl-mods scenario)
        
        (readjust-factions-after-feats-change gen)))))

(defun readjust-factions-after-feats-change (gen)
  (with-slots (scenario) gen
    (with-slots (cotd::cur-faction-list) scenario
      ;; set up a all general factions
      (cotd::scenario-adjust-factions scenario)
      
      (readjust-specific-factions-after-faction-change gen))))

(defun readjust-specific-factions-after-faction-change (gen)
  (with-slots (scenario cur-specific-faction-id) gen
    (with-slots (cotd::specific-faction-list) scenario
      ;; find all specific factions
      (cotd::scenario-adjust-specific-factions scenario)
      
      (let ((cur-faction-id (if cotd::specific-faction-list
                              cur-specific-faction-id
                              nil)))

        (unless (and cur-faction-id
                     (find cur-faction-id cotd::specific-faction-list))
          (setf cur-specific-faction-id (alexandria:random-elt cotd::specific-faction-list)))))))

(defun get-available-and-current-mission (gen)
  (with-slots (cotd::avail-mission-type-list) (scenario gen)
    (loop with cur-mission-type = nil
          for mission-type in cotd::avail-mission-type-list
          when (eq (cotd::id mission-type) (cur-mission-type-id gen)) do (setf cur-mission-type mission-type)
          collect (list :id (cotd::id mission-type) :name (cotd::name mission-type)) into avail-missions
          finally (return (list :current (list :id (cotd::id cur-mission-type) 
                                               :name (cotd::name cur-mission-type)) 
                                :available avail-missions)))))

(defun get-available-and-current-sector (gen)
  (with-slots (cotd::avail-world-sector-type-list) (scenario gen)
    (loop with cur-sector-type = nil
          for world-sector-type in cotd::avail-world-sector-type-list
          when (eq (cotd::wtype world-sector-type) (cur-sector-id gen)) do (setf cur-sector-type world-sector-type)
          collect (list :id (cotd::wtype world-sector-type) :name (cotd::name world-sector-type)) into avail-sectors
          finally (return (list :current (list :id (cotd::wtype cur-sector-type) 
                                               :name (cotd::name cur-sector-type)) 
                                :available avail-sectors)))))

(defun get-available-and-current-month (gen)
  (with-slots (months-list cur-month) gen
    (loop for n from 0 below (length months-list)
          for month-name in months-list
          collect (list :id n :name month-name) into avail-months
          finally (return (list :current (list :id cur-month :name (nth cur-month months-list)) 
                                :available avail-months)))))

(defun get-available-and-current-feats (gen)
  ;; TODO: replace lvl-mod ids with keywords (instead of integers)
  (with-slots (cotd::overall-lvl-mods-list cotd::select-lvl-mods-list cotd::always-lvl-mods-list) (scenario gen)
    (loop for lvl-mod in cotd::overall-lvl-mods-list
          collect (list :id (cotd::id lvl-mod) :name (cotd::name lvl-mod)) into avail-feats
          
          if (find lvl-mod cotd::select-lvl-mods-list)
          collect (list :id (cotd::id lvl-mod) :name (cotd::name lvl-mod)) into selected-feats

          if (find lvl-mod cotd::always-lvl-mods-list)
          collect (list :id (cotd::id lvl-mod) :name (cotd::name lvl-mod)) into req-feats          
          
          finally (return (list :current selected-feats
                                :required req-feats
                                :available avail-feats)))))

(defun get-available-and-current-factions (gen)
  ;; TODO: replace faction ids with keywords (instead of integers)
  (with-slots (cotd::cur-faction-list cotd::avail-faction-list) (scenario gen)
    (loop for (faction-id faction-present) in cotd::cur-faction-list
          
          collect (list :id faction-id :name (cotd::name (cotd::get-faction-type-by-id faction-id)))
          into avail-factions
          
          when (eq faction-present :mission-faction-present)
          collect (list :id faction-id :name (cotd::name (cotd::get-faction-type-by-id faction-id))) 
          into current-factions
          
          when (eq faction-present :mission-faction-delayed)
          collect (list :id faction-id :name (cotd::name (cotd::get-faction-type-by-id faction-id))) 
          into delayed-factions
          
          when (<= (length (second (find faction-id cotd::avail-faction-list :key #'(lambda (a) (first a))))) 1)
          collect (list :id faction-id :name (cotd::name (cotd::get-faction-type-by-id faction-id))) 
          into req-factions
                    
          finally (return (list :current current-factions
                                :delayed delayed-factions
                                :required req-factions
                                :available avail-factions)))))

(defun get-available-and-current-specific-faction (gen)
  (flet ((get-specific-faction-name (specific-faction-type cur-mission-type-id)
           (cotd::name (cotd::get-level-modifier-by-id (second (find specific-faction-type
                                                                     (cotd::scenario-faction-list (cotd::get-mission-type-by-id cur-mission-type-id))
                                                                     :key #'(lambda (a) (first a))))))))
    (with-slots (cur-mission-type-id cur-specific-faction-id scenario) gen
      (with-slots (cotd::specific-faction-list) scenario
        (loop for specific-faction-type in cotd::specific-faction-list
              
              when (find specific-faction-type (cotd::scenario-faction-list (cotd::get-mission-type-by-id cur-mission-type-id))
                         :key #'(lambda (a) (first a)))
              collect (list :id specific-faction-type :name (get-specific-faction-name specific-faction-type cur-mission-type-id))
              into avail-specific-factions
              
              finally (return (list :current (list :id cur-specific-faction-id 
                                                   :name (get-specific-faction-name cur-specific-faction-id cur-mission-type-id)) 
                                    :available avail-specific-factions)))))))

