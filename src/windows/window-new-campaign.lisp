(in-package :cotd)

(defclass new-campaign-window (window)
  ((world-map :initarg :world-map :accessor world-map)
   (cur-sector :initform (cons 0 0) :initarg :cur-sector :accessor cur-sector)))

(defmethod make-output ((win new-campaign-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "NEW CAMPAIGN" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)

  (let* ((x1 20) (y1 20)
         (x2 (+ x1 (* *glyph-w* 5 *max-x-world-map*) 20)) (y2 (+ y1 (* *glyph-h* 5) 20)))
    (draw-world-map (world-map win) x1 y1)

    (highlight-world-map-tile (+ x1 (* (car (cur-sector win)) (* *glyph-w* 5))) (+ y1 (* (cdr (cur-sector win)) (* *glyph-h* 5))))

    (sdl:with-rectangle (rect (sdl:rectangle :x x2 :y y1 :w (- *window-width* 20) :h (* *glyph-h* 5 *max-y-world-map*)))
      (write-text (descr (aref (cells (world-map win)) (car (cur-sector win)) (cdr (cur-sector win))))
                  rect))
    )
  
  (sdl:draw-string-solid-* (format nil "[Arrows/Numpad] Move selection  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win new-campaign-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore unicode))
                     
                     ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))
                     
                     ;;------------------
                     ;; moving - arrows
                     (let ((new-coords (cur-sector win)))
                       (when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                         (setf new-coords (cons (1+ (car (cur-sector win)))
                                                (1- (cdr (cur-sector win)))))
                         )
                       (when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                         (setf new-coords (cons (car (cur-sector win))
                                                (1- (cdr (cur-sector win)))))
                         )
                       (when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                         (setf new-coords (cons (1- (car (cur-sector win)))
                                                (1- (cdr (cur-sector win)))))
                         )
                       (when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                         (setf new-coords (cons (1+ (car (cur-sector win)))
                                                (cdr (cur-sector win))))
                         )
                       (when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                         (setf new-coords (cons (1- (car (cur-sector win)))
                                                (cdr (cur-sector win))))
                         )
                       (when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                         (setf new-coords (cons (1+ (car (cur-sector win)))
                                                (1+ (cdr (cur-sector win)))))
                         )
                       (when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                         (setf new-coords (cons (car (cur-sector win))
                                                (1+ (cdr (cur-sector win)))))
                         )
                       (when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                         (setf new-coords (cons (1- (car (cur-sector win)))
                                                (1+ (cdr (cur-sector win)))))
                         )
                       
                       (when (and (>= (car new-coords) 0) (>= (cdr new-coords) 0)
                                  (< (car new-coords) *max-x-world-map*) (< (cdr new-coords) *max-y-world-map*))
                         (setf (cur-sector win) new-coords))
                       )
                     
                     (cond
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape)
                        (setf *current-window* (return-to win))
                        (return-from run-window nil))
                       ;; enter - select
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        ;;(when (and (menu-funcs win) (nth (cur-sel win) (menu-funcs win)))
                        ;;  (return-from run-window (funcall (nth (cur-sel win) (menu-funcs win)) (cur-sel win))))
                        ))
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
