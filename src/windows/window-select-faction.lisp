(in-package :cotd)

(defclass select-faction-window (window)
  ((menu-items :initarg :menu-items :accessor select-faction-window/menu-items)
   (menu-descrs :initarg :menu-descrs :accessor select-faction-window/menu-descrs)

   (cur-sel :initform 0 :accessor select-faction-window/cur-sel)
      
   (max-menu-length :initform (truncate (- (/ *window-height* 2) 60) (sdl:char-height sdl:*default-font*)) :initarg :max-menu-length :accessor select-faction-window/max-menu-length)
   (window-title :initform "QUICK SCENARIO" :initarg :window-title :accessor select-faction-window/window-title)
   (window-subtitle :initform "Choose your faction & character:" :initarg :window-subtitle :accessor select-faction-window/window-subtitle)
   ))

(defmethod make-output ((win select-faction-window))
  (with-slots (window-title window-subtitle cur-sel menu-descrs menu-items max-menu-length) win
    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))
    
    (sdl:draw-string-solid-* window-title (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)
    
    (sdl:draw-string-solid-* window-subtitle
                             10 (+ 10 (sdl:char-height sdl:*default-font*)))
    
    ;; drawing selection list
    (let ((color-list nil))
      
      ;;(format t "max-menu-length = ~A, cur-str ~A~%" (max-menu-length win) (cur-sel win))
      
      (dotimes (i (length menu-items))
        ;; choose the description
        ;;(setf lst (append lst (list (aref (line-array win) i))))
        
        (if (= i cur-sel) 
          (setf color-list (append color-list (list sdl:*yellow*)))
          (setf color-list (append color-list (list sdl:*white*)))))
      (draw-selection-list menu-items cur-sel max-menu-length 20 (+ 30 (sdl:char-height sdl:*default-font*)) :color-list color-list :use-letters t))
    
    ;; drawing selection description
    (let ((descr (nth cur-sel menu-descrs)))
      (sdl:with-rectangle (rect (sdl:rectangle :x 20 :y (+ (truncate *window-height* 2) 0)
                                               :w (- *window-width* 40)
                                               :h (- (truncate *window-height* 2) 20 0 (sdl:char-height sdl:*default-font*))))
        (write-text descr rect :start-line 0)))
    
    (sdl:draw-string-solid-* (format nil "[Enter] Select  [Up/Down] Move selection  [Shift+Up/Down] Scroll page  [Esc] Exit")
                             10 (- *window-height* 10 (sdl:char-height sdl:*default-font*)))
    
    (sdl:update-display)))

(defmethod run-window ((win select-faction-window))
  (with-slots (quit-func return-to cur-sel menu-items max-menu-length) win
    (sdl:with-events ()
      (:quit-event () (funcall quit-func) t)
      (:key-down-event (:key key :mod mod :unicode unicode)
                       
                       (setf cur-sel (run-selection-list key mod unicode cur-sel :start-page (truncate cur-sel (length menu-items)) :max-str-per-page max-menu-length))
                       (setf cur-sel (adjust-selection-list cur-sel (length menu-items)))
                       
                       (cond
                         ;; escape - quit
                         ((sdl:key= key :sdl-key-escape) 
                          (setf *current-window* return-to)
                          (return-from run-window nil))
                         ;; enter - select
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (return-from run-window cur-sel)
                          ))
                       (make-output *current-window*))
      (:video-expose-event () (make-output *current-window*)))))

