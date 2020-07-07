(in-package :cotd)

(set-campaign-effect-type :id :campaign-effect-satanist-lair-visible
                          :name "Satanits' lair revealed"
                          :descr "The satanist lair is infiltrated and vulnerable to attack."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The agents of the powers that be have ") sdl:*white* message-box-list)
                                             (add-message (format nil "inflitrated the satanists") sdl:*yellow* message-box-list)
                                             (add-message (format nil " and made their lair vulnerable for attack.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The satanists managed to ") sdl:*white* message-box-list)
                                                (add-message (format nil "expose the agents") sdl:*yellow* message-box-list)
                                                (add-message (format nil " who have infiltrated them and are now able lay low.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-satanist-sacrifice
                          :name "Citizen sacrificed"
                          :descr "The satanists have sacrificed a citizen of the City and opened the gates of Hell giving demons more opportunities to invade Earth."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The satanists have made a ") sdl:*white* message-box-list)
                                             (add-message (format nil "blood sacrifice") sdl:*yellow* message-box-list)
                                             (add-message (format nil " and opened the gates of Hell wider giving demons more opportunities to invade Earth.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The ") sdl:*white* message-box-list)
                                                (add-message (format nil "crack of between worlds has closed") sdl:*yellow* message-box-list)
                                                (add-message (format nil " and the forces of Hell now have less opportunities to invade Earth.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-satanist-lair-hidden
                          :name "Satanits' lair hidden"
                          :descr "The satanists have taken great precautions to make the lair hidden and secure."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The satanists ") sdl:*white* message-box-list)
                                             (add-message (format nil "have hidden their lair") sdl:*yellow* message-box-list)
                                             (add-message (format nil " to make it impossible to find them.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The satanists ") sdl:*white* message-box-list)
                                                (add-message (format nil "have relaxed their security") sdl:*yellow* message-box-list)
                                                (add-message (format nil " and it is now possible to infiltrate it.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-demon-protect-dimension
                          :name "Protect Prison Dimension"
                          :descr "The demons have invoked obscure rites from the Book of Rituals to prevent anybody from entering their dimension. The enchantment lasts as long as the demons control the Book of Rituals."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The demons ") sdl:*white* message-box-list)
                                             (add-message (format nil "have protected their dimension") sdl:*yellow* message-box-list)
                                             (add-message (format nil " against entrance.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The ") sdl:*white* message-box-list)
                                                (add-message (format nil "Prison Dimension") sdl:*yellow* message-box-list)
                                                (add-message (format nil " is now available for ") sdl:*white* message-box-list)
                                                (add-message (format nil "entry") sdl:*yellow* message-box-list)
                                                (add-message (format nil " again.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-demon-turmoil
                          :name "Turmoil in Hell"
                          :descr "A recent successful strike inside the demonic realm has caused turmoil in Hell. The demons are not able to raise armies until order is restored."
                          :merge-func #'(lambda (world new-effect old-effect)
                                          (setf (campaign-effect/cd old-effect) (campaign-effect/cd new-effect))
                                          (when (campaign-effect/on-add-func new-effect)
                                            (funcall (campaign-effect/on-add-func new-effect) world new-effect)))
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The demonic hierarchy ") sdl:*white* message-box-list)
                                             (add-message (format nil "has been disrupted") sdl:*yellow* message-box-list)
                                             (add-message (format nil ". Demons shall ") sdl:*white* message-box-list)
                                             (add-message (format nil "not be able to raise armies") sdl:*yellow* message-box-list)
                                             (add-message (format nil " for a while.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The demonic hierarchy") sdl:*white* message-box-list)
                                                (add-message (format nil "has been restored") sdl:*yellow* message-box-list)
                                                (add-message (format nil ". Demons are ") sdl:*white* message-box-list)
                                                (add-message (format nil "able to raise armies") sdl:*yellow* message-box-list)
                                                (add-message (format nil " once again.~%") sdl:*white* message-box-list))))
