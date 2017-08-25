(in-package :cotd)

(defun game-loop ()
  "Main game loop"
  (loop with turn-finished = t
        do
           ;;(format t "GAME-LOOP: Start loop~%")
           (setf turn-finished t)
           
           ;; check all available game events
           (loop for game-event-id in (game-events *world*)
                 for game-event = (get-game-event-by-id game-event-id)
                 when (and (not (disabled game-event))
                           (funcall (on-check game-event) *world*))
                   do
                      (funcall (on-trigger game-event) *world*))

           ;; we need this for events to get triggered only once  
           (setf (turn-finished *world*) nil)
           
           ;; iterate through all the mobs
           ;; those who are not dead and have cur-ap > 0 can make a move
           (loop for mob across *mobs* do
             
             ;(format t "MOB ~A [~A] check-dead = ~A, cur-ap = ~A~%" (name mob) (id mob) (check-dead mob) (cur-ap mob))
             (unless (check-dead mob)    
               (when (> (cur-ap mob) 0)
                 (setf turn-finished nil)
                 (setf (made-turn mob) nil)
                 (set-message-this-turn nil)
                 (setf (motion-set-p mob) nil)
                 (ai-function mob)
                 (when (get-message-this-turn) (add-message (format nil "~%")))
                 (setf (heard-sounds mob) nil)
                 
                 (when (eq mob *player*)
                   (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                   (update-map-area))
                 (update-visible-mobs mob)
                 
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
                   (on-tick mob)))))


           (bt:with-lock-held ((path-lock *world*))
             (when (and *path-thread* (bt:thread-alive-p *path-thread*))
               ;;(format t "THREAD: Destroy thread~%")
               ;;(setf (cur-mob-path *world*) 0)
               ;;(bt:condition-notify (path-cv *world*))
               (bt:destroy-thread *path-thread*)))

           ;(bt:with-lock-held ((fov-lock *world*))
           ;  (setf (cur-mob-fov *world*) 0)
           ;  (bt:condition-notify (fov-cv *world*)))
           
           (when turn-finished
             (incf (real-game-time *world*))
             (setf (turn-finished *world*) t)
             (loop for mob across *mobs* do
               (unless (check-dead mob)
                 ;; increase cur-ap by max-ap
                 (incf (cur-ap mob) (max-ap mob))))
             (loop for feature-id in (feature-id-list (level *world*))
                   for feature = (get-feature-by-id feature-id)
                   when (on-tick-func feature)
                   do
                      (funcall (on-tick-func feature) (level *world*) feature))
             (when (zerop (random 3))
               (setf (wind-dir (level *world*)) (1+ (random 9))))
             ))
  )
  
