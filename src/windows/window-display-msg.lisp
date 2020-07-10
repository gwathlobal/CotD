(in-package :cotd)

(defclass display-msg-window (window)
  ((msg-line :initarg :msg-line :accessor display-msg-window/msg-line :type string)
   (x :initform nil :initarg :x :accessor display-msg-window/x)
   (y :initform nil :initarg :y :accessor display-msg-window/y)
   (w :initform nil :initarg :w :accessor display-msg-window/w)
   (h-txt :initform nil :accessor display-msg-window/h-txt)
   (prompt-line :initform "[Space] Ok" :initarg :prompt-line :accessor display-msg-window/prompt-line :type string)
   (cur-str :initform 0 :accessor display-msg-window/cur-str)
   (margin :initform 4 :accessor display-msg-window/margin :type fixnum)
   ))

(defmethod initialize-instance :after ((win display-msg-window) &key)
  (with-slots (msg-line prompt-line x y w h-txt cur-str margin) win
    (let ((max-str)
          (max-w 330))
      (unless w
        (setf w max-w))
      
      (sdl:with-rectangle (rect (sdl:rectangle :x 0 :y 0 :w (- w margin margin) :h 30))
        
        (setf max-str (write-text msg-line rect :count-only t))
        
      ;(when (< max-str (+ cur-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*))))
      ;  (setf cur-str (- max-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*)))))
        
        (when (< cur-str 0)
          (setf cur-str 0))
        
        (when (= max-str 1)
          (setf w (loop with max = max-w
                        for str in (list msg-line prompt-line)
                        for try-max = (+ 10 (* (sdl:char-width sdl:*default-font*) (length str)))
                        when (> try-max max) do
                          (setf max try-max)
                        finally (return-from nil max))))
        
        (setf h-txt (* (sdl:char-height sdl:*default-font*) max-str))
        
        (unless x
          (setf x (- (truncate *window-width* 2) (truncate w 2) margin)))
        
        (unless y
          (setf y (- (truncate *window-height* 2) (truncate h-txt 2) margin)))
        
        ))))

(defmethod make-output ((win display-msg-window))
  (with-slots (msg-line prompt-line x y w margin h-txt) win
    (let* ((h-prompt (sdl:char-height sdl:*default-font*))
           
           (x-txt-rect x)
           (y-txt-rect y)
           (w-txt-rect w)
           (h-txt-rect (+ h-txt margin margin))
           
           (x-txt-text (+ x-txt-rect margin))
           (y-txt-text (+ y-txt-rect margin))
           (w-txt-text (- w-txt-rect margin margin))
           (h-txt-text (- h-txt-rect margin margin))

           (y-prompt-rect (+ y-txt-rect h-txt-rect -1))
           (h-prompt-rect (+ h-prompt margin margin))

           (y-prompt-text (+ y-prompt-rect margin))
           (h-prompt-text (- h-prompt-rect margin margin))
           )

      ;; draw rectangle for text
      (sdl:with-rectangle (rect (sdl:rectangle :x x-txt-rect :y y-txt-rect :w w-txt-rect :h h-txt-rect))
        (sdl:fill-surface sdl:*black* :template rect)
        (sdl:draw-rectangle rect :color sdl:*white*))

      ;; draw text
      (sdl:with-rectangle (rect (sdl:rectangle :x x-txt-text :y y-txt-text :w w-txt-text :h h-txt-text))
        (write-text msg-line rect :start-line (display-msg-window/cur-str win)))

      ;; draw rectangle for prompt
      (sdl:with-rectangle (rect (sdl:rectangle :x x-txt-rect :y y-prompt-rect :w w-txt-rect :h h-prompt-rect))
        (sdl:fill-surface sdl:*black* :template rect)
        (sdl:draw-rectangle rect :color sdl:*white*))

       ;; draw prompt
      (sdl:with-rectangle (rect (sdl:rectangle :x x-txt-text :y y-prompt-text :w w-txt-text :h h-prompt-text))
        (write-text prompt-line rect :start-line 0))
      
      ))
    
    (sdl:update-display))

(defmethod run-window ((win display-msg-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ;; escape - quit with nil
                       ((sdl:key= key :sdl-key-escape) (progn
                                                         (setf *current-window* (return-to win))
                                                         (make-output *current-window*)
                                                         (return-from run-window nil)))
                       ;; space, enter - quit with t
                       ((or (sdl:key= key :sdl-key-space) (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter)) (progn
                                                                                                                             (setf *current-window* (return-to win))
                                                                                                                             (make-output *current-window*)
                                                                                                                             (return-from run-window t))))
                     (make-output *current-window*)
                     )
    (:video-expose-event () (make-output *current-window*))))
