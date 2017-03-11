(in-package :cotd)

(set-scenario-feature (make-scenario-feature :id +weather-type-clear+
                                             :type +scenario-feature-weather+
                                             :name "Clear"
                                             :func nil))

(set-scenario-feature (make-scenario-feature :id +weather-type-snow+
                                             :type +scenario-feature-weather+
                                             :name "Snow"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (push #'change-level-to-snow post-processing-func-list)
                                                       (pushnew +game-event-snow-falls+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-test+
                                             :type +scenario-feature-city-layout+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (setf layout-func #'(lambda () (create-template-test-city *max-x-level* *max-y-level* *max-z-level* nil)))
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "An ordinary city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level* #'get-max-buildings-normal #'get-reserved-buildings-normal nil)))
                                                       (push +game-event-military-arrive+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A city upon a river"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'get-max-buildings-river #'get-reserved-buildings-river #'place-reserved-buildings-river)))
                                                       (push +game-event-military-arrive+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-port+
                                             :type +scenario-feature-city-layout+
                                             :name "A seaport city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level* #'get-max-buildings-port #'get-reserved-buildings-port
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (let ((result))
                                                                                                                    (cond
                                                                                                                      ((= r 0) (setf result (place-reserved-buildings-port-n reserved-level))) ;; north
                                                                                                                      ((= r 1) (setf result (place-reserved-buildings-port-s reserved-level))) ;; south
                                                                                                                      ((= r 2) (setf result (place-reserved-buildings-port-e reserved-level))) ;; east
                                                                                                                      ((= r 3) (setf result (place-reserved-buildings-port-w reserved-level)))) ;; west
                                                                                                                    result)))))
                                                         (cond
                                                           ((= r 0) (push +game-event-military-arrive-port-n+ game-event-list)) ;; north
                                                           ((= r 1) (push +game-event-military-arrive-port-s+ game-event-list)) ;; south
                                                           ((= r 2) (push +game-event-military-arrive-port-e+ game-event-list)) ;; east
                                                           ((= r 3) (push +game-event-military-arrive-port-w+ game-event-list))) ;; west
                                                         )
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-player+
                                             :type +scenario-feature-player-faction+ :debug t
                                             :name "Player"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
                                                                 (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                                                                       (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of angels = humans / 10, of which 1 will be an archangel
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archangel+ 1)
                                                                                                       (cons +mob-type-angel+ (- (truncate (total-humans world) 10) 1)))
                                                                                           #'find-unoccupied-place-outside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archdemon+ 1)
                                                                                                       (cons +mob-type-demon+ 15)
                                                                                                       (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'create-mobs-from-template mob-func-list)
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                 (find-unoccupied-place-outside world *player*))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-test+
                                             :type +scenario-feature-player-faction+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'test-level-place-mobs mob-func-list)
                                                                                                             
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       ;(push +game-event-lose-game-possessed+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-angels+
                                             :type +scenario-feature-player-faction+
                                             :name "Angels"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; adjust coordinates of all horses to their riders
                                                                 (loop for mob-id in (mob-id-list (level world))
                                                                       for horse = (get-mob-by-id mob-id)
                                                                       for rider = (if (mounted-by-mob-id horse)
                                                                                     (get-mob-by-id (mounted-by-mob-id horse))
                                                                                     nil)
                                                                       when rider
                                                                         do
                                                                            (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
                                                                 (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                                                                       (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of angels = humans / 10, of which 1 will be an archangel
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archangel+ 1)
                                                                                                       (cons +mob-type-angel+ (- (truncate (total-humans world) 10) 1)))
                                                                                           #'find-unoccupied-place-outside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archdemon+ 1)
                                                                                                       (cons +mob-type-demon+ 15)
                                                                                                       (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'create-mobs-from-template mob-func-list)
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-angel+))
                                                                 (find-unoccupied-place-outside world *player*))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-angels+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-demons+
                                             :type +scenario-feature-player-faction+
                                             :name "Demons"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; adjust coordinates of all horses to their riders
                                                                 (loop for mob-id in (mob-id-list (level world))
                                                                       for horse = (get-mob-by-id mob-id)
                                                                       for rider = (if (mounted-by-mob-id horse)
                                                                                     (get-mob-by-id (mounted-by-mob-id horse))
                                                                                     nil)
                                                                       when rider
                                                                         do
                                                                            (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
                                                                 (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                                                                       (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of angels = humans / 10, of which 1 will be an archangel
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archangel+ 1)
                                                                                                       (cons +mob-type-angel+ (- (truncate (total-humans world) 10) 1)))
                                                                                           #'find-unoccupied-place-outside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archdemon+ 1)
                                                                                                       (cons +mob-type-demon+ 15)
                                                                                                       (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'create-mobs-from-template mob-func-list)
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-imp+))
                                                                 (find-unoccupied-place-inside world *player*))
                                                             mob-func-list)
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-demons+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "A city in the woods"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'get-max-buildings-normal #'get-reserved-buildings-normal #'place-reserved-buildings-forest)))
                                                       (push +game-event-military-arrive+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-island+
                                             :type +scenario-feature-city-layout+
                                             :name "An island city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; place tiny forest along the borders
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'get-max-buildings-river #'get-reserved-buildings-river #'place-reserved-buildings-island)))
                                                       (push +game-event-military-arrive-island+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-military-chaplain+
                                             :type +scenario-feature-player-faction+
                                             :name "Military (as Chaplain)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
                                                                 (loop for mob-id in (mob-id-list (level world))
                                                                       for horse = (get-mob-by-id mob-id)
                                                                       for rider = (if (mounted-by-mob-id horse)
                                                                                     (get-mob-by-id (mounted-by-mob-id horse))
                                                                                     nil)
                                                                       when rider
                                                                         do
                                                                            (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
                                                                 (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                                                                       (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the 6 groups of military = 40, where each group has 1 chaplain, 2 sargeants and 3 soldiers
                                                                 (loop repeat 5
                                                                       do
                                                                          (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                                                                            (find-unoccupied-place-outside world chaplain)
                                                                            (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                                                                                  (cons +mob-type-scout+ 1)
                                                                                                                  (cons +mob-type-soldier+ 2)
                                                                                                                  (cons +mob-type-gunner+ 1))
                                                                                                      #'(lambda (world mob)
                                                                                                          (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of angels = humans / 10, of which 1 will be an archangel
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archangel+ 1)
                                                                                                       (cons +mob-type-angel+ (- (truncate (total-humans world) 10) 1)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archdemon+ 1)
                                                                                                       (cons +mob-type-demon+ 15)
                                                                                                       (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'create-mobs-from-template mob-func-list)
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-chaplain+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 ;; place the first group of military around the player
                                                                 (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                                                                       (cons +mob-type-scout+ 1)
                                                                                                       (cons +mob-type-soldier+ 2)
                                                                                                       (cons +mob-type-gunner+ 1))
                                                                                           #'(lambda (world mob)
                                                                                               (find-unoccupied-place-around world mob (x *player*) (y *player*) (z *player*)))))
                                                             mob-func-list)

                                                       ;; remove all "military arrives" events; after the function returns, all nils are to be deleted from the game-event-list  
                                                       ;; I could use remove, but I am afraid that whether game-event-list may not be modified because it is implementation-dependent  
                                                       (loop for i from 0 below (length game-event-list)
                                                             for game-event-id = (nth i game-event-list)
                                                             when (or (= game-event-id +game-event-military-arrive+)
                                                                      (= game-event-id +game-event-military-arrive-port-n+)
                                                                      (= game-event-id +game-event-military-arrive-port-s+)
                                                                      (= game-event-id +game-event-military-arrive-port-e+)
                                                                      (= game-event-id +game-event-military-arrive-port-w+)
                                                                      (= game-event-id +game-event-military-arrive-island+))
                                                               do
                                                                  (setf (nth i game-event-list) nil))
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-humans+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-barricaded-city+
                                             :type +scenario-feature-city-layout+
                                             :name "A barricaded city"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'get-max-buildings-normal #'get-reserved-buildings-normal #'place-reserved-buildings-barricaded-city)))
                                                       (push +game-event-military-arrive+ game-event-list)
                                                                                                                                                                     
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +player-faction-military-scout+
                                             :type +scenario-feature-player-faction+
                                             :name "Military (as Scout)"
                                             :func #'(lambda (layout-func post-processing-func-list mob-func-list game-event-list)
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
                                                                 (loop for mob-id in (mob-id-list (level world))
                                                                       for horse = (get-mob-by-id mob-id)
                                                                       for rider = (if (mounted-by-mob-id horse)
                                                                                     (get-mob-by-id (mounted-by-mob-id horse))
                                                                                     nil)
                                                                       when rider
                                                                         do
                                                                            (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
                                                                 (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                                                                       (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the 6 groups of military = 40, where each group has 1 chaplain, 1 sargeant, 1 scout and 3 soldiers
                                                                 (loop repeat 6
                                                                       do
                                                                          (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+)))
                                                                            (find-unoccupied-place-outside world chaplain)
                                                                            (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                                                                                  (cons +mob-type-scout+ 1)
                                                                                                                  (cons +mob-type-soldier+ 2)
                                                                                                                  (cons +mob-type-gunner+ 1))
                                                                                                      #'(lambda (world mob)
                                                                                                          (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
                                                                 )
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of angels = humans / 10, of which 1 will be an archangel
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archangel+ 1)
                                                                                                       (cons +mob-type-angel+ (- (truncate (total-humans world) 10) 1)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
                                                                 (populate-world-with-mobs world (list (cons +mob-type-archdemon+ 1)
                                                                                                       (cons +mob-type-demon+ 15)
                                                                                                       (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                                                           #'find-unoccupied-place-inside))
                                                             mob-func-list)
                                                       (push #'create-mobs-from-template mob-func-list)
                                                       (push #'(lambda (world mob-template-list) (declare (ignore mob-template-list))
                                                                 (setf *player* (make-instance 'player :mob-type +mob-type-scout+))
                                                                 (find-unoccupied-place-outside world *player*)
                                                                 )
                                                             mob-func-list)

                                                       ;; remove all "military arrives" events; after the function returns, all nils are to be deleted from the game-event-list  
                                                       ;; I could use remove, but I am afraid that whether game-event-list may not be modified because it is implementation-dependent  
                                                       (loop for i from 0 below (length game-event-list)
                                                             for game-event-id = (nth i game-event-list)
                                                             when (or (= game-event-id +game-event-military-arrive+)
                                                                      (= game-event-id +game-event-military-arrive-port-n+)
                                                                      (= game-event-id +game-event-military-arrive-port-s+)
                                                                      (= game-event-id +game-event-military-arrive-port-e+)
                                                                      (= game-event-id +game-event-military-arrive-port-w+)
                                                                      (= game-event-id +game-event-military-arrive-island+))
                                                               do
                                                                  (setf (nth i game-event-list) nil))
                                                       
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-lose-game-possessed+ game-event-list)
                                                       (push +game-event-win-for-humans+ game-event-list)
                                                       
                                                       (values layout-func post-processing-func-list mob-func-list game-event-list))))
