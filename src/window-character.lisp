(in-package :cotd)

(defclass character-window (window)
  ((cur-tab :initform 0 :accessor cur-tab)
   (cur-sel :initform 0 :accessor cur-sel)))

(defun get-mob-stats-line (mob)
  (let ((str))
    (setf str (format nil "~%"))
    (unless (zerop (calculate-total-kills mob))
      (setf str (format nil "~ATotal kills: ~A~%" str (calculate-total-kills mob))))
    (unless (zerop (stat-blesses mob))
      (setf str (format nil "~ATotal blessings: ~A~%" str (stat-blesses mob))))
    (unless (zerop (stat-calls mob))
      (setf str (format nil "~ATotal summons: ~A~%" str (stat-calls mob))))
    (unless (zerop (stat-answers mob))
      (setf str (format nil "~ATotal answers: ~A~%" str (stat-answers mob))))
    str))

(defmethod make-output ((win character-window))
  (fill-background-tiles)

  ;; a pane for players stats
  (let ((x 10)
        (y 10)
        (w (- *window-width* 20))
        (h (- (truncate *window-height* 2) 15)))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (write-text (format nil "~A - ~A~%~%HP: ~A/~A~%Power: ~A/~A~%~%~A~%~A"
                        (name *player*) (name (get-mob-type-by-id (mob-type *player*)))
                        (cur-hp *player*) (max-hp *player*) 
                        (cur-fp *player*) (max-fp *player*)
                        (get-weapon-descr-line *player*)
                        (get-mob-stats-line *player*))
                (sdl:rectangle :x x :y y :w (- (truncate *window-width* 2) 20) :h h) :color sdl:*white*)
    
    (show-char-effects *player* (+ (truncate *window-width* 2) 10) y h)
    )
  
  ;; a pane for ability selection
  (let ((x 10)
        (y (+ (truncate *window-height* 2) 5))
        (w (- (truncate *window-width* 2) 20))
        (h (- (truncate *window-height* 2) 10 10 (sdl:char-height sdl:*default-font*))))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (let ((cur-str) (color-list nil) (str-list))
      (setf cur-str (cur-sel win))
      (setf str-list (loop for ability-type-id in (get-mob-all-abilities *player*)
                           collect (name (get-ability-type-by-id ability-type-id))))

      (setf color-list (loop for i from 0 below (length (get-mob-all-abilities *player*))
                             collect (if (= i cur-str) 
                                       sdl:*yellow*
                                       sdl:*white*)))
     
      (draw-selection-list str-list cur-str (truncate h (sdl:get-font-height)) x y color-list))
    )
  
  ;; a pane for ability description
  (let ((x (+ (truncate *window-width* 2) 10))
        (y (+ (truncate *window-height* 2) 5))
        (w (- (truncate *window-width* 2) 20))
        (h (- (truncate *window-height* 2) 10 10 (sdl:char-height sdl:*default-font*)))
        (ability (get-ability-type-by-id (nth (cur-sel win) (get-mob-all-abilities *player*)))))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (write-text (format nil "~A~%~%~A" 
                          (descr ability)
                          (if (passive ability)
                            "Passive."
                            (format nil "Cost: ~A pwr  Time units: ~A" (cost ability) (spd ability))))
                  (sdl:rectangle :x x :y y :w w :h h) :color sdl:*white*)
    )

  (sdl:draw-string-solid-* (format nil "[Up/Down] Move selection  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win character-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        
                        (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win)))
                        (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (get-mob-all-abilities *player*))))
                        
			(cond
			  ((sdl:key= key :sdl-key-escape) 
			   (setf *current-window* (return-to win)) (go exit-func))
			  )
			(make-output *current-window*)
       			(go exit-func)
			)
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
