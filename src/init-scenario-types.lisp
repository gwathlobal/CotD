(in-package :cotd)

;;======================
;; WEATHER
;;======================

(set-scenario-feature (make-scenario-feature :id +weather-type-clear+
                                             :type +scenario-feature-weather+
                                             :name "Clear"
                                             :func nil))

(set-scenario-feature (make-scenario-feature :id +weather-type-snow+
                                             :type +scenario-feature-weather+
                                             :name "Snow"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (declare (ignore faction-list))
                                                       (push #'change-level-to-snow post-processing-func-list)
                                                       (pushnew +game-event-snow-falls+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +weather-type-rain+
                                             :type +scenario-feature-weather+
                                             :name "Rain"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (declare (ignore faction-list))
                                                       (pushnew +game-event-rain-falls+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

;;======================
;; LAYOUT
;;======================

(set-scenario-feature (make-scenario-feature :id +city-layout-test+
                                             :type +scenario-feature-city-layout+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (declare (ignore faction-list))
                                                       (setf layout-func #'(lambda () (create-template-test-city *max-x-level* *max-y-level* *max-z-level* nil)))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "An ordinary city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'place-land-arrival-border
                                                                                                            )))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A city upon a river"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'place-reserved-buildings-river)))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-port+
                                             :type +scenario-feature-city-layout+
                                             :name "A seaport city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-port)))
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-port)))
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (place-land-arrival-border reserved-level)
                                                                                                                  (let ((result))
                                                                                                                    (cond
                                                                                                                      ((= r 0) (setf result (place-reserved-buildings-port-n reserved-level))) ;; north
                                                                                                                      ((= r 1) (setf result (place-reserved-buildings-port-s reserved-level))) ;; south
                                                                                                                      ((= r 2) (setf result (place-reserved-buildings-port-e reserved-level))) ;; east
                                                                                                                      ((= r 3) (setf result (place-reserved-buildings-port-w reserved-level)))) ;; west
                                                                                                                    (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                      (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                  (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                  (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                          (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                    result)))))
                                                         )
                                                                                                              
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "A city in the woods"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'place-reserved-buildings-forest)))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-island+
                                             :type +scenario-feature-city-layout+
                                             :name "An island city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; place tiny forest along the borders
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'place-reserved-buildings-island)))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-barricaded-city+
                                             :type +scenario-feature-city-layout+
                                             :name "A barricaded city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'place-reserved-buildings-barricaded-city)))
                                                                                                                                                                                                                            
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

;;======================
;; FACTIONS
;;======================

(set-scenario-feature (make-scenario-feature :id +player-faction-test+
                                             :type +scenario-feature-player-faction+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       (declare (ignore faction-list))
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'adjust-initial-visibility mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with demonic runes
                                                                 (place-demonic-runes world))
                                                             mob-func-list)
                                                       (push #'test-level-place-mobs mob-func-list)
                                                                                                             
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-win-for-thief+ game-event-list)
                                                       ;(push +game-event-lose-game-possessed+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-player+
                                             :type +scenario-feature-player-faction+ :debug t
                                             :name "Player"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                 (find-unoccupied-place-outside world *player*))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                                                                              
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-angels+
                                             :type +scenario-feature-player-faction+
                                             :name "Celestial Communion (as Chrome angel)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-angel+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 (setf (faction-name *player*) "Chrome Angel"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-angels+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-demons+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Crimson imp)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-imp+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Crimson Imp"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-demons+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-military-chaplain+
                                             :type +scenario-feature-player-faction+
                                             :name "Military (as Chaplain)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-chaplain+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 (setf (faction-name *player*) "Military Chaplain")
                                                                 ;; place the first group of military around the player
                                                                 (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                                                                       (cons +mob-type-scout+ 1)
                                                                                                       (cons +mob-type-soldier+ 2)
                                                                                                       (cons +mob-type-gunner+ 1))
                                                                                           #'(lambda (world mob)
                                                                                               (find-unoccupied-place-around world mob (x *player*) (y *player*) (z *player*)))))
                                                             mob-func-list)

                                                                                                              
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-humans+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-military-scout+
                                             :type +scenario-feature-player-faction+
                                             :name "Military (as Scout)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-scout+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 (setf (faction-name *player*) "Military Scout")
                                                                 )
                                                             mob-func-list)

                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-humans+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-thief+
                                             :type +scenario-feature-player-faction+
                                             :name "Thief"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-thief+))
                                                                 (find-unoccupied-place-on-top world *player*)
                                                                 (setf (faction-name *player*) "Thief"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-thief+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-satanist+
                                             :type +scenario-feature-player-faction+
                                             :name "Satanists"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-satanist+))
                                                                 (find-player-start-position world *player* +feature-start-satanist-player+)
                                                                 (setf (faction-name *player*) "Satanist"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-demons+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-church+
                                             :type +scenario-feature-player-faction+
                                             :name "Church"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-priest+))
                                                                 (find-player-start-position world *player* +feature-start-church-player+)
                                                                 (setf (faction-name *player*) "Church"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-humans+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-shadows+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Shadow imp)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))
                                                       
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-shadow-imp+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Shadow Imp"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-demons+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-trinity-mimics+
                                             :type +scenario-feature-player-faction+
                                             :name "Celestial Communion (as Trinity mimics)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (let ((mob1 (make-instance 'player :mob-type +mob-type-star-singer+))
                                                                       (mob2 (make-instance 'player :mob-type +mob-type-star-gazer+))
                                                                       (mob3 (make-instance 'player :mob-type +mob-type-star-mender+)))

                                                                   (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                                                                   (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                                                                   (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                                                                   
                                                                   (setf *player* mob1)
                                                                   (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)
                                                                   (setf (faction-name *player*) "Trinity mimic")))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-angels+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-eater+
                                             :type +scenario-feature-player-faction+
                                             :name "Eater of the dead"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-eater-of-the-dead+))
                                                                 (find-unoccupied-place-water world *player*)
                                                                 (setf (faction-name *player*) "Eater of the dead"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-eater+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-puppet+
                                             :type +scenario-feature-player-faction+
                                             :name "Pandemonium Hierarchy (as Malseraph's puppet)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-malseraph-puppet+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Malseraph's puppet"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-demons+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-ghost+
                                             :type +scenario-feature-player-faction+
                                             :name "Lost soul"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list faction-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break

                                                       (setf mob-func-list (scenario-present-faction-setup +player-faction-player+ faction-list mob-func-list))

                                                       (setf game-event-list (scenario-delayed-faction-setup faction-list game-event-list))

                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-ghost+))
                                                                 (find-unoccupied-place-inside world *player*)
                                                                 (setf (faction-name *player*) "Lost soul"))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-ghost+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

;;======================
;; TIME OF DAY
;;======================

(set-scenario-feature (make-scenario-feature :id +tod-type-night+
                                             :type +scenario-feature-time-of-day+
                                             :name "Night"
                                             :func #'(lambda (level)
                                                       (set-up-outdoor-light level 0))))

(set-scenario-feature (make-scenario-feature :id +tod-type-day+
                                             :type +scenario-feature-time-of-day+
                                             :name "Day"
                                             :func #'(lambda (level)
                                                       (set-up-outdoor-light level 100))))

(set-scenario-feature (make-scenario-feature :id +tod-type-morning+
                                             :type +scenario-feature-time-of-day+
                                             :name "Morning"
                                             :func #'(lambda (level)
                                                       (set-up-outdoor-light level 50))))

(set-scenario-feature (make-scenario-feature :id +tod-type-evening+
                                             :type +scenario-feature-time-of-day+
                                             :name "Evening"
                                             :func #'(lambda (level)
                                                       (set-up-outdoor-light level 50))))
