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

(set-campaign-effect-type :id :campaign-effect-demon-corrupt-portals
                          :name "Divine portals corrupted"
                          :descr "The demons have invoked obscure rites on the Holy Relic to corrupt the divine portals. Whenever angels are not initiating a mission, they arrive delayed. The enchantment lasts as long as the demons control the Holy Relic."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The demons have ") sdl:*white* message-box-list)
                                             (add-message (format nil "corrupted divine portals") sdl:*yellow* message-box-list)
                                             (add-message (format nil ".~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "Divine portals") sdl:*yellow* message-box-list)
                                                (add-message (format nil " are ") sdl:*white* message-box-list)
                                                (add-message (format nil "no longer corrupted") sdl:*yellow* message-box-list)
                                                (add-message (format nil ".~%") sdl:*white* message-box-list))))

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
                                                (add-message (format nil "The demonic hierarchy ") sdl:*white* message-box-list)
                                                (add-message (format nil "has been restored") sdl:*yellow* message-box-list)
                                                (add-message (format nil ". Demons are ") sdl:*white* message-box-list)
                                                (add-message (format nil "able to raise armies") sdl:*yellow* message-box-list)
                                                (add-message (format nil " once again.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-demon-delayed
                          :name "The Barrier thickens"
                          :descr "The Barrier between the Prison Dimension and human world thickens. When the demons arrive delayed, it takes them additional 30 turns to arrive."
                          :merge-func #'(lambda (world new-effect old-effect)
                                          (setf (campaign-effect/cd old-effect) (campaign-effect/cd new-effect))
                                          (when (campaign-effect/on-add-func new-effect)
                                            (funcall (campaign-effect/on-add-func new-effect) world new-effect)))
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The priests have prayed ") sdl:*white* message-box-list)
                                             (add-message (format nil "to thicken the Barrier") sdl:*yellow* message-box-list)
                                             (add-message (format nil " between the worlds.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The effects of the prayer are over. The ") sdl:*white* message-box-list)
                                                (add-message (format nil "Barrier") sdl:*yellow* message-box-list)
                                                (add-message (format nil " can be ") sdl:*white* message-box-list)
                                                (add-message (format nil "pierced") sdl:*yellow* message-box-list)
                                                (add-message (format nil " normally again.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-demon-malseraph-blessing
                          :name "Malseraph's blessing"
                          :descr "Malseraph has focused its attention on the events at the city. From time to time it will give demons on the battlefield a modicum of power."
                          :merge-func #'(lambda (world new-effect old-effect)
                                          (setf (campaign-effect/cd old-effect) (campaign-effect/cd new-effect))
                                          (when (campaign-effect/on-add-func new-effect)
                                            (funcall (campaign-effect/on-add-func new-effect) world new-effect)))
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "Malseraph") sdl:*magenta* message-box-list)
                                             (add-message (format nil " turned its gaze to the city and ") sdl:*white* message-box-list)
                                             (add-message (format nil "granted its blessing") sdl:*white* message-box-list)
                                             (add-message (format nil " to the invading demons.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "Malseraph") sdl:*magenta* message-box-list)
                                                (add-message (format nil " has diverted its gaze from the city. Demons fighting there ") sdl:*white* message-box-list)
                                                (add-message (format nil "shall no longer have its blessing") sdl:*yellow* message-box-list)
                                                (add-message (format nil ".~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-angel-hastened
                          :name "Prayer for intervention"
                          :descr "When the angels arrive delayed, it takes them 30 turns less to arrive."
                          :merge-func #'(lambda (world new-effect old-effect)
                                          (setf (campaign-effect/cd old-effect) (campaign-effect/cd new-effect))
                                          (when (campaign-effect/on-add-func new-effect)
                                            (funcall (campaign-effect/on-add-func new-effect) world new-effect)))
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The priests have prayed ") sdl:*white* message-box-list)
                                             (add-message (format nil "for divine intervention") sdl:*yellow* message-box-list)
                                             (add-message (format nil " and their prayers were answered.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The effects of the prayer are over. The ") sdl:*white* message-box-list)
                                                (add-message (format nil "angels") sdl:*yellow* message-box-list)
                                                (add-message (format nil " shall ") sdl:*white* message-box-list)
                                                (add-message (format nil "arrive as usual") sdl:*yellow* message-box-list)
                                                (add-message (format nil " from this time on.~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-eater-agitated
                          :name "Primordials agitated"
                          :descr "The Primordials are awakening from their slumber. Whenever eaters of the dead are present in a mission, they are present en mass."
                          :merge-func #'(lambda (world new-effect old-effect)
                                          (setf (campaign-effect/cd old-effect) (campaign-effect/cd new-effect))
                                          (when (campaign-effect/on-add-func new-effect)
                                            (funcall (campaign-effect/on-add-func new-effect) world new-effect)))
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The ") sdl:*white* message-box-list)
                                             (add-message (format nil "primordials") sdl:*yellow* message-box-list)
                                             (add-message (format nil " are ") sdl:*white* message-box-list)
                                             (add-message (format nil "awakening") sdl:*yellow* message-box-list)
                                             (add-message (format nil " from their slumber.~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "The ") sdl:*white* message-box-list)
                                                (add-message (format nil "primordials") sdl:*yellow* message-box-list)
                                                (add-message (format nil " are falling into ") sdl:*white* message-box-list)
                                                (add-message (format nil "a sleep") sdl:*yellow* message-box-list)
                                                (add-message (format nil ".~%") sdl:*white* message-box-list))))

(set-campaign-effect-type :id :campaign-effect-angel-crusade
                          :name "Divine crusade"
                          :descr "The angels have declared a divine crusade and are able to initiate 1 more mission for the duration of this effect."
                          :merge-func nil
                          :on-add-func #'(lambda (world campaign-effect)
                                           (declare (ignore campaign-effect))
                                           (let ((message-box-list `(,(world/effect-message-box world))))
                                             (add-message (format nil "The angels have ") sdl:*white* message-box-list)
                                             (add-message (format nil "declared divine crusade") sdl:*yellow* message-box-list)
                                             (add-message (format nil ".~%") sdl:*white* message-box-list)))
                          :on-remove-func #'(lambda (world campaign-effect)
                                              (declare (ignore campaign-effect))
                                              (let ((message-box-list `(,(world/effect-message-box world))))
                                                (add-message (format nil "Divine crusade") sdl:*yellow* message-box-list)
                                                (add-message (format nil " has ") sdl:*white* message-box-list)
                                                (add-message (format nil "ended") sdl:*yellow* message-box-list)
                                                (add-message (format nil ".~%") sdl:*white* message-box-list))))
