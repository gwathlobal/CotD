(in-package :cotd-sdl)

(defclass main-menu-window (window)
  ((cur-sel :initform 0 :accessor main-menu-window/cur-sel :type fixnum)
   (menu-items :initform () :accessor main-meni-window/menu-items :type list)
   (menu-strs :initform () :accessor main-menu-window/menu-strs :type list)
   (menu-funcs :initform () :accessor main-menu-window/menu-funcs :type list)
   ))

(defmethod initialize-instance :after ((win main-menu-window) &key)
  (populate-main-menu win))

(defmethod make-output ((win main-menu-window))
  (with-slots (cur-sel menu-items menu-strs) win
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* "City of the Damned" (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)
    
    (sdl:draw-string-solid-* "Whoever wins... We lose" (- *window-width* 20) (+ 10 30 (sdl:char-height sdl:*default-font*)) :justify :right :color sdl:*white*)
    
    ;; drawing selection list
    (loop with color-list = ()
          for i from 0 below (length menu-strs) do
            (if (= i cur-sel)
              (push sdl:*yellow* color-list)
              (push sdl:*white* color-list))
          finally (setf color-list (reverse color-list))
                  (draw-selection-list menu-strs cur-sel (length menu-strs) 20 (+ 10 30 20 (sdl:char-height sdl:*default-font*) (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t))
        
    (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Exit game")
                             10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
    
    (sdl:update-display)))

(defmethod run-window ((win main-menu-window))
  (with-slots (cur-sel menu-funcs menu-strs) win
    (sdl:with-events ()
      (:quit-event () (funcall (quit-func win)) t)
      (:key-down-event (:key key :mod mod :unicode unicode)
                       
                       (setf cur-sel (run-selection-list key mod unicode cur-sel :start-page (truncate cur-sel (length menu-strs)) :max-str-per-page (length menu-strs)))
                       (setf cur-sel (adjust-selection-list cur-sel (length menu-strs)))
                       
                       (cond
                         ;; escape - quit
                         ((sdl:key= key :sdl-key-escape)
                          (game-state-menu->quit)
                          (go-to-quit-game))
                         ;; enter - select
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (when (and menu-funcs (nth cur-sel menu-funcs))
                            (let ((menu-result (funcall (nth cur-sel menu-funcs))))
                              (when (eq menu-result :menu-stop-loop)
                                (return-from run-window nil))))
                          ))
                       (make-output *current-window*))
      (:video-expose-event () (make-output *current-window*)))))

(defun populate-main-menu (win)
  (with-slots (menu-items menu-strs menu-funcs) win
    (setf menu-items ()
          menu-strs ()
          menu-funcs ())
    (flet ((new-campaign-func ()
             (setf *world* (make-instance 'world))
             (setf (world-game-time *world*) (set-current-date-time 1915 3 12 0 0 0))
             (setf (world-map *world*) (generate-normal-world-map *world*))

             (push +game-event-campaign-demon-win+ (game-events *world*))
             (push +game-event-campaign-military-win+ (game-events *world*))
             (push +game-event-campaign-angel-win+ (game-events *world*))
             (push +game-event-campaign-flesh-gathered+ (game-events *world*))
             (push +game-event-campaign-satanists-move+ (game-events *world*))
             (push +game-event-campaign-move-military+ (game-events *world*))
             (push +game-event-campaign-move-demons+ (game-events *world*))
             (push +game-event-campaign-move-relic-to-church+ (game-events *world*))
             (push +game-event-campaign-trigger-commands+ (game-events *world*))
             (push +game-event-campaign-malseraphs-focus+ (game-events *world*))
                                       
             (add-campaign-effect *world* :id :campaign-effect-satanist-sacrifice :cd 5)
                                                                              
             (multiple-value-bind (campaign-items campaign-funcs campaign-descrs) (new-campaign-menu-items)
               (setf *current-window* (make-instance 'select-faction-window 
                                                     :window-title "SELECT FACTION FOR CAMPAIGN" 
                                                     :menu-items campaign-items 
                                                     :menu-descrs campaign-descrs))
               (make-output *current-window*)
               (let ((select-n (run-window *current-window*)))
                 (if select-n
                     (progn
                       (enter-player-name)
                       (setf (world/player-specific-faction *world*) 
                             (funcall (nth select-n campaign-funcs) select-n))
                       (setf *player-title* (get-specific-faction-name (world/player-specific-faction *world*)))

                       ;; TODO: send to server that a custom campaign is to be started
                       ;; (:start-game (:type :campaign :sub-type :custom :player-name *player-name* 
                       ;;               :player-faction world/player-specific-faction))
                       
                       (game-state-menu->campaign-init)
                       :menu-stop-loop)
                     nil))))
           
           (load-campaign-func ()
             (setf *current-window* (make-instance 'load-game-window :save-game-type :save-game-campaign))
             (make-output *current-window*)
             (case (run-window *current-window*)
               (:save-campaign (progn
                                 ;; TODO: send to server that a custom campaign is to be loaded
                                 ;; (:load-game (:type :campaign :name "save0"))
             
                                 (game-state-menu->campaign-map)
                                 :menu-stop-loop))
               (:save-scenario (progn
                                 ;; TODO: send to server that a custom scenario is to be loaded
                                 ;; (:load-game (:type :scenario :name "save0"))
                                 
                                 (game-state-menu->campaign-scenario)
                                 :menu-stop-loop))
               (t (progn
                    ;; TODO: remove recursion
                    (populate-main-menu win)
                    nil))))
           
           (quick-scenario-func () 
             (multiple-value-bind (quick-scenario-items quick-scenario-funcs quick-scenario-descrs) 
                 (quick-scenario-menu-items)
               (setf *current-window* (make-instance 'select-faction-window 
                                                     :menu-items quick-scenario-items 
                                                     :menu-descrs quick-scenario-descrs))
               (make-output *current-window*)
               (let ((select-n (run-window *current-window*)))
                 (when select-n
                   (multiple-value-bind (world-sector mission) (funcall (nth select-n quick-scenario-funcs) select-n)
                     (when (and mission world-sector)
                       (enter-player-name)
                       (setf *player-title* (get-specific-faction-name (player-specific-faction mission)))
                       (prepare-game-scenario mission world-sector)

                       ;; TODO: send to server that a custom scenario is to be started
                       ;; (:start-game (:type :scenario :sub-type :custom :player-name *player-name* 
                       ;;               :mission misson :world-sector world-sector))
             
                       (game-state-menu->custom-scenario)
                       :menu-stop-loop))))))
           
           (custom-scenario-func ()
             (setf *current-window* (make-instance 'custom-scenario-window))
             (make-output *current-window*)
             (multiple-value-bind (world-sector mission) (run-window *current-window*)
               (when (and world-sector mission)
                 (enter-player-name)
                 (setf *player-title* (get-specific-faction-name (player-specific-faction mission)))
                 (prepare-game-scenario mission world-sector)

                 ;; TODO: send to server that a custom scenario is to be started
                 ;; (:start-game (:type :scenario :sub-type :custom :player-name *player-name* 
                 ;;               :mission misson :world-sector world-sector))
             
                 (game-state-menu->custom-scenario)
                 :menu-stop-loop)))
           
           (load-scenario-func ()
             (setf *current-window* (make-instance 'load-game-window :save-game-type :save-game-scenario))
             (make-output *current-window*)
             (case (run-window *current-window*)
               (:save-scenario (progn
                                 ;; TODO: send to server that a custom scenario is to be started
                                 ;; (:load-game (:type :scenario :name "save0"))
             
                                 (game-state-menu->custom-scenario)
                                 :menu-stop-loop))
               (t (progn
                    ;; TODO: remove recursion
                    (populate-main-menu win)
                    nil))))
           
           (settings-func ()
             (setf *current-window* (make-instance 'settings-window))
             (make-output *current-window*)
             (run-window *current-window*)
             nil)
           
           (high-scores-func ()
             (truncate-highscores *highscores*)
             (setf *current-window* (make-instance 'highscores-window))
             (make-output *current-window*)
             (run-window *current-window*)
             nil)
           
           (help-func () 
             (setf *current-window* (make-instance 'help-window))
             (make-output *current-window*)
             (run-window *current-window*)
             nil)
           
           (exit-func () 
             (game-state-menu->quit)
             (go-to-quit-game))
           
           (city-with-all-seeing-func ()
             ;; TODO: send to server that a custom scenario is to be started
             ;; (:start-game (:type :scenario :sub-type :all-seeing))
               
             (multiple-value-bind (mission world-sector) 
                 (find-random-scenario-options +specific-faction-type-player+)
               (when (and mission world-sector)
                 (prepare-game-scenario mission world-sector)
                 (game-state-menu->custom-scenario)
                 :menu-stop-loop)))
           
           (test-level-func () 
             (let ((test-world-map (make-instance 'world-map))
                   (mission (make-instance 'mission :mission-type-id :mission-type-test
                                           :x 0 :y 0
                                           :level-modifier-list (list +lm-tod-night+)))
                   (world-sector (make-instance 'world-sector :wtype :world-sector-test :x 0 :y 0)))
               (setf *world* (make-instance 'world))
               (setf (world-game-time *world*) (set-current-date-time 1915 3 12 0 0 0))
               (generate-empty-world-map test-world-map)
               (setf (world-map *world*) test-world-map)
                                       
               (setf (aref (cells test-world-map) 0 0) world-sector)
               (setf (mission (aref (cells test-world-map) 0 0)) mission)
               (setf (player-lvl-mod-placement-id mission) +lm-placement-test+)
               (setf (player-specific-faction mission) nil)
                                       
               (prepare-game-scenario mission world-sector)

               ;; TODO: send to server that a custom scenario is to be started
               ;; (:start-game (:type :scenario :sub-type :test))
               
               (game-state-menu->custom-scenario)
               :menu-stop-loop))
           
           (replay-prev-scenario-func ()
             (let ((avail-mission-type-list (list (get-mission-type-by-id (first *previous-scenario*)))))
               (multiple-value-bind (mission world-sector) 
                   (find-random-scenario-options (second *previous-scenario*)
                                                 :avail-mission-type-list avail-mission-type-list)
                 (if (and mission world-sector)
                     (progn
                       (enter-player-name)
                       (prepare-game-scenario mission world-sector)
                       
                       ;; TODO: send to server that a custom scenario is to be started
                       ;; (:start-game (:type :scenario :sub-type :previous :player-name *player-name*))
                       
                       (game-state-menu->custom-scenario)
                       :menu-stop-loop)
                   nil))))
           
           (test-campaign-func ()
             ;; TODO: send to server that a custom campaign is to be started
             ;; (:start-game (:type :campaign :sub-type :test))
             
             (let ((mission nil)
                   (world-sector nil))
               (flet ((test-map-func ()
                        (setf (world-map *world*) (generate-test-world-map *world*))
                        (setf (mission (aref (cells (world-map *world*)) 1 2)) 
                              (generate-mission-on-world-map *world* 1 2 
                                                             :mission-type-military-conquest :off-map nil))
                        (world-map *world*)))
                 (setf *world* (make-instance 'world))
                 (setf (world-game-time *world*) (set-current-date-time 1915 3 12 0 0 0))
                 (test-map-func)
                                          
                 (game-state-menu->campaign-map)
                 (setf *current-window* (make-instance 'campaign-window
                                                       :test-map-func #'test-map-func))
                 (make-output *current-window*)
                 (multiple-value-setq (mission world-sector) (run-window *current-window*))
                 (when (and mission world-sector)
                                            
                   (setf (player-lvl-mod-placement-id mission) +lm-placement-player+)
                   (setf (player-specific-faction mission) nil)
                                            
                   (setf *current-window* (return-to *current-window*))
                   (game-state-campaign-map->menu)
                                            
                   (prepare-game-scenario mission world-sector)
                   (game-state-menu->custom-scenario)
                   :menu-stop-loop)))))
      
      (let ((new-campaign-item (list "New campaign" #'new-campaign-func))
            (load-campaign-item (list "Load campaign" #'load-campaign-func))
            (quick-scenario-item (list "Quick scenario" #'quick-scenario-func))
            (custom-scenario-item (list "Custom scenario" #'custom-scenario-func))
            (load-scenario-item (list "Load scenario" #'load-scenario-func))
            (settings-item (list "Settings" #'settings-func))
            (highscores-item (list "High scores" #'high-scores-func))
            (help-item (list "Help" #'help-func))
            (exit-item (list "Exit" #'exit-func))
            (all-see-item (list "City with all-seeing" #'city-with-all-seeing-func))
            (test-level-item (list "Test level" #'test-level-func))
            (play-prev-scenario (list "Replay the previous scenario" #'replay-prev-scenario-func))
            (test-campaign-item (list "Test campaign" #'test-campaign-func)))
        
        (if *cotd-release*
            (progn
              (setf menu-items (append (if *previous-scenario*
                                           (list play-prev-scenario)
                                           nil)
                                       (list new-campaign-item)
                                       (if (find-all-save-game-paths :save-game-campaign)
                                           (list load-campaign-item)
                                           nil)
                                       (list quick-scenario-item custom-scenario-item)
                                       (if (find-all-save-game-paths :save-game-scenario)
                                           (list load-scenario-item)
                                           nil)
                                       (list settings-item highscores-item help-item exit-item))))
            (progn
              (setf menu-items (append (if *previous-scenario*
                                           (list play-prev-scenario)
                                           nil)
                                       (list new-campaign-item)
                                       (if (find-all-save-game-paths :save-game-campaign)
                                           (list load-campaign-item)
                                           nil)
                                       (list quick-scenario-item custom-scenario-item)
                                       (if (find-all-save-game-paths :save-game-scenario)
                                           (list load-scenario-item)
                                           nil)
                                       (list all-see-item test-level-item test-campaign-item settings-item 
                                             highscores-item help-item exit-item))))))
      
      (loop for (menu-str menu-func) in menu-items
            do
               (push menu-str menu-strs)
               (push menu-func menu-funcs)
            finally (setf menu-strs (reverse menu-strs))
                    (setf menu-funcs (reverse menu-funcs))))))
