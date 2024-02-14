(in-package :cotd-sdl)

;;--------------------
;; Faction Types
;;--------------------

(set-faction-type (make-instance 'faction-type :id +faction-type-civilians+
                                               :name "Civilians"
                                               :faction-relations (list (cons +faction-type-civilians+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t) (cons +faction-type-military+ t) (cons +faction-type-church+ t)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil)
                                                                        (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))))

(set-faction-type (make-instance 'faction-type :id +faction-type-angels+
                                               :name "Angels"
                                               :faction-relations (list (cons +faction-type-angels+ t) (cons +faction-type-civilians+ t) (cons +faction-type-animals+ t) (cons +faction-type-criminals+ t) (cons +faction-type-church+ t)
                                                                        (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-wisps+ t)
                                                                        (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-angel-chrome+ +specific-faction-type-angel-trinity+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-demons+
                                               :name "Demons"
                                               :faction-relations (list (cons +faction-type-demons+ t) (cons +faction-type-satanists+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil))
                                               :specific-faction-list (list +specific-faction-type-demon-crimson+ +specific-faction-type-demon-shadow+ +specific-faction-type-demon-malseraph+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-military+
                                               :name "Military"
                                               :faction-relations (list (cons +faction-type-military+ t) (cons +faction-type-civilians+ t) (cons +faction-type-animals+ t) (cons +faction-type-church+ t)
                                                                        (cons +faction-type-demons+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil)
                                                                        (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-military-chaplain+ +specific-faction-type-military-scout+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-animals+
                                               :name "Animals"
                                               :faction-relations (list (cons +faction-type-animals+ t) (cons +faction-type-civilians+ t) (cons +faction-type-angels+ t) (cons +faction-type-military+ t)
                                                                        (cons +faction-type-criminals+ t) (cons +faction-type-church+ t)
                                                                        (cons +faction-type-demons+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))))

(set-faction-type (make-instance 'faction-type :id +faction-type-outsider-beasts+
                                               :name "Outsider beasts"
                                               :faction-relations (list (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-angels+ nil)
                                                                        (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil)
                                                                        (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))))

(set-faction-type (make-instance 'faction-type :id +faction-type-criminals+
                                               :name "Criminals"
                                               :faction-relations (list (cons +faction-type-criminals+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t)
                                                                        (cons +faction-type-civilians+ nil) (cons +faction-type-military+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil)
                                                                        (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil)
                                                                        (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-thief+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-outsider-wisps+
                                               :name "Wisps"
                                               :faction-relations (list (cons +faction-type-angels+ t) (cons +faction-type-outsider-wisps+ t)
                                                                        (cons +faction-type-animals+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil)
                                                                        (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil)
                                                                        (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))))

(set-faction-type (make-instance 'faction-type :id +faction-type-eater+
                                               :name "Eater of the dead"
                                               :faction-relations (list (cons +faction-type-eater+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-civilians+ nil)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-eater+ +specific-faction-type-skinchanger+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-ghost+
                                               :name "Ghost"
                                               :faction-relations (list (cons +faction-type-ghost+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-animals+ nil)
                                                                        (cons +faction-type-civilians+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil)
                                                                        (cons +faction-type-criminals+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-ghost+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-church+
                                               :name "Church"
                                               :faction-relations (list (cons +faction-type-church+ t) (cons +faction-type-civilians+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t) (cons +faction-type-military+ t)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil)
                                                                        (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))
                                               :specific-faction-list (list +specific-faction-type-priest+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-satanists+
                                               :name "Satanists"
                                               :faction-relations (list (cons +faction-type-satanists+ t) (cons +faction-type-demons+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil))
                                               :specific-faction-list (list +specific-faction-type-satanist+)))

;;-------------------------
;; Specific Faction Names
;;-------------------------

(set-specific-faction-name +specific-faction-type-dead-player+ "Dead Player")
(set-specific-faction-name +specific-faction-type-test+ "Test Player")
(set-specific-faction-name +specific-faction-type-player+ "Player")
(set-specific-faction-name +specific-faction-type-angel-chrome+ "Chrome angel")
(set-specific-faction-name +specific-faction-type-angel-trinity+ "Trinity mimic")
(set-specific-faction-name +specific-faction-type-demon-crimson+ "Crimson demon")
(set-specific-faction-name +specific-faction-type-demon-shadow+ "Shadow demon")
(set-specific-faction-name +specific-faction-type-demon-malseraph+ "Malseraph's puppet")
(set-specific-faction-name +specific-faction-type-military-chaplain+ "Military chaplain")
(set-specific-faction-name +specific-faction-type-military-scout+ "Military scout")
(set-specific-faction-name +specific-faction-type-thief+ "Thief")
(set-specific-faction-name +specific-faction-type-satanist+ "Satanist")
(set-specific-faction-name +specific-faction-type-priest+ "Priest")
(set-specific-faction-name +specific-faction-type-eater+ "Eater of the dead")
(set-specific-faction-name +specific-faction-type-ghost+ "Lost soul")
(set-specific-faction-name +specific-faction-type-skinchanger+ "Skinchanger")
