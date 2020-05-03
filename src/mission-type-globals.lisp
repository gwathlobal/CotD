(in-package :cotd)

(defenum:defenum mission-type-enum (:mission-type-none
                                    :mission-type-test
                                    :mission-type-demonic-attack
                                    :mission-type-demonic-raid
                                    :mission-type-demonic-conquest
                                    :mission-type-demonic-thievery
                                    :mission-type-military-raid
                                    :mission-type-military-conquest
                                    :mission-type-celestial-purge
                                    :mission-type-celestial-retrieval))

(defenum:defenum mission-faction-presence-enum (:mission-faction-absent
                                                :mission-faction-present
                                                :mission-faction-delayed))
