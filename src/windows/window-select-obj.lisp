(in-package :cotd)

(defclass select-obj-window (window)
  ((cur-sel :initform 0 :accessor cur-sel)
   (header-line :initform nil :initarg :header-line :accessor header-line)
   (line-list :initarg :line-list :accessor line-list :type list)
   (descr-list :initform nil :initarg :descr-list :accessor descr-list)
   (color-list :initform nil :initarg :color-list :accessor color-list)
   (prompt-list :initarg :prompt-list :accessor prompt-list :type list) ;; each value is (<func if this prompt should apply with 1 arg - cur-sel> <prompt string proper>)
   (enter-func :initarg :enter-func :accessor enter-func) ;; 1 arg - cur-sel
   (select-color-func :initform nil :initarg :select-color-func :accessor select-color-func) ;; 1 arg - cur-sel
   (can-esc :initform t :initarg :can-esc :accessor can-esc)
   
   (x :initform nil :initarg :x :accessor select-obj-window/x)
   (y :initform nil :initarg :y :accessor select-obj-window/y)
   (w :initform nil :initarg :w :accessor select-obj-window/w)
   (h-list :initform nil :accessor select-obj-window/h-list)
   (h-descr :initform nil :accessor select-obj-window/h-descr)
   (margin :initform 4 :accessor select-obj-window/margin :type fixnum)
   ))

(defmethod initialize-instance :after ((win select-obj-window) &key)
  (with-slots (x y w h-list h-descr margin cur-sel header-line line-list descr-list prompt-list can-esc) win
    (let ((default-w 330))
      ;; find the maximum width among all strings
      (unless w
        (setf w (loop with max = default-w
                      for str in (append (if (header-line win)
                                           (list (header-line win))
                                           nil)
                                         (line-list win)
                                         (loop for prompt-func in prompt-list
                                               collect (return-prompt-str prompt-func cur-sel :can-esc can-esc)))
                      for try-max = (+ 10 (* (cotd-render:char-width cotd-render:*default-font*) (+ 10 (length str))))
                      when (> try-max max) do
                        (setf max try-max)
                      finally (return-from nil max))))

      ;; find the maximum height of the description text depending on the found width
      (if descr-list
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x 0 :y 0 :w (- w margin margin) :h 30))
          (setf h-descr (loop with max = 0
                              for descr in descr-list
                              for try-max = (* (cotd-render:char-height cotd-render:*default-font*) (write-text descr rect :count-only t))
                              when (> try-max max) do
                                (setf max try-max)
                              finally (return-from nil max))))
        (setf h-descr 0))

      ;; find the height of the list
      (unless h-list
        (setf h-list (* (cotd-render:char-height cotd-render:*default-font*) (length line-list))))
      
      ;; set x if necessary
      (unless x
        (setf x (- (truncate *window-width* 2) (truncate w 2) margin)))
      
      ;; set y if necessary
      (unless y
        (setf y (- (truncate *window-height* 2) (truncate (+ h-descr h-list) 2) margin))))))

(defun return-prompt-str (prompt-func cur-sel &key (can-esc t))
  (if prompt-func
    (funcall prompt-func cur-sel)
    (if can-esc
      "[Esc] Escape"
      "")))

