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
   ))

(defun show-help-overview (win)
  (let ((str (create-string)) (max-str) (rect))
    (format str "THE PLOT~%")
    (format str "The Legions of Hell invaded the City with the intention to slay its inhabitants. The Heavenly Forces had to intervene. Now both sides are bent to fight each other until none of the opponents remain. ")
    (format str "Choose your side and join the fray!~%~%")
    (format str "GENERAL TIPS~%")
    (format str " - You are not alone here - there are allies that can help.~%")
    (format str " - Your enemies are able to hide their true appearence, so observe and learn their tactics to avoid nasty surprises.~%")
    (format str " - You can attack your allies but not members of your own faction. This does not extend to demons - they can attack anyone.~%")
    (format str " - Angels and demons gain power when killing each other proportional to the strength of the slain adversary.~%")
    (format str " - Stockpile power to get promoted or spend it on available abilities.~%~%")
    (format str "THE HEAVENLY FORCES~%")
    (format str " - You start as an Angel who can easily dispatch lowly Imps.~%")
    (format str " - Bless humans to gain power.~%")
    (format str " - To win, kill all demons or ascend beyond Archangel. Survival of mankind is not required.~%~%")
    (format str "THE LEGIONS OF HELL~%")
    (format str " - You start as a puny Imp who is no match for an Angel.~%")
    (format str " - Kill humans to gain power. Beware of blessed ones.~%")
    (format str " - To win, kill all angels or ascend beyond Archdemon. Destruction of mankind is not enough.~%~%")
    (format str "HUMANS~%")
    (format str " - Humans are frail and week. Citizens of the City will try to flee whenever they see an enemy.~%")
    (format str " - Priests will preach to smite their foes or grant allies divine shield. Smiting applies minor damage to all enemies in sight, while divine shield gives a one-time protection from any harm.~%")
    (format str " - Satanists are allied with demons. They have are able to call demons to them for free and curse all enemies in sight with inaccuracy.~%")
    (format str " - Soldiers arrive towards the end of the battle for the City. They are allied with the citizens but oppose both angels and demons. They are armed with single-shot rifles and need to reload every other turn. But their numbers and the ability to apply damage at range can make short work of any supernatural being.~%")

    (setf rect (sdl:rectangle :x 10 :y 20 :w (- *window-width* 20) :h (- *window-height* 20 30 (sdl:char-height sdl:*default-font*))))

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
    
    (sdl:free rect)))

(defun show-help-keybindings (win )
  (let ((str (create-string)) (max-str) (rect))
    (format str "Arrow keys,                    - Movement~%")
    (format str "Page Up, Page Down, Home, End,~%")
    (format str "Numpad keys~%")
    (format str "Shift + 2                      - Character screen~%")
    (format str "a                              - Invoke ability~%")
    (format str "l                              - Look mode~%")
    (format str "m                              - View messages~%")
    (format str "?                              - Help~%")
    
    (setf rect (sdl:rectangle :x 10 :y 20 :w (- *window-width* 20) :h (- *window-height* 20 30 (sdl:char-height sdl:*default-font*))))

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
    
    (sdl:free rect)))

(defun show-help-credits (win)
  (let ((str (create-string)) (max-str) (rect))
    (format str "Created by Gwathlobal using Common Lisp~%")
    (format str "Inspired by a 7DRL \"City of the Condemned\" by Tapio~%~%")
    (format str "Feel free to email bugs and suggestions to gwathlobal@yandex.ru")
        
    (setf rect (sdl:rectangle :x 10 :y 20 :w (- *window-width* 20) :h (- *window-height* 20 30 (sdl:char-height sdl:*default-font*))))

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
    
    (sdl:free rect)))

(defmethod make-output ((win help-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))
  
  (cond
    ;; draw overview page
    ((= (cur-page win) +win-help-page-overview+) 
     (sdl:draw-string-solid-* "OVERVIEW" (truncate *window-width* 2) 0 :justify :center)
     (show-help-overview win))
    ;; draw keybindings page
    ((= (cur-page win) +win-help-page-keybindings+) 
     (sdl:draw-string-solid-* "KEYBINDINGS" (truncate *window-width* 2) 0 :justify :center)
     (show-help-keybindings win))
    ;; draw credits page
    ((= (cur-page win) +win-help-page-credits+) 
     (sdl:draw-string-solid-* "CREDITS" (truncate *window-width* 2) 0 :justify :center)
     (show-help-credits win))
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
  (tagbody
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
                               (setf *current-window* (return-to win)) (go exit-func))
                             (progn
                               (setf (cur-page win) +win-help-page-menu+))))
			  ;; enter - select
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                           
                           (when (= (cur-page win) +win-help-page-menu+)
                             (logger (format nil "CURPAGE ~A ,NEXT PAGE ~A~%" (cur-page win) (1+ (cur-sel win))))
                             (setf (cur-str win) 0)
                             (setf (cur-page win) (1+ (cur-sel win))))
			   (go exit-func)))
			(go exit-func))
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
