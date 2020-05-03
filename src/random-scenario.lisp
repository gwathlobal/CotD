(in-package :cotd)

(defclass scenario-gen-class ()
  ((world :initform nil :initarg :world :accessor scenario-gen-class/world :type (or null world))
   (mission :initform nil :accessor scenario-gen-class/mission :type (or null mission))
   (world-sector :initform nil :accessor scenario-gen-class/world-sector :type (or null world-sector))

   (avail-mission-type-list :initform () :initarg :avail-mission-type-list :accessor scenario-gen-class/avail-mission-type-list :type list)
   (avail-world-sector-type-list :initform () :initarg :avail-world-sector-type-list :accessor scenario-gen-class/avail-world-sector-type-list :type list)
   (avail-lvl-mods-list :initform () :initarg :avail-lvl-mods-list :accessor scenario-gen-class/avail-lvl-mods-list :type list)

   (overall-lvl-mods-list :initform () :accessor scenario-gen-class/overall-lvl-mods-list :type list)
   (select-lvl-mods-list :initform () :accessor scenario-gen-class/select-lvl-mods-list :type list)
   (always-lvl-mods-list :initform () :accessor scenario-gen-class/always-lvl-mods-list :type list)
   (avail-controlled-list :initform () :accessor scenario-gen-class/avail-controlled-list :type list)
   (select-controlled-mod :initform nil :accessor scenario-gen-class/select-controlled-mod :type (or null level-modifier))
   (avail-feats-list :initform () :accessor scenario-gen-class/avail-feats-list :type list)
   (select-feats-list :initform () :accessor scenario-gen-class/select-feats-list :type list)
   (avail-items-list :initform () :accessor scenario-gen-class/avail-items-list :type list)
   (select-items-list :initform () :accessor scenario-gen-class/select-items-list :type list)
   (avail-tod-list :initform () :accessor scenario-gen-class/avail-tod-list :type list)
   (select-tod-mod  :initform nil :accessor scenario-gen-class/select-tod-mod :type (or null level-modifier))
   (avail-weather-list :initform () :accessor scenario-gen-class/avail-weather-list :type list)
   (select-weather-list :initform () :accessor scenario-gen-class/select-weather-list :type list)

   (avail-faction-list :initform () :accessor  scenario-gen-class/avil-faction-list :type list)
   (cur-faction-list :initform () :accessor  scenario-gen-class/cur-faction-list :type list)

   (specific-faction-list :initform () :accessor  scenario-gen-class/specific-faction-list :type list)
   ))

(defun scenario-set-avail-mission-types (scenario &optional (new-mission-type-list ()))
  (with-slots (avail-mission-type-list) scenario
    ;; set a list of available mission types
    (setf avail-mission-type-list new-mission-type-list)
    
    ;; if no specific mission list is supplied, find all enabled missions
    (when (null avail-mission-type-list)
      (setf avail-mission-type-list (get-all-mission-types-list))
      (setf avail-mission-type-list (list (get-mission-type-by-id :mission-type-demonic-attack)
                                          (get-mission-type-by-id :mission-type-demonic-raid)
                                          (get-mission-type-by-id :mission-type-military-conquest))))
    ))

(defun scenario-set-avail-world-sector-types (scenario &optional (new-world-sector-type-list ()))
  (with-slots (avail-world-sector-type-list mission) scenario
    ;; set a list of available world sector types
    (setf avail-world-sector-type-list new-world-sector-type-list)
    
    ;; if no specific world sector list is supplied, find all world sectors for this mission
    (when (null avail-world-sector-type-list)
      (setf avail-world-sector-type-list (loop for world-sector-id in (world-sector-for-custom-scenario (get-mission-type-by-id (mission-type-id mission)))
                                               collect (get-world-sector-type-by-id world-sector-id))))
    ))

