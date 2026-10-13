(in-package :cotd)

(defclass highscores-window (window)
  ((highscores-place :initform nil :initarg :highscores-place :accessor highscores-place)))

(defmethod make-output ((win highscores-window))
  ;; fill the screen black
  (cotd-render:with-rectangle (a-rect (cotd-render:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (cotd-render:fill-surface cotd-render:*black* :template a-rect))

  (cotd-render:draw-string-solid-* "HIGH SCORES" (truncate *window-width* 2) 10 :justify :center :color cotd-render:*white*)

  (loop for record in (highscores-table/records *highscores*)
        for n from 0 to 9
        with str = nil
        with color = cotd-render:*white*
        with additional-record = (if (> (length (highscores-table/records *highscores*)) 10)
                                   (nth 10 (highscores-table/records *highscores*))
                                   nil)
        do
           (setf str (format nil "  ~3<~A.~> ~A~%~%" (1+ n) (write-highscore-record-to-str record)))
           (if (and (highscores-place win)
                    (= (highscores-place win) n))
             (setf color cotd-render:*yellow*)
             (setf color cotd-render:*white*))
           (cotd-render:with-rectangle (rect (cotd-render:rectangle :x 0 :y (+ 30 (* n (cotd-render:char-height cotd-render:*default-font*) 3)) :w *window-width* :h (* (cotd-render:char-height cotd-render:*default-font*) 2)))
             (write-text str rect :color color))
        finally
           (when additional-record
             (cotd-render:draw-string-solid-* "  ---" 0 (+ 30 (* 10 (cotd-render:char-height cotd-render:*default-font*) 3)) :color cotd-render:*white*)
             (setf str (format nil "  ~3<11.~> ~A~%" (write-highscore-record-to-str additional-record)))
             (if (and (highscores-place win)
                      (= (highscores-place win) 10))
             (setf color cotd-render:*yellow*)
             (setf color cotd-render:*white*))
             (cotd-render:with-rectangle (rect (cotd-render:rectangle :x 0 :y (+ 30 (cotd-render:char-height cotd-render:*default-font*) (* 10 (cotd-render:char-height cotd-render:*default-font*) 3)) :w *window-width* :h (* (cotd-render:char-height cotd-render:*default-font*) 2)))
               (write-text str rect :color color)))
           )
  
  (cotd-render:draw-string-solid-* (format nil "[Esc] Quit")
                           10 (- *window-height* 13 (cotd-render:char-height cotd-render:*default-font*)))
  
  (cotd-render:update-display))

(defmethod run-window ((win highscores-window))
  (cotd-render:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                     (declare (ignore mod unicode))
                     (cond
                       ((key= key :key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       )
                     (make-output *current-window*)
                     
                     )
    (:video-expose-event () (make-output *current-window*)))
  )
