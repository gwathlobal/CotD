(in-package :cotd)

(set-level-modifier :id +lm-placement-player+ :type +level-mod-player-placement+
                    :name "Player"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))

                                                                    (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                    (find-unoccupied-place-outside level *player*)
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-dead-player+ :type +level-mod-player-placement+
                    :name "Dead player"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))

                                                                    (setf *player* (make-instance 'player :mob-type +mob-type-player+))
                                                                    (find-unoccupied-place-outside level *player*)
                                                                    (setf (cur-hp *player*) 0)
                                                                    (make-dead *player* :corpse nil)
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-angel-chrome+ :type +level-mod-player-placement+
                    :name "Celestial Communion (as Chrome angel)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-angels-on-level level world-sector mission world (list (list +mob-type-angel+ 1 t)))
                                                                    (setf (faction-name *player*) "Chrome Angel")
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-angel-trinity+ :type +level-mod-player-placement+
                    :name "Celestial Communion (as Trinity mimics)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-angels-on-level level world-sector mission world (list (list +mob-type-star-singer+ 1 t)))
                                                                    (setf (faction-name *player*) "Trinity mimic")
                                                                    
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-demon-crimson+ :type +level-mod-player-placement+
                    :name "Pandemonium Hierarchy (as Crimson imp)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-demons-on-level level world-sector mission world (list (list +mob-type-imp+ 1 t)))
                                                                    (setf (faction-name *player*) "Crimson Imp")
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-demon-shadow+ :type +level-mod-player-placement+
                    :name "Pandemonium Hierarchy (as Shadow imp)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-demons-on-level level world-sector mission world (list (list +mob-type-shadow-imp+ 1 t)))
                                                                    (setf (faction-name *player*) "Shadow Imp")
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-demon-malseraph+ :type +level-mod-player-placement+
                    :name "Pandemonium Hierarchy (as Malseraph's puppet)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-demons-on-level level world-sector mission world (list (list +mob-type-malseraph-puppet+ 1 t)))
                                                                    (setf (faction-name *player*) "Malseraph's puppet")
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-military-chaplain+ :type +level-mod-player-placement+
                    :name "Military (as Chaplain)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-military-on-level level world-sector mission world
                                                                                             (list (list (list +mob-type-chaplain+ 1 t)
                                                                                                         (list +mob-type-sergeant+ 1 nil)
                                                                                                         (list +mob-type-scout+ 1 nil)
                                                                                                         (list +mob-type-soldier+ 3 nil)
                                                                                                         (list +mob-type-gunner+ 1 nil)))
                                                                                             t)
                                                                    (setf (faction-name *player*) "Military Chaplain")
                                                                    )
                                                                func-list)
                                                          func-list)))

(set-level-modifier :id +lm-placement-military-scout+ :type +level-mod-player-placement+
                    :name "Military (as Scout)"
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))

                                                          (push #'(lambda (level world-sector mission world)
                                                                    
                                                                    (place-military-on-level level world-sector mission world
                                                                                             (list (list (list +mob-type-scout+ 1 t)))
                                                                                             nil)
                                                                    (setf (faction-name *player*) "Military Chaplain")

                                                                    )
                                                                func-list)
                                                          func-list)))
