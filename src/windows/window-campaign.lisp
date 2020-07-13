
(in-package :cotd)

(defenum:defenum campaign-window-tab-type (:campaign-window-map-mode
                                           :campaign-window-mission-mode
                                           :campaign-window-status-mode
                                           :campaign-window-effects-mode
                                           :campaign-window-command-mode
                                           :campaign-window-help-mode))

(defclass campaign-window (window)
  ((cur-sector :initform (cons 0 0) :initarg :cur-sector :accessor campaign-window/cur-sector :type cons)
   (cur-mode :initform :campaign-window-map-mode :initarg :cur-mode :accessor campaign-window/cur-mode :type campaign-window-tab-type)
   (prev-mode :initform :campaign-window-mission-mode :initarg :prev-mode :accessor campaign-window/prev-mode :type campaign-window-tab-type)
   (cur-sel :initform 0 :accessor campaign-window/cur-sel :type fixnum)
   (avail-missions :initform () :accessor campaign-window/avail-missions :type list)
   (test-map-func :initform nil :initarg :test-map-func :accessor campaign-window/test-map-func)
   (reveal-lair :initform t :initarg :reveal-lair :accessor campaign-window/reveal-lair :type boolean)))

(defmethod initialize-instance :after ((win campaign-window) &key)
  (with-slots (cur-mode) win
    (campaign-win-calculate-avail-missions win)

    (when (eq cur-mode :campaign-window-command-mode)
      (campaign-win-display-command win))
    
    (when (eq cur-mode :campaign-window-status-mode) 
      (campaign-win-display-sitrep win))

    (when (eq cur-mode :campaign-window-effects-mode) 
      (campaign-win-display-effects win))

    (when (eq cur-mode :campaign-window-help-mode) 
      (campaign-win-display-help win))

    (when (eq cur-mode :campaign-window-mission-mode)
      (campaign-win-move-select-to-mission win)))
  )

(defmethod campaign-win-display-sitrep ((win campaign-window))
  (when (not (eq (campaign-window/cur-mode win) :campaign-window-status-mode))
    (setf (campaign-window/prev-mode win) (campaign-window/cur-mode win))
    (setf (campaign-window/cur-mode win) :campaign-window-status-mode))

  (let ((sitrep-msg-box (make-message-box)))
    (setf (colored-txt-list (message-box-strings sitrep-msg-box)) (append (colored-txt-list (message-box-strings (world/mission-message-box *world*)))
                                                                          (colored-txt-list (message-box-strings (world/event-message-box *world*)))
                                                                          (colored-txt-list (message-box-strings (world/effect-message-box *world*)))))
    
    (setf *current-window* (make-instance 'message-window 
                                          :return-to win
                                          :message-box sitrep-msg-box
                                          :header-str "SITUATION REPORT"))
    (make-output *current-window*)
    (run-window *current-window*)
  )
  (setf (campaign-window/cur-mode win) (campaign-window/prev-mode win)))

