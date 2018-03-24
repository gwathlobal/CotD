(in-package :cotd)

(defconstant +custom-scenario-win-mission+ 0)
(defconstant +custom-scenario-win-layout+ 1)
(defconstant +custom-scenario-win-weather+ 2)
(defconstant +custom-scenario-win-time-of-day+ 3)
(defconstant +custom-scenario-win-factions+ 4)
(defconstant +custom-scenario-win-specific-faction+ 5)

(defconstant +custom-scenario-win-faction-attacker+ 0)
(defconstant +custom-scenario-win-faction-defender+ 1)
(defconstant +custom-scenario-win-faction-delayed-defender+ 2)
(defconstant +custom-scenario-win-faction-defender+ 1)

(defclass custom-scenario-window (window)
  ((cur-step :initform +custom-scenario-win-mission+ :accessor cur-step)
   (cur-sel :initform 0 :accessor cur-sel)
   (menu-items :initform () :accessor menu-items)
   (mission-list :initarg :mission-list :accessor mission-list)
   (layout-list :accessor layout-list)
   (weather-list :initarg :weather-list :accessor weather-list)
   (tod-list :initarg :tod-list :accessor tod-list)
   (specific-faction-list :accessor specific-faction-list)
   (ref-faction-list :accessor ref-faction-list)
   (cur-faction-list :accessor cur-faction-list)
   (cur-mission :initform 0 :initarg :cur-mission :accessor cur-mission)
   (cur-layout :initform 0 :initarg :cur-layout :accessor cur-layout)
   (cur-weather :initform 0 :initarg :cur-weather :accessor cur-weather)
   (cur-tod :initform 0 :initarg :cur-tod :accessor cur-tod)
   (cur-faction :initform 0 :initarg :cur-faction :accessor cur-faction)
   (cur-specific-faction :initform 0 :initarg :cur-specific-faction :accessor cur-specific-faction)
   ))

