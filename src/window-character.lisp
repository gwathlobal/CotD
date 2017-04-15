(in-package :cotd)

(defconstant +character-win-weapon&armor+ 0)
(defconstant +character-win-abilities+ 1)
(defconstant +character-win-effects+ 2)

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

(defun char-win-draw-weapon&armor (win)
  (declare (ignore win))
  (let* ((x 10)
         (y (+ 30 (* (sdl:char-height sdl:*default-font*) 1)))
         (w (- *window-width* 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y)))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect)
    
    (write-text (format nil "~A - ~A~%~%HP: ~A/~A~%~A~A~%~A~%~%~A~%Dodge chance: ~A~%~A~A"
                        (name *player*) (name (get-mob-type-by-id (mob-type *player*)))
                        (cur-hp *player*) (max-hp *player*) 
                        (if (zerop (max-fp *player*)) "" (format nil "Power: ~A/~A~%" (cur-fp *player*) (max-fp *player*)))
                        (if (mob-ability-p *player* +mob-abil-military-follow-me+) (format nil "Followers: ~A~%" (count-follower-list *player*)) "")
                        (get-weapon-descr-long *player*)
                        (get-armor-descr *player*)
                        (cur-dodge *player*)
                        (if (not (zerop (cur-light *player*))) (format nil "Light radius: ~A~%" (cur-light *player*)) "")
                        (get-mob-stats-line *player*))
                a-rect :color sdl:*white*)
      )
    (sdl:draw-string-solid-* (format nil "[Right] Change tab  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  ))

(defun char-win-draw-abilities (win)
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 10 :y 10 :w 20 :h 20))
    (sdl:fill-surface sdl:*black* :template a-rect))
  (let* ((x 10)
         (y (+ 30 (* (sdl:char-height sdl:*default-font*) 1)))
         (w (- (truncate *window-width* 2) 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y)))
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

  (let* ((x (+ (truncate *window-width* 2) 10))
         (y (+ 30 (* (sdl:char-height sdl:*default-font*) 1)))
         (w (- (truncate *window-width* 2) 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y))
         (ability (get-ability-type-by-id (nth (cur-sel win) (get-mob-all-abilities *player*)))))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      
      
      (write-text (format nil "~A~%~%~A" 
                          (descr ability)
                          (if (passive ability)
                            "Passive."
                            (format nil "~A~ATime units: ~A"
                                    (if (zerop (cost ability)) "" (format nil "Cost: ~A pwr  " (cost ability)))
                                    (if (zerop (cd ability)) "" (format nil "Cooldown: ~A TU  " (* +normal-ap+ (cd ability))))
                                    (spd ability))))
                  a-rect :color sdl:*white*)
      )
    )
  (sdl:draw-string-solid-* (format nil "[Left/Right] Change tab  [Up/Down] Change selection  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))

(defun char-win-draw-effects (win)
  (declare (ignore win))
  (let* ((x 10)
         (y (+ 30 (* (sdl:char-height sdl:*default-font*) 1)))
         (w (- (truncate *window-width* 2) 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y)))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect))
        
    (show-char-effects *player* x y h)
    )
  (sdl:draw-string-solid-* (format nil "[Left] Change tab  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))

(defmethod make-output ((win character-window))
  (fill-background-tiles)

  (sdl:draw-string-solid-* "CHARACTER" (truncate *window-width* 2) 0 :justify :center)
  
  (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*))
    (cond
      ((= (cur-tab win) +character-win-weapon&armor+)
       (setf color-1 sdl:*yellow*)
       (char-win-draw-weapon&armor win))
      ((= (cur-tab win) +character-win-abilities+)
       (setf color-2 sdl:*yellow*)
       (char-win-draw-abilities win))
      ((= (cur-tab win) +character-win-effects+)
       (setf color-3 sdl:*yellow*)
       (char-win-draw-effects win)))

    (sdl:draw-string-solid-* (format nil "Stats") 10 (+ 10 (* (sdl:char-height sdl:*default-font*) 1)) :justify :left :color color-1)
    (sdl:draw-string-solid-* (format nil "Abilities") (truncate *window-width* 2) (+ 10 (* (sdl:char-height sdl:*default-font*) 1)) :justify :center :color color-2)
    (sdl:draw-string-solid-* (format nil "Effects") (- *window-width* 10) (+ 10 (* (sdl:char-height sdl:*default-font*) 1)) :justify :right :color color-3))
  
  (sdl:update-display))

(defmethod run-window ((win character-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     
                     (when (= (cur-tab win) +character-win-abilities+)
                       (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win)))
                       (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (get-mob-all-abilities *player*)))))
                     
                     (cond
                       ((sdl:key= key :sdl-key-left)
                        (decf (cur-tab win))
                        (when (< (cur-tab win) +character-win-weapon&armor+)
                          (setf (cur-tab win) +character-win-weapon&armor+)))
                       
                       ((sdl:key= key :sdl-key-right)
                        (incf (cur-tab win))
                        (when (> (cur-tab win) +character-win-effects+)
                          (setf (cur-tab win) +character-win-effects+)))
                        
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*))
                     
    (:video-expose-event () (make-output *current-window*)))
  )
