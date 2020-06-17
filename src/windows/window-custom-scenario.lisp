(in-package :cotd)

(defenum:defenum custom-scenario-window-tab-type (:custom-scenario-tab-missions
                                                  :custom-scenario-tab-sectors
                                                  :custom-scenario-tab-months
                                                  :custom-scenario-tab-feats
                                                  :custom-scenario-tab-factions
                                                  :custom-scenario-tab-specific-factions))

(defclass custom-scenario-window (window)
  ((cur-step :initform :custom-scenario-tab-missions :accessor custom-scenario-window/cur-step :type custom-scenario-window-tab-type)
   (cur-sel :initform 0 :accessor custom-scenario-window/cur-sel :type fixnum)
   (menu-items :initform () :accessor custom-scenario-window/menu-items :type list)
   
   (scenario :initform (make-instance 'scenario-gen-class) :accessor custom-scenario-window/scenario :type scenario-gen-class)
   (months-list :initform (list "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December") :accessor custom-scenario-window/months-list :type list)
   
   (cur-mission-type :initform 0 :accessor custom-scenario-window/cur-mission-type :type fixnum)
   (cur-sector :initform 0 :accessor custom-scenario-window/cur-sector :type fixnum)
   (cur-month :initform 0 :accessor custom-scenario-window/cur-month :type fixnum)
   (cur-feat :initform 0 :accessor custom-scenario-window/cur-feat :type fixnum)
   (cur-faction :initform 0 :accessor custom-scenario-window/cur-faction :type fixnum)
   (cur-specific-faction :initform 0 :accessor custom-scenario-window/cur-specific-faction :type fixnum)
   ))

(defmethod initialize-instance :after ((win custom-scenario-window) &key)
  (with-slots (scenario cur-mission-type cur-month menu-items cur-sel cur-step) win
    (with-slots (world avail-mission-type-list) scenario
      ;; set up supporting world
      (scenario-create-world scenario)
      (setf *world* world)

      (setf cur-month (random 12))
      (scenario-set-world-date scenario 1915 cur-month (random 30) 0 0 0)
      
      ;; find all available missions
      (scenario-set-avail-mission-types scenario)
      
      (setf cur-mission-type (random (length avail-mission-type-list)))
      
      (adjust-mission-after-change win)
      
      (setf menu-items (populate-custom-scenario-win-menu win cur-step))
      (setf cur-sel cur-mission-type)
  )))

(defun adjust-mission-after-change (win)
  (with-slots (scenario cur-mission-type) win
    (with-slots (avail-mission-type-list) scenario
      ;; create the mission
      (scenario-create-mission scenario (id (nth cur-mission-type avail-mission-type-list)))
      
      (readjust-sectors-after-mission-change win))))

(defun readjust-sectors-after-mission-change (win)
  (with-slots (scenario cur-sector) win
    (with-slots (avail-world-sector-type-list) scenario
      ;; a precaution for the first start before any sectors are added
      (let ((cur-world-sector-type (if avail-world-sector-type-list
                                     (nth cur-sector avail-world-sector-type-list)
                                     nil)))
        
        ;; find all available sectors for the selected mission
        (scenario-set-avail-world-sector-types scenario)
        
        ;; make the selection be the same if there is a world-sector in the new selection
        (if (and cur-world-sector-type
                 (position cur-world-sector-type avail-world-sector-type-list))
          (progn
            (setf cur-sector (position cur-world-sector-type avail-world-sector-type-list)))
          (progn
            (setf cur-sector (random (length avail-world-sector-type-list)))))
        
        (adjust-world-sector-after-change win)))))

(defun adjust-months-before-feats (win)
  (with-slots (scenario cur-month) win
    (with-slots (world) scenario
      (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
        (declare (ignore month))
        (scenario-set-world-date scenario year cur-month day hour min sec))

      (adjust-world-sector-after-change win))))

(defun adjust-world-sector-after-change (win)
  (with-slots (scenario cur-sector) win
    (with-slots (avail-world-sector-type-list) scenario
      ;; create the world sector
      (scenario-create-sector scenario (wtype (nth cur-sector avail-world-sector-type-list)))
      
      (readjust-feats-after-sector-change win))))

(defun readjust-feats-after-sector-change (win)
  (with-slots (scenario cur-feat) win
    (with-slots (world world-sector avail-controlled-list avail-feats-list avail-items-list avail-tod-list avail-weather-list) scenario

      (scenario-set-avail-lvl-mods scenario)

      ;; set a random controlled-by lvl-mod
      (scenario-add/remove-lvl-mod scenario (nth (random (length avail-controlled-list)) avail-controlled-list) :add-general t)

      ;; add random feats lvl-mods
      (loop for lvl-mod in avail-feats-list
            when (zerop (random 4)) do
              (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))
      
      ;; add random items lvl-mods
      (loop for lvl-mod in avail-items-list
        when (zerop (random 4)) do
          (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))
      
      (generate-feats-for-world-sector world-sector (world-map world))

      ;; set a random time-of-day lvl-mod
      (scenario-add/remove-lvl-mod scenario (nth (random (length avail-tod-list)) avail-tod-list) :add-general t)

      ;; add random weather lvl-mods
      (loop for lvl-mod in avail-weather-list
        when (or (not (random-available-for-mission lvl-mod))
                 (funcall (random-available-for-mission lvl-mod)))
          do
          (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))
      
      (setf cur-feat 0)
      (scenario-adjust-lvl-mods-after-sector-regeneration scenario)

      (scenario-sort-select-lvl-mods scenario)
      
      (readjust-factions-after-feats-change win))))

(defun readjust-factions-after-feats-change (win)
  (with-slots (scenario cur-faction) win
    (with-slots (cur-faction-list) scenario
      ;; set up a all general factions
      (scenario-adjust-factions scenario)
      
      (setf cur-faction 0)
      
      (readjust-specific-factions-after-faction-change win))))

(defun readjust-specific-factions-after-faction-change (win)
  (with-slots (scenario cur-specific-faction) win
    (with-slots (specific-faction-list) scenario
      ;; find all specific factions
      (let ((cur-faction-id (if specific-faction-list
                              (nth cur-specific-faction specific-faction-list)
                              nil)))

        (scenario-adjust-specific-factions scenario) 
        
        (if (and cur-faction-id
                 (position cur-faction-id specific-faction-list))
          (progn
            (setf cur-specific-faction (position cur-faction-id specific-faction-list)))
          (progn
            (setf cur-specific-faction (random (length specific-faction-list)))))
        ))))

(defun populate-custom-scenario-win-menu (win step)
  (with-slots (scenario months-list) win
    (with-slots (mission avail-mission-type-list avail-world-sector-type-list overall-lvl-mods-list select-lvl-mods-list cur-faction-list specific-faction-list) scenario
      (case step
        (:custom-scenario-tab-missions (return-from populate-custom-scenario-win-menu
                                         (loop for mission-type in avail-mission-type-list
                                               collect (name mission-type))))
        (:custom-scenario-tab-sectors (return-from populate-custom-scenario-win-menu
                                        (loop for world-sector-type in avail-world-sector-type-list
                                              collect (name world-sector-type))))
        (:custom-scenario-tab-months (return-from populate-custom-scenario-win-menu
                                       (copy-list months-list)))
        (:custom-scenario-tab-feats (return-from populate-custom-scenario-win-menu
                                      (loop for lvl-mod in overall-lvl-mods-list
                                            collect (format nil "~A ~A"
                                                            (if (find lvl-mod select-lvl-mods-list)
                                                              "[+]"
                                                              "   ")
                                                            (name lvl-mod)))))
        (:custom-scenario-tab-factions (return-from populate-custom-scenario-win-menu
                                         (loop for (faction-id faction-present) in cur-faction-list
                                               collect (format nil "~A ~A"
                                                               (case faction-present
                                                                 (:mission-faction-present "[+]")
                                                                 (:mission-faction-delayed "[d]")
                                                                 (t "   "))
                                                               (name (get-faction-type-by-id faction-id))))))
        (:custom-scenario-tab-specific-factions (return-from populate-custom-scenario-win-menu
                                                  (loop for specific-faction-type in specific-faction-list
                                                        when (find specific-faction-type (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                                   :key #'(lambda (a) (first a)))
                                                          collect (name (get-level-modifier-by-id (second (find specific-faction-type
                                                                                                                (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                                                                                :key #'(lambda (a) (first a)))))))
                                                  )))
      )))

(defun get-included-faction-str (win-faction-list)
  (loop with str = (create-string)
        with first-no-comma = t
        for (faction-id faction-present) in win-faction-list
        when (not (eq faction-present :mission-faction-absent)) do
          (format str "~A~A ~A"
                  (if (not first-no-comma)
                    ", "
                    "")
                  (case faction-present
                    (:mission-faction-present "[+]")
                    (:mission-faction-delayed "[d]"))
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
  (with-slots (cur-step cur-sel menu-items scenario cur-sector cur-faction cur-specific-faction) win
    (with-slots (world world-sector mission avail-world-sector-type-list overall-lvl-mods-list always-lvl-mods-list select-lvl-mods-list avail-faction-list cur-faction-list specific-faction-list) scenario
      (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
        (sdl:fill-surface sdl:*black* :template a-rect))
      
      (sdl:draw-string-solid-* "CUSTOM SCENARIO" (truncate *window-width* 2) 0 :justify :center)
      
      (let ((text-str-num)
            (x-title (+ 10 10 (* *glyph-w* 5)))
            (y-title (+ 10 (sdl:char-height sdl:*default-font*))))
        ;; draw the sector image
        (let ((*random-state* (make-random-state (world-map/random-state (world-map world)))))
          (draw-world-map-cell world-sector 10 (+ 10 y-title)))
        ;; draw the current scenario info
        (sdl:with-rectangle (rect (sdl:rectangle :x x-title :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* x-title 10) :h (- (truncate *window-height* 2) 20)))
          (setf text-str-num (write-text (format nil "Date&Time: ~A~%Mission: ~A~%Sector: ~A~%Feats: ~A~%Factions: ~A~%Player faction: ~A"
                                                 (show-date-time-YMD (world-game-time world))
                                                 (name (get-mission-type-by-id (mission-type-id mission)))
                                                 (name (get-world-sector-type-by-id (wtype world-sector)))
                                                 (get-included-lvl-mods select-lvl-mods-list)
                                                 (get-included-faction-str cur-faction-list)
                                                 (name (get-level-modifier-by-id (second (find (nth cur-specific-faction specific-faction-list)
                                                                                               (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                                                               :key #'(lambda (a) (first a))))))
                                                 )
                                         rect)))
        
        ;; draw the steps of scenario customization
        (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*) (color-4 sdl:*white*) (color-5 sdl:*white*) (color-6 sdl:*white*))
          (case cur-step
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
        (let ((color-list nil))
          (dotimes (i (length menu-items))
            (case cur-step
              (:custom-scenario-tab-feats (progn
                                            (cond
                                              ((and (= i cur-sel) (find (nth i overall-lvl-mods-list) always-lvl-mods-list)) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 0)))))
                                              ((and (= i cur-sel) (not (find (nth i overall-lvl-mods-list) always-lvl-mods-list))) (setf color-list (append color-list (list sdl:*yellow*))))
                                              ((and (/= i cur-sel) (find (nth i overall-lvl-mods-list) always-lvl-mods-list)) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 150)))))
                                              ((and (/= i cur-sel) (not (find (nth i overall-lvl-mods-list) always-lvl-mods-list))) (setf color-list (append color-list (list sdl:*white*)))))))
              (:custom-scenario-tab-factions (progn
                                               (let* ((current-faction (first (nth i cur-faction-list)))
                                                      (ref-faction-obj (find current-faction
                                                                             avail-faction-list :key #'(lambda (a)
                                                                                                             (first a))))
                                                      (more-than-one (if (> (length (second ref-faction-obj)) 1)
                                                                       t
                                                                       nil)))
                                                 (cond
                                                   ((and (= i cur-sel) (not more-than-one)) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 0)))))
                                                   ((and (= i cur-sel) more-than-one) (setf color-list (append color-list (list sdl:*yellow*))))
                                                   ((and (/= i cur-sel) (not more-than-one)) (setf color-list (append color-list (list (sdl:color :r 150 :g 150 :b 150)))))
                                                   ((and (/= i cur-sel) more-than-one) (setf color-list (append color-list (list sdl:*white*))))))))
              (t (if (= i cur-sel) 
                   (setf color-list (append color-list (list sdl:*yellow*)))
                   (setf color-list (append color-list (list sdl:*white*)))))))
          (draw-selection-list menu-items cur-sel (length menu-items) 20 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 4 text-str-num))) :color-list color-list))
        )
      
      (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* 10 (* 2 (sdl:char-height sdl:*default-font*))) :w (- *window-width* 20) :h (* 2 (sdl:char-height sdl:*default-font*))))
        (let ((str (create-string)))
          (case cur-step
            (:custom-scenario-tab-missions (format str "[Enter/Right] Select  [Up/Down] Move selection  [Esc] Exit"))
            (:custom-scenario-tab-specific-factions (format str "[Enter] Start game  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
            (:custom-scenario-tab-factions (progn
                                             (let* ((current-faction (first (nth cur-faction cur-faction-list)))
                                                    (faction-present (second (nth cur-faction cur-faction-list)))
                                                    (ref-faction-obj (find current-faction
                                                                           avail-faction-list :key #'(lambda (a)
                                                                                                       (first a))))
                                                    (ref-faction-present-pos (position faction-present (second ref-faction-obj)))
                                                    (next-faction-present (if (>= (1+ ref-faction-present-pos) (length (second ref-faction-obj)))
                                                                            (first (second ref-faction-obj))
                                                                            (nth (1+ ref-faction-present-pos) (second ref-faction-obj)))))
                                               (cond
                                                 ((<= (length (second ref-faction-obj)) 1) nil)
                                                 ((eq next-faction-present :mission-faction-present) (format str "[Space] Include as present faction  "))
                                                 ((eq next-faction-present :mission-faction-delayed) (format str "[Space] Include as delayed faction  "))
                                                 ((eq next-faction-present :mission-faction-absent) (format str "[Space] Exclude the faction  "))))
                                             (format str "[Right] Next step  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")
                                             ))
            (:custom-scenario-tab-feats (progn
                                          (when (not (find (nth cur-sel overall-lvl-mods-list) always-lvl-mods-list))
                                            (if (find (nth cur-sel overall-lvl-mods-list) select-lvl-mods-list)
                                              (format str "[Space] Remove feat  ")
                                              (format str "[Space] Add feat  ")))
                                          (format str "[Right] Next step  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")
                                          ))
            (t (format str "[Enter/Right] Select  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
            )
          (write-text str rect)))
      
      (sdl:update-display))))

