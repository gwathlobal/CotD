(in-package :cotd)

(defun game-loop ()
  "Main game loop"
  (loop do
     
       (when (check-lose *world*)
	 (funcall *game-over-func*))
       
       (when (check-win *world*)
         (funcall *game-won-func*))
       
       ;;(format t "[T:~A] GLOBAL-TICK~%" *global-game-time*)
       
       (loop for mob being the hash-values in *mobs-hash* do
         (unless (check-dead mob)
           
           (if (> (action-delay mob) 0)
             (decf (action-delay mob))
             (progn
               ;;(format t "[T:~A] TICK~%" *global-game-time*)
               
                (ai-function mob)))
           (when (= (mod *global-game-time* +normal-ap+) 0)
             (on-tick mob))))
       
       (incf *global-game-time*)
        ))
  
(defun init-game (join-heaven)
  (clrhash *mobs-hash*)
  (clrhash *lvl-features*)
  
  (setf *global-game-time* 0)
  (setf *message-box* nil)
  
  (setf *cur-angel-names* (copy-list *init-angel-names*))
  (setf *cur-demon-names* (copy-list *init-demon-names*))

  (setf *update-screen-closure* #'(lambda () (make-output *current-window*)
				    ))
 
  (if join-heaven
    (progn
      (setf *world* (make-instance 'world-for-angels)) 
      (setf *player* (make-instance 'player :mob-type +mob-type-angel+)))
    (progn
      (setf *world* (make-instance 'world-for-demons)) 
      (setf *player* (make-instance 'player :mob-type +mob-type-imp+))))
  
  (create-world *world*)

  (if join-heaven
    (progn
      (loop with x = (random *max-x-level*)
            with y = (random *max-y-level*)
            until (and (not (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10))))
                       (not (get-mob-* (level *world*) x y))
                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y) +terrain-trait-blocks-move+)))
            finally (setf (x *player*) x (y *player*) y)
                    (add-mob-to-level-list (level *world*) *player*)
            do
               (setf x (random *max-x-level*))
               (setf y (random *max-y-level*))))
    (progn
      (loop with x = (random *max-x-level*)
            with y = (random *max-y-level*)
            until (and (and (> x 10) (< x (- *max-x-level* 10)) (> y 10) (< y (- *max-y-level* 10)))
                       (not (get-mob-* (level *world*) x y))
                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y) +terrain-trait-blocks-move+)))
            finally (setf (x *player*) x (y *player*) y)
                    (add-mob-to-level-list (level *world*) *player*)
            do
               (setf x (random *max-x-level*))
               (setf y (random *max-y-level*)))))
   
  (setf (name *player*) "Player")
  
  ;(let ((criminal (make-instance 'mob :mob-type +mob-type-criminal+ :z (z *player*) :x (+ (x *player*) 3) :y (- (y *player*) 0))))
  ;      (demon (make-instance 'mob :mob-type +mob-type-imp+ :z (z *player*) :x (- (x *player*) 3) :y (+ (y *player*) 0))))
  ;  (setf (cur-hp demon) 1)
  ;  (set-mob-effect criminal +mob-effect-blessed+)
  ;  (add-mob-to-level-list (level *world*) criminal)
  ;  (add-mob-to-level-list (level *world*) demon)
  ;  )
  
  ;(setf (x *player*) 45 (y *player*) 15)
  ;(add-mob-to-level-list (level *world*) (make-instance 'mob :mob-type +mob-type-imp+ :x (+ (x *player*) 6) :y (- (y *player*) 0)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-demon+ :z (z *player*) :x (- (x *player*) 3) :y (- (y *player*) 6)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-angel+ :z (z *player*) :x (- (x *player*) 3) :y (- (y *player*) 3)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-angel+ :z (z *player*) :x (- (x *player*) 6) :y (- (y *player*) 3)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-archangel+ :z (z *player*) :x (+ (x *player*) 6) :y (+ (y *player*) 3)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-imp+ :z (z *player*) :x (+ (x *player*) 6) :y (- (y *player*) 3)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-imp+ :z (z *player*) :x (+ (x *player*) 7) :y (- (y *player*) 3)))
  ;(add-mob-to-level-list (get-level-by-z *world* (z *player*)) (make-instance 'mob :mob-type +mob-type-archdemon+ :z (z *player*) :x (- (x *player*) 3) :y (+ (y *player*) 0)))
    
  )  

(defun main-menu ()
  
  (setf *current-window* (make-instance 'start-game-window 
                                        :menu-items (list "Join the Heavenly Forces" "Join the Legions of Hell" "Help" "Exit")
                                        :menu-funcs (list #'(lambda (n) 
                                                              (declare (ignore n))
                                                              (return-from main-menu t))
                                                          #'(lambda (n) 
                                                              (declare (ignore n))
                                                              (return-from main-menu nil))
                                                           #'(lambda (n) 
                                                              (declare (ignore n))
                                                              (setf *current-window* (make-instance 'help-window)))
                                                          #'(lambda (n) 
                                                              (declare (ignore n))
                                                              (funcall *quit-func*)))))
  (make-output *current-window*)
  (loop while t do
    (run-window *current-window*)))

  
(defun cotd-main () 
  (setf *msg-box-window-height* (* +default-font-h+ 8))
  (setf *random-state* (make-random-state t))
  (sdl:with-init ()
    (setf *window-width* (+ 200 50 (+ 30 (* +glyph-w+ *max-x-view*))) 
          *window-height* (+ 30 (* +glyph-h+ *max-y-view*) *msg-box-window-height*))
    (sdl:window *window-width* *window-height*
		
		:title-caption "The City of the Damned"
		:icon-caption "The City of the Damned")
    (sdl:enable-key-repeat nil nil)
    (sdl:enable-unicode)
    
    (setf *temp-rect* (sdl::rectangle-from-edges-* 0 0 +glyph-w+ +glyph-h+))
    
    
    (format t "path = ~A~%" (sdl:create-path "data/font4.bmp" *current-dir*))
    
    (setf *glyph-front* (sdl:load-image (sdl:create-path "data/font4.bmp" *current-dir*) 
					:color-key sdl:*white*))
    (setf *glyph-temp* (sdl:create-surface +glyph-w+ +glyph-h+ :color-key sdl:*black*))
 
    (tagbody
       (setf *quit-func* #'(lambda () (go exit-tag)))
       (let ((join-heavens (main-menu)))
         (init-game join-heavens))
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
