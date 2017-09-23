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

(defun return-scenario-stats ()
  (let ((str (create-string)))
    
    (format str "          Humans: total ~A, killed ~A, left ~A~%" (initial-humans *world*) (- (initial-humans *world*) (total-humans *world*)) (total-humans *world*))
    (format str "          Angels: total ~A, killed ~A, left ~A~%" (initial-angels *world*) (- (initial-angels *world*) (total-angels *world*)) (total-angels *world*))
    (format str "          Demons: total ~A, killed ~A, left ~A~%" (initial-demons *world*) (- (initial-demons *world*) (total-demons *world*)) (total-demons *world*))
    (format str "          Undead: total ~A, killed ~A, left ~A~%" (initial-undead *world*) (- (initial-undead *world*) (total-undead *world*)) (total-undead *world*))
    (format str "~%")
    (format str "     The Butcher: ~A with ~A kills~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-kills))) (calculate-total-kills (find-mob-with-max-kills)))
    (format str " The Hand of God: ~A with ~A blessings~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-blesses))) (stat-blesses (find-mob-with-max-blesses)))
    (format str "    The Summoner: ~A with ~A summons~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-calls))) (stat-calls (find-mob-with-max-calls)))
    (format str "      The Jumper: ~A with ~A summon answers~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-answers))) (stat-answers (find-mob-with-max-answers)))
    (format str "   The Berserker: ~A with ~A friendly kills~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-friendly-kills))) (calculate-total-friendly-kills (find-mob-with-max-friendly-kills)))
    (format str " The Evil Spirit: ~A with ~A possessions~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-possessions))) (stat-possess (find-mob-with-max-possessions)))
    (format str " The Necromancer: ~A with ~A reanimations~%" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-reanimations))) (stat-raised-dead (find-mob-with-max-reanimations)))
    (format str "     The Scrooge: ~A~%" (if (zerop (calculate-total-value (find-mob-with-max-value)))
                                           (format nil "None")
                                           (format nil "~A with ~A$ worth of items" (prepend-article +article-a+ (get-qualified-name (find-mob-with-max-value))) (calculate-total-value (find-mob-with-max-value)))))
        
    str))

(defun dump-character-on-game-over ()
  )
