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
                                                          (reverse func-list))))
