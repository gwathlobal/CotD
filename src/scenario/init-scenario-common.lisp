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
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       (push #'change-level-to-snow template-processing-func-list)
                                                       (pushnew +game-event-snow-falls+ game-event-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +weather-type-rain+
                                             :type +scenario-feature-weather+
                                             :name "Rain"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       (pushnew +game-event-rain-falls+ game-event-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

;;======================
;; LAYOUT
;;======================

(set-scenario-feature (make-scenario-feature :id +city-layout-test+
                                             :type +scenario-feature-city-layout+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       (setf layout-func #'(lambda () (create-template-test-city *max-x-level* *max-y-level* *max-z-level* nil)))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "An ordinary district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-land-arrival-border))
                                                                                                            )))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A district upon a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-river)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-port+
                                             :type +scenario-feature-city-layout+
                                             :name "A seaport district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-port)))
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-port)))
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                         #'(lambda (reserved-level)
                                                                                                                                                             (place-land-arrival-border reserved-level)
                                                                                                                                                             (let ((result))
                                                                                                                                                               (cond
                                                                                                                                                                 ;; north
                                                                                                                                                                 ((= r 0) (setf result (place-reserved-buildings-port-n reserved-level)))
                                                                                                                                                                 ;; south
                                                                                                                                                                 ((= r 1) (setf result (place-reserved-buildings-port-s reserved-level)))
                                                                                                                                                                 ;; east
                                                                                                                                                                 ((= r 2) (setf result (place-reserved-buildings-port-e reserved-level)))
                                                                                                                                                                 ;; west
                                                                                                                                                                 ((= r 3) (setf result (place-reserved-buildings-port-w reserved-level)))) 
                                                                                                                                                               (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                                 (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                   (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                     (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                               result))))
                                                                                                              )))
                                                         )
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "Outskirts of the city"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-forest)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-island+
                                             :type +scenario-feature-city-layout+
                                             :name "An island district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-island)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-barricaded-city+
                                             :type +scenario-feature-city-layout+
                                             :name "A barricaded district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-barricaded-city)))))
                                                                                                                                                                                                                            
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

;;======================
;; FACTIONS
;;======================

(set-scenario-feature (make-scenario-feature :id +player-faction-test+
                                             :type +scenario-feature-player-faction+ :debug t :disabled t
                                             :name "Test"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       ;; it is important that the player setup function is the last to be pushed so that it is the first to be processed, otherwise everything will break
                                                       (push #'adjust-mobs-after-creation mob-func-list)
                                                       (push #'(lambda (world mob-template-list)
                                                                 (declare (ignore mob-template-list))
                                                                 ;; populate the world with demonic runes
                                                                 (place-demonic-runes world))
                                                             mob-func-list)
                                                       (push #'test-level-place-mobs mob-func-list)
                                                                                                             
                                                       (push +game-event-lose-game-died+ game-event-list)
                                                       (push +game-event-win-for-thief+ game-event-list)
                                                       ;(push +game-event-lose-game-possessed+ game-event-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))


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

;;======================
;; MISSION
;;======================

(set-scenario-feature (make-scenario-feature :id +mission-sf-demonic-raid+
                                             :type +scenario-feature-mission+
                                             :name "Demonic raid (SF)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       (push #'(lambda (world)
                                                                 (let ((portals ())
                                                                       (max-portals 8))
                                                                   (loop with max-x = (- (array-dimension (terrain (level world)) 0) 60)
                                                                         with max-y = (- (array-dimension (terrain (level world)) 1) 60)
                                                                         with cur-portal = 0
                                                                         for free-place = t
                                                                         for x = (+ (random max-x) 30)
                                                                         for y = (+ (random max-y) 30)
                                                                         while (< (length portals) max-portals) do
                                                                           (check-surroundings x y t #'(lambda (dx dy)
                                                                                                         (when (or (get-terrain-type-trait (get-terrain-* (level world) dx dy 2) +terrain-trait-blocks-move+)
                                                                                                                   (not (get-terrain-type-trait (get-terrain-* (level world) dx dy 2) +terrain-trait-opaque-floor+))
                                                                                                                   (get-terrain-type-trait (get-terrain-* (level world) dx dy 2) +terrain-trait-water+))
                                                                                                           (setf free-place nil))))
                                                                           (when (and free-place
                                                                                      (not (find (list x y 2) portals :test #'(lambda (a b)
                                                                                                                                (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 10)
                                                                                                                                  t
                                                                                                                                  nil)
                                                                                                                                ))))
                                                                             (push (list x y 2) portals)
                                                                             (incf cur-portal)))
                                                                   (loop for (x y z) in portals do
                                                                     ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id +feature-demonic-portal+)) x y z)
                                                                     (add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-demonic-portal+ :x x :y y :z z))))) 
                                                             post-processing-func-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))
