(in-package :cotd)

(defclass input-str-window (window)
  ((input :initform (make-array '(0) :element-type 'character :adjustable t :fill-pointer t) :accessor input)
   (max-w :initform 0 :accessor max-w)
   (init-input :initform nil :initarg :init-input :accessor init-input)
   (header-str :initarg :header-str :accessor header-str)
   (main-str :initarg :main-str :accessor main-str)
   (prompt-str :initarg :prompt-str :accessor prompt-str)
   (all-func :initform nil :initarg :all-func :accessor all-func) ;; a function that takes no args and returns a string with a predefined value that means "all" in the context
   (input-check-func :initform #'(lambda (char cur-str) (declare (ignore char cur-str)) t) :initarg :input-check-func :accessor input-check-func)
   (final-check-func :initform nil :initarg :final-check-func :accessor final-check-func) ;; a funcation that takes the full input string and checks if its value is valid in the context before the window can return it
   (no-escape :initform nil :initarg :no-escape :accessor no-escape))
  )

(defmethod initialize-instance :after ((win input-str-window) &key)
  (when (init-input win)
    ;(vector-push-extend (init-input win) (input win))
    (setf (input win) (make-array (list (length (init-input win))) :element-type 'character :adjustable t :fill-pointer t :initial-contents (init-input win)))))

(defmethod make-output ((win input-str-window))
  (let* ((w (if (> (+ 10 (* (max (length (header-str win)) (length (format nil "~A: ~A" (main-str win) (input win))) (length (prompt-str win))) (sdl:char-width sdl:*default-font*)))
                   (max-w win))
              (+ 10 (* (max (length (header-str win)) (length (format nil "~A: ~A" (main-str win) (input win))) (length (prompt-str win))) (sdl:char-width sdl:*default-font*)))
              (max-w win)))
         (h (+ 11 (* (sdl:char-height sdl:*default-font*) 3)))
         (x (- (truncate *window-width* 2) (truncate w 2)))
         (y (- (truncate *window-height* 2) (truncate h 2))))

    (setf (max-w win) w)
         
    ;; drawing a large rectangle in white
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*white* :template a-rect))
    ;; drawing a smaller rectanagle in black to make a 1 pixel width border
    (sdl:with-rectangle (a-rect (sdl:rectangle :x (1+ x) :y (1+ y) :w (- w 2) :h (- h 2)))
      (sdl:fill-surface sdl:*black* :template a-rect))
    ;; drawing a line to separate the header and main string
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y (+ y 3 (* (sdl:char-height sdl:*default-font*) 1)) :w w :h 1))
      (sdl:fill-surface sdl:*white* :template a-rect))
    ;; drawing a line to separate the prompt and main string
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y (+ y 6 (* (sdl:char-height sdl:*default-font*) 2)) :w w :h 1))
      (sdl:fill-surface sdl:*white* :template a-rect))

    (sdl:draw-string-solid-* (header-str win) (+ x 5) (+ y 1) :color sdl:*white*)
    (sdl:draw-string-solid-* (format nil "~A: ~A" (main-str win) (input win)) (+ x 5) (+ y 4 (* (sdl:char-height sdl:*default-font*) 1)) :color sdl:*white*)
    (sdl:draw-string-solid-* (prompt-str win) (+ x 5) (+ y 8 (* (sdl:char-height sdl:*default-font*) 2)) :color sdl:*white*)

    (sdl:update-display)))

(defmethod run-window ((win input-str-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     
                     (cond
                       ((and (not (no-escape win)) (sdl:key= key :sdl-key-escape)) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       ((sdl:key= key :sdl-key-backspace) (when (> (fill-pointer (input win)) 0) (decf (fill-pointer (input win)))))
                       ;; a - select all
                       ((and (all-func win) (sdl:key= key :sdl-key-a) (= mod 0)) (setf (fill-pointer (input win)) 0) (format (input win) "~A" (funcall (all-func win))))
                       ((sdl:key= key :sdl-key-return) (when (and (not (zerop (length (input win))))
                                                                  (or (null (final-check-func win))
                                                                      (and (final-check-func win)
                                                                           (funcall (final-check-func win) (input win)))))
                                                         (setf *current-window* (return-to win))
                                                         (make-output *current-window*)
                                                         (return-from run-window (input win))))
                       (t (when (funcall (input-check-func win) (code-char unicode) (input win))
                            (setf (input win) (get-text-input (input win) key mod unicode)))
                          ))
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*)))
  )
