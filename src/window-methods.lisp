(in-package :cotd)

(defvar *glyph-temp*)
(defvar *glyph-front*)
(defvar *window-width*)
(defvar *window-height*)
(defparameter *temp-rect* nil)
(defparameter *msg-box-window-height* (* 13 5))

(defun draw-glyph (x y n &key (surface sdl:*default-surface*) front-color back-color)
  "Drawing a glyph from 'font.bmp' at a certain point of the surface."
  (declare (type fixnum x y n) (type sdl:color front-color back-color))
  ;; select a rectangle with the glyph to be drawn
  (sdl:set-cell-* (* n *glyph-w*) 0 *glyph-w* *glyph-h* :surface *glyph-front* :index 0)
  
  ;; fill the temporary surface with the desired color of the glyph
  ;; draw the glyph to the temporary surface
  ;; as the transparent color of the src surface is the actual color of the glyph (white), we get the glyph of the desired color on the black background 
  (sdl:fill-surface front-color :surface *glyph-temp*)
  (sdl:draw-surface-at-* *glyph-front* 0 0 :surface *glyph-temp*)
  
  ;; fill the rectangle on the dst surface with the desired color of the background
  ;; draw the glyph from the temporary surface to the dst surface
  ;; as the transparent color of the temporary surface is black, we get the glyph of the desired color on the desired background
  ;; for speed I use this temporary rectangle as this function is invoked about 4000 times or more a frame and otherwise (e.g. using with-rectangle) map rendering slows to a crawl
  
  (setf (sdl:x *temp-rect*) x)
  (setf (sdl:y *temp-rect*) y)
  (setf (sdl:width *temp-rect*) *glyph-w*)
  (setf (sdl:height *temp-rect*) *glyph-h*)
  (sdl:fill-surface back-color :surface surface :template *temp-rect*)
  
  (sdl:draw-surface-at-* *glyph-temp* x y :surface surface))

(defun calculate-start-coord (rel-x rel-y array max-x-view max-y-view)
  "Calculate the top-left corner of the visible area. Used to draw the map and to choose objects on it."
  (let* ((array-max-x (first (array-dimensions array))) (array-max-y (second (array-dimensions array)))
	 (max-x (min array-max-x max-x-view)) (max-y (min array-max-y max-y-view))
	 (sx 0) (sy 0))
	 
     (declare (type fixnum sx sy max-x max-y))
     
     (setf sx (if (< (- rel-x (truncate max-x 2)) 1) 0 (- rel-x (truncate max-x 2))))
     (setf sy (if (< (- rel-y (truncate max-y 2)) 1) 0 (- rel-y (truncate max-y 2))))
     (when (> (+ sx max-x) array-max-x) (setf sx (- array-max-x max-x)))
     (when (> (+ sy max-y) array-max-y) (setf sy (- array-max-y max-y)))
     ;;(format t "rel = (~A, ~A), s = (~A, ~A)~%" rel-x rel-y sx sy)
     (values sx sy max-x max-y)))

