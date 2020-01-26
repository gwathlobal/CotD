(in-package :cotd)

(defclass new-game-window (window)
  ((cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :accessor menu-items)
   (menu-funcs :initform () :accessor menu-funcs)
   (menu-descrs :initform () :accessor menu-descrs)
   (max-menu-length :initform (truncate (- (/ *window-height* 2) 60) (sdl:char-height sdl:*default-font*)) :initarg :max-menu-length :accessor max-menu-length)
   ))

(defmethod initialize-instance :after ((win new-game-window) &key)
  (multiple-value-bind (new-game-items new-game-funcs new-game-descrs) (new-game-menu-items)
    (setf (menu-items win) new-game-items)
    (setf (menu-funcs win) new-game-funcs)
    (setf (menu-descrs win) new-game-descrs))
  )

(defmethod make-output ((win new-game-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "NEW GAME" (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)

  (sdl:draw-string-solid-* (format nil "Choose your faction & character:")
                           10 (+ 10 (sdl:char-height sdl:*default-font*)))
  
  ;; drawing selection list
  (let ((cur-str (cur-sel win)) (color-list nil))

    ;;(format t "max-menu-length = ~A, cur-str ~A~%" (max-menu-length win) (cur-sel win))
    
    (dotimes (i (length (menu-items win)))
      ;; choose the description
      ;;(setf lst (append lst (list (aref (line-array win) i))))
      
      (if (= i cur-str) 
        (setf color-list (append color-list (list sdl:*yellow*)))
        (setf color-list (append color-list (list sdl:*white*)))))
    (draw-selection-list (menu-items win) cur-str (max-menu-length win) 20 (+ 30 (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t))

  ;; drawing selection description
  (let ((descr (nth (cur-sel win) (menu-descrs win))))
    (sdl:with-rectangle (rect (sdl:rectangle :x 20 :y (+ (truncate *window-height* 2) 0)
                                             :w (- *window-width* 40)
                                             :h (- (truncate *window-height* 2) 20 0 (sdl:char-height sdl:*default-font*))))
      (write-text descr rect :start-line 0)))

  (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Exit")
                           10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
  
  (sdl:update-display))

(defmethod run-window ((win new-game-window))
     (sdl:with-events ()
       (:quit-event () (funcall (quit-func win)) t)
       (:key-down-event (:key key :mod mod :unicode unicode)

                        (setf (cur-sel win) (run-selection-list key mod unicode (cur-sel win) :start-page (truncate (cur-sel win) (length (menu-items win))) :max-str-per-page (max-menu-length win)))
                        (setf (cur-sel win) (adjust-selection-list (cur-sel win) (length (menu-items win))))
                        
                        (cond
			  ;; escape - quit
			  ((sdl:key= key :sdl-key-escape) 
			   (setf *current-window* (return-to win))
                           (return-from run-window (values nil nil nil nil)))
			  ;; enter - select
			  ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                           (when (and (menu-funcs win) (nth (cur-sel win) (menu-funcs win)))
                             (return-from run-window (funcall (nth (cur-sel win) (menu-funcs win)) (cur-sel win))))
                           ))
			(make-output *current-window*))
       (:video-expose-event () (make-output *current-window*))))

(defun new-game-menu-items ()
  (let ((menu-items nil)
        (menu-funcs nil)
        (menu-descrs nil)
        (join-heaven-item (list "Join the Celestial Communion (as a Chrome angel)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-angel-chrome+))

                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              (nth (random (length tod-types)) tod-types)
                                              +specific-faction-type-angel-chrome+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/communion_chrome.txt")))
        (join-trinity-item (list "Join the Celestial Communion (as a Trinity mimic)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-angel-trinity+))
                                      
                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              (nth (random (length tod-types)) tod-types)
                                              +specific-faction-type-angel-trinity+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/communion_trinity.txt")))
        (join-legion-item (list "Join the Pandemonium Hierarchy (as a Crimson imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-crimson+))
                                      
                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              (nth (random (length tod-types)) tod-types)
                                              +specific-faction-type-demon-crimson+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/pandemonium_crimsonimp.txt")))
        (join-shadow-item (list "Join the Pandemonium Hierarchy (as a Shadow imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-shadow+))
                                      
                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              +tod-type-evening+
                                              +specific-faction-type-demon-shadow+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/pandemonium_shadowimp.txt")))
        (join-puppet-item (list "Join the Pandemonium Hierarchy (as Malseraph's puppet)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))

                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-demon-malseraph+))
                                      
                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              (nth (random (length tod-types)) tod-types)
                                              +specific-faction-type-demon-malseraph+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/pandemonium_puppet.txt")))
        (join-chaplain-item (list "Join the Military (as a Chaplain)"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-military-chaplain+))
                                        
                                        (values mission-id
                                                layout-id
                                                (nth (random (length weather-types)) weather-types)
                                                (nth (random (length tod-types)) tod-types)
                                                +specific-faction-type-military-chaplain+
                                                faction-list)))
                                  (get-txt-from-file "data/descriptions/military_chaplain.txt")))
        (join-scout-item (list "Join the Military (as a Scout)"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-military-scout+))
                                     
                                     (values mission-id
                                             layout-id
                                             (nth (random (length weather-types)) weather-types)
                                             (nth (random (length tod-types)) tod-types)
                                             +specific-faction-type-military-scout+
                                             faction-list)))
                               (get-txt-from-file "data/descriptions/military_scout.txt")))
        (join-thief-item (list "Join as the Thief"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-thief+))
                                     
                                     (values mission-id
                                             layout-id
                                             (nth (random (length weather-types)) weather-types)
                                             +tod-type-evening+
                                             +specific-faction-type-thief+
                                             faction-list)))
                               (get-txt-from-file "data/descriptions/criminals.txt")))
        (join-satanist-item (list "Join the Satanists"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                            (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                            (mission-id)
                                            (layout-id)
                                            (faction-list))

                                        (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-satanist+))
                                        
                                        (values mission-id
                                                layout-id
                                                (nth (random (length weather-types)) weather-types)
                                                (nth (random (length tod-types)) tod-types)
                                                +specific-faction-type-satanist+
                                                faction-list)))
                                  (get-txt-from-file "data/descriptions/satanists.txt")))
        (join-church-item (list "Join the Church"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                          (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                          (mission-id)
                                          (layout-id)
                                          (faction-list))
                                      
                                      (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-priest+))
                                      
                                      (values mission-id
                                              layout-id
                                              (nth (random (length weather-types)) weather-types)
                                              (nth (random (length tod-types)) tod-types)
                                              +specific-faction-type-priest+
                                              faction-list)))
                                (get-txt-from-file "data/descriptions/church.txt")))
        (join-eater-item (list "Join as the Eater of the dead"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (remove +weather-type-snow+ (get-all-scenario-features-by-type +scenario-feature-weather+ nil)))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))
                                     
                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-eater+))
                                     
                                     (values mission-id
                                             layout-id
                                             (nth (random (length weather-types)) weather-types)
                                             (nth (random (length tod-types)) tod-types)
                                             +specific-faction-type-eater+
                                             faction-list)))
                               (get-txt-from-file "data/descriptions/primordials_eater.txt")))
        (join-skin-item (list "Join as the Skinchanger"
                              #'(lambda (n) 
                                  (declare (ignore n))
                                  (let ((weather-types (remove +weather-type-snow+ (get-all-scenario-features-by-type +scenario-feature-weather+ nil)))
                                        (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                        (mission-id)
                                        (layout-id)
                                        (faction-list))
                                    
                                    (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-skinchanger+))

                                    (format t "specific-faction-type = ~A~%" +specific-faction-type-skinchanger+)
                                    
                                    (values mission-id
                                            layout-id
                                            (nth (random (length weather-types)) weather-types)
                                            (nth (random (length tod-types)) tod-types)
                                            +specific-faction-type-skinchanger+
                                            faction-list)))
                              (get-txt-from-file "data/descriptions/primordials_skinchanger.txt")))
        (join-ghost-item (list "Join as the Lost soul"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (let ((weather-types (get-all-scenario-features-by-type +scenario-feature-weather+ nil))
                                         (tod-types (get-all-scenario-features-by-type +scenario-feature-time-of-day+ nil))
                                         (mission-id)
                                         (layout-id)
                                         (faction-list))

                                     (multiple-value-setq (mission-id layout-id faction-list) (find-random-scenario-options +specific-faction-type-ghost+))
                                     
                                     (values mission-id
                                             layout-id
                                             (nth (random (length weather-types)) weather-types)
                                             (nth (random (length tod-types)) tod-types)
                                             +specific-faction-type-ghost+
                                             faction-list)))
                               (get-txt-from-file "data/descriptions/lostsoul.txt")))
        )

    (setf menu-items (list (first join-heaven-item) (first join-trinity-item) (first join-legion-item) (first join-shadow-item) (first join-puppet-item)
                           (first join-chaplain-item) (first join-scout-item) (first join-thief-item) (first join-satanist-item) (first join-church-item)
                           (first join-eater-item) (first join-skin-item) (first join-ghost-item)))
    (setf menu-funcs (list (second join-heaven-item) (second join-trinity-item) (second join-legion-item) (second join-shadow-item) (second join-puppet-item)
                           (second join-chaplain-item) (second join-scout-item) (second join-thief-item) (second join-satanist-item) (second join-church-item)
                           (second join-eater-item) (second join-skin-item) (second join-ghost-item)))
    (setf menu-descrs (list (third join-heaven-item) (third join-trinity-item) (third join-legion-item) (third join-shadow-item) (third join-puppet-item)
                            (third join-chaplain-item) (third join-scout-item) (third join-thief-item) (third join-satanist-item) (third join-church-item)
                            (third join-eater-item) (third join-skin-item) (third join-ghost-item)))

    (values menu-items menu-funcs menu-descrs)))
