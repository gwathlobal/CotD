(in-package :cotd)

(defconstant +game-over-player-dead+ 0)
(defconstant +game-over-demons-won+ 1)
(defconstant +game-over-angels-won+ 2)

(setf *game-over-func*
      #'(lambda ()
	  (add-message (create-string "~%"))
	  (add-message (create-string "You are dead.~%"))
	  (setf *current-window* (make-instance 'cell-window))
          (update-visible-area (level *world*) (x *player*) (y *player*))
	  (make-output *current-window*)
	  (sdl:with-events ()
	    (:quit-event () (funcall (quit-func *current-window*)) t)
	    (:key-down-event () 
                             (setf *current-window* (make-instance 'final-stats-window :game-over-type +game-over-player-dead+))
                             (make-output *current-window*)
                             (run-window *current-window*))
	    (:video-expose-event () (make-output *current-window*)))))

(setf *game-won-func*
      #'(lambda ()
	  (add-message (format nil "~%"))
	  (add-message (format nil "Congratulations! You have won the game!~%"))
	  (setf *current-window* (make-instance 'cell-window))
	  (make-output *current-window*)
	  (sdl:with-events ()
	    (:quit-event () (funcall (quit-func *current-window*)) t)
	    (:key-down-event () 
                             (setf *current-window* (make-instance 'final-stats-window :game-over-type (if (subtypep (type-of *world*) 'world-for-angels)
                                                                                                         +game-over-angels-won+
                                                                                                         +game-over-demons-won+)))
                             (make-output *current-window*)
                             (run-window *current-window*))
	    (:video-expose-event () (make-output *current-window*)))))

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
    
    
    
    (write-text str (sdl:rectangle :x 0 :y 30 :w *window-width* :h (* 9 +default-font-h+))))

  (show-small-message-box 6 (+ 40 (* 9 +default-font-h+)) *window-width* (- *window-height* 40 (* 9 +default-font-h+)))
  
  (sdl:update-display))

(defmethod run-window ((win final-stats-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
			    (funcall (quit-func *current-window*)))
                          )
                        )
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))

(defun find-mob-with-max-kills ()
  (loop for mob being the hash-values in *mobs-hash*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-kills mob) (calculate-total-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-blesses ()
  (loop for mob being the hash-values in *mobs-hash*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-blesses mob) (stat-blesses mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-calls ()
  (loop for mob being the hash-values in *mobs-hash*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-calls mob) (stat-calls mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-answers ()
  (loop for mob being the hash-values in *mobs-hash*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-answers mob) (stat-answers mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-friendly-kills ()
  (loop for mob being the hash-values in *mobs-hash*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-friendly-kills mob) (calculate-total-friendly-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))
