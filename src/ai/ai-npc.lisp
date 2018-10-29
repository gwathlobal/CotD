(in-package :cotd)

(defmethod ai-function ((mob mob))
  ;(declare (optimize (speed 3)))
  ;;(setf *ms-inside-path-start* (get-internal-real-time))

  ;;(format t "~%TIME-ELAPSED AI ~A [~A] BEFORE : ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
  
  (logger (format nil "~%AI-Function Computer ~A [~A] (~A ~A ~A)~%" (name mob) (id mob) (x mob) (y mob) (z mob)))
  
  ;; skip and invoke the master AI
  (when (master-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being possessed by ~A [~A], skipping its turn.~%" (name mob) (id mob) (name (get-mob-by-id (master-mob-id mob))) (master-mob-id mob)))
    (make-act mob +normal-ap+)
    (return-from ai-function nil))

  (when (and (path-dst mob)
             (= (x mob) (first (path-dst mob)))
             (= (y mob) (second (path-dst mob)))
             (= (z mob) (third (path-dst mob))))
            (setf (path-dst mob) nil))
  
  ;; skip turn if being ridden
  (when (mounted-by-mob-id mob)
    (logger (format nil "AI-FUNCTION: ~A [~A] is being ridden by ~A [~A], moving according to the direction.~%" (name mob) (id mob) (name (get-mob-by-id (mounted-by-mob-id mob))) (mounted-by-mob-id mob)))
    (move-mob mob (x-y-into-dir 0 0))
    (return-from ai-function nil)
    )
    
  (update-visible-mobs mob)
  (update-visible-items mob)

  (setf (aref (memory-map mob) (truncate (x mob) 10) (truncate (y mob) 10)) (real-game-time *world*))

  ;; if the mob is blind - move in random direction
  (when (mob-effect-p mob +mob-effect-blind+)
    (logger (format nil "AI-FUNCTION: ~A [~A] is blind, moving in random direction.~%" (name mob) (id mob)))
    (ai-mob-random-dir mob)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob is confused - 33% chance to move in random direction
  (when (and (mob-effect-p mob +mob-effect-confuse+)
             (zerop (random 2)))
    (logger (format nil "AI-FUNCTION: ~A [~A] is confused, moving in random direction.~%" (name mob) (id mob)))
    (ai-mob-random-dir mob)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob is heavily irradiated - (2% * irradiation power) chance to take no action
  (when (and (mob-effect-p mob +mob-effect-irradiated+)
             (< (random 100) (* 2 (param1 (get-effect-by-id (mob-effect-p mob +mob-effect-irradiated+))))))
    (logger (format nil "AI-FUNCTION: ~A [~A] is irradiated, loses turn.~%" (name mob) (id mob)))
    (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                           (format nil "~A is sick. " (capitalize-name (prepend-article +article-the+ (name mob))))
                           :color (if (if-cur-mob-seen-through-shared-vision *player*)
                                    *shared-mind-msg-color*
                                    sdl:*white*))
    (move-mob mob 5)
    (setf (path mob) nil)
    (return-from ai-function nil))

  ;; if the mob possesses smb, there is a chance that the slave will revolt and move randomly
  (let ((rebel-chance-level (cond
                              ((mob-ability-value mob +mob-abil-can-possess+) (mob-ability-value mob +mob-abil-can-possess+))
                              ((mob-ability-p mob +mob-abil-ghost-possess+) (if (and (slave-mob-id mob)
                                                                                     (mob-ability-p (get-mob-by-id (slave-mob-id mob)) +mob-abil-undead+))
                                                                                  0
                                                                                  1))
                              (t 0))
                            ))
    (when (and (slave-mob-id mob)
               (not (zerop rebel-chance-level))
               (zerop (random (* *possessed-revolt-chance* rebel-chance-level))))
      (logger (format nil "AI-FUNCTION: ~A [~A] is revolting against ~A [~A].~%" (name (get-mob-by-id (slave-mob-id mob))) (slave-mob-id mob) (name mob) (id mob)))
      (when (and (check-mob-visible mob :observer *player*)
                 (or (mob-effect-p mob +mob-effect-reveal-true-form+)
                     (get-faction-relation (faction mob) (faction *player*))))
        (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                               (format nil "~A revolts against ~A. " (capitalize-name (prepend-article +article-the+ (name (get-mob-by-id (slave-mob-id mob))))) (prepend-article +article-the+ (name mob)))
                               :color (if (if-cur-mob-seen-through-shared-vision *player*)
                                        *shared-mind-msg-color*
                                        sdl:*white*)))
      (setf (path mob) nil)
      (ai-mob-random-dir mob)
      (return-from ai-function nil)
      )
    )
  
  ;; calculate a list of hostile & allied mobs
  (let ((hostile-mobs nil)
        (allied-mobs nil)
        (nearest-enemy nil)
        (nearest-ally nil))
    
    (loop for mob-id of-type fixnum in (visible-mobs mob)
          for target-mob = (get-mob-by-id mob-id)
          with vis-mob-type = nil
          do
             
             ;; inspect a mob appearance
             (setf vis-mob-type (get-mob-type-by-id (face-mob-type-id target-mob)))
             ;; however is you are of the same faction, you know who is who
             (when (= (faction mob) (faction target-mob))
               (setf vis-mob-type (get-mob-type-by-id (mob-type target-mob))))
             
             (if (or (get-faction-relation (faction mob) (faction vis-mob-type))
                     (and (mounted-by-mob-id target-mob)
                          (get-faction-relation (faction mob) (faction (get-mob-by-id (mounted-by-mob-id target-mob))))))
               (progn
                 (pushnew mob-id allied-mobs)
                 ;; find the nearest allied mob
                 (unless nearest-ally
                   (setf nearest-ally target-mob))
                 (when (< (get-distance (x target-mob) (y target-mob) (x mob) (y mob))
                          (get-distance (x nearest-ally) (y nearest-ally) (x mob) (y mob)))
                   (setf nearest-ally target-mob))
                 )
               (progn
                 (pushnew mob-id hostile-mobs)
                 
                 ;; find the nearest hostile mob
                 (unless nearest-enemy
                   (setf nearest-enemy target-mob))
                 (when (< (get-distance (x target-mob) (y target-mob) (x mob) (y mob))
                          (get-distance (x nearest-enemy) (y nearest-enemy) (x mob) (y mob)))
                   (setf nearest-enemy target-mob))
                 )))

    ;; if the mob is feared, move away from the nearest enemy
    (when (and nearest-enemy (mob-effect-p mob +mob-effect-fear+))
      (logger (format nil "AI-FUNCTION: ~A [~A] is in fear with an enemy ~A [~A] in sight.~%" (name mob) (id mob) (name nearest-enemy) (id nearest-enemy)))
      (ai-mob-flee mob nearest-enemy)      
      (return-from ai-function))

    ;; find and apply the AI package
    (let ((ai-package-array (make-array (list (1+ +ai-priority-always+)) :initial-element ())))

      ;;(format t "~%TIME-ELAPSED AI ~A [~A] before ai package sort: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      
      ;; sort all AI packages according to priorities (and do not include 'never' packages)
      (loop for ai-package-id being the hash-key in (ai-packages mob)
            for ai-package = (get-ai-package-by-id ai-package-id)
            when (/= (priority ai-package) +ai-priority-never+)
              do
                 (setf (aref ai-package-array (priority ai-package)) (pushnew ai-package (aref ai-package-array (priority ai-package)))))

      ;; adding objective packages
      (when (get-objectives-based-on-faction (loyal-faction mob) (mission-scenario (level *world*)))
        (loop for ai-objective-package-id in (get-objectives-based-on-faction (loyal-faction mob) (mission-scenario (level *world*))) do
          (setf (aref ai-package-array (priority (get-ai-package-by-id ai-objective-package-id)))
                (pushnew (get-ai-package-by-id ai-objective-package-id) (aref ai-package-array (priority (get-ai-package-by-id ai-objective-package-id)))))))

      (unless *cotd-release*
        (logger (format nil "AI-FUNCTION: ai-package-array~%"))
        (loop for priority from 0 below (length ai-package-array)
              when (aref ai-package-array priority)
                do
                   (logger (format nil " Priority ~A. ~A.~%" priority (loop for ai-package in (aref ai-package-array priority)
                                                                            collect (format nil "~A " (id ai-package)))))))
      

      ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ai package sort: ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
      
      ;; invoke all 'always' packages if possible
      (loop for ai-package in (aref ai-package-array +ai-priority-always+)
            for ai-check-func of-type function = (on-check-ai ai-package)
            for ai-invoke-func of-type function = (on-invoke-ai ai-package)
            with check-result = nil
            when (and ai-check-func
                      ai-invoke-func
                      (setf check-result (funcall ai-check-func mob nearest-enemy nearest-ally hostile-mobs allied-mobs)))
              do
                 ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ai check func [~A]: ~A~%" (name mob) (id mob) (id ai-package) (- (get-internal-real-time) *time-at-end-of-player-turn*))
                 (funcall ai-invoke-func mob nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                 ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ai invoke func [~A]: ~A~%" (name mob) (id mob) (id ai-package) (- (get-internal-real-time) *time-at-end-of-player-turn*))
            )

      ;; for each priority check try to invoke a random ai-package in this priority
      (loop for priority from 9 downto 1
            for ai-package-list = (aref ai-package-array priority)
            with r of-type fixnum = 0
            when ai-package-list
              do
                 ;; find all applicable AI packages on this priority level
                 (setf ai-package-list (loop for ai-package in ai-package-list
                                             for ai-check-func of-type function = (on-check-ai ai-package)
                                             with check-result = nil
                                             when (and ai-check-func
                                                       (setf check-result (funcall ai-check-func mob nearest-enemy nearest-ally hostile-mobs allied-mobs)))
                                               collect (list ai-package check-result)))
                 ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ai check funcs with priority ~A: ~A~%" (name mob) (id mob) priority (- (get-internal-real-time) *time-at-end-of-player-turn*))

                 (when ai-package-list
                   ;; if there are several of them choose one randomly
                   (setf r (random (length ai-package-list)))
                   (let ((ai-invoke-func (on-invoke-ai (first (nth r ai-package-list))))
                         (check-result (second (nth r ai-package-list))))
                     (declare (type function ai-invoke-func))
                     (funcall ai-invoke-func mob nearest-enemy nearest-ally hostile-mobs allied-mobs check-result)
                     ;;(format t "~%TIME-ELAPSED AI ~A [~A] after ai invoke func [~A]: ~A~%" (name mob) (id mob) (id (first (nth r ai-package-list))) (- (get-internal-real-time) *time-at-end-of-player-turn*))
                     (return-from ai-function))))

      
      )
    
    ;; if there are no hostile mobs move randomly
    ;; pester the AI until it makes some meaningful action
    (ai-mob-random-dir mob))
  ;;(format t "~%TIME-ELAPSED AI ~A [~A] AFTER : ~A~%" (name mob) (id mob) (- (get-internal-real-time) *time-at-end-of-player-turn*))
  )
