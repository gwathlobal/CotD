(in-package :cotd)

(defclass cell-window (window)
  ((shoot-mode :initform :single :accessor shoot-mode)
   (idle-calcing :initform :done :accessor idle-calcing) ; :done - background pathfinding calculation finished
                                                         ; :in-progress - background pathfinding calculation in progress
                                                         ; :npc-turn - it is not players turn
   (max-glyphs :initform 11 :accessor max-glyphs)
   ))

(defun show-char-effects (mob x y h)
  (loop for effect-id being the hash-value in (effects mob)
        for effect = (get-effect-by-id effect-id)
        with y1 = y    
        do
           (when (and (> (hash-table-count (effects mob)) (truncate h (sdl:get-font-height)))
                      (> (+ y1 (* 2 (sdl:get-font-height))) (+ y h)))
             (sdl:draw-string-solid-* "(...)" x y1 :color sdl:*white*)
             (loop-finish))
           (sdl:draw-string-solid-* (format nil "~A~A" (name effect) (if (eq (cd effect) t)
                                                                       ""
                                                                       (format nil " (~A)" (cd effect))))
                                    x y1 :color (funcall (color-func (get-effect-type-by-id (effect-type effect)))
                                                         effect
                                                         mob))
           
           (incf y1 (sdl:get-font-height))))

(defun show-part-of-level (win win-x win-y x y z)
  (with-slots (max-glyphs) win

    ;; draw a rectangle
    (sdl:with-rectangle (rect (sdl:rectangle :x win-x :y win-y :w (* *glyph-w* (+ 1 max-glyphs)) :h (* *glyph-h* (+ 1 max-glyphs))))
      (sdl:fill-surface sdl:*black* :template rect)
      (sdl:draw-rectangle rect :color sdl:*white*))
    
    ;; draw relative level
    (let ((str (format nil "~@D" (- z (z *player*))))
          (sx (+ 10 win-x))
          (sy (- win-y 5)))
      (sdl:with-rectangle (rect (sdl:rectangle :x sx :y sy :w (* (sdl:char-width sdl:*default-font*) (length str)) :h (sdl:char-height sdl:*default-font*)))
        (sdl:fill-surface sdl:*black* :template rect))
      (sdl:draw-string-solid-* str
                               sx sy :color sdl:*white*))

    ;; draw map
    (update-map-area (+ win-x (truncate *glyph-w* 2)) (+ win-y (truncate *glyph-h* 2)) :rel-x x :rel-y y :rel-z z :max-x-view max-glyphs :max-y-view max-glyphs)
    (highlight-map-tile (+ win-x (truncate *glyph-w* 2) (* *glyph-w* (truncate max-glyphs 2))) (+ win-y (truncate *glyph-h* 2) (* *glyph-h* (truncate max-glyphs 2))))
    
    ))

