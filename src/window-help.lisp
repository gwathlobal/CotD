(in-package :cotd)

(defconstant +win-help-page-menu+ 0)
(defconstant +win-help-page-overview+ 1)
(defconstant +win-help-page-keybindings+ 2)
(defconstant +win-help-page-credits+ 3)


(defclass help-window (window)
  ((cur-page :initform +win-help-page-menu+ :accessor cur-page)
   (cur-str :initform 0 :accessor cur-str)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform (list "Overview" "Keybindings" "Credits") :accessor menu-items)
   (help-txt :initform (help-window-populate-txt) :accessor help-txt)
   ))

(defun help-window-populate-txt ()
  (let ((file-list (list "help/overview.txt" "help/keybindings.txt" "help/credits.txt"))
        (get-txt-func #'(lambda (filename)
                          (with-open-file (file (merge-pathnames filename *current-dir*) :direction :input :if-does-not-exist nil)
                            (when file 
                              (loop for line = (read-line file nil)
                                    with str = (create-string "")
                                    while line do (format str "~A~%" line)
                                    finally (return str)))))))
    (append (list nil) (map 'list get-txt-func file-list)))
  )

(defun show-help-text (win txt-n)
  (let ((str (nth txt-n (help-txt win)))
        (max-str))

    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y 20 :w (- *window-width* 20) :h (- *window-height* 20 30 (sdl:char-height sdl:*default-font*))))
      ;; calculate the maximum number of lines
      (setf max-str (write-text str rect :count-only t))
      
      (when (< max-str (+ (cur-str win) (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*))))
        (setf (cur-str win) (- max-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*)))))
      
      (when (< (cur-str win) 0)
        (setf (cur-str win) 0))
      
      (write-text str rect :start-line (cur-str win))
      
      (sdl:draw-string-solid-* (format nil "~A[Esc] Exit" (if (> max-str (truncate (sdl:height rect) (sdl:char-height sdl:*default-font*)))
                                                            "[Up/Down] Scroll text  "
                                                            ""))
                               10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
      )))

(defmethod make-output ((win help-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
  
  (cond
    ;; draw overview page
    ((= (cur-page win) +win-help-page-overview+) 
     (sdl:draw-string-solid-* "OVERVIEW" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-overview+))
    ;; draw keybindings page
    ((= (cur-page win) +win-help-page-keybindings+) 
     (sdl:draw-string-solid-* "KEYBINDINGS" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-keybindings+))
    ;; draw credits page
    ((= (cur-page win) +win-help-page-credits+) 
     (sdl:draw-string-solid-* "CREDITS" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-credits+))
    (t ;; draw the menu
     (sdl:draw-string-solid-* "HELP" (truncate *window-width* 2) 0 :justify :center)
     (let ((cur-str) (color-list nil))
      (setf cur-str (cur-sel win))
       (dotimes (i (length (menu-items win)))
         (if (= i cur-str) 
           (setf color-list (append color-list (list sdl:*yellow*)))
           (setf color-list (append color-list (list sdl:*white*)))))
       (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 10) color-list))

     (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))
    )

  
  
  (sdl:update-display))

(defmethod run-window ((win help-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     
                     (when (= (cur-page win) +win-help-page-menu+)
                       (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win)))
                       (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (menu-items win)))))
                     
                     (cond
                       ((and (sdl:key= key :sdl-key-up) (= mod 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-keybindings+)
                                  (= (cur-page win) +win-help-page-credits+))
                          (decf (cur-str win))))
                       ((and (sdl:key= key :sdl-key-down) (= mod 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-keybindings+)
                                  (= (cur-page win) +win-help-page-credits+))
                          (incf (cur-str win))))
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape) 
                        (if (= (cur-page win) +win-help-page-menu+)
                          (progn 
                            (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                          (progn
                            (setf (cur-page win) +win-help-page-menu+))))
                       ;; enter - select
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        (when (= (cur-page win) +win-help-page-menu+)
                          (setf (cur-str win) 0)
                          (setf (cur-page win) (1+ (cur-sel win))))
                        ))
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
