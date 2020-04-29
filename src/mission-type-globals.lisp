(in-package :cotd)

(defconstant +mission-type-none+ -1)
(defconstant +mission-type-test+ 0)
(defconstant +mission-type-demonic-attack+ 1)
(defconstant +mission-type-demonic-raid+ 2)
(defconstant +mission-type-demonic-conquest+ 3)
(defconstant +mission-type-demonic-thievery+ 4)
(defconstant +mission-type-military-raid+ 5)
(defconstant +mission-type-military-conquest+ 6)
(defconstant +mission-type-celestial-purge+ 7)
(defconstant +mission-type-celestial-retrieval+ 8)

(defenum:defenum mission-type-enum (:mission-type-none
                                    :mission-type-test
                                    :mission-type-demonic-attack
                                    :mission-type-demonic-raid
                                    :mission-type-demonic-conquest
                                    :mission-type-demonic-theivery
                                    :mission-type-military-raid
                                    :mission-type-military-conquest
                                    :mission-type-celestial-purge
                                    :mission-type-celestial-retrieval))

(defenum:defenum mission-faction-presence-enum (:mission-faction-absent
                                                :mission-faction-present
                                                :mission-faction-delayed))
