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
                                             :name "The outskirts of the city"
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

(set-scenario-feature (make-scenario-feature :id +city-layout-lake+
                                             :type +scenario-feature-city-layout+
                                             :name "A district upon a lake"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-lake-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A district upon a lake and a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-river)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-port-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A seaport district with a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-port)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-port)))
                                                                                                            #'(lambda (reserved-level)
                                                                                                                (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                       #'(lambda (reserved-level)
                                                                                                                                                           (place-land-arrival-border reserved-level)
                                                                                                                                                           (let ((result) (r (random 11)) (n nil) (s nil) (w nil) (e nil))

                                                                                                                                                             (cond
                                                                                                                                                               ((= r 0) (setf w t e t))           ;; 0 - we
                                                                                                                                                               ((= r 1) (setf n t s t))           ;; 1 - ns
                                                                                                                                                               ((= r 2) (setf n t e t))           ;; 2 - ne
                                                                                                                                                               ((= r 3) (setf n t w t))           ;; 3 - nw
                                                                                                                                                               ((= r 4) (setf s t e t))           ;; 4 - se
                                                                                                                                                               ((= r 5) (setf s t w t))           ;; 5 - sw
                                                                                                                                                               ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                                                                                                                               ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                                                                                                                               ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                                                                                                                               ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                                                                                                                               ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe
                                                                                                                                                             
                                                                                                                                                             (when n (place-city-river-n reserved-level))
                                                                                                                                                             (when s (place-city-river-s reserved-level))
                                                                                                                                                             (when w (place-city-river-w reserved-level))
                                                                                                                                                             (when e (place-city-river-e reserved-level))
                                                                                                                                                             (place-city-river-center reserved-level)

                                                                                                                                                             (setf r (random 4))
                                                                                                                                                             (cond
                                                                                                                                                               ;; north
                                                                                                                                                               ((= r 0)
                                                                                                                                                                (place-city-river-n reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-port-n reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; south
                                                                                                                                                               ((= r 1)
                                                                                                                                                                (place-city-river-s reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-port-s reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; east
                                                                                                                                                               ((= r 2)
                                                                                                                                                                (place-city-river-e reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-port-e reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; west
                                                                                                                                                               ((= r 3)
                                                                                                                                                                (place-city-river-w reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-port-w reserved-level t))
                                                                                                                                                                ))
                                                                                                                                                             
                                                                                                                                                             (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                               (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                 (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-river+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-bridge+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                   (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                             result))))
                                                                                                            )))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))


(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-land-arrival-border))
                                                                                                            )))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-river+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned district upon a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-river)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-port+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned seaport district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-port)))
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-port)))
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                         #'(lambda (reserved-level)
                                                                                                                                                             (place-land-arrival-border reserved-level)
                                                                                                                                                             (let ((result))
                                                                                                                                                               (cond
                                                                                                                                                                 ;; north
                                                                                                                                                                 ((= r 0) (setf result (place-reserved-buildings-ruined-port-n
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; south
                                                                                                                                                                 ((= r 1) (setf result (place-reserved-buildings-ruined-port-s
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; east
                                                                                                                                                                 ((= r 2) (setf result (place-reserved-buildings-ruined-port-e
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; west
                                                                                                                                                                 ((= r 3) (setf result (place-reserved-buildings-ruined-port-w
                                                                                                                                                                                        reserved-level)))) 
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

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "The abandoned outskirts of the city"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-ruined-forest)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-island+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned island district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-island)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-lake+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned district upon a lake"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-lake-river+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned district upon a lake and river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-river)))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-ruined-port-river+
                                             :type +scenario-feature-city-layout+
                                             :name "An abandoned seaport district with a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-ruined-port)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-ruined-port)))
                                                                                                            #'(lambda (reserved-level)
                                                                                                                (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                       #'(lambda (reserved-level)
                                                                                                                                                           (place-land-arrival-border reserved-level)
                                                                                                                                                           (let ((result) (r (random 11)) (n nil) (s nil) (w nil) (e nil))

                                                                                                                                                             (cond
                                                                                                                                                               ((= r 0) (setf w t e t))           ;; 0 - we
                                                                                                                                                               ((= r 1) (setf n t s t))           ;; 1 - ns
                                                                                                                                                               ((= r 2) (setf n t e t))           ;; 2 - ne
                                                                                                                                                               ((= r 3) (setf n t w t))           ;; 3 - nw
                                                                                                                                                               ((= r 4) (setf s t e t))           ;; 4 - se
                                                                                                                                                               ((= r 5) (setf s t w t))           ;; 5 - sw
                                                                                                                                                               ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                                                                                                                               ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                                                                                                                               ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                                                                                                                               ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                                                                                                                               ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe
                                                                                                                                                             
                                                                                                                                                             (when n (place-city-river-n reserved-level))
                                                                                                                                                             (when s (place-city-river-s reserved-level))
                                                                                                                                                             (when w (place-city-river-w reserved-level))
                                                                                                                                                             (when e (place-city-river-e reserved-level))
                                                                                                                                                             (place-city-river-center reserved-level)

                                                                                                                                                             (setf r (random 4))
                                                                                                                                                             (cond
                                                                                                                                                               ;; north
                                                                                                                                                               ((= r 0)
                                                                                                                                                                (place-city-river-n reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-n reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; south
                                                                                                                                                               ((= r 1)
                                                                                                                                                                (place-city-river-s reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-s reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; east
                                                                                                                                                               ((= r 2)
                                                                                                                                                                (place-city-river-e reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-e reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; west
                                                                                                                                                               ((= r 3)
                                                                                                                                                                (place-city-river-w reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-w reserved-level t))
                                                                                                                                                                ))
                                                                                                                                                             
                                                                                                                                                             (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                               (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                 (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-river+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-bridge+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                   (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                             result))))
                                                                                                            )))
                                                                                                                                                                     
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-land-arrival-border
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-river
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-port+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted seaport district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-port)))
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-port)))
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                         #'(lambda (reserved-level)
                                                                                                                                                             (place-land-arrival-border reserved-level)
                                                                                                                                                             (let ((result))
                                                                                                                                                               (cond
                                                                                                                                                                 ;; north
                                                                                                                                                                 ((= r 0) (setf result (place-reserved-buildings-ruined-port-n
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; south
                                                                                                                                                                 ((= r 1) (setf result (place-reserved-buildings-ruined-port-s
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; east
                                                                                                                                                                 ((= r 2) (setf result (place-reserved-buildings-ruined-port-e
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; west
                                                                                                                                                                 ((= r 3) (setf result (place-reserved-buildings-ruined-port-w
                                                                                                                                                                                        reserved-level)))) 
                                                                                                                                                               (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                                 (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                   (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                     (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                               result))
                                                                                                                                                         (list +reserved-building-army-post+
                                                                                                                                                               +building-city-army-post-corrupted+
                                                                                                                                                               +reserved-building-sigil-post+
                                                                                                                                                               +building-city-corrupted-sigil-post+)))
                                                                                                              (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+)
                                                                                                              )))
                                                         )
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "The corrupted outskirts of the city"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-corrupted-forest
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-island+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted island district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-island
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-lake+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a lake"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-corrupted
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-lake-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a lake and a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-river-corrupted
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-port-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted seaport district with a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-port)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-port)))
                                                                                                            #'(lambda (reserved-level)
                                                                                                                (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                       #'(lambda (reserved-level)
                                                                                                                                                           (place-land-arrival-border reserved-level)
                                                                                                                                                           (let ((result) (r (random 11)) (n nil) (s nil) (w nil) (e nil))

                                                                                                                                                             (cond
                                                                                                                                                               ((= r 0) (setf w t e t))           ;; 0 - we
                                                                                                                                                               ((= r 1) (setf n t s t))           ;; 1 - ns
                                                                                                                                                               ((= r 2) (setf n t e t))           ;; 2 - ne
                                                                                                                                                               ((= r 3) (setf n t w t))           ;; 3 - nw
                                                                                                                                                               ((= r 4) (setf s t e t))           ;; 4 - se
                                                                                                                                                               ((= r 5) (setf s t w t))           ;; 5 - sw
                                                                                                                                                               ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                                                                                                                               ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                                                                                                                               ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                                                                                                                               ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                                                                                                                               ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe
                                                                                                                                                             
                                                                                                                                                             (when n (place-city-river-n reserved-level))
                                                                                                                                                             (when s (place-city-river-s reserved-level))
                                                                                                                                                             (when w (place-city-river-w reserved-level))
                                                                                                                                                             (when e (place-city-river-e reserved-level))
                                                                                                                                                             (place-city-river-center reserved-level)

                                                                                                                                                             (setf r (random 4))
                                                                                                                                                             (cond
                                                                                                                                                               ;; north
                                                                                                                                                               ((= r 0)
                                                                                                                                                                (place-city-river-n reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-n reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; south
                                                                                                                                                               ((= r 1)
                                                                                                                                                                (place-city-river-s reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-s reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; east
                                                                                                                                                               ((= r 2)
                                                                                                                                                                (place-city-river-e reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-e reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; west
                                                                                                                                                               ((= r 3)
                                                                                                                                                                (place-city-river-w reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-w reserved-level t))
                                                                                                                                                                ))
                                                                                                                                                             
                                                                                                                                                             (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                               (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                 (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-river+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-bridge+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                   (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                             result))
                                                                                                                                                       (list +reserved-building-army-post+
                                                                                                                                                             +building-city-army-post-corrupted+
                                                                                                                                                             +reserved-building-sigil-post+
                                                                                                                                                             +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+)
                                                                                                            )))
                                                                                                                                                                   
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-normal+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-land-arrival-border
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-river
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-port+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted seaport district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (let ((r (random 4)))
                                                         (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-port)))
                                                                                                              #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-port)))
                                                                                                              #'(lambda (reserved-level)
                                                                                                                  (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                         #'(lambda (reserved-level)
                                                                                                                                                             (place-land-arrival-border reserved-level)
                                                                                                                                                             (let ((result))
                                                                                                                                                               (cond
                                                                                                                                                                 ;; north
                                                                                                                                                                 ((= r 0) (setf result (place-reserved-buildings-ruined-port-n
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; south
                                                                                                                                                                 ((= r 1) (setf result (place-reserved-buildings-ruined-port-s
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; east
                                                                                                                                                                 ((= r 2) (setf result (place-reserved-buildings-ruined-port-e
                                                                                                                                                                                        reserved-level)))
                                                                                                                                                                 ;; west
                                                                                                                                                                 ((= r 3) (setf result (place-reserved-buildings-ruined-port-w
                                                                                                                                                                                        reserved-level)))) 
                                                                                                                                                               (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                                 (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                   (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                             (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                     (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                               result))
                                                                                                                                                         (list +reserved-building-army-post+
                                                                                                                                                               +building-city-army-post-corrupted+
                                                                                                                                                               +reserved-building-sigil-post+
                                                                                                                                                               +building-city-corrupted-sigil-post+)))
                                                                                                              (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+)
                                                                                                              )))
                                                         )
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-forest+
                                             :type +scenario-feature-city-layout+
                                             :name "The corrupted outskirts of the city"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-normal)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-normal)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-ruined-forest
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-island+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted island district"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-island
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-lake+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a lake"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-corrupted
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-lake-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted district upon a lake and a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-river)))
                                                                                                            #'(lambda (reserved-level) (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                                              #'place-reserved-buildings-lake-river-corrupted
                                                                                                                                                                              (list +reserved-building-army-post+
                                                                                                                                                                                    +building-city-army-post-corrupted+
                                                                                                                                                                                    +reserved-building-sigil-post+
                                                                                                                                                                                    +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+))))
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +city-layout-corrupted-steal-port-river+
                                             :type +scenario-feature-city-layout+
                                             :name "A corrupted seaport district with a river"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore mission-id))
                                                       (setf layout-func #'(lambda () (create-template-city *max-x-level* *max-y-level* *max-z-level*
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-max-buildings-corrupted-steal-port)))
                                                                                                            #'(lambda () (set-building-types-for-factions faction-list (get-reserved-buildings-corrupted-steal-port)))
                                                                                                            #'(lambda (reserved-level)
                                                                                                                (place-reserved-buildings-for-factions faction-list reserved-level
                                                                                                                                                       #'(lambda (reserved-level)
                                                                                                                                                           (place-land-arrival-border reserved-level)
                                                                                                                                                           (let ((result) (r (random 11)) (n nil) (s nil) (w nil) (e nil))

                                                                                                                                                             (cond
                                                                                                                                                               ((= r 0) (setf w t e t))           ;; 0 - we
                                                                                                                                                               ((= r 1) (setf n t s t))           ;; 1 - ns
                                                                                                                                                               ((= r 2) (setf n t e t))           ;; 2 - ne
                                                                                                                                                               ((= r 3) (setf n t w t))           ;; 3 - nw
                                                                                                                                                               ((= r 4) (setf s t e t))           ;; 4 - se
                                                                                                                                                               ((= r 5) (setf s t w t))           ;; 5 - sw
                                                                                                                                                               ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                                                                                                                               ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                                                                                                                               ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                                                                                                                               ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                                                                                                                               ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe
                                                                                                                                                             
                                                                                                                                                             (when n (place-city-river-n reserved-level))
                                                                                                                                                             (when s (place-city-river-s reserved-level))
                                                                                                                                                             (when w (place-city-river-w reserved-level))
                                                                                                                                                             (when e (place-city-river-e reserved-level))
                                                                                                                                                             (place-city-river-center reserved-level)

                                                                                                                                                             (setf r (random 4))
                                                                                                                                                             (cond
                                                                                                                                                               ;; north
                                                                                                                                                               ((= r 0)
                                                                                                                                                                (place-city-river-n reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-n reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; south
                                                                                                                                                               ((= r 1)
                                                                                                                                                                (place-city-river-s reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-s reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; east
                                                                                                                                                               ((= r 2)
                                                                                                                                                                (place-city-river-e reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-e reserved-level t))
                                                                                                                                                                )
                                                                                                                                                               ;; west
                                                                                                                                                               ((= r 3)
                                                                                                                                                                (place-city-river-w reserved-level)
                                                                                                                                                                (setf result (place-reserved-buildings-ruined-port-w reserved-level t))
                                                                                                                                                                ))
                                                                                                                                                             
                                                                                                                                                             (loop for x from 0 below (array-dimension reserved-level 0) do
                                                                                                                                                               (loop for y from 0 below (array-dimension reserved-level 1) do
                                                                                                                                                                 (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-pier+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-river+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-bridge+)
                                                                                                                                                                           (= (aref reserved-level x y 2) +building-city-land-border+))
                                                                                                                                                                   (push (list (aref reserved-level x y 2) x y 2) result))))
                                                                                                                                                             result))
                                                                                                                                                       (list +reserved-building-army-post+
                                                                                                                                                             +building-city-army-post-corrupted+
                                                                                                                                                             +reserved-building-sigil-post+
                                                                                                                                                             +building-city-corrupted-sigil-post+)))
                                                                                                            (list +level-city-border+ +terrain-border-creep+
                                                                                                                  +level-city-park+ +building-city-corrupted-park-tiny+
                                                                                                                  +level-city-floor+ +terrain-floor-creep+
                                                                                                                  +level-city-floor-bright+ +terrain-floor-creep-bright+)
                                                                                                            )))
                                                                                                                                                                     
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
                                                                 (logger (format nil "POST-PROCESSING FUNC: Demonic raid, placing portals~%"))
                                                                 (let ((portals ())
                                                                       (max-portals 6))
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
                                                                                                                                )))
                                                                                      (loop for feature-id in (feature-id-list (level world))
                                                                                            for feature = (get-feature-by-id feature-id)
                                                                                            with result = t
                                                                                            when (and (= (feature-type feature) +feature-start-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            finally (return result)))
                                                                             (push (list x y 2) portals)
                                                                             (incf cur-portal)))
                                                                   (loop for (x y z) in portals do
                                                                     ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id +feature-demonic-portal+)) x y z)
                                                                     (add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-demonic-portal+ :x x :y y :z z))))) 
                                                             post-processing-func-list)
                                                       
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +mission-sf-demonic-steal+
                                             :type +scenario-feature-mission+
                                             :name "Demonic steal (SF)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       ;; place portals
                                                       (push #'(lambda (world)
                                                                 (logger (format nil "POST-PROCESSING FUNC: Demonic steal, placing portals~%"))
                                                                 (let ((portals ())
                                                                       (max-portals 6))
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
                                                                                                                                )))
                                                                                      (loop for feature-id in (feature-id-list (level world))
                                                                                            for feature = (get-feature-by-id feature-id)
                                                                                            with result = t
                                                                                            when (and (= (feature-type feature) +feature-start-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                                                                                      (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                                                                              do
                                                                                                 (setf result nil)
                                                                                                 (loop-finish)
                                                                                            finally (return result)))
                                                                             (push (list x y 2) portals)
                                                                             (incf cur-portal)))
                                                                   (loop for (x y z) in portals do
                                                                     ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id +feature-demonic-portal+)) x y z)
                                                                     (add-feature-to-level-list (level world) (make-instance 'feature :feature-type +feature-demonic-portal+ :x x :y y :z z))))) 
                                                             post-processing-func-list)
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +mission-sf-ruined-district+
                                             :type +scenario-feature-mission+
                                             :name "Abandoned district (SF)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       ;; place blood spatters
                                                       (push #'(lambda (world)
                                                                 (logger (format nil "POST-PROCESSING FUNC: Abandoned district, placing blood~%"))
                                                                 (let ((blood ())
                                                                       (max-blood (sqrt (* (array-dimension (terrain (level world)) 0)
                                                                                           (array-dimension (terrain (level world)) 1)))))
                                                                   (loop with max-x = (- (array-dimension (terrain (level world)) 0) 2)
                                                                         with max-y = (- (array-dimension (terrain (level world)) 1) 2)
                                                                         with max-z = (- (array-dimension (terrain (level world)) 2) 2)
                                                                         with cur-blood = 0
                                                                         for x = (1+ (random max-x))
                                                                         for y = (1+ (random max-y))
                                                                         for z = (1+ (random max-z))
                                                                         while (< cur-blood max-blood) do
                                                                           (when (and (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-blocks-move+))
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-water+)))
                                                                             (if (zerop (random 2))
                                                                               (push (list x y z +feature-blood-stain+) blood)
                                                                               (push (list x y z +feature-blood-old+) blood))
                                                                             (incf cur-blood)
                                                                             (check-surroundings x y nil #'(lambda (dx dy)
                                                                                                             (when (and (get-terrain-type-trait (get-terrain-* (level world) dx dy z) +terrain-trait-opaque-floor+)
                                                                                                                        (not (get-terrain-type-trait (get-terrain-* (level world) dx dy z) +terrain-trait-water+)))
                                                                                                               (when (zerop (random 4))
                                                                                                                 (push (list dx dy z +feature-blood-old+) blood))))))
                                                                         )
                                                                   (loop for (x y z feature-type-id) in blood do
                                                                     ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id feature-type-id)) x y z)
                                                                     (add-feature-to-level-list (level world) (make-instance 'feature :feature-type feature-type-id :x x :y y :z z))))) 
                                                             post-processing-func-list)
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))

