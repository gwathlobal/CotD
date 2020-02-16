(in-package :cotd)

;;---------------------------------
;; Sector Feat level modifiers
;;---------------------------------


(set-level-modifier :id +lm-feat-river+ :type +level-mod-sector-feat+
                    :name "River")

(set-level-modifier :id +lm-feat-sea+ :type +level-mod-sector-feat+
                    :name "Sea")

(set-level-modifier :id +lm-feat-barricade+ :type +level-mod-sector-feat+
                    :name "Barricade")

(set-level-modifier :id +lm-feat-library+ :type +level-mod-sector-feat+
                    :name "Library")

(set-level-modifier :id +lm-feat-church+ :type +level-mod-sector-feat+
                    :name "Church"
                    :faction-list-func #'(lambda (world-sector)
                                           (if (or (= (wtype world-sector) +world-sector-normal-residential+)
                                                   (= (wtype world-sector) +world-sector-normal-sea+)
                                                   (= (wtype world-sector) +world-sector-normal-island+)
                                                   (= (wtype world-sector) +world-sector-normal-port+)
                                                   (= (wtype world-sector) +world-sector-normal-lake+)
                                                   (= (wtype world-sector) +world-sector-normal-forest+))
                                             (list (list +faction-type-church+ +mission-faction-present+))
                                             nil)
                                           )
                    )

(set-level-modifier :id +lm-feat-lair+ :type +level-mod-sector-feat+
                    :name "Satanists' lair"
                    :faction-list-func #'(lambda (world-sector)
                                           (declare (ignore world-sector))
                                           (list (list +faction-type-satanists+ +mission-faction-present+)))
                    )