(defmethod initialize-instance :after ((win custom-scenario-window) &key)
  (setf (cur-mission win) (random (length (mission-list win))))
  (setf (layout-list win) (copy-list (district-layout-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))))
  (setf (cur-layout win) (random (length (layout-list win))))
  (setf (cur-weather win) (random (length (weather-list win))))
  (setf (cur-tod win) (random (length (tod-list win))))
  (setf (ref-faction-list win) (append (faction-list (get-mission-district-by-id (nth (cur-layout win) (layout-list win))))
                                       (faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))))
  (setf (cur-faction-list win) (loop with result = ()
                                     for (faction-id faction-present) in (ref-faction-list win)
                                     for faction-obj = (find faction-id result :key #'(lambda (a) (first a)))
                                     do
                                       (if faction-obj
                                         (progn
                                           (when (not (eq faction-present (second faction-obj)))
                                             (setf (second faction-obj) +mission-faction-absent+)))
                                         (progn
                                           (push (list faction-id faction-present) result)))
                                     finally (return-from nil result)))
  (setf (cur-faction win) (random (length (cur-faction-list win))))
  (setf (specific-faction-list win) (loop with result = ()
                                                   for (faction-id faction-present) in (cur-faction-list win)
                                                   for faction-obj = (get-faction-type-by-id faction-id)
                                                   when (or (= faction-present +mission-faction-attacker+)
                                                            (= faction-present +mission-faction-defender+))
                                                     do
                                                        (loop for specific-faction-type in (specific-faction-list faction-obj)
                                                              when (find specific-faction-type (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                         :key #'(lambda (a) (first a)))
                                                                do
                                                                   (setf result (append result (list specific-faction-type))))
                                                   finally (when (not *cotd-release*)
                                                             (when (find +specific-faction-type-player+ (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                         :key #'(lambda (a) (first a)))
                                                               (push +specific-faction-type-player+ result))
                                                             (when (find +specific-faction-type-dead-player+ (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                         :key #'(lambda (a) (first a)))
                                                               (push +specific-faction-type-dead-player+ result)))
                                                           (remove-duplicates result)
                                                           (return-from nil result)))
  (setf (cur-specific-faction win) (random (length (specific-faction-list win))))
  (setf (cur-sel win) (cur-mission win)))

(defun readjust-after-mission-change (win)
  (let ((cur-layout-id (nth (cur-layout win) (layout-list win))))
    (setf (layout-list win) (copy-list (district-layout-list (get-mission-scenario-by-id (cur-mission win)))))
    (if (position cur-layout-id (layout-list win))
      (progn
        (setf (cur-layout win) (position cur-layout-id (layout-list win))))
      (progn
        (setf (cur-layout win) (random (length (layout-list win))))))
    (readjust-after-layout-change win)))

(defun readjust-after-layout-change (win)
  (setf (ref-faction-list win) (append (faction-list (get-mission-district-by-id (nth (cur-layout win) (layout-list win))))
                                       (faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))))
  (setf (cur-faction-list win) (loop with result = ()
                                     for (faction-id faction-present) in (ref-faction-list win)
                                     for faction-obj = (find faction-id result :key #'(lambda (a) (first a)))
                                     do
                                       (if faction-obj
                                         (progn
                                           (when (not (eq faction-present (second faction-obj)))
                                             (setf (second faction-obj) +mission-faction-absent+)))
                                         (progn
                                           (push (list faction-id faction-present) result)))
                                       finally (return-from nil result)))
  (setf (cur-faction win) (random (length (cur-faction-list win))))
  (readjust-after-faction-change win))

(defun readjust-after-faction-change (win)
  (let ((cur-faction-id (nth (cur-specific-faction win) (specific-faction-list win))))
    (setf (specific-faction-list win) (loop with result = ()
                                                     for (faction-id faction-present) in (cur-faction-list win)
                                                     for faction-obj = (get-faction-type-by-id faction-id)
                                                     when (or (= faction-present +mission-faction-attacker+)
                                                              (= faction-present +mission-faction-defender+))
                                                       do
                                                          (loop for specific-faction-type in (specific-faction-list faction-obj)
                                                                when (find specific-faction-type (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                           :key #'(lambda (a) (first a)))
                                                                  do
                                                                     (setf result (append result (list specific-faction-type))))
                                                     finally (when (not *cotd-release*)
                                                               (when (find +specific-faction-type-player+ (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                           :key #'(lambda (a) (first a)))
                                                                 (push +specific-faction-type-player+ result))
                                                               (when (find +specific-faction-type-dead-player+ (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                           :key #'(lambda (a) (first a)))
                                                                 (push +specific-faction-type-dead-player+ result)))
                                                             (remove-duplicates result)
                                                             (return-from nil result)))
    (if (position cur-faction-id (specific-faction-list win))
      (progn
        (setf (cur-specific-faction win) (position cur-faction-id (specific-faction-list win))))
      (progn
        (setf (cur-specific-faction win) (random (length (specific-faction-list win))))))
    ))

(defun populate-custom-scenario-win-menu (win step)
  (cond
    ((= step +custom-scenario-win-mission+) (return-from populate-custom-scenario-win-menu
                                              (loop for id in (mission-list win)
                                                    collect (name (get-mission-scenario-by-id id)))))
    ((= step +custom-scenario-win-layout+) (return-from populate-custom-scenario-win-menu
                                             (loop for sf-id in (layout-list win)
                                                   collect (sf-name (get-scenario-feature-by-id sf-id)))))
    ((= step +custom-scenario-win-weather+) (return-from populate-custom-scenario-win-menu
                                               (loop for sf-id in (weather-list win)
                                                     collect (sf-name (get-scenario-feature-by-id sf-id)))))
    ((= step +custom-scenario-win-time-of-day+) (return-from populate-custom-scenario-win-menu
                                                  (loop for sf-id in (tod-list win)
                                                        collect (sf-name (get-scenario-feature-by-id sf-id)))))
    ((= step +custom-scenario-win-factions+) (return-from populate-custom-scenario-win-menu
                                               (loop for (faction-id faction-present) in (cur-faction-list win)
                                                     collect (format nil "~A ~A"
                                                                     (cond
                                                                       ((= faction-present +mission-faction-present+) "[+]")
                                                                       ((= faction-present +mission-faction-attacker+) "[A]")
                                                                       ((= faction-present +mission-faction-defender+) "[D]")
                                                                       ((= faction-present +mission-faction-delayed+) "[d]")
                                                                       (t "[-]"))
                                                                     (name (get-faction-type-by-id faction-id))))))
    ((= step +custom-scenario-win-specific-faction+) (format t "~A~%" (specific-faction-list win))(return-from populate-custom-scenario-win-menu
                                                       (loop for specific-faction-type in (specific-faction-list win)
                                                             when (find specific-faction-type (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                        :key #'(lambda (a) (first a)))
                                                               collect (sf-name (get-scenario-feature-by-id (second (find specific-faction-type
                                                                                                                          (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                                                                          :key #'(lambda (a) (first a)))))))
                                                       ))))

(defun get-included-faction-str (win-faction-list)
  (loop with str = (create-string)
        with first-no-comma = t
        for (faction-id faction-present) in win-faction-list
        when (/= faction-present +mission-faction-absent+) do
          (format str "~A~A ~A"
                  (if (not first-no-comma)
                    ", "
                    "")
                  (cond
                    ((= faction-present +mission-faction-present+) "[+]")
                    ((= faction-present +mission-faction-attacker+) "[A]")
                    ((= faction-present +mission-faction-defender+) "[D]")
                    ((= faction-present +mission-faction-delayed+) "[d]"))
                  (name (get-faction-type-by-id faction-id)))
          (setf first-no-comma nil)
        finally (return-from nil str)))

(defmethod make-output ((win custom-scenario-window))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x 0 :y 0 :w *window-width* :h *window-height*))
    (sdl:fill-surface sdl:*black* :template a-rect))

  (sdl:draw-string-solid-* "CUSTOM SCENARIO" (truncate *window-width* 2) 0 :justify :center)

  (let ((text-str-num))
    ;; draw the current scenario info
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (+ 10 (sdl:char-height sdl:*default-font*)) :w (- *window-width* 20) :h (- (truncate *window-height* 2) 20)))
      (setf text-str-num (write-text (format nil "Mission: ~A~%Layout: ~A~%Weather: ~A~%Time of day: ~A~%Factions: ~A~%Player faction: ~A"
                                             (name (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                             (sf-name (get-scenario-feature-by-id (nth (cur-layout win) (layout-list win))))
                                             (sf-name (get-scenario-feature-by-id (nth (cur-weather win) (weather-list win))))
                                             (sf-name (get-scenario-feature-by-id (nth (cur-tod win) (tod-list win))))
                                             (get-included-faction-str (cur-faction-list win))
                                             (sf-name (get-scenario-feature-by-id (second (find (nth (cur-specific-faction win) (specific-faction-list win))
                                                                                                (scenario-faction-list (get-mission-scenario-by-id (nth (cur-mission win) (mission-list win))))
                                                                                                :key #'(lambda (a) (first a))))))
                                             )
                                     rect)))
      
    ;; draw the steps of scenario customization
    (let ((color-1 sdl:*white*) (color-2 sdl:*white*) (color-3 sdl:*white*) (color-4 sdl:*white*) (color-5 sdl:*white*) (color-6 sdl:*white*))
      (cond
        ((= (cur-step win) +custom-scenario-win-mission+) (setf color-1 sdl:*yellow*))
        ((= (cur-step win) +custom-scenario-win-layout+) (setf color-2 sdl:*yellow*))
        ((= (cur-step win) +custom-scenario-win-weather+) (setf color-3 sdl:*yellow*))
        ((= (cur-step win) +custom-scenario-win-time-of-day+) (setf color-4 sdl:*yellow*))
        ((= (cur-step win) +custom-scenario-win-factions+) (setf color-5 sdl:*yellow*))
        ((= (cur-step win) +custom-scenario-win-specific-faction+) (setf color-6 sdl:*yellow*)))

      (sdl:draw-string-solid-* (format nil "1. Mission") 10 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :left :color color-1)
      (sdl:draw-string-solid-* (format nil "2. City layout") (* 5 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-2)
      (sdl:draw-string-solid-* (format nil "3. Weather") (* 8 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-3)
      (sdl:draw-string-solid-* (format nil "4. Time of day") (* 11 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-4)
      (sdl:draw-string-solid-* (format nil "5. Factions") (* 14 (truncate *window-width* 20)) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :center :color color-5)
      (sdl:draw-string-solid-* (format nil "6. Player faction") (- *window-width* 10) (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 2 text-str-num))) :justify :right :color color-6))
    
    ;; draw the selection for each step
    (let ((cur-str) (color-list nil))
      (setf cur-str (cur-sel win))
      (dotimes (i (length (menu-items win)))
        (if (= i cur-str) 
          (setf color-list (append color-list (list sdl:*yellow*)))
          (setf color-list (append color-list (list sdl:*white*)))))
      (draw-selection-list (menu-items win) cur-str (length (menu-items win)) 20 (+ 10 (* (sdl:char-height sdl:*default-font*) (+ 4 text-str-num))) :color-list color-list))
    )
    
    (sdl:with-rectangle (rect (sdl:rectangle :x 10 :y (- *window-height* 10 (* 2 (sdl:char-height sdl:*default-font*))) :w (- *window-width* 20) :h (* 2 (sdl:char-height sdl:*default-font*))))
    (let ((str (create-string)))
      (cond
        ((= (cur-step win) +custom-scenario-win-mission+) (format str "[Enter/Right] Select  [Up/Down] Move selection  [Esc] Exit"))
        ((= (cur-step win) +custom-scenario-win-specific-faction+) (format str "[Enter] Start game  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit"))
        ((= (cur-step win) +custom-scenario-win-factions+) (progn
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-attacker+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                     (if (and (/= (second a) +mission-faction-attacker+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+))
                                                               (format str "[Space] Include as attacker  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-attacker+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                     (if (and (/= (second a) +mission-faction-attacker+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+))
                                                               (format str "[Space] Exclude as attacker  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-defender+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-defender+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+))
                                                               (format str "[Space] Include as defender  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-defender+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-defender+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+))
                                                               (format str "[Space] Exclude as defender  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-delayed+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-delayed+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+))
                                                               (format str "[d] Include as delayed faction  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-delayed+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-delayed+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+))
                                                               (format str "[d] Exclude as delayed faction  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-present+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-present+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (not (find-if #'(lambda (a)
                                                                                          (if (and (= (second a) +mission-faction-defender+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                      (ref-faction-list win)))
                                                                        (not (find-if #'(lambda (a)
                                                                                          (if (and (= (second a) +mission-faction-attacker+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                      (ref-faction-list win)))
                                                                        (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+))
                                                               (format str "[Space] Include as present faction  "))
                                                             (when (and (find-if #'(lambda (a)
                                                                                     (if (and (= (second a) +mission-faction-present+)
                                                                                              (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                       t
                                                                                       nil))
                                                                                 (ref-faction-list win))
                                                                        (find-if #'(lambda (a)
                                                                                          (if (and (/= (second a) +mission-faction-present+)
                                                                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                                                            t
                                                                                            nil))
                                                                                 (ref-faction-list win))
                                                                        (= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+))
                                                               (format str "[Space] Exclude as present faction  "))
                                                             (format str "[Right] Next step  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")))
        (t (format str "[Enter/Right] Select  [Up/Down] Move selection  [Left] Previous step  [Esc] Exit")))
      (write-text str rect)))
  
  (sdl:update-display))

(defmethod run-window ((win custom-scenario-window))
  (sdl:with-events ()
    (:quit-event () (funcall (quit-func win)) t)
    (:key-down-event (:key key :mod mod :unicode unicode)

                     (cond
                       ((sdl:key= key :sdl-key-left)
                        (decf (cur-step win))
                        (when (< (cur-step win) +custom-scenario-win-mission+)
                          (setf (cur-step win) +custom-scenario-win-mission+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                       
                       ((sdl:key= key :sdl-key-right)
                        (incf (cur-step win))
                        (when (> (cur-step win) +custom-scenario-win-specific-faction+)
                          (setf (cur-step win) +custom-scenario-win-specific-faction+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                       
                       ;; escape - quit
                       ((sdl:key= key :sdl-key-escape)
                        (setf *current-window* (return-to win))
                        (return-from run-window (values nil nil nil nil)))

                       ;; Space - include/exclude faction as a defender
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-defender+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-defender+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-defender+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; d - include/exclude faction as a delayed defender
                       ((and (sdl:key= key :sdl-key-d)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-delayed+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-delayed+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-delayed+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; Space - include/exclude faction as an attacker
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-attacker+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-attacker+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win)))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-attacker+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )

                       ;; space - include/exclude faction as present
                       ((and (sdl:key= key :sdl-key-space)
                             (= (cur-step win) +custom-scenario-win-factions+)
                             (find-if #'(lambda (a)
                                          (if (and (= (second a) +mission-faction-present+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (find-if #'(lambda (a)
                                          (if (and (/= (second a) +mission-faction-present+)
                                                   (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                            t
                                            nil))
                                      (ref-faction-list win))
                             (not (find-if #'(lambda (a)
                                               (if (and (= (second a) +mission-faction-defender+)
                                                        (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                 t
                                                 nil))
                                           (ref-faction-list win)))
                             (not (find-if #'(lambda (a)
                                               (if (and (= (second a) +mission-faction-attacker+)
                                                        (= (first a) (first (nth (cur-faction win) (cur-faction-list win)))))
                                                 t
                                                 nil))
                                           (ref-faction-list win))))
                        (if (/= (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-present+)
                          (setf (second (nth (cur-faction win) (cur-faction-list win))) +mission-faction-absent+))
                        (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win)))
                        )
                       
                       ;; enter - select
                       ((or (sdl:key= key :sdl-key-return) (sdl:key= key :sdl-key-kp-enter))
                        (if (< (cur-step win) +custom-scenario-win-specific-faction+)
                          (progn
                            (incf (cur-step win))
                            (when (> (cur-step win) +custom-scenario-win-specific-faction+)
                              (setf (cur-step win) +custom-scenario-win-specific-faction+))
                            (setf (menu-items win) (populate-custom-scenario-win-menu win (cur-step win))))
                          (progn
                            (return-from run-window (values (nth (cur-mission win) (mission-list win))
                                                            (nth (cur-layout win) (layout-list win))
                                                            (nth (cur-weather win) (weather-list win))
                                                            (nth (cur-tod win) (tod-list win))
                                                            (nth (cur-specific-faction win) (specific-faction-list win))
                                                            (cur-faction-list win))))))
                       )

                     (cond
                       ((= (cur-step win) +custom-scenario-win-mission+) (progn (setf (cur-mission win) (run-selection-list key mod unicode (cur-mission win)))
                                                                                (setf (cur-mission win) (adjust-selection-list (cur-mission win) (length (mission-list win))))
                                                                                (setf (cur-sel win) (cur-mission win))
                                                                                (readjust-after-mission-change win)))
                       ((= (cur-step win) +custom-scenario-win-layout+) (progn (setf (cur-layout win) (run-selection-list key mod unicode (cur-layout win)))
                                                                               (setf (cur-layout win) (adjust-selection-list (cur-layout win) (length (layout-list win))))
                                                                               (setf (cur-sel win) (cur-layout win))
                                                                               (readjust-after-layout-change win)))
                       ((= (cur-step win) +custom-scenario-win-weather+) (progn (setf (cur-weather win) (run-selection-list key mod unicode (cur-weather win)))
                                                                                (setf (cur-weather win) (adjust-selection-list (cur-weather win) (length (weather-list win))))
                                                                                (setf (cur-sel win) (cur-weather win))))
                       ((= (cur-step win) +custom-scenario-win-time-of-day+) (progn (setf (cur-tod win) (run-selection-list key mod unicode (cur-tod win)))
                                                                                    (setf (cur-tod win) (adjust-selection-list (cur-tod win) (length (tod-list win))))
                                                                                    (setf (cur-sel win) (cur-tod win))))
                       ((= (cur-step win) +custom-scenario-win-factions+) (progn (setf (cur-faction win) (run-selection-list key mod unicode (cur-faction win)))
                                                                                 (setf (cur-faction win) (adjust-selection-list (cur-faction win) (length (cur-faction-list win))))
                                                                                 (setf (cur-sel win) (cur-faction win))
                                                                                 (readjust-after-faction-change win)))
                       ((= (cur-step win) +custom-scenario-win-specific-faction+) (progn (setf (cur-specific-faction win) (run-selection-list key mod unicode (cur-specific-faction win)))
                                                                                         (setf (cur-specific-faction win) (adjust-selection-list (cur-specific-faction win)
                                                                                                                                                          (length (specific-faction-list win))))
                                                                                         (setf (cur-sel win) (cur-specific-faction win)))))
                     
                     (make-output *current-window*))
    (:video-expose-event () (make-output *current-window*))))
