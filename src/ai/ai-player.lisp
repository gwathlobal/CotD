(in-package :cotd)

(defmethod ai-function ((player player))
  (logger (format nil "~%AI-FUnction Player~%"))
  ;(logger (format nil "~%TIME-ELAPSED BEFORE: ~A~%" (- (get-internal-real-time) *time-at-end-of-player-turn*)))

  
  (format t "~%TIME-ELAPSED BEFORE: ~A~%" (- (get-internal-real-time) *time-at-end-of-player-turn*))

  ;; this should be done in this order for the lit-unlit tiles to be displayed properly
  ;; because update-visible-area actually sets the glyphs and colors of the player screen
  ;; while update-visible-mobs prepares the lit-unlit status of the tiles
  (update-visible-mobs player)
  (update-visible-area (level *world*) (x player) (y player) (z player))

  (format t "TIME-ELAPSED AFTER: ~A~%" (- (get-internal-real-time) *time-at-end-of-player-turn*))
  
  ;; find the nearest enemy
  (when (mob-ability-p *player* +mob-abil-detect-good+)
    (sense-good))
  (when (mob-ability-p *player* +mob-abil-detect-evil+)
    (sense-evil))

  ;; print out the items on the player's tile
  (loop for item-id in (get-items-* (level *world*) (x *player*) (y *player*) (z *player*))
        for item = (get-item-by-id item-id)
        with n = 0
        do
           (when (zerop n)
             (add-message "You see "))
           (when (not (zerop n))
             (add-message ", "))
           (add-message (format nil "~A" (prepend-article +article-a+ (visible-name item))))
           (incf n)
        finally (when (not (zerop n))
                  (add-message (format nil ".~%"))))
  
  (make-output *current-window*) 

  ;; if player is fearing somebody & there is an enemy nearby
  ;; wait for a meaningful action and move randomly instead
  (when (mob-effect-p *player* +mob-effect-fear+)
    (logger (format nil "AI-FUNCTION: ~A [~A] is under effects of fear.~%" (name player) (id player)))
    (let ((nearest-enemy nil))
      (loop for mob-id of-type fixnum in (visible-mobs *player*)
            for mob = (get-mob-by-id mob-id)
            with vis-mob-type = nil
            do
               ;; inspect a mob appearance
               (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id mob)))
               ;; however is you are of the same faction, you know who is who
               (when (= (faction *player*) (faction mob))
                 (setf vis-mob-type (get-mob-type-by-id (mob-type mob))))
                  
               (when (not (get-faction-relation (faction *player*) (faction vis-mob-type)))
                 ;; find the nearest hostile mob
                 (unless nearest-enemy
                   (setf nearest-enemy mob))
                 (when (< (get-distance (x mob) (y mob) (x *player*) (y *player*))
                          (get-distance (x nearest-enemy) (y nearest-enemy) (x *player*) (y *player*)))
                   (setf nearest-enemy mob))
                 ))
      
      (when nearest-enemy
        (logger (format nil "AI-FUNCTION: ~A [~A] fears ~A [~A].~%" (name player) (id player) (name nearest-enemy) (id nearest-enemy)))
        (setf (can-move-if-possessed player) t)
        (loop while (can-move-if-possessed player) do
          (get-input-player))
        (ai-mob-flee *player* nearest-enemy)
        (return-from ai-function nil))))

  ;; if the player is confused and the RNG is right
  ;; wait for a meaningful action and move randomly instead
  (when (and (mob-effect-p player +mob-effect-confuse+)
             (zerop (random 2)))
    (logger (format nil "AI-FUNCTION: ~A [~A] is under effects of confusion.~%" (name player) (id player)))
    (setf (can-move-if-possessed player) t)
    (loop while (can-move-if-possessed player) do
      (get-input-player))
    (print-visible-message (x player) (y player) (z player) (level *world*) 
                           (format nil "~A is confused. " (capitalize-name (name player))))
    (ai-mob-random-dir *player*)
    (return-from ai-function nil))

  ;; if the player is irradiated and the RNG is right
  ;; wait for a meaningful action and wait a turn instead
  (when (and (mob-effect-p player +mob-effect-irradiated+)
             (< (random 100) (* 2 (param1 (get-effect-by-id (mob-effect-p player +mob-effect-irradiated+))))))
    (logger (format nil "AI-FUNCTION: ~A [~A] is under effects of irradiation.~%" (name player) (id player)))
    (setf (can-move-if-possessed player) t)
    (loop while (can-move-if-possessed player) do
      (get-input-player))
    (print-visible-message (x player) (y player) (z player) (level *world*) 
                           (format nil "~A feels sick. " (capitalize-name (name player))))
    (move-mob player 5)
    (return-from ai-function nil))
  
  ;; if possessed & unable to revolt - wait till the player makes a meaningful action
  ;; then skip and invoke the master AI
  (logger (format nil "AI-FUNCTION: MASTER ID ~A, SLAVE ID ~A~%" (master-mob-id player) (slave-mob-id player)))
  (when (master-mob-id player)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
    
    (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player))) (z player) (z (get-mob-by-id (master-mob-id player))))
    
    (setf (can-move-if-possessed player) t)
    (loop while (can-move-if-possessed player) do
      (get-input-player))

    (let ((rebel-chance-level (cond
                                ((mob-ability-value (get-mob-by-id (master-mob-id player)) +mob-abil-can-possess+) (mob-ability-value (get-mob-by-id (master-mob-id player)) +mob-abil-can-possess+))
                                ((mob-ability-p (get-mob-by-id (master-mob-id player)) +mob-abil-ghost-possess+) 1)
                                (t 0))
                              ))
      (if (and (not (zerop rebel-chance-level))
               (zerop (random (* *possessed-revolt-chance* rebel-chance-level))))
        (progn
          (logger (format nil "AI-FUNCTION: ~A [~A] revolts against ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
          
          (print-visible-message (x player) (y player) (z player) (level *world*) 
                                 (format nil "~A revolts against ~A. " (capitalize-name (name player)) (name (get-mob-by-id (master-mob-id player))) ))
          (ai-mob-random-dir (get-mob-by-id (master-mob-id player)))
          (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player))) (z player) (z (get-mob-by-id (master-mob-id player))))
          (setf (path (get-mob-by-id (master-mob-id player))) nil)
          (return-from ai-function nil)
          )
        (progn
          (logger (format nil "AI-FUNCTION: ~A [~A] was unable to revolt against ~A [~A].~%" (name player) (id player) (name (get-mob-by-id (master-mob-id player))) (master-mob-id player)))
          
          (ai-function (get-mob-by-id (master-mob-id player)))
          
          (when (master-mob-id player)
            (setf (x player) (x (get-mob-by-id (master-mob-id player))) (y player) (y (get-mob-by-id (master-mob-id player))) (z player) (z (get-mob-by-id (master-mob-id player)))))
          
          (make-act player +normal-ap+)
          (return-from ai-function nil)))
      ))
  
  ;; if player possesses somebody & the slave revolts
  ;; wait for a meaningful action and move randomly instead 
  (when (slave-mob-id player)
    (let ((rebel-chance-level (cond
                                ((mob-ability-value player +mob-abil-can-possess+) (mob-ability-value player +mob-abil-can-possess+))
                                ((mob-ability-p player +mob-abil-ghost-possess+) (if (and (slave-mob-id player)
                                                                                          (mob-ability-p (get-mob-by-id (slave-mob-id player)) +mob-abil-undead+))
                                                                                   0
                                                                                   1))
                                (t 0))
                              ))
      (when (and (not (zerop rebel-chance-level))
                 (zerop (random (* *possessed-revolt-chance* rebel-chance-level))))
        (logger (format nil "AI-FUNCTION: ~A [~A] possesses ~A [~A], but the slave revolts.~%" (name player) (id player) (name (get-mob-by-id (slave-mob-id player))) (slave-mob-id player)))
        (setf (can-move-if-possessed player) t)
        (loop while (can-move-if-possessed player) do
          (get-input-player))
        
        (print-visible-message (x player) (y player) (z player) (level *world*) 
                               (format nil "~A revolts against ~A. " (capitalize-name (name (get-mob-by-id (slave-mob-id player)))) (name player)))
        (ai-mob-random-dir player)
        (return-from ai-function nil)
        ))
    )
  
  ;; player is able to move freely
  ;; pester the player until it makes some meaningful action that can trigger the event chain
  (loop until (made-turn player) do
    (setf (can-move-if-possessed player) nil)
    (get-input-player))
  (setf *time-at-end-of-player-turn* (get-internal-real-time)))

