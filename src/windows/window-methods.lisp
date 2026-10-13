(in-package :cotd)

(defvar *glyph-front*)
(defvar *window-width*)
(defvar *window-height*)
(defparameter *temp-rect* nil)
(defparameter *msg-box-window-height* (* 13 5))
(defvar *start-logo*)

(defparameter *sdl-color-cache* (make-hash-table :test 'eql)
  "packed-color -> cotd-render:color, so each distinct colour allocates at most once.")

(defun sdl-color (packed)
  "The one boundary converting a packed-color to the cotd-render:color the renderer needs."
  (declare (type packed-color packed) (optimize (speed 3)))
  (or (gethash packed *sdl-color-cache*)
      (setf (gethash packed *sdl-color-cache*)
            (cotd-render:color :r (ldb (byte 8 16) packed)
                       :g (ldb (byte 8 8) packed)
                       :b (ldb (byte 8 0) packed)))))

(defparameter *glyph-strip-cache* (make-hash-table :test 'eql)
  "Font strips pre-tinted with a glyph colour, keyed on the packed colour.

Keyed by the packed-color integer (eql) rather than identity: every glyph/back
colour in play is now a plain fixnum, so equal colours always share a strip -
no more near-duplicate strips for two equal-but-distinct colour objects.")

(defun reset-glyph-strip-cache ()
  "Drop the tinted strips. Call after (re)loading *glyph-front*."
  (clrhash *glyph-strip-cache*))

(defun init-glyph-front ()
  "Load the font strip and the render globals DRAW-GLYPH/UPDATE-MAP-AREA need
\(*GLYPH-W*, *GLYPH-H*, *GLYPH-FRONT*, *TEMP-RECT*). Shared by COTD-INIT and
the headless render oracle in headless-test.lisp, which needs these same
globals but none of COTD-INIT's options/highscores/window-caption setup."
  (setf *glyph-w* 15 *glyph-h* 15)
  (setf *temp-rect* (sdl::rectangle-from-edges-* 0 0 *glyph-w* *glyph-h*))
  (setf *glyph-front* (cotd-render:load-image (cotd-render:create-path "data/font_large.bmp" *asset-dir*)
                                      :color-key cotd-render:*white*))
  ;; the tinted strips are derived from *glyph-front*, so drop them with it
  (reset-glyph-strip-cache))

(defun colorized-glyph-strip (front-color)
  "The whole font strip tinted with FRONT-COLOR (a packed-color), built once per colour.

The tinting is what draw-glyph used to redo per glyph: fill a surface with the
glyph colour, then blit the font over it. White is the font's colour key, so
the fill shows through the glyph shape and the surround stays black; black is
this surface's colour key, so blitting it leaves only the glyph. None of that
depends on which glyph or where it goes, so it is done once per colour instead
of 4000 times a frame."
  (or (gethash front-color *glyph-strip-cache*)
      (setf (gethash front-color *glyph-strip-cache*)
              (let ((strip (cotd-render:create-surface (cotd-render:width *glyph-front*)
                                               (cotd-render:height *glyph-front*)
                                               :color-key cotd-render:*black*)))
                (cotd-render:fill-surface (sdl-color front-color) :surface strip)
                (cotd-render:set-cell-* 0 0 (cotd-render:width *glyph-front*) (cotd-render:height *glyph-front*)
                                :surface *glyph-front* :index 0)
                (cotd-render:draw-surface-at-* *glyph-front* 0 0 :surface strip)
                strip))))

(defun draw-glyph (x y n &key (surface cotd-render:*default-surface*) front-color back-color)
  "Drawing a glyph from 'font.bmp' at a certain point of the surface."
  (declare (type fixnum x y n) (type packed-color front-color back-color))
  (let ((strip (colorized-glyph-strip front-color)))
    ;; select the rectangle holding this glyph, already in the right colour
    (cotd-render:set-cell-* (* n *glyph-w*) 0 *glyph-w* *glyph-h* :surface strip :index 0)

    ;; fill the rectangle on the dst surface with the desired background colour,
    ;; then blit the glyph over it. Black is the strip's colour key, so only the
    ;; glyph itself lands.
    ;; for speed I use this temporary rectangle as this function is invoked about 4000 times or more a frame and otherwise (e.g. using with-rectangle) map rendering slows to a crawl
    (setf (cotd-render:x *temp-rect*) x)
    (setf (cotd-render:y *temp-rect*) y)
    (setf (cotd-render:width *temp-rect*) *glyph-w*)
    (setf (cotd-render:height *temp-rect*) *glyph-h*)
    (cotd-render:fill-surface (sdl-color back-color) :surface surface :template *temp-rect*)

    (cotd-render:draw-surface-at-* strip x y :surface surface)))

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

(defun update-map-area (start-x start-y &key (rel-x (x *player*)) (rel-y (y *player*)) (rel-z (z *player*)) (array (memo (level *world*))) (max-x-view *max-x-view*) (max-y-view *max-y-view*)
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
	   (setf x1 (+ (* x glyph-w) start-x))
	   (setf y1 (+ (* y glyph-h) start-y))
	   ;; select the object, the glyph of which shall be drawn
	   (setf single-memo (aref array (+ sx x) (+ sy y) rel-z))
	   ;;(when (and (eql (get-single-memo-visible single-memo) nil) 
	   ;;      (not (eql (glyph object) (map-object-template-glyph (get-map-object-template +glyph-blank+)))))
	   ;;  (setf (glyph-color object) (cotd-render:color :r 140 :b 140 :g 140))
	   ;;  (setf (back-color object) (cotd-render:color :r 30 :b 30 :g 30)))
	   ;; draw the glyph
	   
	   (draw-glyph x1 y1 (get-single-memo-glyph-idx single-memo) 
		       :front-color (get-single-memo-glyph-color single-memo) 
		       :back-color (get-single-memo-back-color single-memo))

           (funcall post-func (+ sx x) (+ sy y) x1 y1)

           (when (get-single-memo-player single-memo)
             (highlight-map-tile x1 y1)))))))

