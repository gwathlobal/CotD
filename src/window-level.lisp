(in-package :cotd)

(defun show-char-effects (mob x y h)
  (let ((font (sdl:initialise-default-font sdl:*font-6x13*)))
    (loop for effect being the hash-key in (effects mob)
          with y1 = y    
          do
             (when (> (+ y1 (sdl:get-font-height :font font)) (+ y h))
               (sdl:draw-string-solid-* "(...)" x y1 :color sdl:*white*)
               (loop-finish))
             (cond
               ((= effect +mob-effect-possessed+) (sdl:draw-string-solid-* "Possession" x y1 :color sdl:*red*))
               ((= effect +mob-effect-blessed+) (sdl:draw-string-solid-* "Blessed" x y1 :color sdl:*red*))
               ((= effect +mob-effect-reveal-true-form+) (sdl:draw-string-solid-* "Revealed" x y1 :color sdl:*red*))
               ((= effect +mob-effect-divine-consealed+) (sdl:draw-string-solid-* "Consealed" x y1 :color sdl:*cyan*))
               ((= effect +mob-effect-calling-for-help+) (sdl:draw-string-solid-* "Summoning" x y1 :color sdl:*green*))
               ((= effect +mob-effect-called-for-help+) (sdl:draw-string-solid-* "Called" x y1 :color sdl:*green*)))
             (incf y1 (sdl:get-font-height :font font)))))

(defun show-char-properties (x y meaningful-action)
  (let* ((font (sdl:initialise-default-font sdl:*font-6x13*)) (str)
         (str-lines))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w 250 :h (* *glyph-h* *max-y-view*)))
      (sdl:fill-surface sdl:*black* :template a-rect)
      (setf str (format nil "~A - ~A~%~%HP: ~A/~A~%Power: ~A/~A~%~%~A~%~%Humans ~A~%Blessed ~A~%Angels ~A~%Demons ~A~%"
                        (name *player*) (name (get-mob-type-by-id (mob-type *player*)))
                        (cur-hp *player*) (max-hp *player*) 
                        (cur-fp *player*) (max-fp *player*)
                        (get-weapon-descr-line *player*)
                        (total-humans *world*)
                        (total-blessed *world*)
                        (total-angels *world*)
                        (total-demons *world*)                     
                      ))
      (setf str-lines (write-text  str a-rect  :font font :color sdl:*white*)))
    (show-char-effects *player* x (+ y (* (sdl:get-font-height :font font) (1+ str-lines))) 52)
    (sdl:draw-string-solid-* (format nil "Time ~A"  *global-game-time*)
                                     x (+ y 237) :font font :color (if meaningful-action
                                                   sdl:*red*
                                                   sdl:*white*))
    ))

(defun show-small-message-box (x y w &optional (h *msg-box-window-height*))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
    (sdl:fill-surface sdl:*black* :template a-rect))
  (sdl:with-default-font ((sdl:initialise-default-font sdl:*font-6x13*))
    (let ((max-lines (write-text (get-msg-str-list) (sdl:rectangle :x x :y y :w w :h h) :count-only t)))
      (when (> (message-list-length) 0)
      	(write-text (get-msg-str-list) (sdl:rectangle :x x :y y :w w :h h) :start-line (if (< (truncate h 13) max-lines)
                                                                                         (- max-lines (truncate h 13))
                                                                                         0))))))

(defun update-screen (win)
  
  ;; filling the background with tiles
  
  (fill-background-tiles)
  
  ;;(update-visible-area (get-level-by-z *world* (z *player*)) (x *player*) (y *player*))
    
  (update-map-area)
    
  (show-char-properties (+ 20 (* *glyph-w* *max-x-view*)) 10 (meaningful-action win))
  (show-small-message-box *glyph-w* (+ 20 (* *glyph-h* *max-y-view*)) (+ 250 (+ 10 (* *glyph-w* *max-x-view*))))
    
  (sdl:update-display)
  
 )

(defmethod make-output ((win cell-window))
  
  (update-screen win)
  )

