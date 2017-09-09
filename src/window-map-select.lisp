(in-package :cotd)

(defconstant +map-select-win-map+ 0)
(defconstant +map-select-win-mobs+ 1)

(defclass map-select-window (cell-window)
  ((max-x :initform 0 :accessor max-x)
   (max-y :initform 0 :accessor max-y)
   (exec-func :initarg :exec-func :accessor exec-func)
   (check-lof :initform nil :initarg :check-lof :accessor check-lof)
   (cmd-str :initarg :cmd-str :accessor cmd-str)
   (cur-sel :initform 0 :accessor cur-sel)
   (sel-list :initform (stable-sort (copy-list (visible-mobs *player*))
                                    #'(lambda (a b)
                                        (if (< (get-distance-3d (x *player*) (y *player*) (z *player*) (x a) (y a) (z a))
                                               (get-distance-3d (x *player*) (y *player*) (z *player*) (x b) (y b) (z b)))
                                          t
                                          nil))
                                    :key #'get-mob-by-id)
             :initarg :sel-list :accessor sel-list)
   (cur-tab :initform +map-select-win-map+ :accessor cur-tab))) ;; map-select-win-... constants

(defmethod initialize-instance :after ((win map-select-window) &key)
  (let ((hostile-mobs))
     ;; find the nearest hostile mob & set it as target
    (loop for mob-id in (visible-mobs *player*)
          when (and (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id (get-mob-by-id mob-id))))))
                    (not (and (riding-mob-id *player*)
                              (= (riding-mob-id *player*) mob-id))))
            do
               (push mob-id hostile-mobs))
    
    (setf hostile-mobs (sort hostile-mobs
                             #'(lambda (mob-1 mob-2)
                                 (if (and (< (get-distance (x *player*) (y *player*) (x mob-1) (y mob-1))
                                             (get-distance (x *player*) (y *player*) (x mob-2) (y mob-2)))
                                          (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-1)))))
                                          (not (get-faction-relation (faction *player*) (faction (get-mob-type-by-id (face-mob-type-id mob-2))))))
                                   t
                                   nil))
                             :key #'(lambda (mob-id)
                                      (get-mob-by-id mob-id))))
    ;(format t "HOSTILE-MOBS ~A~%" hostile-mobs)
    (if hostile-mobs
      (setf (view-x *player*) (x (get-mob-by-id (first hostile-mobs))) (view-y *player*) (y (get-mob-by-id (first hostile-mobs))) (view-z *player*) (z (get-mob-by-id (first hostile-mobs))))
      (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*) (view-z *player*) (z *player*))
    )))

