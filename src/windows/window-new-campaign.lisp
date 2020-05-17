(in-package :cotd)

(defenum:defenum new-campaign-window-tab-type (:new-campaign-window-map-mode
                                               :new-campaign-window-mission-mode))

(defclass new-campaign-window (window)
  ((world :initarg :world :accessor new-campaign-window/world :type world)
   (world-map :initarg :world-map :accessor new-campaign-window/world-map)
   (world-time :initarg :world-time :accessor world-time)
   (cur-sector :initform (cons 0 0) :initarg :cur-sector :accessor new-campaign-window/cur-sector :type cons)
   (cur-mode :initform :new-campaign-window-mission-mode :initarg :cur-mode :accessor new-campaign-window/cur-mode :type new-campaign-window-tab-type)
   (cur-sel :initform 0 :accessor new-campaign-window/cur-sel :type fixnum)
   (avail-missions :initform () :accessor new-campaign-window/avail-missions :type list)
   (test-map-func :initform nil :initarg :test-map-func :accessor new-campaign-window/test-map-func)))

(defmethod initialize-instance :after ((win new-campaign-window) &key)
  (with-slots (cur-mode) win
    (campaign-win-calculate-avail-missions win)
    
    (when (eq cur-mode :new-campaign-window-mission-mode)
      (campaign-win-move-select-to-mission win))))

(defmethod campaign-win-calculate-avail-missions ((win new-campaign-window))
  (with-slots (avail-missions world-map) win
    (setf avail-missions (loop with result = ()
                               for x from 0 below *max-x-world-map* do
                                 (loop for y from 0 below *max-y-world-map*
                                       for mission = (mission (aref (cells world-map) x y))
                                       when mission
                                         do
                                            (push mission result))
                               finally (return result)))))

(defmethod campaign-win-move-select-to-mission ((win new-campaign-window))
  (with-slots (cur-sector cur-sel avail-missions) win
    (when avail-missions
      (setf cur-sector (cons (x (nth cur-sel avail-missions))
                             (y (nth cur-sel avail-missions)))))))

(defmethod make-output ((win new-campaign-window))
  (with-slots (cur-mode cur-sector cur-sel world-map world-time avail-missions) win
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* "NEW CAMPAIGN" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)
    
    
    (let* ((x1 20) (y1 20) (map-w (* *glyph-w* 5 *max-x-world-map*)) (map-h (* *glyph-h* 5 *max-y-world-map*))
           (x2 (+ x1 map-w 20)) (y2 (+ y1 20))
           (str1 "Select mission in a sector:")
           (str2 "Select available mission:")
           (str3 (format nil "~A" (show-date-time-YMD world-time))))
      (if (eq cur-mode :new-campaign-window-map-mode)
        (sdl:draw-string-solid-* str1 (+ x1 (truncate map-w 2)) y1 :justify :center :color sdl:*white*)
        (sdl:draw-string-solid-* str2 (+ x2 (truncate (- *window-width* x2 20) 2)) y1 :justify :center :color sdl:*white*))
      
      (draw-world-map world-map x1 y2)
      
      (highlight-world-map-tile (+ x1 (* (car cur-sector) (* *glyph-w* 5))) (+ y2 (* (cdr cur-sector) (* *glyph-h* 5))))
      
      (sdl:draw-string-solid-* str3 (+ x1 (truncate map-w 2)) (+ y1 map-h 30) :justify :center :color sdl:*white*)
      
      (if (eq cur-mode :new-campaign-window-map-mode)
        (sdl:with-rectangle (rect (sdl:rectangle :x x2 :y y2 :w (- *window-width* x2 20) :h map-h))
          (write-text (descr (aref (cells world-map) (car cur-sector) (cdr cur-sector)))
                      rect))
        (progn
          (let ((color-list nil)
                (mission-names-list ())
                (str-per-page 10))
            (dotimes (i (length avail-missions))
              (push (name (nth i avail-missions)) mission-names-list)
              (if (= i cur-sel) 
                (setf color-list (append color-list (list sdl:*yellow*)))
                (setf color-list (append color-list (list sdl:*white*)))))
            (setf mission-names-list (reverse mission-names-list))
            (draw-selection-list mission-names-list cur-sel str-per-page x2 y2 :color-list color-list)
            
            (sdl:with-rectangle (rect (sdl:rectangle :x x2
                                                     :y (+ y2 10 (* (sdl:char-height sdl:*default-font*) str-per-page))
                                                     :w (- *window-width* x2 20)
                                                     :h (- *window-height* 40 (+ 10 10 (* (sdl:char-height sdl:*default-font*) str-per-page)))))
              (write-text (descr (aref (cells world-map) (car cur-sector) (cdr cur-sector)))
                          rect))))
        )
      )
    (let ((run-mission-str (if (mission (aref (cells world-map) (car cur-sector) (cdr cur-sector)))
                             "[Enter] Start mission  "
                             ""))
          (test-gen-str (if (not *cotd-release*)
                          "[r] Randomize map  [t] Test map  "
                          "")))
      (sdl:draw-string-solid-* (format nil "~A[Arrows/Numpad] Move selection  [Tab] Change mode  ~A[Esc] Exit" run-mission-str test-gen-str)
                               10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))
    
    (sdl:update-display)))

