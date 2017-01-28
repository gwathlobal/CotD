(in-package :cotd)

(defconstant +game-over-player-dead+ 0)
(defconstant +game-over-demons-won+ 1)
(defconstant +game-over-angels-won+ 2)

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
      ((= (game-over-type win) +game-over-demons-won+) (setf str (format nil "LEGIONS OF HELL WON")) (setf color sdl:*green*))
      ((= (game-over-type win) +game-over-angels-won+) (setf str (format nil "THE HEAVENLY FORCES WON")) (setf color sdl:*green*)))
    (sdl:draw-string-solid-* str  (truncate *window-width* 2) 10 :justify :center :color color)
    )
  
  ;; display scenario stats
  (let ((str (create-string)))
    
    (format str "          Humans: total ~A, killed ~A, left ~A~%" (initial-humans *world*) (- (initial-humans *world*) (total-humans *world*)) (total-humans *world*))
    (format str "          Angels: total ~A, killed ~A, left ~A~%" (initial-angels *world*) (- (initial-angels *world*) (total-angels *world*)) (total-angels *world*))
    (format str "          Demons: total ~A, killed ~A, left ~A~%" (initial-demons *world*) (- (initial-demons *world*) (total-demons *world*)) (total-demons *world*))
    (format str "~%")
    (format str "     The Butcher: ~A with ~A kills~%" (get-qualified-name (find-mob-with-max-kills)) (calculate-total-kills (find-mob-with-max-kills)))
    (format str " The Hand of God: ~A with ~A blessings~%" (get-qualified-name (find-mob-with-max-blesses)) (stat-blesses (find-mob-with-max-blesses)))
    (format str "    The Summoner: ~A with ~A summons~%" (get-qualified-name (find-mob-with-max-calls)) (stat-calls (find-mob-with-max-calls)))
    (format str "      The Jumper: ~A with ~A summon answers~%" (get-qualified-name (find-mob-with-max-answers)) (stat-answers (find-mob-with-max-answers)))
    (format str "   The Berserker: ~A with ~A friendly kills~%" (get-qualified-name (find-mob-with-max-friendly-kills)) (calculate-total-friendly-kills (find-mob-with-max-friendly-kills)))
    
    
    
    (write-text str (sdl:rectangle :x 0 :y 30 :w *window-width* :h (* 9 (sdl:get-font-height)))))

  (show-small-message-box 6 (+ 40 (* 9 (sdl:get-font-height))) *window-width* (- *window-height* 40 10 (sdl:char-height sdl:*default-font*) (* 9 (sdl:get-font-height))))

  (sdl:draw-string-solid-* (format nil "[m] Main menu  [Esc] Exit game")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win final-stats-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        (declare (ignore mod unicode))
                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
                           (funcall (quit-func *current-window*)))
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
