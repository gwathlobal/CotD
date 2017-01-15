(in-package :cotd)

(defun game-loop ()
  "Main game loop"
  (loop do

    ;; check all available game events
    (loop for game-event-id in (game-events *world*)
          for game-event = (get-game-event-by-id game-event-id)
          when (and (not (disabled game-event))
                    (funcall (on-check game-event) *world*))
            do
               (funcall (on-trigger game-event) *world*))
    
    ;; iterate through all the mobs
    ;; those who are not dead and have the delay of 0 can make a move
    (loop for mob being the hash-values in *mobs-hash* do
      (unless (check-dead mob)
        
        (if (> (action-delay mob) 0)
          (decf (action-delay mob))
          (progn
            (ai-function mob)))
        (when (= (mod *global-game-time* +normal-ap+) 0)
          (on-tick mob))))
    
    (incf *global-game-time*)))
  
(defun init-game (menu-result)
  (clrhash *mobs-hash*)
  (clrhash *lvl-features*)
  
  (setf *global-game-time* 0)
  (setf *message-box* nil)
  
  (setf *cur-angel-names* (copy-list *init-angel-names*))
  (setf *cur-demon-names* (copy-list *init-demon-names*))

  (setf *update-screen-closure* #'(lambda () (make-output *current-window*)
				    ))

  (cond
    ((or (eql menu-result 'city-all-see) (eql menu-result 'test-level-all-see)) (progn
                                                                                  (setf *world* (make-instance 'world))
                                                                                  (setf *player* (make-instance 'player :mob-type +mob-type-player+))))
    ((eql menu-result 'test-level) (progn
                                     (setf *world* (make-instance 'world))
                                     (setf *player* (make-instance 'player :mob-type +mob-type-human+))))
    ((eql menu-result 'join-heavens) (progn
                                      (setf *world* (make-instance 'world-for-angels)) 
                                      (setf *player* (make-instance 'player :mob-type +mob-type-angel+))))
    ((eql menu-result 'join-hell) (progn
                                    (setf *world* (make-instance 'world-for-demons)) 
                                    (setf *player* (make-instance 'player :mob-type +mob-type-imp+)))))
  
  (create-world *world* menu-result)

  (cond
    ((eql menu-result 'join-heavens) (loop with x = (random *max-x-level*)
                                           with y = (random *max-y-level*)
                                           until (and (not (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10))))
                                                      (not (get-mob-* (level *world*) x y))
                                                      (not (get-terrain-type-trait (get-terrain-* (level *world*) x y) +terrain-trait-blocks-move+)))
                                           finally (setf (x *player*) x (y *player*) y)
                                                   (add-mob-to-level-list (level *world*) *player*)
                                           do
                                              (setf x (random *max-x-level*))
                                              (setf y (random *max-y-level*))))
    ((eql menu-result 'join-hell) (loop with x = (random *max-x-level*)
                                        with y = (random *max-y-level*)
                                        until (and (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10)))
                                                   (not (get-mob-* (level *world*) x y))
                                                   (not (get-terrain-type-trait (get-terrain-* (level *world*) x y) +terrain-trait-blocks-move+)))
                                        finally (setf (x *player*) x (y *player*) y)
                                                (add-mob-to-level-list (level *world*) *player*)
                                        do
                                           (setf x (random *max-x-level*))
                                           (setf y (random *max-y-level*))))
    ((eql menu-result 'city-all-see) (progn (setf (x *player*) 1 (y *player*) 1)
                                            (add-mob-to-level-list (level *world*) *player*))))
  
  (setf (name *player*) "Player")

  (add-message (format nil "Welcome to City of the Damned. To view help, press '?'.~%"))
  )  

(defun main-menu ()

  (if *cotd-release*
    (progn
      (setf *current-window* (make-instance 'start-game-window 
                                            :menu-items (list "Join the Heavenly Forces" "Join the Legions of Hell" "Help" "Exit")
                                            :menu-funcs (list #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'join-heavens))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'join-hell))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'help-window)))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (funcall *quit-func*))))))
    (progn
      (setf *current-window* (make-instance 'start-game-window 
                                            :menu-items (list "Join the Heavenly Forces" "Join the Legions of Hell" "City with all-seeing" "Test level" "Test level with all-seeing" "Help" "Exit")
                                            :menu-funcs (list #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'join-heavens))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'join-hell))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'city-all-see))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'test-level))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (return-from main-menu 'test-level-all-see))
                                                              #'(lambda (n) 
                                                                  (declare (ignore n))
                                                                  (setf *current-window* (make-instance 'help-window)))
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

      (setf *window-width* (+ 200 50 (+ 30 (* *glyph-w* *max-x-view*))) 
            *window-height* (+ 30 (* *glyph-h* *max-y-view*) *msg-box-window-height*))
      
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
  
    (tagbody
       (setf *quit-func* #'(lambda () (go exit-tag)))
       (let ((menu-result (main-menu)))
         (init-game menu-result))
       (setf *current-window* (make-instance 'cell-window))
       (make-output *current-window*)
       ;; the game loop
       (game-loop)
       exit-tag nil))
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

#+sbcl
(defun make-exec ()
  (sb-ext:save-lisp-and-die "cotd" :toplevel #'cotd-exec :executable t :application-type :gui))
