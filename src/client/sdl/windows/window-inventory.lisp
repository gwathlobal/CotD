(in-package :cotd-sdl)

(defclass inventory-window (window)
  ((cur-tab :initform 0 :accessor cur-tab)
   (cur-inv :initform 0 :accessor cur-inv)))

(defconstant +inv-tab-inv+ 0)
(defconstant +inv-tab-descr+ 1)
(defconstant +inv-tab-char+ 2)

(defmethod make-output ((win inventory-window))
  (fill-background-tiles)

  ;; a pane for inventory
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 10 :y 10 :w 305 :h 435))
    (sdl:fill-surface sdl:*black* :template a-rect))
  ;; a pane for item description
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 325 :y 10 :w 305 :h (- *window-height* 20)))
    (sdl:fill-surface sdl:*black* :template a-rect))
  ;; a pane for player chars
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 325 :y 245 :w 305 :h 200))
    (sdl:fill-surface sdl:*black* :template a-rect))
  ;; a pane for displaying commands
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 10 :y (- *window-height* (* 2 (sdl:char-height sdl:*default-font*))) :w 620 :h 13))
    (sdl:fill-surface sdl:*black* :template a-rect)
    (sdl:draw-string-solid-* (format nil "~A~A~A[Esc] Exit"
                                     (if (> (length (inv *player*)) 0)
                                       "[d] Drop all  "
                                       "")
                                     (if (and (> (length (inv *player*)) 0)
                                              (> (qty (get-inv-item-by-pos (inv *player*) (cur-inv win))) 1))
                                       "[Ctrl+d] Drop  "
                                       "")
                                     (if (and (> (length (inv *player*)) 0)
                                              (on-check-applic (get-inv-item-by-pos (inv *player*) (cur-inv win)))
                                              (on-use (get-inv-item-by-pos (inv *player*) (cur-inv win)))
                                              (funcall (on-check-applic (get-inv-item-by-pos (inv *player*) (cur-inv win))) *player* (get-inv-item-by-pos (inv *player*) (cur-inv win))))
                                       "[u] Use  "
                                       ""))
                             10 (sdl:y a-rect) :color sdl:*white*))

  ;; drawing the inventory list
  (let ((cur-str) (lst (make-list 0)) (color-list (make-list 0)))
    ;(when (= +inv-tab-inv+ (cur-tab win)) (setf selected t))
    (setf cur-str (cur-inv win))
    (loop for i from 0 below (length (inv *player*))
          for item = (get-inv-item-by-pos (inv *player*) i)
          do
             (push (capitalize-name (prepend-article +article-a+ (visible-name item))) lst)
             (push (if (= i cur-str)
                     sdl:*yellow*
                     sdl:*white*)
                   color-list))
    (setf lst (reverse lst) color-list (reverse color-list))
    
    (draw-selection-list lst cur-str (truncate 425 15) 20 20 :color-list color-list))

  ;; drawing selected item description
  (when (> (length (inv *player*)) 0)
    (let ((item (get-inv-item-by-pos (inv *player*) (cur-inv win)))
          (lines-count 0))
      (setf lines-count (write-text (get-item-descr item) (sdl:rectangle :x 330 :y 15 :w (- *window-width* 330 20) :h (- *window-height* 50))))
      (when (flavor-quote item)
        (cond
          ((equal (options-font *options*) 'font-8x13) (sdl:initialise-default-font sdl:*font-8x13o*))
          (t (sdl:initialise-default-font sdl:*font-6x13o*)))
        (write-text (flavor-quote item) (sdl:rectangle :x 330 :y (+ 15 (* lines-count (sdl:char-height sdl:*default-font*))) :w (- *window-width* 330 20) :h (- *window-height* 50)))
        (cond
          ((equal (options-font *options*) 'font-8x13) (sdl:initialise-default-font sdl:*font-8x13*))
          (t (sdl:initialise-default-font sdl:*font-6x13*))))
      ))

  (sdl:update-display))

(defmethod run-window ((win inventory-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)

                      ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))
  
                     ;; adjusting the inventory selection
                     (cond
                       ((= (cur-tab win) +inv-tab-inv+) (progn (setf (cur-inv win) (run-selection-list key mod unicode (cur-inv win)))
                                                               (setf (cur-inv win) (adjust-selection-list (cur-inv win) (length (inv *player*)))))))
                     (cond
                       ((sdl:key= key :sdl-key-escape) 
                        (setf *current-window* (return-to win)) (make-output *current-window*) (return-from run-window nil))
                       ;; d - drop all items
                       ((and (sdl:key= key :sdl-key-d) (= mod 0))
                        (clear-message-list (level/small-message-box (level *world*)))
                        (mob-drop-item *player* (get-inv-item-by-pos (inv *player*) (cur-inv win)))
                        (setf *current-window* (return-to win))
                        (make-output *current-window*)
                        (return-from run-window nil))
                       ;; Ctrl + d - drop a number of items
                       ((and (sdl:key= key :sdl-key-d) (/= (logand mod sdl-cffi::sdl-key-mod-ctrl) 0)) 
                        (progn
                          
                          (setf *current-window* (make-instance 'input-str-window 
                                                                :init-input "1"
                                                                :header-str (format nil "Dropping ~A" (prepend-article +article-a+ (visible-name (get-inv-item-by-pos (inv *player*) (cur-inv win)))))
                                                                :main-str "Enter the quantity to drop"
                                                                :prompt-str "[Enter] Drop [Escape] Cancel [a] All"
                                                                :all-func #'(lambda () (format nil "~A" (qty (get-inv-item-by-pos (inv *player*) (cur-inv win)))))
                                                                :input-check-func #'(lambda (char cur-str)
                                                                                      (declare (ignore cur-str))
                                                                                      (let ((i (parse-integer (string char) :junk-allowed t)))
                                                                                        (if (and (not (null i))
                                                                                                 (<= 1 i (qty (get-inv-item-by-pos (inv *player*) (cur-inv win)))))
                                                                                          t
                                                                                          nil)))
                                                                :final-check-func #'(lambda (full-input-str)
                                                                                      (let ((i (parse-integer full-input-str :junk-allowed t)))
                                                                                        (if (and (not (null i))
                                                                                                 (<= 1 i (qty (get-inv-item-by-pos (inv *player*) (cur-inv win)))))
                                                                                          t
                                                                                          nil)))
                                                                ))
                          (make-output *current-window*)
                          (let ((qty (run-window *current-window*)))
                            (when qty
                              (clear-message-list (level/small-message-box (level *world*)))
                              (mob-drop-item *player* (get-inv-item-by-pos (inv *player*) (cur-inv win)) :qty (parse-integer qty :junk-allowed nil))
                              (setf *current-window* (return-to win))
                              (make-output *current-window*)
                              (return-from run-window nil)))
                          ))
                       ;; u - use an item
                       ((sdl:key= key :sdl-key-u)
                        (let ((item (get-inv-item-by-pos (inv *player*) (cur-inv win)))
                              (result))
                          (setf result (window-use-item item (return-to win)))
                          (when result
                            (return-from run-window nil)))))
                     (make-output *current-window*)
                     
                     )
    (:video-expose-event () (make-output *current-window*)))
  )
