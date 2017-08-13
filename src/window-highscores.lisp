(in-package :cotd)

(defclass highscores-window (window)
  ())

(defmethod make-output ((win highscores-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "HIGH SCORES" (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)

  (loop for record in (highscores-highscore-records *highscores*)
        for n from 0
        with str = (create-string)
        do
           (format str "  ~3<~A.~> ~A~%" (1+ n) (write-highscores-to-str record))
        finally
           (when (highscores-additional-record *highscores*)
             (format str "  ---~%  ~3<11.~> ~A~%" (write-highscores-to-str (highscores-additional-record *highscores*))))
           (sdl:with-rectangle (rect (sdl:rectangle :x 0 :y 30 :w *window-width* :h (- *window-height* (* 3 (sdl:char-height sdl:*default-font*)))))
             (write-text str rect)))
  
  (sdl:draw-string-solid-* (format nil "[Esc] Quit")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win highscores-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)

                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*)
                     
                     )
    (:video-expose-event () (make-output *current-window*)))
  )
