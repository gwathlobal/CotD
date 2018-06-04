(in-package :cotd)

(defun game-loop ()
  "Main game loop"
  (loop with turn-finished = t
        do
           ;;(format t "GAME-LOOP: Start loop~%")
           (setf turn-finished t)
           (logger (format nil "REAL-GAME-TURN: ~A~%~%" (real-game-time *world*)))

           ;; check for the player's win conditions first
           (when (and *player*
                      (find (loyal-faction *player*) (game-events *world*))
                      (funcall (on-check (get-game-event-by-id (find (loyal-faction *player*) (game-events *world*)))) *world*))
             (funcall (on-trigger (get-game-event-by-id (find (loyal-faction *player*) (game-events *world*)))) *world*))
           
           ;; check all available game events
           (loop for game-event-id of-type fixnum in (game-events *world*)
                 for game-event of-type game-event = (get-game-event-by-id game-event-id)
                 when (and (not (disabled game-event))
                           (funcall (on-check game-event) *world*))
                   do
                      (funcall (on-trigger game-event) *world*))

           ;; we need this for events to get triggered only once  
           (setf (turn-finished *world*) nil)

           (when (or (check-dead *player*)
                     (master-mob-id *player*))
             (when (master-mob-id *player*)
               (setf (x *player*) (x (get-mob-by-id (master-mob-id *player*))) (y *player*) (y (get-mob-by-id (master-mob-id *player*))) (z *player*) (z (get-mob-by-id (master-mob-id *player*)))))
             (update-visible-mobs *player*)
             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
             
             (make-output *current-window*)
             (pause-for-poll))
           
           ;; iterate through all the mobs
           ;; those who are not dead and have cur-ap > 0 can make a move
           (loop for mob of-type mob across *mobs* do
             (when (and (not (check-dead mob))
                        (> (cur-ap mob) 0)
                        (not (is-merged mob)))
               
               (setf turn-finished nil)
               (setf (made-turn mob) nil)
               (set-message-this-turn nil)
               (setf (motion-set-p mob) nil)
               
               ;; for trinity mimics - set the current mob as the player
               ;; for split soul - set the current mob as the player
               (when (or (and (subtypep (type-of mob) 'player)
                              (mob-ability-p mob +mob-abil-trinity-mimic+)
                              (find (id mob) (mimic-id-list *player*)))
                         (and (subtypep (type-of mob) 'player)
                              (mob-effect-p mob +mob-effect-split-soul-target+))
                         (and (subtypep (type-of mob) 'player)
                              (mob-effect-p mob +mob-effect-split-soul-source+)))
                 (setf *player* mob))

               (setf (if-cur-mob-seen-through-shared-vision *player*) (if (mounted-by-mob-id mob)
                                                                        (and (find (mounted-by-mob-id mob) (shared-visible-mobs *player*))
                                                                             (not (find (mounted-by-mob-id mob) (proper-visible-mobs *player*))))
                                                                        (and (find (id mob) (shared-visible-mobs *player*))
                                                                             (not (find (id mob) (proper-visible-mobs *player*))))))
               
               (ai-function mob)
               (when (get-message-this-turn) (add-message (format nil "~%")))
               (setf (heard-sounds mob) nil)

               (update-visible-mobs mob)
               (when (eq mob *player*)
                 (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                 (update-map-area)
                 )
               
               
               ;; process animations for this turn if any
               (when (animation-queue *world*)
                 
                 (loop for animation in (animation-queue *world*)
                       do
                          (play-animation animation))
                 (sdl:update-display)
                 (sdl-cffi::sdl-delay 100)
                 (setf (animation-queue *world*) nil)
                 (update-map-area))
               
               (when (<= (cur-ap mob) 0)
                 (on-tick mob))

               (unless *cotd-release*
                 ;; checking for inconsistences between *items* and item-quadrant-map 
                 (loop for y from 0 below (array-dimension (item-quadrant-map (level *world*)) 1) do
                   (loop for x from 0 below (array-dimension (item-quadrant-map (level *world*)) 0) do
                     (loop for item-id in (aref (item-quadrant-map (level *world*)) x y)
                           unless (get-item-by-id item-id) do
                             (error (format nil "ITEM ID ~A AT (~A ~A) NIL, FAILED!!!" item-id x y)))))
                 ;; checking for inconsistences between actual number of angels on map and (total-angels *world*)
                 (loop with result = 0
                       for mob-id in (mob-id-list (level *world*))
                       for mob = (get-mob-by-id mob-id)
                       when (and (not (check-dead mob))
                                 (and (mob-ability-p mob +mob-abil-angel+)
                                      (not (mob-ability-p mob +mob-abil-animal+))))
                         do
                            (incf result)
                            (loop for merged-id in (merged-id-list mob)
                                  for merged-mob = (get-mob-by-id merged-id)
                                  when (and (not (check-dead merged-mob))
                                            (and (mob-ability-p merged-mob +mob-abil-angel+)
                                                 (not (mob-ability-p merged-mob +mob-abil-animal+))))
                                    do
                                       (incf result))
                       finally (when (/= (total-angels *world*) result)
                                 (error (format nil "FAILED!!! TOTAL ANGELS = ~A, ACTUAL ANGELS ALIVE = ~A" (total-angels *world*) result))))
                     
                 )

               ))
                      
           (bt:with-lock-held ((path-lock *world*))
             (when (and *path-thread* (bt:thread-alive-p *path-thread*))
               (bt:destroy-thread *path-thread*)))
           
           (when turn-finished
             (incf (real-game-time *world*))
             (when (check-dead *player*)
               (incf (player-game-time *world*) +normal-ap+))
             (setf (turn-finished *world*) t)
             (set-message-this-turn nil)
             (loop for mob of-type mob across *mobs* do
               (when (and (not (check-dead mob))
                          (not (is-merged mob)))
                 ;; increase cur-ap by max-ap
                 (incf (cur-ap mob) (max-ap mob))
                 ;; tick piety if the mob worships a god
                 (setf (if-cur-mob-seen-through-shared-vision *player*) (and (find (id mob) (shared-visible-mobs *player*))
                                                                             (not (find (id mob) (proper-visible-mobs *player*)))))
                 
                 (when (worshiped-god mob)
                   (funcall (piety-tick-func (get-god-by-id (get-worshiped-god-type (worshiped-god mob)))) (get-god-by-id (get-worshiped-god-type (worshiped-god mob))) mob))))
             (loop for feature-id of-type fixnum in (feature-id-list (level *world*))
                   for feature of-type feature = (get-feature-by-id feature-id)
                   when (and feature
                             (on-tick-func feature))
                   do
                      (funcall (on-tick-func feature) (level *world*) feature))
             (when (zerop (random 3))
               (setf (wind-dir (level *world*)) (1+ (random 9))))
             (when (get-message-this-turn) (add-message (format nil "~%")))
             ))
  )
  
(defun init-game (mission-id layout-id weather-id tod-id specific-faction-type faction-list)
  (setf *mobs* (make-array (list 0) :adjustable t))
  (setf *lvl-features* (make-array (list 0) :adjustable t))
  (setf *items* (make-array (list 0) :adjustable t))
  
  (clear-message-list *full-message-box*)
  (clear-message-list *small-message-box*)
  
  (setf *cur-angel-names* (copy-list *init-angel-names*))
  (setf *cur-demon-names* (copy-list *init-demon-names*))
  (setf *cur-human-names* (copy-list *init-human-names*))
  (setf *cur-human-surnames* (copy-list *init-human-surnames*))

  (setf *update-screen-closure* #'(lambda (str)
                                    (when (and str
                                               (subtypep (type-of *current-window*) 'loading-window))
                                      (setf (cur-str *current-window*) str))
                                    (make-output *current-window*)
				    ))

  (setf *world* (make-instance 'world))
  
  (create-world *world* mission-id layout-id weather-id tod-id specific-faction-type faction-list)

  ;;(format t "FACTION-LIST ~A~%" faction-list)
  
  (setf (name *player*) "Player")

  (add-message (format nil "Welcome to City of the Damned.~%This is a "))
  (add-message (format nil "~(~A~)" (name (get-mission-scenario-by-id mission-id))) sdl:*yellow*)
  (add-message (format nil " in "))
  (add-message (format nil "~(~A~)" (sf-name (get-scenario-feature-by-id (level-layout (level *world*))))) sdl:*yellow*)
  (add-message (format nil "!~%~%To view help, press '?'.~%To view your current objective, press 'j'.~%"))

  )  

(defun find-random-scenario-options (specific-faction-type)
  (let ((available-faction-list)
        (available-layout-list)
        (available-mission-list)
        (mission-id)
        (layout-id)
        (faction-list))

    (setf available-faction-list (loop for faction-type across *faction-types*
                                       when (and faction-type
                                                 (find specific-faction-type (specific-faction-list faction-type)))
                                         collect (id faction-type)))

    (setf available-layout-list
          (loop for mission-district across *mission-districts* 
                when (eq t (loop with result = nil
                                 for faction-type-id in available-faction-list
                                 when (and mission-district
                                           (find-if #'(lambda (a)
                                                        (if (and (or (= (second a) +mission-faction-attacker+)
                                                                     (= (second a) +mission-faction-defender+)
                                                                     (= (second a) +mission-faction-present+))
                                                                 (= (first a) faction-type-id))
                                                          t
                                                          nil))
                                                    (faction-list mission-district)))
                                   do
                                      (setf result t)
                                      (loop-finish)
                                 finally (return-from nil result)))
                  collect (id mission-district)))
    
    (setf available-mission-list (loop for mission-scenario across *mission-scenarios*
                                       when (or (eq t (loop with result = nil
                                                            for layout-id in available-layout-list
                                                            when (find layout-id (district-layout-list mission-scenario)) do
                                                              (setf result t)
                                                              (loop-finish)
                                                            finally (return-from nil result)))
                                                (eq t (loop with result = nil
                                                            for faction-type-id in available-faction-list
                                                            when (find-if #'(lambda (a)
                                                                              (if (and (or (= (second a) +mission-faction-attacker+)
                                                                                           (= (second a) +mission-faction-defender+)
                                                                                           (= (second a) +mission-faction-present+))
                                                                                       (= (first a) faction-type-id))
                                                                                t
                                                                                nil))
                                                                          (faction-list mission-scenario))
                                                              do
                                                                 (setf result t)
                                                                 (loop-finish)
                                                            finally (return-from nil result))))
                                         collect (id mission-scenario)))
    
    (setf mission-id (nth (random (length available-mission-list)) available-mission-list))
    
    (setf layout-id (nth (random (length (district-layout-list (get-mission-scenario-by-id mission-id)))) (district-layout-list (get-mission-scenario-by-id mission-id))))
    
    ;; collecting all available factions with the structure (faction-id (<faction-present> <faction-present> ...)) 
    (setf faction-list (loop with result = ()
                             for (faction-id faction-present) in (append (faction-list (get-mission-district-by-id layout-id))
                                                                         (faction-list (get-mission-scenario-by-id mission-id)))
                             for faction-obj = (find faction-id result :key #'(lambda (a) (first a)))
                             do
                                (if faction-obj
                                  (progn
                                    (pushnew faction-present (second faction-obj)))
                                  (progn
                                    (push (list faction-id (list faction-present)) result)))
                             finally (return-from nil result)))
    
    ;; remove +mission-faction-present+ if there are +mission-faction-defender+ or +mission-faction-attacker+ options available for this faction
    (loop for (faction-id faction-present-list) in faction-list
          for n from 0
          when (and (find +mission-faction-present+ faction-present-list)
                    (or (find +mission-faction-attacker+ faction-present-list)
                        (find +mission-faction-defender+ faction-present-list)))
            do
               (setf (nth n faction-list) (list faction-id (remove +mission-faction-present+ faction-present-list))))

    ;; remove +mission-faction-delayed+ and +mission-faction-absent+ for the player faction
    (loop for (faction-id faction-present-list) in faction-list
          for n from 0
          when (and (or (find +mission-faction-delayed+ faction-present-list)
                        (find +mission-faction-absent+ faction-present-list) )
                    (find faction-id available-faction-list))
            do
               (setf (nth n faction-list) (list faction-id (remove +mission-faction-delayed+ (second (nth n faction-list)))))
               (setf (nth n faction-list) (list faction-id (remove +mission-faction-absent+ (second (nth n faction-list))))))
        
    ;; set up random presence options in the faction list
    (loop for (faction-id faction-present-list) in faction-list
          for n from 0
          do
             (setf (nth n faction-list) (list faction-id (nth (random (length faction-present-list)) faction-present-list))))
    
    (return-from find-random-scenario-options (values mission-id
                                                      layout-id
                                                      faction-list))))

(defun main-menu ()
  (let ((join-heaven-item (cons "Join the Celestial Communion (as a Chrome angel)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-angel-chrome+))

                                      (return-from main-menu (values mission-id
                                                                     layout-id
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +specific-faction-type-angel-chrome+
                                                                     faction-list))))))
        (join-trinity-item (cons "Join the Celestial Communion (as a Trinity mimic)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-angel-trinity+))
                                      
                                      (return-from main-menu (values mission-id
                                                                     layout-id
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +specific-faction-type-angel-trinity+
                                                                     faction-list))))))
        (join-legion-item (cons "Join the Pandemonium Hierarchy (as a Crimson imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-crimson+))
                                      
                                      (return-from main-menu (values mission-id
                                                                     layout-id
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +specific-faction-type-demon-crimson+
                                                                     faction-list))))))
        (join-shadow-item (cons "Join the Pandemonium Hierarchy (as a Shadow imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-shadow+))
                                      
                                      (return-from main-menu (values mission-id
                                                                     layout-id
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     +tod-type-evening+
                                                                     +specific-faction-type-demon-shadow+
                                                                     faction-list))))))
        (join-puppet-item (cons "Join the Pandemonium Hierarchy (as Malseraph's puppet)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-malseraph+))
                                      
                                      (return-from main-menu (values mission-id
                                                                     layout-id
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +specific-faction-type-demon-malseraph+
                                                                     faction-list))))))
        (join-chaplain-item (cons "Join the Military (as a Chaplain)"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-military-chaplain+))
                                        
                                        (return-from main-menu (values mission-id
                                                                       layout-id
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +specific-faction-type-military-chaplain+
                                                                       faction-list))))))
        (join-scout-item (cons "Join the Military (as a Scout)"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-military-scout+))
                                     
                                     (return-from main-menu (values mission-id
                                                                    layout-id
                                                                    (nth (random (length weather-types)) weather-types)
                                                                    (nth (random (length tod-types)) tod-types)
                                                                    +specific-faction-type-military-scout+
                                                                    faction-list))))))
        (join-thief-item (cons "Join as the Thief"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-thief+))
                                     
                                     (return-from main-menu (values mission-id
                                                                    layout-id
                                                                    (nth (random (length weather-types)) weather-types)
                                                                    +tod-type-evening+
                                                                    +specific-faction-type-thief+
                                                                    faction-list))))))
        (join-satanist-item (cons "Join the Satanists"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-satanist+))
                                        
                                        (return-from main-menu (values mission-id
                                                                       layout-id
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +specific-faction-type-satanist+
                                                                       faction-list))))))
        (join-church-item (cons "Join the Church"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-priest+))
                                        
                                        (return-from main-menu (values mission-id
                                                                       layout-id
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +specific-faction-type-priest+
                                                                       faction-list))))))
        (join-eater-item (cons "Join as the Eater of the dead"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (remove +weather-type-snow+ (get-all-scenario-features-by-type +scenario-feature-weather+ nil)))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-eater+))
                                        
                                        (return-from main-menu (values mission-id
                                                                       layout-id
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +specific-faction-type-eater+
                                                                       faction-list))))))
        (join-ghost-item (cons "Join as the Lost soul"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-ghost+))
                                     
                                     (return-from main-menu (values mission-id
                                                                    layout-id
                                                                    (nth (random (length weather-types)) weather-types)
                                                                    (nth (random (length tod-types)) tod-types)
                                                                    +specific-faction-type-ghost+
                                                                    faction-list))))))
        (custom-scenario-item (cons "Custom scenario"
                                    #'(lambda (n)
                                        (declare (ignore n))
                                        (setf *current-window* (make-instance 'custom-scenario-window
                                                                              :mission-list (get-all-mission-scenarios-list)
                                                                              :weather-list (get-all-scenario-features-by-type +scenario-feature-weather+ (not *cotd-release*))
                                                                              :tod-list (get-all-scenario-features-by-type +scenario-feature-time-of-day+ (not *cotd-release*))
                                                                              ))
                                        (setf (menu-items *current-window*) (populate-custom-scenario-win-menu *current-window* (cur-step *current-window*)))
                                        (make-output *current-window*)
                                        (multiple-value-bind (mission-id layout-id weather-id tod-id specific-faction-type faction-list) (run-window *current-window*)
                                          (when (and mission-id layout-id weather-id tod-id specific-faction-type faction-list)
                                            (return-from main-menu (values mission-id layout-id weather-id tod-id specific-faction-type faction-list)))))))
        (highscores-item (cons "High scores"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (setf *current-window* (make-instance 'highscores-window))
                                   (make-output *current-window*)
                                   (run-window *current-window*))))
        (help-item (cons "Help"
                         #'(lambda (n) 
                             (declare (ignore n))
                             (setf *current-window* (make-instance 'help-window))
                             (make-output *current-window*)
                             (run-window *current-window*))))
        (exit-item (cons "Exit"
                         #'(lambda (n) 
                             (declare (ignore n))
                             (funcall *quit-func*))))
        (all-see-item (cons "City with all-seeing"
                            #'(lambda (n) 
                                (declare (ignore n))
                                (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                      (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                      (mission-id)
                                      (layout-id)
                                      (faction-list))

                                  (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-angel-chrome+))
                                  
                                  (return-from main-menu (values mission-id
                                                                 layout-id
                                                                 (nth (random (length weather-types)) weather-types)
                                                                 (nth (random (length tod-types)) tod-types)
                                                                 +specific-faction-type-player+
                                                                 faction-list))))))
        (test-level-item (cons "Test level"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (return-from main-menu (values 0
                                                                  +city-layout-test+
                                                                  +weather-type-clear+
                                                                  +tod-type-night+
                                                                  +specific-faction-type-test+
                                                                  nil))))))
    (if *cotd-release*
      (progn
        (setf *current-window* (make-instance 'start-game-window 
                                              :menu-items (list (car join-heaven-item) (car join-trinity-item) (car join-legion-item) (car join-shadow-item) (car join-puppet-item) (car join-chaplain-item) (car join-scout-item)
                                                                (car join-thief-item) (car join-satanist-item) (car join-church-item) (car join-eater-item) (car join-ghost-item)
                                                                (car custom-scenario-item) (car highscores-item) (car help-item) (car exit-item))
                                              :menu-funcs (list (cdr join-heaven-item) (cdr join-trinity-item) (cdr join-legion-item) (cdr join-shadow-item) (cdr join-puppet-item) (cdr join-chaplain-item) (cdr join-scout-item)
                                                                (cdr join-thief-item) (cdr join-satanist-item) (cdr join-church-item) (cdr join-eater-item) (cdr join-ghost-item)
                                                                (cdr custom-scenario-item) (cdr highscores-item) (cdr help-item) (cdr exit-item)))))
      (progn
        (setf *current-window* (make-instance 'start-game-window 
                                              :menu-items (list (car join-heaven-item) (car join-trinity-item) (car join-legion-item) (car join-shadow-item) (car join-puppet-item) (car join-chaplain-item) (car join-scout-item)
                                                                (car join-thief-item) (car join-satanist-item) (car join-church-item) (car join-eater-item) (car join-ghost-item)
                                                                (car custom-scenario-item) (car all-see-item) (car test-level-item)
                                                                (car highscores-item) (car help-item) (car exit-item))
                                              :menu-funcs (list (cdr join-heaven-item) (cdr join-trinity-item) (cdr join-legion-item) (cdr join-shadow-item) (cdr join-puppet-item) (cdr join-chaplain-item) (cdr join-scout-item)
                                                                (cdr join-thief-item) (cdr join-satanist-item) (cdr join-church-item) (cdr join-eater-item) (cdr join-ghost-item)
                                                                (cdr custom-scenario-item) (cdr all-see-item) (cdr test-level-item)
                                                                (cdr highscores-item) (cdr help-item) (cdr exit-item)))))))
  
  (make-output *current-window*)
  (loop while t do
    (run-window *current-window*)))

  
