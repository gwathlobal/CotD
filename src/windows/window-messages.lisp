(in-package :cotd)

(defclass message-window (window)
  ((cur-str :accessor cur-str)
   (message-box :initarg :message-box :accessor message-window/message-box)
   (header-str :initarg :header-str :accessor message-window/header-str)
   ))

(defmethod initialize-instance :after ((win message-window) &key)
  (with-slots (cur-str message-box) win
    (setf cur-str (message-list-length message-box))))

(defmethod make-output ((win message-window))
  (with-slots (cur-str message-box header-str) win
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* header-str (truncate *window-width* 2) 0 :justify :center)
    
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* 10) :h (- *window-height* (+ 10 (sdl:char-height sdl:*default-font*)) (sdl:char-height sdl:*default-font*) 20)))
      (let ((max-str (write-colored-text (colored-txt-list (message-box-strings message-box)) rect :count-only t)))
        
        (when (< max-str (+ cur-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*))))
          (setf cur-str (- max-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*)))))
        
        (when (< cur-str 0)
          (setf cur-str 0))
        
        (write-colored-text (colored-txt-list (message-box-strings message-box)) rect :start-line cur-str)
        )
      )
    
    (sdl:draw-string-solid-* (format nil "[Shift+Up/Down] Scroll page  [Up/Down] Scroll text  [Esc] Exit")
                             10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
    
    (sdl:update-display)))


(defmethod run-window ((win message-window))
  (with-slots (cur-str) win
    (sdl:with-events ()
      (:quit-event () (funcall (quit-func win)) t)
      (:key-down-event (:key key :mod mod :unicode unicode)
                       (declare (ignore unicode))
                       
                       ;; normalize mod
                       (setf mod (normalize-key-mod mod))
                       
                       (cond
                         ((and (key= key :key-up) (key-mod-none-p mod))
                          (decf cur-str))
                         ((and (key= key :key-down) (key-mod-none-p mod))
                          (incf cur-str))
                         ((and (or (key= key :key-up) (key= key :key-kp8)) (key-mod-shift-p mod))
                          (decf cur-str 30))
                         ((and (or (key= key :key-down) (key= key :key-kp2)) (key-mod-shift-p mod))
                          (incf cur-str 30))
                         ;; escape - quit
                         ((key= key :key-escape) 
                          (setf *current-window* (return-to win))
                          (make-output *current-window*)
                          (return-from run-window nil))
                         )
                       (make-output *current-window*))
      (:video-expose-event () (make-output *current-window*)))
    ))