(defun update-map-area (&key (rel-x (x *player*)) (rel-y (y *player*)) (rel-z (z *player*)) (array (memo (level *world*))) (max-x-view *max-x-view*) (max-y-view *max-y-view*)
                             (post-func #'(lambda (x y x1 y1) (declare (ignore x y x1 y1)) nil)))
  (declare (optimize (speed 3)))
  ;; draw the level
   (let* ((x1 0) (y1 0) (glyph-w *glyph-w*) (glyph-h *glyph-h*) (single-memo))
     (declare (type fixnum x1 y1 rel-x rel-y glyph-w glyph-h))

     (multiple-value-bind (sx sy max-x max-y) (calculate-start-coord rel-x rel-y array max-x-view max-y-view)
       (declare (type fixnum sx sy max-x max-y))
       (dotimes (x max-x)
	 (declare (type fixnum x))
	 (dotimes (y max-y)
	   (declare (type fixnum y))
	   ;; calculate the coordinates where to draw the glyph
	   (setf x1 (+ (* x glyph-w) glyph-w))
	   (setf y1 (+ (* y glyph-h) glyph-h))
	   ;; select the object, the glyph of which shall be drawn
	   (setf single-memo (aref array (+ sx x) (+ sy y) rel-z))
	   ;;(when (and (eql (get-single-memo-visible single-memo) nil) 
	   ;;      (not (eql (glyph object) (map-object-template-glyph (get-map-object-template +glyph-blank+)))))
	   ;;  (setf (glyph-color object) (sdl:color :r 140 :b 140 :g 140))
	   ;;  (setf (back-color object) (sdl:color :r 30 :b 30 :g 30)))
	   ;; draw the glyph
	   
	   (draw-glyph x1 y1 (get-single-memo-glyph-idx single-memo) 
		       :front-color (get-single-memo-glyph-color single-memo) 
		       :back-color (get-single-memo-back-color single-memo))

           (funcall post-func (+ sx x) (+ sy y) x1 y1)

           (when (get-single-memo-player single-memo)
             (highlight-map-tile x1 y1)))))))

(defun highlight-map-tile (x1 y1)
  (let ((color (sdl:color :r 85 :g 107 :b 47)))
    ;; draw the rectangle
    (sdl:draw-pixel-* (+ x1 1) y1 :color color)
    (sdl:draw-pixel-* (+ x1 2) y1 :color color)
    (sdl:draw-pixel-* x1 (+ y1 1) :color color)
    (sdl:draw-pixel-* x1 (+ y1 2) :color color)

    (sdl:draw-pixel-* (- (+ x1 (1- *glyph-w*)) 1) y1 :color color)
    (sdl:draw-pixel-* (- (+ x1 (1- *glyph-w*)) 2) y1 :color color)
    (sdl:draw-pixel-* (+ x1 (1- *glyph-w*)) (+ y1 1) :color color)
    (sdl:draw-pixel-* (+ x1 (1- *glyph-w*)) (+ y1 2) :color color)

    (sdl:draw-pixel-* (+ x1 1) (+ y1 (1- *glyph-h*)) :color color)
    (sdl:draw-pixel-* (+ x1 2) (+ y1 (1- *glyph-h*)) :color color)
    (sdl:draw-pixel-* x1 (- (+ y1 (1- *glyph-h*)) 1) :color color)
    (sdl:draw-pixel-* x1 (- (+ y1 (1- *glyph-h*)) 2) :color color)

    (sdl:draw-pixel-* (- (+ x1 (1- *glyph-w*)) 1) (+ y1 (1- *glyph-h*)) :color color)
    (sdl:draw-pixel-* (- (+ x1 (1- *glyph-w*)) 2) (+ y1 (1- *glyph-h*)) :color color)
    (sdl:draw-pixel-* (+ x1 (1- *glyph-w*)) (- (+ y1 (1- *glyph-h*)) 1) :color color)
    (sdl:draw-pixel-* (+ x1 (1- *glyph-w*)) (- (+ y1 (1- *glyph-h*)) 2) :color color)
  ;(sdl:with-rectangle (l-rect (sdl:rectangle :x x1 :y y1 :w 1 :h *glyph-h*))
  ;  (sdl:fill-surface color :template l-rect))
  ;(sdl:with-rectangle (r-rect (sdl:rectangle :x (+ x1 (1- *glyph-w*)) :y y1 :w 1 :h *glyph-h*))
  ;  (sdl:fill-surface color :template r-rect))
  ;(sdl:with-rectangle (t-rect (sdl:rectangle :x x1 :y y1 :w *glyph-w* :h 1))
  ;  (sdl:fill-surface color :template t-rect))
  ;(sdl:with-rectangle (b-rect (sdl:rectangle :x x1 :y (+ y1 (1- *glyph-h*)) :w *glyph-w* :h 1))
  ;  (sdl:fill-surface color :template b-rect))
    ))

(defun check-tile-on-map (map-x map-y map-z sx sy max-x-view max-y-view view-z)
  (if (and (>= map-x sx) (>= map-y sy)
           (< map-x (+ sx max-x-view))
           (< map-y (+ sy max-y-view))
           (= view-z map-z))
    t
    nil))

(defun display-animation-on-map (map-x map-y map-z glyph-idx glyph-color back-color)
  (let ((scr-x 0) (scr-y 0))
    (declare (type fixnum scr-x scr-y))
    
    (when (/= (view-z *player*) map-z)
      (return-from display-animation-on-map nil))

    (multiple-value-bind (sx sy) (calculate-start-coord (x *player*) (y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
      ;; calculate the coordinates where to draw the animation
      
      (setf scr-x (+ (* (- map-x sx) *glyph-w*) *glyph-w*))
      (setf scr-y (+ (* (- map-y sy) *glyph-h*) *glyph-h*))
      ;(format t "MAP-X ~A MAP-Y ~A; SX ~A SY ~A; SCR-X ~A SCR-Y ~A~%" map-x map-y sx sy scr-x scr-y)
      
      ;; drawing glyph
      (draw-glyph scr-x scr-y glyph-idx 
                  :front-color glyph-color
                  :back-color back-color)
      )
    ))

(defun display-cell-on-map (map-x map-y map-z &key (array (memo (level *world*))))
  (let ((scr-x 0) (scr-y 0) (single-memo))
    (declare (type fixnum scr-x scr-y))

    (when (/= (view-z *player*) map-z)
      (return-from display-cell-on-map nil))
    
    (multiple-value-bind (sx sy) (calculate-start-coord (x *player*) (y *player*) (memo (level *world*)) *max-x-view* *max-y-view*)
    ;; calculate the coordinates where to draw the animation
    
      (setf scr-x (+ (* (- map-x sx) *glyph-w*) *glyph-w*))
      (setf scr-y (+ (* (- map-y sy) *glyph-h*) *glyph-h*))

      (setf single-memo (aref array map-x map-y map-z))
      
      ;; drawing glyph
      (draw-glyph scr-x scr-y (get-single-memo-glyph-idx single-memo) 
                  :front-color (get-single-memo-glyph-color single-memo) 
                  :back-color (get-single-memo-back-color single-memo))
      )
    ))

(defun fill-background-tiles ()
  "Fill the background"
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect)))

(defun create-string (&optional str)
  (let ((new-str (make-array (list 0) :element-type 'character :adjustable t :fill-pointer t)))
    (when str
      (format new-str str))
    new-str))

(defun get-input-player ()
  (run-window *current-window*)
  )

(defun get-text-input (str key mod unicode)
  (declare (ignore key mod))
  (when (> unicode 0)
    (vector-push-extend (code-char unicode) str))
  str)

(defvar *sel-y-offset* 0)
(defvar *sel-x-offset* 4)

(defun draw-selection-list (str-list cur-str str-per-page x y &key (color-list ())
                                                                   (char-height (+ (sdl:char-height sdl:*default-font*) *sel-y-offset*))
                                                                   (str-func #'(lambda (x y color str use-letters)
                                                                                 ;; use-letters here can be
                                                                                 ;;   nil
                                                                                 ;;   (list i str-per-page)
                                                                                 (sdl:draw-string-solid-* (if use-letters
                                                                                                            (if (< (first use-letters) (second use-letters))
                                                                                                              (format nil "[~A]  ~A" (nth (first use-letters) *char-list*) str)
                                                                                                              (format nil "     ~A" str))
                                                                                                            str)
                                                                                                          x y :color color)))
                                                                   (use-letters nil))
  (declare (type list color-list str-list))
  
  (unless str-list
    (return-from draw-selection-list nil))

  
  (when (and use-letters (> str-per-page (length *char-list*)))
    (setf str-per-page (length *char-list*)))
  
  (let* ((color) (str)
	 (list-start (* (truncate cur-str str-per-page) str-per-page))
	 (list-end (if (> (+ list-start str-per-page) (length str-list)) (length str-list) (+ list-start str-per-page))))
    ;; from the start of the current page (determined previously) to the end of the page (or end of list whichever is less)
    (dotimes (i (- list-end list-start))
      (setf str (nth (+ i list-start) str-list))
      ;; highlight the current selected item
      (if (eql color-list nil)
        (setf color sdl:*white*)
        (setf color (nth (+ i list-start) color-list)))
      (funcall str-func (+ x (sdl:char-width sdl:*default-font*) *sel-x-offset*) (+ y (* i char-height)) color str (if use-letters
                                                                                                                     (list i str-per-page)
                                                                                                                     nil))
      )
    ;; draw a scroll bar when necessary
    (when (> (length str-list) str-per-page)
      (sdl:draw-string-solid-* "*" x (+ y (* char-height (truncate (* (/ cur-str (length str-list)) str-per-page)))) :color sdl:*white*))))

(defun draw-multiline-selection-list (item-list cur-item x y w h &optional (color-list ()))
  (unless item-list
    (return-from draw-multiline-selection-list nil))
  
  (sdl:with-rectangle (rect (sdl:rectangle :x x :y y :w (- w 12) :h h))  
    (let ((screen-list ()) (start-item) (is-more-than-one-screen nil))
      ;; assign numbers of screens to the items pertaining to them
      (let ((screen-i 0) (item-h) (is-first t))
        (dotimes (i (length item-list))
	  (setf item-h (* 13 (write-text (nth i item-list) rect :count-only t)))
	  
	  (if (or (> (sdl:height rect) item-h) (and is-first (<= (sdl:height rect) item-h)))
	      (progn
		(setf screen-list (append screen-list (list screen-i)))
		(setf is-first nil)
		(if (> (sdl:height rect) item-h)
		    (progn
		      (incf (sdl:y rect) item-h)
		      (decf (sdl:height rect) item-h))
		    (progn 
		      (incf screen-i)
		      (setf is-more-than-one-screen t))))
	      (progn
		(incf screen-i)
		(setf is-more-than-one-screen t)
		(setf screen-list (append screen-list (list screen-i)))
		(setf (sdl:y rect) y)
		(setf (sdl:height rect) h)
                (incf (sdl:y rect) item-h)
                (decf (sdl:height rect) item-h)
		(setf is-first t)))
	  ))
      
      ;; find the screen by current item
      (dotimes (i (length item-list))
	(when (= (nth i screen-list) (nth cur-item screen-list))
	  (setf start-item i)
	  (return)))
      
      ;; draw the screen found
      (let ((str) (item-h) (color))
        (setf (sdl:y rect) y)
	(setf (sdl:height rect) h)
	;; yes, ugly hack but I was being lazy and did not want to investigate how to create a 'while' statement
	;; iterate through all items until we get to the starting one
	(dotimes (i (- (length item-list) start-item))
	  (if (= (nth (+ i start-item) screen-list) (nth cur-item screen-list))
	      (progn
		(setf str (nth (+ i start-item) item-list))
		;; highlight the current selected item
		(if (eql color-list nil)
		    (setf color sdl:*white*)
		    (setf color (nth (+ i start-item) color-list)))
		(setf item-h (* 13 (write-text str rect :color color :count-only nil)))
		(when (> (sdl:height rect) item-h)
		  (incf (sdl:y rect) item-h)
		  (decf (sdl:height rect) item-h)))
	      (progn
		(return)))))
      ;; draw scroll bar when necessary
      (when is-more-than-one-screen
	(sdl:draw-string-solid-* "*" (- (+ x w) 12) (+ y (truncate (* h (/ cur-item (length item-list))))) :color sdl:*white*)))))

;; I might do something wrong here but I am not sure how I can access this enum otherwise
(defconstant SDL-KEY-MOD-NUM (cffi:foreign-enum-value sdl-cffi::'Sdl-Mod :SDL-KEY-MOD-NUM))

(defun run-selection-list (key mod unicode cur-str &key (start-page 0) (max-str-per-page -1))
  (declare (ignore unicode))

  ;; normalize mod
  (loop while (>= mod sdl-key-mod-num) do
    (decf mod sdl-key-mod-num))
  
  (cond
    ((and (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8)) (= mod 0)) (decf cur-str))
    ((and (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2)) (= mod 0)) (incf cur-str))
    ((and (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8)) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
     (if (= max-str-per-page -1)
       (decf cur-str 10)
       (decf cur-str max-str-per-page)))
    ((and (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2)) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
     (if (= max-str-per-page -1)
       (incf cur-str 10)
       (incf cur-str max-str-per-page)))
    ((and (sdl:key= key :sdl-key-a) (= mod 0) (< 0 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 0)))
    ((and (sdl:key= key :sdl-key-b) (= mod 0) (< 1 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 1)))
    ((and (sdl:key= key :sdl-key-c) (= mod 0) (< 2 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 2)))
    ((and (sdl:key= key :sdl-key-d) (= mod 0) (< 3 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 3)))
    ((and (sdl:key= key :sdl-key-e) (= mod 0) (< 4 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 4)))
    ((and (sdl:key= key :sdl-key-f) (= mod 0) (< 5 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 5)))
    ((and (sdl:key= key :sdl-key-g) (= mod 0) (< 6 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 6)))
    ((and (sdl:key= key :sdl-key-h) (= mod 0) (< 7 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 7)))
    ((and (sdl:key= key :sdl-key-i) (= mod 0) (< 8 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 8)))
    ((and (sdl:key= key :sdl-key-j) (= mod 0) (< 9 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 9)))
    ((and (sdl:key= key :sdl-key-k) (= mod 0) (< 10 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 10)))
    ((and (sdl:key= key :sdl-key-l) (= mod 0) (< 11 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 11)))
    ((and (sdl:key= key :sdl-key-m) (= mod 0) (< 12 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 12)))
    ((and (sdl:key= key :sdl-key-n) (= mod 0) (< 13 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 13)))
    ((and (sdl:key= key :sdl-key-o) (= mod 0) (< 14 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 14)))
    ((and (sdl:key= key :sdl-key-p) (= mod 0) (< 15 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 15)))
    ((and (sdl:key= key :sdl-key-q) (= mod 0) (< 16 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 16)))
    ((and (sdl:key= key :sdl-key-r) (= mod 0) (< 17 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 17)))
    ((and (sdl:key= key :sdl-key-s) (= mod 0) (< 18 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 18)))
    ((and (sdl:key= key :sdl-key-t) (= mod 0) (< 19 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 19)))
    ((and (sdl:key= key :sdl-key-u) (= mod 0) (< 20 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 20)))
    ((and (sdl:key= key :sdl-key-v) (= mod 0) (< 21 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 21)))
    ((and (sdl:key= key :sdl-key-w) (= mod 0) (< 22 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 22)))
    ((and (sdl:key= key :sdl-key-x) (= mod 0) (< 23 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 23)))
    ((and (sdl:key= key :sdl-key-y) (= mod 0) (< 24 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 24)))
    ((and (sdl:key= key :sdl-key-z) (= mod 0) (< 25 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 25))))
  cur-str)

(defun adjust-selection-list (cur-str max-str)
  (when (< cur-str 0) (setf cur-str 0))
  (when (>= cur-str max-str) (setf cur-str (- max-str 1)))
  cur-str)

(defun read-word (txt start-pos)
  (let ((txt-length (length txt)) (was-letter nil) (cur-pos) (word-length) (eol nil))
    (loop named outer finally (setf cur-pos read-pos word-length (- read-pos start-pos))
       for read-pos from start-pos to (1- txt-length) do
	 (cond
	   ((eql (char-code (aref txt read-pos)) (char-code #\Space)) (when (eql was-letter t) (setf cur-pos (incf read-pos) word-length (- read-pos start-pos)) (return-from outer nil)))  
	   ((eql (char-code (aref txt read-pos)) 13)
	    (setf eol t cur-pos read-pos word-length (- read-pos start-pos)) 
            (when (< read-pos (1- txt-length))
	      (incf cur-pos))
	    (return-from outer nil))
	   ((eql (char-code (aref txt read-pos)) 10) (setf eol t cur-pos (1+ read-pos) word-length (- read-pos start-pos)) (return-from outer nil))
	   (t (setf was-letter t))))
    (values cur-pos word-length eol)))

(defun write-text (txt rect &key (surface sdl:*default-surface*) (justify :left) (color sdl:*white*) (font sdl:*default-font*) (count-only nil) (start-line 0))
  (let ((txt-length (length txt)) (read-pos 0) (x (sdl:x rect)) (y (sdl:y rect)) (eol) (word-length) (row-length-in-pixels 0) (prev-pos) (cur-pos) (read-pos2) (cur-line 0)
        (final-txt (create-string)))
    (loop until (or (>= read-pos txt-length) (>= y (+ (sdl:y rect) (sdl:height rect)))) do
	 (setf prev-pos read-pos)
	 (setf cur-pos prev-pos)
	 (multiple-value-setq (read-pos word-length eol) (read-word txt read-pos))
	 (setf row-length-in-pixels (* word-length (sdl:char-width font)))
	 (incf cur-pos word-length)
	 (loop until (or (>= read-pos txt-length) (>= x (+ (sdl:x rect) (sdl:width rect)))) do
	      (when (eql eol t) (loop-finish))
	      (multiple-value-setq (read-pos2 word-length eol) (read-word txt read-pos))
	      (if (< (+ row-length-in-pixels (* word-length (sdl:char-width font))) (sdl:width rect))
		(progn (incf row-length-in-pixels (* word-length (sdl:char-width font))) (setf read-pos read-pos2))
		(progn (loop-finish)))
	      (incf cur-pos word-length))
	 (cond
	   ((eql justify ':left) (setf x (sdl:x rect)))
	   ((eql justify ':center) (setf x (truncate (+ (sdl:x rect) (sdl:width rect)) 2)))
	   ((eql justify ':right) (setf x (+ (sdl:x rect) (sdl:width rect)))))
         (when (and (eql count-only t) (>= cur-line start-line))
           (format final-txt "~A~A~%" (subseq txt prev-pos cur-pos) (new-line)))
	 (when (and (eql count-only nil) (>= cur-line start-line))
	   (sdl:draw-string-solid-* (subseq txt prev-pos cur-pos) x y :justify justify :surface surface :font font :color color)
	   (incf y (sdl:char-height font)))
	 (incf cur-line))
    (values cur-line final-txt)))

(defun pause-for-poll ()
  (sdl:with-events (:poll)
    (:quit-event () (funcall (quit-func *current-window*)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape)
                        (setf *current-window* (make-instance 'select-obj-window 
                                                              :return-to *current-window*
                                                              :header-line "Are you sure you want to quit?"
                                                              :enter-func #'(lambda (cur-sel)
                                                                              (if (= cur-sel 0)
                                                                                (funcall *start-func*)
                                                                                (setf *current-window* (return-to *current-window*)))
                                                                              )
                                                              :line-list (list "Yes" "No")
                                                              :prompt-list (list #'(lambda (cur-sel)
                                                                                     (declare (ignore cur-sel))
                                                                                     "[Enter] Select  [Esc] Exit")
                                                                                 #'(lambda (cur-sel)
                                                                                     (declare (ignore cur-sel))
                                                                                     "[Enter] Select  [Esc] Exit"))))
                        (make-output *current-window*)
                        (run-window *current-window*))
                       )
                     )
    (:video-expose-event () (make-output *current-window*))
    (:idle () (return-from pause-for-poll))))
