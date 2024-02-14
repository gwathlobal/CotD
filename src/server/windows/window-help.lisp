(in-package :cotd)

(defconstant +win-help-page-menu+ 0)
(defconstant +win-help-page-overview+ 1)
(defconstant +win-help-page-concepts-combat+ 2)
(defconstant +win-help-page-concepts-environment+ 3)
(defconstant +win-help-page-concepts-gods+ 4)
(defconstant +win-help-page-keybindings+ 5)
(defconstant +win-help-page-credits+ 6)

;; It is required for the help to be displayed correctly (without double newlines), that the help txt files are saved with Unix-style endlines
;; By default when cloning a repository from Github to Windows in creates txt files with Windows-style endlines 

(defclass help-window (window)
  ((cur-page :initform +win-help-page-menu+ :accessor cur-page)
   (cur-str :initform 0 :accessor cur-str)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform (list "Overview"
                               "Concepts: Combat"
                               "Concepts: Environment"
                               "Concepts: Gods"
                               "Keybindings"
                               "Credits")
               :accessor menu-items)
   (help-txt :initform (populate-txt-from-filelist (list "help/overview.txt"
                                                         "help/concept_combat.txt"
                                                         "help/concept_environment.txt"
                                                         "help/concept_gods.txt"
                                                         "help/keybindings.txt"
                                                         "help/credits.txt"))
             :accessor help-txt)
   ))

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
                                                            "[Shift+Up/Down] Page Up/Down  [Up/Down] Scroll text  "
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
    ;; draw combat page
    ((= (cur-page win) +win-help-page-concepts-combat+) 
     (sdl:draw-string-solid-* "CONCEPTS: COMBAT" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-concepts-combat+))
    ;; draw environment page
    ((= (cur-page win) +win-help-page-concepts-environment+) 
     (sdl:draw-string-solid-* "CONCEPTS: ENVIRONMENT" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-concepts-environment+))
    ;; draw gods page
    ((= (cur-page win) +win-help-page-concepts-gods+) 
     (sdl:draw-string-solid-* "CONCEPTS: GODS" (truncate *window-width* 2) 0 :justify :center)
     (show-help-text win +win-help-page-concepts-gods+))
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
       (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 10) :color-list color-list :use-letters t))

     (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))
    )

  
  
  (sdl:update-display))

(defmethod run-window ((win help-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)

                      ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))
                     
                     (when (= (cur-page win) +win-help-page-menu+)
                       (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (menu-items win))) :max-str-per-page (length (menu-items win))))
                       (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (menu-items win)))))
                     
                     (cond
                       ((and (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8)) (= mod 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-concepts-combat+)
                                  (= (cur-page win) +win-help-page-concepts-environment+)
                                  (= (cur-page win) +win-help-page-concepts-gods+)
                                  (= (cur-page win) +win-help-page-keybindings+)
                                  (= (cur-page win) +win-help-page-credits+))
                          (decf (cur-str win))))
                       ((and (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8)) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-concepts-combat+)
                                  (= (cur-page win) +win-help-page-concepts-environment+)
                                  (= (cur-page win) +win-help-page-concepts-gods+)
                                  (= (cur-page win) +win-help-page-keybindings+)
                                  (= (cur-page win) +win-help-page-credits+))
                          (decf (cur-str win) 30)))
                       ((and (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2)) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-concepts-combat+)
                                  (= (cur-page win) +win-help-page-concepts-environment+)
                                  (= (cur-page win) +win-help-page-concepts-gods+)
                                  (= (cur-page win) +win-help-page-keybindings+)
                                  (= (cur-page win) +win-help-page-credits+))
                          (incf (cur-str win) 30)))
                       ((and (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2)) (= mod 0))
                        (when (or (= (cur-page win) +win-help-page-overview+)
                                  (= (cur-page win) +win-help-page-concepts-combat+)
                                  (= (cur-page win) +win-help-page-concepts-environment+)
                                  (= (cur-page win) +win-help-page-concepts-gods+)
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