(defmethod make-output ((win select-obj-window))
  (with-slots (x y w h-list h-descr margin cur-sel header-line line-list descr-list prompt-list can-esc select-color-func color-list) win
    (let* ((h-header (cotd-render:char-height cotd-render:*default-font*))
           (h-prompt (cotd-render:char-height cotd-render:*default-font*))
           (cur-y y)

           (x-rect x)
           (w-rect w)
           (x-txt (+ x-rect margin))
           (w-txt (- w-rect margin margin))

           (y-header-rect)
           (h-header-rect)

           (y-header-txt)
           (h-header-txt)

           (y-list-rect)
           (h-list-rect)

           (y-list-txt)

           (y-descr-rect)
           (h-descr-rect)

           (y-descr-txt)
           (h-descr-txt)

           (y-prompt-rect)
           (h-prompt-rect)

           (y-prompt-txt)
           (h-prompt-txt)
           )

      (when header-line
        ;; setting up coordiantes
        (setf y-header-rect cur-y
              h-header-rect (+ h-header margin margin)
              y-header-txt (+ y-header-rect margin)
              h-header-txt (- h-header-rect margin margin)
              cur-y (+ cur-y h-header-rect -1))
        ;; draw rectangle for header
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-rect :y y-header-rect :w w-rect :h h-header-rect))
          (cotd-render:fill-surface cotd-render:*black* :template rect)
          (cotd-render:draw-rectangle rect :color cotd-render:*white*))
        ;; draw text for header
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-txt :y y-header-txt :w w-txt :h h-header-txt))
          (write-text header-line rect)))

      (when line-list
        ;; setting up coordiantes
        (setf y-list-rect cur-y
              h-list-rect (+ h-list margin margin)
              y-list-txt (+ y-list-rect margin)
              cur-y (+ cur-y h-list-rect -1))
        ;; draw rectangle for list
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-rect :y y-list-rect :w w-rect :h h-list-rect))
          (cotd-render:fill-surface cotd-render:*black* :template rect)
          (cotd-render:draw-rectangle rect :color cotd-render:*white*))
        ;; draw list
        (loop with final-color-list = ()
              for i from 0 below (length line-list) do
                (if (= i cur-sel) 
                  (if select-color-func
                    (push (funcall select-color-func cur-sel) final-color-list)
                    (push cotd-render:*yellow* final-color-list))
                  (if color-list
                    (push (nth i color-list) final-color-list)
                    (push cotd-render:*white* final-color-list)))
              finally
                 (setf final-color-list (reverse final-color-list))
                 (draw-selection-list line-list cur-sel (length line-list) x-txt y-list-txt :color-list final-color-list :use-letters t)))

      (when descr-list
        ;; setting up coordiantes
        (setf y-descr-rect cur-y
              h-descr-rect (+ h-descr margin margin)
              y-descr-txt (+ y-descr-rect margin)
              h-descr-txt (- h-descr-rect margin margin)
              cur-y (+ cur-y h-descr-rect -1))
        ;; draw rectangle for description
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-rect :y y-descr-rect :w w-rect :h h-descr-rect))
          (cotd-render:fill-surface cotd-render:*black* :template rect)
          (cotd-render:draw-rectangle rect :color cotd-render:*white*))
        ;; draw description text
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-txt :y y-descr-txt :w w-txt :h h-descr-txt))
          (write-text (nth cur-sel descr-list) rect :color cotd-render:*white*)))
      
      (when prompt-list
        ;; setting up coordiantes
        (setf y-prompt-rect cur-y
              h-prompt-rect (+ h-prompt margin margin)
              y-prompt-txt (+ y-prompt-rect margin)
              h-prompt-txt (- h-prompt-rect margin margin)
              cur-y (+ cur-y h-prompt-rect -1))
        ;; draw rectangle for prompt
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-rect :y y-prompt-rect :w w-rect :h h-prompt-rect))
          (cotd-render:fill-surface cotd-render:*black* :template rect)
          (cotd-render:draw-rectangle rect :color cotd-render:*white*))
        ;; draw text for prompt
        (cotd-render:with-rectangle (rect (cotd-render:rectangle :x x-txt :y y-prompt-txt :w w-txt :h h-prompt-txt))
          (write-text (return-prompt-str (nth cur-sel prompt-list) cur-sel :can-esc can-esc) rect)))
      ))
  (cotd-render:update-display))

(defmethod run-window ((win select-obj-window))
  (tagbody
     (cotd-render:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
			
			(setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (line-list win))) :max-str-per-page (length (line-list win))))
                        (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (line-list win))))

                        (cond
			  ;; escape - quit
			  ((and (key= key :key-escape) (can-esc win)) 
			   (setf *current-window* (return-to win)) (go exit-func))
			  ;; enter - select
			  ((or (key= key :key-return) (key= key :key-kp-enter))
			   (funcall (enter-func win) (cur-sel win))
			   (go exit-func)))
                        (make-output *current-window*)
			)
       (:video-expose-event () (make-output *current-window*)))
     exit-func (make-output *current-window*)))
