(in-package :cotd)

(defconstant +custom-scenario-win-mission+ 0)
(defconstant +custom-scenario-win-layout+ 1)
(defconstant +custom-scenario-win-weather+ 2)
(defconstant +custom-scenario-win-time-of-day+ 3)
(defconstant +custom-scenario-win-factions+ 4)
(defconstant +custom-scenario-win-specific-faction+ 5)

(defenum:defenum custom-scenario-window-tab-type (:custom-scenario-tab-missions
                                                  :custom-scenario-tab-sectors
                                                  :custom-scenario-tab-months
                                                  :custom-scenario-tab-feats
                                                  :custom-scenario-tab-factions
                                                  :custom-scenario-tab-specific-factions))

(defclass custom-scenario-window (window)
  ((cur-step :initform :custom-scenario-tab-missions :accessor cur-step)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :accessor menu-items)

   (world :initarg :world :accessor world :type world)
   
   (world-sector :accessor world-sector)
   (mission :accessor mission)

   (mission-type-list :initform () :accessor mission-type-list)
   (cur-mission-type :initform 0 :accessor cur-mission-type :type fixnum)

   (sector-list :initform () :accessor sector-list)
   (cur-sector :initform 0 :accessor cur-sector :type fixnum)

   (months-list :initform (list "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December") :accessor months-list)
   (cur-month :initform 0 :accessor cur-month :type fixnum)

   (overall-lvl-mods-list :initform () :accessor overall-lvl-mods-list)
   (select-lvl-mods-list :initform () :accessor select-lvl-mods-list)
   (always-lvl-mods-list :initform () :accessor always-lvl-mods-list)
   (avail-controlled-list :initform () :accessor avail-controlled-list)
   (select-controlled-mod :initform nil :accessor select-controlled-mod)
   (avail-feats-list :initform () :accessor avail-feats-list)
   (select-feats-list :initform () :accessor select-feats-list)
   (avail-items-list :initform () :accessor avail-items-list)
   (select-items-list :initform () :accessor select-items-list)
   (avail-tod-list :initform () :accessor avail-tod-list)
   (select-tod-mod  :initform nil :accessor select-tod-mod)
   (avail-weather-list :initform () :accessor avail-weather-list)
   (select-weather-list :initform () :accessor select-weather-list)
   (cur-feat :initform 0 :accessor cur-feat :type fixnum)

   (ref-faction-list :initform () :accessor ref-faction-list)
   (cur-faction-list :initform () :accessor cur-faction-list)
   (cur-faction :initform 0 :accessor cur-faction :type fixnum)
   
   (specific-faction-list :initform () :accessor specific-faction-list)
   (cur-specific-faction :initform 0 :accessor cur-specific-faction :type fixnum)
   ))

(defmethod initialize-instance :after ((win custom-scenario-window) &key)

  (setf *current-window* win)

  (setf (cur-month win) (random 12))
  (setf (world-game-time (world win)) (set-current-date-time 1915
                                                             (cur-month win)
                                                             (random 30)
                                                             0 0 0))
  
  ;; find all available missions
  (setf (mission-type-list win) (loop for id being the hash-keys in *mission-types*
                                      when (enabled (get-mission-type-by-id id))
                                        collect (get-mission-type-by-id id)))

  (setf (mission-type-list win) (loop for id in (list +mission-type-demonic-attack+ +mission-type-demonic-raid+ +mission-type-military-conquest+)
                                       when (enabled (get-mission-type-by-id id))
                                         collect (get-mission-type-by-id id)))
  
  (setf (cur-mission-type win) (random (length (mission-type-list win))))

  (adjust-mission-after-change win)
  
  (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
  (setf (cur-sel win) (cur-mission-type win))
  )

(defun adjust-mission-after-change (win)
  (setf (mission win) (make-instance 'mission :mission-type-id (id (nth (cur-mission-type win) (mission-type-list win)))
                                              :x 1 :y 1
                                              :faction-list ()
                                              :level-modifier-list ()))
  
  (readjust-sectors-after-mission-change win))

(defun readjust-sectors-after-mission-change (win)
  ;; a precaution for the first start before any sectors are added
  (let ((cur-world-sector-type (if (sector-list win)
                                 (nth (cur-sector win) (sector-list win))
                                 nil)))

    ;; find all available sectors for the selected mission
    (setf (sector-list win) (loop for world-sector-id in (world-sector-for-custom-scenario (get-mission-type-by-id (mission-type-id (mission win))))
                                  collect (get-world-sector-type-by-id world-sector-id)))

    ;; make the selection be the same if there is a world-sector in the new selection
    (if (and cur-world-sector-type
             (position cur-world-sector-type (sector-list win)))
      (progn
        (setf (cur-sector win) (position cur-world-sector-type (sector-list win))))
      (progn
        (setf (cur-sector win) (random (length (sector-list win))))))
        
    (adjust-world-sector-after-change win)))

(defun adjust-world-sector-after-change (win)
  (loop for x from 0 to 2 do
    (loop for y from 0 to 2 do
      (setf (aref (cells (world-map (world win))) x y) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x x :y y))))
  
  (setf (world-sector win) (make-instance 'world-sector :wtype (wtype (nth (cur-sector win) (sector-list win)))
                                                        :x 1 :y 1))
  (setf (aref (cells (world-map (world win))) 1 1) (world-sector win))
  (setf (mission (world-sector win)) (mission win))
  
  (when (scenario-enabled-func (get-world-sector-type-by-id (wtype (world-sector win))))
    (funcall (scenario-enabled-func (get-world-sector-type-by-id (wtype (world-sector win)))) (world-map (world win)) (x (world-sector win)) (y (world-sector win)))) 
  
  (readjust-feats-after-sector-change win))

