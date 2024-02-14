(in-package :cotd)

(set-god-type (make-instance 'god :id +god-entity-malseraph+ :name "Malseraph"
                                  :piety-level-func #'(lambda (god piety-num)
                                                        (declare (ignore god))
                                                        (cond
                                                          ((<= piety-num +malseraphs-piety-very-low+) 0)
                                                          ((<= piety-num +malseraphs-piety-low+) 1)
                                                          ((<= piety-num +malseraphs-piety-medium+) 2)
                                                          ((<= piety-num +malseraphs-piety-high+) 3)
                                                          (t 4)))
                                  :piety-str-func #'(lambda (god piety-num)
                                                      (let ((piety-level (funcall (piety-level-func god) god piety-num)))
                                                        (cond
                                                          ((= piety-level 0) "Bored!")
                                                          ((= piety-level 1) "Losing interest")
                                                          ((= piety-level 2) "Interested")
                                                          ((= piety-level 3) "Intrigued")
                                                          (t "Amazed!"))))
                                  :piety-change-str-func #'(lambda (god piety-num-new piety-num-old)
                                                             (let ((piety-level (funcall (piety-level-func god) god piety-num-new))
                                                                   (piety-level-old (funcall (piety-level-func god) god piety-num-old)))
                                                               (cond
                                                                 ((= piety-level 0) "Malseraph is bored! ")
                                                                 ((and (= piety-level 1) (< piety-level piety-level-old)) "Malseraph loses interest in you. ")
                                                                 ((and (= piety-level 1) (> piety-level piety-level-old)) "Malseraph becomes slightly interested in you. ")
                                                                 ((and (= piety-level 2) (< piety-level piety-level-old)) "Malseraph's peak of interest is over. ")
                                                                 ((and (= piety-level 2) (> piety-level piety-level-old)) "Malseraph becomes mildly interested in you. ")
                                                                 ((and (= piety-level 3) (< piety-level piety-level-old)) "Malseraph wants you to continue. ")
                                                                 ((and (= piety-level 3) (> piety-level piety-level-old)) "Malseraph is intrigued. ")
                                                                 (t "Malseraph is amazed! "))))
                                  :piety-tick-func #'(lambda (god mob)
                                                       (let* ((new-piety (- (get-worshiped-god-piety (worshiped-god mob))
                                                                            (+ 2 (random 3))))
                                                              (piety-level (funcall (piety-level-func god) god new-piety))
                                                              (card-played nil)
                                                              (bad-chance (cond
                                                                            ((= piety-level 2) 1)
                                                                            ((= piety-level 1) 5)
                                                                            ((= piety-level 0) 20)
                                                                            (t 0)))
                                                              (deck-of-damnation (list (list +item-card-polymorph-self+ 120) (list +item-card-irradiate-self+ 60) (list +item-card-teleport+ 80) (list +item-card-confuse-self+ 70)
                                                                                       (list +item-card-silence-self+ 70) (list +item-card-slow-self+ 70) (list +item-card-fear-self+ 50) (list +item-card-blindness-self+ 70)
                                                                                       (list +item-card-curse-self+ 50) (list +item-card-lignify-self+ 120)))
                                                              (good-chance (cond
                                                                            ((= piety-level 1) 1)
                                                                            ((= piety-level 2) 5)
                                                                            ((= piety-level 3) 10)
                                                                            (t 0)))
                                                              (deck-of-boons (list (list +item-card-polymorph-other+ t t) (list +item-card-irradiate-other+ t t) (list +item-card-confuse-other+ t t) (list +item-card-silence-other+ t t)
                                                                                   (list +item-card-slow-other+ t t) (list +item-card-fear-other+ t t) (list +item-card-blindness-other+ t t) (list +item-card-curse-other+ t t)
                                                                                   (list +item-card-give-deck+ nil nil) (list +item-card-cure-mutation+ nil nil) (list +item-card-lignify-other+ t t)))
                                                              (neutral-chance (cond
                                                                                ((= piety-level 1) 3)
                                                                                ((= piety-level 2) 5)
                                                                                ((= piety-level 3) 3)
                                                                                (t 1)))
                                                              (deck-of-neutrality (list (list +item-card-glowing-all+) (list +item-card-disguise+))))

                                                         ;; Malseraph is not interested and something bad is about to happen 
                                                         (when (and (not card-played)
                                                                    (not (zerop bad-chance))
                                                                    (< (random 100) bad-chance))
                                                           (setf card-played t)
                                                           (let* ((r (random (length deck-of-damnation)))
                                                                  (card-type-id (first (nth r deck-of-damnation)))
                                                                  (piety-gain (second (nth r deck-of-damnation))))
                                                             (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                    (format nil "Malseraph draws the ~A. " (name (get-card-type-by-id card-type-id)))
                                                                                    :color sdl:*magenta*
                                                                                    :tags (list (when (and (find (id mob) (shared-visible-mobs *player*))
                                                                                                           (not (find (id mob) (proper-visible-mobs *player*))))
                                                                                                  :singlemind)))
                                                             (funcall (on-use (get-card-type-by-id card-type-id)) (get-card-type-by-id card-type-id) mob)
                                                             (incf new-piety piety-gain)

                                                             (when (= card-type-id +item-card-teleport+)
                                                               (update-visible-mobs mob)
                                                               (when (eq mob *player*)
                                                                 (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                                                                 (update-map-area *start-map-x* 0)))
                                                             (loop for mob-id in (visible-mobs mob)
                                                                   for vmob = (get-mob-by-id mob-id)
                                                                   with enemy-strength = 0
                                                                   when (and (not (check-dead vmob))
                                                                             (not (is-merged vmob))
                                                                             (null (get-faction-relation (faction mob) (get-visible-faction vmob :viewer mob))))
                                                                     do
                                                                        (incf enemy-strength (strength vmob))
                                                                   finally
                                                                      (when (>= enemy-strength (strength mob))
                                                                        (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                               (format nil "Malseraph bursts with laughter. ")
                                                                                               :color sdl:*magenta*
                                                                                               :tags (list (when (and (find (id mob) (shared-visible-mobs *player*))
                                                                                                                      (not (find (id mob) (proper-visible-mobs *player*))))
                                                                                                             :singlemind)))
                                                                        (incf new-piety 40)))))

                                                         ;; Malseraph is interested and something good is about to happen
                                                         (when (and (not card-played)
                                                                    (not (zerop good-chance))
                                                                    (< (random 100) good-chance))
                                                           (setf card-played t)
                                                           (let* ((r (random (length deck-of-boons)))
                                                                  (card-type-id (first (nth r deck-of-boons)))
                                                                  (needs-enemies (second (nth r deck-of-boons)))
                                                                  (print-msg (third (nth r deck-of-boons)))
                                                                  (nearest-enemy (loop for mob-id in (visible-mobs mob)
                                                                                       for vmob = (get-mob-by-id mob-id)
                                                                                       when (and (not (check-dead vmob))
                                                                                                 (not (is-merged vmob))
                                                                                                 (null (get-faction-relation (faction mob) (get-visible-faction vmob :viewer mob))))
                                                                                         do
                                                                                            (return vmob))))

                                                             (when (or (and needs-enemies
                                                                            nearest-enemy)
                                                                       (not needs-enemies))
                                                               (when (or print-msg
                                                                         (and (not print-msg)
                                                                              (eq mob *player*)))
                                                                 (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                        (format nil "Malseraph draws the ~A. " (name (get-card-type-by-id card-type-id)))
                                                                                        :color sdl:*magenta*
                                                                                        :tags (list (when (and (find (id mob) (shared-visible-mobs *player*))
                                                                                                               (not (find (id mob) (proper-visible-mobs *player*))))
                                                                                                      :singlemind))))
                                                               (funcall (on-use (get-card-type-by-id card-type-id)) (get-card-type-by-id card-type-id) mob))

                                                             ))

                                                         ;; Malseraph is mildly interested and something neutral is about to happen
                                                         (when (and (not card-played)
                                                                    (not (zerop neutral-chance))
                                                                    (< (random 100) neutral-chance))
                                                           (setf card-played t)
                                                           (let* ((r (random (length deck-of-neutrality)))
                                                                  (card-type-id (first (nth r deck-of-neutrality))))
                                                             (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                    (format nil "Malseraph draws the ~A. " (name (get-card-type-by-id card-type-id)))
                                                                                    :color sdl:*magenta*
                                                                                    :tags (list (when (and (find (id mob) (shared-visible-mobs *player*))
                                                                                                           (not (find (id mob) (proper-visible-mobs *player*))))
                                                                                                  :singlemind)))
                                                             (funcall (on-use (get-card-type-by-id card-type-id)) (get-card-type-by-id card-type-id) mob)
                                                             ))

                                                         ;; check if strength of enemies around of you is more than the previous turn
                                                         (loop for mob-id in (visible-mobs mob)
                                                                   for vmob = (get-mob-by-id mob-id)
                                                                   with enemy-strength = 0
                                                                   when (and (not (check-dead vmob))
                                                                             (not (is-merged vmob))
                                                                             (null (get-faction-relation (faction mob) (get-visible-faction vmob :viewer mob))))
                                                                     do
                                                                        (incf enemy-strength (strength vmob))
                                                               finally
                                                                  (when (> enemy-strength (+ (get-worshiped-god-param1 (worshiped-god mob)) (strength mob)))
                                                                        (print-visible-message (x mob) (y mob) (z mob) (level *world*) 
                                                                                               (format nil "Malseraph giggles. ")
                                                                                               :color sdl:*magenta*
                                                                                               :tags (list (when (and (find (id mob) (shared-visible-mobs *player*))
                                                                                                                      (not (find (id mob) (proper-visible-mobs *player*))))
                                                                                                             :singlemind)))
                                                                        (incf new-piety 40)
                                                                        (set-mob-worshiped-god-param1 mob enemy-strength))
                                                                  
                                                                  (when (<= enemy-strength (+ (get-worshiped-god-param1 (worshiped-god mob)) (strength mob)))
                                                                    (set-mob-worshiped-god-param2 mob (1+ (get-worshiped-god-param2 (worshiped-god mob)))))
                                                                  (when (> (get-worshiped-god-param2 (worshiped-god mob)) 5)
                                                                    (set-mob-worshiped-god-param1 mob enemy-strength)
                                                                    (set-mob-worshiped-god-param2 mob 0)))
                                                         
                                                         (set-mob-piety mob new-piety)))))