(defun highlight-left-top-corner (x1 y1 &key (color cotd-render:*yellow*))
  (cotd-render:draw-pixel-* (+ x1 1) y1 :color color)
  (cotd-render:draw-pixel-* (+ x1 2) y1 :color color)
  (cotd-render:draw-pixel-* x1 (+ y1 1) :color color)
  (cotd-render:draw-pixel-* x1 (+ y1 2) :color color))

(defun highlight-left-bottom-corner (x1 y1 &key (color cotd-render:*yellow*))
  (cotd-render:draw-pixel-* (+ x1 1) y1 :color color)
  (cotd-render:draw-pixel-* (+ x1 2) y1 :color color)
  (cotd-render:draw-pixel-* x1 (- y1 1) :color color)
  (cotd-render:draw-pixel-* x1 (- y1 2) :color color))

(defun highlight-right-top-corner (x1 y1 &key (color cotd-render:*yellow*))
  (cotd-render:draw-pixel-* (- x1 1) y1 :color color)
  (cotd-render:draw-pixel-* (- x1 2) y1 :color color)
  (cotd-render:draw-pixel-* x1 (+ y1 1) :color color)
  (cotd-render:draw-pixel-* x1 (+ y1 2) :color color))

(defun highlight-right-bottom-corner (x1 y1 &key (color cotd-render:*yellow*))
  (cotd-render:draw-pixel-* (- x1 1) y1 :color color)
  (cotd-render:draw-pixel-* (- x1 2) y1 :color color)
  (cotd-render:draw-pixel-* x1 (- y1 1) :color color)
  (cotd-render:draw-pixel-* x1 (- y1 2) :color color))

(defun highlight-map-tile (x1 y1)
  (let ((color (cotd-render:color :r 85 :g 107 :b 47)))
    ;; draw the rectangle
    (highlight-left-top-corner x1 y1 :color color)

    (highlight-left-bottom-corner x1 (+ y1 (1- *glyph-h*)) :color color)

    (highlight-right-top-corner (+ x1 (1- *glyph-w*)) y1 :color color)

    (highlight-right-bottom-corner (+ x1 (1- *glyph-w*)) (+ y1 (1- *glyph-h*)) :color color)
    ))

(defun highlight-world-map-tile (x1 y1)
  (let ((color cotd-render:*yellow*))
    ;; draw the rectangle
    (highlight-left-top-corner x1 y1 :color color)

    (highlight-left-bottom-corner x1 (+ y1 (* *glyph-h* 5) -1) :color color)

    (highlight-right-top-corner (+ x1 (* *glyph-w* 5) -1) y1 :color color)

    (highlight-right-bottom-corner (+ x1 (* *glyph-w* 5) -1) (+ y1 (* *glyph-h* 5) -1) :color color)
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
      
      (setf scr-x (+ (* (- map-x sx) *glyph-w*) *start-map-x*))
      (setf scr-y (+ (* (- map-y sy) *glyph-h*)))
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
    
      (setf scr-x (+ (* (- map-x sx) *glyph-w*) *start-map-x*))
      (setf scr-y (+ (* (- map-y sy) *glyph-h*)))

      (setf single-memo (aref array map-x map-y map-z))
      
      ;; drawing glyph
      (draw-glyph scr-x scr-y (get-single-memo-glyph-idx single-memo) 
                  :front-color (get-single-memo-glyph-color single-memo) 
                  :back-color (get-single-memo-back-color single-memo))
      )
    ))

