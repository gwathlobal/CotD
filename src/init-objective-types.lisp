(in-package :cotd)

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-attacker+
                                                   :descr "To win, destroy all angels in the district. To lose, die."))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-defender+
                                                   :descr "To win, destroy all demons in the district. To lose, die."))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-eater+
                                                   :descr "To win, destroy all angels and demons in the district. To lose, die."))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-thief+
                                                   :descr "To win, gather at least $1500 worth of items and leave the district by moving to its border. To lose, die or get possessed."))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-ghost+
                                                   :descr "To win, find the Book of Rituals and read it while standing on a summoning circle in the satanits' lair. To lose, die."))

(set-objective-type (make-instance 'objective-type :id +objective-demon-attack-scout+
                                                   :descr "To win, destroy all demons in the district. To lose, die or get possessed."))

