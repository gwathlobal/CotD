(in-package :cotd-sdl)

(defclass settings-window (window)
  ((cur-str :initform 0 :accessor cur-str)
   (cur-sel :initform 0 :accessor cur-sel)
   (options-list :initform (list (list "                                 Font size"
                                       ;; currently displayed value
                                       #'(lambda (options)
                                           (options-font options))
                                       ;; function to change the value
                                       #'(lambda ()
                                           (let ((avail-values (list 'font-6x13 'font-8x13))
                                                 (n 0))
                                             ;; find current value
                                             (setf n (loop for i from 0 below (length avail-values)
                                                           for item in avail-values
                                                           do
                                                           (when (eq item (options-font *options*))
                                                             (return i))
                                                           ))
                                             ;; move to next value
                                             (incf n)
                                             (when (>= n (length avail-values))
                                               (setf n 0))
                                             (setf (options-font *options*) (nth n avail-values)))
                                           ))
                                 
                                 (list "                               Player name"
                                       ;; currently displayed value
                                       #'(lambda (options)
                                           (options-player-name options))
                                       ;; function to change the value
                                       #'(lambda ()
                                           (setf *current-window* (make-instance 'input-str-window 
                                                                                 :init-input (options-player-name *options*)
                                                                                 :header-str "Choose name"
                                                                                 :main-str "Enter you name"
                                                                                 :prompt-str "[Enter] Confirm  [Esc] Cancel"
                                                                                 :all-func nil
                                                                                 :no-escape nil
                                                                                 :input-check-func #'(lambda (char cur-str)
                                                                                                       (if (and (not (null char))
                                                                                                                (or (find (string-downcase (string char)) *char-list* :test #'string=)
                                                                                                                    (char= char #\Space)
                                                                                                                    (char= char #\-))
                                                                                                                (< (length cur-str) *max-player-name-length*))
                                                                                                         t
                                                                                                         nil))
                                                                                 :final-check-func #'(lambda (full-input-str)
                                                                                                       (if (not (null full-input-str))
                                                                                                         t
                                                                                                         nil))
                                                                                 ))
                                           (make-output *current-window*)
                                           (let ((return-value (run-window *current-window*)))
                                             (unless (eq return-value nil)
                                               (setf (options-player-name *options*) return-value)))
                                           ))
                                 
                                 (list "Hide messages available through Singlemind"
                                       ;; currently displayed value
                                       #'(lambda (options)
                                           (if (options-ignore-singlemind-messages options)
                                             "Yes"
                                             "No")
                                           )
                                       ;; function to change the value
                                       #'(lambda ()
                                           (if (options-ignore-singlemind-messages *options*)
                                             (setf (options-ignore-singlemind-messages *options*) nil)
                                             (setf (options-ignore-singlemind-messages *options*) t))                                           
                                           )))
                 :initarg :options-list
                 :accessor options-list)))

(defmethod make-output ((win settings-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "SETTINGS" (truncate *window-width* 2) 10 :justify :center :color sdl:*white*)

  (let ((cur-str (cur-sel win))
        (color-list nil)
        (options-list (loop for item in (options-list win)
                            collect (format nil "~A : ~A" (first item) (funcall (second item) *options*)))))
    
    (dotimes (i (length (options-list win)))
      (if (= i cur-str) 
        (setf color-list (append color-list (list sdl:*yellow*)))
        (setf color-list (append color-list (list sdl:*white*)))))
    (draw-selection-list options-list cur-str (length options-list) 20 (+ 10 20) :color-list color-list :use-letters t))
    
  (sdl:draw-string-solid-* (format nil "[Enter] Change  [Esc] Quit")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win settings-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     
                     ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))

                     (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (options-list win))) :max-str-per-page (length (options-list win))))
                     (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (options-list win))))
                     
                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        (funcall (third (nth (cur-sel win) (options-list win))))
                        (with-open-file (file (merge-pathnames "options.cfg" *current-dir*) :direction :output :if-exists :supersede)
                          (format file "~A" (create-options-file-string *options*)))
                        ))
                     (make-output *current-window*)
                     
                     )
    (:video-expose-event () (make-output *current-window*)))
  )