(defun fill-background-tiles ()
  "Fill the background"
  (cotd-render:with-rectangle (a-rect (cotd-render:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (cotd-render:fill-surface cotd-render:*black* :template a-rect)))

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
                                                                   (char-height (+ (cotd-render:char-height cotd-render:*default-font*) *sel-y-offset*))
                                                                   (str-func #'(lambda (x y color str use-letters)
                                                                                 ;; use-letters here can be
                                                                                 ;;   nil
                                                                                 ;;   (list i str-per-page)
                                                                                 (cotd-render:draw-string-solid-* (if use-letters
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
        (setf color cotd-render:*white*)
        (setf color (nth (+ i list-start) color-list)))
      (funcall str-func (+ x (cotd-render:char-width cotd-render:*default-font*) *sel-x-offset*) (+ y (* i char-height)) color str (if use-letters
                                                                                                                     (list i str-per-page)
                                                                                                                     nil))
      )
    ;; draw a scroll bar when necessary
    (when (> (length str-list) str-per-page)
      (cotd-render:draw-string-solid-* "*" x (+ y (* char-height (truncate (* (/ cur-str (length str-list)) str-per-page)))) :color cotd-render:*white*))))

(defun draw-multiline-selection-list (item-list cur-item x y w h &optional (color-list ()))
  (unless item-list
    (return-from draw-multiline-selection-list nil))
  
  (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x :y y :w (- w 12) :h h))  
    (let ((screen-list ()) (start-item) (is-more-than-one-screen nil))
      ;; assign numbers of screens to the items pertaining to them
      (let ((screen-i 0) (item-h) (is-first t))
        (dotimes (i (length item-list))
	  (setf item-h (* 13 (write-text (nth i item-list) rect :count-only t)))
	  
	  (if (or (> (cotd-render:height rect) item-h) (and is-first (<= (cotd-render:height rect) item-h)))
	      (progn
		(setf screen-list (append screen-list (list screen-i)))
		(setf is-first nil)
		(if (> (cotd-render:height rect) item-h)
		    (progn
		      (incf (cotd-render:y rect) item-h)
		      (decf (cotd-render:height rect) item-h))
		    (progn 
		      (incf screen-i)
		      (setf is-more-than-one-screen t))))
	      (progn
		(incf screen-i)
		(setf is-more-than-one-screen t)
		(setf screen-list (append screen-list (list screen-i)))
		(setf (cotd-render:y rect) y)
		(setf (cotd-render:height rect) h)
                (incf (cotd-render:y rect) item-h)
                (decf (cotd-render:height rect) item-h)
		(setf is-first t)))
	  ))
      
      ;; find the screen by current item
      (dotimes (i (length item-list))
	(when (= (nth i screen-list) (nth cur-item screen-list))
	  (setf start-item i)
	  (return)))
      
      ;; draw the screen found
      (let ((str) (item-h) (color))
        (setf (cotd-render:y rect) y)
	(setf (cotd-render:height rect) h)
	;; yes, ugly hack but I was being lazy and did not want to investigate how to create a 'while' statement
	;; iterate through all items until we get to the starting one
	(dotimes (i (- (length item-list) start-item))
	  (if (= (nth (+ i start-item) screen-list) (nth cur-item screen-list))
	      (progn
		(setf str (nth (+ i start-item) item-list))
		;; highlight the current selected item
		(if (eql color-list nil)
		    (setf color cotd-render:*white*)
		    (setf color (nth (+ i start-item) color-list)))
		(setf item-h (* 13 (write-text str rect :color color :count-only nil)))
		(when (> (cotd-render:height rect) item-h)
		  (incf (cotd-render:y rect) item-h)
		  (decf (cotd-render:height rect) item-h)))
	      (progn
		(return)))))
      ;; draw scroll bar when necessary
      (when is-more-than-one-screen
	(cotd-render:draw-string-solid-* "*" (- (+ x w) 12) (+ y (truncate (* h (/ cur-item (length item-list))))) :color cotd-render:*white*)))))