(set-scenario-feature (make-scenario-feature :id +mission-sf-irradiated-district+
                                             :type +scenario-feature-mission+
                                             :name "Irradiated district (SF)"
                                             :func #'(lambda (layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list faction-list mission-id)
                                                       (declare (ignore faction-list mission-id))
                                                       ;; place irradiated spots
                                                       (push #'(lambda (world)
                                                                 (logger (format nil "POST-PROCESSING FUNC: Irradiated district, placing irradiated spots~%"))
                                                                 (loop with max-x = (- (array-dimension (terrain (level world)) 0) 2)
                                                                       with max-y = (- (array-dimension (terrain (level world)) 1) 2)
                                                                       with max-z = (- (array-dimension (terrain (level world)) 2) 2)
                                                                       with cur-spot = 0
                                                                       with max-spots = (+ 3 (random 10))
                                                                       with func = (defun func (tx ty tz)
                                                                                     (set-terrain-* (level world) tx ty tz +terrain-floor-creep-irradiated+)
                                                                                     (check-surroundings tx ty nil #'(lambda (dx dy)
                                                                                                                     (when (= (get-terrain-* (level world) dx dy tz) +terrain-floor-creep+)
                                                                                                                       (when (zerop (random 4))
                                                                                                                         (funcall #'func dx dy tz))))))
                                                                       for x = (1+ (random max-x))
                                                                       for y = (1+ (random max-y))
                                                                       for z = (1+ (random max-z))
                                                                       while (< cur-spot max-spots) do
                                                                         (when (= (get-terrain-* (level world) x y z) +terrain-floor-creep+)
                                                                           (funcall func x y z)
                                                                           (incf cur-spot)))
                                                                 (set-terrain-* (level world) 47 47 2 +terrain-floor-creep-irradiated+)
                                                                 ) 
                                                             post-processing-func-list)
                                                                                                              
                                                       (values layout-func template-processing-func-list post-processing-func-list mob-func-list game-event-list))))
