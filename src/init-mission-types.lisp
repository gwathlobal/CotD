(in-package :cotd)

;;----------------------------------------
;; MISSION-DISTRICTS
;;----------------------------------------

(set-mission-district (make-instance 'mission-district :id +city-layout-normal+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-forest+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-port+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-island+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-river+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

(set-mission-district (make-instance 'mission-district :id +city-layout-barricaded-city+
                                                       :faction-list (list (list +faction-type-civilians+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-present+)
                                                                           (list +faction-type-church+ +mission-faction-absent+)
                                                                           (list +faction-type-satanists+ +mission-faction-present+)
                                                                           (list +faction-type-satanists+ +mission-faction-absent+)
                                                                           (list +faction-type-eater+ +mission-faction-present+)
                                                                           (list +faction-type-eater+ +mission-faction-absent+)
                                                                           (list +faction-type-criminals+ +mission-faction-present+)
                                                                           (list +faction-type-criminals+ +mission-faction-absent+)
                                                                           (list +faction-type-ghost+ +mission-faction-present+)
                                                                           (list +faction-type-ghost+ +mission-faction-absent+))))

;;----------------------------------------
;; MISSION-SCENARIOS
;;----------------------------------------

(set-mission-scenario (make-instance 'mission-scenario :id +mission-scenario-demon-attack+
                                                       :name "Demonic attack"
                                                       :district-layout-list (list +city-layout-normal+ +city-layout-forest+ +city-layout-port+ +city-layout-island+ +city-layout-river+ +city-layout-barricaded-city+)
                                                       :faction-list (list (list +faction-type-demons+ +mission-faction-attacker+)
                                                                           (list +faction-type-military+ +mission-faction-defender+)
                                                                           (list +faction-type-military+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-defender+)
                                                                           (list +faction-type-angels+ +mission-faction-delayed+)
                                                                           (list +faction-type-angels+ +mission-faction-absent+)
                                                                           (list +faction-type-church+ +mission-faction-defender+)
                                                                           (list +faction-type-satanists+ +mission-faction-attacker+)
                                                                           (list +faction-type-eater+ +mission-faction-attacker+)
                                                                           (list +faction-type-criminals+ +mission-faction-defender+)
                                                                           (list +faction-type-ghost+ +mission-faction-defender+)
                                                                           )
                                                       ))
