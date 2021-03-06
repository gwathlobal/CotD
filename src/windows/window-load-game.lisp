(in-package :cotd)

(defclass load-game-window (window)
  ((save-game-type :initarg :save-game-type :type save-game-type-enum)
   (title-string :type string)
   (display-str-list :initform () :type list)
   (game-pathname-list :initform () :type list)
   (descr-pathname-list :initform () :type list)
   (game-slot-list :initform () :type list)
   (cur-sel :initform 0 :type fixnum)))

(defmethod initialize-instance :after ((win load-game-window) &key)
  (with-slots (save-game-type title-string display-str-list game-pathname-list descr-pathname-list game-slot-list) win
    (loop with filename-descr = (make-pathname :name *save-descr-filename*)
          with filename-game = (make-pathname :name *save-game-filename*)
          with serialized-save-descr = nil
          with save-descr-list = ()
          for pathname in (find-all-save-game-paths save-game-type)
          for descr-pathname = (merge-pathnames filename-descr pathname)
          for game-pathname = (merge-pathnames filename-game pathname)
          do
             (setf serialized-save-descr (load-descr-from-disk descr-pathname))
             (when serialized-save-descr
               (push (list serialized-save-descr game-pathname descr-pathname) save-descr-list))
          finally
             (setf save-descr-list (stable-sort save-descr-list #'<
                                                :key #'(lambda (a)
                                                         (serialized-save-descr/save-date (first a)))))
             (loop for (save-descr game-pathname descr-pathname) in save-descr-list do
               (with-slots (id player-name sector-name mission-name world-date-str save-date) save-descr
                 (multiple-value-bind (second minute hour date month year day-of-week dst-p tz) (decode-universal-time save-date)
                   (declare (ignore day-of-week dst-p tz))
                   (push (format nil "~40@<~A~> ~40@<~A~>~30@<~A~>~%~A [~A]" player-name
                                 (if sector-name
                                   sector-name
                                   "")
                                 (if mission-name
                                   mission-name
                                   "")
                                 (show-date-time-short (set-current-date-time year (1- month) (1- date) hour minute second))
                                 world-date-str)
                         display-str-list))
                 (push id game-slot-list))
               (push game-pathname game-pathname-list)
               (push descr-pathname descr-pathname-list)))
    (case save-game-type
      (:save-game-campaign (setf title-string "LOAD CAMPAIGN"))
      (:save-game-scenario (setf title-string "LOAD SCENARIO")))))