(defun map-select-update (win)
  (update-map-area :rel-x (view-x *player*) :rel-y (view-y *player*) :rel-z (view-z *player*)
                   :post-func #'(lambda (x y x1 y1)
                                  (loop for sound in (heard-sounds *player*) 
                                        when (and (= (sound-x sound) x)
                                                  (= (sound-y sound) y)
                                                  (= (sound-z sound) (view-z *player*)))
                                          do
                                             (draw-glyph x1
                                                         y1
                                                         31
                                                         :front-color sdl:*white*
                                                         :back-color sdl:*black*))))

  ;; drawing the highlighting rectangle around the viewed grid-cell
  (let ((lof-blocked t))
    (let ((x1 0) (y1 0) (color) (tx (view-x *player*)) (ty (view-y *player*)) (tz (view-z *player*)))
      (declare (type fixnum x1 y1))
      (multiple-value-bind (sx sy max-x max-y) (calculate-start-coord (view-x *player*) (view-y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
        (setf (max-x win) max-x (max-y win) max-y)
        ;; calculate the coordinates where to draw the rectangle
        (setf x1 (+ (* (- (view-x *player*) sx) *glyph-w*) *glyph-w*))
        (setf y1 (+ (* (- (view-y *player*) sy) *glyph-h*) *glyph-h*))
        ;;(format t "VIEW X,Y = (~A, ~A); sx, sy = (~A, ~A); x1 , y1 = (~A, ~A)~%" (view-x *player*) (view-y *player*) sx sy x1 y1)

        (when (check-lof win)
          (line-of-sight (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)
                         #'(lambda (dx dy dz prev-cell)
                             (declare (type fixnum dx dy))
                             (let ((exit-result t))
                               (block nil
                                 (setf tx dx ty dy tz dz)

                                 (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                   (setf exit-result 'exit)
                                   (return))
                                 )
                               exit-result))))

        (when (and (= tx (view-x *player*)) (= ty (view-y *player*)) (= tz (view-z *player*)))
          (setf lof-blocked nil))
                   
        ;; adjust color depending on the target
        (if (and (not lof-blocked)
                 (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) 
                 (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                 (check-mob-visible (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) :observer *player*))
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
    (sdl:with-rectangle (obj-list-rect (sdl:rectangle :x 10 :y (- *window-height* *msg-box-window-height* 10) :w (- *window-width* 260 10) :h *msg-box-window-height*))
      (sdl:fill-surface sdl:*black* :template obj-list-rect))
    (let ((str (create-string))
          (feature-list)
          (mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
      (when (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
        ;;(format t "HERE~%")
        (when lof-blocked
          (format str "Line of fire blocked!~%"))
        (format str "~A (~A, ~A, ~A)~A~A~A~A" (capitalize-name (get-terrain-name (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))) (view-x *player*) (view-y *player*) (view-z *player*)
                (if *cotd-release* "" (format nil " Light: ~A+~A"
                                              (get-single-memo-light (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                              (get-outdoor-light-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                (if *cotd-release* "" (format nil " ~A" (aref (aref (connect-map (level *world*)) 1) (view-x *player*) (view-y *player*) (view-z *player*))))
                (if *cotd-release* "" (format nil " ~A" (aref (aref (connect-map (level *world*)) 3) (view-x *player*) (view-y *player*) (view-z *player*))))
                (if *cotd-release* "" (format nil " ~A" (level-cells-connected-p (level *world*) (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)
                                                                                 (if (riding-mob-id *player*)
                                                                                   (map-size (get-mob-by-id (riding-mob-id *player*)))
                                                                                   (map-size *player*))
                                                                                 (get-mob-move-mode *player*))))
                )
        (setf feature-list (get-features-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
        (dolist (feature feature-list)
          (format str ", ~A~A"
                  (capitalize-name (name (get-feature-by-id feature)))
                  (if *cotd-release* "" (format nil " (~A)" (counter (get-feature-by-id feature))))))
        (when (and mob
                   (check-mob-visible mob :observer *player*))
          (format str "~%~A~A~A"
                  (capitalize-name (get-current-mob-name mob))
                  (if (riding-mob-id mob)
                    (format nil ", riding ~A" (capitalize-name (visible-name (get-mob-by-id (riding-mob-id mob)))))
                    "")
                  (if (and (check-lof win) (not lof-blocked))
                    (format nil " (hit: ~D%)" (if (< (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) 2)
                                                100
                                                (truncate (- (r-acc *player*) (* (get-distance (x *player*) (y *player*) (view-x *player*) (view-y *player*)) *acc-loss-per-tile*)))))
                    "")))
        (loop for item-id in (get-items-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
              for item = (get-item-by-id item-id)
              do
                 (format str "~%~A~A"
                         (capitalize-name (name item))
                         (if (> (qty item) 1)
                           (format nil " x~A" (qty item))
                           "")))
                         
                         
        )
      (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* *msg-box-window-height* 20) :w (- *window-width* 260 10) :h (- *msg-box-window-height* (* 2 (sdl:get-font-height)))))
        (write-text str rect)))
  
    ;; drawing the propmt line
    (let ((x 10) (y (- *window-height* 5 (sdl:char-height sdl:*default-font*))) (w (- *window-width* 260 10)) (h (sdl:get-font-height)))
      (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
        (sdl:fill-surface sdl:*black* :template a-rect)
        (cond
          ((= (cur-tab win) +map-select-win-mobs+) (sdl:draw-string-solid-* (format nil "[Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Ctrl+l] Map select  [Esc] Quit") x y :color sdl:*white*))
          ((and (= (cur-tab win) +map-select-win-map+) (sel-list win)) (sdl:draw-string-solid-* (format nil "~A[Ctrl+l] Mob select  [Esc] Quit" (nth +map-select-win-map+ (cmd-str win))) x y :color sdl:*white*))
          (t (sdl:draw-string-solid-* (format nil "~A[Esc] Quit" (first (cmd-str win))) x y :color sdl:*white*)))
        
        ))))

(defmethod make-output ((win map-select-window))
  (fill-background-tiles)
  
  (show-char-properties (+ 20 (* *glyph-w* *max-x-view*)) 10 (idle-calcing win))
  ;(show-small-message-box *glyph-w* (- *window-height* *msg-box-window-height* 10) (+ 250 (+ 10 (* *glyph-w* *max-x-view*))))
  (show-level-weather (+ 20 (* *glyph-w* *max-x-view*)) (+ (- *window-height* *msg-box-window-height* 20) (* -2 (sdl:char-height sdl:*default-font*))))
  (cond
    ((and (= (cur-tab win) +map-select-win-mobs+) (sel-list win))
     (progn
       (let ((color-list)
             )
         (dotimes (i (length (sel-list win)))
           
           (if (= i (cur-sel win)) 
             (setf color-list (append color-list (list sdl:*yellow*)))
             (setf color-list (append color-list (list sdl:*white*)))))
         (draw-selection-list (sel-list win) (cur-sel win) 6 (- *window-width* 260) (- *window-height* *msg-box-window-height* 20)
                              :color-list color-list
                              :char-height (if (> *glyph-h* (+ (sdl:char-height sdl:*default-font*) *sel-y-offset*))
                                                  *glyph-h*
                                                  (+ (sdl:char-height sdl:*default-font*) *sel-y-offset*))
                              :str-func #'(lambda (x y color str use-letters)
                                            ;; the list of strings to display is basically a list of visible mob IDs, so 'str' param is a mob ID here
                                            ;; use-letters here can be
                                            ;;   nil
                                            ;;   (list i str-per-page)
                                            (if use-letters
                                              (progn
                                                (sdl:draw-string-solid-* (if (< (first use-letters) (second use-letters))
                                                                           (format nil "[~A]  " (nth (first use-letters) *char-list*))
                                                                           (format nil "     "))
                                                                         x y :color color)
                                                (draw-visible-mob-func (+ x (* 5 (sdl:char-width sdl:*default-font*))) y (get-mob-by-id str) *player* color))
                                              (progn
                                                (draw-visible-mob-func x y (get-mob-by-id str) *player* color))))
                              :use-letters t))))
    (t (show-visible-mobs (- *window-width* 260) (- *window-height* *msg-box-window-height* 20) 260 *msg-box-window-height* :mob *player* :visible-mobs (sel-list win))))
  
  (map-select-update win)
  
  (sdl:update-display))

(defmethod run-window ((win map-select-window))
  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        
			(cond
                          ((= (cur-tab win) +map-select-win-mobs+)
                           (progn
                             (when (and (sdl:key= key :sdl-key-l) (/= (logand mod sdl-cffi::sdl-key-mod-ctrl) 0))
                               (setf (cur-tab win) +map-select-win-map+))

                             (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) 6) :max-str-per-page 6))
                             (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (sel-list win))))
                             (when (sel-list win)
                               (setf (view-x *player*) (x (get-mob-by-id (nth (cur-sel win) (sel-list win))))
                                     (view-y *player*) (y (get-mob-by-id (nth (cur-sel win) (sel-list win))))
                                     (view-z *player*) (z (get-mob-by-id (nth (cur-sel win) (sel-list win))))))
                             ))
                          (t (progn
                               (when (and (sdl:key= key :sdl-key-l) (/= (logand mod sdl-cffi::sdl-key-mod-ctrl) 0) (sel-list win))
                                 (setf (cur-tab win) +map-select-win-mobs+)
                                 (when (sel-list win)
                                   (setf (view-x *player*) (x (get-mob-by-id (nth (cur-sel win) (sel-list win))))
                                         (view-y *player*) (y (get-mob-by-id (nth (cur-sel win) (sel-list win))))
                                         (view-z *player*) (z (get-mob-by-id (nth (cur-sel win) (sel-list win)))))))
                               
                               ;; move the target rectangle
                               (when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                                 (when (and (< (view-x *player*) (- (array-dimension (terrain (level *world*)) 0) 1)) (> (view-y *player*) 0))
                                   (incf (view-x *player*)) (decf (view-y *player*))))
                               (when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                                 (when (> (view-y *player*) 0)
                                   (decf (view-y *player*))))
                               (when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                                 (when (and (> (view-x *player*) 0) (> (view-y *player*) 0))
                                   (decf (view-x *player*)) (decf (view-y *player*))))
                               (when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                                 (when (< (view-x *player*) (- (array-dimension (terrain (level *world*)) 0) 1))
                                   (incf (view-x *player*))))
                               (when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                                 (when (> (view-x *player*) 0)
                                   (decf (view-x *player*))))
                               (when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                                 (when (and (< (view-x *player*) (- (array-dimension (terrain (level *world*)) 0) 1)) (< (view-y *player*) (- (array-dimension (terrain (level *world*)) 1) 1)))
                                   (incf (view-x *player*)) (incf (view-y *player*))))
                               (when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                                 (when (< (view-y *player*) (- (array-dimension (terrain (level *world*)) 1) 1))
                                   (incf (view-y *player*))))
                               (when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                                 (when (and (> (view-x *player*) 0) (< (view-y *player*) (- (array-dimension (terrain (level *world*)) 1) 1)))
                                   (decf (view-x *player*)) (incf (view-y *player*))))
                               (when (and (sdl:key= key :sdl-key-period) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                 (when (and (> (view-z *player*) 0))
                                   (decf (view-z *player*))))
                               (when (and (sdl:key= key :sdl-key-comma) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                 (when (and (< (view-z *player*) (- (array-dimension (terrain (level *world*)) 2) 1)))
                                   (incf (view-z *player*))))
                               ))
			    )
                        
			(cond
			  ((sdl:key= key :sdl-key-escape) (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*)) (setf *current-window* (return-to win)) (go exit-func))
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter)) (when (funcall (exec-func win))
                                                                                                 (go exit-func)))
			  ;((sdl:key= key :sdl-key-tab) (setf (cur-tab win) (not (cur-tab win))) (setf (cur-inv win) 0))
			  )
			(go exit-func))
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
