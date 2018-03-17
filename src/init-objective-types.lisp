(in-package :cotd)

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-attacker+
                                                   :descr "To win, destroy all angels in the district. To lose, have all demons killed."
                                                   :ai-package-id +ai-package-patrol-district+))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-defender+
                                                   :descr "To win, destroy all demons in the district. To lose, have all angels killed."
                                                   :ai-package-id +ai-package-patrol-district+))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-eater+
                                                   :descr "To win, destroy all angels and demons in the district. To lose, die."
                                                   :ai-package-id +ai-package-patrol-district+))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-thief+
                                                   :descr "To win, gather at least $1500 worth of items and leave the district by moving to its border. To lose, die or get possessed."
                                                   :ai-package-id +ai-package-patrol-district+))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-ghost+
                                                   :descr "To win, find the Book of Rituals in the library and read it while standing on a summoning circle in the satanists' lair. To lose, die."
                                                   :ai-package-id +ai-package-patrol-district+))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-scout+
                                                   :descr "To win, destroy all demons in the district. To lose, die or get possessed."
                                                   :ai-package-id +ai-package-patrol-district+))

