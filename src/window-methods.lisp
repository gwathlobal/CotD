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

(defun update-map-area (&key (rel-x (x *player*)) (rel-y (y *player*)) (rel-z (z *player*)) (array (memo (level *world*))) (max-x-view *max-x-view*) (max-y-view *max-y-view*))
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
		       :back-color (get-single-memo-back-color single-memo)))))))

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
  (run-window *current-window*))

(defun get-text-input (str key mod unicode)
  (declare (ignore key mod))
  (when (> unicode 0)
    (vector-push-extend (code-char unicode) str))
  str)

(defvar *sel-y-offset* 0)
(defvar *sel-x-offset* 4)

(defun draw-selection-list (str-list cur-str str-per-page x y &key (color-list ())
                                                                   (char-height (+ (sdl:char-height sdl:*default-font*) *sel-y-offset*))
                                                                   (str-func #'(lambda (x y color str)
                                                                                 (sdl:draw-string-solid-* str x y :color color))))
  (declare (type list color-list str-list))
  
  (unless str-list
    (return-from draw-selection-list nil))
  
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
      (funcall str-func (+ x (sdl:char-width sdl:*default-font*) *sel-x-offset*) (+ y (* i char-height)) color str)
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

(defun run-selection-list (key mod unicode cur-str)
  (declare (ignore unicode))
  (cond
    ((and (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8)) (= mod 0)) (decf cur-str))
    ((and (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2)) (= mod 0)) (incf cur-str)))
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
  (let ((txt-length (length txt)) (read-pos 0) (x (sdl:x rect)) (y (sdl:y rect)) (eol) (word-length) (row-length-in-pixels 0) (prev-pos) (cur-pos) (read-pos2) (cur-line 0))
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
	 (when (and (eql count-only nil) (>= cur-line start-line))
	   (sdl:draw-string-solid-* (subseq txt prev-pos cur-pos) x y :justify justify :surface surface :font font :color color)
	   (incf y (sdl:char-height font)))
	 (incf cur-line))
    cur-line))

