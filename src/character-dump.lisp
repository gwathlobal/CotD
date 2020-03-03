(in-package :cotd)


(defun find-mob-with-max-kills ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-kills mob) (calculate-total-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-blesses ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-blesses mob) (stat-blesses mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-calls ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-calls mob) (stat-calls mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-answers ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-answers mob) (stat-answers mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-friendly-kills ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-friendly-kills mob) (calculate-total-friendly-kills mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun calculate-total-value (mob)
  (if (and (check-dead mob) (eq mob *player*))
    (stat-gold mob)
    (get-overall-value (inv mob))))

(defun find-mob-with-max-value ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (calculate-total-value mob) (calculate-total-value mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-possessions ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-possess mob) (stat-possess mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun find-mob-with-max-reanimations ()
  (loop for mob across *mobs*
        with mob-found = nil
        finally (return mob-found)
        do
           (if mob-found
             (when (> (stat-raised-dead mob) (stat-raised-dead mob-found))
               (setf mob-found mob))
             (setf mob-found mob))))

(defun return-scenario-stats (&optional (on-screen t))
  (let ((str (create-string)))
    
    (format str "          Humans: total ~A, killed ~A, left ~A~A~%" (initial-humans *world*) (- (initial-humans *world*) (total-humans *world*)) (total-humans *world*) (new-line on-screen))
    (format str "          Angels: total ~A, killed ~A, left ~A~A~%" (initial-angels *world*) (- (initial-angels *world*) (total-angels *world*)) (total-angels *world*) (new-line on-screen))
    (format str "          Demons: total ~A, killed ~A, left ~A~A~%" (initial-demons *world*) (- (initial-demons *world*) (total-demons *world*)) (total-demons *world*) (new-line on-screen))
    (format str "          Undead: total ~A, killed ~A, left ~A~A~%" (initial-undead *world*) (- (initial-undead *world*) (total-undead *world*)) (total-undead *world*) (new-line on-screen))
    (format str "~%")
    (format str "     The Butcher: ~A~A~%" (if (zerop (calculate-total-kills (find-mob-with-max-kills)))
                                             (format nil "-")
                                             (format nil "~A with ~A kills" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-kills))) (calculate-total-kills (find-mob-with-max-kills))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-kills)))
             (not (zerop (calculate-total-kills *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A kills" (prepend-article +article-a+ (get-qualified-name *player*)) (calculate-total-kills *player*))
              (new-line on-screen)))
    
    (format str " The Hand of God: ~A~A~%" (if (zerop (stat-blesses (find-mob-with-max-blesses)))
                                             (format nil "-")
                                             (format nil "~A with ~A blessings" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-blesses))) (stat-blesses (find-mob-with-max-blesses))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-blesses)))
             (not (zerop (stat-blesses *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A blessings" (prepend-article +article-a+ (get-qualified-name *player*)) (stat-blesses *player*))
              (new-line on-screen)))
    
    (format str "    The Summoner: ~A~A~%" (if (zerop (stat-calls (find-mob-with-max-calls)))
                                             (format nil "-")
                                             (format nil "~A with ~A summons" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-calls))) (stat-calls (find-mob-with-max-calls))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-calls)))
             (not (zerop (stat-calls *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A summons" (prepend-article +article-a+ (get-qualified-name *player*)) (stat-calls *player*))
              (new-line on-screen)))
    
    (format str "      The Jumper: ~A~A~%" (if (zerop (stat-answers (find-mob-with-max-answers)))
                                             (format nil "-")
                                             (format nil "~A with ~A summon answers" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-answers))) (stat-answers (find-mob-with-max-answers))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-answers)))
             (not (zerop (stat-answers *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A summons answers" (prepend-article +article-a+ (get-qualified-name *player*)) (stat-answers *player*))
              (new-line on-screen)))
    
    (format str "   The Berserker: ~A~A~%" (if (zerop (calculate-total-friendly-kills (find-mob-with-max-friendly-kills)))
                                             (format nil "-")
                                             (format nil "~A with ~A friendly kills" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-friendly-kills))) (calculate-total-friendly-kills (find-mob-with-max-friendly-kills))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-friendly-kills)))
             (not (zerop (calculate-total-friendly-kills *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A friendly kills" (prepend-article +article-a+ (get-qualified-name *player*)) (calculate-total-friendly-kills *player*))
              (new-line on-screen)))
    
    (format str " The Evil Spirit: ~A~A~%" (if (zerop (stat-possess (find-mob-with-max-possessions)))
                                             (format nil "-")
                                             (format nil "~A with ~A possessions" (prepend-article +article-a+ (if (and (not (eq (find-mob-with-max-possessions) *player*))
                                                                                                                        (mob-ability-p (find-mob-with-max-possessions) +mob-abil-ghost-possess+))
                                                                                                                 (name (get-mob-type-by-id +mob-type-ghost+))
                                                                                                                 (get-qualified-name (find-mob-with-max-possessions))))
                                                     (stat-possess (find-mob-with-max-possessions))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-possessions)))
             (not (zerop (stat-possess *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A possessions" (prepend-article +article-a+ (get-qualified-name *player*))
                                                        (stat-possess *player*))
              (new-line on-screen)))
    
    (format str " The Necromancer: ~A~A~%" (if (zerop (stat-raised-dead (find-mob-with-max-reanimations)))
                                             (format nil "-")
                                             (format nil "~A with ~A reanimations" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-reanimations))) (stat-raised-dead (find-mob-with-max-reanimations))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-reanimations)))
             (not (zerop (stat-raised-dead *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A reanimations" (prepend-article +article-a+ (get-qualified-name *player*)) (stat-raised-dead *player*))
              (new-line on-screen)))
    
    (format str "     The Scrooge: ~A~A~%" (if (zerop (calculate-total-value (find-mob-with-max-value)))
                                             (format nil "-")
                                             (format nil "~A with ~A$ worth of items" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-value))) (calculate-total-value (find-mob-with-max-value))))
            (new-line on-screen))
    (if (and (not (eq *player* (find-mob-with-max-value)))
             (not (zerop (calculate-total-value *player*))))
      (format str "                  vs ~A~A~%" (format nil "~A with ~A$ worth of items" (prepend-article +article-a+ (get-qualified-name *player*)) (calculate-total-value *player*))
              (new-line on-screen)))
        
    str))

