(in-package :cotd)

(defclass highscores-window (window)
  ((highscores-place :initform nil :initarg :highscores-place :accessor highscores-place)))

(defmethod make-output ((win highscores-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "HIGH SCORES" (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)

  (loop for record in (highscores-highscore-records *highscores*)
        for n from 0
        with str = nil
        with color = sdl:*white*
        do
           (setf str (format nil "  ~3<~A.~> ~A~%~%" (1+ n) (write-highscores-to-str record)))
           (if (and (highscores-place win)
                    (= (highscores-place win) n))
             (setf color sdl:*yellow*)
             (setf color sdl:*white*))
           (sdl:with-rectangle (rect (sdl:rectangle :x 0 :y (+ 30 (* n (sdl:char-height sdl:*default-font*) 3)) :w *window-width* :h (* (sdl:char-height sdl:*default-font*) 2)))
             (write-text str rect :color color))
        finally
           (when (highscores-additional-record *highscores*)
             (sdl:draw-string-solid-* "  ---" 0 (+ 30 (* 10 (sdl:char-height sdl:*default-font*) 3)) :color sdl:*white*)
             (setf str (format nil "  ~3<11.~> ~A~%" (write-highscores-to-str (highscores-additional-record *highscores*))))
             (if (and (highscores-place win)
                      (= (highscores-place win) 10))
             (setf color sdl:*yellow*)
             (setf color sdl:*white*))
             (sdl:with-rectangle (rect (sdl:rectangle :x 0 :y (+ 30 (sdl:char-height sdl:*default-font*) (* 10 (sdl:char-height sdl:*default-font*) 3)) :w *window-width* :h (* (sdl:char-height sdl:*default-font*) 2)))
               (write-text str rect :color color)))
           )
  
  (sdl:draw-string-solid-* (format nil "[Esc] Quit")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win highscores-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*)
                     
                     )
    (:video-expose-event () (make-output *current-window*)))
  )
