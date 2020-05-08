(in-package :cotd)

(defconstant +new-campaign-window-map-mode+ 0)
(defconstant +new-campaign-window-mission-mode+ 1)

(defclass new-campaign-window (window)
  ((world :initarg :world :accessor world)
   (world-map :initarg :world-map :accessor world-map)
   (world-time :initarg :world-time :accessor world-time)
   (cur-sector :initform (cons 0 0) :initarg :cur-sector :accessor cur-sector)
   (cur-mode :initform +new-campaign-window-mission-mode+ :initarg :cur-mode :accessor cur-mode)
   (cur-sel :initform 0 :accessor cur-sel)
   (avail-missions :initform () :accessor avail-missions)
   (test-map-func :initform nil :initarg :test-map-func :accessor test-map-func)))

(defmethod initialize-instance :after ((win new-campaign-window) &key)
  (setf (avail-missions win) (loop with result = ()
                                   for x from 0 below *max-x-world-map* do
                                     (loop for y from 0 below *max-y-world-map*
                                           for mission = (mission (aref (cells (world-map win)) x y))
                                           when mission
                                             do
                                                (push mission result))
                                   finally (return result)))
  (when (= (cur-mode win) +new-campaign-window-mission-mode+)
    (campaign-win-move-select-to-mission win)))

(defmethod campaign-win-move-select-to-mission ((win new-campaign-window))
  (setf (cur-sector win) (cons (x (nth (cur-sel win) (avail-missions win)))
                               (y (nth (cur-sel win) (avail-missions win))))))

(defmethod make-output ((win new-campaign-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "NEW CAMPAIGN" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)

  
  (let* ((x1 20) (y1 20) (map-w (* *glyph-w* 5 *max-x-world-map*)) (map-h (* *glyph-h* 5 *max-y-world-map*))
         (x2 (+ x1 map-w 20)) (y2 (+ y1 20))
         (str1 "Select mission in a sector:")
         (str2 "Select available mission:")
         (str3 (format nil "~A" (show-date-time-YMD (world-time win)))))
    (if (= (cur-mode win) +new-campaign-window-map-mode+)
      (sdl:draw-string-solid-* str1 (+ x1 (truncate map-w 2)) y1 :justify :center :color sdl:*white*)
      (sdl:draw-string-solid-* str2 (+ x2 (truncate (- *window-width* x2 20) 2)) y1 :justify :center :color sdl:*white*))
    
    (draw-world-map (world-map win) x1 y2)

    (highlight-world-map-tile (+ x1 (* (car (cur-sector win)) (* *glyph-w* 5))) (+ y2 (* (cdr (cur-sector win)) (* *glyph-h* 5))))

    (sdl:draw-string-solid-* str3 (+ x1 (truncate map-w 2)) (+ y1 map-h 30) :justify :center :color sdl:*white*)
    
    (if (= (cur-mode win) +new-campaign-window-map-mode+)
      (sdl:with-rectangle (rect (sdl:rectangle :x x2 :y y2 :w (- *window-width* x2 20) :h map-h))
        (write-text (descr (aref (cells (world-map win)) (car (cur-sector win)) (cdr (cur-sector win))))
                    rect))
      (progn
        (let ((cur-str) (color-list nil)
              (mission-names-list ())
              (str-per-page 10))
          (setf cur-str (cur-sel win))
          (dotimes (i (length (avail-missions win)))
            (push (name (nth i (avail-missions win))) mission-names-list)
            (if (= i cur-str) 
              (setf color-list (append color-list (list sdl:*yellow*)))
              (setf color-list (append color-list (list sdl:*white*)))))
          (setf mission-names-list (reverse mission-names-list))
          (draw-selection-list mission-names-list cur-str str-per-page x2 y2 :color-list color-list)
        
        (sdl:with-rectangle (rect (sdl:rectangle :x x2
                                                 :y (+ y2 10 (* (sdl:char-height sdl:*default-font*) str-per-page))
                                                 :w (- *window-width* x2 20)
                                                 :h (- *window-height* 40 (+ 10 10 (* (sdl:char-height sdl:*default-font*) str-per-page)))))
          (write-text (descr (aref (cells (world-map win)) (car (cur-sector win)) (cdr (cur-sector win))))
                      rect))))
      )
    )
  (let ((run-mission-str (if (mission (aref (cells (world-map win)) (car (cur-sector win)) (cdr (cur-sector win))))
                           "[Enter] Start mission  "
                           "")))
    (sdl:draw-string-solid-* (format nil "~A[Arrows/Numpad] Move selection  [Tab] Change mode  [r] Randomize map  [t] Test map  [Esc] Exit" run-mission-str)
                             10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))
  
  (sdl:update-display))

(defmethod run-window ((win new-campaign-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                                          
                     ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))

                     (with-slots (world world-map test-map-func cur-mode) win
                       ;;------------------
                       ;; moving - arrows
                       (cond
                         ((= cur-mode +new-campaign-window-map-mode+)
                          (progn (let ((new-coords (cur-sector win)))
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
                                   )))
                         ((= cur-mode +new-campaign-window-mission-mode+)
                          (progn (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win)))
                                 (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (avail-missions win))))
                                 (campaign-win-move-select-to-mission win))))
                       
                       (cond
                         ;; escape - quit
                         ((sdl:key= key :sdl-key-escape)
                          (setf *current-window* (return-to win))
                          (return-from run-window nil))
                         ;; t - return test map
                         ((sdl:key= key :sdl-key-t)
                          (setf world-map (funcall test-map-func))
                          (setf cur-mode +new-campaign-window-mission-mode+)
                          (campaign-win-move-select-to-mission win))
                         ;; r - random map
                         ((sdl:key= key :sdl-key-r)
                          (setf world-map (generate-normal-world-map world))
                          (setf (world-map world) world-map)
                          (setf cur-mode +new-campaign-window-map-mode+))
                         ;; tab - change mode
                         ((sdl:key= key :sdl-key-tab)
                          (if (= cur-mode +new-campaign-window-mission-mode+)
                            (setf cur-mode +new-campaign-window-map-mode+)
                            (progn
                              (setf cur-mode +new-campaign-window-mission-mode+)
                              (campaign-win-move-select-to-mission win))))
                         ;; enter - select
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (when (mission (aref (cells world-map) (car (cur-sector win)) (cdr (cur-sector win))))
                            (return-from run-window (values (mission (aref (cells world-map) (car (cur-sector win)) (cdr (cur-sector win))))
                                                            (aref (cells world-map) (car (cur-sector win)) (cdr (cur-sector win))))))
                          ))
                       (make-output *current-window*)))
    (:video-expose-event () (make-output *current-window*))))
