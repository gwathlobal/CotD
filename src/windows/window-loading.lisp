(in-package :cotd)

(defclass loading-window (window)
  ((update-func :initarg :update-func :accessor update-func)
   (cur-str :initform "Generating map" :initarg :cur-str :accessor cur-str)))

(defmethod make-output ((win loading-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
 
  ;; invoke the function to update the window
  (funcall (update-func win) win)

  (sdl:update-display))

(defmethod run-window ((win loading-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:video-expose-event () (make-output *current-window*)))
  )
