(in-package :cotd)

(defclass loading-window (window)
  ((update-func :initarg :update-func :accessor update-func)))

(defmethod make-output ((win loading-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
 
  ;; invoke the function to update the window
  (funcall (update-func win))

  (sdl:update-display))

(defmethod run-window ((win loading-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
			(go exit-func)
			)
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