(defun scenario-set-avail-lvl-mods (scenario &optional (new-avail-lvl-mods-list ()))
  (with-slots (overall-lvl-mods-list select-lvl-mods-list select-controlled-mod select-feats-list select-items-list select-tod-mod select-weather-list
               avail-lvl-mods-list avail-controlled-list avail-feats-list avail-items-list avail-tod-list avail-weather-list world-sector mission world)
      scenario
    ;; set a list of available lvl mods
    (setf avail-lvl-mods-list new-avail-lvl-mods-list)

    ;; if no specific lvl mod list is supplied, find all available lvl mods
    (when (not avail-lvl-mods-list)
      (setf avail-lvl-mods-list (get-all-lvl-mods-list)))
    
    ;; populate lists for specific lvl mod types
    (loop initially (setf select-lvl-mods-list ()
                          select-controlled-mod nil
                          select-feats-list ()
                          select-items-list ()
                          select-tod-mod nil
                          select-weather-list ()
                          avail-controlled-list ()
                          avail-feats-list ()
                          avail-items-list ()
                          avail-tod-list ()
                          avail-weather-list ())
          for lvl-mod in avail-lvl-mods-list
          when (and (is-available-for-mission lvl-mod)
                    (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
            do
               (cond
                 ((= (lm-type lvl-mod) +level-mod-controlled-by+) (push lvl-mod avail-controlled-list))
                 ((= (lm-type lvl-mod) +level-mod-sector-feat+) (push lvl-mod avail-feats-list))
                 ((= (lm-type lvl-mod) +level-mod-sector-item+) (push lvl-mod avail-items-list))
                 ((= (lm-type lvl-mod) +level-mod-time-of-day+) (push lvl-mod avail-tod-list))
                 ((= (lm-type lvl-mod) +level-mod-weather+) (push lvl-mod avail-weather-list)))
          finally (setf overall-lvl-mods-list (append avail-controlled-list avail-feats-list avail-items-list avail-tod-list avail-weather-list))) 
    ))

(defun scenario-create-world (scenario)
  (with-slots (world) scenario
    (setf world (make-instance 'world))

    (with-slots (world-map) world
      (setf world-map (make-instance 'world-map))
      (generate-empty-world-map world-map)

      (loop for lm-controlled-id in (list +lm-controlled-by-demons+ +lm-controlled-by-military+) do
        (loop for x = (random *max-x-world-map*)
              for y = (random *max-y-world-map*)
              while (or (and (<= x 2)
                             (<= y 2))
                        (/= (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-none+))
              finally
                 (setf (controlled-by (aref (cells world-map) x y)) lm-controlled-id)))

      (scenario-set-world-date scenario 1915 (random 12) (random 30) 0 0 0))))

(defun scenario-create-mission (scenario mission-type-id &key (x 1) (y 1))
  (with-slots (mission) scenario
    ;; create the mission
    (setf mission (make-instance 'mission :mission-type-id mission-type-id
                                          :x x :y y
                                          :faction-list ()
                                          :level-modifier-list ()))
    ))

(defun scenario-create-sector (scenario world-sector-type-id)
  (with-slots (world world-sector mission) scenario
    (loop for x from 0 to 2 do
      (loop for y from 0 to 2 do
        (setf (aref (cells (world-map world)) x y) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x x :y y))))
    
    (setf world-sector (make-instance 'world-sector :wtype world-sector-type-id
                                                    :x 1 :y 1))
    (setf (aref (cells (world-map world)) 1 1) world-sector)
    (setf (mission world-sector) mission)
    (setf (level-modifier-list mission) ())
    (setf (faction-list mission) ())
    
    (when (scenario-enabled-func (get-world-sector-type-by-id (wtype world-sector)))
      (funcall (scenario-enabled-func (get-world-sector-type-by-id (wtype world-sector))) (world-map world) (x world-sector) (y world-sector)))))

(defun scenario-set-world-date (scenario &optional (year 1915) (month 0) (day 0) (hour 0) (min 0) (sec 0))
  (with-slots (world) scenario
    (setf (world-game-time world) (set-current-date-time year
                                                         month
                                                         day
                                                         hour min sec))))

(defun scenario-set-controlled-by-lvl-mod (scenario lvl-mod &key (add-to-sector t) (apply-scenario-func t))
  (with-slots (world-sector world select-lvl-mods-list select-controlled-mod) scenario
    (let ((prev-lvl-mod (get-level-modifier-by-id (controlled-by world-sector))))
      ;; remove previous controlled-by from sector
      (when (and prev-lvl-mod
                 apply-scenario-func
                 (scenario-disabled-func prev-lvl-mod))
        (funcall (scenario-disabled-func prev-lvl-mod) (world-map world) (x world-sector) (y world-sector)))
      
      ;; set new controlled-by in window
      (setf select-lvl-mods-list (remove prev-lvl-mod select-lvl-mods-list))
      (setf select-controlled-mod lvl-mod)
      (pushnew lvl-mod select-lvl-mods-list)
      
      ;; add new controlled-by to sector
      (when add-to-sector
        (setf (controlled-by world-sector) (id lvl-mod)))
      (when (and apply-scenario-func
                 (scenario-enabled-func lvl-mod))
        (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))

(defun scenario-add/remove-feat-lvl-mod (scenario lvl-mod &key (add-general t) (add-to-sector t) (apply-scenario-func t))
  (with-slots (world world-sector select-lvl-mods-list select-feats-list) scenario
    (if add-general
      ;; either add...
      (progn
        ;; do not add if already added
        (when (not (find lvl-mod select-lvl-mods-list))
          (push lvl-mod select-lvl-mods-list)
          (push lvl-mod select-feats-list)
          
          (when add-to-sector
            (push (list (id lvl-mod) nil) (feats world-sector)))
          (when (and apply-scenario-func
                     (scenario-enabled-func lvl-mod))
            (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))))
      ;; ...or remove
      (progn
        (when (and apply-scenario-func
                   (scenario-disabled-func lvl-mod))
          (funcall (scenario-disabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))
        (setf (feats world-sector) (remove (id lvl-mod) (feats world-sector) :key #'(lambda (a) (first a))))
        
        (setf select-lvl-mods-list (remove lvl-mod select-lvl-mods-list))
        (setf select-feats-list (remove lvl-mod select-feats-list))))))

(defun scenario-add/remove-item-lvl-mod (scenario lvl-mod &key (add-general t) (add-to-sector t) (apply-scenario-func t))
  (with-slots (world world-sector select-lvl-mods-list select-items-list) scenario
    (if add-general
      ;; either add...
      (progn
        ;; do not add if already added
        (when (not (find lvl-mod select-lvl-mods-list))
          (push lvl-mod select-lvl-mods-list)
          (push lvl-mod select-items-list)
          
          (when add-to-sector
            (push (id lvl-mod) (items world-sector)))
          (when (and apply-scenario-func
                     (scenario-enabled-func lvl-mod))
            (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))))
      ;; ...or remove
      (progn
        (when (and apply-scenario-func
                   (scenario-disabled-func lvl-mod))
          (funcall (scenario-disabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))
        (setf (items world-sector) (remove (id lvl-mod) (items world-sector)))
        
        (setf select-lvl-mods-list (remove lvl-mod select-lvl-mods-list))
        (setf select-items-list (remove lvl-mod select-items-list))))))

(defun scenario-set-tod-lvl-mod (scenario lvl-mod &key (add-to-sector t) (apply-scenario-func t))
  (with-slots (world world-sector mission select-lvl-mods-list select-tod-mod) scenario
    (let ((prev-lvl-mod (find +level-mod-time-of-day+ (level-modifier-list mission)
                              :key #'(lambda (a)
                                       (lm-type (get-level-modifier-by-id a))))))
      ;; remove previous tod from sector
      (when (and prev-lvl-mod
                 apply-scenario-func
                 (scenario-disabled-func prev-lvl-mod))
        (funcall (scenario-disabled-func prev-lvl-mod) (world-map world) (x world-sector) (y world-sector))
        (remove (id prev-lvl-mod) (level-modifier-list mission)))
      
      ;; set new tod in window
      (setf select-lvl-mods-list (remove prev-lvl-mod select-lvl-mods-list))
      (setf select-tod-mod lvl-mod)
      (pushnew lvl-mod select-lvl-mods-list)
      
      ;; add new to to sector
      (when add-to-sector
        (push (id lvl-mod) (level-modifier-list mission)))
      (when (and apply-scenario-func
                 (scenario-enabled-func lvl-mod))
        (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))

(defun scenario-add/remove-weather-lvl-mod (scenario lvl-mod &key (add-general t) (add-to-sector t) (apply-scenario-func t))
  (with-slots (world world-sector mission select-lvl-mods-list select-weather-list) scenario
    (if add-general
      ;; either add...
      (progn
        ;; do not add if already added
        (when (not (find lvl-mod select-lvl-mods-list))
          (push lvl-mod select-lvl-mods-list)
          (push lvl-mod select-weather-list)
          
          (when add-to-sector
            (push (id lvl-mod) (level-modifier-list mission)))
          (when (and apply-scenario-func
                     (scenario-enabled-func lvl-mod))
            (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))))
      ;; ...or remove
      (progn
        (when (and apply-scenario-func
                   (scenario-disabled-func lvl-mod))
          (funcall (scenario-disabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))
        (setf (level-modifier-list mission) (remove (id lvl-mod) (level-modifier-list mission)))
        
        (setf select-lvl-mods-list (remove lvl-mod select-lvl-mods-list))
        (setf select-weather-list (remove lvl-mod select-weather-list))))))

(defun scenario-add/remove-lvl-mod (scenario lvl-mod &key (add-general t) (add-to-sector t) (apply-scenario-func t))
  (cond
    ((= (lm-type lvl-mod) +level-mod-controlled-by+) (scenario-set-controlled-by-lvl-mod scenario lvl-mod :add-to-sector add-to-sector :apply-scenario-func apply-scenario-func))
    ((= (lm-type lvl-mod) +level-mod-sector-feat+) (scenario-add/remove-feat-lvl-mod scenario lvl-mod :add-general add-general :add-to-sector add-to-sector :apply-scenario-func apply-scenario-func))
    ((= (lm-type lvl-mod) +level-mod-sector-item+) (scenario-add/remove-item-lvl-mod scenario lvl-mod :add-general add-general :add-to-sector add-to-sector :apply-scenario-func apply-scenario-func))
    ((= (lm-type lvl-mod) +level-mod-time-of-day+) (scenario-set-tod-lvl-mod scenario lvl-mod :add-to-sector add-to-sector :apply-scenario-func apply-scenario-func))
    ((= (lm-type lvl-mod) +level-mod-weather+) (scenario-add/remove-weather-lvl-mod scenario lvl-mod :add-general add-general :add-to-sector add-to-sector :apply-scenario-func apply-scenario-func))))

(defun scenario-adjust-lvl-mods-after-sector-regeneration (scenario)
  (with-slots (world world-sector mission always-lvl-mods-list select-lvl-mods-list) scenario
    ;; if there are lvl mods in world sector that are not added properly, add them (availability check is done inside add/remove, so lvl-mods are not duplicated)
    (loop for (lvl-mod-id aux) in (feats world-sector)
          for lvl-mod = (get-level-modifier-by-id lvl-mod-id)
          do
             (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t :add-to-sector nil))
    
    ;; add feats from always present lvl mods from the world sector
    (loop initially (setf always-lvl-mods-list ())
          for lvl-mod-id in (funcall (always-lvl-mods-func (get-world-sector-type-by-id (wtype world-sector))) world-sector (mission-type-id mission) (world-game-time world))
          do
             (scenario-add/remove-lvl-mod scenario (get-level-modifier-by-id lvl-mod-id) :add-general t)
             (pushnew (get-level-modifier-by-id lvl-mod-id) always-lvl-mods-list))
    
    ;; go through all (select-lvl-mods-list win) and add all lvl-mods they depend on (as well as dependencies of dependencies, etc.)
    (loop with overall-depend-lvl-mod-list = ()
          with lvl-mod = nil
          with push-dependent-func = #'(lambda (depend-lvl-mod-list)
                                         (loop for depend-lvl-mod-id in depend-lvl-mod-list
                                               for depend-lvl-mod = (get-level-modifier-by-id depend-lvl-mod-id)
                                               do
                                                  (pushnew depend-lvl-mod overall-depend-lvl-mod-list)))
            initially
               (loop for lvl-mod in select-lvl-mods-list do
                 (funcall push-dependent-func (funcall (depends-on-lvl-mod-func lvl-mod) world-sector (mission-type-id mission) (world-game-time world))))
          while (> (length overall-depend-lvl-mod-list) 0) do
            (setf lvl-mod (pop overall-depend-lvl-mod-list))
            (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t)
            (pushnew lvl-mod always-lvl-mods-list)

            (funcall push-dependent-func (funcall (depends-on-lvl-mod-func lvl-mod) world-sector (mission-type-id mission) (world-game-time world))))
    ))

(defun scenario-sort-select-lvl-mods (scenario)
  (with-slots (select-lvl-mods-list) scenario
    (setf select-lvl-mods-list (stable-sort select-lvl-mods-list #'(lambda (a b)
                                                                     (if (< (lm-type a) (lm-type b))
                                                                       t
                                                                       nil))))))

(defun scenario-adjust-factions (scenario &key (req-faction-id nil) (req-faction-present nil))
  (with-slots (world-sector mission avail-faction-list cur-faction-list) scenario
    ;; find all general factions
    (loop initially (setf avail-faction-list ())
          with sector-factions = (if (faction-list-func (get-world-sector-type-by-id (wtype world-sector)))
                                   (funcall (faction-list-func (get-world-sector-type-by-id (wtype world-sector))))
                                   nil)
          
          with controlled-by-factions = (if (faction-list-func (get-level-modifier-by-id (controlled-by world-sector)))
                                          (funcall (faction-list-func (get-level-modifier-by-id (controlled-by world-sector))) (wtype world-sector))
                                          nil)
          
          with feats-factions = (loop for (feat-id) in (feats world-sector)
                                      when (faction-list-func (get-level-modifier-by-id feat-id))
                                        append (funcall (faction-list-func (get-level-modifier-by-id feat-id)) (wtype world-sector)))
          
          with items-factions = (loop for item-id in (items world-sector)
                                      when (faction-list-func (get-level-modifier-by-id item-id))
                                        append (funcall (faction-list-func (get-level-modifier-by-id item-id)) (wtype world-sector)))
          
          with mission-factions = (if (faction-list-func (get-mission-type-by-id (mission-type-id mission)))
                                    (funcall (faction-list-func (get-mission-type-by-id (mission-type-id mission))) world-sector)
                                    nil)
          
          with overall-factions = (append sector-factions controlled-by-factions feats-factions items-factions mission-factions)
          for (faction-id faction-present) in overall-factions
          for faction-obj = (find faction-id avail-faction-list :key #'(lambda (a) (first a)))
          do
             (if faction-obj
               (progn
                 (when (not (find faction-present (second faction-obj)))
                   (push faction-present (second faction-obj))))
               (progn
                 (push (list faction-id (list faction-present)) avail-faction-list)))
          finally
             (loop initially (setf cur-faction-list ())
                   for (faction-id faction-present-list) in avail-faction-list
                   do
                      (if (and req-faction-id (= faction-id req-faction-id))
                        (push (list faction-id req-faction-present) cur-faction-list)
                        (push (list faction-id (nth (random (length faction-present-list)) faction-present-list))
                              cur-faction-list))
                   finally (setf cur-faction-list (stable-sort cur-faction-list #'(lambda (a b)
                                                                                    (if (eq (second a) :mission-faction-present)
                                                                                      (if (string-lessp (name (get-faction-type-by-id (first a)))
                                                                                                        (name (get-faction-type-by-id (first b))))
                                                                                        t
                                                                                        nil)
                                                                                      nil))))
                           (setf (faction-list mission) cur-faction-list)))))

(defun scenario-adjust-specific-factions (scenario)
  (with-slots (mission cur-faction-list specific-faction-list) scenario
    (loop initially (setf specific-faction-list ())
          for (faction-id faction-present) in cur-faction-list
          for faction-obj = (get-faction-type-by-id faction-id)
          when (or (eq faction-present :mission-faction-present)
                   (eq faction-present :mission-faction-delayed))
            do
               (loop for specific-faction-type in (specific-faction-list faction-obj)
                     when (find specific-faction-type (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                :key #'(lambda (a) (first a)))
                       do
                          (push specific-faction-type specific-faction-list))
          finally (setf specific-faction-list (reverse specific-faction-list))
                  (when (not *cotd-release*)
                    (when (find +specific-faction-type-player+ (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                :key #'(lambda (a) (first a)))
                      (push +specific-faction-type-player+ specific-faction-list))
                    (when (find +specific-faction-type-dead-player+ (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                :key #'(lambda (a) (first a)))
                      (push +specific-faction-type-dead-player+ specific-faction-list)))
                  (remove-duplicates specific-faction-list))))

(defun scenario-set-player-specific-faction (scenario specific-faction-type)
  (with-slots (mission) scenario
    (setf (player-lvl-mod-placement-id mission) (second (find specific-faction-type (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                              :key #'(lambda (a) (first a)))))))

(defun find-random-scenario-options (specific-faction-type &key (avail-mission-type-list nil) (avail-world-sector-type-list nil) (avail-lvl-mods-list nil) )
  (let ((available-faction-list ())
        (available-variants-list ()))

    ;; find all factions that have the required specific faction
    (setf available-faction-list (loop for faction-type across *faction-types*
                                       when (and faction-type
                                                 (find specific-faction-type (specific-faction-list faction-type)))
                                         collect (id faction-type)))

    (when (null available-faction-list)
      (return-from find-random-scenario-options (generate-random-scenario nil nil :mission-faction-present specific-faction-type
                                                                          :avail-mission-type-list avail-mission-type-list
                                                                          :avail-world-sector-type-list nil
                                                                          :avail-lvl-mods-list avail-lvl-mods-list)))

    ;; if available lvl-mods are not supplied, take all of them
    (when (not avail-lvl-mods-list)
      (setf avail-lvl-mods-list (get-all-lvl-mods-list)))

    ;; if available mission-types are not supplied, take all of them
    (when (not avail-mission-type-list)
      (setf avail-mission-type-list (get-all-mission-types-list))
      (setf avail-mission-type-list (list (get-mission-type-by-id :mission-type-demonic-attack)
                                          (get-mission-type-by-id :mission-type-demonic-raid)
                                          (get-mission-type-by-id :mission-type-military-conquest))))
    
    ;; if available sector types are not supplied, find all possible sectors in game
    (when (not avail-world-sector-type-list)
      (setf avail-world-sector-type-list (get-all-world-sector-types-list)))
    
    ;; find all lvl mods that produce the required faction & are available for mission & world-sector
    (loop for lvl-mod in avail-lvl-mods-list
          when (faction-list-func lvl-mod) do
            (loop for world-sector-type in avail-world-sector-type-list do
              (loop with result-1 = nil
                    for (faction-type-id faction-present) in (funcall (faction-list-func lvl-mod) (wtype world-sector-type))
                    when (eq faction-present :mission-faction-present) do
                      (setf result-1 (loop with result-2 = nil
                                           for target-faction-id in available-faction-list
                                           when (= target-faction-id faction-type-id) do
                                             (setf result-2 t)
                                             (loop-finish)
                                           finally (return result-2)))
                      (when result-1
                        (loop for mission-type in avail-mission-type-list
                              when (world-sector-for-custom-scenario mission-type) do
                                (loop for world-sector-type-id in (world-sector-for-custom-scenario mission-type)
                                      when (= world-sector-type-id (wtype world-sector-type)) do
                                        (loop for month in (list 0 1 2 3 4 5 6 7 8 9 10 11)
                                              for world-time = (set-current-date-time 1915 month 0 0 0 0) do
                                                (when (and (is-available-for-mission lvl-mod)
                                                           (funcall (is-available-for-mission lvl-mod) (wtype world-sector-type) (id mission-type) world-time))
                                                  (push (list lvl-mod world-sector-type mission-type) available-variants-list)
                                                  (loop-finish)))
                                      ))))))

    ;; find all world-sectors that produce the required faction & are available for mission
    (loop for world-sector-type in avail-world-sector-type-list
          when (faction-list-func world-sector-type) do
            (loop with result-1 = nil
                  for (faction-type-id faction-present) in (funcall (faction-list-func world-sector-type))
                  when (eq faction-present :mission-faction-present) do
                    (setf result-1 (loop with result-2 = nil
                                         for target-faction-id in available-faction-list
                                         when (= target-faction-id faction-type-id) do
                                           (setf result-2 t)
                                           (loop-finish)
                                         finally (return result-2)))
                    (when result-1
                      (loop for mission-type in avail-mission-type-list
                            when (world-sector-for-custom-scenario mission-type) do
                              (loop for world-sector-type-id in (world-sector-for-custom-scenario mission-type)
                                    when (= world-sector-type-id (wtype world-sector-type)) do
                                      (push (list nil world-sector-type mission-type) available-variants-list))))))

    ;; find all missions that produce the required faction
    (loop for mission-type in avail-mission-type-list
          when (faction-list-func mission-type) do
            (loop for world-sector-type in avail-world-sector-type-list
                  for world-sector = (make-instance 'world-sector :wtype (wtype world-sector-type) :x 1 :y 1)
                  do
                     (loop with result-1 = nil
                           for (faction-type-id faction-present) in (funcall (faction-list-func mission-type) world-sector)
                           when (eq faction-present :mission-faction-present) do
                             (setf result-1 (loop with result-2 = nil
                                                  for target-faction-id in available-faction-list
                                                  when (= target-faction-id faction-type-id) do
                                                    (setf result-2 t)
                                                    (loop-finish)
                                                  finally (return result-2)))
                             (when result-1
                               (when (world-sector-for-custom-scenario mission-type)
                                 (loop for world-sector-type-id in (world-sector-for-custom-scenario mission-type)
                                       when (= world-sector-type-id (wtype world-sector-type)) do
                                         (push (list nil world-sector-type mission-type) available-variants-list)))))
                     ))
    
    (loop for (lvl-mod world-sector-type mission-type) in available-variants-list do
      (format t "Lvl-mod ~A, World Sector: ~A, Mission Type: ~A~%"
              (if lvl-mod
                (name lvl-mod)
                "NIL")
              (if world-sector-type
                (name world-sector-type)
                "NIL")
              (if mission-type
                (name mission-type)
                "NIL")))

    (when available-variants-list
      ;; generate a mission with all other parameters & exit
      (let ((lvl-mod-obj (nth (random (length available-variants-list)) available-variants-list)))
        (return-from find-random-scenario-options (generate-random-scenario (first lvl-mod-obj) (nth (random (length available-faction-list)) available-faction-list) :mission-faction-present specific-faction-type
                                                                            :avail-mission-type-list (list (third lvl-mod-obj))
                                                                            :avail-world-sector-type-list (list (second lvl-mod-obj))
                                                                            :avail-lvl-mods-list avail-lvl-mods-list)))
   
      )))

(defun generate-random-scenario (req-lvl-mod req-faction-id req-faction-present specific-faction-type &key (avail-mission-type-list nil) (avail-world-sector-type-list nil) (avail-lvl-mods-list nil))
  (let ((scenario (make-instance 'scenario-gen-class))
        (lvl-mod-controlled-by-set nil)
        (lvl-mod-feats-set nil)
        (lvl-mod-items-set nil)
        (lvl-mod-tod-set nil)
        (lvl-mod-weather-set nil))
    
    (flet ((add-lvl-mod (lvl-mod &key (add-to-sector t))
             (cond
               ((= (lm-type lvl-mod) +level-mod-controlled-by+) (progn
                                                                  (setf lvl-mod-controlled-by-set t)
                                                                  (scenario-set-controlled-by-lvl-mod scenario lvl-mod :add-to-sector add-to-sector)))
               ((= (lm-type lvl-mod) +level-mod-sector-feat+) (progn
                                                                (setf lvl-mod-feats-set t)
                                                                (scenario-add/remove-feat-lvl-mod scenario lvl-mod :add-general t :add-to-sector add-to-sector)))
               ((= (lm-type lvl-mod) +level-mod-sector-item+) (progn
                                                                (setf lvl-mod-items-set t)
                                                                (scenario-add/remove-item-lvl-mod scenario lvl-mod :add-general t :add-to-sector add-to-sector)))
               ((= (lm-type lvl-mod) +level-mod-time-of-day+) (progn
                                                                (setf lvl-mod-tod-set t)
                                                                (scenario-set-tod-lvl-mod scenario lvl-mod :add-to-sector add-to-sector)))
               ((= (lm-type lvl-mod) +level-mod-weather+) (progn
                                                            (setf lvl-mod-weather-set t)
                                                            (scenario-add/remove-weather-lvl-mod scenario lvl-mod :add-general t :add-to-sector add-to-sector))))))

      (with-slots (world world-sector mission avail-controlled-list avail-feats-list avail-items-list avail-tod-list avail-weather-list) scenario
        ;; create the supporting world
        (scenario-create-world scenario)
        
        ;; set up available missions
        (scenario-set-avail-mission-types scenario avail-mission-type-list)

        ;; create the mission
        (scenario-create-mission scenario (id (nth (random (length (scenario-gen-class/avail-mission-type-list scenario))) (scenario-gen-class/avail-mission-type-list scenario))))

        ;; set up available world-sectors
        (scenario-set-avail-world-sector-types scenario avail-world-sector-type-list)

        ;; create the world sector
        (scenario-create-sector scenario (wtype (nth (random (length (scenario-gen-class/avail-world-sector-type-list scenario))) (scenario-gen-class/avail-world-sector-type-list scenario))))

        ;; set up available lvl mods
        (scenario-set-avail-lvl-mods scenario avail-lvl-mods-list)

        ;; add the required lvl-mod
        (when req-lvl-mod
          (add-lvl-mod req-lvl-mod))

        ;; if controlled-by is not already set, set a random controlled-by lvl-mod
        (when (not lvl-mod-controlled-by-set)
          (add-lvl-mod (nth (random (length avail-controlled-list)) avail-controlled-list)))

        ;; add random feats lvl-mods
        (loop for lvl-mod in avail-feats-list
              when (zerop (random 4)) do
                (add-lvl-mod lvl-mod))

        ;; add random items lvl-mods
        (loop for lvl-mod in avail-items-list
            when (zerop (random 4)) do
              (add-lvl-mod lvl-mod))

        (generate-feats-for-world-sector world-sector (world-map world))

        ;; if tod is not already set, find and set a random time-of-day lvl-mod
        (when (not lvl-mod-tod-set)
          (add-lvl-mod (nth (random (length avail-tod-list)) avail-tod-list)))

        ;; add random weather lvl-mods
        (loop for lvl-mod in avail-weather-list
              when (or (not (random-available-for-mission lvl-mod))
                       (funcall (random-available-for-mission lvl-mod)))
                do
                   (add-lvl-mod lvl-mod))

        ;; add all dependent lvl mods, as well as lvl mods after wrold sector generation above
        (scenario-adjust-lvl-mods-after-sector-regeneration scenario)

        (scenario-sort-select-lvl-mods scenario)

        ;; set up a all general factions
        (scenario-adjust-factions scenario :req-faction-id req-faction-id :req-faction-present req-faction-present)

        ;; set up the required player faction
        (scenario-set-player-specific-faction scenario specific-faction-type)
                
        (setf *world* world)

        (return-from generate-random-scenario (values mission world-sector))))))
