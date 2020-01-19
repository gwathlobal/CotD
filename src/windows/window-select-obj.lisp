(in-package :cotd)

(defclass select-obj-window (window)
  ((cur-sel :initform 0 :accessor cur-sel)
   (header-line :initform nil :initarg :header-line :accessor header-line)
   (line-list :initarg :line-list :accessor line-list :type list)
   (descr-list :initform nil :initarg :descr-list :accessor descr-list)
   (color-list :initform nil :initarg :color-list :accessor color-list)
   (prompt-list :initarg :prompt-list :accessor prompt-list :type list) ;; each value is (<func if this prompt should apply with 1 arg - cur-sel> <prompt string proper>)
   (enter-func :initarg :enter-func :accessor enter-func) ;; 1 arg - cur-sel
   (select-color-func :initform nil :initarg :select-color-func :accessor select-color-func) ;; 1 arg - cur-sel
   )) 

(defmethod make-output ((win select-obj-window))
  (let ((x (- (truncate *window-width* 2) 150)) (y (- (truncate *window-height* 2) 50)) (w 330) (h 65) (descr-h 0))
    ;; find the descr height
    (when (descr-list win)
      (sdl:with-rectangle (rect (sdl:rectangle :x x :y y :w (- w 8) :h 600))
	(let ((first-descr t) (new-descr-h 0))
	  (loop for descr in (descr-list win) do
	       (setf new-descr-h (+ 2 (* (sdl:char-height sdl:*default-font*) (write-text descr rect :count-only t))))
	       (when first-descr 
		 (setf descr-h new-descr-h)
		 (setf first-descr nil))
	       (when (> new-descr-h descr-h) (setf descr-h new-descr-h))))))

    ;; define the height of the window depending on the length of the object array
    (setf y (- (truncate *window-height* 2) (truncate (+ (* (sdl:char-height sdl:*default-font*) (length (line-list win))) descr-h) 2)))
    (setf h (+ 19 (* 13 (length (line-list win))) descr-h))

    ;; drawing a large rectangle in white
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*white* :template a-rect))
    ;; drawing a smaller rectanagle in black to make a 1 pixel width border
    (sdl:with-rectangle (a-rect (sdl:rectangle :x (1+ x) :y (1+ y) :w (- w 2) :h (- h 2)))
      (sdl:fill-surface sdl:*black* :template a-rect))
    ;; drawing a line to separate the lines with the descr
    (sdl:with-rectangle (rect (sdl:rectangle :x x :y (- (+ y h) 17 descr-h) :w w :h 1))
      (sdl:fill-surface sdl:*white* :template rect))
    ;; drawing a line to separate the prompt and command hint line
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y (- (+ y h) 17) :w w :h 1))
      (sdl:fill-surface sdl:*white* :template a-rect))

    (when (header-line win)
      (sdl:with-rectangle (rect (sdl:rectangle :x x :y (- y (sdl:char-height sdl:*default-font*) 2) :w w :h (+ (sdl:char-height sdl:*default-font*) 2)))
        (sdl:fill-surface sdl:*white* :template rect))
      (sdl:with-rectangle (rect (sdl:rectangle :x (1+ x) :y (1- (- y (sdl:char-height sdl:*default-font*))) :w (- w 2) :h (+ (sdl:char-height sdl:*default-font*) 1)))
        (sdl:fill-surface sdl:*black* :template rect))
      (sdl:draw-string-solid-* (header-line win) (+ x 5) (- y (sdl:char-height sdl:*default-font*) 1) :color sdl:*white*))
    ;; drawing objects
    (let ((cur-str) (color-list nil))
      (setf cur-str (cur-sel win))
      (dotimes (i (length (line-list win)))
	;; choose the description
	;;(setf lst (append lst (list (aref (line-array win) i))))

        (if (= i cur-str) 
          (if (select-color-func win)
            (setf color-list (append color-list (list (funcall (select-color-func win) cur-str)))) 
            (setf color-list (append color-list (list sdl:*yellow*))))
          (if (color-list win)
            (setf color-list (append color-list (list (nth i (color-list win)))))
            (setf color-list (append color-list (list sdl:*white*)))))
        )
      (draw-selection-list (line-list win) cur-str (length (line-list win)) (- (truncate *window-width* 2) 150) (1+ y) :color-list color-list :use-letters t))

    ;; drawing descriptions
    (when (descr-list win)
      (sdl:with-rectangle (rect (sdl:rectangle :x (+ x 4) :y (- (+ y h) 16 descr-h) :w (- w 8) :h descr-h))
        (write-text (nth (cur-sel win) (descr-list win)) rect :color sdl:*white*)))

    (let ((str))
      ;; choose the prompt
      (if (prompt-list win)
        (setf str (funcall (nth (cur-sel win) (prompt-list win)) (cur-sel win)))
        (setf str "[Esc] Escape"))
      
      (sdl:draw-string-solid-* str (+ x 5) (- (+ y h) (sdl:char-height sdl:*default-font*) 2) :color sdl:*white*))
    (sdl:update-display)))

(defmethod run-window ((win select-obj-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
			
			(setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (line-list win))) :max-str-per-page (length (line-list win))))
                        (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (line-list win))))

                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
			   (setf *current-window* (return-to win)) (format t "AFTER ESCAPE FROM SELECT-OBJ~%") (go exit-func))
			  ;; enter - select
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
			   (funcall (enter-func win) (cur-sel win))
			   (go exit-func)))
                        (make-output *current-window*)
			)
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
