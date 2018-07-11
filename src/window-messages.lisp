(in-package :cotd)

(defclass message-window (window)
  ((cur-str :initform (message-list-length) :accessor cur-str)
   ))

(defmethod make-output ((win message-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "MESSAGES" (truncate *window-width* 2) 0 :justify :center)

  (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* 10) :h (- *window-height* (+ 10 (sdl:char-height sdl:*default-font*)) (sdl:char-height sdl:*default-font*) 20)))
    (let ((max-str (write-colored-text (colored-txt-list (message-box-strings *full-message-box*)) rect :count-only t)))

      (when (< max-str (+ (cur-str win) (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*))))
        (setf (cur-str win) (- max-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*)))))
      
      (when (< (cur-str win) 0)
        (setf (cur-str win) 0))

      ;;(format t "CUR-STR= ~A~%" (cur-str win))
      
      (write-colored-text (colored-txt-list (message-box-strings *full-message-box*)) rect :start-line (cur-str win))
      )
    )
    
  (sdl:draw-string-solid-* (format nil "[Up/Down] Scroll text  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win message-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        (declare (ignore unicode))

                         ;; normalize mod
                        (loop while (>= mod sdl-key-mod-num) do
                          (decf mod sdl-key-mod-num))
  
                        (cond
                          ((and (sdl:key= key :sdl-key-up) (= mod 0))
                           (decf (cur-str win)))
                          ((and (sdl:key= key :sdl-key-down) (= mod 0))
                           (incf (cur-str win)))
                          ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
                           (setf *current-window* (return-to win)) (go exit-func))
                             
			  ;; enter - select
			  )
			(go exit-func))
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
