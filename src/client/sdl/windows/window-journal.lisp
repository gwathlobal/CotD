(in-package :cotd-sdl)

(defclass journal-window (window)
  ())

(defmethod make-output ((win journal-window))
  (fill-background-tiles)

  (sdl:draw-string-solid-* "JOURNAL" (truncate *window-width* 2) 0 :justify :center)

  (let* ((x 10)
         (y (+ 0 (* 2 (sdl:char-height sdl:*default-font*))))
         (w (- *window-width* 20))
         (h (- *window-height* 20 (sdl:char-height sdl:*default-font*) y))
         (txt-struct (make-colored-txt)))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect)

      (when (find (loyal-faction *player*) (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level *world*))))) :key #'(lambda (a)
                                                                                                                                         (first a)))
        (add-colored-str txt-struct (format nil "~A~%~%~%" (funcall (descr-func (get-game-event-by-id (second (find (loyal-faction *player*) (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level *world*)))))
                                                                                                                    :key #'(lambda (a)
                                                                                                                             (first a)))))))))
        )
      (add-colored-str txt-struct (format nil "Faction relations~%"))
            
      (loop for faction-type across *faction-types*
            when (and faction-type
                      (not (= (id faction-type) (faction *player*))))
              do
                 (add-colored-str txt-struct (format nil "  ~20A : ~A~%" (name faction-type) (if (get-faction-relation (id faction-type) (faction *player*))
                                                                                               "ALLY"
                                                                                               "ENEMY"))))
      
      (write-colored-text (colored-txt-list txt-struct) a-rect))
    )

  (sdl:draw-string-solid-* (format nil "[Esc] Exit")
                           10 (- *window-height* 13 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win journal-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*))
                     
    (:video-expose-event () (make-output *current-window*)))
  )