(defun adjust-months-before-feats (win)
  (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time (world win)))
    (declare (ignore month))
    (setf (world-game-time (world win)) (set-current-date-time year
                                                               (cur-month win)
                                                               day
                                                               hour min sec)))
  (adjust-world-sector-after-change win))

(defun set-controlled-by-lvl-mod (win lvl-mod &key (add-to-sector t))
  (let ((prev-lvl-mod (select-controlled-mod win)))
    ;; remove previous controlled-by from sector
    (when (and prev-lvl-mod
               (scenario-disabled-func prev-lvl-mod))
      (funcall (scenario-disabled-func prev-lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
        
    ;; set new controlled-by in window
    (setf (select-lvl-mods-list win) (remove prev-lvl-mod (select-lvl-mods-list win)))
    (setf (select-controlled-mod win) lvl-mod)
    (pushnew lvl-mod (select-lvl-mods-list win))

    ;; add new controlled-by to sector
    (when add-to-sector
      (setf (controlled-by (world-sector win)) (id lvl-mod)))
    (when (scenario-enabled-func lvl-mod)
      (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))))

(defun add/remove-feat-lvl-mod (win lvl-mod &key (add-general t) (add-to-sector t))
  (if add-general
    ;; either add...
    (progn
      ;; do not add if already added
      (when (not (find lvl-mod (select-lvl-mods-list win)))
        (push lvl-mod (select-lvl-mods-list win))
        (push lvl-mod (select-feats-list win))

        (when add-to-sector
          (push (list (id lvl-mod) nil) (feats (world-sector win))))
        (when (scenario-enabled-func lvl-mod)
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))))
    ;; ...or remove
    (progn
      (when (scenario-disabled-func lvl-mod)
        (funcall (scenario-disabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
      (setf (feats (world-sector win)) (remove (id lvl-mod) (feats (world-sector win)) :key #'(lambda (a) (first a))))

      (setf (select-lvl-mods-list win) (remove lvl-mod (select-lvl-mods-list win)))
      (setf (select-feats-list win) (remove lvl-mod (select-feats-list win))))))

(defun add/remove-item-lvl-mod (win lvl-mod &key (add-general t) (add-to-sector t))
  (if add-general
    ;; either add...
    (progn
      ;; do not add if already added
      (when (not (find lvl-mod (select-lvl-mods-list win)))
        (push lvl-mod (select-lvl-mods-list win))
        (push lvl-mod (select-items-list win))

        (when add-to-sector
          (push (id lvl-mod) (items (world-sector win))))
        (when (scenario-enabled-func lvl-mod)
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))))
    ;; ...or remove
    (progn
      (when (scenario-disabled-func lvl-mod)
        (funcall (scenario-disabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
      (setf (items (world-sector win)) (remove (id lvl-mod) (items (world-sector win))))

      (setf (select-lvl-mods-list win) (remove lvl-mod (select-lvl-mods-list win)))
      (setf (select-items-list win) (remove lvl-mod (select-items-list win))))))

(defun set-tod-lvl-mod (win lvl-mod &key (add-to-sector t))
  (let ((prev-lvl-mod (select-tod-mod win)))
    ;; remove previous tod from sector
    (when (and prev-lvl-mod
               (scenario-disabled-func prev-lvl-mod))
      (funcall (scenario-disabled-func prev-lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win)))
      (remove (id prev-lvl-mod) (level-modifier-list (mission win))))
    
    ;; set new tod in window
    (setf (select-lvl-mods-list win) (remove prev-lvl-mod (select-lvl-mods-list win)))
    (setf (select-tod-mod win) lvl-mod)
    (pushnew lvl-mod (select-lvl-mods-list win))

    ;; add new to to sector
    (when add-to-sector
      (push (id lvl-mod) (level-modifier-list (mission win))))
    (when (scenario-enabled-func lvl-mod)
      (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))))

(defun add/remove-weather-lvl-mod (win lvl-mod &key (add-general t) (add-to-sector t))
  (if add-general
    ;; either add...
    (progn
      ;; do not add if already added
      (when (not (find lvl-mod (select-lvl-mods-list win)))
        (push lvl-mod (select-lvl-mods-list win))
        (push lvl-mod (select-weather-list win))
        
        (when add-to-sector
          (push (id lvl-mod) (level-modifier-list (mission win))))
        (when (scenario-enabled-func lvl-mod)
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))))
    ;; ...or remove
    (progn
      (when (scenario-disabled-func lvl-mod)
        (funcall (scenario-disabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
      (setf (level-modifier-list (mission win)) (remove (id lvl-mod) (level-modifier-list (mission win))))

      (setf (select-lvl-mods-list win) (remove lvl-mod (select-lvl-mods-list win)))
      (setf (select-weather-list win) (remove lvl-mod (select-weather-list win))))))

(defun add/remove-lvl-mod (win lvl-mod &key (add-general t) (add-to-sector t))
  (cond
    ((= (lm-type lvl-mod) +level-mod-controlled-by+) (set-controlled-by-lvl-mod win lvl-mod :add-to-sector add-to-sector))
    ((= (lm-type lvl-mod) +level-mod-sector-feat+) (add/remove-feat-lvl-mod win lvl-mod :add-general add-general :add-to-sector add-to-sector))
    ((= (lm-type lvl-mod) +level-mod-sector-item+) (add/remove-item-lvl-mod win lvl-mod :add-general add-general :add-to-sector add-to-sector))
    ((= (lm-type lvl-mod) +level-mod-time-of-day+) (set-tod-lvl-mod win lvl-mod :add-to-sector add-to-sector))
    ((= (lm-type lvl-mod) +level-mod-weather+) (add/remove-weather-lvl-mod win lvl-mod :add-general add-general :add-to-sector add-to-sector))))

(defun readd-lvl-mods-after-sector-regeneration (win)

  ;; if there are lvl mods in world sector that are not added to window, add them (availability check is done inside add/remove, so lvl-mods are not duplicated)
  (loop for (lvl-mod-id aux) in (feats (world-sector win))
        for lvl-mod = (get-level-modifier-by-id lvl-mod-id)
        do
           (add/remove-lvl-mod win lvl-mod :add-general t :add-to-sector nil))

  (setf (always-lvl-mods-list win) ())

  ;; add feats from always present lvl mods from the world sector
  (loop for lvl-mod-id in (funcall (always-lvl-mods-func (get-world-sector-type-by-id (wtype (world-sector win)))) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))) do
    (add/remove-lvl-mod win (get-level-modifier-by-id lvl-mod-id) :add-general t)
    (pushnew (get-level-modifier-by-id lvl-mod-id) (always-lvl-mods-list win)))

  ;; go through all (select-lvl-mods-list win) and add all lvl-mods they depend on
  (loop for lvl-mod in (select-lvl-mods-list win)
        for depend-lvl-mod-list = (funcall (depends-on-lvl-mod-func lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win)))
        when depend-lvl-mod-list do
          (loop for depend-lvl-mod-id in depend-lvl-mod-list
                for depend-lvl-mod = (get-level-modifier-by-id depend-lvl-mod-id)
                do
                   (add/remove-lvl-mod win depend-lvl-mod :add-general t)
                   (pushnew depend-lvl-mod (always-lvl-mods-list win))))
  )

(defun readjust-feats-after-sector-change (win)
  (setf (select-lvl-mods-list win) ())
  
  ;; find all available controlled-by lvl-mods for the selected mission
  (setf (avail-controlled-list win) (loop for lvl-mod across *level-modifiers*
                                          when (and (= (lm-type lvl-mod) +level-mod-controlled-by+)
                                                    (is-available-for-mission lvl-mod)
                                                    (funcall (is-available-for-mission lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))))
                                            collect lvl-mod))
  (add/remove-lvl-mod win (nth (random (length (avail-controlled-list win))) (avail-controlled-list win)) :add-general t)
    
  ;; find all available feat lvl-mods for the selected mission
  (setf (avail-feats-list win) (loop for lvl-mod across *level-modifiers*
                                     when (and (= (lm-type lvl-mod) +level-mod-sector-feat+)
                                               (is-available-for-mission lvl-mod)
                                               (funcall (is-available-for-mission lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))))
                                       collect lvl-mod))
  (setf (select-feats-list win) ())
  (loop for lvl-mod in (avail-feats-list win)
        when (zerop (random 4)) do
          (add/remove-lvl-mod win lvl-mod :add-general t))

  ;; find all available item lvl-mods for the selected mission
  (setf (avail-items-list win) (loop for lvl-mod across *level-modifiers*
                                     when (and (= (lm-type lvl-mod) +level-mod-sector-item+)
                                               (is-available-for-mission lvl-mod)
                                               (funcall (is-available-for-mission lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))))
                                       collect lvl-mod))
  (setf (select-items-list win) ())
  (loop for lvl-mod in (avail-items-list win)
        when (zerop (random 4)) do
          (add/remove-lvl-mod win lvl-mod :add-general t))
  
  (generate-feats-for-world-sector (world-sector win) (world-map (world win)))
  
  ;; find all available time of day lvl-mods for the selected mission
  (setf (avail-tod-list win) (loop for lvl-mod across *level-modifiers*
                                   when (and (= (lm-type lvl-mod) +level-mod-time-of-day+)
                                             (is-available-for-mission lvl-mod)
                                             (funcall (is-available-for-mission lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))))
                                     collect lvl-mod))
  (add/remove-lvl-mod win (nth (random (length (avail-tod-list win))) (avail-tod-list win)) :add-general t)
    
  ;; find all available weather lvl-mods for the selected mission
  (setf (avail-weather-list win) (loop for lvl-mod across *level-modifiers*
                                       when (and (= (lm-type lvl-mod) +level-mod-weather+)
                                                 (is-available-for-mission lvl-mod)
                                                 (funcall (is-available-for-mission lvl-mod) (world-sector win) (mission-type-id (mission win)) (world-game-time (world win))))
                                         collect lvl-mod))
  (setf (select-weather-list win) ())
  (loop for lvl-mod in (avail-weather-list win)
        when (zerop (random 4)) do
          (add/remove-lvl-mod win lvl-mod :add-general t))
      
  (setf (overall-lvl-mods-list win) (append (avail-controlled-list win) (avail-feats-list win) (avail-items-list win) (avail-tod-list win) (avail-weather-list win)))
  (setf (cur-feat win) 0)
  (readd-lvl-mods-after-sector-regeneration win)
  (setf (select-lvl-mods-list win) (stable-sort (select-lvl-mods-list win) #'(lambda (a b)
                                                                               (if (< (lm-type a) (lm-type b))
                                                                                 t
                                                                                 nil))))
  
  (readjust-factions-after-feats-change win))

(defun readjust-factions-after-feats-change (win)
  ;; find all general factions
  (loop with sector-factions = (if (faction-list-func (get-world-sector-type-by-id (wtype (world-sector win))))
                                 (funcall (faction-list-func (get-world-sector-type-by-id (wtype (world-sector win)))))
                                 nil)
        
        with controlled-by-factions = (if (faction-list-func (get-level-modifier-by-id (controlled-by (world-sector win))))
                                        (funcall (faction-list-func (get-level-modifier-by-id (controlled-by (world-sector win)))) (world-sector win))
                                        nil)
        
        with feats-factions = (loop for (feat-id) in (feats (world-sector win))
                                    when (faction-list-func (get-level-modifier-by-id feat-id))
                                      append (funcall (faction-list-func (get-level-modifier-by-id feat-id)) (world-sector win)))
        
        with items-factions = (loop for item-id in (items (world-sector win))
                                    when (faction-list-func (get-level-modifier-by-id item-id))
                                      append (funcall (faction-list-func (get-level-modifier-by-id item-id)) (world-sector win)))
        
        with mission-factions = (if (faction-list-func (get-mission-type-by-id (mission-type-id (mission win))))
                                  (funcall (faction-list-func (get-mission-type-by-id (mission-type-id (mission win)))) (world-sector win))
                                  nil)
        
        with overall-factions = (append sector-factions controlled-by-factions feats-factions items-factions mission-factions)
        with result = ()
        for (faction-id faction-present) in overall-factions
        for faction-obj = (find faction-id result :key #'(lambda (a) (first a)))
        do
           (if faction-obj
             (progn
               (when (not (find faction-present (second faction-obj)))
                 (push faction-present (second faction-obj))))
             (progn
               (push (list faction-id (list faction-present)) result)))
        finally
           (setf (ref-faction-list win) result))

  (loop initially (setf (cur-faction-list win) ())
        for (faction-id faction-present-list) in (ref-faction-list win)
        do
           (push (list faction-id (nth (random (length faction-present-list)) faction-present-list))
                 (cur-faction-list win))
        finally (setf (faction-list (mission win)) (cur-faction-list win)))
  (setf (cur-faction win) (random (length (cur-faction-list win))))

  (readjust-specific-factions-after-faction-change win))

(defun readjust-specific-factions-after-faction-change (win)
  ;; find all specific factions
  (let ((cur-faction-id (if (specific-faction-list win)
                          (nth (cur-specific-faction win) (specific-faction-list win))
                          nil)))
    (setf (specific-faction-list win) (loop with result = ()
                                            for (faction-id faction-present) in (cur-faction-list win)
                                            for faction-obj = (get-faction-type-by-id faction-id)
                                            when (= faction-present +mission-faction-present+)
                                              do
                                                 (loop for specific-faction-type in (specific-faction-list faction-obj)
                                                       when (find specific-faction-type (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                  :key #'(lambda (a) (first a)))
                                                         do
                                                            (setf result (append result (list specific-faction-type))))
                                            finally  (when (not *cotd-release*)
                                                      (when (find +specific-faction-type-player+ (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                  :key #'(lambda (a) (first a)))
                                                        (push +specific-faction-type-player+ result))
                                                      (when (find +specific-faction-type-dead-player+ (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                  :key #'(lambda (a) (first a)))
                                                        (push +specific-faction-type-dead-player+ result)))
                                                     (remove-duplicates result)
                                                    (return-from nil result)))
    (if (and cur-faction-id
             (position cur-faction-id (specific-faction-list win)))
      (progn
        (setf (cur-specific-faction win) (position cur-faction-id (specific-faction-list win))))
      (progn
        (setf (cur-specific-faction win) (random (length (specific-faction-list win))))))
    )
  )

(defun populate-custom-scenario-win-menu (win step)
  (case step
    (:custom-scenario-tab-missions (return-from populate-custom-scenario-win-menu
                                    (loop for mission-type in (mission-type-list win)
                                          when (enabled mission-type)
                                            collect (name mission-type))))
    (:custom-scenario-tab-sectors (return-from populate-custom-scenario-win-menu
                                    (loop for world-sector-type in (sector-list win)
                                          collect (name world-sector-type))))
    (:custom-scenario-tab-months (return-from populate-custom-scenario-win-menu
                                   (copy-list (months-list win))))
    (:custom-scenario-tab-feats (return-from populate-custom-scenario-win-menu
                                  (loop for lvl-mod in (overall-lvl-mods-list win)
                                        collect (format nil "~A ~A"
                                                        (if (find lvl-mod (select-lvl-mods-list win))
                                                          "[+]"
                                                          "   ")
                                                        (name lvl-mod)))))
    (:custom-scenario-tab-factions (return-from populate-custom-scenario-win-menu
                                     (loop for (faction-id faction-present) in (cur-faction-list win)
                                           collect (format nil "~A ~A"
                                                           (cond
                                                             ((= faction-present +mission-faction-present+) "[+]")
                                                             ((= faction-present +mission-faction-delayed+) "[d]")
                                                             (t "   "))
                                                           (name (get-faction-type-by-id faction-id))))))
    (:custom-scenario-tab-specific-factions (return-from populate-custom-scenario-win-menu
                                              (loop for specific-faction-type in (specific-faction-list win)
                                                    when (find specific-faction-type (scenario-faction-list (mission-type-id (mission win)))
                                                               :key #'(lambda (a) (first a)))
                                                      collect (name (get-level-modifier-by-id (second (find specific-faction-type
                                                                                                            (scenario-faction-list (mission-type-id (mission win)))
                                                                                                            :key #'(lambda (a) (first a)))))))
                                              )))
  )

(defun get-included-faction-str (win-faction-list)
  (loop with str = (create-string)
        with first-no-comma = t
        for (faction-id faction-present) in win-faction-list
        when (/= faction-present +mission-faction-absent+) do
          (format str "~A~A ~A"
                  (if (not first-no-comma)
                    ", "
                    "")
                  (cond
                    ((= faction-present +mission-faction-present+) "[+]")
                    ((= faction-present +mission-faction-delayed+) "[d]"))
                  (name (get-faction-type-by-id faction-id)))
          (setf first-no-comma nil)
        finally (return-from nil str)))

(defun get-included-lvl-mods (select-lvl-mods-list)
  (loop with str = (create-string)
        with first-no-comma = t
        for lvl-mod in select-lvl-mods-list
        do
           (format str "~A~A"
                   (if (not first-no-comma)
                     ", "
                     "")
                   (name lvl-mod))
           (setf first-no-comma nil)
        finally (return-from nil str)))

(defmethod make-output ((win custom-scenario-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "CUSTOM SCENARIO" (truncate *window-width* 2) 0 :justify :center)

  (let ((text-str-num)
        (x-title (+ 10 10 (* *glyph-w* 5)))
        (y-title (+ 10 (sdl:char-height sdl:*default-font*))))
    ;; draw the sector image
    (draw-world-map-cell (world-sector win) 10 (+ 10 y-title))
    ;; draw the current scenario info
    (sdl:with-rectangle (rect (sdl:rectangle :x x-title :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* x-title 10) :h (- (truncate *window-height* 2) 20)))
      (setf text-str-num (write-text (format nil "Date&Time: ~A~%Mission: ~A~%Sector: ~A~%Feats: ~A~%Factions: ~A~%Player faction: ~A"
                                             (show-date-time-YMD (world-game-time (world win)))
                                             (name (get-mission-type-by-id (mission-type-id (mission win))))
                                             (name (nth (cur-sector win) (sector-list win)))
                                             (get-included-lvl-mods (select-lvl-mods-list win))
                                             (get-included-faction-str (cur-faction-list win))
                                             (name (get-level-modifier-by-id (second (find (nth (cur-specific-faction win) (specific-faction-list win))
                                                                                           (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                                           :key #'(lambda (a) (first a))))))
                                             )
                                     rect)))
      
    ;; draw the steps of scenario customization
    (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*) (color-4 sdl:*white*) (color-5 sdl:*white*) (color-6 sdl:*white*))
      (case (cur-step win)
        (:custom-scenario-tab-missions (setf color-1 sdl:*yellow*))
        (:custom-scenario-tab-sectors (setf color-2 sdl:*yellow*))
        (:custom-scenario-tab-months (setf color-3 sdl:*yellow*))
        (:custom-scenario-tab-feats (setf color-4 sdl:*yellow*))
        (:custom-scenario-tab-factions (setf color-5 sdl:*yellow*))
        (:custom-scenario-tab-specific-factions (setf color-6 sdl:*yellow*)))

      (sdl:draw-string-solid-* (format nil "1. Mission") 10 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :left :color color-1)
      (sdl:draw-string-solid-* (format nil "2. Sector") (* 4 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :left :color color-2)
      (sdl:draw-string-solid-* (format nil "3. Month") (* 8 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-3)
      (sdl:draw-string-solid-* (format nil "4. Feats") (* 11 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-4)
      (sdl:draw-string-solid-* (format nil "5. Factions") (* 14 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-5)
      (sdl:draw-string-solid-* (format nil "6. Player faction") (- *window-width* 10) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :right :color color-6))
    
    ;; draw the selection for each step
    (let ((cur-str) (color-list nil))
      (setf cur-str (cur-sel win))
      (dotimes (i (length (menu-items win)))
        (case (cur-step win)
          (:custom-scenario-tab-feats (progn
                                        (cond
                                          ((and (= i cur-str) (find (nth i (overall-lvl-mods-list win)) (always-lvl-mods-list win))) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 0)))))
                                          ((and (= i cur-str) (not (find (nth i (overall-lvl-mods-list win)) (always-lvl-mods-list win)))) (setf color-list (append color-list (list sdl:*yellow*))))
                                          ((and (/= i cur-str) (find (nth i (overall-lvl-mods-list win)) (always-lvl-mods-list win))) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 150)))))
                                          ((and (/= i cur-str) (not (find (nth i (overall-lvl-mods-list win)) (always-lvl-mods-list win)))) (setf color-list (append color-list (list sdl:*white*)))))))
          (t (if (= i cur-str) 
               (setf color-list (append color-list (list sdl:*yellow*)))
               (setf color-list (append color-list (list sdl:*white*)))))))
      (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 4 text-str-num))) :color-list color-list))
    )
    
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* 10 (* 2 (sdl:char-height sdl:*default-font*))) :w (- *window-width* 20) :h (* 2 (sdl:char-height sdl:*default-font*))))
      (let ((str (create-string)))
        (case (cur-step win)
          (:custom-scenario-tab-missions (format str "[Enter/Right] Select  [Up/Down] Move selection  [Esc] Exit"))
          (:custom-scenario-tab-specific-factions (format str "[Enter] Start game  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
          (:custom-scenario-tab-factions (progn
                                           (let* ((cur-faction (first (nth (cur-faction win) (cur-faction-list win))))
                                                  (faction-present (second (nth (cur-faction win) (cur-faction-list win))))
                                                  (ref-faction-obj (find cur-faction
                                                                         (ref-faction-list win) :key #'(lambda (a)
                                                                                                         (first a))))
                                                  (ref-faction-present-pos (position faction-present (second ref-faction-obj)))
                                                  (next-faction-present (if (>= (1+ ref-faction-present-pos) (length (second ref-faction-obj)))
                                                                          (first (second ref-faction-obj))
                                                                          (nth (1+ ref-faction-present-pos) (second ref-faction-obj)))))
                                             (cond
                                               ((= next-faction-present +mission-faction-present+) (format str "[Space] Include as present faction  "))
                                               ((= next-faction-present +mission-faction-delayed+) (format str "[Space] Include as delayed faction  "))
                                               ((= next-faction-present +mission-faction-absent+) (format str "[Space] Exclude the faction  "))))
                                           (format str "[Right] Next step  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")
                                           ))
          (:custom-scenario-tab-feats (progn
                                        (when (not (find (nth (cur-sel win) (overall-lvl-mods-list win)) (always-lvl-mods-list win)))
                                          (if (find (nth (cur-sel win) (overall-lvl-mods-list win)) (select-lvl-mods-list win))
                                            (format str "[Space] Remove feat  ")
                                            (format str "[Space] Add feat  ")))
                                        (format str "[Right] Next step  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")
                                        ))
          (t (format str "[Enter/Right] Select  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
        )
        (write-text str rect)))
  
  (sdl:update-display))

(defmethod run-window ((win custom-scenario-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)

                     (cond
                       ((sdl:key= key :sdl-key-left)
                        (progn
                          (when (defenum:previous-enum-tag 'custom-scenario-window-tab-type (cur-step win))
                            (setf (cur-step win) (defenum:previous-enum-tag 'custom-scenario-window-tab-type (cur-step win))))
                          
                          (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))))
                       
                       ((sdl:key= key :sdl-key-right)
                        (progn
                          (when (defenum:next-enum-tag 'custom-scenario-window-tab-type (cur-step win))
                            (setf (cur-step win) (defenum:next-enum-tag 'custom-scenario-window-tab-type (cur-step win))))
                          
                          (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))))
                       
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape)
                        (setf *current-window* (return-to win))
                        (return-from run-window (values nil nil nil nil)))

                       ;; Space - add/remove feat inside feats tab
                       ((and (sdl:key= key :sdl-key-space)
                             (eq (cur-step win) :custom-scenario-tab-feats))
                        (progn
                          (let ((lvl-mod (nth (cur-sel win) (overall-lvl-mods-list win))))
                            (when (not (find lvl-mod (always-lvl-mods-list win)))
                              ;; make a radio button for the controlled-by lvl mods
                              (when (= (lm-type lvl-mod) +level-mod-controlled-by+)
                                (add/remove-lvl-mod win lvl-mod))
                              
                              ;; make checkboxes for the feats lvl mods
                              (when (= (lm-type lvl-mod) +level-mod-sector-feat+)
                                (if (find lvl-mod (select-feats-list win))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general nil))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general t))))
                              
                              ;; make checkboxes for the items lvl mods
                              (when (= (lm-type lvl-mod) +level-mod-sector-item+)
                                (if (find lvl-mod (select-items-list win))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general nil))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general t))))
                              
                              ;; make a radio button for the time of day lvl mods
                              (when (= (lm-type lvl-mod) +level-mod-time-of-day+)
                                (add/remove-lvl-mod win lvl-mod))
                              
                              ;; make checkboxes for the weather lvl mods
                              (when (= (lm-type lvl-mod) +level-mod-weather+)
                                (if (find lvl-mod (select-weather-list win))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general nil))
                                  (progn
                                    (add/remove-lvl-mod win lvl-mod :add-general t))))
                              
                              (generate-feats-for-world-sector (world-sector win) (world-map (world win)))
                              (readd-lvl-mods-after-sector-regeneration win)
                              
                              (setf (select-lvl-mods-list win) (stable-sort (select-lvl-mods-list win) #'(lambda (a b)
                                                                                                           (if (< (lm-type a) (lm-type b))
                                                                                                             t
                                                                                                             nil))))
                              
                              (readjust-factions-after-feats-change win)
                              
                              (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))))))
                       
                       ;; Space - include/exclude faction as a defender
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-defender+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-defender+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+)
                          (when (find-if #'(lambda (a)
                                             (if (and (= (second a) +mission-faction-absent+)
                                                      (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                               t
                                               nil))
                                         (ref-faction-list win))
                            (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+)))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; d - include/exclude faction as a delayed defender
                       ((and (sdl:key= key :sdl-key-d)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-delayed+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-delayed+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+)
                          (when (find-if #'(lambda (a)
                                             (if (and (= (second a) +mission-faction-absent+)
                                                      (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                               t
                                               nil))
                                         (ref-faction-list win))
                            (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+)))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; Space - include/exclude faction as an attacker
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-attacker+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-attacker+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+)
                          (when (find-if #'(lambda (a)
                                             (if (and (= (second a) +mission-faction-absent+)
                                                      (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                               t
                                               nil))
                                         (ref-faction-list win))
                            (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+)))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; space - include/exclude faction as present
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-present+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-present+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (not (find-if #'(lambda (a)
                                               (if (and (= (second a) +mission-faction-defender+)
                                                        (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                 t
                                                 nil))
                                           (ref-faction-list win)))
                             (not (find-if #'(lambda (a)
                                               (if (and (= (second a) +mission-faction-attacker+)
                                                        (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                 t
                                                 nil))
                                           (ref-faction-list win))))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )
                       
                       ;; enter - select
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        (if (not (eq (cur-step win) :custom-scenario-tab-specific-factions))
                          (progn
                            (setf (cur-step win) (defenum:next-enum-tag 'custom-scenario-window-tab-type (cur-step win)))

                            (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                          (progn
                            (setf (player-lvl-mod-placement-id (mission win)) (second (find (nth (cur-specific-faction win) (specific-faction-list win)) (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                                            :key #'(lambda (a) (first a)))))
                            (return-from run-window (values (world-sector win) (mission win)
                                                            ))))
                        (if (< (cur-step win) +custom-scenario-win-specific-faction+)
                          (progn
                            (incf (cur-step win))
                            (when (> (cur-step win) +custom-scenario-win-specific-faction+)
                              (setf (cur-step win) +custom-scenario-win-specific-faction+))
                            (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                          (progn
                            (setf (player-lvl-mod-placement-id (mission win)) (second (find (nth (cur-specific-faction win) (specific-faction-list win)) (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                                            :key #'(lambda (a) (first a)))))
                            (return-from run-window (values (world-sector win) (mission win)
                                                            )))))
                       )

                     (case (cur-step win)
                       (:custom-scenario-tab-missions (progn (let ((prev-cur-sel (cur-mission-type win)))
                                                               (setf (cur-mission-type win) (run-selection-list key mod unicode (cur-mission-type win)))
                                                               (setf (cur-mission-type win) (adjust-selection-list (cur-mission-type win) (length (mission-type-list win))))
                                                               (setf (cur-sel win) (cur-mission-type win))
                                                               
                                                               (when (/= prev-cur-sel (cur-sel win))
                                                                 (adjust-mission-after-change win)))))
                       (:custom-scenario-tab-sectors (progn (let ((prev-cur-sel (cur-sector win)))
                                                              (setf (cur-sector win) (run-selection-list key mod unicode (cur-sector win)))
                                                              (setf (cur-sector win) (adjust-selection-list (cur-sector win) (length (sector-list win))))
                                                              (setf (cur-sel win) (cur-sector win))

                                                              (when (/= prev-cur-sel (cur-sel win))
                                                                (adjust-world-sector-after-change win)))))
                       (:custom-scenario-tab-months (progn (let ((prev-cur-sel (cur-month win)))
                                                             (setf (cur-month win) (run-selection-list key mod unicode (cur-month win)))
                                                             (setf (cur-month win) (adjust-selection-list (cur-month win) (length (months-list win))))
                                                             (setf (cur-sel win) (cur-month win))

                                                              (when (/= prev-cur-sel (cur-sel win))
                                                                (adjust-months-before-feats win)))))
                       (:custom-scenario-tab-feats (progn (setf (cur-feat win) (run-selection-list key mod unicode (cur-feat win)))
                                                          (setf (cur-feat win) (adjust-selection-list (cur-feat win) (length (overall-lvl-mods-list win))))
                                                          (setf (cur-sel win) (cur-feat win))
                                                          ))
                       (:custom-scenario-tab-factions (progn (setf (cur-faction win) (run-selection-list key mod unicode (cur-faction win)))
                                                             (setf (cur-faction win) (adjust-selection-list (cur-faction win) (length (cur-faction-list win))))
                                                             (setf (cur-sel win) (cur-faction win))
                                                             ))
                       (:custom-scenario-tab-specific-factions (progn (setf (cur-specific-faction win) (run-selection-list key mod unicode (cur-specific-faction win)))
                                                                      (setf (cur-specific-faction win) (adjust-selection-list (cur-specific-faction win)
                                                                                                                              (length (specific-faction-list win))))
                                                                      (setf (cur-sel win) (cur-specific-faction win)))))
                     
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
