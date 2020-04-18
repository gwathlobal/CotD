(in-package :cotd)

(defconstant +custom-scenario-win-mission+ 0)
(defconstant +custom-scenario-win-layout+ 1)
(defconstant +custom-scenario-win-weather+ 2)
(defconstant +custom-scenario-win-time-of-day+ 3)
(defconstant +custom-scenario-win-factions+ 4)
(defconstant +custom-scenario-win-specific-faction+ 5)

(defenum:defenum custom-scenario-window-tab-type (:custom-scenario-tab-mission
                                                  :custom-scenario-tab-sectors
                                                  :custom-scenario-tab-feats
                                                  :custom-scenario-tab-factions
                                                  :custom-scenario-tab-specific-factions))

(defclass custom-scenario-window (window)
  ((cur-step :initform :custom-scenario-tab-mission :accessor cur-step)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :accessor menu-items)

   (world :initarg :world :accessor world :type world)
   
   (world-sector :accessor world-sector)
   (mission :accessor mission)
      
   (mission-type-list :initform () :accessor mission-type-list)
   (cur-mission-type :initform 0 :accessor cur-mission-type)

   (sector-list :initform () :accessor sector-list)
   (cur-sector :initform 0 :accessor cur-sector)

   (overall-lvl-mods-list :accessor overall-lvl-mods-list)
   (select-lvl-mods-list :accessor select-lvl-mods-list)
   (avail-controlled-list :accessor avail-controlled-list)
   (select-controlled-mod :accessor select-controlled-mod)
   (avail-feats-list :accessor avail-feats-list)
   (select-feats-list :accessor select-feats-list)
   (avail-items-list :accessor avail-items-list)
   (select-items-list :accessor select-items-list)
   (avail-tod-list :accessor avail-tod-list)
   (select-tod-mod :accessor select-tod-mod)
   (avail-weather-list :accessor avail-weather-list)
   (select-weather-list :accessor select-weather-list)
   (cur-feat :accessor cur-feat)

   (ref-faction-list :initform () :accessor ref-faction-list)
   (cur-faction-list :initform () :accessor cur-faction-list)
   (cur-faction :accessor cur-faction)
   
   (specific-faction-list :initform () :accessor specific-faction-list)
   (cur-specific-faction :initform 0 :accessor cur-specific-faction)
   ))