(defun dump-character-on-game-over (player-name score game-time layout-str final-str scenario-stats)
  (declare (ignore player-name))
  (multiple-value-bind (second minute hour date month year day daylight-p zone) (get-decoded-time)
    (declare (ignore day daylight-p zone))
    (let* ((file-name (format nil "~A-~A-~4,'0d-~2,'0d-~2,'0d-~2,'0d-~2,'0d-~2,'0d.txt" (get-qualified-name *player*) score year month date hour minute second))
           (dir-path (merge-pathnames "morgue/" *current-dir*)))
      (ensure-directories-exist dir-path)
      (with-open-file (file (merge-pathnames file-name dir-path) :direction :output :if-exists :supersede)
        (format file "~A - ~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~A~%" (get-qualified-name *player*) year month date hour minute second (new-line))
        (format file "~A~%" (new-line))
        (format file "Mission: ~A~A~%" (name (mission (level *world*))) (new-line))
        (format file "Game time: ~D turn~:P~A~%" game-time (new-line))
        (format file "Game score: ~A~A~%" score (new-line))
        (format file "Layout: ~A~A~%" layout-str (new-line))
        (format file "~A~A~%" final-str (new-line))
        (format file "~A~%" (new-line))
        (format file "~A~A~%" scenario-stats (new-line))
        (format file "~A~%" (new-line))
        (let ((x 6)
              (y (+ 40 (* 13 (sdl:get-font-height))))
              (w 800)
              (h (- 520 40 10 (sdl:char-height sdl:*default-font*) (* 14 (sdl:get-font-height)))))
          (sdl:with-rectangle (rect (sdl:rectangle :x x
                                                   :y y
                                                   :w w
                                                   :h h))
            (let ((max-lines (write-text (get-msg-str-list *full-message-box*) rect :count-only t)))
              (when (> (message-list-length) 0)
                (multiple-value-bind (max-lines final-txt) (write-text (get-msg-str-list *full-message-box*) rect :start-line (if (< (truncate h (sdl:char-height sdl:*default-font*)) max-lines)
                                                                                                                                (- max-lines (truncate h (sdl:char-height sdl:*default-font*)))
                                                                                                                                0)
                                                                                                                  :count-only t)
                  (declare (ignore max-lines))
                  (format file "~A~A~%" final-txt (new-line))
                  )))))
        
        
        ))))
