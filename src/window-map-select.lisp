(in-package :cotd)

(defclass map-select-window (cell-window)
  ((max-x :initform 0 :accessor max-x)
   (max-y :initform 0 :accessor max-y)
   (exec-func :initarg :exec-func :accessor exec-func)
   (check-lof :initform nil :initarg :check-lof :accessor check-lof)
   (cmd-str :initarg :cmd-str :accessor cmd-str)
   (cur-inv :initform 0 :accessor cur-inv)
   (cur-tab :initform t :accessor cur-tab))) ; t - map, nil - obj list

(defmethod initialize-instance :after ((win map-select-window) &key)
  ;; find the nearest hostile mob & set it as target
  (setf (visible-mobs *player*) (sort (visible-mobs *player*)
                                      #'(lambda (mob-1 mob-2)
                                          (if (and (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-1)))))
                                                   (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-2)))))
                                            t
                                            nil))
                                      :key #'(lambda (mob-id)
                                               (get-mob-by-id mob-id))))
  (setf (visible-mobs *player*) (sort (visible-mobs *player*)
                                      #'(lambda (mob-1 mob-2)
                                          (if (and (< (get-distance (x *player*) (y *player*) (x mob-1) (y mob-1))
                                                      (get-distance (x *player*) (y *player*) (x mob-2) (y mob-2)))
                                                   (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-1)))))
                                                   (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-2))))))
                                            t
                                            nil))
                                      :key #'(lambda (mob-id)
                                               (get-mob-by-id mob-id))))
  (if (and (visible-mobs *player*)
           (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id (get-mob-by-id (first (visible-mobs *player*)))))))))
    (setf (view-x *player*) (x (get-mob-by-id (first (visible-mobs *player*)))) (view-y *player*) (y (get-mob-by-id (first (visible-mobs *player*)))))
    (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*))
    ))

(defun map-select-update (win)
  (update-map-area :rel-x (view-x *player*) :rel-y (view-y *player*))

  ;; drawing the highlighting rectangle around the viewed grid-cell
  (let ((lof-blocked t))
    (let ((x1 0) (y1 0) (color) (tx (view-x *player*)) (ty (view-y *player*)))
      (declare (type fixnum x1 y1))
      (multiple-value-bind (sx sy max-x max-y) (calculate-start-coord (view-x *player*) (view-y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
        (setf (max-x win) max-x (max-y win) max-y)
        ;; calculate the coordinates where to draw the rectangle
        (setf x1 (+ (* (- (view-x *player*) sx) *glyph-w*) *glyph-w*))
        (setf y1 (+ (* (- (view-y *player*) sy) *glyph-h*) *glyph-h*))
        ;;(format t "VIEW X,Y = (~A, ~A); sx, sy = (~A, ~A); x1 , y1 = (~A, ~A)~%" (view-x *player*) (view-y *player*) sx sy x1 y1)

        (when (check-lof win)
          (line-of-sight (x *player*) (y *player*) (view-x *player*) (view-y *player*) #'(lambda (dx dy)
                                                                                           (declare (type fixnum dx dy))
                                                                                           (let ((terrain) (exit-result t))
                                                                                             (block nil
                                                                                               (setf tx dx ty dy)
                                                                                               (when (or (< dx 0) (>= dx *max-x-level*)
                                                                                                         (< dy 0) (>= dy *max-y-level*))
                                                                                                 (setf exit-result 'exit)
                                                                                                 (return))
                                                                                               
                                                                                               (setf terrain (get-terrain-* (level *world*) dx dy))
                                                                                               (unless terrain
                                                                                                 (setf exit-result 'exit)
                                                                                                 (return))
                                                                                               (when (get-terrain-type-trait terrain +terrain-trait-blocks-projectiles+)
                                                                                                 (setf exit-result 'exit)
                                                                                                 (return))
                                                                                               )
                                                                                             exit-result))))

        (when (and (= tx (view-x *player*)) (= ty (view-y *player*)))
          (setf lof-blocked nil))
                   
        ;; adjust color depending on the target
        (if (and (not lof-blocked)
                 (get-mob-* (level *world*) (view-x *player*) (view-y *player*)) 
                 (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*))))
          (setf color sdl:*red*)
          (setf color sdl:*yellow*))
        
       
        ;; draw the rectangle
        (sdl:with-rectangle (l-rect (sdl:rectangle :x x1 :y y1 :w 1 :h *glyph-h*))
          (sdl:fill-surface color :template l-rect))
        (sdl:with-rectangle (r-rect (sdl:rectangle :x (+ x1 (1- *glyph-w*)) :y y1 :w 1 :h *glyph-h*))
          (sdl:fill-surface color :template r-rect))
        (sdl:with-rectangle (t-rect (sdl:rectangle :x x1 :y y1 :w *glyph-w* :h 1))
          (sdl:fill-surface color :template t-rect))
        (sdl:with-rectangle (b-rect (sdl:rectangle :x x1 :y (+ y1 (1- *glyph-h*)) :w *glyph-w* :h 1))
          (sdl:fill-surface color :template b-rect))))
    
    ;; drawing a list of objects in the grid-cell instead of a message box
    (sdl:with-rectangle (obj-list-rect (sdl:rectangle :x 10 :y (- *window-height* *msg-box-window-height* 10) :w (- *window-width* 20) :h *msg-box-window-height*))
      (sdl:fill-surface sdl:*black* :template obj-list-rect))
    (let ((str (create-string))
          (feature-list)
          (mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*))))
      (when (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*)))
        ;;(format t "HERE~%")
        (when lof-blocked
          (format str "Line of fire blocked!~%"))
        (format str "~A (~A, ~A)" (get-terrain-name (get-terrain-* (level *world*) (view-x *player*) (view-y *player*))) (view-x *player*) (view-y *player*))
        (setf feature-list (get-features-* (level *world*) (view-x *player*) (view-y *player*)))
        (dolist (feature feature-list)
          (format str ", ~A" (name feature)))
        (when mob
          (format str "~%~A~A~A"
                  (get-current-mob-name mob)
                  (if (riding-mob-id mob)
                    (format nil ", riding ~A" (get-current-mob-name (get-mob-by-id (riding-mob-id mob))))
                    "")
                  (if (and (check-lof win) (not lof-blocked))
                    (format nil " (hit: ~D%)" (if (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                100
                                                (truncate (- (r-acc *player*) (* (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) *acc-loss-per-tile*)))))
                    "")))
        (loop for item-id in (get-items-* (level *world*) (view-x *player*) (view-y *player*))
              for item = (get-item-by-id item-id)
              do
                 (format str "~%~A" (name item)))
                         
                         
        )
      (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* *msg-box-window-height* 10) :w (- *window-width* 20) :h (- *msg-box-window-height* (* 2 (sdl:get-font-height)))))
        (write-text str rect)))
  
    ;; drawing the propmt line
    (let ((x 10) (y (- *window-height* 10 (sdl:char-height sdl:*default-font*))) (w (- *window-width* 20)) (h (sdl:get-font-height)))
      (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
        (sdl:fill-surface sdl:*black* :template a-rect)
        (if (cur-tab win)
          (sdl:draw-string-solid-* (format nil "~A[Esc] Quit" (cmd-str win)) x y :color sdl:*white*)
          (sdl:draw-string-solid-* (format nil "~A[Esc] Quit" (cmd-str win)) x y :color sdl:*white*))
        ))))

