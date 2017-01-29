(in-package :cotd)

(defconstant +custom-scenario-win-layout+ 0)
(defconstant +custom-scenario-win-weather+ 1)
(defconstant +custom-scenario-win-player-faction+ 2)

(defclass custom-scenario-window (window)
  ((cur-step :initform +custom-scenario-win-layout+ :accessor cur-step)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :accessor menu-items)
   (layout-list :initarg :layout-list :accessor layout-list)
   (weather-list :initarg :weather-list :accessor weather-list)
   (player-faction-list :initarg :player-faction-list :accessor player-faction-list)
   (cur-layout :initform 0 :initarg :cur-layout :accessor cur-layout)
   (cur-weather :initform 0 :initarg :cur-weather :accessor cur-weather)
   (cur-faction :initform 0 :initarg :cur-faction :accessor cur-faction)
   ))

(defmethod initialize-instance :after ((win custom-scenario-window) &key)
  (setf (cur-layout win) (random (length (layout-list win))))
  (setf (cur-weather win) (random (length (weather-list win))))
  (setf (cur-faction win) (random (length (player-faction-list win))))
  (setf (cur-sel win) (cur-layout win)))

(defun populate-custom-scenario-win-menu (win step)
  (cond
    ((= step +custom-scenario-win-layout+) (return-from populate-custom-scenario-win-menu
                                             (loop for sf-id in (layout-list win)
                                                   collect (sf-name (get-scenario-feature-by-id sf-id)))))
    ((= step +custom-scenario-win-weather+) (return-from populate-custom-scenario-win-menu
                                               (loop for sf-id in (weather-list win)
                                                     collect (sf-name (get-scenario-feature-by-id sf-id)))))
    ((= step +custom-scenario-win-player-faction+) (return-from populate-custom-scenario-win-menu
                                                     (loop for sf-id in (player-faction-list win)
                                                           collect (sf-name (get-scenario-feature-by-id sf-id)))))))

(defmethod make-output ((win custom-scenario-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "CUSTOM SCENARIO" (truncate *window-width* 2) 0 :justify :center)
  
  ;; draw the current scenario info
  (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* 20) :h (- (truncate *window-height* 2) 20)))
    (write-text (format nil "Layout: ~A~%Weather: ~A~%Player faction: ~A"
                        (sf-name (get-scenario-feature-by-id (nth (cur-layout win) (layout-list win))))
                        (sf-name (get-scenario-feature-by-id (nth (cur-weather win) (weather-list win))))
                        (sf-name (get-scenario-feature-by-id (nth (cur-faction win) (player-faction-list win)))))
                rect))

  ;; draw the steps of scenario customization
  (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*))
    (cond
      ((= (cur-step win) +custom-scenario-win-layout+) (setf color-1 sdl:*yellow*))
      ((= (cur-step win) +custom-scenario-win-weather+) (setf color-2 sdl:*yellow*))
      ((= (cur-step win) +custom-scenario-win-player-faction+) (setf color-3 sdl:*yellow*)))
    
    (sdl:draw-string-solid-* (format nil "1. City layout") 10 (+ 10 (* (sdl:char-height sdl:*default-font*) 5)) :justify :left :color color-1)
    (sdl:draw-string-solid-* (format nil "2. Weather") (truncate *window-width* 2) (+ 10 (* (sdl:char-height sdl:*default-font*) 4)) :justify :center :color color-2)
    (sdl:draw-string-solid-* (format nil "3. Player faction") (- *window-width* 10) (+ 10 (* (sdl:char-height sdl:*default-font*) 4)) :justify :right :color color-3))

  ;; draw the selection for each step
  (let ((cur-str) (color-list nil))
    (setf cur-str (cur-sel win))
    (dotimes (i (length (menu-items win)))
      (if (= i cur-str) 
        (setf color-list (append color-list (list sdl:*yellow*)))
        (setf color-list (append color-list (list sdl:*white*)))))
    (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 (* (sdl:char-height sdl:*default-font*) 7)) color-list))

  (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* 10 (* 2 (sdl:char-height sdl:*default-font*))) :w (- *window-width* 20) :h (* 2 (sdl:char-height sdl:*default-font*))))
    (let ((str (create-string)))
      (cond
        ((= (cur-step win) +custom-scenario-win-layout+) (format str "[Enter/Right] Select  [Up/Down] Move selection  [Esc] Exit"))
        ((= (cur-step win) +custom-scenario-win-player-faction+) (format str "[Enter] Start game  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
        (t (format str "[Enter/Right] Select  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")))
      (write-text str rect)))
  
  (sdl:update-display))

(defmethod run-window ((win custom-scenario-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     
                     (cond
                       ((sdl:key= key :sdl-key-left)
                        (decf (cur-step win))
                        (when (< (cur-step win) +custom-scenario-win-layout+)
                          (setf (cur-step win) +custom-scenario-win-layout+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                       
                       ((sdl:key= key :sdl-key-right)
                        (incf (cur-step win))
                        (when (> (cur-step win) +custom-scenario-win-player-faction+)
                          (setf (cur-step win) +custom-scenario-win-player-faction+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                       
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape)
                        (setf *current-window* (return-to win))
                        (return-from run-window (values nil nil nil)))
                       
                       ;; enter - select
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        (if (< (cur-step win) +custom-scenario-win-player-faction+)
                          (progn
                            (incf (cur-step win))
                            (when (> (cur-step win) +custom-scenario-win-player-faction+)
                              (setf (cur-step win) +custom-scenario-win-player-faction+))
                            (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                          (progn
                            (return-from run-window (values (nth (cur-layout win) (layout-list win))
                                                            (nth (cur-weather win) (weather-list win))
                                                            (nth (cur-faction win) (player-faction-list win)))))))
                       )

                     (cond
                       ((= (cur-step win) +custom-scenario-win-layout+) (progn (setf (cur-layout win) (run-selection-list key mod unicode (cur-layout win)))
                                                                               (setf (cur-layout win) (adjust-selection-list (cur-layout win) (length (layout-list win))))
                                                                               (setf (cur-sel win) (cur-layout win))))
                       ((= (cur-step win) +custom-scenario-win-weather+) (progn (setf (cur-weather win) (run-selection-list key mod unicode (cur-weather win)))
                                                                                (setf (cur-weather win) (adjust-selection-list (cur-weather win) (length (weather-list win))))
                                                                                (setf (cur-sel win) (cur-weather win))))
                       ((= (cur-step win) +custom-scenario-win-player-faction+) (progn (setf (cur-faction win) (run-selection-list key mod unicode (cur-faction win)))
                                                                                       (setf (cur-faction win) (adjust-selection-list (cur-faction win) (length (player-faction-list win))))
                                                                                       (setf (cur-sel win) (cur-faction win)))))
                     
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
