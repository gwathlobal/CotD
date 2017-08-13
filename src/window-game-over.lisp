(in-package :cotd)

(defconstant +game-over-player-dead+ 0)
(defconstant +game-over-demons-won+ 1)
(defconstant +game-over-angels-won+ 2)
(defconstant +game-over-military-won+ 3)
(defconstant +game-over-player-possessed+ 4)
(defconstant +game-over-thief-won+ 5)

(defclass final-stats-window (window)
  ((game-over-type :initarg :game-over-type :accessor game-over-type)))

(defmethod make-output ((win final-stats-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
 
  ;; displaying the type of game over
  (let ((str) (color))
    (cond
      ((= (game-over-type win) +game-over-player-dead+) (setf str (format nil "YOU ARE DEAD")) (setf color sdl:*red*))
      ((= (game-over-type win) +game-over-demons-won+) (setf str (format nil "THE PANDEMONIUM HIERARCHY WON")) (setf color sdl:*green*))
      ((= (game-over-type win) +game-over-angels-won+) (setf str (format nil "THE CELESTIAL COMMUNION WON")) (setf color sdl:*green*))
      ((= (game-over-type win) +game-over-military-won+) (setf str (format nil "THE MILITARY WON")) (setf color sdl:*green*))
      ((= (game-over-type win) +game-over-player-possessed+) (setf str (format nil "YOU ARE POSSESSED")) (setf color sdl:*red*))
      ((= (game-over-type win) +game-over-thief-won+) (setf str (format nil "YOU HAVE COLLECTED ENOUGH VALUABLES AND MANAGED TO ESCAPE THE CITY")) (setf color sdl:*green*)))
    (sdl:draw-string-solid-* str  (truncate *window-width* 2) 10 :justify :center :color color)
    )
  
  ;; display scenario stats
  (let ((str (create-string)))
    
    (format str "          Humans: total ~A, killed ~A, left ~A~%" (initial-humans *world*) (- (initial-humans *world*) (total-humans *world*)) (total-humans *world*))
    (format str "          Angels: total ~A, killed ~A, left ~A~%" (initial-angels *world*) (- (initial-angels *world*) (total-angels *world*)) (total-angels *world*))
    (format str "          Demons: total ~A, killed ~A, left ~A~%" (initial-demons *world*) (- (initial-demons *world*) (total-demons *world*)) (total-demons *world*))
    (format str "          Undead: total ~A, killed ~A, left ~A~%" (initial-undead *world*) (- (initial-undead *world*) (total-undead *world*)) (total-undead *world*))
    (format str "~%")
    (format str "     The Butcher: ~A with ~A kills~%" (get-qualified-name (find-mob-with-max-kills)) (calculate-total-kills (find-mob-with-max-kills)))
    (format str " The Hand of God: ~A with ~A blessings~%" (get-qualified-name (find-mob-with-max-blesses)) (stat-blesses (find-mob-with-max-blesses)))
    (format str "    The Summoner: ~A with ~A summons~%" (get-qualified-name (find-mob-with-max-calls)) (stat-calls (find-mob-with-max-calls)))
    (format str "      The Jumper: ~A with ~A summon answers~%" (get-qualified-name (find-mob-with-max-answers)) (stat-answers (find-mob-with-max-answers)))
    (format str "   The Berserker: ~A with ~A friendly kills~%" (get-qualified-name (find-mob-with-max-friendly-kills)) (calculate-total-friendly-kills (find-mob-with-max-friendly-kills)))
    (format str " The Evil Spirit: ~A with ~A possessions~%" (get-qualified-name (find-mob-with-max-possessions)) (stat-possess (find-mob-with-max-possessions)))
    (format str " The Necromancer: ~A with ~A reanimations~%" (get-qualified-name (find-mob-with-max-reanimations)) (stat-raised-dead (find-mob-with-max-reanimations)))
    (format str "     The Scrooge: ~A~%" (if (zerop (calculate-total-value (find-mob-with-max-value)))
                                                                   (format nil "None")
                                                                   (format nil "~A with ~A$ worth of items" (get-qualified-name (find-mob-with-max-value)) (calculate-total-value (find-mob-with-max-value)))))
        
    (write-text str (sdl:rectangle :x 0 :y 30 :w *window-width* :h (* 13 (sdl:get-font-height)))))

  (show-message-box 6 (+ 40 (* 13 (sdl:get-font-height))) *window-width* (- *window-height* 40 10 (sdl:char-height sdl:*default-font*) (* 14 (sdl:get-font-height))) *full-message-box*)

  (sdl:draw-string-solid-* (format nil "[m] Main menu  [Esc] High Scores")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win final-stats-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        (declare (ignore mod unicode))
                        (cond
			  ;; escape - high scores
			  ((sdl:key= key :sdl-key-escape) 
                           (setf *current-window* (make-instance 'highscores-window))
                           (make-output *current-window*)
                           (run-window *current-window*)
                           (funcall *start-func*))
                          ;; m - main menu
                          ((sdl:key= key :sdl-key-m) 
                           (funcall *start-func*))
                          )
                        )
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))

(defun find-mob-with-max-kills ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-kills mob) (calculate-total-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-blesses ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-blesses mob) (stat-blesses mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-calls ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-calls mob) (stat-calls mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-answers ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-answers mob) (stat-answers mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-friendly-kills ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-friendly-kills mob) (calculate-total-friendly-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun calculate-total-value (mob)
  (if (and (check-dead mob) (eq mob *player*))
    (stat-gold mob)
    (get-overall-value (inv mob))))

(defun find-mob-with-max-value ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-value mob) (calculate-total-value mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-possessions ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-possess mob) (stat-possess mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-reanimations ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-raised-dead mob) (stat-raised-dead mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))