(defmethod make-output ((win map-select-window))
  (fill-background-tiles)
  
  (show-char-properties (+ 20 (* *glyph-w* *max-x-view*)) 10 (idle-calcing win))
  ;(show-small-message-box *glyph-w* (- *window-height* *msg-box-window-height* 10) (+ 250 (+ 10 (* *glyph-w* *max-x-view*))))
  
  (map-select-update win)
  
  (sdl:update-display))

(defmethod run-window ((win map-select-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
			
			(if (cur-tab win)
			    (progn
			      ;; move the target rectangle
			      (when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
				(when (and (< (view-x *player*) (- *max-x-level* 1)) (> (view-y *player*) 0))
				  (incf (view-x *player*)) (decf (view-y *player*))))
			      (when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
				(when (> (view-y *player*) 0)
				  (decf (view-y *player*))))
			      (when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
				(when (and (> (view-x *player*) 0) (> (view-y *player*) 0))
				  (decf (view-x *player*)) (decf (view-y *player*))))
			      (when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
				(when (< (view-x *player*) (- *max-x-level* 1))
				  (incf (view-x *player*))))
			      (when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
				(when (> (view-x *player*) 0)
				  (decf (view-x *player*))))
			      (when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
				(when (and (< (view-x *player*) (- *max-x-level* 1)) (< (view-y *player*) (- *max-y-level* 1)))
				  (incf (view-x *player*)) (incf (view-y *player*))))
			      (when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
				(when (< (view-y *player*) (- *max-y-level* 1))
                                  (incf (view-y *player*))))
			      (when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
				(when (and (> (view-x *player*) 0) (< (view-y *player*) (- *max-y-level* 1)))
				  (decf (view-x *player*)) (incf (view-y *player*))))
			      )
			    (progn
			      (setf (cur-inv win) (run-selection-list key mod unicode (cur-inv win)))))
                        
			(cond
			  ((sdl:key= key :sdl-key-escape) (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*)) (setf *current-window* (return-to win)) (go exit-func))
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter)) (when (funcall (exec-func win))
                                                                                                 (go exit-func)))
			  ;((sdl:key= key :sdl-key-tab) (setf (cur-tab win) (not (cur-tab win))) (setf (cur-inv win) 0))
			  )
			(go exit-func))
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