(defmethod campaign-win-display-effects ((win campaign-window))
  (let* ((effects-message-box (make-message-box))
         (message-box-list `(,effects-message-box)))
    (loop for campaign-effect in (world/campaign-effects *world*) do
      (add-message (format nil "~A" (campaign-effect/name campaign-effect)) sdl:*yellow* message-box-list)
      (if (campaign-effect/cd campaign-effect)
        (add-message (format nil " [~A turn~:P left]~%" (campaign-effect/cd campaign-effect)) sdl:*white* message-box-list)
        (add-message (format nil "~%") sdl:*white* message-box-list))
      (add-message (format nil "~A~%~%" (campaign-effect/descr campaign-effect)) sdl:*white* message-box-list))
    
    (when (not (eq (campaign-window/cur-mode win) :campaign-window-effects-mode))
      (setf (campaign-window/prev-mode win) (campaign-window/cur-mode win))
      (setf (campaign-window/cur-mode win) :campaign-window-effects-mode))
    
    (setf *current-window* (make-instance 'message-window 
                                          :return-to win
                                          :message-box effects-message-box
                                          :header-str "CURRENT EFFECTS"))
    (make-output *current-window*)
    (run-window *current-window*)

    (setf (campaign-window/cur-mode win) (campaign-window/prev-mode win))))

(defmethod campaign-win-display-help ((win campaign-window))
  (when (not (eq (campaign-window/cur-mode win) :campaign-window-help-mode))
    (setf (campaign-window/prev-mode win) (campaign-window/cur-mode win))
    (setf (campaign-window/cur-mode win) :campaign-window-help-mode))

  (let* ((help-msg-box (make-message-box))
         (msg-box-list `(,help-msg-box))
         (text-list (list (list +faction-type-angels+ +game-event-campaign-angel-win+)
                          (list +faction-type-demons+ +game-event-campaign-demon-win+)
                          (list +faction-type-military+ +game-event-campaign-military-win+)))
         (keys-txt (get-txt-from-file "help/campaign_keybindings.txt")))
    (when (find (get-general-faction-from-specific (world/player-specific-faction *world*)) text-list :key #'(lambda (a) (first a)))
      (let ((objective-text (funcall (descr-func (get-game-event-by-id (second (find (get-general-faction-from-specific (world/player-specific-faction *world*)) text-list :key #'(lambda (a) (first a)))))))))
        (add-message objective-text sdl:*white* msg-box-list)))

    (when keys-txt
      (add-message (format nil "~%~%~%") sdl:*white* msg-box-list)
      (add-message keys-txt sdl:*white* msg-box-list))
    
    (setf *current-window* (make-instance 'message-window 
                                          :return-to win
                                          :message-box help-msg-box
                                          :header-str "HELP"))
    (make-output *current-window*)
    (run-window *current-window*)
  )
  (setf (campaign-window/cur-mode win) (campaign-window/prev-mode win)))

(defmethod campaign-win-display-command ((win campaign-window))
  (when (not (eq (campaign-window/cur-mode win) :campaign-window-command-mode))
    (setf (campaign-window/prev-mode win) (campaign-window/cur-mode win))
    (setf (campaign-window/cur-mode win) :campaign-window-command-mode))
  
  (let ((player-faction (get-general-faction-from-specific (world/player-specific-faction *world*))))
    (when (not (gethash player-faction (world/commands *world*)))
      (let ((command-list (loop for command being the hash-values in *campaign-commands*
                                when (and (eq (campaign-command/faction-type command) player-faction)
                                          (funcall (campaign-command/on-check-func command) *world* command))
                                  collect command))
            (menu-items ())
            (prompt-list ())
            (enter-func nil)
            (header-str nil))
        (setf header-str "Select a command")
        (setf menu-items (loop for command in command-list
                                       collect (funcall (campaign-command/name-func command) *world*)))
        (setf prompt-list (loop repeat (length menu-items)
                                collect #'(lambda (cur-sel)
                                            (declare (ignore cur-sel))
                                            "[Enter] Select")))
        (setf enter-func #'(lambda (cur-sel)
                             (setf (gethash player-faction (world/commands *world*))
                                   (list :command (campaign-command/id (nth cur-sel command-list)) :cd (campaign-command/cd (nth cur-sel command-list))))
                             (setf *current-window* (return-to *current-window*))
                             ))
        (setf *current-window* (make-instance 'select-obj-window 
                                              :return-to *current-window*
                                              :header-line header-str
                                              :line-list menu-items
                                              :prompt-list prompt-list
                                              :enter-func enter-func
                                              :can-esc nil
                                              ))
        (make-output *current-window*)
        (run-window *current-window*))))
  
  (setf (campaign-window/cur-mode win) (campaign-window/prev-mode win)))

(defmethod campaign-win-display-init-hint ((win campaign-window))

  (let* ((msg-str nil)
         (text-list (list (list +faction-type-angels+ +game-event-campaign-angel-win+)
                          (list +faction-type-demons+ +game-event-campaign-demon-win+)
                          (list +faction-type-military+ +game-event-campaign-military-win+))))

    (setf msg-str (format nil "Welcome to the campaign of the City of the Damned!"))
    
    (when (find (get-general-faction-from-specific (world/player-specific-faction *world*)) text-list :key #'(lambda (a) (first a)))
      (let ((objective-text (funcall (descr-func (get-game-event-by-id (second (find (get-general-faction-from-specific (world/player-specific-faction *world*)) text-list :key #'(lambda (a) (first a)))))))))
        (setf msg-str (format nil "~A~%~%" msg-str))
        (setf msg-str (format nil "~A~A" msg-str objective-text))))
    
    (setf msg-str (format nil "~A~%~%To display help, press '?'." msg-str))
    
    (setf *current-window* (make-instance 'display-msg-window
                                          :msg-line msg-str
                                          :w 400))
    (make-output *current-window*)
    (run-window *current-window*))
  )

(defmethod campaign-win-display-mission-details ((win campaign-window))
  (with-accessors ((cur-sector campaign-window/cur-sector)
                   (reveal-lair campaign-window/reveal-lair))
      win
    (let* ((world-sector (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
           (mission-type (get-mission-type-by-id (mission-type-id (mission world-sector))))
           (msg-str nil))
      (setf msg-str (format nil "~A~%~%" (name (mission world-sector))))
      (setf msg-str (format nil "~A~A~%" msg-str (description world-sector :reveal-lair reveal-lair)))
      (when (find (get-general-faction-from-specific (world/player-specific-faction *world*)) (win-condition-list mission-type) :key #'(lambda (a) (first a)))
        (let ((objective-text (funcall (descr-func (get-game-event-by-id (second (find (get-general-faction-from-specific (world/player-specific-faction *world*)) (win-condition-list mission-type) :key #'(lambda (a) (first a)))))))))
          (setf msg-str (format nil "~A~A~%~%" msg-str objective-text))))
    
    (setf *current-window* (make-instance 'display-msg-window
                                          :msg-line msg-str
                                          :w (truncate (* *window-width* 2/3))
                                          :prompt-line "[Enter] Start mission  [Esc] Cancel"))
    (make-output *current-window*)
    (run-window *current-window*)))
  )

(defmethod campaign-win-calculate-avail-missions ((win campaign-window))
  (with-slots (avail-missions) win
    (setf avail-missions (world/present-missions *world*))))

(defmethod campaign-win-move-select-to-mission ((win campaign-window))
  (with-slots (cur-sector cur-sel avail-missions) win
    (when avail-missions
      (setf cur-sector (cons (x (nth cur-sel avail-missions))
                             (y (nth cur-sel avail-missions)))))))

(defun calc-is-mission-available (mission general-player-faction)
  (let* ((faction-obj (find general-player-faction (faction-list mission) :key #'(lambda (a) (first a))))
         (faction-present (if faction-obj
                            (not (eq (second faction-obj) :mission-faction-absent))
                            nil)))
    faction-present))

(defmethod make-output ((win campaign-window))
  (with-slots (cur-mode cur-sector cur-sel avail-missions reveal-lair) win

    (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
      (sdl:fill-surface sdl:*black* :template a-rect))

    (let* ((x1 20) (y1 20) (map-w (* *glyph-w* 5 *max-x-world-map*)) (map-h (* *glyph-h* 5 *max-y-world-map*))
           (x2 (+ x1 map-w 20)) (y2 (+ y1 20))
           (select-mission-sector-str "Select mission in a sector:")
           (select-avail-mission-str "Select available mission:")
           (date-str (format nil "~A" (show-date-time-YMD (world-game-time *world*))))
           (init-campaign-str "Generate a campaign map, press [r] to create a new one")
           (prompt-str nil)
           (header-str nil))
      
      (with-slots (game-state) *game-manager*
        (case game-state
          (:game-state-campaign-init (progn
                                       (setf header-str "NEW CAMPAIGN")
                                       (setf prompt-str (format nil "[Enter] Accept map  [r] Randomize map  [Arrows/Numpad] Move selection"))

                                       ;; draw subheader
                                       (sdl:draw-string-solid-* init-campaign-str (- (truncate *window-width* 2) (truncate (* (length init-campaign-str) (sdl:char-width sdl:*default-font*)) 2)) y1 :justify :left :color sdl:*white*)))
          (:game-state-campaign-map (progn
                                      (let* ((player-faction (get-general-faction-from-specific (world/player-specific-faction *world*)))
                                             (demon-win-cond (get-win-condition-by-id :win-cond-demon-campaign))
                                             (military-win-cond (get-win-condition-by-id :win-cond-military-campaign))
                                             (angels-win-cond (get-win-condition-by-id :win-cond-angels-campaign))
                                             (max-flesh-points (win-condition/win-formula demon-win-cond))
                                             (normal-sectors-left (funcall (win-condition/win-func demon-win-cond) *world* demon-win-cond))
                                             (machines-left (funcall (win-condition/win-func angels-win-cond) *world* angels-win-cond))
                                             (demon-str nil)
                                             (max-lines 0)
                                             (command-str "Press [c] to select a new command"))

                                        (setf header-str "CAMPAIGN MAP")
                                        (setf prompt-str (format nil "~A[Tab] Change mode  ~A[s] Situation report  [e] Effects  [n] Next day"
                                                                 (if (and (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
                                                                          (calc-is-mission-available (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
                                                                                                     (get-general-faction-from-specific (world/player-specific-faction *world*))))
                                                                   "[Enter] Start mission  "
                                                                   "")
                                                                 (if (not (gethash player-faction (world/commands *world*)))
                                                                   "[c] Select a command  "
                                                                   "")
                                                                 ))
                                        
                                        (when (gethash player-faction (world/commands *world*))
                                          (let* ((world-command (gethash player-faction (world/commands *world*)))
                                                 (command (get-campaign-command-by-id (getf world-command :command)))
                                                 (cd (getf world-command :cd)))
                                            (setf command-str (format nil "~A ~A"
                                                                      (funcall (campaign-command/name-func command) *world*)
                                                                      (if (campaign-command/on-trigger-end-func command)
                                                                        (format nil "[complete in ~A day~:P]" cd)
                                                                        (format nil "[~A day~:P for next]" cd))))))
                                        (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) *world* military-win-cond)
                                          (setf demon-str (format nil "Flesh gathered: ~A of ~A, inhabited districts left: ~A, sectors corrupted: ~A, satanists' lairs left: ~A, dimensional engines left: ~A~%~%Command: ~A"
                                                                  (world/flesh-points *world*) max-flesh-points normal-sectors-left corrupted-sectors-left satanist-lairs-left machines-left command-str)))
                                        
                                        (sdl:with-rectangle (a-rect (sdl:rectangle :x (+ x1 0) :y (+ y1 map-h 50) :w (- *window-width* x1 20) :h (* 1 (sdl:get-font-height))))
                                          (setf max-lines (write-text demon-str a-rect :count-only t)))
                                        (sdl:with-rectangle (a-rect (sdl:rectangle :x (+ x1 0) :y (+ y1 map-h 50) :w (- *window-width* x1 20) :h (* max-lines (sdl:get-font-height))))
                                          (write-text demon-str a-rect))
                                        )
                                      
                                      
                                      ;; draw subheader
                                      (if (eq cur-mode :campaign-window-map-mode)
                                        (sdl:draw-string-solid-* select-mission-sector-str (+ x1 (truncate map-w 2)) y1 :justify :center :color sdl:*white*)
                                        (sdl:draw-string-solid-* select-avail-mission-str (+ x2 (truncate (- *window-width* x2 20) 2)) y1 :justify :center :color sdl:*white*)))))
        )

      ;; draw map
      (draw-world-map (world-map *world*) x1 y2 :reveal-lairs reveal-lair)
      (highlight-world-map-tile (+ x1 (* (car cur-sector) (* *glyph-w* 5))) (+ y2 (* (cdr cur-sector) (* *glyph-h* 5))))

      ;; draw date
      (sdl:draw-string-solid-* date-str (+ x1 (truncate map-w 2)) (+ y1 map-h 30) :justify :center :color sdl:*white*)

      ;; display missions
      (case cur-mode
        (:campaign-window-map-mode (progn
                                     (sdl:with-rectangle (rect (sdl:rectangle :x x2 :y y2 :w (- *window-width* x2 20) :h map-h))
                                       (write-text (description (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)) :reveal-lair reveal-lair)
                                                   rect))))
        (:campaign-window-mission-mode (progn
                                         (let ((color-list nil)
                                               (mission-names-list ())
                                               (str-per-page 10))
                                           (loop with general-player-faction = (get-general-faction-from-specific (world/player-specific-faction *world*))
                                                 for i from 0 below (length avail-missions)
                                                 for mission = (nth i avail-missions)
                                                 for faction-present = (calc-is-mission-available mission general-player-faction)
                                                 do
                                                    (push (name mission) mission-names-list)
                                                    (cond
                                                      ((and (= i cur-sel) faction-present) (push sdl:*yellow* color-list))
                                                      ((and (= i cur-sel) (not faction-present)) (push (sdl:color :r 150 :g 150 :b 0) color-list))
                                                      ((and (/= i cur-sel) faction-present) (push sdl:*white* color-list))
                                                      ((and (/= i cur-sel) (not faction-present)) (push (sdl:color :r 150 :g 150 :b 150) color-list)))
                                                 finally
                                                    (setf mission-names-list (reverse mission-names-list))
                                                    (setf color-list (reverse color-list)))
                                           
                                           (draw-selection-list mission-names-list cur-sel str-per-page x2 y2 :color-list color-list)
                                           
                                           (sdl:with-rectangle (rect (sdl:rectangle :x x2
                                                                                    :y (+ y2 10 (* (sdl:char-height sdl:*default-font*) str-per-page))
                                                                                    :w (- *window-width* x2 20)
                                                                                    :h (- *window-height* 40 (+ 10 10 (* (sdl:char-height sdl:*default-font*) str-per-page)))))
                                             (write-text (description (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)) :reveal-lair reveal-lair)
                                                         rect))))))
      
      ;; draw header
      (sdl:draw-string-solid-* header-str (truncate *window-width* 2) 0 :justify :center :color sdl:*white*)

      ;; draw prompt
      (sdl:draw-string-solid-* prompt-str 10 (- *window-height* 10 (sdl:char-height sdl:*default-font*))))

    (sdl:update-display)))

(defmethod run-window ((win campaign-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)
                                          
                     ;; normalize mod
                     (loop while (>= mod sdl-key-mod-num) do
                       (decf mod sdl-key-mod-num))

                     (with-slots (test-map-func cur-mode cur-sector cur-sel avail-missions return-to reveal-lair) win
                       ;;------------------
                       ;; moving - arrows
                       (case cur-mode
                         (:campaign-window-map-mode (progn (let ((new-coords cur-sector))
                                                                 (when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                                                                   (setf new-coords (cons (car cur-sector)
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (1- (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (cdr cur-sector)))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (cdr cur-sector)))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                                                                   (setf new-coords (cons (1+ (car cur-sector))
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                                                                   (setf new-coords (cons (car cur-sector)
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 (when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                                                                   (setf new-coords (cons (1- (car cur-sector))
                                                                                          (1+ (cdr cur-sector))))
                                                                   )
                                                                 
                                                                 (when (and (>= (car new-coords) 0) (>= (cdr new-coords) 0)
                                                                            (< (car new-coords) *max-x-world-map*) (< (cdr new-coords) *max-y-world-map*))
                                                                   (setf cur-sector new-coords))
                                                                 )))
                         (:campaign-window-mission-mode (progn (setf cur-sel (run-selection-list key mod unicode cur-sel))
                                                                   (setf cur-sel (adjust-selection-list cur-sel (length avail-missions)))
                                                                   (campaign-win-move-select-to-mission win))))
                       
                       (cond
                         ;; escape - quit
                         ((sdl:key= key :sdl-key-escape)
                          (with-slots (game-state) *game-manager*
                           (case game-state
                             (:game-state-campaign-map (show-escape-menu))))
                          
                          )
                         ;; r - random map
                         ((sdl:key= key :sdl-key-r)
                          (with-slots (game-state) *game-manager*
                            (case game-state
                              (:game-state-campaign-init (progn
                                                           (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time *world*))
                                                             (declare (ignore month))
                                                             (setf (world-game-time *world*) (set-current-date-time year (random 12) day hour min sec)))
                                                           (setf (world-map *world*) (generate-normal-world-map *world*))
                                                           (setf cur-mode :campaign-window-map-mode))))
                            )
                          )
                         ;; Shift + D - debug menu, for debug purposes only
                         ((and (sdl:key= key :sdl-key-d) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0)
                               (null *cotd-release*))
                          (let ((menu-items ())
                                (prompt-list ())
                                (enter-func nil)
                                (header-str nil))
                            (setf header-str "Debug Menu")
                            (setf menu-items (list "Add 500 flesh points"
                                                   (if reveal-lair
                                                     "Hide satanists' lairs"
                                                     "Show satanists' lairs")
                                                   "Close"))
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
                                                        (incf (world/flesh-points *world*) 500)
                                                        (setf *current-window* (return-to *current-window*))))
                                                   (1 (progn
                                                        (setf reveal-lair (not reveal-lair))
                                                        (setf *current-window* (return-to *current-window*))))
                                                   (t (progn
                                                        (setf *current-window* (return-to *current-window*)))))
                                                 ))
                            (setf *current-window* (make-instance 'select-obj-window 
                                                                  :return-to *current-window*
                                                                  :header-line header-str
                                                                  :line-list menu-items
                                                                  :prompt-list prompt-list
                                                                  :enter-func enter-func
                                                                  ))
                            (make-output *current-window*)
                            (run-window *current-window*))
                          )
                         ;; tab - change mode
                         ((sdl:key= key :sdl-key-tab)
                          (if (eq cur-mode :campaign-window-mission-mode)
                            (setf cur-mode :campaign-window-map-mode)
                            (when avail-missions
                              (setf cur-mode :campaign-window-mission-mode)
                              (campaign-win-move-select-to-mission win))))
                         ;; enter - select
                         ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                          (with-slots (game-state) *game-manager*
                            (case game-state
                              (:game-state-campaign-init (progn
                                                           (generate-missions-on-world-map *world*)
                                                           (campaign-win-calculate-avail-missions win)
                                                           (setf cur-mode :campaign-window-mission-mode)
                                                           (campaign-win-move-select-to-mission win)
                                                           (game-state-campaign-init->campaign-map)
                                                           (make-output *current-window*)
                                                           (campaign-win-display-init-hint win)
                                                           ))
                              (:game-state-campaign-map (when (and (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
                                                                   (calc-is-mission-available (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
                                                                                              (get-general-faction-from-specific (world/player-specific-faction *world*))))
                                                          (when (campaign-win-display-mission-details win)
                                                            (campaign-win-display-command win)
                                                            (return-from run-window (values (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector)))
                                                                                            (world-sector (mission (aref (cells (world-map *world*)) (car cur-sector) (cdr cur-sector))))))))))
                            )))
                       ;;------------------
                       ;; select a command - c
                       (when (or (and (sdl:key= key :sdl-key-c) (= mod 0))
                                 (eq unicode +cotd-unicode-latin-c-small+))
                         (case (game-manager/game-state *game-manager*)
                           (:game-state-campaign-map (campaign-win-display-command win))))
                       ;;------------------
                       ;; view situation report - s
                       (when (or (and (sdl:key= key :sdl-key-s) (= mod 0))
                                 (eq unicode +cotd-unicode-latin-s-small+))
                          (case (game-manager/game-state *game-manager*)
                            (:game-state-campaign-map (campaign-win-display-sitrep win))))
                       ;;------------------
                       ;; view situation report - e
                       (when (or (and (sdl:key= key :sdl-key-e) (= mod 0))
                                 (eq unicode +cotd-unicode-latin-e-small+))
                          (case (game-manager/game-state *game-manager*)
                            (:game-state-campaign-map (campaign-win-display-effects win))))
                       ;;------------------
                       ;; help screen - ?
                       (when (or (sdl:key= key :sdl-key-question)
                                 (eq unicode +cotd-unicode-question-mark+)
                                 (and (sdl:key= key :sdl-key-slash) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                 (and (sdl:key= key :sdl-key-7) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0)))
                          (case (game-manager/game-state *game-manager*)
                            (:game-state-campaign-map (campaign-win-display-help win))))
                       ;;------------------
                       ;; next day - n
                       (when (or (and (sdl:key= key :sdl-key-n) (= mod 0))
                                 (eq unicode +cotd-unicode-latin-n-small+))
                         (with-slots (game-state) *game-manager*
                           (case game-state
                             (:game-state-campaign-map (progn
                                                         (campaign-win-display-command win)
                                                         
                                                         (game-state-campaign-map->post-scenario)
                                                         (return-from run-window nil))))))
                       (make-output *current-window*)))
    (:idle () #+swank
              (update-swank)
              )
    (:video-expose-event () (make-output *current-window*))))