(defun run-selection-list (key mod unicode cur-str &key (start-page 0) (max-str-per-page -1) (use-letters t))
  (declare (ignore unicode))

  ;; normalize mod
  (setf mod (normalize-key-mod mod))
  
  (cond
    ((and (or (key= key :key-up) (key= key :key-kp8)) (key-mod-none-p mod)) (decf cur-str))
    ((and (or (key= key :key-down) (key= key :key-kp2)) (key-mod-none-p mod)) (incf cur-str))
    ((and (or (key= key :key-up) (key= key :key-kp8)) (key-mod-shift-p mod))
     (if (= max-str-per-page -1)
       (decf cur-str 10)
       (decf cur-str max-str-per-page)))
    ((and (or (key= key :key-down) (key= key :key-kp2)) (key-mod-shift-p mod))
     (if (= max-str-per-page -1)
       (incf cur-str 10)
       (incf cur-str max-str-per-page)))
    ((and use-letters (key= key :key-a) (key-mod-none-p mod) (< 0 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 0)))
    ((and use-letters (key= key :key-b) (key-mod-none-p mod) (< 1 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 1)))
    ((and use-letters (key= key :key-c) (key-mod-none-p mod) (< 2 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 2)))
    ((and use-letters (key= key :key-d) (key-mod-none-p mod) (< 3 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 3)))
    ((and use-letters (key= key :key-e) (key-mod-none-p mod) (< 4 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 4)))
    ((and use-letters (key= key :key-f) (key-mod-none-p mod) (< 5 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 5)))
    ((and use-letters (key= key :key-g) (key-mod-none-p mod) (< 6 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 6)))
    ((and use-letters (key= key :key-h) (key-mod-none-p mod) (< 7 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 7)))
    ((and use-letters (key= key :key-i) (key-mod-none-p mod) (< 8 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 8)))
    ((and use-letters (key= key :key-j) (key-mod-none-p mod) (< 9 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 9)))
    ((and use-letters (key= key :key-k) (key-mod-none-p mod) (< 10 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 10)))
    ((and use-letters (key= key :key-l) (key-mod-none-p mod) (< 11 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 11)))
    ((and use-letters (key= key :key-m) (key-mod-none-p mod) (< 12 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 12)))
    ((and use-letters (key= key :key-n) (key-mod-none-p mod) (< 13 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 13)))
    ((and use-letters (key= key :key-o) (key-mod-none-p mod) (< 14 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 14)))
    ((and use-letters (key= key :key-p) (key-mod-none-p mod) (< 15 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 15)))
    ((and use-letters (key= key :key-q) (key-mod-none-p mod) (< 16 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 16)))
    ((and use-letters (key= key :key-r) (key-mod-none-p mod) (< 17 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 17)))
    ((and use-letters (key= key :key-s) (key-mod-none-p mod) (< 18 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 18)))
    ((and use-letters (key= key :key-t) (key-mod-none-p mod) (< 19 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 19)))
    ((and use-letters (key= key :key-u) (key-mod-none-p mod) (< 20 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 20)))
    ((and use-letters (key= key :key-v) (key-mod-none-p mod) (< 21 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 21)))
    ((and use-letters (key= key :key-w) (key-mod-none-p mod) (< 22 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 22)))
    ((and use-letters (key= key :key-x) (key-mod-none-p mod) (< 23 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 23)))
    ((and use-letters (key= key :key-y) (key-mod-none-p mod) (< 24 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 24)))
    ((and use-letters (key= key :key-z) (key-mod-none-p mod) (< 25 max-str-per-page)) (setf cur-str (+ (* start-page max-str-per-page) 25))))
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

(defun write-text (txt rect &key (surface cotd-render:*default-surface*) (justify :left) (color cotd-render:*white*) (font cotd-render:*default-font*) (count-only nil) (start-line 0))
  (let ((txt-length (length txt)) (read-pos 0) (x (cotd-render:x rect)) (y (cotd-render:y rect)) (eol) (word-length) (row-length-in-pixels 0) (prev-pos) (cur-pos) (read-pos2) (cur-line 0)
        (final-txt (create-string)))
    (loop until (or (>= read-pos txt-length) (>= y (+ (cotd-render:y rect) (cotd-render:height rect)))) do
	 (setf prev-pos read-pos)
	 (setf cur-pos prev-pos)
	 (multiple-value-setq (read-pos word-length eol) (read-word txt read-pos))
	 (setf row-length-in-pixels (* word-length (cotd-render:char-width font)))
	 (incf cur-pos word-length)
	 (loop until (or (>= read-pos txt-length) (>= x (+ (cotd-render:x rect) (cotd-render:width rect)))) do
	      (when (eql eol t) (loop-finish))
	      (multiple-value-setq (read-pos2 word-length eol) (read-word txt read-pos))
	      (if (< (+ row-length-in-pixels (* word-length (cotd-render:char-width font))) (cotd-render:width rect))
		(progn (incf row-length-in-pixels (* word-length (cotd-render:char-width font))) (setf read-pos read-pos2))
		(progn (loop-finish)))
	      (incf cur-pos word-length))
	 (cond
	   ((eql justify ':left) (setf x (cotd-render:x rect)))
	   ((eql justify ':center) (setf x (truncate (+ (cotd-render:x rect) (cotd-render:width rect)) 2)))
	   ((eql justify ':right) (setf x (+ (cotd-render:x rect) (cotd-render:width rect)))))
         (when (and (eql count-only t) (>= cur-line start-line))
           (format final-txt "~A~A~%" (subseq txt prev-pos cur-pos) (new-line)))
	 (when (and (eql count-only nil) (>= cur-line start-line))
	   (cotd-render:draw-string-solid-* (subseq txt prev-pos cur-pos) x y :justify justify :surface surface :font font :color color)
	   (incf y (cotd-render:char-height font)))
	 (incf cur-line))
    (values cur-line final-txt)))

(defun write-colored-text (txt-struct rect &key (surface cotd-render:*default-surface*) (font cotd-render:*default-font*) (count-only nil) (start-line 0))
  ;;(format t "write-colored-text~%")
  (let ((x (cotd-render:x rect)) (y (cotd-render:y rect)) (eol) (word-length) (prev-pos) (cur-pos) (read-pos2) (cur-line 0)
        (final-txt (create-string)))
    (loop for (txt color) in txt-struct
          for txt-length = (length txt)
          for read-pos = 0
          do
             ;;(format t "TXT = ~A~%~%" txt)
             (loop until (or (>= read-pos txt-length) (>= y (+ (cotd-render:y rect) (cotd-render:height rect)))) do
               (setf prev-pos read-pos)
               (setf cur-pos prev-pos)
               (loop until (or (>= read-pos txt-length) (>= x (+ (cotd-render:x rect) (cotd-render:width rect)))) do
                 (when (eql eol t) (loop-finish))
                 (multiple-value-setq (read-pos2 word-length eol) (read-word txt read-pos))
                 (if (< (+ x (* word-length (cotd-render:char-width font))) (+ (cotd-render:x rect) (cotd-render:width rect)))
                   (progn 
                     (setf read-pos read-pos2)
                     ;;(format t "read-pos = ~A, cur-pos = ~A, cur-pos + world-length = ~A " read-pos cur-pos (+ cur-pos word-length))
                     ;;(format t "txt = ~A~%" (subseq txt cur-pos (+ cur-pos word-length)))
                     (when (>= cur-line start-line)
                       (format final-txt "~A" (subseq txt cur-pos (+ cur-pos word-length)))
                       (when (null count-only)
                         (cotd-render:draw-string-solid-* (subseq txt cur-pos (+ cur-pos word-length)) x y :justify :left :surface surface :font font :color color)))
                     (incf x (* word-length (cotd-render:char-width font)))
                     (incf cur-pos word-length))
                   (progn (setf eol t) (loop-finish)))
                     )

               ;;(format t "X = ~A, Y = ~A, EOL = ~A, read-pos = ~A, txt-length = ~A~%" x y eol read-pos txt-length)

               (when eol
                 (setf x (cotd-render:x rect))
                 (setf eol nil)
                 (when (>= cur-line start-line)
                   (format final-txt "~A~%" (new-line))
                   (when (null count-only)
                     (incf y (cotd-render:char-height font))))
                 (incf cur-line))
                   )
          )
    ;;(format t "final-txt = ~A~%" final-txt)
    
    (values cur-line final-txt)))

(defun show-escape-menu ()
  (let ((menu-items ())
        (prompt-list ())
        (enter-func nil)
        (header-str nil))
    (case (game-manager/game-state *game-manager*)
      (:game-state-campaign-scenario (progn
                                       (setf header-str "Scenario Menu")
                                       (setf menu-items (list "Save game & quit" "Abandon mission" "Close"))
                                       (setf prompt-list (list #'(lambda (cur-sel)
                                                                   (declare (ignore cur-sel))
                                                                   "[Enter] Select  [Esc] Exit")
                                                               #'(lambda (cur-sel)
                                                                   (declare (ignore cur-sel))
                                                                   "[Enter] Select  [Esc] Exit")
                                                               #'(lambda (cur-sel)
                                                                   (declare (ignore cur-sel))
                                                                   "[Enter] Select  [Esc] Exit")))
                                       (setf enter-func #'(lambda (cur-sel)
                                                            (case cur-sel
                                                              (0 (progn
                                                                   (save-game-to-disk :save-game-campaign :save-scenario)
                                                                   (game-state-campaign-scenario->menu)
                                                                   (go-to-start-game)
                                                                   ))
                                                              (1 (progn
                                                                   (game-state-campaign-scenario->post-scenario)
                                                                   (go-to-start-game)
                                                                   ))
                                                              (t (progn
                                                                   (setf *current-window* (return-to *current-window*)))))
                                                            ))))
      (:game-state-custom-scenario (progn
                                     (setf header-str "Scenario Menu")
                                     (setf menu-items (list "Save game & quit" "Quit without saving" "Close"))
                                     (setf prompt-list (list #'(lambda (cur-sel)
                                                                 (declare (ignore cur-sel))
                                                                 "[Enter] Select  [Esc] Exit")
                                                             #'(lambda (cur-sel)
                                                                 (declare (ignore cur-sel))
                                                                 "[Enter] Select  [Esc] Exit")
                                                             #'(lambda (cur-sel)
                                                                 (declare (ignore cur-sel))
                                                                 "[Enter] Select  [Esc] Exit")))
                                     (setf enter-func #'(lambda (cur-sel)
                                                          (case cur-sel
                                                            (0 (progn
                                                                 (save-game-to-disk :save-game-scenario :save-scenario)
                                                                 (game-state-custom-scenario->menu)
                                                                 (go-to-start-game)
                                                                 ))
                                                            (1 (progn
                                                                 (game-state-custom-scenario->menu)
                                                                 (go-to-start-game)
                                                                 ))
                                                            (t (progn
                                                                 (setf *current-window* (return-to *current-window*)))))
                                                          ))))
      (:game-state-campaign-map (progn
                                  (setf header-str "Campaign Menu")
                                  (setf menu-items (list "Save campaign & quit" "Quit without saving" "Close"))
                                  (setf prompt-list (list #'(lambda (cur-sel)
                                                              (declare (ignore cur-sel))
                                                              "[Enter] Select  [Esc] Exit")
                                                          #'(lambda (cur-sel)
                                                              (declare (ignore cur-sel))
                                                              "[Enter] Select  [Esc] Exit")
                                                          #'(lambda (cur-sel)
                                                              (declare (ignore cur-sel))
                                                              "[Enter] Select  [Esc] Exit")))
                                  (setf enter-func #'(lambda (cur-sel)
                                                       (case cur-sel
                                                         (0 (progn
                                                              (save-game-to-disk :save-game-campaign :save-campaign)
                                                              (game-state-campaign-map->menu)
                                                              (go-to-start-game)
                                                              ))
                                                         (1 (progn
                                                              (game-state-campaign-map->menu)
                                                              (go-to-start-game)
                                                              ))
                                                         (t (progn
                                                              (setf *current-window* (return-to *current-window*)))))
                                                       )))))
    (setf *current-window* (make-instance 'select-obj-window 
                                          :return-to *current-window*
                                          :header-line header-str
                                          :line-list menu-items
                                          :prompt-list prompt-list
                                          :enter-func enter-func
                                          ))
    (make-output *current-window*)
    (run-window *current-window*)))

