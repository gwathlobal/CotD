(in-package :cotd)

(defclass campaign-over-window (window)
  ((campaign-over-type :initarg :campaign-over-type :accessor campaign-over-window/campaign-over-type :type game-over-enum)
   (player-won :initform nil :initarg :player-won :accessor campaign-over-window/player-won)))

(defmethod make-output ((win campaign-over-window))
  ;; fill the screen black
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (with-slots (player-won campaign-over-type) win
    
    ;; set up all strings
    (let ((header-str (create-string))
          (long-text)
          (max-lines)
          (color)
          (prompt-str))
      (if player-won
        (progn
          (format header-str "VICTORY! ")
          (setf color sdl:*green*))
        (progn
          (format header-str "DEFEAT! ")
          (setf color sdl:*red*)))
      
      (case campaign-over-type
        (:game-over-demons-won (progn
                                 (format header-str "THE PANDEMONIUM HIERARCHY WON")
                                 (setf long-text (format nil "The demons have gathered enough flesh for their nefarious purposes and have withdrawn into their own hellish dimension. But the portals to our world are not completely shut and may open one day again..."))))
        (:game-over-angels-won (progn
                                 (format header-str "THE CELESTIAL COMMUNION WON")
                                 (setf long-text (format nil "The angels were able to destroy the hellish machines of the Pandemonium Hierarchy and close the Prison Dimension. The Communion once again stands vigil to keep the malformed Firstborn inside the confines designated by the One."))))
        (:game-over-military-won (progn
                                   (format header-str "THE MILITARY WON")
                                   (setf long-text (format nil "The humans managed to fend off the hellish invaders and hunt down the traitor who aided them into our world. The scars of the Otherworldly War run deep and the humankind is shaken by cosmic truth that was revealed to it..."))))
        )
      (setf prompt-str (format nil "[Esc] Main menu"))


      ;; display header
      (sdl:draw-string-solid-* header-str (truncate *window-width* 2) 10 :justify :center :color color)

      ;; display ending text
      (sdl:with-rectangle (a-rect (sdl:rectangle :x 30 :y 30 :w (- *window-width* 60) :h (* 1 (sdl:get-font-height))))
        (setf max-lines (write-text long-text a-rect :count-only t)))
      
      (sdl:with-rectangle (a-rect (sdl:rectangle :x 30 :y 30 :w (- *window-width* 60) :h (* max-lines (sdl:get-font-height))))
        (write-text long-text a-rect))

      ;; display prompt
      (sdl:draw-string-solid-* prompt-str
                               10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
      )
    )
  (sdl:update-display))

(defmethod run-window ((win campaign-over-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ;; escape - return to main menu
                       ((sdl:key= key :sdl-key-escape)
                        (game-state-post-scenario->menu)
                        (go-to-start-game)
                        )
                       )
                     )
    (:video-expose-event () (make-output *current-window*))))