(defmethod run-window ((win custom-scenario-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (with-slots (cur-step cur-sel menu-items scenario months-list cur-mission-type cur-sector cur-month cur-feat cur-faction cur-specific-faction) win
                       (with-slots (world world-sector mission
                                    avail-mission-type-list avail-world-sector-type-list
                                    overall-lvl-mods-list always-lvl-mods-list select-feats-list select-items-list select-weather-list
                                    avail-faction-list cur-faction-list specific-faction-list)
                           scenario
                         (cond
                           ((sdl:key= key :sdl-key-left)
                            (progn
                              (when (defenum:previous-enum-tag 'custom-scenario-window-tab-type cur-step)
                                (setf cur-step (defenum:previous-enum-tag 'custom-scenario-window-tab-type cur-step)))
                              
                              (setf menu-items (populate-custom-scenario-win-menu win cur-step))))
                           
                           ((sdl:key= key :sdl-key-right)
                            (progn
                              (when (defenum:next-enum-tag 'custom-scenario-window-tab-type cur-step)
                                (setf cur-step (defenum:next-enum-tag 'custom-scenario-window-tab-type cur-step)))
                              
                              (setf menu-items (populate-custom-scenario-win-menu win cur-step))))
                           
                           ;; escape - quit
                           ((sdl:key= key :sdl-key-escape)
                            (setf *current-window* (return-to win))
                            (return-from run-window (values nil nil)))
                           
                           ;; Space - add/remove feat inside feats tab
                           ((and (sdl:key= key :sdl-key-space)
                                 (eq cur-step :custom-scenario-tab-feats))
                            (progn
                              (let ((lvl-mod (nth cur-sel overall-lvl-mods-list)))
                                (when (not (find lvl-mod always-lvl-mods-list))
                                  ;; make a radio button for the controlled-by lvl mods
                                  (when (= (lm-type lvl-mod) +level-mod-controlled-by+)
                                    (scenario-add/remove-lvl-mod scenario lvl-mod))
                                  
                                  ;; make checkboxes for the feats lvl mods
                                  (when (= (lm-type lvl-mod) +level-mod-sector-feat+)
                                    (if (find lvl-mod select-feats-list)
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general nil))
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))))
                                  
                                  ;; make checkboxes for the items lvl mods
                                  (when (= (lm-type lvl-mod) +level-mod-sector-item+)
                                    (if (find lvl-mod select-items-list)
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general nil))
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))))
                                  
                                  ;; make a radio button for the time of day lvl mods
                                  (when (= (lm-type lvl-mod) +level-mod-time-of-day+)
                                    (scenario-add/remove-lvl-mod scenario lvl-mod))
                                  
                                  ;; make checkboxes for the weather lvl mods
                                  (when (= (lm-type lvl-mod) +level-mod-weather+)
                                    (if (find lvl-mod select-weather-list)
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general nil))
                                      (progn
                                        (scenario-add/remove-lvl-mod scenario lvl-mod :add-general t))))
                                  
                                  (generate-feats-for-world-sector world-sector (world-map world))
                                  (scenario-adjust-lvl-mods-after-sector-regeneration scenario)
                                  (scenario-sort-select-lvl-mods scenario)
                                  
                                  (readjust-factions-after-feats-change win)
                                  
                                  (setf menu-items (populate-custom-scenario-win-menu win cur-step))))))
                           
                           ;; Space - add/remove faction inside factions tab
                           ((and (sdl:key= key :sdl-key-space)
                                 (eq cur-step :custom-scenario-tab-factions))
                            (progn
                              (let* ((current-faction (first (nth cur-faction cur-faction-list)))
                                     (faction-present (second (nth cur-faction cur-faction-list)))
                                     (ref-faction-obj (find current-faction
                                                            avail-faction-list :key #'(lambda (a)
                                                                                            (first a))))
                                     (ref-faction-present-pos (position faction-present (second ref-faction-obj)))
                                     (next-faction-present (if (>= (1+ ref-faction-present-pos) (length (second ref-faction-obj)))
                                                             (first (second ref-faction-obj))
                                                             (nth (1+ ref-faction-present-pos) (second ref-faction-obj)))))
                                (setf (nth cur-faction cur-faction-list) (list current-faction next-faction-present))
                                
                                (readjust-specific-factions-after-faction-change win)
                                (setf menu-items (populate-custom-scenario-win-menu win cur-step)))))
                           
                           ;; enter - select
                           ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                            (if (not (eq cur-step :custom-scenario-tab-specific-factions))
                              (progn
                                (setf cur-step (defenum:next-enum-tag 'custom-scenario-window-tab-type cur-step))
                                
                                (setf menu-items (populate-custom-scenario-win-menu win cur-step)))
                              (progn
                                (scenario-set-player-specific-faction scenario (nth cur-specific-faction specific-faction-list))
                                
                                (return-from run-window (values world-sector mission)))))
                           )
                         
                         (case cur-step
                           (:custom-scenario-tab-missions (progn (let ((prev-cur-sel cur-mission-type))
                                                                   (setf cur-mission-type (run-selection-list key mod unicode cur-mission-type))
                                                                   (setf cur-mission-type (adjust-selection-list cur-mission-type (length avail-mission-type-list)))
                                                                   (setf cur-sel cur-mission-type)
                                                                   
                                                                   (when (/= prev-cur-sel cur-sel)
                                                                     (adjust-mission-after-change win)))))
                           (:custom-scenario-tab-sectors (progn (let ((prev-cur-sel cur-sector))
                                                                  (setf cur-sector (run-selection-list key mod unicode cur-sector))
                                                                  (setf cur-sector (adjust-selection-list cur-sector (length avail-world-sector-type-list)))
                                                                  (setf cur-sel cur-sector)
                                                                  
                                                                  (when (/= prev-cur-sel cur-sel)
                                                                    (adjust-world-sector-after-change win)))))
                           (:custom-scenario-tab-months (progn (let ((prev-cur-sel cur-month))
                                                                 (setf cur-month (run-selection-list key mod unicode cur-month))
                                                                 (setf cur-month (adjust-selection-list cur-month (length months-list)))
                                                                 (setf cur-sel cur-month)
                                                                 
                                                                 (when (/= prev-cur-sel cur-sel)
                                                                   (adjust-months-before-feats win)))))
                           (:custom-scenario-tab-feats (progn (setf cur-feat (run-selection-list key mod unicode cur-feat))
                                                              (setf cur-feat (adjust-selection-list cur-feat (length overall-lvl-mods-list)))
                                                              (setf cur-sel cur-feat)
                                                              ))
                           (:custom-scenario-tab-factions (progn (setf cur-faction (run-selection-list key mod unicode cur-faction))
                                                                 (setf cur-faction (adjust-selection-list cur-faction (length cur-faction-list)))
                                                                 (setf cur-sel cur-faction)
                                                                 ))
                           (:custom-scenario-tab-specific-factions (progn (setf cur-specific-faction (run-selection-list key mod unicode cur-specific-faction))
                                                                          (setf cur-specific-faction (adjust-selection-list cur-specific-faction
                                                                                                                            (length specific-faction-list)))
                                                                          (setf cur-sel cur-specific-faction))))
                         
                         (make-output *current-window*))))
    (:video-expose-event () (make-output *current-window*))))
