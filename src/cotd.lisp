(in-package :cotd)

(defun game-loop ()
  "Main game loop"
  (loop with turn-finished = t
        do
           (setf turn-finished t)
           
           ;; check all available game events
           (loop for game-event-id in (game-events *world*)
                 for game-event = (get-game-event-by-id game-event-id)
                 when (and (not (disabled game-event))
                           (funcall (on-check game-event) *world*))
                   do
                      (funcall (on-trigger game-event) *world*))

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
                 (ai-function mob)
                 (when (get-message-this-turn) (add-message (format nil "~%")))

                 (when (eq mob *player*)
                   (update-visible-area (level *world*) (x *player*) (y *player*))
                   (update-map-area))
                 
                 ;; process animations for this turn if any
                 (when (animation-queue *world*)
                   
                   (loop for animation in (animation-queue *world*)
                         do
                            (play-animation animation))
                   (sdl:update-display)
                   (sdl-cffi::sdl-delay 100)
                   (setf (animation-queue *world*) nil)
                   (update-map-area)))))
                     
           (bt:with-lock-held ((path-lock *world*))
             (setf (cur-mob-path *world*) 0)
             (bt:condition-notify (path-cv *world*)))
           
           
           (when turn-finished
             (incf (real-game-time *world*))
             (setf (turn-finished *world*) t)
             (loop for mob across *mobs* do
               (unless (check-dead mob)
                 (on-tick mob)
                 (when (> (cur-ap mob) 0)
                   (setf (made-turn mob) nil))))
             ;(incf (game-time *world*))
             ))
  )
  
