(in-package :cotd)

(defclass loading-window (window)
  ((update-func :initarg :update-func :accessor update-func)
   (cur-str :initform "Generating map" :initarg :cur-str :accessor cur-str)
   (hint-text :initform (nth (random (length *scenario-hints*)) *scenario-hints*) :initarg :hint-text :accessor loading-window/hint-text)))

(defmethod make-output ((win loading-window))
  ;; fill the screen black
  (cotd-render:with-rectangle (a-rect (cotd-render:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (cotd-render:fill-surface cotd-render:*black* :template a-rect))
 
  ;; invoke the function to update the window
  (funcall (update-func win) win)

  (when (loading-window/hint-text win)
    (let* ((max-lines 0)
           (x-margin 30)
           (x x-margin)
           (w (- *window-width* (* x-margin 2)))
           (y-margin 30))
      (cotd-render:with-rectangle (a-rect (cotd-render:rectangle :x 0 :y 0 :w w :h (* 1 (cotd-render:get-font-height))))
        (setf max-lines (write-text (loading-window/hint-text win) a-rect :count-only t)))
      (cotd-render:with-rectangle (a-rect (cotd-render:rectangle :x x :y (- *window-height* y-margin (* max-lines (cotd-render:get-font-height))) :w w :h (* max-lines (cotd-render:get-font-height))))
        (write-text (loading-window/hint-text win) a-rect))))
  
  (cotd-render:update-display))

(defmethod run-window ((win loading-window))
  (cotd-render:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:video-expose-event () (make-output *current-window*)))
  )
