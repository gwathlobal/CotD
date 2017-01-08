(in-package :cotd)

(defclass map-select-window (cell-window)
  ((max-x :initform 0 :accessor max-x)
   (max-y :initform 0 :accessor max-y)
   (is-done-once :initform nil :accessor is-done-once)
   (exec-func :initarg :exec-func :accessor exec-func)
   (cmd-str :initarg :cmd-str :accessor cmd-str)
   (cur-inv :initform 0 :accessor cur-inv)
   (cur-tab :initform t :accessor cur-tab))) ; t - map, nil - obj list

(defmethod make-output ((win map-select-window))
  (unless (is-done-once win)
    ;;(format t "VIEW X,Y = (~A, ~A); x , y = (~A, ~A)~%" (view-x *player*) (view-y *player*) (x *player*) (y *player*))
    ;; find the nearest mob & set it as target
    (let ((mob-obj) (first t) (best-mob nil))
      (dolist (mob-id (visible-mobs *player*))
	(setf mob-obj (get-mob-by-id mob-id))
	(when first 
	  (setf best-mob mob-obj)
	  (setf first nil))
	(when (< (get-distance (x *player*) (y *player*) (x mob-obj) (y mob-obj))
		 (get-distance (x *player*) (y *player*) (x best-mob) (y best-mob)))
	  (setf best-mob mob-obj)))
      (if best-mob
	  (progn
	    (setf (view-x *player*) (x best-mob))
	    (setf (view-y *player*) (y best-mob)))
	  (progn
	    (setf (view-x *player*) (x *player*))
	    (setf (view-y *player*) (y *player*))))
    (setf (is-done-once win) t)))

  (update-map-area :rel-x (view-x *player*) :rel-y (view-y *player*))

  ;; drawing the highlighting rectangle around the viewed grid-cell
  (let ((x1 0) (y1 0) (color))
     (declare (type fixnum x1 y1))
     (multiple-value-bind (sx sy max-x max-y) (calculate-start-coord (view-x *player*) (view-y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
       (setf (max-x win) max-x (max-y win) max-y)
       ;; calculate the coordinates where to draw the rectangle
       (setf x1 (+ (* (- (view-x *player*) sx) +glyph-w+) +glyph-w+))
       (setf y1 (+ (* (- (view-y *player*) sy) +glyph-h+) +glyph-h+))
       ;;(format t "VIEW X,Y = (~A, ~A); sx, sy = (~A, ~A); x1 , y1 = (~A, ~A)~%" (view-x *player*) (view-y *player*) sx sy x1 y1)
       ;; adjust color depending on the target
       (if (and (get-mob-* (level *world*) (view-x *player*) (view-y *player*)) 
		(get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*))))
	   (setf color sdl:*red*)
	   (setf color sdl:*yellow*))
       
       
       ;; draw the rectangle
       (sdl:with-rectangle (l-rect (sdl:rectangle :x x1 :y y1 :w 1 :h +glyph-h+))
	 (sdl:fill-surface color :template l-rect))
       (sdl:with-rectangle (r-rect (sdl:rectangle :x (+ x1 (1- +glyph-w+)) :y y1 :w 1 :h +glyph-h+))
	 (sdl:fill-surface color :template r-rect))
       (sdl:with-rectangle (t-rect (sdl:rectangle :x x1 :y y1 :w +glyph-w+ :h 1))
	 (sdl:fill-surface color :template t-rect))
       (sdl:with-rectangle (b-rect (sdl:rectangle :x x1 :y (+ y1 (1- +glyph-h+)) :w +glyph-w+ :h 1))
	 (sdl:fill-surface color :template b-rect))))
  
  ;; drawing a list of objects in the grid-cell instead of a message box
  (sdl:with-rectangle (obj-list-rect (sdl:rectangle :x +glyph-w+ :y (+ 20 (* +glyph-h+ *max-y-view*)) :w (+ 250 (+ 10 (* +glyph-w+ *max-x-view*))) :h *msg-box-window-height*))
    (sdl:fill-surface sdl:*black* :template obj-list-rect))
  (let ((str (create-string)) (feature-list))
    (when (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*)))
      ;;(format t "HERE~%")
      (format str "~A (~A, ~A)" (get-terrain-name (get-terrain-* (level *world*) (view-x *player*) (view-y *player*))) (view-x *player*) (view-y *player*))
      (setf feature-list (get-features-* (level *world*) (view-x *player*) (view-y *player*)))
      (dolist (feature feature-list)
	(format str ", ~A" (name feature)))
      (when (get-mob-* (level *world*) (view-x *player*) (view-y *player*))
	(format str "~%~A [~A]" (get-current-mob-name (get-mob-* (level *world*) (view-x *player*) (view-y *player*))) (id (get-mob-* (level *world*) (view-x *player*) (view-y *player*)))))
      )
    (sdl:with-default-font ((sdl:initialise-default-font sdl:*font-6x13*))
	(write-text str (sdl:rectangle :x +glyph-w+ :y (+ 20 (* +glyph-h+ *max-y-view*)) :w (+ 200 (+ 10 (* +glyph-w+ *max-x-view*))) :h (- *msg-box-window-height* (* 2 +default-font-h+))))))
  
  ;; drawing the propmt line
  (let ((x +glyph-w+) (y (+ 20 (* +glyph-h+ *max-y-view*) (- *msg-box-window-height* +default-font-h+))) (w (+ 200 (+ 10 (* +glyph-w+ *max-x-view*)))) (h +default-font-h+))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect)
      (let ((font (sdl:initialise-default-font sdl:*font-6x13*)))
	(if (cur-tab win)
	    (sdl:draw-string-solid-* (format nil "~A[Esc] Quit" (cmd-str win)) x y :color sdl:*white* :font font)
	    (sdl:draw-string-solid-* (format nil "~A[Esc] Quit" (cmd-str win)) x y :color sdl:*white* :font font)))
      (sdl:update-display))))

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
			  ((sdl:key= key :sdl-key-return) (funcall (exec-func win)) (go exit-func))
			  ;((sdl:key= key :sdl-key-tab) (setf (cur-tab win) (not (cur-tab win))) (setf (cur-inv win) 0))
			  )
			(go exit-func))
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
