(in-package :cotd)

(set-campaign-effect-type :id :campaign-effect-satanist-lair-visible
                          :name "Satanits' lair revealed"
                          :descr "The satanist lair is infiltrated and vulnerable to attack."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/sitrep-message-box world))))
                                             (add-message (format nil "The agents of the powers that be have ") sdl:*white* message-box-list)
                                             (add-message (format nil "inflitrated the satanists") sdl:*yellow* message-box-list)
                                             (add-message (format nil " and made their lair vulnerable for attack.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/sitrep-message-box world))))
                                                (add-message (format nil "The satanists managed to ") sdl:*white* message-box-list)
                                                (add-message (format nil "exposed the agents") sdl:*yellow* message-box-list)
                                                (add-message (format nil " who have infiltrated them and are now able lay low.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-satanist-sacrifice
                          :name "Citizen sacrificed"
                          :descr "The satanists have sacrificed a citizen of the City and opened the gates of Hell giving demons more opportunities to invade Earth."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/sitrep-message-box world))))
                                             (add-message (format nil "The satanists have made a ") sdl:*white* message-box-list)
                                             (add-message (format nil "blood sacrifice") sdl:*yellow* message-box-list)
                                             (add-message (format nil " and opened the gates of Hell wider giving demons more opportunities to invade Earth.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/sitrep-message-box world))))
                                                (add-message (format nil "The ") sdl:*white* message-box-list)
                                                (add-message (format nil "crack of between worlds has closed") sdl:*yellow* message-box-list)
                                                (add-message (format nil " and the forces of Hell now have less opportunities to invade Earth.~%") sdl:*white* message-box-list))))
