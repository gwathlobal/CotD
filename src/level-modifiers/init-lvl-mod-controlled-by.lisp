(in-package :cotd)

;;---------------------------------
;; Controlled By level modifiers
;;---------------------------------

(set-level-modifier :id +lm-controlled-by-none+ :type +level-mod-controlled-by+
                    :name "Is not controlled by anyone"
                    :priority 25)

(set-level-modifier :id +lm-controlled-by-demons+ :type +level-mod-controlled-by+
                    :name "Controlled by demons"
                    :faction-list-func #'(lambda (world-sector)
                                           (declare (ignore world-sector))
                                           (list (list +faction-type-demons+ +mission-faction-present+)))
                    :priority 25
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (format t "TEMPLATE LEVEL FUNC: LM CONTROLLED BY DEMONS~%")

                                                 (let ((building-id +building-city-sigil-post+)
                                                       (x-w 4)
                                                       (y-n 4)
                                                       (x-e (- (array-dimension template-level 0) 5))
                                                       (y-s (- (array-dimension template-level 1) 5)))
                                                   ;; place nw post
                                                   (when (level-city-can-place-build-on-grid building-id x-w y-n 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-w y-n 2 template-level))
                                                     
                                                   ;; place ne post
                                                   (when (level-city-can-place-build-on-grid building-id x-e y-n 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-e y-n 2 template-level))
                                                   
                                                   ;; place sw post
                                                   (when (level-city-can-place-build-on-grid building-id x-w y-s 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-w y-s 2 template-level))
                                                     
                                                   ;; place se post
                                                   (when (level-city-can-place-build-on-grid building-id x-e y-s 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-e y-s 2 template-level))

                                                   )
                                                 )
                     :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          ;; add demonic sigils
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector world mission))

                                                                    (format t "OVERALL-POST-PROCESS-FUNC: Add demon sigils~%~%")

                                                                    (loop with sigil = nil
                                                                          for feature-id in (feature-id-list level)
                                                                          for lvl-feature = (get-feature-by-id feature-id)
                                                                          when (= (feature-type lvl-feature) +feature-start-sigil-point+)
                                                                            do
                                                                               (setf sigil (make-instance 'mob :mob-type +mob-type-demon-sigil+))
                                                                               (setf (x sigil) (x lvl-feature) (y sigil) (y lvl-feature) (z sigil) (z lvl-feature))
                                                                               (add-mob-to-level-list level sigil)
                                                                               (set-mob-effect sigil :effect-type-id +mob-effect-demonic-sigil+ :actor-id (id sigil) :cd t))
                                                                    )
                                                                func-list)
                                                          func-list))
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
                                                   (when (level-city-can-place-build-on-grid building-id x-w y-n 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-w y-n 2 template-level))
                                                     
                                                   ;; place ne post
                                                   (when (level-city-can-place-build-on-grid building-id x-e y-n 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-e y-n 2 template-level))
                                                   
                                                   ;; place sw post
                                                   (when (level-city-can-place-build-on-grid building-id x-w y-s 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-w y-s 2 template-level))
                                                     
                                                   ;; place se post
                                                   (when (level-city-can-place-build-on-grid building-id x-e y-s 2 template-level)
                                                     (level-city-reserve-build-on-grid building-id x-e y-s 2 template-level))

                                                   )
                                                 )
                    )


