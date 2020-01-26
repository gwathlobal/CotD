(in-package :cotd)

(defclass new-campaign-window (window)
  ((world-map :initarg :world-map :accessor world-map)))

(defmethod make-output ((win new-campaign-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "NEW CAMPAIGN" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)

  (draw-world-map (world-map win) 20 20)
  
  (sdl:draw-string-solid-* (format nil "[Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win new-campaign-window))
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        (declare (ignore mod unicode))
                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
			   (setf *current-window* (return-to win))
                           (return-from run-window nil))
			  ;; enter - select
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                           ;;(when (and (menu-funcs win) (nth (cur-sel win) (menu-funcs win)))
                           ;;  (return-from run-window (funcall (nth (cur-sel win) (menu-funcs win)) (cur-sel win))))
                           ))
			(make-output *current-window*))
       (:video-expose-event () (make-output *current-window*))))
