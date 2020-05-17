(in-package :cotd)

(defclass load-game-window (window)
  ((save-game-type :initarg :save-game-type :type save-game-type-enum)
   (title-string :type string)
   (save-list :initform () :type list)
   (game-pathname-list :initform () :type list)
   (game-slot-list :initform () :type list)
   (cur-sel :initform 0 :type fixnum)))

(defmethod initialize-instance :after ((win load-game-window) &key)
  (with-slots (save-game-type title-string save-list game-pathname-list game-slot-list) win
    (loop for pathname in (find-all-save-game-paths save-game-type)
          with filename-descr = (make-pathname :name *save-descr-filename*)
          with filename-game = (make-pathname :name *save-game-filename*)
          with serialized-save-descr = nil
          do
             (setf serialized-save-descr (load-descr-from-disk (merge-pathnames filename-descr pathname)))
             (when serialized-save-descr
               (with-slots (id player-name sector-name mission-name save-date) serialized-save-descr
                 (multiple-value-bind (second minute hour date month year day-of-week dst-p tz) (decode-universal-time save-date)
                   (declare (ignore day-of-week dst-p tz))
                   (push (format nil "~40@<~A~> ~30@<~A~>~30@<~A~>~%~A" player-name sector-name mission-name
                                 (show-date-time-short (set-current-date-time year (1- month) (1- date) hour minute second)))
                         save-list))
                 (push id game-slot-list))
               (push (merge-pathnames filename-game pathname) game-pathname-list)))
    (case save-game-type
      (:save-game-campaign (setf title-string "LOAD CAMPAIGN"))
      (:save-game-scenario (setf title-string "LOAD SCENARIO")))))

(defmethod make-output ((win load-game-window))
  (with-slots (title-string save-list cur-sel) win
    ;; fill the screen black
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* title-string (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)
    
    (let ((color-list nil))
      (dotimes (i (length save-list))
        (if (= i cur-sel) 
          (setf color-list (append color-list (list sdl:*yellow*)))
          (setf color-list (append color-list (list sdl:*white*)))))
      (draw-multiline-selection-list save-list cur-sel 20 (+ 10 10 (sdl:char-height sdl:*default-font*)) (- *window-width* 10) (- *window-height* (+ 10 (sdl:char-height sdl:*default-font*)) (sdl:char-height sdl:*default-font*) 20)
                                     color-list)
      ;;(draw-selection-list (menu-items win) cur-sel (length (menu-items win)) 20 (+ 10 30 20 (sdl:char-height sdl:*default-font*) (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t)
      )

    (sdl:draw-string-solid-* (format nil "~A[Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Quit"
                                     (if save-list
                                       "[Enter] Load game  "
                                       ""))
                             10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
    
    (sdl:update-display)))

(defmethod run-window ((win load-game-window))
  (with-slots (save-list game-pathname-list cur-sel game-slot-list) win
    (sdl:with-events ()
      (:quit-event () (funcall (quit-func win)) t)
      (:key-down-event (:key key :mod mod :unicode unicode)

                       (when save-list
                         (setf cur-sel (run-selection-list key mod unicode cur-sel :start-page (truncate cur-sel (length save-list)) :max-str-per-page (length save-list)))
                         (setf cur-sel (adjust-selection-list cur-sel (length save-list))))
                       
                       (cond
                         ;; esc - exit the window
                         ((sdl:key= key :sdl-key-escape) 
                          (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                         ;; enter - load selected game
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (when (and game-pathname-list (nth cur-sel game-pathname-list))
                            (let ((result nil))
                              (setf result (load-game-from-disk (nth cur-sel game-pathname-list)))
                              (when result
                                (setf (game-manager/game-slot-id *game-manager*) (nth cur-sel game-slot-list))
                                (funcall *game-func*))))
                           )
                         )
                       (make-output *current-window*)
                       
                       )
      (:video-expose-event () (make-output *current-window*)))
    ))
