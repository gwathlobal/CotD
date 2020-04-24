(in-package :cotd)

;;---------------------------------
;; Controlled By level modifiers
;;---------------------------------

(set-level-modifier :id +lm-controlled-by-none+ :type +level-mod-controlled-by+
                    :name "Uncontrolled"
                    :priority 25)

(set-level-modifier :id +lm-controlled-by-demons+ :type +level-mod-controlled-by+
                    :name "Controlled by demons"
                    :faction-list-func #'(lambda (world-sector)
                                           (declare (ignore world-sector))
                                           (list (list +faction-type-demons+ +mission-faction-present+)))
                    :priority 25
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          ;; add starting points for demons
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector world mission))
                                                                    
                                                                    (logger (format nil "OVERALL-POST-PROCESS-FUNC: Add starting points for demons~%~%"))

                                                                    (loop repeat 50
                                                                          do
                                                                          (loop with max-x = (array-dimension (terrain level) 0)
                                                                                with max-y = (array-dimension (terrain level) 1)
                                                                                for x = (random max-x)
                                                                                for y = (random max-y)
                                                                                for z = 2
                                                                                until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                                                                                           (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+))
                                                                                           (not (get-mob-* level x y z))
                                                                                           (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+)
                                                                                           (/= (get-level-connect-map-value level x y z 1 +connect-map-move-walk+)
                                                                                               +connect-room-none+)
                                                                                           (loop for feature-id in (feature-id-list level)
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
                                                                                                 when (and (get-feature-type-trait feature +feature-trait-remove-on-dungeon-generation+)
                                                                                                           (< (get-distance x y (x feature) (y feature)) 2))
                                                                                                   do
                                                                                                      (setf result nil)
                                                                                                      (loop-finish)
                                                                                                 finally (return result)))
                                                                                finally (add-feature-to-level-list level (make-instance 'feature :feature-type +feature-start-place-demons+ :x x :y y :z z))
                                                                                        ))
                                                                    
                                                                    
                                                                    )
                                                                func-list)
                                                          
                                                          func-list))
                    :is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                  (declare (ignore world-sector world-time))
                                                  ;; is not available for missions where demons attack
                                                  (if (or (= mission-type-id +mission-type-demonic-attack+)
                                                          (= mission-type-id +mission-type-demonic-raid+))
                                                    nil
                                                    t))
                    )

(set-level-modifier :id +lm-controlled-by-military+ :type +level-mod-controlled-by+
                    :name "Controlled by the military"
                    :faction-list-func #'(lambda (world-sector)
                                           (declare (ignore world-sector))
                                           (list (list +faction-type-military+ +mission-faction-present+)))
                    :priority 25
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore world-sector mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM CONTROLLED BY MILITARY~%")

                                                 (let ((building-id +building-city-army-post+)
                                                       (x-w 4)
                                                       (y-n 4)
                                                       (x-e (- (array-dimension template-level 0) 5))
                                                       (y-s (- (array-dimension template-level 1) 5)))
                                                   ;; place nw post
                                                   (level-city-reserve-build-on-grid building-id x-w y-n 2 template-level)
                                                   
                                                   ;; place ne post
                                                   (level-city-reserve-build-on-grid building-id x-e y-n 2 template-level)
                                                   
                                                   ;; place sw post
                                                   (level-city-reserve-build-on-grid building-id x-w y-s 2 template-level)
                                                   
                                                   ;; place se post
                                                   (level-city-reserve-build-on-grid building-id x-e y-s 2 template-level)
                                                   )
                                                 )
                    :is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                  (declare (ignore world-sector world-time))
                                                  ;; is not available for missions where military attack
                                                  (if (or (= mission-type-id +mission-type-military-conquest+))
                                                    nil
                                                    t))
                    )


