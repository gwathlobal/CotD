(in-package :cotd)

(defenum:defenum world-sector-type-enum (:world-sector-test
                                         :world-sector-normal-residential
                                         :world-sector-normal-sea
                                         :world-sector-normal-island
                                         :world-sector-normal-port
                                         :world-sector-normal-lake
                                         :world-sector-normal-forest
                                         :world-sector-abandoned-residential
                                         :world-sector-abandoned-island
                                         :world-sector-abandoned-port
                                         :world-sector-abandoned-lake
                                         :world-sector-abandoned-forest
                                         :world-sector-corrupted-residential
                                         :world-sector-corrupted-island
                                         :world-sector-corrupted-port
                                         :world-sector-corrupted-lake
                                         :world-sector-corrupted-forest
                                         :world-sector-hell-plain
                                         ))

(defenum:defenum mission-type-enum (:mission-type-none
                                    :mission-type-test
                                    :mission-type-demonic-attack
                                    :mission-type-demonic-raid
                                    :mission-type-demonic-conquest
                                    :mission-type-demonic-thievery
                                    :mission-type-military-raid
                                    :mission-type-military-conquest
                                    :mission-type-celestial-purge
                                    :mission-type-celestial-retrieval
                                    :mission-type-eliminate-satanists
                                    :mission-type-celestial-sabotage
                                    :mission-type-military-sabotage))

(defenum:defenum mission-faction-presence-enum (:mission-faction-absent
                                                :mission-faction-present
                                                :mission-faction-delayed))

(defparameter *mission-types* (make-hash-table))
(defparameter *campaign-effect-types* (make-hash-table))
