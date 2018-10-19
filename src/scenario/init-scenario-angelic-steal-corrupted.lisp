(in-package :cotd)

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-player+
                                             :type +scenario-feature-player-faction+ :debug t
                                             :name "Player"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                 (find-unoccupied-place-outside world *player*))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                                                                                                                                     
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-dead-player+
                                             :type +scenario-feature-player-faction+ :debug t
                                             :name "Dead player"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-dead-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 (setf (cur-hp *player*) 0)
                                                                 (make-dead *player* :corpse nil))
                                                             mob-func-list)

                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-angel-chrome+
                                             :type +scenario-feature-player-faction+
                                             :name "Celestial Communion (as Chrome angel)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-angel-chrome+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-angel+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 (setf (faction-name *player*) "Chrome Angel")
                                                                                                                                  
                                                                 )
                                                             mob-func-list)
                                                       
                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-angel-trinity+
                                             :type +scenario-feature-player-faction+
                                             :name "Celestial Communion (as Trinity mimics)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-angel-trinity+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (let ((mob1 (make-instance 'player :mob-type +mob-type-star-singer+))
                                                                       (mob2 (make-instance 'player :mob-type +mob-type-star-gazer+))
                                                                       (mob3 (make-instance 'player :mob-type +mob-type-star-mender+)))

                                                                   (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                                                                   (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                                                                   (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                                                                   
                                                                   (setf *player* mob1)
                                                                   (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)
                                                                   (setf (faction-name *player*) "Trinity mimic"))
                                                                 )
                                                             mob-func-list)
                                                       
                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-demon-crimson+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Crimson imp)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-demon-crimson+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-imp+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Crimson Imp"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-demon-shadow+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Shadow imp)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-demon-shadow+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-shadow-imp+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Shadow Imp"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-demon-malseraph+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Malseraph's puppet)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-demon-malseraph+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-malseraph-puppet+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Malseraph's puppet"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-player-died+ game-event-list)
                                                       (setf game-event-list (set-up-win-conditions game-event-list faction-list mission-id))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-eater+
                                             :type +scenario-feature-player-faction+
                                             :name "Eater of the dead"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-eater+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-eater-of-the-dead+))
                                                                 (find-unoccupied-place-water world *player*)
                                                                 (setf (faction-name *player*) "Eater of the dead"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-eater+ game-event-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +sf-faction-angelic-steal-skinchanger+
                                             :type +scenario-feature-player-faction+
                                             :name "Skinchanger"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup-angelic-steal +specific-faction-type-skinchanger+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup-angelic-steal faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-skinchanger-melee+))
                                                                 (find-unoccupied-place-water world *player*)
                                                                 (setf (faction-name *player*) "Skinchanger"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-eater+ game-event-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))