(defun init-game (layout-id weather-id faction-id)
  (setf *mobs* (make-array (list 0) :adjustable t))
  (setf *lvl-features* (make-array (list 0) :adjustable t))
  (setf *items* (make-array (list 0) :adjustable t))
  
  (clear-message-list)
  
  (setf *cur-angel-names* (copy-list *init-angel-names*))
  (setf *cur-demon-names* (copy-list *init-demon-names*))

  (setf *update-screen-closure* #'(lambda () (make-output *current-window*)
				    ))

  (setf *world* (make-instance 'world))
  
  (create-world *world* layout-id weather-id faction-id)

  (setf (name *player*) "Player")

  (add-message (format nil "Welcome to City of the Damned. To view help, press '?'.~%"))
  )  

(defun main-menu ()

  (if *cotd-release*
    (progn
      (setf *current-window* (make-instance 'start-game-window 
                                            :menu-items (list "Join the Heavenly Forces" "Join the Legions of Hell" "Join the Military (as Chaplain)" "Join the Military (as Scout)" "Custom scenario" "Help" "Exit")
                                            :menu-funcs (list #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-angels+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-demons+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-military-chaplain+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-military-scout+))))
                                                              #'(lambda (n)
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'custom-scenario-window
                                                                                                        :layout-list (get-all-scenario-features-by-type +scenario-feature-city-layout+ (not *cotd-release*))
                                                                                                        :weather-list (get-all-scenario-features-by-type +scenario-feature-weather+ (not *cotd-release*))
                                                                                                        :player-faction-list (get-all-scenario-features-by-type +scenario-feature-player-faction+ (not *cotd-release*))))
                                                                  (setf (menu-items *current-window*) (populate-custom-scenario-win-menu *current-window* (cur-step *current-window*)))
                                                                  (make-output *current-window*)
                                                                  (multiple-value-bind (layout-id weather-id faction-id) (run-window *current-window*)
                                                                    (when (and layout-id weather-id faction-id)
                                                                      (return-from main-menu (values layout-id weather-id faction-id)))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'help-window))
                                                                  (make-output *current-window*)
                                                                  (run-window *current-window*))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (funcall *quit-func*))))))
    (progn
      (setf *current-window* (make-instance 'start-game-window 
                                            :menu-items (list "Join the Heavenly Forces" "Join the Legions of Hell" "Join the Military (as Chaplain)" "Join the Military (as Scout)" "Custom scenario" "City with all-seeing"
                                                              "Test level" "Help" "Exit")
                                            :menu-funcs (list #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-angels+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-demons+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-military-chaplain+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-military-scout+))))
                                                              #'(lambda (n)
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'custom-scenario-window
                                                                                                        :layout-list (get-all-scenario-features-by-type +scenario-feature-city-layout+ (not *cotd-release*))
                                                                                                        :weather-list (get-all-scenario-features-by-type +scenario-feature-weather+ (not *cotd-release*))
                                                                                                        :player-faction-list (get-all-scenario-features-by-type +scenario-feature-player-faction+ (not *cotd-release*))))
                                                                  (setf (menu-items *current-window*) (populate-custom-scenario-win-menu *current-window* (cur-step *current-window*)))
                                                                  (make-output *current-window*)
                                                                  (multiple-value-bind (layout-id weather-id faction-id) (run-window *current-window*)
                                                                    (when (and layout-id weather-id faction-id)
                                                                      (return-from main-menu (values layout-id weather-id faction-id)))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                                                        (city-layouts (get-all-scenario-features-by-type +scenario-feature-city-layout+ nil)))

                                                                    (return-from main-menu (values (nth (random (length city-layouts)) city-layouts)
                                                                                                   (nth (random (length weather-types)) weather-types)
                                                                                                   +player-faction-player+))))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu (values +city-layout-test+
                                                                                                 +weather-type-clear+
                                                                                                 +player-faction-test+)))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'help-window))
                                                                  (make-output *current-window*)
                                                                  (run-window *current-window*))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (funcall *quit-func*)))))))
  
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
            (loop for s-expr = (read file nil) 
                  while s-expr do
                    (read-options s-expr *options*))))   
        (progn 
          (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output)
            (format file "~%;; TILES: Changes the size of tiles~%;; Format (tiles <size>)~%;; <size> can be (without quotes) \"large\" or \"small\"~%(tiles large)~%")
            (format file "~%;; FONT: Changes the size of text font~%;; Format (font <font type>)~%;; <font type> can be (without quotes) \"font-6x13\" or \"font-8x13\"~%(font font-6x13)")))
        )
      
      ;; set parameters depending on options
      ;; tiles
      (cond
        ((equal (options-tiles *options*) 'small) (setf *glyph-w* 10 *glyph-h* 10 tiles-path "data/font_small.bmp"))
        (t (setf *glyph-w* 15 *glyph-h* 15 tiles-path "data/font_large.bmp")))
      ;; font
      (cond
        ((equal (options-font *options*) 'font-8x13) (sdl:initialise-default-font sdl:*font-8x13*))
        (t (sdl:initialise-default-font sdl:*font-6x13*)))
      

      (setf *msg-box-window-height* (* (sdl:get-font-height) 8))
      (setf *random-state* (make-random-state t))

      (setf *window-width* (+ 200 80 (+ 30 (* *glyph-w* *max-x-view*))) 
            *window-height* (+ 30 (* *glyph-h* *max-y-view*) *msg-box-window-height*))

      (when (<= *window-height* 384)
        (incf *window-height* (+ (* 4 (sdl:char-height sdl:*default-font*)) 0)))
      
      (sdl:window *window-width* *window-height*
                  :title-caption "The City of the Damned"
                  :icon-caption "The City of the Damned")
      (sdl:enable-key-repeat nil nil)
      (sdl:enable-unicode)
      
      (setf *temp-rect* (sdl::rectangle-from-edges-* 0 0 *glyph-w* *glyph-h*))
      
      
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
       (multiple-value-bind (layout-id weather-id faction-id) (main-menu)
         (init-game layout-id weather-id faction-id))

       ;; initialize thread, that will calculate random-movement paths while the system waits for player input
       (let ((out *standard-output*))
         (handler-case (setf *path-thread* (bt:make-thread #'(lambda () (thread-path-loop out)) :name "Pathing thread"))
           (t ()
             (logger "MAIN: This system does not support multithreading!~%"))))
       (bt:condition-notify (path-cv *world*))
       
       (setf *current-window* (make-instance 'cell-window))
       (make-output *current-window*)
       ;; the game loop
       (game-loop)
     exit-tag
       ;; destroy the thread once the game is about to be exited
       (when (and *path-thread* (bt:thread-alive-p *path-thread*)) (bt:destroy-thread *path-thread*))
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
  (sb-ext:save-lisp-and-die "cotd" :toplevel #'cotd-exec :executable t))