(defmethod run-window ((win cell-window))

  (tagbody
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func *current-window*)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)
                        
                        ;;------------------
			;; moving - arrows
			(when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 9)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 8)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 7)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 6)
                            )
                          (setf (meaningful-action win) t))
			(when (sdl:key= key :sdl-key-kp5)
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 5)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 4)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 3)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 2)
                            )
                          (setf (meaningful-action win) t))
			(when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 1)
                            )
                          (setf (meaningful-action win) t))
			;;------------------
			;; character mode - Shift + 2
			(when (and (sdl:key= key :sdl-key-2) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
			  (setf *current-window* (make-instance 'character-window :return-to *current-window*)))
                        ;;------------------
			;; help screen - ?
			(when (or (sdl:key= key :sdl-key-question)
                                  (and (sdl:key= key :sdl-key-slash) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                  (and (sdl:key= key :sdl-key-7) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0)))
			  (setf *current-window* (make-instance 'help-window :return-to *current-window*)))		
                        ;;------------------
			;; select abilities - a
                        (when (and (sdl:key= key :sdl-key-a))
                          (let ((abil-name-list nil)
                                (mob-abilities (get-mob-all-abilities *player*)))
                            
                            ;; filter ability list to leave only non passive and applicable
                            (setf mob-abilities (loop for ability-type-id in mob-abilities
                                                      when (and (not (abil-passive-p ability-type-id))
                                                                (abil-applicable-p (get-ability-type-by-id ability-type-id) *player* *player*))
                                                        collect ability-type-id))
                            (if mob-abilities
                              (progn
                                ;; populate the ability name list 
                                (setf abil-name-list
                                      (loop
                                        for ability-type-id in mob-abilities
                                        collect (name (get-ability-type-by-id ability-type-id))))
                                
                                ;; display the window with the list
                                (setf *current-window* (make-instance 'select-obj-window 
                                                                      :return-to *current-window* 
                                                                      :obj-list abil-name-list
                                                                      :enter-func #'(lambda (cur-sel)
                                                                                      (when (can-invoke-ability *player* *player* (nth cur-sel mob-abilities))
                                                                                        (mob-invoke-ability *player* *player* (nth cur-sel mob-abilities))
                                                                                        (setf *current-window* win)
                                                                                        (setf (meaningful-action win) t))
                                                                                        )
                                                                      :line-list abil-name-list
                                                                      :prompt-list (list (list #'(lambda (cur-sel) 
                                                                                                   t)
                                                                                               "[Enter] Invoke [Escape] Cancel") 
                                                                                         ))))
                              (progn
                                ;; no abilites - display a message
                                (add-message (format nil "You have no abilities to invoke.~%"))
                                ))
			    ))
			;;------------------
			;; look mode - l
			(when (and (sdl:key= key :sdl-key-l) (= mod 0))
			  (setf *current-window* (make-instance 'map-select-window 
								:return-to *current-window*
								:cmd-str ""
								:exec-func #'(lambda ()
									       nil)))
			  (make-output *current-window*))
			;;------------------
			;; fire mode - f
			;;(when (and (sdl:key= key :sdl-key-f) (= mod 0))
			;;  (if (ranged *player*)
			;;      (progn (setf *current-window* (make-instance 'map-select-window 
			;;						   :return-to *current-window*
			;;						   :cmd-str (format nil "[Enter] Fire ")
			;;						   :exec-func #'(lambda ()
			;;								  (when (get-mob-* (get-level-by-z *world* (z *player*)) (view-x *player*) (view-y *player*))
			;;								    (shoot-target *player* (get-mob-* (get-level-by-z *world* (z *player*)) (view-x *player*) (view-y *player*)))
			;;								    (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*))
			;;								    (setf *current-window* (return-to *current-window*))))))
			;;	     (make-output *current-window*))
			;;      (progn (add-message (format nil "Can't switch into firing mode: no ranged weapons.~%")))))
			;;------------------
			;; use feature - u
			;;(when (and (sdl:key= key :sdl-key-u) (= mod 0))
			;;  (let ((feature-list (get-features-* (get-level-by-z *world* (z *player*)) (x *player*) (y *player*)))
			;;	(line-list))
			;;    (setf feature-list (remove-if #'(lambda (item) (if (func item) nil t)) feature-list))
			;;    (when feature-list
			;;      (if (> (length feature-list) 1)
			;;	  (progn
			;;	    (dolist (feature feature-list)
			;;	      (setf line-list (append line-list (list (name feature)))))
			;;	    (setf *current-window* (make-instance 'select-obj-window 
			;;						  :return-to *current-window* 
			;;						  :obj-list feature-list
			;;						  :enter-func #'(lambda (cur-sel)
			;;								  (funcall (func (nth cur-sel feature-list)))
			;;								  (setf *current-window* win))
			;;						  :line-list line-list
			;;						  :prompt-list (list (list #'(lambda (cur-sel) 
			;;									       t)
			;;									   "[Enter] Use [Escape] Cancel") 
			;;								     ))))
			;;	  (progn
			;;	    (funcall (func (nth 0 feature-list))))))))
			      
			
			(make-output *current-window*)
			(go exit-loop)
                        )
       (:video-expose-event () (make-output *current-window*)))
    exit-loop)
  nil)