(defun pause-for-poll ()
  (cotd-render:with-events (:poll)
    (:quit-event () (funcall (quit-func *current-window*)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ;; escape - quit
                       ((key= key :key-escape)
                        (show-escape-menu))
                       )
                     )
    (:video-expose-event () (make-output *current-window*))
    (:idle () (return-from pause-for-poll))))

(defun draw-world-map-cell (world-sector scr-x scr-y &key (reveal-lair nil))
  (let* ((max-disp-w 5)
         (max-disp-h 5)
         (river-feat (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))
         (sea-feat (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a))))
         (barricade-feat (find +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))
         (satanists-feat (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
         (church-feat (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a))))
         (library-feat (find +lm-feat-library+ (feats world-sector) :key #'(lambda (a) (first a))))
         (machine-feat (find +lm-feat-hell-engine+ (feats world-sector) :key #'(lambda (a) (first a))))
         (flesh-feat (find +lm-feat-hell-flesh-storage+ (feats world-sector) :key #'(lambda (a) (first a))))
         (displayed-cells (make-array (list max-disp-w max-disp-h) :initial-element (list 0 +color-black+ +color-black+)))
         (water-color nil)
         (gray-color (rgb 40 40 40))
         (purple-color (rgb 40 0 40))
         (brown-color (rgb 40 20 0))
         (green-color (rgb 0 40 0)))

    (when *world*
      (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time *world*))
        (declare (ignore year day hour min sec))
        (if (or (= month 11) (= month 0) (= month 1))
          (setf water-color (rgb 0 150 255))
          (setf water-color +color-blue+))))

    (case (wtype world-sector)
      ;; display sea sector
      ((:world-sector-normal-sea)
       (progn
         (setf displayed-cells (make-array (list max-disp-w max-disp-h) :initial-element (list +glyph-id-wall+ +color-blue+ +color-black+)))))
      ;; display island sector
      ((:world-sector-normal-island :world-sector-abandoned-island :world-sector-corrupted-island)
       (progn
         (setf displayed-cells (make-array (list max-disp-w max-disp-h) :initial-element (list +glyph-id-wall+ +color-blue+ +color-black+)))
         (let ((r)
               (color (case (wtype world-sector)
                            (:world-sector-normal-island brown-color)
                            (:world-sector-abandoned-island gray-color)
                            (:world-sector-corrupted-island purple-color)))
               (glyph (case (wtype world-sector)
                            (:world-sector-normal-island +glyph-id-normal-house+)
                            (:world-sector-abandoned-island +glyph-id-abandoned-house+)
                            (:world-sector-corrupted-island +glyph-id-corrupted-house+))))
           (loop for x from 1 to 3 do
             (loop for y from 1 to 3 do
               (setf r (random 8))
               (case r
                 (0 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-1+ color +color-black+)))
                 (1 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-2+ color +color-black+)))
                 (2 (setf (aref displayed-cells x y) (list glyph color +color-black+)))
                 (t (setf (aref displayed-cells x y) (list 0 +color-black+ +color-black+)))))))))
      ;; display outskirts sector
      ((:world-sector-normal-forest :world-sector-abandoned-forest :world-sector-corrupted-forest)
       (progn
         (let ((r)
                (color-tree (case (wtype world-sector)
                              (:world-sector-normal-forest green-color)
                              (:world-sector-abandoned-forest gray-color)
                              (:world-sector-corrupted-forest purple-color)))
                (color-house (case (wtype world-sector)
                               (:world-sector-normal-forest brown-color)
                               (:world-sector-abandoned-forest gray-color)
                               (:world-sector-corrupted-forest purple-color)))
                (glyph (case (wtype world-sector)
                         (:world-sector-normal-forest +glyph-id-normal-tree+)
                         (:world-sector-abandoned-forest +glyph-id-abandoned-tree+)
                         (:world-sector-corrupted-forest +glyph-id-corrupted-tree+))))
           (loop for x from 0 to 4 do
             (loop for y from 0 to 4 do
               (setf r (random 12))
               (case r
                 (0 (setf (aref displayed-cells x y) (list +glyph-id-leaf-tree+ color-tree +color-black+)))
                 (1 (setf (aref displayed-cells x y) (list +glyph-id-pine-tree+ color-tree +color-black+)))
                 (2 (setf (aref displayed-cells x y) (list glyph color-tree +color-black+)))
                 (3 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-1+ color-house +color-black+)))
                 (4 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-2+ color-house +color-black+)))
                 (t (setf (aref displayed-cells x y) (list 0 +color-black+ +color-black+)))))))))
      ;; display residential and seaport district
      ((:world-sector-normal-residential :world-sector-abandoned-residential :world-sector-corrupted-residential :world-sector-normal-port :world-sector-abandoned-port :world-sector-corrupted-port)
       (progn
         (let ((r)
                (color (case (wtype world-sector)
                         ((:world-sector-normal-residential :world-sector-normal-port) brown-color)
                         ((:world-sector-abandoned-residential :world-sector-abandoned-port) gray-color)
                         ((:world-sector-corrupted-residential :world-sector-corrupted-port) purple-color)))
                (glyph (case (wtype world-sector)
                         ((:world-sector-normal-residential :world-sector-normal-port) +glyph-id-normal-house+)
                         ((:world-sector-abandoned-residential :world-sector-abandoned-port) +glyph-id-abandoned-house+)
                         ((:world-sector-corrupted-residential :world-sector-corrupted-port) +glyph-id-corrupted-house+))))
           (loop for x from 0 to 4 do
             (loop for y from 0 to 4 do
               (setf r (random 15))
               (case r
                 (0 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-1+ color +color-black+)))
                 (1 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-2+ color +color-black+)))
                 (2 (setf (aref displayed-cells x y) (list glyph color +color-black+)))
                 (t (setf (aref displayed-cells x y) (list 0 +color-black+ +color-black+)))))))
         
         (when (and sea-feat
                    (or (eq (wtype world-sector) :world-sector-normal-port)
                        (eq (wtype world-sector) :world-sector-abandoned-port)
                        (eq (wtype world-sector) :world-sector-corrupted-port)))
           (when (find :n (second sea-feat))
             (setf (aref displayed-cells 0 1) (list 0 +color-black+ +color-black+))
             (setf (aref displayed-cells 1 1) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 2 1) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 3 1) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 4 1) (list 0 +color-black+ +color-black+)))
           (when (find :s (second sea-feat))
             (setf (aref displayed-cells 0 3) (list 0 +color-black+ +color-black+))
             (setf (aref displayed-cells 1 3) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 2 3) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 3 3) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 4 3) (list 0 +color-black+ +color-black+))
             )
           (when (find :w (second sea-feat))
             (setf (aref displayed-cells 1 0) (list 0 +color-black+ +color-black+))
             (setf (aref displayed-cells 1 1) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 1 2) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 1 3) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 1 4) (list 0 +color-black+ +color-black+)))
           (when (find :e (second sea-feat))
             (setf (aref displayed-cells 3 0) (list 0 +color-black+ +color-black+))
             (setf (aref displayed-cells 3 1) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 3 2) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 3 3) (list +glyph-id-factory-icon+ gray-color +color-black+))
             (setf (aref displayed-cells 3 4) (list 0 +color-black+ +color-black+))))))
      ;; display lake
      ((:world-sector-normal-lake :world-sector-abandoned-lake :world-sector-corrupted-lake)
       (progn
         (let ((r (random 12))
               (color (case (wtype world-sector)
                        (:world-sector-normal-lake brown-color)
                        (:world-sector-abandoned-lake gray-color)
                        (:world-sector-corrupted-lake purple-color)))
               (glyph (case (wtype world-sector)
                        (:world-sector-normal-lake +glyph-id-normal-house+)
                        (:world-sector-abandoned-lake +glyph-id-abandoned-house+)
                        (:world-sector-corrupted-lake +glyph-id-corrupted-house+))))
           (loop for x from 0 to 4 do
             (loop for y from 0 to 4 do
               (setf r (random 12))
               (case r
                 (0 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-1+ color +color-black+)))
                 (1 (setf (aref displayed-cells x y) (list +glyph-id-campaign-house-2+ color +color-black+)))
                 (2 (setf (aref displayed-cells x y) (list glyph color +color-black+)))
                 (t (setf (aref displayed-cells x y) (list 0 +color-black+ +color-black+)))))))))
      )
    
    ;; display barricades
    (when barricade-feat
      (when (find :n (second barricade-feat))
        (setf (aref displayed-cells 0 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 1 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 2 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 3 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+)))
      (when (find :s (second barricade-feat))
        (setf (aref displayed-cells 0 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 1 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 2 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 3 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+)))
      (when (find :w (second barricade-feat))
        (setf (aref displayed-cells 0 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 0 1) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 0 2) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 0 3) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 0 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+)))
      (when (find :e (second barricade-feat))
        (setf (aref displayed-cells 4 0) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 1) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 2) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 3) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))
        (setf (aref displayed-cells 4 4) (list +glyph-id-hash+ (rgb 139 69 19) +color-black+))))

    ;; display rivers
    (when river-feat
      (when (find :n (second river-feat))
        (setf (aref displayed-cells 2 0) (list +glyph-id-vertical-river+ water-color +color-black+))
        (setf (aref displayed-cells 2 1) (list +glyph-id-vertical-river+ water-color +color-black+)))
      (when (find :s (second river-feat))
        (setf (aref displayed-cells 2 3) (list +glyph-id-vertical-river+ water-color +color-black+))
        (setf (aref displayed-cells 2 4) (list +glyph-id-vertical-river+ water-color +color-black+)))
      (when (find :w (second river-feat))
        (setf (aref displayed-cells 0 2) (list +glyph-id-horizontal-river+ water-color +color-black+))
        (setf (aref displayed-cells 1 2) (list +glyph-id-horizontal-river+ water-color +color-black+)))
      (when (find :e (second river-feat))
        (setf (aref displayed-cells 3 2) (list +glyph-id-horizontal-river+ water-color +color-black+))
        (setf (aref displayed-cells 4 2) (list +glyph-id-horizontal-river+ water-color +color-black+))))

     ;; display seas for ports
    (when (and sea-feat
               (or (eq (wtype world-sector) :world-sector-normal-port)
                   (eq (wtype world-sector) :world-sector-abandoned-port)
                   (eq (wtype world-sector) :world-sector-corrupted-port)))
      (when (find :n (second sea-feat))
        (setf (aref displayed-cells 0 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 1 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 2 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 3 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 0) (list +glyph-id-wall+ +color-blue+ +color-black+)))
      (when (find :s (second sea-feat))
        (setf (aref displayed-cells 0 4) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 1 4) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 2 4) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 3 4) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 4) (list +glyph-id-wall+ +color-blue+ +color-black+)))
      (when (find :w (second sea-feat))
        (setf (aref displayed-cells 0 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 0 1) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 0 2) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 0 3) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 0 4) (list +glyph-id-wall+ +color-blue+ +color-black+)))
      (when (find :e (second sea-feat))
        (setf (aref displayed-cells 4 0) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 1) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 2) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 3) (list +glyph-id-wall+ +color-blue+ +color-black+))
        (setf (aref displayed-cells 4 4) (list +glyph-id-wall+ +color-blue+ +color-black+))))
    
    ;; display lake
    (when (or (eq (wtype world-sector) :world-sector-normal-lake)
              (eq (wtype world-sector) :world-sector-abandoned-lake)
              (eq (wtype world-sector) :world-sector-corrupted-lake))
      (setf (aref displayed-cells 1 1) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 1 2) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 1 3) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 2 1) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 2 3) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 3 1) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 3 2) (list +glyph-id-wall+ water-color +color-black+))
      (setf (aref displayed-cells 3 3) (list +glyph-id-wall+ water-color +color-black+)))

    ;; display controlled status
    (cond
      ((= (controlled-by world-sector) +lm-controlled-by-demons+)
       (progn
         (setf (aref displayed-cells 1 1) (list +glyph-id-large-d+ +color-red+ +color-black+))))
      ((= (controlled-by world-sector) +lm-controlled-by-military+)
       (progn
         (setf (aref displayed-cells 1 1) (list +glyph-id-large-m+ +color-green+ +color-black+))))
      )

    ;; display satanists, church, library, etc
    ;; do not show satanists lairs if they are hidden (the faction does not see them) and there is no mission there
    (let ((feat-list (remove nil (list (if (or reveal-lair (mission world-sector))
                                         satanists-feat
                                         nil)
                                       church-feat
                                       library-feat
                                       machine-feat
                                       flesh-feat))))
      (if (> (length feat-list) 1)
        (progn
          (setf (aref displayed-cells 1 3) (list +glyph-id-three-dots+ +color-white+ +color-black+)))
        (progn
          (when (= (length feat-list) 1)
            (cond
              ((eq (first feat-list) satanists-feat) (progn
                                                       (setf (aref displayed-cells 1 3) (list +glyph-id-sacrificial-circle+ +color-magenta+ +color-black+))))
              ((eq (first feat-list) church-feat) (progn
                                                    (setf (aref displayed-cells 1 3) (list +glyph-id-church+ +color-white+ +color-black+))))
              ((eq (first feat-list) library-feat) (progn
                                                     (setf (aref displayed-cells 1 3) (list +glyph-id-book+ +color-white+ +color-black+))))
              ((eq (first feat-list) machine-feat) (progn
                                                     (setf (aref displayed-cells 1 3) (list +glyph-id-machine+ +color-white+ +color-black+))))
              ((eq (first feat-list) flesh-feat) (progn
                                                   (setf (aref displayed-cells 1 3) (list +glyph-id-percent+ +color-magenta+ +color-black+))))))))
      )
    
    (setf (aref displayed-cells 2 2) (list (glyph-idx (get-world-sector-type-by-id (wtype world-sector)))
                                           (glyph-color (get-world-sector-type-by-id (wtype world-sector)))
                                           +color-black+))

    ;; display items
    (cond
      ((> (length (items world-sector)) 1) (progn
                                             (setf (aref displayed-cells 3 3) (list +glyph-id-three-dots+ +color-white+ +color-black+))))
      ((= (length (items world-sector)) 1) (cond
                                             ((= (first (items world-sector)) +lm-item-holy-relic+)
                                              (setf (aref displayed-cells 3 3) (list +glyph-id-christ-cross+ +color-cyan+ +color-black+)))
                                             ((= (first (items world-sector)) +lm-item-book-of-rituals+)
                                              (setf (aref displayed-cells 3 3) (list +glyph-id-book+ +color-magenta+ +color-black+)))
                                             (t (setf (aref displayed-cells 3 3) (list +glyph-id-exclamation-mark+ +color-yellow+ +color-black+))))))

    ;; display available mission
    (when (mission world-sector)
      (if (eq world-sector (world-sector (mission world-sector)))
        (setf (aref displayed-cells 3 1) (list +glyph-id-crossed-swords+ +color-yellow+ +color-black+))
        (setf (aref displayed-cells 3 1) (list +glyph-id-portal+ (rgb 255 75 0) +color-black+))))
    
    (loop for dy from 0 below max-disp-h do
      (loop for dx from 0 below max-disp-w do
        (draw-glyph (+ scr-x (* dx *glyph-w*)) (+ scr-y (* dy *glyph-h*)) (first (aref displayed-cells dx dy))
                    :front-color (second (aref displayed-cells dx dy)) 
                    :back-color (third (aref displayed-cells dx dy)))))
    ))