(defun quick-scenario-menu-items ()
  (let ((menu-items nil)
        (menu-funcs nil)
        (menu-descrs nil)
        (join-heaven-item (list "Join the Celestial Communion (as a Chrome angel)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-angel-chrome+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                    )
                                (get-txt-from-file "data/descriptions/communion_chrome.txt")))
        (join-trinity-item (list "Join the Celestial Communion (as a Trinity mimic)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-angel-trinity+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                    )
                                (get-txt-from-file "data/descriptions/communion_trinity.txt")))
        (join-legion-item (list "Join the Pandemonium Hierarchy (as a Crimson imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-demon-crimson+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_crimsonimp.txt")))
        (join-shadow-item (list "Join the Pandemonium Hierarchy (as a Shadow imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    ;; start in the evening
                                    (let ((lvl-mod-list (append (list (get-level-modifier-by-id +lm-tod-evening+))
                                                                (remove +level-mod-time-of-day+ (get-all-lvl-mods-list) :key #'(lambda (a)
                                                                                                                                 (lm-type a))))))
                                      (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-demon-shadow+ :avail-lvl-mods-list lvl-mod-list)
                                        (when (and mission world-sector)
                                          (values world-sector mission))))
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_shadowimp.txt")))
        (join-puppet-item (list "Join the Pandemonium Hierarchy (as Malseraph's puppet)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-demon-malseraph+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_puppet.txt")))
        (join-chaplain-item (list "Join the Military (as a Chaplain)"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-military-chaplain+)
                                        (when (and mission world-sector)
                                          (values world-sector mission)))
                                      )
                                  (get-txt-from-file "data/descriptions/military_chaplain.txt")))
        (join-scout-item (list "Join the Military (as a Scout)"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-military-scout+)
                                     (when (and mission world-sector)
                                       (values world-sector mission)))
                                   )
                               (get-txt-from-file "data/descriptions/military_scout.txt")))
        (join-thief-item (list "Join as the Thief"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   ;; start in the evening
                                    (let ((lvl-mod-list (append (list (get-level-modifier-by-id +lm-tod-evening+))
                                                                (remove +level-mod-time-of-day+ (get-all-lvl-mods-list) :key #'(lambda (a)
                                                                                                                                 (lm-type a))))))
                                      (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-thief+ :avail-lvl-mods-list lvl-mod-list)
                                        (when (and mission world-sector)
                                          (values world-sector mission))))
                                   )
                               (get-txt-from-file "data/descriptions/criminals.txt")))
        (join-satanist-item (list "Join the Satanists"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-satanist+)
                                        (when (and mission world-sector)
                                          (values world-sector mission)))
                                      )
                                  (get-txt-from-file "data/descriptions/satanists.txt")))
        (join-church-item (list "Join the Church"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-priest+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                    )
                                (get-txt-from-file "data/descriptions/church.txt")))
        (join-eater-item (list "Join as the Eater of the dead"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   ;; do not start in the snow
                                   (let ((lvl-mod-list (remove +lm-weather-snow+ (get-all-lvl-mods-list) :key #'(lambda (a)
                                                                                                                  (lm-type a)))))
                                      (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-eater+ :avail-lvl-mods-list lvl-mod-list)
                                        (when (and mission world-sector)
                                          (values world-sector mission))))
                                   )
                               (get-txt-from-file "data/descriptions/primordials_eater.txt")))
        (join-skin-item (list "Join as the Skinchanger"
                              #'(lambda (n) 
                                  (declare (ignore n))
                                  ;; do not start in the snow
                                   (let ((lvl-mod-list (remove +lm-weather-snow+ (get-all-lvl-mods-list) :key #'(lambda (a)
                                                                                                                  (lm-type a)))))
                                     (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-skinchanger+ :avail-lvl-mods-list lvl-mod-list)
                                       (when (and mission world-sector)
                                         (values world-sector mission))))
                                  )
                              (get-txt-from-file "data/descriptions/primordials_skinchanger.txt")))
        (join-ghost-item (list "Join as the Lost soul"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   (multiple-value-bind (mission world-sector) (find-random-scenario-options +specific-faction-type-ghost+)
                                      (when (and mission world-sector)
                                        (values world-sector mission)))
                                   )
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

(defun new-campaign-menu-items ()
  (let ((menu-items nil)
        (menu-funcs nil)
        (menu-descrs nil)
        (join-heaven-item (list "Join the Celestial Communion (as a Chrome angel)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    +specific-faction-type-angel-chrome+
                                    )
                                (get-txt-from-file "data/descriptions/communion_chrome.txt")))
        (join-trinity-item (list "Join the Celestial Communion (as a Trinity mimic)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    +specific-faction-type-angel-trinity+
                                    )
                                (get-txt-from-file "data/descriptions/communion_trinity.txt")))
        (join-legion-item (list "Join the Pandemonium Hierarchy (as a Crimson imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    +specific-faction-type-demon-crimson+
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_crimsonimp.txt")))
        (join-shadow-item (list "Join the Pandemonium Hierarchy (as a Shadow imp)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    +specific-faction-type-demon-shadow+
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_shadowimp.txt")))
        (join-puppet-item (list "Join the Pandemonium Hierarchy (as Malseraph's puppet)"
                                #'(lambda (n) 
                                    (declare (ignore n))
                                    +specific-faction-type-demon-malseraph+
                                    )
                                (get-txt-from-file "data/descriptions/pandemonium_puppet.txt")))
        (join-chaplain-item (list "Join the Military (as a Chaplain)"
                                  #'(lambda (n) 
                                      (declare (ignore n))
                                      +specific-faction-type-military-chaplain+
                                      )
                                  (get-txt-from-file "data/descriptions/military_chaplain.txt")))
        (join-scout-item (list "Join the Military (as a Scout)"
                               #'(lambda (n) 
                                   (declare (ignore n))
                                   +specific-faction-type-military-scout+
                                   )
                               (get-txt-from-file "data/descriptions/military_scout.txt")))
        
        )

    (setf menu-items (list (first join-heaven-item) (first join-trinity-item) (first join-legion-item) (first join-shadow-item) (first join-puppet-item)
                           (first join-chaplain-item) (first join-scout-item)))
    (setf menu-funcs (list (second join-heaven-item) (second join-trinity-item) (second join-legion-item) (second join-shadow-item) (second join-puppet-item)
                           (second join-chaplain-item) (second join-scout-item)))
    (setf menu-descrs (list (third join-heaven-item) (third join-trinity-item) (third join-legion-item) (third join-shadow-item) (third join-puppet-item)
                            (third join-chaplain-item) (third join-scout-item)))

    (values menu-items menu-funcs menu-descrs)))
