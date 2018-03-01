(in-package :cotd)

(defclass journal-window (window)
  ())

(defmethod make-output ((win journal-window))
  (fill-background-tiles)

  (sdl:draw-string-solid-* "JOURNAL" (truncate *window-width* 2) 0 :justify :center)

  (let* ((x 10)
         (y (+ 0 (* 2 (sdl:char-height sdl:*default-font*))))
         (w (- *window-width* 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y)))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect)

      (write-text (format nil "~A" (descr (get-objective-type-by-id (objectives *player*))))
                  a-rect :color sdl:*white*))
    )

  (sdl:draw-string-solid-* (format nil "[Esc] Exit")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win journal-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*))
                     
    (:video-expose-event () (make-output *current-window*)))
  )
