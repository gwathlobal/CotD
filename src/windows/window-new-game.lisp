(in-package :cotd)

(defclass new-game-window (window)
  ((cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :initarg :menu-items :accessor menu-items)
   (menu-funcs :initform () :initarg :menu-funcs :accessor menu-funcs)
   (menu-descrs :initform () :initarg :menu-descrs :accessor menu-descrs)
   (max-menu-length :initform (truncate (- (/ *window-height* 2) 40) (sdl:char-height sdl:*default-font*)) :initarg :max-menu-length :accessor max-menu-length)
   ))

(defmethod make-output ((win new-game-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "NEW GAME" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)
  
  ;; drawing selection list
  (let ((cur-str (cur-sel win)) (color-list nil))

    ;;(format t "max-menu-length = ~A, cur-str ~A~%" (max-menu-length win) (cur-sel win))
    
    (dotimes (i (length (menu-items win)))
      ;; choose the description
      ;;(setf lst (append lst (list (aref (line-array win) i))))
      
      (if (= i cur-str) 
        (setf color-list (append color-list (list sdl:*yellow*)))
        (setf color-list (append color-list (list sdl:*white*)))))
    (draw-selection-list (menu-items win) cur-str (max-menu-length win) 20 (+ 10 (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t))

  ;; drawing selection description
  (let ((descr (nth (cur-sel win) (menu-descrs win))))
    (sdl:with-rectangle (rect (sdl:rectangle :x 20 :y (+ (truncate *window-height* 2) 0)
                                             :w (- *window-width* 40)
                                             :h (- (truncate *window-height* 2) 20 30 (sdl:char-height sdl:*default-font*))))
      (write-text descr rect :start-line 0)))

  (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win new-game-window))
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)

                        (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (menu-items win))) :max-str-per-page (max-menu-length win)))
                        (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (menu-items win))))
                        
                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
			   (setf *current-window* (return-to win))
                           (return-from run-window (values nil nil nil nil)))
			  ;; enter - select
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                           (when (and (menu-funcs win) (nth (cur-sel win) (menu-funcs win)))
                             (return-from run-window (funcall (nth (cur-sel win) (menu-funcs win)) (cur-sel win))))
                           ))
			(make-output *current-window*))
       (:video-expose-event () (make-output *current-window*))))