(defun draw-world-map (world-map scr-x scr-y &key (reveal-lairs nil))
  (let ((*random-state* (make-random-state (world-map/random-state world-map))))
    (loop with max-disp-w = 5
          with max-disp-h = 5
          for y from 0 below *max-y-world-map* do
            (loop for x from 0 below *max-y-world-map*
                  for x1 = (+ scr-x (* x *glyph-w* max-disp-w))
                  for y1 = (+ scr-y (* y *glyph-h* max-disp-h))
                  for sector = (aref (cells world-map) x y)
                  do
                     (draw-world-map-cell sector x1 y1 :reveal-lair reveal-lairs))))
  )

(defun window-use-item (item success-return-win)
  (cond
    ((map-select-func item)
     (progn
       (setf *current-window* (make-instance 'map-select-window 
                                             :return-to *current-window*
                                             :start-map-select (start-map-select-func item)
                                             :cmd-str (list "[Enter] Use  "
                                                            "")
                                             :exec-func #'(lambda ()
                                                            (if (funcall (map-select-func item)
                                                                         item)
                                                              (progn
                                                                (setf *current-window* success-return-win)
                                                                (make-output *current-window*)
                                                                t)
                                                              (progn
                                                                nil)))))
       (make-output *current-window*)
       (run-window *current-window*)))
    (t
     (progn
       (clear-message-list (level/small-message-box (level *world*)))
       (mob-use-item *player* nil item)
       (setf *current-window* success-return-win)
       (make-output *current-window*)
       t))))
