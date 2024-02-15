(in-package :cotd-sdl)

(defun game-loop ()
  "Main game loop"
  (loop with turn-finished = t
        do
           ;;(format t "GAME-LOOP: Start loop~%")
           (setf turn-finished t)
           (log:info "~%REAL-GAME-TURN: ~A~%" (player-game-time (level *world*)))

           ;; check for the player's win conditions first
           (when (and *player*
                      (find (loyal-faction *player*) (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level *world*)))))
                            :key #'(lambda (a)
                                     (first a)))
                      (funcall (on-check (get-game-event-by-id (second (find (loyal-faction *player*) (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level *world*)))))
                                                                             :key #'(lambda (a)
                                                                                      (first a))))))
                               *world*))
             (funcall (on-trigger (get-game-event-by-id (second (find (loyal-faction *player*) (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level *world*)))))
                                                                             :key #'(lambda (a)
                                                                                      (first a))))))
                      *world*))
           
           ;; check all available game events
           (loop for game-event-id of-type fixnum in (game-events (level *world*))
                 for game-event of-type game-event = (get-game-event-by-id game-event-id)
                 when (and (not (disabled game-event))
                           (funcall (on-check game-event) *world*))
                   do
                      (funcall (on-trigger game-event) *world*))

           ;; we need this for events to get triggered only once  
           (setf (turn-finished *world*) nil)

           (process-animations-on-level (level *world*))

           (when (or (check-dead *player*)
                     (master-mob-id *player*)
                     (player-outside-level *player*))
             (unless (player-outside-level *player*)
               (when (master-mob-id *player*)
                 (setf (x *player*) (x (get-mob-by-id (master-mob-id *player*))) (y *player*) (y (get-mob-by-id (master-mob-id *player*))) (z *player*) (z (get-mob-by-id (master-mob-id *player*)))))
               (update-visible-mobs *player*)
               (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*)))
             
             (make-output *current-window*)
             (pause-for-poll))
           
           ;; iterate through all the mobs
           ;; those who are not dead and have cur-ap > 0 can make a move
           (loop for mob-id in (mob-id-list (level *world*))
                 for mob = (get-mob-by-id mob-id)
                 do
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

               ;;(format t "~%TIME-ELAPSED MOB ~A [~A] after AI func finished: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
               (update-visible-mobs mob)
               ;;(format t "~%TIME-ELAPSED AI ~A [~A] after UPDATE-VISIBLE-MOBS: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
               (when (eq mob *player*)
                 (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                 (update-map-area *start-map-x* 0)
                 )
               ;;(format t "~%TIME-ELAPSED AI ~A [~A] after players' UPDATE-VISIBLE-MOBS (if any): ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
               
               ;; process animations for this turn if any
               (process-animations-on-level (level *world*))
               
               (when (<= (cur-ap mob) 0)
                 ;;(format t "~%TIME-ELAPSED AI ~A [~A] before ON-TICK: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
                 (on-tick mob)
                 ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ON-TICK: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
				 )

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
                            ;(loop for merged-id in (merged-id-list mob)
                            ;      for merged-mob = (get-mob-by-id merged-id)
                            ;      when (and (not (check-dead merged-mob))
                            ;                (and (mob-ability-p merged-mob +mob-abil-angel+)
                            ;                     (not (mob-ability-p merged-mob +mob-abil-animal+))))
                            ;        do
                            ;           (incf result))
                       finally (when (/= (total-angels (level *world*)) result)
                                 (error (format nil "FAILED!!! TOTAL ANGELS = ~A, ACTUAL ANGELS ALIVE = ~A" (total-angels (level *world*)) result)))
                       )
                 )

               ))
                      
           (bt:with-lock-held ((path-lock *world*))
             (when (and *path-thread* (bt:thread-alive-p *path-thread*))
               (bt:destroy-thread *path-thread*)))
           
           (when turn-finished
             (incf (player-game-time (level *world*)))
             (when (check-dead *player*)
               (incf (world-game-time *world*) +normal-ap+))
             (setf (turn-finished *world*) t)
             (set-message-this-turn nil)
             (loop  for mob-id in (mob-id-list (level *world*))
                    for mob = (get-mob-by-id mob-id)
                    do
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
  
(defun init-game (mission world-sector)
  (setf *mobs* (make-array (list 0) :adjustable t))
  (setf *lvl-features* (make-array (list 0) :adjustable t))
  (setf *items* (make-array (list 0) :adjustable t))
  
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

  (let ((sector-level-gen-func (sector-level-gen-func (get-world-sector-type-by-id (wtype world-sector))))
        (level-template-pre-process-func-list ())
        (overall-post-process-func-list ())
        (terrain-post-process-func-list ()))

    ;; add all funcs from world sector
    (let ((world-sector-type (get-world-sector-type-by-id (wtype world-sector))))
      (when (template-level-gen-func world-sector-type)
        (setf level-template-pre-process-func-list (append level-template-pre-process-func-list
                                                           (list (template-level-gen-func world-sector-type)))))
      (when (overall-post-process-func-list world-sector-type)
        (setf overall-post-process-func-list (append overall-post-process-func-list
                                                     (funcall (overall-post-process-func-list world-sector-type)))))
      (when (terrain-post-process-func-list world-sector-type)
        (setf terrain-post-process-func-list (append terrain-post-process-func-list
                                                     (funcall (terrain-post-process-func-list world-sector-type)))))
      )
    
    ;; add all funcs from level-modifiers
    ;; sort them by level-modifier priority, to ensure that all template-level reservations are made in the right order
    (loop with lm-controlled-by = (list (get-level-modifier-by-id (controlled-by world-sector)))
          with lm-feats = (loop for (lm-feat-id) in (feats world-sector)
                                collect (get-level-modifier-by-id lm-feat-id))
          with lm-item = (loop for lm-item-id in (items world-sector)
                               collect (get-level-modifier-by-id lm-item-id))
          with sorted-lvl-mod-list = (stable-sort (append lm-controlled-by lm-feats lm-item)
                                                  #'(lambda (a b)
                                                      (if (< (priority a) (priority b))
                                                        t
                                                        nil)))
          for lvl-mod in sorted-lvl-mod-list
          do
             (when (template-level-gen-func lvl-mod)
               (setf level-template-pre-process-func-list (append level-template-pre-process-func-list
                                                                  (list (template-level-gen-func lvl-mod)))))
             (when (overall-post-process-func-list lvl-mod)
               (setf overall-post-process-func-list (append overall-post-process-func-list
                                                            (funcall (overall-post-process-func-list lvl-mod)))))
             (when (terrain-post-process-func-list lvl-mod)
               (setf terrain-post-process-func-list (append terrain-post-process-func-list
                                                            (funcall (terrain-post-process-func-list lvl-mod))))))   

    ;; add all level modifiers from the mission
    (loop for lvl-mod-id in (level-modifier-list mission)
          for lvl-mod = (get-level-modifier-by-id lvl-mod-id)
          do
             (when (template-level-gen-func lvl-mod)
               (setf level-template-pre-process-func-list (append level-template-pre-process-func-list
                                                                  (list (template-level-gen-func lvl-mod)))))
             (when (overall-post-process-func-list lvl-mod)
               (setf overall-post-process-func-list (append overall-post-process-func-list
                                                            (funcall (overall-post-process-func-list lvl-mod)))))
             (when (terrain-post-process-func-list lvl-mod)
               (setf terrain-post-process-func-list (append terrain-post-process-func-list
                                                            (funcall (terrain-post-process-func-list lvl-mod))))))
    
    ;; add all funcs from mission
    (let ((mission-type (get-mission-type-by-id (mission-type-id mission))))
      (when (template-level-gen-func mission-type)
        (setf level-template-pre-process-func-list (append level-template-pre-process-func-list
                                                           (list (template-level-gen-func mission-type)))))
      (when (overall-post-process-func-list mission-type)
        (setf overall-post-process-func-list (append overall-post-process-func-list
                                                     (funcall (overall-post-process-func-list mission-type)))))
      (when (terrain-post-process-func-list mission-type)
        (setf terrain-post-process-func-list (append terrain-post-process-func-list
                                                     (funcall (terrain-post-process-func-list mission-type)))))
      )

    (generate-level-from-sector sector-level-gen-func
                                :level-template-pre-process-func-list level-template-pre-process-func-list
                                :overall-post-process-func-list overall-post-process-func-list
                                :terrain-level-post-process-func-list terrain-post-process-func-list
                                :world-sector world-sector
                                :mission mission
                                :world *world*)
    )

  (when (player-specific-faction mission)
    (setf *previous-scenario* (list (mission-type-id mission) (player-specific-faction mission))))

  (clear-message-list (level/full-message-box (level *world*)))
  (clear-message-list (level/small-message-box (level *world*)))
  
  ;;(format t "FACTION-LIST ~A~%" faction-list)
  
  (setf (name *player*) "Player")

  (add-message (format nil "This is a "))
  (add-message (format nil "~(~A~)" (name mission)) sdl:*yellow*)
  (add-message (format nil " in "))
  (add-message (format nil "~(~A~)" (name (get-world-sector-type-by-id (wtype world-sector)))) sdl:*yellow*)
  (add-message (format nil "!~%~%To view help, press '?'.~%To view your current objective, press 'j'.~%"))

  (when (player-outside-level *player*)
    (add-message (format nil "~%Your arrival here is delayed, please wait!~%")))

  )

(defun main-menu ()
  (stop-path-thread)
  (with-slots (game-slot-id) *game-manager*
    (setf game-slot-id nil)) 
  (setf *current-window* (make-instance 'main-menu-window))
  (make-output *current-window*)
  (run-window *current-window*))

(defun cotd-init ()
  (setf yason:*parse-object-key-fn* #'str-to-keyword)
  (setf yason:*symbol-key-encoder* #'yason:encode-symbol-as-lowercase)
  (setf yason:*symbol-encoder* #'yason:encode-symbol-as-lowercase)
  
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
            (t (c)
              (log:error "OPTIONS.CFG: Error occured while reading the options.cfg: ~A. Overwriting with defaults.~%" c)
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
    (setf *highscores* (make-instance 'highscores-table))
    (load-highscores-from-disk)
    (truncate-highscores *highscores*)
        
    (setf *msg-box-window-height* (* (sdl:get-font-height) 8))
    (setf *random-state* (make-random-state t))
    
    (setf *window-width* (+ 540 (+ 30 (* *glyph-w* *max-x-view*))) 
          *window-height* (+ 30 (* *glyph-h* *max-y-view*) *msg-box-window-height* (* 3 (sdl:char-height sdl:*default-font*))))
    
    (when (<= *window-height* 384)
      (incf *window-height* (+ (* 6 (sdl:char-height sdl:*default-font*)) 0)))
    
    (sdl:window *window-width* *window-height*
                :title-caption "The City of the Damned"
                :icon-caption "The City of the Damned")
    (sdl:enable-key-repeat nil nil)
    (sdl:enable-unicode)
    
    (setf *temp-rect* (sdl::rectangle-from-edges-* 0 0 *glyph-w* *glyph-h*))
    
    
    (log:info "current-dir = ~A" *current-dir*)
    (log:info "path = ~A" (sdl:create-path tiles-path *current-dir*))
    
    (setf *glyph-front* (sdl:load-image (sdl:create-path tiles-path *current-dir*) 
                                        :color-key sdl:*white*))
    (setf *glyph-temp* (sdl:create-surface *glyph-w* *glyph-h* :color-key sdl:*black*))
    
    (setf *path-thread* nil)
    (setf *previous-scenario* nil)
    (setf *game-manager* (make-instance 'game-manager))
    (game-state-start->init)))

(defun stop-path-thread ()
  (when (and *path-thread* (bt:thread-alive-p *path-thread*))
    (bt:destroy-thread *path-thread*)))

(defun enter-player-name ()
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
  
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
  (setf *player-name* (options-player-name *options*)))

(defun prepare-game-scenario (mission world-sector)
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
  (init-game mission world-sector)

   ;; initialize thread, that will calculate random-movement paths while the system waits for player input
  (handler-case (setf *path-thread* (bt:make-thread #'(lambda () (thread-path-loop)) :name "Pathing thread"))
    (t (c)
      (log:error "MAIN: This system does not support multithreading! Error: ~A~%" c)))
  
  (bt:condition-notify (path-cv *world*))
  
  ;; set the same name for mimics if any
  (setf (name *player*) *player-name*)
  (setf (alive-name *player*) (name *player*))
  (when (mob-ability-p *player* +mob-abil-trinity-mimic+)
    (loop for mob-id in (mimic-id-list *player*)
          for mob = (get-mob-by-id mob-id)
          do
             (setf (name mob) (name *player*))
             (setf (alive-name mob) (alive-name *player*))))
  
  (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output :if-exists :supersede)
    (format file "~A" (create-options-file-string *options*))))

(defun scenario-game-loop ()
  (setf *current-window* (make-instance 'cell-window))
  (make-output *current-window*)
  ;; the game loop
  (game-loop))

(defun campaign-game-loop ()
  (setf *current-window* (make-instance 'campaign-window :cur-mode (case (game-manager/game-state *game-manager*)
                                                                     (:game-state-campaign-init :campaign-window-map-mode)
                                                                     (t (if (and (zerop (message-list-length (world/mission-message-box *world*)))
                                                                                 (zerop (message-list-length (world/event-message-box *world*)))
                                                                                 (zerop (message-list-length (world/effect-message-box *world*))))
                                                                          :campaign-window-mission-mode
                                                                          :campaign-window-status-mode)))
                                                         :reveal-lair (if (or (eq (get-general-faction-from-specific (world/player-specific-faction *world*)) +faction-type-demons+)
                                                                              (find-campaign-effects-by-id *world* :campaign-effect-satanist-lair-visible))
                                                                        t
                                                                        nil)))
  (make-output *current-window*)
  (multiple-value-bind (mission world-sector) (run-window *current-window*)
    (when (and mission world-sector)
      (setf (player-specific-faction mission) (world/player-specific-faction *world*))
      (setf (player-lvl-mod-placement-id mission) (second (find (player-specific-faction mission) (scenario-faction-list (get-mission-type-by-id (mission-type-id mission)))
                                                                :key #'(lambda (a) (first a)))))
      (game-state-campaign-map->campaign-scenario)

      (prepare-game-scenario mission world-sector)
      (return-from campaign-game-loop (values world-sector mission)))))

(defun process-post-scenario ()
  (with-slots (level world-map random-number) *world*
    (let ((present-missions (world/present-missions *world*)))
           
      ;; add AI commands before mission results are processed
      (loop for faction-type in (list +faction-type-demons+ +faction-type-angels+ +faction-type-military+ +faction-type-satanists+ +faction-type-church+ +faction-type-eater+) do
        (when (not (gethash faction-type (world/commands *world*)))
          (let ((command-hash (make-hash-table))
                (selected-command nil))

            ;; sort commands by priority
            (loop for command being the hash-values in *campaign-commands*
                  when (and (eq (campaign-command/faction-type command) faction-type)
                            (funcall (campaign-command/on-check-func command) *world* command))
                    do
                       (push command (gethash (campaign-command/priority command) command-hash)))

            ;; select a random command out of the topmost priority list
            (loop for priority from 10 downto 0
                  for command-list = (gethash priority command-hash)
                  when command-list
                    do
                       (setf selected-command (nth (random (length command-list)) command-list))
                       (loop-finish))
            
            (setf (gethash faction-type (world/commands *world*))
                  (list :command (campaign-command/id selected-command) :cd (campaign-command/cd selected-command))))))

      ;; clear results
      (setf (world/post-mission-results *world*) ())
      
      ;; clear the situation report
      (clear-message-list (world/mission-message-box *world*))
      (clear-message-list (world/event-message-box *world*))
      (clear-message-list (world/effect-message-box *world*))

      ;; advance one day forward
      (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time *world*))
        (setf (world-game-time *world*) (set-current-date-time year month (1+ day) hour min sec)))
      
      ;; add date to the top
      (add-message (format nil " === ~A ===~%~%" (show-date-time-ymd (world-game-time *world*))) sdl:*white* `(,(world/mission-message-box *world*)))
      
      ;; process missions 
      (loop with mission-result = nil
            for mission in present-missions
            for world-sector = (aref (cells (world-map *world*)) (x mission) (y mission))
            do
               (if (and level (level/mission-result level) (mission level)
                        (eq mission (mission level)))
                 ;; where the player was present...
                 (progn
                   (setf mission-result (level/mission-result level)))
                 ;; ...and where the player was absent
                 (progn
                   (setf mission-result (auto-resolve-mission *world* mission))
                   
                   ;; increase world flesh points
                   (when (or (eq (getf mission-result :mission-result) :game-over-demons-won)
                             (eq (getf mission-result :mission-result) :game-over-satanists-won))
                     (setf (getf mission-result :flesh-points) (truncate (+ 75 (random 50)) 10)))))
               
               (case (getf mission-result :mission-result)
                 (:game-over-angels-won (progn
                                          (add-message (format nil " - The angels were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*)))))
                 (:game-over-church-won (progn
                                          (add-message (format nil " - The priests were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*)))))
                 (:game-over-military-won (progn
                                            (add-message (format nil " - The military were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*)))))
                 (:game-over-demons-won (progn
                                          (add-message (format nil " - The demons were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*)))))
                 (:game-over-satanists-won (progn
                                             (add-message (format nil " - The satanists were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*)))))
                 (:game-over-eater-won (progn
                                         (add-message (format nil " - The primordials were victorious during a ") sdl:*white* `(,(world/mission-message-box *world*))))))
               
               (add-message (format nil "~(~A~)" (name mission)) sdl:*yellow* `(,(world/mission-message-box *world*)))
               (add-message (format nil " in ") sdl:*white* `(,(world/mission-message-box *world*)))
               (add-message (format nil "~(~A~)" (name world-sector)) sdl:*yellow* `(,(world/mission-message-box *world*)))
               (add-message (format nil ".") sdl:*white* `(,(world/mission-message-box *world*)))
               
               (loop with campaign-mission-result = (find (getf mission-result :mission-result) (mission-type/campaign-result (get-mission-type-by-id (mission-type-id mission)))
                                                          :key #'(lambda (a) (first a)))
                     for transform-sector-func in (second campaign-mission-result) do
                       (funcall transform-sector-func world-map (x mission) (y mission)))

               (add-message (format nil "~%") sdl:*white* `(,(world/mission-message-box *world*)))
               
               ;; sum all flesh points
               (unless (getf (world/post-mission-results *world*) :flesh-points)
                 (setf (getf (world/post-mission-results *world*) :flesh-points) 0))
               (when (getf mission-result :flesh-points)
                 (incf (getf (world/post-mission-results *world*) :flesh-points) (getf mission-result :flesh-points)))
            )

      (loop for game-event-id in (game-events *world*)
            for game-event = (get-game-event-by-id game-event-id)
            when (and (not (disabled game-event))
                      (funcall (on-check game-event) *world*))
              do
                 (funcall (on-trigger game-event) *world*))
      
      (with-slots (campaign-effects) *world*
        (loop for campaign-effect in campaign-effects
              when (campaign-effect/cd campaign-effect)
                do
                   (decf (campaign-effect/cd campaign-effect))
                   (when (= (campaign-effect/cd campaign-effect) 0)
                     (remove-campaign-effect *world* campaign-effect))))

      (when (or (colored-txt-list (message-box-strings (world/event-message-box *world*)))
                (colored-txt-list (message-box-strings (world/effect-message-box *world*))))
        (add-message (format nil "~%") sdl:*white* `(,(world/mission-message-box *world*))))

      (when (and (colored-txt-list (message-box-strings (world/event-message-box *world*)))
                 (colored-txt-list (message-box-strings (world/effect-message-box *world*))))
        (add-message (format nil "~%") sdl:*white* `(,(world/event-message-box *world*))))
      
      ;; reset all missions and regenerate them
      (reset-all-missions-on-world-map *world*)

      ;; regenerate transient feats
      (loop for x from 0 below (array-dimension (cells (world-map *world*)) 0) do
        (loop for y from 0 below (array-dimension (cells (world-map *world*)) 1) do
          (let ((world-sector (aref (cells (world-map *world*)) x y)))
            (regenerate-transient-feats-for-world-sector world-sector (world-map *world*)))))
      
      (generate-missions-on-world-map *world*))
    (setf random-number (random 100)))
  (game-state-post-scenario->campaign-map))

(defmacro handle-errors-to-ui (&body body)
  `(if *cotd-release*
     (handler-case
         (progn ,@body)
       (t (c)
         (stop-path-thread)
         (setf *cotd-logging* :log-option-all)
         (setf *cotd-log-level* :info)
         (setup-log)
         (log:error "~A" c)
         (setf *current-window* (make-instance 'display-msg-window
                                               :msg-line (format nil "ERROR: ~A" c)
                                               :w (truncate (* *window-width* 2/3))
                                               :prompt-line "[Esc] Exit"))
         (make-output *current-window*)
         (run-window *current-window*)
         (return-from cotd-main nil)))
     (progn ,@body)))

(defun cotd-main () 
  (in-package :cotd-sdl)
  (setup-log)
  (log:info "Start program")

  (sdl:with-init ()
    (handle-errors-to-ui
      (cotd-init)
      (tagbody
        (setf *quit-func* #'(lambda ()
                              (when (and *game-manager*
                                         *world*)
                                (case (game-manager/game-state *game-manager*)
                                  ((:game-state-custom-scenario) (save-game-to-disk :save-game-scenario :save-scenario))
                                  ((:game-state-campaign-scenario) (save-game-to-disk :save-game-campaign :save-scenario))
                                  ((:game-state-campaign-map :game-state-post-scenario) (save-game-to-disk :save-game-campaign :save-campaign))))
                              
                               (go quit-menu-tag)))
        (setf *start-func* #'(lambda () (go start-game-tag)))
        (cotd-sdl/websocket:start-client 32167 #'handle-server-messages)
        (game-state-init->menu)
       start-game-tag
         (loop while t do
           (case (game-manager/game-state *game-manager*)
             (:game-state-main-menu (main-menu))
             ((:game-state-custom-scenario) (scenario-game-loop))
             ((:game-state-campaign-map :game-state-campaign-init) (campaign-game-loop))
             ((:game-state-campaign-scenario) (scenario-game-loop))
             (:game-state-post-scenario (process-post-scenario))))
       quit-menu-tag
        (stop-path-thread)
        (cotd-sdl/websocket:close-client))
      (log:info "End program~%"))
    nil))

(defun setup-log ()
  (case *cotd-logging*
    (:log-option-all (log:config :sane :console :daily (merge-pathnames (make-pathname :name "log.txt") *current-dir*) :pattern "%D - %p (%c{1}) %m%n" *cotd-log-level*))
    (:log-option-file (log:config :sane :daily (merge-pathnames (make-pathname :name "log.txt") *current-dir*) :pattern "%D - %p (%c{1}) %m%n" *cotd-log-level*))
    (t (log:config :off))))

(defun handle-server-messages (message)
  (log:info "Received message from server: ~A" message)
  (log:info "Current window: ")
  (unless (null *current-window*)
    (let ((parsed-msg (yason:parse message)))
      (when (null parsed-msg)
        (log:error "Parsed message is empty.")
        (return-from handle-server-messages))
      
      (handle-server-message *current-window* parsed-msg))))

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
  (setf *cotd-logging* :log-option-none)
  (setf *cotd-log-level* :error)

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
  (setf *cotd-logging* :log-option-file)
  (setf *cotd-log-level* :error)
  
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