(defmethod make-output ((win load-game-window))
  (with-slots (title-string display-str-list cur-sel) win
    ;; fill the screen black
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* title-string (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)
    
    (let ((color-list nil))
      (dotimes (i (length display-str-list))
        (if (= i cur-sel) 
          (setf color-list (append color-list (list sdl:*yellow*)))
          (setf color-list (append color-list (list sdl:*white*)))))
      (draw-multiline-selection-list display-str-list cur-sel 20 (+ 10 10 (sdl:char-height sdl:*default-font*)) (- *window-width* 10) (- *window-height* (+ 10 (sdl:char-height sdl:*default-font*)) (sdl:char-height sdl:*default-font*) 20)
                                     color-list)
      ;;(draw-selection-list (menu-items win) cur-sel (length (menu-items win)) 20 (+ 10 30 20 (sdl:char-height sdl:*default-font*) (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t)
      )

    (sdl:draw-string-solid-* (format nil "~A[Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Quit"
                                     (if display-str-list
                                       "[Enter] Load game  [d] Delete game  "
                                       ""))
                             10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
    
    (sdl:update-display)))

(defmethod run-window ((win load-game-window))
  (with-slots (display-str-list game-pathname-list descr-pathname-list cur-sel game-slot-list) win
    (sdl:with-events ()
      (:quit-event () (funcall (quit-func win)) t)
      (:key-down-event (:key key :mod mod :unicode unicode)

                       (when display-str-list
                         (setf cur-sel (run-selection-list key mod unicode cur-sel :start-page (truncate cur-sel (length display-str-list)) :max-str-per-page (length display-str-list) :use-letters nil))
                         (setf cur-sel (adjust-selection-list cur-sel (length display-str-list))))
                       
                       (cond
                         ;; esc - exit the window
                         ((sdl:key= key :sdl-key-escape) 
                          (setf *current-window* (return-to win))
                          (make-output *current-window*)
                          (return-from run-window nil))
                         ;; d - remove the selected game
                         ((or (and (sdl:key= key :sdl-key-d))
                              (eq unicode +cotd-unicode-latin-d-small+))
                          (when (and game-pathname-list (nth cur-sel game-pathname-list)
                                     descr-pathname-list (nth cur-sel descr-pathname-list))
                            (setf *current-window* (make-instance 'select-obj-window 
                                                                  :return-to *current-window*
                                                                  :header-line "Are you sure you want to delete this game?"
                                                                  :enter-func #'(lambda (current-sel)
                                                                                  (case current-sel
                                                                                    (0 (progn
                                                                                         (let* ((descr-pathname (nth cur-sel descr-pathname-list))
                                                                                                (dir-to-delete (make-pathname :host (pathname-host descr-pathname)
                                                                                                                              :device (pathname-device descr-pathname)
                                                                                                                              :directory (pathname-directory descr-pathname)))
                                                                                                (result))
                                                                                           (setf result (delete-dir-from-disk dir-to-delete))
                                                                                           (when (not result)
                                                                                             (setf *current-window* (make-instance 'display-msg-window
                                                                                                                                   :msg-line "An error has occured while the system tried to remove the game!"))
                                                                                             (make-output *current-window*)
                                                                                             (run-window *current-window*))
                                                                                           (setf game-pathname-list (remove (nth cur-sel game-pathname-list) game-pathname-list))
                                                                                           (setf descr-pathname-list (remove (nth cur-sel descr-pathname-list) descr-pathname-list))
                                                                                           (setf display-str-list (remove (nth cur-sel display-str-list) display-str-list))
                                                                                           (when (>= cur-sel (length display-str-list))
                                                                                             (setf cur-sel (1- (length display-str-list)))))
                                                                                         (setf *current-window* (return-to *current-window*))))
                                                                                    (t (progn
                                                                                         (setf *current-window* (return-to *current-window*)))))
                                                                                  )
                                                                  :line-list (list "Yes" "No")
                                                                  :prompt-list (list #'(lambda (cur-sel)
                                                                                         (declare (ignore cur-sel))
                                                                                         "[Enter] Select  [Esc] Exit")
                                                                                     #'(lambda (cur-sel)
                                                                                         (declare (ignore cur-sel))
                                                                                         "[Enter] Select  [Esc] Exit"))))
                            (make-output *current-window*)
                            (run-window *current-window*)
                            )
                          )
                         ;; enter - load selected game
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (when (and game-pathname-list (nth cur-sel game-pathname-list))
                            (let ((saved-game nil)
                                  (serialized-save-descr (load-descr-from-disk (nth cur-sel descr-pathname-list))))
                              (if (and serialized-save-descr
                                         (not (eq (getf (serialized-save-descr/params serialized-save-descr) :version) *save-version*)))
                                (progn
                                  (setf *current-window* (make-instance 'display-msg-window
                                                                        :msg-line (format nil "Failed to load the game!~%The save file is incompatible with the current version of the game and it is recommended to remove it." )
                                                                        :w (- *window-width* 400)))
                                  (make-output *current-window*)
                                  (run-window *current-window*))
                                (progn
                                  (setf saved-game (load-game-from-disk (nth cur-sel game-pathname-list)))
                                  (if saved-game
                                    (progn
                                      (setf *current-window* (make-instance 'display-msg-window
                                                                            :msg-line (format nil "Save game loaded successfully!" )
                                                                            :w (- *window-width* 400)))
                                      (make-output *current-window*)
                                      (run-window *current-window*)
                                      (setf (game-manager/game-slot-id *game-manager*) (nth cur-sel game-slot-list))
                                      (return-from run-window (serialized-game/save-type saved-game)))
                                    (progn
                                      (setf *current-window* (make-instance 'display-msg-window
                                                                            :msg-line (format nil "Failed to load the game!~%The save file is corrupted and it is recommended to remove it." )
                                                                            :w (- *window-width* 400)))
                                      (make-output *current-window*)
                                      (run-window *current-window*))
                                    )))
                              ))
                           )
                         )
                       (make-output *current-window*)
                       
                       )
      (:video-expose-event () (make-output *current-window*)))
    ))