(defun show-char-properties (x y idle-calcing)
  (let* ((str (create-string))
         (str-lines))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w (- *window-width* x 10) :h (* *glyph-h* *max-y-view*)))
      (sdl:fill-surface sdl:*black* :template a-rect)

      ;; name
      (format str "~A - ~A~%~%" (name *player*) (capitalize-name (name (get-mob-type-by-id (mob-type *player*)))))

      ;; player stats
      (format str "HP: ~A/~A~%"
              (cur-hp *player*) (max-hp *player*))
      (unless (zerop (max-fp *player*))
        (format str "Power: ~A/~A~%" (cur-fp *player*) (max-fp *player*)))
      (when (/= (cur-oxygen *player*) *max-oxygen-level*)
        (format str "Oxygen: ~A/~A~%" (cur-oxygen *player*) *max-oxygen-level*))

      ;; god
      (when (worshiped-god *player*)
        (format str "~A: ~A~%" (name (get-god-by-id (get-worshiped-god-type (worshiped-god *player*)))) (return-piety-str (get-worshiped-god-type (worshiped-god *player*))
                                                                                                                          (get-worshiped-god-piety (worshiped-god *player*)))))

      ;; followers
      (when (or (mob-ability-p *player* +mob-abil-military-follow-me+)
                (mob-ability-p *player* +mob-abil-prayer-bless+))
        (format str "Followers: ~A~%" (count-follower-list *player*)))

      ;; weapon description
      (format str "~%~A~%" (get-weapon-descr-line *player*))
      
      ;; win condition for demonic attack
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-church+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-demonic-attack))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (let ((win-condition (get-win-condition-by-id :win-cond-demonic-attack)))
          (format str "~%Civilians left: ~A~%" (funcall (win-condition/win-func win-condition) *world* win-condition)))
        )

       ;; win condition for demonic raid
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-church+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-demonic-raid))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (let ((win-formula (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-raid))))
          (format str "~%Flesh left: ~A pts~%" (if (> (- win-formula (get-demon-raid-overall-points *world*)) 0)
                                                 (- win-formula (get-demon-raid-overall-points *world*))
                                                 0)))
        )

      ;; win condition for thief
      (when (and (= (mob-type *player*) +mob-type-thief+)
                 (not (mob-ability-p *player* +mob-abil-ghost-possess+)))
        (let ((win-formula (win-condition/win-formula (get-win-condition-by-id :win-cond-thief))))
          (format str "~%Value left: ~A$~%" (if (> (- win-formula (get-overall-value (inv *player*))) 0)
                                          (- win-formula (get-overall-value (inv *player*)))
                                          0))))

      ;; win condition for demonic conquest
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-church+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-demonic-conquest))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (multiple-value-bind (max-sigils max-turns) (values-list (win-condition/win-formula (get-win-condition-by-id :win-cond-demonic-conquest)))
          (format str "~%Demonic sigils: ~A/~A (~A)~%" (length (demonic-sigils (level *world*))) max-sigils
                  (if (>= (length (demonic-sigils (level *world*))) max-sigils)
                    (format nil "~D turn~:P left" (- max-turns (get-demon-conquest-turns-left *world*)))
                    "none"))))

      ;; win condition for celestial purge
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-church+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-celestial-purge))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (format str "~%Demonic sigils left: ~A~%" (length (demonic-sigils (level *world*)))))

      ;; win condition for military conquest
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-military-conquest))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (let ((max-sigils (win-condition/win-formula (get-win-condition-by-id :win-cond-military-conquest))))
          (format str "~%Demonic sigils: ~A/~A~%" (length (demonic-sigils (level *world*))) max-sigils)))
      
      ;; win condition for satanist elimination
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+)
                         (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-church+)
                         (= (loyal-faction *player*) +faction-type-satanists+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-eliminate-satanists))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (format str "~%Satanists left: ~A~%" (nth +faction-type-satanists+ (total-faction-list (level *world*))))
        )
      
      ;; win condition for celestial sabotage
      (when (or (and (or (= (loyal-faction *player*) +faction-type-demons+)
                         (= (loyal-faction *player*) +faction-type-angels+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-celestial-sabotage))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (let ((max-machines (win-condition/win-formula (get-win-condition-by-id :win-cond-celestial-sabotage))))
          (format str "~%Demonic machines: ~A/~A~%" (length (demonic-machines (level *world*))) max-machines)))
     
      ;; win condition for military sabotage
      (when (or (and (or (= (loyal-faction *player*) +faction-type-military+)
                         (= (loyal-faction *player*) +faction-type-angels+))
                     (eq (mission-type-id (mission (level *world*))) :mission-type-military-sabotage))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (format str "~%Raw storages left: ~A~%" (length (bomb-plant-locations (level *world*)))))

      ;; win condition for eater during satanist elimination
      (when (or (and (= (loyal-faction *player*) +faction-type-eater+)
                     (eq (mission-type-id (mission (level *world*))) :mission-type-eliminate-satanists))
                (eq (mission-type-id (mission (level *world*))) :mission-type-test))
        (let* ((win-condition (get-win-condition-by-id :win-cond-eater-cosnume))
               (corpses (funcall (win-condition/win-func win-condition) *world* win-condition)))
          (format str "~%Corpses eaten: ~A/~A~%" (eater-corpses-consumed *player*) corpses)))

      ;; delayed arrival
      (loop with do-once = nil
            for (game-event-id turns-left init-str) in `((,+game-event-delayed-arrival-demons+ ,(- (turns-for-delayed-demons (level *world*)) (player-game-time (level *world*))) "Demons arrive")
                                                         (,+game-event-delayed-arrival-angels+ ,(- (turns-for-delayed-angels (level *world*)) (player-game-time (level *world*))) "Angels arrive")
                                                         (,+game-event-delayed-arrival-military+ ,(- (turns-for-delayed-military (level *world*)) (player-game-time (level *world*))) "Military arrive"))
            when (and (find game-event-id (game-events (level *world*)))
                      (>= turns-left 0))
              do
                 (unless do-once
                   (setf do-once t)
                   (format str "~%"))
                 (format str "~A: ~A~%"
                         init-str
                         (if (zerop turns-left)
                           "now!"
                           (format nil "in ~A turn~:P" turns-left))))
            
      (setf str (format nil "~A~%Humans ~A~%Blessed ~A~%Angels ~A~%Demons ~A~%Undead ~A~%~A~A~A~A~%~%Visibility: ~A~A"
                        str
                        (total-humans (level *world*))
                        (total-blessed (level *world*))
                        (total-angels (level *world*))
                        (total-demons (level *world*))
                        (total-undead (level *world*))
                        (sense-good-evil-str)
                        (if (mimic-id-list *player*)
                          (loop for mimic-id in (mimic-id-list *player*)
                                for mimic = (get-mob-by-id mimic-id)
                                with i = 0
                                with str = (create-string)
                                when (and (not (eq *player* mimic))
                                          (not (is-merged mimic))
                                          (not (check-dead mimic)))
                                do
                                   (when (> i 0)
                                     (format str "~%"))
                                   (format str "~A (HP: ~A, Pwr: ~A~A)" (capitalize-name (name (get-mob-type-by-id (mob-type mimic)))) (cur-hp mimic) (cur-fp mimic)
                                           (if (find (id mimic) (merged-id-list *player*))
                                             ", merged"
                                             ""))
                                   (incf i)
                                finally (return (format nil "~%~A" str)))
                          "")
                        (if (or (mob-ability-p *player* +mob-abil-momentum+)
                                (mob-ability-p *player* +mob-abil-facing+)) (format nil "~%Moving: ~A~A"
                                                                                    (x-y-into-str (momentum-dir *player*))
                                                                                    (if (not (zerop (momentum-spd *player*)))
                                                                                      (format nil " (Spd: ~A)" (momentum-spd *player*))
                                                                                      ""))
                          "")
                        (if (riding-mob-id *player*) (format nil "~%Riding: ~A~%  HP: ~A/~A~A"
                                                             (name (get-mob-by-id (riding-mob-id *player*)))
                                                             (cur-hp (get-mob-by-id (riding-mob-id *player*))) (max-hp (get-mob-by-id (riding-mob-id *player*)))
                                                             (if (or (mob-ability-p (get-mob-by-id (riding-mob-id *player*)) +mob-abil-momentum+)
                                                                     (mob-ability-p (get-mob-by-id (riding-mob-id *player*)) +mob-abil-facing+))
                                                               (format nil "~%  Direction: ~A~A"
                                                                       (x-y-into-str (momentum-dir (get-mob-by-id (riding-mob-id *player*))))
                                                                       (if (not (zerop (momentum-spd (get-mob-by-id (riding-mob-id *player*)))))
                                                                         (format nil " (Spd: ~A)" (momentum-spd (get-mob-by-id (riding-mob-id *player*))))
                                                                         ""))
                                                               "")
                                                             )
                                                             
                          "")
                        (format nil "~A~A" (get-mob-visibility *player*) (if (> (brightness *player*) *mob-visibility-threshold*)
                                                                           " (lit)"
                                                                           ""))
                        (if *cotd-release* "" (format nil " (B: ~A)" (brightness *player*)))
                      ))
      (setf str-lines (write-text  str a-rect :color sdl:*white*)))
    
    (show-char-effects *player* x (+ y (* (sdl:get-font-height) (1+ str-lines))) (- (+ (- *window-height* *msg-box-window-height* 20) (* -3 (sdl:char-height sdl:*default-font*)))
                                                                                    (+ y (* (sdl:get-font-height) (1+ str-lines)))))
    
    (show-time-label idle-calcing x (+ (- *window-height* *msg-box-window-height* 20) (* -3 (sdl:char-height sdl:*default-font*))))
    ))

(defun show-message-box (x y w &optional (h *msg-box-window-height*) (message-box (level/small-message-box (level *world*))))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
    (sdl:fill-surface sdl:*black* :template a-rect))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
    (let ((max-lines (write-colored-text (colored-txt-list (message-box-strings message-box)) a-rect :count-only t)))
      (when (> (message-list-length) 0)
        (write-colored-text (colored-txt-list (message-box-strings message-box)) a-rect :start-line (if (< (truncate h (sdl:char-height sdl:*default-font*)) max-lines)
                                                                                                      (- max-lines (truncate h (sdl:char-height sdl:*default-font*)))
                                                                                                      0))))))

(defun sense-good-evil-str ()
  (let ((str (create-string)) (first t))
    (when (sense-evil-id *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense evil: ~A~%" (general-direction-str (x *player*) (y *player*) (x (get-mob-by-id (sense-evil-id *player*))) (y (get-mob-by-id (sense-evil-id *player*))))))
    (when (sense-good-id *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense good: ~A~%" (general-direction-str (x *player*) (y *player*) (x (get-mob-by-id (sense-good-id *player*))) (y (get-mob-by-id (sense-good-id *player*))))))
    (when (sense-unnatural-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense unnatural: ~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-unnatural-pos *player*)) (second (sense-unnatural-pos *player*)))))
    (when (sense-relic-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense relic: ~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-relic-pos *player*)) (second (sense-relic-pos *player*)))))
    (when (sense-portal-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense portal: ~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-portal-pos *player*)) (second (sense-portal-pos *player*)))))
    (when (sense-sigil-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense sigil: ~A~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-sigil-pos *player*)) (second (sense-sigil-pos *player*)))
              (if (and (mob-ability-p *player* +mob-abil-create-demon-sigil+)
                       (>= (get-distance (x *player*) (y *player*) (first (sense-sigil-pos *player*)) (second (sense-sigil-pos *player*))) *demonic-conquest-win-sigils-dist*))
                " (available)"
                "")))
    (when (sense-machine-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense engine: ~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-machine-pos *player*)) (second (sense-machine-pos *player*)))))
    (when (sense-stockpile-pos *player*)
      (when first (format str "~%") (setf first nil))
      (format str "Sense storage: ~A~%" (general-direction-str (x *player*) (y *player*) (first (sense-stockpile-pos *player*)) (second (sense-stockpile-pos *player*)))))
    str))

(defun general-direction-str (sx sy tx ty)
  (let ((a (round (* (atan (- sy ty) (- sx tx)) (/ 180 pi))))
        (result))
    (cond
      ((and (> a 22.5) (<= a 67.5)) (setf result "NW"))
      ((and (> a 67.5) (<= a 112.5)) (setf result "N"))
      ((and (> a 112.5) (<= a 157.5)) (setf result "NE"))
      ((and (< a -22.5) (>= a -67.5)) (setf result "SW"))
      ((and (< a -67.5) (>= a -112.5)) (setf result "S"))
      ((and (< a -112.5) (>= a -157.5)) (setf result "SE"))
      ((or (> a 157.5) (< a -157.5)) (setf result "E"))
      ((or (> a -22.5) (<= a 22.5)) (setf result "W")))
    result))

(defun draw-visible-mob-func (x y target-mob origin-mob color)
  (let ((vmob target-mob)
        (mob origin-mob))
    (draw-glyph x y (get-current-mob-glyph-idx vmob :x (x vmob) :y (y vmob) :z (z vmob))
                       :front-color (get-current-mob-glyph-color vmob)
                       :back-color (get-current-mob-back-color vmob))
    (sdl:draw-string-solid-* (format nil "~A~A~A~A"
                                     (if (find (id vmob) (proper-visible-mobs mob))
                                       ""
                                       "(M) ")
                                     (capitalize-name (visible-name vmob))
                                     (if (riding-mob-id vmob)
                                       (format nil ", riding ~A" (prepend-article +article-a+ (visible-name (get-mob-by-id (riding-mob-id vmob)))))
                                       "")
                                     (if (/= (- (z vmob) (z mob)) 0)
                                       (format nil " (~@d)" (- (z vmob) (z mob)))
                                       ""))
                             (+ x *glyph-w* 10) y :color color)))

(defun show-visible-mobs (x y w h &key (mob *player*) (visible-mobs (stable-sort (copy-list (visible-mobs mob))
                                                                                 #'(lambda (a b)
                                                                                     (if (< (get-distance-3d (x mob) (y mob) (z mob) (x a) (y a) (z a))
                                                                                            (get-distance-3d (x mob) (y mob) (z mob) (x b) (y b) (z b)))
                                                                                       t
                                                                                       nil))
                                                                                 :key #'get-mob-by-id)))
  (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
    (sdl:fill-surface sdl:*black* :template a-rect))
  
  (loop with y1 = y
        for mob-id in visible-mobs
        for vmob = (get-mob-by-id mob-id)
        do
           (when (and (> (length visible-mobs) (truncate h *glyph-h*))
                      (> (+ y1 (* 1 *glyph-h*)) (+ y h)))
             (sdl:draw-string-solid-* "(...)" x y1 :color sdl:*white*)
             (loop-finish))
           (draw-visible-mob-func x y1 vmob mob sdl:*white*)
           (incf y1 *glyph-h*)))

(defun show-level-weather (x y &key (level (level *world*)))
  
  (sdl:draw-string-solid-* (format nil "Wind: ~A, ~A"
                                   (cond
                                     ((eq (wind-dir level) 1) "SW")
                                     ((eq (wind-dir level) 2) "S")
                                     ((eq (wind-dir level) 3) "SE")
                                     ((eq (wind-dir level) 4) "W")
                                     ((eq (wind-dir level) 6) "E")
                                     ((eq (wind-dir level) 7) "NW")
                                     ((eq (wind-dir level) 8) "N")
                                     ((eq (wind-dir level) 9) "NE")
                                     (t "None"))
                                   (return-weather-type-str (level *world*)))
                           x y :color sdl:*white*))

(defun show-abilities-on-cooldown (x y)
  (loop with str = (create-string)
        with need-comma = nil
        for ability-type-id in (stable-sort (loop for ability-type-id in (get-mob-all-abilities *player*)
                                                  when (not (abil-applic-cd-p ability-type-id *player*))
                                                    collect ability-type-id)
                                            #'(lambda (a b)
                                                (if (> (abil-cur-cd-p *player* a)
                                                       (abil-cur-cd-p *player* b))
                                                  t
                                                  nil)))
        do
           (when (> (+ (* (length str) (sdl:char-width sdl:*default-font*)) (* (+ (length (name (get-ability-type-by-id ability-type-id))) 7) (sdl:char-width sdl:*default-font*)))
                    (+ 20 (* *glyph-w* *max-x-view*)))
             (format str " ...")
             (loop-finish))
           (format str "~A~A [~A]"
                   (if need-comma ", " "")
                   (name (get-ability-type-by-id ability-type-id))
                   (abil-cur-cd-p *player* ability-type-id)
                   )
           (setf need-comma t)
        finally (sdl:draw-string-solid-* str x y :color sdl:*red*))
  )

(defun show-delayed-arrival ()
  (let* ((turns-before-arrival (cond
                                 ((= (loyal-faction *player*) +faction-type-demons+) (turns-for-delayed-demons (level *world*)))
                                 ((= (loyal-faction *player*) +faction-type-angels+) (turns-for-delayed-angels (level *world*)))
                                 ((= (loyal-faction *player*) +faction-type-military+) (turns-for-delayed-military (level *world*)))
                                 (t 220)))
         (str (format nil "Turns before arrival: ~A/~A" (player-game-time (level *world*)) turns-before-arrival))
         (w (* (sdl:char-width sdl:*default-font*) (length str)))
         (h (sdl:char-height sdl:*default-font*))
         (x (+ *start-map-x* (- (truncate (* *max-x-view* *glyph-w*) 2) (truncate w 2))))
         (y (- (truncate (* *max-y-view* *glyph-h*) 2) (truncate h 2))))
    (sdl:with-rectangle (a-rect (sdl:rectangle :x x :y y :w w :h h))
      (sdl:fill-surface sdl:*black* :template a-rect)

      (sdl:draw-string-solid-* str x y :color sdl:*white*))
  ))

(defun update-screen (win)
  
  ;; filling the background with black rectangle
    
  (fill-background-tiles)

  (with-slots (max-glyphs) win
    (update-map-area *start-map-x* 0 :post-func #'(lambda (x y x1 y1)
                                                            (loop for sound in (heard-sounds *player*) 
                                                                  when (and (= (sound-x sound) x)
                                                                            (= (sound-y sound) y)
                                                                            (= (sound-z sound) (z *player*)))
                                                                    do
                                                                       (draw-glyph x1
                                                                                   y1
                                                                                   31
                                                                                   :front-color sdl:*white*
                                                                                   :back-color sdl:*black*))
                                                            ))
    
    (show-abilities-on-cooldown 10 (- *window-height* *msg-box-window-height* 20 (* (sdl:char-height sdl:*default-font*) 2)))
    (show-char-properties (+ *start-map-x* 20 (* *glyph-w* *max-x-view*)) 10 (idle-calcing win))
    (show-message-box 10 (- *window-height* *msg-box-window-height* 20) (- *window-width* 260 10))
    (show-visible-mobs (- *window-width* 260) (- *window-height* *msg-box-window-height* 20) 260 *msg-box-window-height*)
    (show-level-weather (+ *start-map-x* 20 (* *glyph-w* *max-x-view*)) (+ (- *window-height* *msg-box-window-height* 20) (* -2 (sdl:char-height sdl:*default-font*))))

    ;; display up to two parts of the level
    ;; sort the list of visible z levels
    ;; if there is an enemy in range - 
    (loop with result = (remove-duplicates (loop for mob-id in (visible-mobs *player*)
                                                 for mob = (get-mob-by-id mob-id)
                                                 when (and (<= (abs (- (x *player*) (x mob))) 5)
                                                           (<= (abs (- (y *player*) (y mob))) 5)
                                                           (/= (z *player*) (z mob))
                                                           (find (z mob) (visible-z-list *player*)))
                                                   collect (z mob)))
          for off-z from 1 below (array-dimension (terrain (level *world*)) 2) do
            (when (find (- (z *player*) off-z) (visible-z-list *player*))
              (pushnew (- (z *player*) off-z) result))
            (when (find (+ (z *player*) off-z) (visible-z-list *player*))
              (pushnew (+ (z *player*) off-z) result))
          finally (setf (visible-z-list *player*) (reverse result)))
    (loop with accepted-z-levels = ()
          with offset = (truncate max-glyphs 2)
          for z in (visible-z-list *player*) do
            (let ((non-air-found nil))
              (block outer
                (loop for x from (- (x *player*) offset) to (+ (x *player*) offset) do
                  (loop for y from (- (y *player*) offset) to (+ (y *player*) offset) do
                    (when (and (>= x 0) (>= y 0) (< x (array-dimension (terrain (level *world*)) 0)) (< y (array-dimension (terrain (level *world*)) 1))
                               (or (and (not (eq (get-terrain-* (level *world*) x y z) +terrain-border-air+))
                                        (not (eq (get-terrain-* (level *world*) x y z) +terrain-floor-air+)))
                                   (get-mob-* (level *world*) x y z)))
                      (setf non-air-found t)
                      (return-from outer nil))))) 
              (when non-air-found
                (push z accepted-z-levels)))
            (when (>= (length accepted-z-levels) 2)
              (loop-finish))
          finally
             (when accepted-z-levels
               (show-part-of-level win 5 10 (x *player*) (y *player*) (first accepted-z-levels)))
             (when (> (length accepted-z-levels) 1)
               (show-part-of-level win 5 (+ 10 10 (* *glyph-h* (+ 1 max-glyphs))) (x *player*) (y *player*) (second accepted-z-levels))))
    
    
    
  
    (when (player-outside-level *player*)
      (show-delayed-arrival)))
    
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

                        ;(format t "~%")
                        ;(format t "KEY = ~A~%" key)
                        ;(format t "MOD BEFORE NORMALIZE = ~A~%" mod)
                        
                        ;; normalize mod
                        (loop while (>= mod sdl-key-mod-num) do
                          (decf mod sdl-key-mod-num))

                        ;(format t "MOD AFTER NORMALIZE = ~A~%" mod)
                        ;(format t "UNICODE = ~A~%" unicode)
                                                
                        ;;------------------
			;; moving - arrows
			(when (or (sdl:key= key :sdl-key-pageup) (sdl:key= key :sdl-key-kp9))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 9)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-kp8))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 8)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-home) (sdl:key= key :sdl-key-kp7))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 7)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-kp6))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 6)
                                )))
                          )
                        (when (or (sdl:key= key :sdl-key-kp5)
                                  (and (sdl:key= key :sdl-key-period)
                                       (= mod 0)))
                          (clear-message-list (level/small-message-box (level *world*)))
                          (if (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (move-mob *player* 5)
                            )
                          )
			(when (or (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-kp4))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 4)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-pagedown) (sdl:key= key :sdl-key-kp3))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 3)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-kp2))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 2)
                                )))
                          )
			(when (or (sdl:key= key :sdl-key-end) (sdl:key= key :sdl-key-kp1))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 1)
                                )))
                          )
                        ;;------------------
			;; move down - Shift + . (i.e., >)
                        (when (and (or (and (sdl:key= key :sdl-key-period) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                       (eq unicode +cotd-unicode-greater-than-sign+))
                                   (> (z *player*) 0)
                                   (not (get-terrain-type-trait (get-terrain-* (level *world*) (x *player*) (y *player*) (z *player*)) +terrain-trait-blocks-move-floor+))
                                   (not (get-terrain-type-trait (get-terrain-* (level *world*) (x *player*) (y *player*) (1- (z *player*))) +terrain-trait-blocks-move+))
                                   (or (mob-effect-p *player* +mob-effect-climbing-mode+)
                                       (get-terrain-type-trait (get-terrain-* (level *world*) (x *player*) (y *player*) (z *player*)) +terrain-trait-water+)
                                       (mob-effect-p *player* +mob-effect-flying+)
                                       (mob-ability-p *player* +mob-abil-flying+))
                                   )
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 5 :dir-z -1)
                                )))
                          )
                        ;;------------------
			;; move up - Shift + , (i.e., <)
                        (when (and (or (and (sdl:key= key :sdl-key-comma) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                       (eq unicode +cotd-unicode-less-than-sign+))
                                   (or (and (mob-effect-p *player* +mob-effect-climbing-mode+)
                                            (funcall #'(lambda ()
                                                         (let ((result nil))
                                                           (check-surroundings (x *player*) (y *player*) nil
                                                                               #'(lambda (dx dy)
                                                                                   (when (and (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (z *player*)) +terrain-trait-blocks-move+)
                                                                                              (not (get-terrain-type-trait (get-terrain-* (level *world*) dx dy (z *player*)) +terrain-trait-not-climable+)))
                                                                                     (setf result t))))
                                                           result))))
                                       (and (get-terrain-type-trait (get-terrain-* (level *world*) (x *player*) (y *player*) (1+ (z *player*))) +terrain-trait-water+)
                                            (get-terrain-type-trait (get-terrain-* (level *world*) (x *player*) (y *player*) (z *player*)) +terrain-trait-water+))
                                       (mob-effect-p *player* +mob-effect-flying+)
                                       (mob-ability-p *player* +mob-abil-flying+))
                                   (not (mob-effect-p *player* +mob-effect-gravity-pull+))
                                   (< (z *player*) (1- (array-dimension (terrain (level *world*)) 2))))
                          (if (mob-ability-p *player* +mob-abil-immobile+)
                            (add-message (format nil "You are immobile and can not move.~%"))
                            (progn
                              (clear-message-list (level/small-message-box (level *world*)))
                              (if (can-move-if-possessed *player*)
                                (setf (can-move-if-possessed *player*) nil)
                                (move-mob *player* 5 :dir-z 1)
                                )))
                          )
			;;------------------
			;; character mode - Shift + 2
			(when (or (and (sdl:key= key :sdl-key-2) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                  (eq unicode +cotd-unicode-at-sign+))
			  (setf *current-window* (make-instance 'character-window :return-to *current-window*)))
                        ;;------------------
			;; help screen - ?
			(when (or (sdl:key= key :sdl-key-question)
                                  (eq unicode +cotd-unicode-question-mark+)
                                  (and (sdl:key= key :sdl-key-slash) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))
                                  (and (sdl:key= key :sdl-key-7) (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0)))
			  (setf *current-window* (make-instance 'help-window :return-to *current-window*)))
                        ;;------------------
			;; select item to use - u
                        (when (or (and (sdl:key= key :sdl-key-u))
                                  (eq unicode +cotd-unicode-latin-u-small+))
                          (when (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (go exit-loop))
                          
                          (let ((item-name-list nil)
                                (item-descr-list nil)
                                (item-prompt-list nil)
                                (item-color-list nil)
                                (mob-items nil))

                            ;; filter item list to leave only usable ones
                            (setf mob-items (loop for item-id in (inv *player*)
                                                  for item = (get-item-by-id item-id)
                                                  when (and (on-check-applic item)
                                                            (on-use item)
                                                            (funcall (on-check-applic item) *player* item))
                                                    collect item))
                            
                            (if mob-items
                              (progn
                                ;; populate item name list 
                                (setf item-name-list
                                      (loop for item in mob-items
                                            collect (capitalize-name (prepend-article +article-a+ (visible-name item)))))

                                ;; populate item descripiton list
                                (setf item-descr-list
                                      (loop for item in mob-items
                                            collect (descr item)))

                                ;; populate item color list
                                (setf item-color-list
                                      (loop for item in mob-items
                                            collect sdl:*white*))

                                ;; populate item prompt list
                                (setf item-prompt-list
                                      (loop for item in mob-items
                                            collect #'(lambda (cur-sel)
                                                        (declare (ignore cur-sel))
                                                        "[Enter] Use  [Escape] Cancel")))
                                
                                ;; display the window with the list
                                (setf *current-window* (make-instance 'select-obj-window 
                                                                      :return-to *current-window*
                                                                      :w (- *window-width* 300)
                                                                      :header-line "Choose item:"
                                                                      :color-list item-color-list
                                                                      :select-color-func #'(lambda (cur-sel)
                                                                                             (declare (ignore cur-sel))
                                                                                             sdl:*yellow*)
                                                                      :enter-func #'(lambda (cur-sel)
                                                                                      (let ((item (get-inv-item-by-pos (inv *player*) cur-sel)))
                                                                                        (window-use-item item win)))
                                                                      :line-list item-name-list
                                                                      :descr-list item-descr-list
                                                                      :prompt-list item-prompt-list)))
                              (progn
                                ;; no items - display a message
                                (add-message (format nil "You have no items to use.~%"))
                                ))
			    ))
                        ;;------------------
			;; select abilities - a
                        (when (or (and (sdl:key= key :sdl-key-a))
                                  (eq unicode +cotd-unicode-latin-a-small+))
                          (when (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (go exit-loop))
                          
                          (let ((abil-name-list nil)
                                (abil-descr-list nil)
                                (abil-prompt-list nil)
                                (abil-color-list nil)
                                (mob-abilities nil))

                            ;; filter ability list to leave only non passive and applicable
                            (setf mob-abilities (loop for ability-type-id in (get-mob-all-abilities *player*)
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

                                ;; populate the ability description list
                                (setf abil-descr-list
                                      (loop
                                        for ability-type-id in mob-abilities
                                        collect (cond
                                                  ((not (abil-applic-cost-p ability-type-id *player*)) (format nil "Cost: ~A pwr. Insufficient power!" (cost (get-ability-type-by-id ability-type-id))))
                                                  ((not (abil-applic-cd-p ability-type-id *player*)) (format nil "CD: ~A turn~:P. On cooldown!" (abil-cur-cd-p *player* ability-type-id)))
                                                  (t (format nil "~A~ATime: ~A turn~:P."
                                                          (if (zerop (cost (get-ability-type-by-id ability-type-id)))
                                                            ""
                                                            (format nil "Cost: ~A pwr. " (cost (get-ability-type-by-id ability-type-id))))
                                                          (if (abil-applic-cd-p ability-type-id *player*)
                                                            ""
                                                            (format nil "CD: ~A turn~:P. " (abil-cur-cd-p *player* ability-type-id)))
                                                          (/ (spd (get-ability-type-by-id ability-type-id)) +normal-ap+))))))

                                ;; populate the ability description list
                                (setf abil-color-list
                                      (loop
                                        for ability-type-id in mob-abilities
                                        collect (if (or (not (abil-applic-cost-p ability-type-id *player*))
                                                        (not (abil-applic-cd-p ability-type-id *player*)))
                                                  sdl:*red*
                                                  sdl:*white*)
                                                ))

                                ;; populate the ability prompt list
                                (setf abil-prompt-list
                                      (loop
                                        for ability-type-id in mob-abilities
                                        collect #'(lambda (cur-sel)
                                                    (if (can-invoke-ability *player* *player* (nth cur-sel mob-abilities))
                                                      "[Enter] Invoke  [Escape] Cancel"
                                                      "[Escape] Cancel"))))
                                
                                ;; display the window with the list
                                (setf *current-window* (make-instance 'select-obj-window 
                                                                      :return-to *current-window*
                                                                      :header-line "Choose ability:"
                                                                      :descr-list abil-descr-list
                                                                      :color-list abil-color-list
                                                                      :select-color-func #'(lambda (n)
                                                                                             (if (or (not (abil-applic-cost-p (nth n mob-abilities) *player*))
                                                                                                     (not (abil-applic-cd-p (nth n mob-abilities) *player*)))
                                                                                               (sdl:color :r 255 :g 69 :b 0)
                                                                                               sdl:*yellow*))
                                                                      :enter-func #'(lambda (cur-sel)
                                                                                      (when (can-invoke-ability *player* *player* (nth cur-sel mob-abilities))
                                                                                        (cond
                                                                                          ((map-select-func (get-ability-type-by-id (nth cur-sel mob-abilities)))
                                                                                           (progn
                                                                                             (setf *current-window* (make-instance 'map-select-window 
                                                                                                                                   :return-to *current-window*
                                                                                                                                   :start-map-select (abil-start-map-select-func-p (nth cur-sel mob-abilities))
                                                                                                                                   :cmd-str (list "[Enter] Invoke  "
                                                                                                                                                  "")
                                                                                                                                   :exec-func #'(lambda ()
                                                                                                                                                  (if (funcall (map-select-func (get-ability-type-by-id (nth cur-sel mob-abilities)))
                                                                                                                                                               (nth cur-sel mob-abilities))
                                                                                                                                                    (progn
                                                                                                                                                      (setf *current-window* win)
                                                                                                                                                      (make-output *current-window*)
                                                                                                                                                      t)
                                                                                                                                                    (progn
                                                                                                                                                     nil)))
                                                                                                                                   ))
                                                                                             (make-output *current-window*)))
                                                                                          ((obj-select-func (get-ability-type-by-id (nth cur-sel mob-abilities)))
                                                                                           (progn
                                                                                             (funcall (obj-select-func (get-ability-type-by-id (nth cur-sel mob-abilities)))
                                                                                                      (nth cur-sel mob-abilities))
                                                                                             (setf *current-window* win)
                                                                                             (make-output *current-window*)))
                                                                                          (t
                                                                                           (progn
                                                                                             (clear-message-list (level/small-message-box (level *world*)))
                                                                                             (mob-invoke-ability *player* *player* (nth cur-sel mob-abilities))
                                                                                             (setf *current-window* win)
                                                                                             (set-idle-calcing win))))
                                                                                        
                                                                                        )
                                                                                      )
                                                                      :line-list abil-name-list
                                                                      :prompt-list abil-prompt-list)))
                              (progn
                                ;; no abilites - display a message
                                (add-message (format nil "You have no abilities to invoke.~%"))
                                ))
			    ))
			;;------------------
			;; look mode - l
			(when (or (and (sdl:key= key :sdl-key-l) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-l-small+))
			  (setf *current-window* (make-instance 'map-select-window 
								:return-to *current-window*
								:cmd-str (list "[<] Look up  [>] Look down  "
                                                                               "")
								:exec-func #'(lambda ()
									       nil)))
			  (make-output *current-window*))
                        ;;------------------
			;; shoot mode - f
			(when (or (and (sdl:key= key :sdl-key-f) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-f-small+))

                          (when (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (go exit-loop))
                          
                          (if (is-weapon-ranged *player*)
                            (progn
                              (if (mob-can-shoot *player*)
                                (progn
                                  (setf *current-window* (make-instance 'map-select-window 
                                                                        :return-to *current-window*
                                                                        :cmd-str (list "[Enter] Fire  [<] Look up  [>] Look down  "
                                                                                       "")
                                                                        :start-map-select #'player-start-map-select-nearest-hostile
                                                                        :check-lof t
                                                                        :exec-func #'(lambda ()
                                                                                       (if (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                                                         (progn
                                                                                           (clear-message-list (level/small-message-box (level *world*)))
                                                                                           (mob-shoot-target *player* (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                                           (setf (view-x *player*) (x *player*) (view-y *player*) (y *player*))
                                                                                           (setf *current-window* (return-to *current-window*))
                                                                                           t)
                                                                                         (progn
                                                                                           nil))
                                                                                       )))
                                  (make-output *current-window*))
                                (progn
                                  (add-message (format nil "Can't switch into firing mode: need to reload.~%")))))
                            (progn
                              (add-message (format nil "Can't switch into firing mode: no ranged weapons.~%")))))
                        ;;------------------
			;; reload - r
			(when (or (and (sdl:key= key :sdl-key-r) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-r-small+))
                          (clear-message-list (level/small-message-box (level *world*)))
                          (when (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (go exit-loop))
                          
                          (if (is-weapon-ranged *player*)
                            (progn
                              (if (< (get-ranged-weapon-charges *player*) (get-ranged-weapon-max-charges *player*))
                                (progn
                                  (mob-reload-ranged-weapon *player*))
                                (progn
                                  (add-message (format nil "Can't reload: magazine already full.~%")))))
                            (progn
                              (add-message (format nil "Can't reload: this is not a ranged weapon.~%")))))
                        ;;------------------
			;; view inventory - i
                        (when (or (and (sdl:key= key :sdl-key-i) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-i-small+))
                          (setf *current-window* (make-instance 'inventory-window :return-to *current-window*)))
                        ;;------------------
			;; pick item - p, g or ,
			(when (or (and (sdl:key= key :sdl-key-p) (= mod 0))
                                  (and (sdl:key= key :sdl-key-g) (= mod 0))
                                  (and (sdl:key= key :sdl-key-comma) (= mod 0)))

                          (when (can-move-if-possessed *player*)
                            (setf (can-move-if-possessed *player*) nil)
                            (go exit-loop))
                          
			  ;; count the number of items and containers at the grid-cell
			  (let ((item-line-list nil)
                                (item-prompt-list)
				(item-list (get-items-* (level *world*) (x *player*) (y *player*) (z *player*))))
			    ;; 
                            (setf item-line-list (loop for item-id in item-list
                                                  for item = (get-item-by-id item-id)
                                                       collect (format nil "~A"
                                                                       (capitalize-name (prepend-article +article-a+ (visible-name item)))
                                                                       )))
                            ;; populate the ability prompt list
                            (setf item-prompt-list (loop for item-id in item-list
                                                         collect #'(lambda (cur-sel)
                                                                     (declare (ignore cur-sel))
                                                                     "[Enter] Pick up  [Escape] Cancel")))

                            ;; a single item - just pick it up
			    (when (= (length item-list) 1)
			      (log:info (format nil "PLAYER-ITEM-PICK: On item on the tile, pick it right away~%"))
                              (clear-message-list (level/small-message-box (level *world*)))
			      (mob-pick-item *player* (get-inv-item-by-pos item-list 0)))
			    ;; a several items - show selection window
			    (when (> (length item-list) 1)
			      (setf *current-window* (make-instance 'select-obj-window 
								    :return-to *current-window* 
								    :header-line "Choose an item to pick up:"
								    :enter-func #'(lambda (cur-sel)
                                                                                    (clear-message-list (level/small-message-box (level *world*)))
										    (mob-pick-item *player* (get-inv-item-by-pos item-list cur-sel))
										    (setf *current-window* win)
                                                                                    (set-idle-calcing win)
                                                                                    ;(show-time-label (idle-calcing win) (+ 20 (* *glyph-w* *max-x-view*)) (+ 10 237) t)
                                                                                    )
								    :line-list item-line-list
								    :prompt-list item-prompt-list)))
			    ))
                        ;;------------------
			;; view messages - m
                        (when (or (and (sdl:key= key :sdl-key-m) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-m-small+))
			  (setf *current-window* (make-instance 'message-window 
								:return-to *current-window*
                                                                :message-box (level/full-message-box (level *world*))
                                                                :header-str "MESSAGES"))
                          (make-output *current-window*))
                        ;;------------------
			;; view journal - j
                        (when (or (and (sdl:key= key :sdl-key-j) (= mod 0))
                                  (eq unicode +cotd-unicode-latin-j-small+))
			  (setf *current-window* (make-instance 'journal-window 
								:return-to *current-window*))
                          (make-output *current-window*))
                        ;;------------------
			;; scenario main menu - Esc
                        (when (sdl:key= key :sdl-key-escape)
                          (show-escape-menu)
                          )
			
			(set-idle-calcing win)

                        
			(make-output *current-window*)
			(go exit-loop)
                        )
       (:idle () (update-swank)
              
                 (set-idle-calcing win)

                 
                 (show-time-label (idle-calcing win) (+ *start-map-x* 20 (* *glyph-w* *max-x-view*)) (+ (- *window-height* *msg-box-window-height* 20) (* -3 (sdl:char-height sdl:*default-font*))) t)
              )
              
       (:video-expose-event () (make-output *current-window*)))
    exit-loop)
  nil)

(defun show-time-label (idle-calcing x y &optional (update nil))
  (sdl:draw-string-solid-* (format nil "~A [T: ~A]"  (show-date-time-short (world-game-time *world*)) (player-game-time (level *world*)))
                           x y :color (cond ((eql idle-calcing :done) sdl:*white*)
                                            ((eql idle-calcing :in-progress) sdl:*yellow*)
                                            ((eql idle-calcing :npc-turn) sdl:*red*)))
  (when update
    (sdl:update-display)))

(defun set-idle-calcing (win)
  (if (made-turn *player*)
    (setf (idle-calcing win) :npc-turn)
    (setf (idle-calcing win) :done)))


