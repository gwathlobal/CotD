(in-package :cotd)

(defun find-random-scenario-options (specific-faction-type &key (avail-mission-type-list nil) (avail-world-sector-type-list nil) (avail-lvl-mods-list nil) )
  (let ((available-faction-list ())
        (available-variants-list ())
        )

    ;; find all factions that have the required specific faction
    (setf available-faction-list (loop for faction-type across *faction-types*
                                       when (and faction-type
                                                 (find specific-faction-type (specific-faction-list faction-type)))
                                         collect (id faction-type)))

    (when (null available-faction-list)
      (return-from find-random-scenario-options (generate-random-scenario nil nil +mission-faction-present+ specific-faction-type
                                                                          :avail-mission-type-list avail-mission-type-list
                                                                          :avail-world-sector-type-list nil
                                                                          :avail-lvl-mods-list avail-lvl-mods-list)))

    ;; if available lvl-mods are not supplied, take all of them
    (when (not avail-lvl-mods-list)
      (setf avail-lvl-mods-list (get-all-lvl-mods-list)))

    ;; if available mission-types are not supplied, take all of them
    (when (not avail-mission-type-list)
      (setf avail-mission-type-list (get-all-mission-types-list))
      (setf avail-mission-type-list (list (get-mission-type-by-id +mission-type-demonic-attack+)
                                          (get-mission-type-by-id +mission-type-demonic-raid+)
                                          (get-mission-type-by-id +mission-type-military-conquest+))))
    
    ;; if available sector types are not supplied, find all possible sectors in game
    (when (not avail-world-sector-type-list)
      (setf avail-world-sector-type-list (get-all-world-sector-types-list)))
    
    ;; find all lvl mods that produce the required faction & are available for mission & world-sector
    (loop for lvl-mod in avail-lvl-mods-list
          when (faction-list-func lvl-mod) do
            (loop for world-sector-type in avail-world-sector-type-list do
              (loop with result-1 = nil
                    for (faction-type-id faction-present) in (funcall (faction-list-func lvl-mod) (wtype world-sector-type))
                    when (= faction-present +mission-faction-present+) do
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
                  when (= faction-present +mission-faction-present+) do
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
                           when (= faction-present +mission-faction-present+) do
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
        (return-from find-random-scenario-options (generate-random-scenario (first lvl-mod-obj) (nth (random (length available-faction-list)) available-faction-list) +mission-faction-present+ specific-faction-type
                                                                            :avail-mission-type-list (list (third lvl-mod-obj))
                                                                            :avail-world-sector-type-list (list (second lvl-mod-obj))
                                                                            :avail-lvl-mods-list avail-lvl-mods-list)))
   
      )))

(defun generate-random-scenario (req-lvl-mod req-faction-id req-faction-present specific-faction-type &key (avail-mission-type-list nil) (avail-world-sector-type-list nil) (avail-lvl-mods-list nil))
  (let ((world nil)
        (test-world-map (make-instance 'world-map))
        (mission nil)
        (world-sector nil)
        
        (lvl-mod-controlled-by-set nil)
        (lvl-mod-feats-set nil)
        (lvl-mod-items-set nil)
        (lvl-mod-tod-set nil)
        (lvl-mod-weather-set nil)

        (avail-controlled-list ())
        (avail-feats-list ())
        (avail-items-list ())
        (avail-tod-list ())
        (avail-weather-list ())

        (select-lvl-mods-list ()))
    
    (flet ((add/remove-lvl-mod (lvl-mod &key (add-to-sector t))
             (cond
               ((= (lm-type lvl-mod) +level-mod-controlled-by+) (progn
                                                                      (setf lvl-mod-controlled-by-set t)
                                                                      (let ((prev-lvl-mod (get-level-modifier-by-id (controlled-by world-sector))))
                                                                        ;; remove previous controlled-by from sector
                                                                        (when (and prev-lvl-mod
                                                                                   (scenario-disabled-func prev-lvl-mod))
                                                                          (funcall (scenario-disabled-func prev-lvl-mod) (world-map world) (x world-sector) (y world-sector)))
                                                                        
                                                                        ;; set new controlled-by in window
                                                                        (setf select-lvl-mods-list (remove prev-lvl-mod select-lvl-mods-list))
                                                                        (pushnew lvl-mod select-lvl-mods-list)
                                                                        
                                                                        ;; add new controlled-by to sector
                                                                        (when add-to-sector
                                                                          (setf (controlled-by world-sector) (id lvl-mod)))
                                                                        (when (scenario-enabled-func lvl-mod)
                                                                          (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))
               ((= (lm-type lvl-mod) +level-mod-sector-feat+) (progn
                                                                    (setf lvl-mod-feats-set t)
                                                                    ;; do not add if already added
                                                                    (when (not (find lvl-mod select-lvl-mods-list))
                                                                      (push lvl-mod select-lvl-mods-list)
                                                                      
                                                                      (when add-to-sector
                                                                        (push (list (id lvl-mod) nil) (feats world-sector)))
                                                                      (when (scenario-enabled-func lvl-mod)
                                                                        (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))
               ((= (lm-type lvl-mod) +level-mod-sector-item+) (progn
                                                                    (setf lvl-mod-items-set t)
                                                                    ;; do not add if already added
                                                                    (when (not (find lvl-mod select-lvl-mods-list))
                                                                      (push lvl-mod select-lvl-mods-list)
                                                                                                                                            
                                                                      (when add-to-sector
                                                                        (push (id lvl-mod) (items world-sector)))
                                                                      (when (scenario-enabled-func lvl-mod)
                                                                        (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))
               ((= (lm-type lvl-mod) +level-mod-time-of-day+) (progn
                                                                    (setf lvl-mod-tod-set t)
                                                                    (let ((prev-lvl-mod (find +level-mod-time-of-day+ (level-modifier-list mission)
                                                                                              :key #'(lambda (a)
                                                                                                       (lm-type (get-level-modifier-by-id a))))))
                                                                      ;; remove previous tod from sector
                                                                      (when (and prev-lvl-mod
                                                                                 (scenario-disabled-func prev-lvl-mod))
                                                                        (funcall (scenario-disabled-func prev-lvl-mod) (world-map world) (x world-sector) (y world-sector))
                                                                        (remove (id prev-lvl-mod) (level-modifier-list mission)))
                                                                      
                                                                      ;; set new tod in window
                                                                      (setf select-lvl-mods-list (remove prev-lvl-mod select-lvl-mods-list))
                                                                      (pushnew lvl-mod select-lvl-mods-list)
                                                                      
                                                                      ;; add new to to sector
                                                                      (when add-to-sector
                                                                        (push (id lvl-mod) (level-modifier-list mission)))
                                                                      (when (scenario-enabled-func lvl-mod)
                                                                        (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector))))))
               ((= (lm-type lvl-mod) +level-mod-weather+) (progn
                                                                (setf lvl-mod-weather-set t)
                                                                ;; do not add if already added
                                                                (when (not (find lvl-mod select-lvl-mods-list))
                                                                  (push lvl-mod select-lvl-mods-list)
                                                                  
                                                                  (when add-to-sector
                                                                    (push (id lvl-mod) (level-modifier-list mission)))
                                                                  (when (scenario-enabled-func lvl-mod)
                                                                    (funcall (scenario-enabled-func lvl-mod) (world-map world) (x world-sector) (y world-sector)))))))))

      (when (not avail-lvl-mods-list)
        (setf avail-lvl-mods-list (get-all-lvl-mods-list)))
      
      ;; create the supporting world
      (setf world (make-instance 'world))
      (setf *world* world)
      (generate-empty-world-map test-world-map (world-game-time world))
      (loop for lm-controlled-id in (list +lm-controlled-by-demons+ +lm-controlled-by-military+) do
        (loop for x = (random *max-x-world-map*)
              for y = (random *max-y-world-map*)
              while (or (and (<= x 2)
                             (<= y 2))
                        (/= (controlled-by (aref (cells test-world-map) x y)) +lm-controlled-by-none+))
              finally
                 (setf (controlled-by (aref (cells test-world-map) x y)) lm-controlled-id)))
      
      (setf (world-map world) test-world-map)
      (setf (world-game-time world) (set-current-date-time 1915
                                                           (random 12)
                                                           (random 30)
                                                           0 0 0))

      ;; find a random mission from the list,
      ;; if no specific mission list is supplied, select from all enabled missions
      (when (null avail-mission-type-list)
        (setf avail-mission-type-list (get-all-mission-types-list))
        (setf avail-mission-type-list (list (get-mission-type-by-id +mission-type-demonic-attack+)
                                            (get-mission-type-by-id +mission-type-demonic-raid+)
                                            (get-mission-type-by-id +mission-type-military-conquest+))))
      
      ;; create the mission
      (setf mission (make-instance 'mission :mission-type-id (id (nth (random (length avail-mission-type-list)) avail-mission-type-list))
                                            :x 1 :y 1
                                            :faction-list ()
                                            :level-modifier-list ()))
      
      ;; select a random world sector available for the mission, if none already selected
      (when (null avail-world-sector-type-list)
        (setf avail-world-sector-type-list (loop for world-sector-id in (world-sector-for-custom-scenario (get-mission-type-by-id (mission-type-id mission)))
                                                 collect (get-world-sector-type-by-id world-sector-id))))
            
      ;; make necessary adjustments for the selected world-sector
      (loop for x from 0 to 2 do
        (loop for y from 0 to 2 do
          (setf (aref (cells (world-map world)) x y) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x x :y y))))
      
      (setf world-sector (make-instance 'world-sector :wtype (wtype (nth (random (length avail-world-sector-type-list)) avail-world-sector-type-list))
                                                      :x 1 :y 1))
      (setf (aref (cells (world-map world)) 1 1) world-sector)
      (setf (mission world-sector) mission)
      
      (when (scenario-enabled-func (get-world-sector-type-by-id (wtype world-sector)))
        (funcall (scenario-enabled-func (get-world-sector-type-by-id (wtype world-sector))) (world-map world) (x world-sector) (y world-sector)))
      
      (when req-lvl-mod
        (add/remove-lvl-mod req-lvl-mod))

      ;; if controlled-by is not already set, find and set a random controlled-by lvl-mod
      (when (not lvl-mod-controlled-by-set)
        (setf avail-controlled-list (loop for lvl-mod in avail-lvl-mods-list
                                          when (and (= (lm-type lvl-mod) +level-mod-controlled-by+)
                                                    (is-available-for-mission lvl-mod)
                                                    (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
                                            collect lvl-mod))
        (add/remove-lvl-mod (nth (random (length avail-controlled-list)) avail-controlled-list)))
      
      ;; add random feats lvl-mods, except req-lvl-mod
      (setf avail-feats-list (loop for lvl-mod in avail-lvl-mods-list
                                   when (and (= (lm-type lvl-mod) +level-mod-sector-feat+)
                                             (is-available-for-mission lvl-mod)
                                             (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
                                     collect lvl-mod))
      (when lvl-mod-feats-set
        (setf avail-feats-list (remove req-lvl-mod avail-feats-list)))
      (loop for lvl-mod in avail-feats-list
            when (zerop (random 4)) do
              (add/remove-lvl-mod lvl-mod))
      
      ;; add random items lvl-mods, except req-lvl-mod
      (setf avail-items-list (loop for lvl-mod in avail-lvl-mods-list
                                   when (and (= (lm-type lvl-mod) +level-mod-sector-item+)
                                             (is-available-for-mission lvl-mod)
                                             (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
                                     collect lvl-mod))
      (when lvl-mod-items-set
        (setf avail-items-list (remove req-lvl-mod avail-items-list)))
      (loop for lvl-mod in avail-items-list
            when (zerop (random 4)) do
              (add/remove-lvl-mod lvl-mod))

      (generate-feats-for-world-sector world-sector (world-map world))
  
      ;; if tod is not already set, find and set a random time-of-day lvl-mod
      (when (not lvl-mod-tod-set)
        (setf avail-tod-list (loop for lvl-mod in avail-lvl-mods-list
                                   when (and (= (lm-type lvl-mod) +level-mod-time-of-day+)
                                             (is-available-for-mission lvl-mod)
                                             (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
                                     collect lvl-mod))
        (add/remove-lvl-mod (nth (random (length avail-tod-list)) avail-tod-list)))
    
      ;; add random weather lvl-mods, except req-lvl-mod
      (setf avail-weather-list (loop for lvl-mod in avail-lvl-mods-list
                                     when (and (= (lm-type lvl-mod) +level-mod-weather+)
                                               (is-available-for-mission lvl-mod)
                                               (funcall (is-available-for-mission lvl-mod) (wtype world-sector) (mission-type-id mission) (world-game-time world)))
                                       collect lvl-mod))
      (when lvl-mod-weather-set
        (setf avail-weather-list (remove req-lvl-mod avail-weather-list)))
      (loop for lvl-mod in avail-weather-list
            when (zerop (random 4)) do
              (add/remove-lvl-mod lvl-mod))
      
      ;; if there are lvl mods in world sector that are not added properly, add them (duplicates are handled inside add/remove-lvl-mod)
      (loop for (lvl-mod-id aux) in (feats world-sector)
            for lvl-mod = (get-level-modifier-by-id lvl-mod-id)
            do
               (add/remove-lvl-mod lvl-mod :add-to-sector nil))
      
      ;; add feats from always present lvl mods from the world sector
      (loop for lvl-mod-id in (funcall (always-lvl-mods-func (get-world-sector-type-by-id (wtype world-sector))) world-sector (mission-type-id mission) (world-game-time world)) do
        (add/remove-lvl-mod (get-level-modifier-by-id lvl-mod-id)))
      
      ;; go through all (select-lvl-mods-list win) and add all lvl-mods they depend on
      (loop for lvl-mod in select-lvl-mods-list
            for depend-lvl-mod-list = (funcall (depends-on-lvl-mod-func lvl-mod) world-sector (mission-type-id mission) (world-game-time world))
            when depend-lvl-mod-list do
              (loop for depend-lvl-mod-id in depend-lvl-mod-list
                    for depend-lvl-mod = (get-level-modifier-by-id depend-lvl-mod-id)
                    do
                       (add/remove-lvl-mod depend-lvl-mod)))

      ;; find all general factions
      (loop with sector-factions = (if (faction-list-func (get-world-sector-type-by-id (wtype world-sector)))
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
            with ref-faction-list = ()
            for (faction-id faction-present) in overall-factions
            for faction-obj = (find faction-id ref-faction-list :key #'(lambda (a) (first a)))
            do
               (if faction-obj
                 (progn
                   (when (not (find faction-present (second faction-obj)))
                     (push faction-present (second faction-obj))))
                 (progn
                   (push (list faction-id (list faction-present)) ref-faction-list)))
            finally
               (loop with cur-faction-list = ()
                     for (faction-id faction-present-list) in ref-faction-list
                     do
                        (if (and req-faction-id (= faction-id req-faction-id))
                          (push (list faction-id req-faction-present) cur-faction-list)
                          (push (list faction-id (nth (random (length faction-present-list)) faction-present-list))
                              cur-faction-list))
                     finally (setf (faction-list mission) cur-faction-list)))

      (setf (player-lvl-mod-placement-id mission) (second (find specific-faction-type (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                                :key #'(lambda (a) (first a)))))

      (return-from generate-random-scenario (values mission world-sector))
      )))