(defun init-game (layout-id weather-id tod-id faction-id)
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
  
  (create-world *world* layout-id weather-id tod-id faction-id)

  (setf (name *player*) "Player")

  (add-message (format nil "Welcome to City of the Damned. To view help, press '?'.~%"))

  (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
  )  

(defun main-menu ()
  (let ((join-heaven-item (cons "Join the Celestial Communion"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                      
                                      (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +player-faction-angels+))))))
        (join-legion-item (cons "Join the Pandemonium Hierarchy"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                      
                                      (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                     (nth (random (length weather-types)) weather-types)
                                                                     (nth (random (length tod-types)) tod-types)
                                                                     +player-faction-demons+))))))
        (join-chaplain-item (cons "Join the Military (as Chaplain)"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                        
                                        (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +player-faction-military-chaplain+))))))
        (join-scout-item (cons "Join the Military (as Scout)"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                     
                                     (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                    (nth (random (length weather-types)) weather-types)
                                                                    (nth (random (length tod-types)) tod-types)
                                                                    +player-faction-military-scout+))))))
        (join-thief-item (cons "Join as the Thief"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                     
                                     (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                    (nth (random (length weather-types)) weather-types)
                                                                    +tod-type-evening+
                                                                    +player-faction-thief+))))))
        (join-satanist-item (cons "Join the Satanists"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                        
                                        (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +player-faction-satanist+))))))
        (join-church-item (cons "Join the Church"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                        
                                        (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                       (nth (random (length weather-types)) weather-types)
                                                                       (nth (random (length tod-types)) tod-types)
                                                                       +player-faction-church+))))))
        (custom-scenario-item (cons "Custom scenario"
                                    #'(lambda (n)
                                        (declare (ignore n))
                                        (setf *current-window* (make-instance 'custom-scenario-window
                                                                              :layout-list (get-all-scenario-features-by-type +scenario-feature-city-layout+ (not *cotd-release*))
                                                                              :weather-list (get-all-scenario-features-by-type +scenario-feature-weather+ (not *cotd-release*))
                                                                              :tod-list (get-all-scenario-features-by-type +scenario-feature-time-of-day+ (not *cotd-release*))
                                                                              :player-faction-list (get-all-scenario-features-by-type +scenario-feature-player-faction+ (not *cotd-release*))))
                                        (setf (menu-items *current-window*) (populate-custom-scenario-win-menu *current-window* (cur-step *current-window*)))
                                        (make-output *current-window*)
                                        (multiple-value-bind (layout-id weather-id tod-id faction-id) (run-window *current-window*)
                                          (when (and layout-id weather-id tod-id faction-id)
                                            (return-from main-menu (values layout-id weather-id tod-id faction-id)))))))
        (highscores-item (cons "High Scores"
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
                                      (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))
                                  
                                  (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                 (nth (random (length weather-types)) weather-types)
                                                                 (nth (random (length tod-types)) tod-types)
                                                                 +player-faction-player+))))))
        (test-level-item (cons "Test level"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (return-from main-menu (values +city-layout-test+
                                                                  +weather-type-clear+
                                                                  +tod-type-night+
                                                                  +player-faction-test+))))))
    (if *cotd-release*
      (progn
        (setf *current-window* (make-instance 'start-game-window 
                                              :menu-items (list (car join-heaven-item) (car join-legion-item) (car join-chaplain-item) (car join-scout-item) (car join-thief-item) (car join-satanist-item) (car join-church-item)
                                                                (car custom-scenario-item) (car highscores-item) (car help-item) (car exit-item))
                                              :menu-funcs (list (cdr join-heaven-item) (cdr join-legion-item) (cdr join-chaplain-item) (cdr join-scout-item) (cdr join-thief-item) (cdr join-satanist-item) (cdr join-church-item)
                                                                (cdr custom-scenario-item) (cdr highscores-item) (cdr help-item) (cdr exit-item)))))
      (progn
        (setf *current-window* (make-instance 'start-game-window 
                                              :menu-items (list (car join-heaven-item) (car join-legion-item) (car join-chaplain-item) (car join-scout-item) (car join-thief-item) (car join-satanist-item) (car join-church-item)
                                                                (car custom-scenario-item) (car all-see-item) (car test-level-item)
                                                                (car highscores-item) (car help-item) (car exit-item))
                                              :menu-funcs (list (cdr join-heaven-item) (cdr join-legion-item) (cdr join-chaplain-item) (cdr join-scout-item) (cdr join-thief-item) (cdr join-satanist-item) (cdr join-church-item)
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
        ((equal (options-font *options*) 'font-8x13) (sdl:initialise-default-font sdl:*font-8x13*))
        (t (sdl:initialise-default-font sdl:*font-6x13*)))
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

      (setf *window-width* (+ 300 (+ 30 (* *glyph-w* *max-x-view*))) 
            *window-height* (+ 30 (* *glyph-h* *max-y-view*) *msg-box-window-height* (sdl:char-height sdl:*default-font*)))

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
       (multiple-value-bind (layout-id weather-id tod-id faction-id) (main-menu)
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
         (init-game layout-id weather-id tod-id faction-id))

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
       (setf (name *player*) (options-player-name *options*))
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