(defmethod run-window ((win new-campaign-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                                          
                     ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))

                     (with-slots (world world-map world-time test-map-func cur-mode cur-sector cur-sel avail-missions return-to) win
                       ;;------------------
                       ;; moving - arrows
                       (case cur-mode
                         (:new-campaign-window-map-mode (progn (let ((new-coords cur-sector))
                                                                 (when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                                                                   (setf new-coords (cons (car cur-sector)
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (cdr cur-sector)))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (cdr cur-sector)))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                                                                   (setf new-coords (cons (car cur-sector)
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 
                                                                 (when (and (>= (car new-coords) 0) (>= (cdr new-coords) 0)
                                                                            (< (car new-coords) *max-x-world-map*) (< (cdr new-coords) *max-y-world-map*))
                                                                   (setf cur-sector new-coords))
                                                                 )))
                         (:new-campaign-window-mission-mode (progn (setf cur-sel (run-selection-list key mod unicode cur-sel))
                                                                   (setf cur-sel (adjust-selection-list cur-sel (length avail-missions)))
                                                                   (campaign-win-move-select-to-mission win))))
                       
                       (cond
                         ;; escape - quit
                         ((sdl:key= key :sdl-key-escape)
                          (setf *current-window* return-to)
                          (return-from run-window nil))
                         ;; t - return test map
                         ((sdl:key= key :sdl-key-t)
                          (setf world-map (funcall test-map-func))
                          (campaign-win-calculate-avail-missions win)
                          (setf cur-mode :new-campaign-window-mission-mode)
                          (campaign-win-move-select-to-mission win))
                         ;; r - random map
                         ((sdl:key= key :sdl-key-r)
                          (setf world-map (generate-normal-world-map world))
                          (setf (world-map world) world-map)
                          (campaign-win-calculate-avail-missions win)
                          (setf cur-mode :new-campaign-window-map-mode))
                         ;; s - save map
                         ((and (sdl:key= key :sdl-key-s) (not *cotd-release*))
                          ;(save-world-to-disk world *campaign-saves-dir* *campaign-saves-filename*)
                          )
                         ;; l - save map
                         ((and (sdl:key= key :sdl-key-l) (not *cotd-release*))
                          ;(let ((saved-world (load-world-from-disk *campaign-saves-dir* *campaign-saves-filename*)))
                          ;  (when saved-world
                          ;    (setf world saved-world)
                          ;    (setf world-map (world-map world))
                          ;    (setf world-time (world-game-time world))
                          ;    (setf *world* world)))
                          )
                         ;; tab - change mode
                         ((sdl:key= key :sdl-key-tab)
                          (if (eq cur-mode :new-campaign-window-mission-mode)
                            (setf cur-mode :new-campaign-window-map-mode)
                            (when avail-missions
                              (setf cur-mode :new-campaign-window-mission-mode)
                              (campaign-win-move-select-to-mission win))))
                         ;; enter - select
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (when (mission (aref (cells world-map) (car cur-sector) (cdr cur-sector)))
                            (return-from run-window (values (mission (aref (cells world-map) (car cur-sector) (cdr cur-sector)))
                                                            (aref (cells world-map) (car cur-sector) (cdr cur-sector)))))
                          ))
                       (make-output *current-window*)))
    (:video-expose-event () (make-output *current-window*))))