(defun cotd-main () 
  (in-package :cotd)
    
  (sdl:with-init ()
    
    (let ((tiles-path))
    
      ;; create default options
      (setf *options* (make-options :tiles 'large))
      
      ;; get options from file if possible
      (if (probe-file (merge-pathnames "options.cfg" *current-dir*))
        (progn
          (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :input)
            (handler-case
                (loop for s-expr = (read file nil) 
                      while s-expr do
                        (read-options s-expr *options*))
              (t ()
                (logger "OPTIONS.CFG: Error occured while reading the options.cfg. Overwriting with defaults.~%")
                (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output :if-exists :supersede)
                  (format file "~A" (create-options-file-string *options*)))))))   
        (progn 
          (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output)
            (format file "~A" (create-options-file-string *options*))))
        )
      
      ;; set parameters depending on options
      ;; tiles
      (cond
        (t (setf *glyph-w* 15 *glyph-h* 15 tiles-path "data/font_large.bmp")))
      ;; font
      (cond
        ((equal (options-font *options*) 'font-6x13) (sdl:initialise-default-font sdl:*font-6x13*))
        (t (sdl:initialise-default-font sdl:*font-8x13*)))
      ;; name
      (cond
        ((options-player-name *options*) nil)
        (t (setf (options-player-name *options*) "Player")))

      ;; create default highscores
      (setf *highscores* (make-highscores))

      (if (probe-file (merge-pathnames "scenario-highscores" *current-dir*))
        (progn
          (with-open-file (file (merge-pathnames "scenario-highscores" *current-dir*) :direction :input)
            (handler-case
                (loop for s-expr = (read file nil) 
                      while s-expr do
                        (add-highscore-record (read-highscore-record s-expr) *highscores*))
              (t ()
                (logger "OPTIONS.CFG: Error occured while reading the scenario-highscores. Overwriting with defaults.~%")
                (write-highscores-to-file *highscores*)
                ))))   
        (progn 
          (write-highscores-to-file *highscores*)
          )
        )
      

      (setf *msg-box-window-height* (* (sdl:get-font-height) 8))
      (setf *random-state* (make-random-state t))

      (setf *window-width* (+ 350 (+ 30 (* *glyph-w* *max-x-view*))) 
            *window-height* (+ 30 (* *glyph-h* *max-y-view*) *msg-box-window-height* (* 3 (sdl:char-height sdl:*default-font*))))

      (when (<= *window-height* 384)
        (incf *window-height* (+ (* 6 (sdl:char-height sdl:*default-font*)) 0)))
      
      (sdl:window *window-width* *window-height*
                  :title-caption "The City of the Damned"
                  :icon-caption "The City of the Damned")
      (sdl:enable-key-repeat nil nil)
      (sdl:enable-unicode)
      
      (setf *temp-rect* (sdl::rectangle-from-edges-* 0 0 *glyph-w* *glyph-h*))
      

      (logger (format nil "current-dir = ~A~%" *current-dir*))
      (logger (format nil "path = ~A~%" (sdl:create-path tiles-path *current-dir*)))
      
      (setf *glyph-front* (sdl:load-image (sdl:create-path tiles-path *current-dir*) 
                                          :color-key sdl:*white*))
      (setf *glyph-temp* (sdl:create-surface *glyph-w* *glyph-h* :color-key sdl:*black*))
      )

    (setf *path-thread* nil)
    
    (tagbody
       (setf *quit-func* #'(lambda () (go exit-tag)))
       (setf *start-func* #'(lambda () (go start-tag)))
     start-tag
       (when (and *path-thread* (bt:thread-alive-p *path-thread*))
         (bt:destroy-thread *path-thread*))
       (multiple-value-bind (mission-id layout-id weather-id tod-id specific-faction-type faction-list) (main-menu)
         (setf *current-window* (make-instance 'loading-window 
                                               :update-func #'(lambda (win)
                                                                (when (/= *max-progress-bar* 0) 
                                                                  (let ((str (format nil "~A... ~3D%"
                                                                                     (cur-str win)
                                                                                     (truncate (* 100 *cur-progress-bar*) *max-progress-bar*))))
                                                                    (sdl:draw-string-solid-*  str
                                                                                              (truncate (- (/ *window-width* 2) (/ (* (length str) (sdl:char-width sdl:*default-font*)) 2)))
                                                                                              (truncate (- (/ *window-height* 2) (/ (sdl:char-height sdl:*default-font*) 2)))
                                                                                              :color sdl:*white*))
                                                                  ))))
         (init-game mission-id layout-id weather-id tod-id specific-faction-type faction-list))

       ;; initialize thread, that will calculate random-movement paths while the system waits for player input
       (let ((out *standard-output*))
         
         (handler-case (setf *path-thread* (bt:make-thread #'(lambda () (thread-path-loop out)) :name "Pathing thread"))
           (t ()
             (logger "MAIN: This system does not support multithreading!~%")))
       ;  (handler-case (setf *fov-thread* (bt:make-thread #'(lambda () (thread-fov-loop out)) :name "FOV thread"))
       ;    (t ()
       ;      (logger "MAIN: This system does not support multithreading!~%")))
         )
       (bt:condition-notify (path-cv *world*))
       (bt:condition-notify (fov-cv *world*))

       ;; let player enter his\her name
       (setf *current-window* (make-instance 'input-str-window 
                                             :init-input (options-player-name *options*)
                                             :header-str "Choose name"
                                             :main-str "Enter you name"
                                             :prompt-str "[Enter] Confirm"
                                             :all-func nil
                                             :no-escape t
                                             :input-check-func #'(lambda (char cur-str)
                                                                   (if (and (not (null char))
                                                                            (or (find (string-downcase (string char)) *char-list* :test #'string=)
                                                                                (char= char #\Space)
                                                                                (char= char #\-))
                                                                            (< (length cur-str) *max-player-name-length*))
                                                                       t
                                                                       nil))
                                             :final-check-func #'(lambda (full-input-str)
                                                                   (if (not (null full-input-str))
                                                                       t
                                                                       nil))
                                             ))
       (make-output *current-window*)
       (setf (options-player-name *options*) (run-window *current-window*))

       ;; set the same name for mimics if any
       (setf (name *player*) (options-player-name *options*))
       (setf (alive-name *player*) (name *player*))
       (when (mob-ability-p *player* +mob-abil-trinity-mimic+)
         (loop for mob-id in (mimic-id-list *player*)
               for mob = (get-mob-by-id mob-id)
               do
                  (setf (faction-name mob) (faction-name *player*))
                  (setf (name mob) (name *player*))))
       
       (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output :if-exists :supersede)
         (format file "~A" (create-options-file-string *options*)))
       
       (setf *current-window* (make-instance 'cell-window))
       (make-output *current-window*)
       ;; the game loop
       (game-loop)
     exit-tag
       ;; destroy the thread once the game is about to be exited
       (when (and *path-thread* (bt:thread-alive-p *path-thread*)) (bt:destroy-thread *path-thread*))
       ;(when (and *fov-thread* (bt:thread-alive-p *fov-thread*)) (bt:destroy-thread *fov-thread*))
     nil))
)

#+clisp
(defun cotd-exec ()
  (cffi:define-foreign-library sdl
    (:darwin (:or (:framework "SDL")
                 (:default "libSDL")))
    (:windows "SDL.dll")
    (:unix (:or "libSDL-1.2.so.0.7.2"
 	      "libSDL-1.2.so.0"
 	      "libSDL-1.2.so"
 	      "libSDL.so"
 	      "libSDL")))
  
  (cffi:use-foreign-library sdl)
  (setf *current-dir* *default-pathname-defaults*)
  (setf *cotd-release* t)

  (sdl:with-init ()  
    (cotd-main))
  (ext:quit))

#+sbcl
(defun cotd-exec ()
  (cffi:define-foreign-library sdl
    (:darwin (:or (:framework "SDL")
                 (:default "libSDL")))
    (:windows "SDL.dll")
    (:unix (:or "libSDL-1.2.so.0.7.2"
 	      "libSDL-1.2.so.0"
 	      "libSDL-1.2.so"
 	      "libSDL.so"
 	      "libSDL")))

  (cffi:use-foreign-library sdl)
  (setf *current-dir* *default-pathname-defaults*)
  (setf *cotd-release* t)
  
  (sdl:with-init ()  
    (cotd-main))
  (sb-ext:exit))

#+clisp
(defun make-exec ()
  (ext:saveinitmem "cotd" 
                   :quiet t :script t :init-function #'cotd-exec  
		   :executable t))

#+(and sbcl windows) 
(defun make-exec ()
  (sb-ext:save-lisp-and-die "cotd.exe" :toplevel #'cotd-exec :executable t :application-type :gui))

#+(and sbcl unix) 
(defun make-exec ()
  (sb-ext:save-lisp-and-die "cotd" :toplevel #'cotd-exec :executable t :compression t))
