(in-package :cotd)

(defun scenario-delayed-faction-setup-demonic-attack (faction-list game-event-list)

  ;; add delayed military
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-attack-delayed-arrival-military+ game-event-list))

  ;; add delayed angels
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-attack-delayed-arrival-angels+ game-event-list))
  
  game-event-list)

(defun scenario-delayed-faction-setup-demonic-raid (faction-list game-event-list)

  ;; add delayed military
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-military+ game-event-list))

  ;; add delayed angels
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-angels+ game-event-list))
  
  game-event-list)

(defun scenario-delayed-faction-setup-demonic-steal (faction-list game-event-list)

  ;; add delayed military
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-military+ game-event-list))

  ;; add delayed angels
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-angels+ game-event-list))
  
  game-event-list)

(defun scenario-delayed-faction-setup-demonic-conquest (faction-list game-event-list)

  ;; add delayed military
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-military+ game-event-list))

  ;; add delayed angels
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-demon-raid-delayed-arrival-angels+ game-event-list))
  
  game-event-list)

(defun scenario-present-faction-setup-demonic-attack (specific-faction-type faction-list mob-func-list)
  (push #'adjust-mobs-after-creation mob-func-list)
  (push #'replace-gold-features-with-items mob-func-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; populate the world with demonic runes
            (place-demonic-runes world))
        mob-func-list)

  ;; remove the land arrival feature and add delayed arrival points to level
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-delayed-arrival-point+)
                            
                    do
                       (when (not (get-terrain-type-trait (get-terrain-* (level world) (x lvl-feature) (y lvl-feature) (z lvl-feature)) +terrain-trait-blocks-move+))
                         (push (list (x lvl-feature) (y lvl-feature) (z lvl-feature)) (delayed-arrival-points (level world))))
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; remove the starting features
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
                    do
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for mob-id in (mob-id-list (level world))
                  for horse = (get-mob-by-id mob-id)
                  for rider = (if (mounted-by-mob-id horse)
                                (get-mob-by-id (mounted-by-mob-id horse))
                                nil)
                  when rider
                    do
                       (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
            ;; remove the glitch from (0, 0, 0)
            (setf (aref (mobs (level world)) 0 0 0) nil)
            )
        mob-func-list)
  
  ;; populate the world with 1 ghost
  (when (and (/= specific-faction-type +specific-faction-type-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-ghost+ 1))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with 1 eater of the dead
  (when (and (/= specific-faction-type +specific-faction-type-eater+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-eater-of-the-dead+ 1))
                                        #'find-unoccupied-place-water))
          mob-func-list))
  
  ;; populate the world with 1 thief
  (when (and (/= specific-faction-type +specific-faction-type-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-thief+ 1))
                                        #'find-unoccupied-place-on-top))
          mob-func-list))

  ;; populate the world with the 3 groups of military, where each group has 1 chaplain, 2 sargeants and 3 soldiers
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
              
              (loop repeat 3
                    do
                       (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                         ;; place the chaplains at the army post if the military is defending
                         (if (find-if #'(lambda (a)
                                          (if (and (= (first a) +faction-type-military+)
                                                   (= (second a) +mission-faction-defender+))
                                            t
                                            nil))
                                      faction-list)
                           (progn
                             (loop for feature-id in (feature-id-list (level world))
                                   for lvl-feature = (get-feature-by-id feature-id)
                                   when (= (feature-type lvl-feature) +feature-start-military-point+)
                                     do
                                        (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                                        (add-mob-to-level-list (level world) chaplain)
                                        (remove-feature-from-level-list (level world) lvl-feature)
                                        (remove-feature-from-world lvl-feature)
                                        (loop-finish))
                             )
                           (find-unoccupied-place-outside world chaplain))
                         (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                               (cons +mob-type-scout+ 1)
                                                               (cons +mob-type-soldier+ 3)
                                                               (cons +mob-type-gunner+ 1))
                                                   #'(lambda (world mob)
                                                       (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
              )
          mob-func-list))

  ;; add an additional group of military if there is no player chaplain
  (when (and (/= specific-faction-type +specific-faction-type-military-chaplain+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-military+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                ;; place the chaplains at the army post if the military is defending
                (if (find-if #'(lambda (a)
                                 (if (and (= (first a) +faction-type-military+)
                                          (= (second a) +mission-faction-defender+))
                                   t
                                   nil))
                             faction-list)
                  (progn
                    (loop for feature-id in (feature-id-list (level world))
                          for lvl-feature = (get-feature-by-id feature-id)
                          when (= (feature-type lvl-feature) +feature-start-military-point+)
                            do
                               (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                               (add-mob-to-level-list (level world) chaplain)
                               (remove-feature-from-level-list (level world) lvl-feature)
                               (remove-feature-from-world lvl-feature)
                               (loop-finish))
                    )
                  (find-unoccupied-place-outside world chaplain))
                (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                      (cons +mob-type-scout+ 1)
                                                      (cons +mob-type-soldier+ 3)
                                                      (cons +mob-type-gunner+ 1))
                                          #'(lambda (world mob)
                                              (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
          mob-func-list))
  
  ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
            
              (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                    (cons +mob-type-wisp+ (truncate (total-humans world) 15)))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                        #'find-unoccupied-place-inside))
          mob-func-list))

  ;; populate the world with the number of angels = humans / 11
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-angel+ (- (truncate (total-humans world) 11) 1)))
                                        #'find-unoccupied-place-outside)
              )
          mob-func-list))
  
  ;; populate the world with trinity mimics
  (when (and (/= specific-faction-type +specific-faction-type-angel-trinity+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-angels+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              ;; set up trinity mimics
              (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+))
                    (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+))
                    (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+)))
                
                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                
                (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)))
          mob-func-list))

  ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
  ;; make some of them shadow demons if there is dark in the city
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              (multiple-value-bind (year month day hour min sec) (get-current-date-time (player-game-time world))
                (declare (ignore year month day min sec))
                (populate-world-with-mobs world (if (and (>= hour 7) (< hour 19))
                                                  (list (cons +mob-type-archdemon+ 1)
                                                        (cons +mob-type-demon+ 15)
                                                        (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                  (list (if (zerop (random 2)) (cons +mob-type-archdemon+ 1) (cons +mob-type-shadow-devil+ 1))
                                                        (cons +mob-type-demon+ 7)
                                                        (cons +mob-type-shadow-demon+ 8)
                                                        (cons +mob-type-imp+ (- (truncate (total-humans world) 8) 16))
                                                        (cons +mob-type-shadow-imp+ (- (truncate (total-humans world) 8) 16))))
                                          #'find-unoccupied-place-inside)))
          mob-func-list))

  ;; populate world with malseraph puppets
  (when (and (or (/= specific-faction-type +specific-faction-type-demon-malseraph+))
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-demons+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (populate-world-with-mobs world (list (cons +mob-type-malseraph-puppet+ 1))
                                      #'find-unoccupied-place-inside))
        mob-func-list))
  
  (push #'create-mobs-from-template mob-func-list)
  mob-func-list)

(defun scenario-present-faction-setup-demonic-raid (specific-faction-type faction-list mob-func-list)
  (push #'adjust-mobs-after-creation mob-func-list)
  (push #'replace-gold-features-with-items mob-func-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; populate the world with demonic runes
            (place-demonic-runes world))
        mob-func-list)

  ;; remove the land arrival feature and add delayed arrival points to level
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-delayed-arrival-point+)
                            
                    do
                       (when (not (get-terrain-type-trait (get-terrain-* (level world) (x lvl-feature) (y lvl-feature) (z lvl-feature)) +terrain-trait-blocks-move+))
                         (push (list (x lvl-feature) (y lvl-feature) (z lvl-feature)) (delayed-arrival-points (level world))))
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; remove the starting features
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
                    do
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for mob-id in (mob-id-list (level world))
                  for horse = (get-mob-by-id mob-id)
                  for rider = (if (mounted-by-mob-id horse)
                                (get-mob-by-id (mounted-by-mob-id horse))
                                nil)
                  when rider
                    do
                       (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
            ;; remove the glitch from (0, 0, 0)
            (setf (aref (mobs (level world)) 0 0 0) nil)
            )
        mob-func-list)
  
  ;; populate the world with 1 ghost
  (when (and (/= specific-faction-type +specific-faction-type-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-ghost+ 1))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with 1 eater of the dead
  (when (and (/= specific-faction-type +specific-faction-type-eater+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-eater-of-the-dead+ 1))
                                        #'find-unoccupied-place-water))
          mob-func-list))
  
  ;; populate the world with 1 thief
  (when (and (/= specific-faction-type +specific-faction-type-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-thief+ 1))
                                        #'find-unoccupied-place-on-top))
          mob-func-list))

  ;; populate the world with the 3 groups of military, where each group has 1 chaplain, 2 sargeants and 3 soldiers
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
              
              (loop repeat 3
                    do
                       (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                         ;; place the chaplains at the army post if the military is defending
                         (if (find-if #'(lambda (a)
                                          (if (and (= (first a) +faction-type-military+)
                                                   (= (second a) +mission-faction-defender+))
                                            t
                                            nil))
                                      faction-list)
                           (progn
                             (loop for feature-id in (feature-id-list (level world))
                                   for lvl-feature = (get-feature-by-id feature-id)
                                   when (= (feature-type lvl-feature) +feature-start-military-point+)
                                     do
                                        (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                                        (add-mob-to-level-list (level world) chaplain)
                                        (remove-feature-from-level-list (level world) lvl-feature)
                                        (remove-feature-from-world lvl-feature)
                                        (loop-finish))
                             )
                           (find-unoccupied-place-outside world chaplain))
                         (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                               (cons +mob-type-scout+ 1)
                                                               (cons +mob-type-soldier+ 3)
                                                               (cons +mob-type-gunner+ 1))
                                                   #'(lambda (world mob)
                                                       (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
              )
          mob-func-list))

  ;; add an additional group of military if there is no player chaplain
  (when (and (/= specific-faction-type +specific-faction-type-military-chaplain+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-military+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                ;; place the chaplains at the army post if the military is defending
                (if (find-if #'(lambda (a)
                                 (if (and (= (first a) +faction-type-military+)
                                          (= (second a) +mission-faction-defender+))
                                   t
                                   nil))
                             faction-list)
                  (progn
                    (loop for feature-id in (feature-id-list (level world))
                          for lvl-feature = (get-feature-by-id feature-id)
                          when (= (feature-type lvl-feature) +feature-start-military-point+)
                            do
                               (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                               (add-mob-to-level-list (level world) chaplain)
                               (remove-feature-from-level-list (level world) lvl-feature)
                               (remove-feature-from-world lvl-feature)
                               (loop-finish))
                    )
                  (find-unoccupied-place-outside world chaplain))
                (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                      (cons +mob-type-scout+ 1)
                                                      (cons +mob-type-soldier+ 3)
                                                      (cons +mob-type-gunner+ 1))
                                          #'(lambda (world mob)
                                              (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
          mob-func-list))
  
  ;; no outsider beasts 
  
  ;; populate the world with the number of angels = humans / 11
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-angel+ (if (> (+ (total-angels world) (truncate (total-humans world) 11)) *min-angels-number*)
                                                                             (- (truncate (total-humans world) 11) 1)
                                                                             (- *min-angels-number* (total-angels world)))))
                                        #'find-unoccupied-place-outside)
              )
          mob-func-list))
  
  ;; populate the world with trinity mimics
  (when (and (/= specific-faction-type +specific-faction-type-angel-trinity+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-angels+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              ;; set up trinity mimics
              (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+))
                    (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+))
                    (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+)))
                
                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                
                (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)))
          mob-func-list))

  ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
  ;; make some of them shadow demons if there is dark in the city
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              (multiple-value-bind (year month day hour min sec) (get-current-date-time (player-game-time world))
                (declare (ignore year month day min sec))
                (populate-world-with-mobs world (if (and (>= hour 7) (< hour 19))
                                                  (list (cons +mob-type-archdemon+ 1)
                                                        (cons +mob-type-demon+ 15)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- 46 16)
                                                                               (- (truncate (total-humans world) 4) 16))))
                                                  (list (if (zerop (random 2)) (cons +mob-type-archdemon+ 1) (cons +mob-type-shadow-devil+ 1))
                                                        (cons +mob-type-demon+ 7)
                                                        (cons +mob-type-shadow-demon+ 8)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- (/ 46 2) 16)
                                                                               (truncate (- (/ (total-humans world) 4) 16) 2)))
                                                        (cons +mob-type-shadow-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                                      (- (/ 46 2) 16)
                                                                                      (truncate (- (/ (total-humans world) 4) 16) 2)))))
                                          #'find-unoccupied-place-portal)))
          mob-func-list))

  ;; populate world with malseraph puppets
  (when (and (or (/= specific-faction-type +specific-faction-type-demon-malseraph+))
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-demons+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (populate-world-with-mobs world (list (cons +mob-type-malseraph-puppet+ 1))
                                      #'find-unoccupied-place-portal))
        mob-func-list))
  
  (push #'create-mobs-from-template mob-func-list)
  mob-func-list)

(defun scenario-present-faction-setup-demonic-steal (specific-faction-type faction-list mob-func-list)
  (push #'adjust-mobs-after-creation mob-func-list)
  (push #'replace-gold-features-with-items mob-func-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; populate the world with demonic runes
            (place-demonic-runes world))
        mob-func-list)

  ;; remove the land arrival feature and add delayed arrival points to level
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-delayed-arrival-point+)
                            
                    do
                       (when (not (get-terrain-type-trait (get-terrain-* (level world) (x lvl-feature) (y lvl-feature) (z lvl-feature)) +terrain-trait-blocks-move+))
                         (push (list (x lvl-feature) (y lvl-feature) (z lvl-feature)) (delayed-arrival-points (level world))))
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; remove the starting features
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
                    do
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; add a relic
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (loop with item = nil
                  for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-start-place-church-relic+)
                    do
                       (setf item (make-instance 'item :item-type +item-type-church-reliс+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature))) 
                       (add-item-to-level-list (level world) item)
                       (setf (relic-id (level world)) (id item)))
            )
        mob-func-list)

  ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for mob-id in (mob-id-list (level world))
                  for horse = (get-mob-by-id mob-id)
                  for rider = (if (mounted-by-mob-id horse)
                                (get-mob-by-id (mounted-by-mob-id horse))
                                nil)
                  when rider
                    do
                       (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
            ;; remove the glitch from (0, 0, 0)
            (setf (aref (mobs (level world)) 0 0 0) nil)
            )
        mob-func-list)
  
  ;; populate the world with 1 ghost
  (when (and (/= specific-faction-type +specific-faction-type-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-ghost+ 1))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with 1 eater of the dead
  (when (and (/= specific-faction-type +specific-faction-type-eater+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-eater-of-the-dead+ 1))
                                        #'find-unoccupied-place-water))
          mob-func-list))
  
  ;; populate the world with 1 thief
  (when (and (/= specific-faction-type +specific-faction-type-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-thief+ 1))
                                        #'find-unoccupied-place-on-top))
          mob-func-list))

  ;; populate the world with the 3 groups of military, where each group has 1 chaplain, 2 sargeants and 3 soldiers
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
              
              (loop repeat 3
                    do
                       (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                         ;; place the chaplains at the army post if the military is defending
                         (if (find-if #'(lambda (a)
                                          (if (and (= (first a) +faction-type-military+)
                                                   (= (second a) +mission-faction-defender+))
                                            t
                                            nil))
                                      faction-list)
                           (progn
                             (loop for feature-id in (feature-id-list (level world))
                                   for lvl-feature = (get-feature-by-id feature-id)
                                   when (= (feature-type lvl-feature) +feature-start-military-point+)
                                     do
                                        (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                                        (add-mob-to-level-list (level world) chaplain)
                                        (remove-feature-from-level-list (level world) lvl-feature)
                                        (remove-feature-from-world lvl-feature)
                                        (loop-finish))
                             )
                           (find-unoccupied-place-outside world chaplain))
                         (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                               (cons +mob-type-scout+ 1)
                                                               (cons +mob-type-soldier+ 3)
                                                               (cons +mob-type-gunner+ 1))
                                                   #'(lambda (world mob)
                                                       (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
              )
          mob-func-list))

  ;; add an additional group of military if there is no player chaplain
  (when (and (/= specific-faction-type +specific-faction-type-military-chaplain+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-military+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                ;; place the chaplains at the army post if the military is defending
                (if (find-if #'(lambda (a)
                                 (if (and (= (first a) +faction-type-military+)
                                          (= (second a) +mission-faction-defender+))
                                   t
                                   nil))
                             faction-list)
                  (progn
                    (loop for feature-id in (feature-id-list (level world))
                          for lvl-feature = (get-feature-by-id feature-id)
                          when (= (feature-type lvl-feature) +feature-start-military-point+)
                            do
                               (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                               (add-mob-to-level-list (level world) chaplain)
                               (remove-feature-from-level-list (level world) lvl-feature)
                               (remove-feature-from-world lvl-feature)
                               (loop-finish))
                    )
                  (find-unoccupied-place-outside world chaplain))
                (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                      (cons +mob-type-scout+ 1)
                                                      (cons +mob-type-soldier+ 3)
                                                      (cons +mob-type-gunner+ 1))
                                          #'(lambda (world mob)
                                              (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
          mob-func-list))
  
  ;; no outsider beasts 
  
  ;; populate the world with the number of angels = humans / 11
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (loop with arrival-points = (loop for feature-id in (feature-id-list (level world))
                                                for lvl-feature = (get-feature-by-id feature-id)
                                                when (= (feature-type lvl-feature) +feature-start-place-church-angels+) 
                                                  collect (list (x lvl-feature) (y lvl-feature) (z lvl-feature)))
                    with positioned = nil
                    with max-angels = (if (> (+ (total-angels world) (truncate (total-humans world) 11)) *min-angels-number*)
                                        (- (truncate (total-humans world) 11) 1)
                                        (- *min-angels-number* (total-angels world)))
                    while (null positioned)
                    for n = (random (length arrival-points))
                    for arrival-point = (nth n arrival-points)
                    do
                       (check-surroundings (first arrival-point) (second arrival-point) t
                                           #'(lambda (dx dy)
                                               (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                          (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                          (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+)
                                                          (not (zerop max-angels)))
                                                 (add-mob-to-level-list (level world) (make-instance 'mob :mob-type +mob-type-angel+
                                                                                                          :x dx :y dy :z (third arrival-point)))
                                                 (decf max-angels)
                                                 )))
                       (when (zerop max-angels)
                         (setf positioned t)))
              )
          mob-func-list))
  
  ;; populate the world with trinity mimics
  (when (and (/= specific-faction-type +specific-faction-type-angel-trinity+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-angels+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              ;; find a suitable arrival point to accomodate trinity mimics
              (loop with arrival-points = (loop for feature-id in (feature-id-list (level world))
                                                for lvl-feature = (get-feature-by-id feature-id)
                                                when (= (feature-type lvl-feature) +feature-start-place-church-angels+) 
                                                  collect (list (x lvl-feature) (y lvl-feature) (z lvl-feature)))
                    with positioned = nil
                    with trinity-mimic-list = (list +mob-type-star-singer+ +mob-type-star-gazer+ +mob-type-star-mender+)
                    while (null positioned)
                    for n = (random (length arrival-points))
                    for arrival-point = (nth n arrival-points)
                    do
                       (let ((free-cells ()))
                         (check-surroundings (first arrival-point) (second arrival-point) t
                                             #'(lambda (dx dy)
                                                 (when (and (not (get-mob-* (level world) dx dy (third arrival-point)))
                                                            (not (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-blocks-move+))
                                                            (get-terrain-type-trait (get-terrain-* (level world) dx dy (third arrival-point)) +terrain-trait-opaque-floor+))
                                                   (push (list dx dy (third arrival-point)) free-cells))))
                         (when (>= (length free-cells) (length trinity-mimic-list))
                           (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+ :x (first (nth 0 free-cells)) :y (second (nth 0 free-cells)) :z (third (nth 0 free-cells))))
                                 (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+ :x (first (nth 1 free-cells)) :y (second (nth 1 free-cells)) :z (third (nth 1 free-cells))))
                                 (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+ :x (first (nth 2 free-cells)) :y (second (nth 2 free-cells)) :z (third (nth 2 free-cells)))))
                             
                             (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                             (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                             (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                             (setf (name mob2) (name mob1) (name mob3) (name mob1))
                             
                             (add-mob-to-level-list (level world) mob1)
                             (add-mob-to-level-list (level world) mob2)
                             (add-mob-to-level-list (level world) mob3))
                           
                           (setf positioned t)
                           ))
                      )
              
             
              )
          mob-func-list))

  ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
  ;; make some of them shadow demons if there is dark in the city
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              (multiple-value-bind (year month day hour min sec) (get-current-date-time (player-game-time world))
                (declare (ignore year month day min sec))
                (populate-world-with-mobs world (if (and (>= hour 7) (< hour 19))
                                                  (list (cons +mob-type-archdemon+ 1)
                                                        (cons +mob-type-demon+ 15)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- 46 16)
                                                                               (- (truncate (total-humans world) 4) 16))))
                                                  (list (if (zerop (random 2)) (cons +mob-type-archdemon+ 1) (cons +mob-type-shadow-devil+ 1))
                                                        (cons +mob-type-demon+ 7)
                                                        (cons +mob-type-shadow-demon+ 8)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- (/ 46 2) 16)
                                                                               (truncate (- (/ (total-humans world) 4) 16) 2)))
                                                        (cons +mob-type-shadow-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                                      (- (/ 46 2) 16)
                                                                                      (truncate (- (/ (total-humans world) 4) 16) 2)))))
                                          #'find-unoccupied-place-portal)))
          mob-func-list))

  
  
  ;; populate world with malseraph puppets
  (when (and (or (/= specific-faction-type +specific-faction-type-demon-malseraph+))
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-demons+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (populate-world-with-mobs world (list (cons +mob-type-malseraph-puppet+ 1))
                                      #'find-unoccupied-place-portal))
        mob-func-list))
  
  (push #'create-mobs-from-template mob-func-list)
  mob-func-list)

(defun scenario-present-faction-setup-demonic-conquest (specific-faction-type faction-list mob-func-list)
  (push #'adjust-mobs-after-creation mob-func-list)
  (push #'replace-gold-features-with-items mob-func-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; populate the world with demonic runes
            (place-demonic-runes world))
        mob-func-list)

  ;; remove the land arrival feature and add delayed arrival points to level
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-delayed-arrival-point+)
                            
                    do
                       (when (not (get-terrain-type-trait (get-terrain-* (level world) (x lvl-feature) (y lvl-feature) (z lvl-feature)) +terrain-trait-blocks-move+))
                         (push (list (x lvl-feature) (y lvl-feature) (z lvl-feature)) (delayed-arrival-points (level world))))
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; remove the starting features
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
                    do
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for mob-id in (mob-id-list (level world))
                  for horse = (get-mob-by-id mob-id)
                  for rider = (if (mounted-by-mob-id horse)
                                (get-mob-by-id (mounted-by-mob-id horse))
                                nil)
                  when rider
                    do
                       (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
            ;; remove the glitch from (0, 0, 0)
            (setf (aref (mobs (level world)) 0 0 0) nil)
            )
        mob-func-list)
  
  ;; populate the world with 1 ghost
  (when (and (/= specific-faction-type +specific-faction-type-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-ghost+ 1))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with 1 eater of the dead
  (when (and (/= specific-faction-type +specific-faction-type-eater+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-eater-of-the-dead+ 1))
                                        #'find-unoccupied-place-water))
          mob-func-list))
  
  ;; populate the world with 1 thief
  (when (and (/= specific-faction-type +specific-faction-type-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-thief+ 1))
                                        #'find-unoccupied-place-on-top))
          mob-func-list))

  ;; populate the world with the 3 groups of military, where each group has 1 chaplain, 2 sargeants and 3 soldiers
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
              
              (loop repeat 3
                    do
                       (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                         ;; place the chaplains at the army post if the military is defending
                         (if (find-if #'(lambda (a)
                                          (if (and (= (first a) +faction-type-military+)
                                                   (= (second a) +mission-faction-defender+))
                                            t
                                            nil))
                                      faction-list)
                           (progn
                             (loop for feature-id in (feature-id-list (level world))
                                   for lvl-feature = (get-feature-by-id feature-id)
                                   when (= (feature-type lvl-feature) +feature-start-military-point+)
                                     do
                                        (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                                        (add-mob-to-level-list (level world) chaplain)
                                        (remove-feature-from-level-list (level world) lvl-feature)
                                        (remove-feature-from-world lvl-feature)
                                        (loop-finish))
                             )
                           (find-unoccupied-place-outside world chaplain))
                         (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                               (cons +mob-type-scout+ 1)
                                                               (cons +mob-type-soldier+ 3)
                                                               (cons +mob-type-gunner+ 1))
                                                   #'(lambda (world mob)
                                                       (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
              )
          mob-func-list))

  ;; add an additional group of military if there is no player chaplain
  (when (and (/= specific-faction-type +specific-faction-type-military-chaplain+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-military+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                ;; place the chaplains at the army post if the military is defending
                (if (find-if #'(lambda (a)
                                 (if (and (= (first a) +faction-type-military+)
                                          (= (second a) +mission-faction-defender+))
                                   t
                                   nil))
                             faction-list)
                  (progn
                    (loop for feature-id in (feature-id-list (level world))
                          for lvl-feature = (get-feature-by-id feature-id)
                          when (= (feature-type lvl-feature) +feature-start-military-point+)
                            do
                               (setf (x chaplain) (x lvl-feature) (y chaplain) (y lvl-feature) (z chaplain) (z lvl-feature))
                               (add-mob-to-level-list (level world) chaplain)
                               (remove-feature-from-level-list (level world) lvl-feature)
                               (remove-feature-from-world lvl-feature)
                               (loop-finish))
                    )
                  (find-unoccupied-place-outside world chaplain))
                (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                      (cons +mob-type-scout+ 1)
                                                      (cons +mob-type-soldier+ 3)
                                                      (cons +mob-type-gunner+ 1))
                                          #'(lambda (world mob)
                                              (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
          mob-func-list))
  
  ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
            
              (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                    (cons +mob-type-wisp+ (truncate (total-humans world) 15)))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with the number of angels = humans / 11
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-angel+ (if (> (+ (total-angels world) (truncate (total-humans world) 11)) *min-angels-number*)
                                                                             (- (truncate (total-humans world) 11) 1)
                                                                             (- *min-angels-number* (total-angels world)))))
                                        #'find-unoccupied-place-outside)
              )
          mob-func-list))
  
  ;; populate the world with trinity mimics
  (when (and (/= specific-faction-type +specific-faction-type-angel-trinity+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-angels+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              ;; set up trinity mimics
              (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+))
                    (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+))
                    (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+)))
                
                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                
                (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)))
          mob-func-list))

  ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
  ;; make some of them shadow demons if there is dark in the city
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              (multiple-value-bind (year month day hour min sec) (get-current-date-time (player-game-time world))
                (declare (ignore year month day min sec))
                (populate-world-with-mobs world (if (and (>= hour 7) (< hour 19))
                                                  (list (cons +mob-type-archdemon+ 1)
                                                        (cons +mob-type-demon+ 15)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- 46 16)
                                                                               (- (truncate (total-humans world) 4) 16))))
                                                  (list (if (zerop (random 2)) (cons +mob-type-archdemon+ 1) (cons +mob-type-shadow-devil+ 1))
                                                        (cons +mob-type-demon+ 7)
                                                        (cons +mob-type-shadow-demon+ 8)
                                                        (cons +mob-type-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                               (- (/ 46 2) 16)
                                                                               (truncate (- (/ (total-humans world) 4) 16) 2)))
                                                        (cons +mob-type-shadow-imp+ (if (> (+ (truncate (total-humans world) 4) 16) 46)
                                                                                      (- (/ 46 2) 16)
                                                                                      (truncate (- (/ (total-humans world) 4) 16) 2)))))
                                          #'find-unoccupied-place-portal)))
          mob-func-list))

  ;; populate world with malseraph puppets
  (when (and (or (/= specific-faction-type +specific-faction-type-demon-malseraph+))
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-demons+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (populate-world-with-mobs world (list (cons +mob-type-malseraph-puppet+ 1))
                                      #'find-unoccupied-place-portal))
        mob-func-list))
  
  (push #'create-mobs-from-template mob-func-list)
  mob-func-list)
