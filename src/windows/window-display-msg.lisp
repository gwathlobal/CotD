(in-package :cotd)

(defclass display-msg-window (window)
  ((msg-line :initarg :msg-line :accessor display-msg-window/msg-line :type string)
   (prompt-line :initform "[Space] Ok" :accessor display-msg-window/prompt-line :type string)
   ))

(defmethod make-output ((win display-msg-window))
  (with-slots (msg-line prompt-line) win
    (let* ((w (loop with max = 330
                    for str in (list msg-line prompt-line)
                    for try-max = (+ 10 (* (sdl:char-width sdl:*default-font*) (length str)))
                    when (> try-max max) do
                      (setf max try-max)
                    finally (return-from nil max)))
           (x (- (truncate *window-width* 2) (truncate w 2)))
           (h (* 2 (+ (sdl:char-height sdl:*default-font*) 4)))
           (y (- (truncate *window-height* 2) (truncate h 2)))
           )

      ;; drawing a large rectangle in white
      (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
        (sdl:fill-surface sdl:*white* :template a-rect))
      ;; drawing a smaller rectanagle in black to make a 1 pixel width border
      (sdl:with-rectangle (a-rect (sdl:rectangle :x (1+ x) :y (1+ y) :w (- w 2) :h (- h 2)))
        (sdl:fill-surface sdl:*black* :template a-rect))
      ;; drawing a line to separate the msg with the prompt
      (sdl:with-rectangle (rect (sdl:rectangle :x x :y (+ y (truncate h 2)) :w w :h 1))
        (sdl:fill-surface sdl:*white* :template rect))

      (sdl:draw-string-solid-* msg-line (+ x 5) (+ y 2) :color sdl:*white*)
      
      (sdl:draw-string-solid-* prompt-line (+ x w -5) (+ y h -2 (* -1 (sdl:char-height sdl:*default-font*))) :color sdl:*white* :justify :right)
      ))
    
    (sdl:update-display))

(defmethod run-window ((win display-msg-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
			(declare (ignore mod unicode))
                        (cond
			  ;; escape, space, enter - quit
			  ((or (sdl:key= key :sdl-key-escape) (sdl:key= key :sdl-key-space) (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
			   (setf *current-window* (return-to win)) (go exit-func)))
                        (make-output *current-window*)
			)
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