(defmethod initialize-instance :after ((win custom-scenario-window) &key)

  (setf *current-window* win)
  
  (setf (world-game-time (world win)) (set-current-date-time 1915
                                                             (random 12)
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

  (setf (mission win) (make-instance 'mission :mission-type-id (id (nth (cur-mission-type win) (mission-type-list win)))
                                              :x 1 :y 1
                                              :faction-list ()
                                              :level-modifier-list ()))

  (readjust-sectors-after-mission-change win)

  
  
  (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
  
  )

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
        
    (setf (world-sector win) (make-instance 'world-sector :wtype (wtype (nth (cur-sector win) (sector-list win)))
                                                          :x 1 :y 1))

    (when (scenario-enabled-func (get-world-sector-type-by-id (wtype (world-sector win))))
      (funcall (scenario-enabled-func (get-world-sector-type-by-id (wtype (world-sector win)))) (world-map (world win)) (x (world-sector win)) (y (world-sector win)))) 
    
    (readjust-feats-after-layout-change win)))

(defun readjust-feats-after-layout-change (win)
  ;; find all available controlled-by lvl-mods for the selected mission
  (setf (avail-controlled-list win) (loop for lvl-mod across *level-modifiers*
                                          when (= (lm-type lvl-mod) +level-mod-controlled-by+)
                                            collect lvl-mod))
  (setf (select-controlled-mod win) (nth (random (length (avail-controlled-list win))) (avail-controlled-list win)))
  (setf (controlled-by (world-sector win)) (id (select-controlled-mod win)))
  (when (scenario-enabled-func (get-level-modifier-by-id (controlled-by (world-sector win))))
    (funcall (scenario-enabled-func (get-level-modifier-by-id (controlled-by (world-sector win)))) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
  
  ;; find all available feat lvl-mods for the selected mission
  (setf (avail-feats-list win) (loop for lvl-mod across *level-modifiers*
                                          when (= (lm-type lvl-mod) +level-mod-sector-feat+)
                                            collect lvl-mod))
  (setf (select-feats-list win) (loop for lvl-mod in (avail-feats-list win)
                                      when (zerop (random 4))
                                        collect lvl-mod))
  (setf (feats (world-sector win)) (loop for lvl-mod in (select-feats-list win)
                                         collect (list (id lvl-mod) nil)))
  (loop for lvl-mod in (select-feats-list win)
        when (scenario-enabled-func lvl-mod) do
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))

  ;; find all available item lvl-mods for the selected mission
  (setf (avail-items-list win) (loop for lvl-mod across *level-modifiers*
                                          when (= (lm-type lvl-mod) +level-mod-sector-item+)
                                            collect lvl-mod))
  (setf (select-items-list win) (loop for lvl-mod in (avail-items-list win)
                                      when (zerop (random 4))
                                        collect lvl-mod))
  (setf (items (world-sector win)) (loop for lvl-mod in (select-items-list win)
                                         collect (id lvl-mod)))
  (loop for lvl-mod in (select-items-list win)
        when (scenario-enabled-func lvl-mod) do
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))

  ;; find all available time of day lvl-mods for the selected mission
  (setf (avail-tod-list win) (loop for lvl-mod across *level-modifiers*
                                          when (= (lm-type lvl-mod) +level-mod-time-of-day+)
                                            collect lvl-mod))
  (setf (select-tod-mod win) (nth (random (length (avail-tod-list win))) (avail-tod-list win)))
  (when (scenario-enabled-func (select-tod-mod win))
    (funcall (scenario-enabled-func (select-tod-mod win)) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
  
  ;; find all available weather lvl-mods for the selected mission
  (setf (avail-weather-list win) (loop for lvl-mod across *level-modifiers*
                                       when (and (= (lm-type lvl-mod) +level-mod-weather+)
                                                 (is-available-for-mission lvl-mod)
                                                 (funcall (is-available-for-mission lvl-mod) (world-sector win) (cur-mission-type win) (world-game-time (world win))))
                                         collect lvl-mod))
  (setf (select-weather-list win) (loop for lvl-mod in (avail-weather-list win)
                                      when (zerop (random 4))
                                        collect lvl-mod))
  (loop for lvl-mod in (select-weather-list win)
        when (scenario-enabled-func lvl-mod) do
          (funcall (scenario-enabled-func lvl-mod) (world-map (world win)) (x (world-sector win)) (y (world-sector win))))
  
  (generate-feats-for-world-sector (world-sector win) (world-map (world win)))
  
  (setf (overall-lvl-mods-list win) (append (avail-controlled-list win) (avail-feats-list win) (avail-items-list win) (avail-tod-list win) (avail-weather-list win)))
  (setf (select-lvl-mods-list win) (append (list (select-controlled-mod win)) (select-feats-list win) (select-items-list win) (list (select-tod-mod win)) (select-weather-list win)))
  (setf (cur-feat win) (random (length (overall-lvl-mods-list win))))

  (setf (level-modifier-list (mission win)) (append (list (id (select-tod-mod win)))
                                                    (loop for lvl-mod in (select-weather-list win)
                                                          collect (id lvl-mod))))

  (readjust-factions-after-layout-change win))

(defun readjust-factions-after-layout-change (win)
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
                                            when (or (= faction-present +mission-faction-attacker+)
                                                     (= faction-present +mission-faction-defender+)
                                                     (= faction-present +mission-faction-present+))
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
    (:custom-scenario-tab-mission (return-from populate-custom-scenario-win-menu
                                    (loop for mission-type in (mission-type-list win)
                                          when (enabled mission-type)
                                            collect (name mission-type))))
    (:custom-scenario-tab-sectors (return-from populate-custom-scenario-win-menu
                                    (loop for world-sector-type in (sector-list win)
                                          collect (name world-sector-type))))
    (:custom-scenario-tab-feats (return-from populate-custom-scenario-win-menu
                                  (loop for lvl-mod in (overall-lvl-mods-list win)
                                        collect (name lvl-mod))))
    (:custom-scenario-tab-factions (return-from populate-custom-scenario-win-menu
                                     (loop for (faction-id faction-present) in (cur-faction-list win)
                                           collect (format nil "~A ~A"
                                                           (cond
                                                             ((= faction-present +mission-faction-present+) "[+]")
                                                             ((= faction-present +mission-faction-attacker+) "[A]")
                                                             ((= faction-present +mission-faction-defender+) "[D]")
                                                             ((= faction-present +mission-faction-delayed+) "[d]")
                                                             (t "[-]"))
                                                           (name (get-faction-type-by-id faction-id))))))
    (:custom-scenario-tab-specific-factions (return-from populate-custom-scenario-win-menu
                                              (loop for specific-faction-type in (specific-faction-list win)
                                                    when (find specific-faction-type (scenario-faction-list (nth (cur-mission-type win) (mission-type-list win)))
                                                               :key #'(lambda (a) (first a)))
                                                      collect (name (get-level-modifier-by-id (second (find specific-faction-type
                                                                                                            (scenario-faction-list (nth (cur-mission-type win) (mission-type-list win)))
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
                    ((= faction-present +mission-faction-attacker+) "[A]")
                    ((= faction-present +mission-faction-defender+) "[D]")
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

  (let ((text-str-num))
    ;; draw the current scenario info
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* 20) :h (- (truncate *window-height* 2) 20)))
      (setf text-str-num (write-text (format nil "Mission: ~A~%Sector: ~A~%Feats: ~A~%Factions: ~A~%Player faction: ~A"
                                             (name (nth (cur-mission-type win) (mission-type-list win)))
                                             (name (nth (cur-sector win) (sector-list win)))
                                             (get-included-lvl-mods (select-lvl-mods-list win))
                                             (get-included-faction-str (cur-faction-list win))
                                             (name (get-level-modifier-by-id (second (find (nth (cur-specific-faction win) (specific-faction-list win))
                                                                                           (scenario-faction-list (get-mission-type-by-id (mission-type-id (mission win))))
                                                                                           :key #'(lambda (a) (first a))))))
                                             )
                                     rect)))
      
    ;; draw the steps of scenario customization
    (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*) (color-4 sdl:*white*) (color-5 sdl:*white*))
      (case (cur-step win)
        (:custom-scenario-tab-mission (setf color-1 sdl:*yellow*))
        (:custom-scenario-tab-sectors (setf color-2 sdl:*yellow*))
        (:custom-scenario-tab-feats (setf color-3 sdl:*yellow*))
        (:custom-scenario-tab-factions (setf color-4 sdl:*yellow*))
        (:custom-scenario-tab-specific-factions (setf color-5 sdl:*yellow*)))
      
      (sdl:draw-string-solid-* (format nil "1. Mission") 10 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :left :color color-1)
      (sdl:draw-string-solid-* (format nil "2. Sector") (* 5 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-2)
      (sdl:draw-string-solid-* (format nil "3. Feats") (* 9 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-3)
      (sdl:draw-string-solid-* (format nil "4. Factions") (* 14 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-4)
      (sdl:draw-string-solid-* (format nil "5. Player faction") (- *window-width* 10) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :right :color color-5))
    
    ;; draw the selection for each step
    (let ((cur-str) (color-list nil))
      (setf cur-str (cur-sel win))
      (dotimes (i (length (menu-items win)))
        (if (= i cur-str) 
          (setf color-list (append color-list (list sdl:*yellow*)))
          (setf color-list (append color-list (list sdl:*white*)))))
      (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 4 text-str-num))) :color-list color-list))
    )
    
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* 10 (* 2 (sdl:char-height sdl:*default-font*))) :w (- *window-width* 20) :h (* 2 (sdl:char-height sdl:*default-font*))))
      (let ((str (create-string)))
        (case (cur-step win)
          (:custom-scenario-tab-mission (format str "[Enter/Right] Select  [Up/Down] Move selection  [Esc] Exit"))
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
                        (if (< (cur-step win) +custom-scenario-win-specific-faction+)
                          (progn
                            (incf (cur-step win))
                            (when (> (cur-step win) +custom-scenario-win-specific-faction+)
                              (setf (cur-step win) +custom-scenario-win-specific-faction+))
                            (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                          (progn
                            (return-from run-window (values (nth (cur-mission-type win) (mission-type-list win))
                                                            (nth (cur-layout win) (layout-list win))
                                                            (nth (cur-weather win) (weather-list win))
                                                            (nth (cur-tod win) (tod-list win))
                                                            (nth (cur-specific-faction win) (specific-faction-list win))
                                                            (cur-faction-list win))))))
                       )

                     (case (cur-step win)
                       (:custom-scenario-tab-mission (progn (setf (cur-mission-type win) (run-selection-list key mod unicode (cur-mission-type win)))
                                                            (setf (cur-mission-type win) (adjust-selection-list (cur-mission-type win) (length (mission-type-list win))))
                                                            (setf (cur-sel win) (cur-mission-type win))
                                                            (readjust-sectors-after-mission-change win)))
                       (:custom-scenario-tab-sectors (progn (setf (cur-sector win) (run-selection-list key mod unicode (cur-sector win)))
                                                            (setf (cur-sector win) (adjust-selection-list (cur-sector win) (length (sector-list win))))
                                                            (setf (cur-sel win) (cur-sector win))
                                                            (readjust-feats-after-layout-change win)))
                       (:custom-scenario-tab-feats (progn (setf (cur-feat win) (run-selection-list key mod unicode (cur-feat win)))
                                                          (setf (cur-feat win) (adjust-selection-list (cur-feat win) (length (overall-lvl-mods-list win))))
                                                          (setf (cur-sel win) (cur-feat win))
                                                          (readjust-factions-after-layout-change win)))
                       (:custom-scenario-tab-factions (progn (setf (cur-faction win) (run-selection-list key mod unicode (cur-faction win)))
                                                             (setf (cur-faction win) (adjust-selection-list (cur-faction win) (length (cur-faction-list win))))
                                                             (setf (cur-sel win) (cur-faction win))
                                                             (readjust-specific-factions-after-faction-change win)))
                       (:custom-scenario-tab-specific-factions (progn (setf (cur-specific-faction win) (run-selection-list key mod unicode (cur-specific-faction win)))
                                                                      (setf (cur-specific-faction win) (adjust-selection-list (cur-specific-faction win)
                                                                                                                              (length (specific-faction-list win))))
                                                                      (setf (cur-sel win) (cur-specific-faction win)))))
                     
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
