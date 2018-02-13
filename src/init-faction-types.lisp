(in-package :cotd)

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
                                               :scenario-faction-list (list +player-faction-angels+ +player-faction-trinity-mimics+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-demons+
                                               :name "Demons"
                                               :faction-relations (list (cons +faction-type-demons+ t) (cons +faction-type-satanists+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil))
                                               :scenario-faction-list (list +player-faction-demons+ +player-faction-shadows+ +player-faction-puppet+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-military+
                                               :name "Military"
                                               :faction-relations (list (cons +faction-type-military+ t) (cons +faction-type-civilians+ t) (cons +faction-type-animals+ t) (cons +faction-type-church+ t)
                                                                        (cons +faction-type-demons+ nil) (cons +faction-type-angels+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil)
                                                                        (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))
                                               :scenario-faction-list (list +player-faction-military-chaplain+ +player-faction-military-scout+)))

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
                                               :scenario-faction-list (list +player-faction-thief+)))

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
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))))

(set-faction-type (make-instance 'faction-type :id +faction-type-ghost+
                                               :name "Ghost"
                                               :faction-relations (list (cons +faction-type-ghost+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-animals+ nil)
                                                                        (cons +faction-type-civilians+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil)
                                                                        (cons +faction-type-criminals+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))
                                               :scenario-faction-list (list +player-faction-eater+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-ghost+
                                               :name "Ghost"
                                               :faction-relations (list (cons +faction-type-ghost+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil) (cons +faction-type-animals+ nil)
                                                                        (cons +faction-type-civilians+ nil) (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-military+ nil) (cons +faction-type-demons+ nil)
                                                                        (cons +faction-type-criminals+ nil) (cons +faction-type-church+ nil) (cons +faction-type-satanists+ nil))
                                               :scenario-faction-list (list +player-faction-ghost+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-church+
                                               :name "Church"
                                               :faction-relations (list (cons +faction-type-church+ t) (cons +faction-type-civilians+ t) (cons +faction-type-angels+ t) (cons +faction-type-animals+ t) (cons +faction-type-military+ t)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-demons+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil)
                                                                        (cons +faction-type-eater+ nil) (cons +faction-type-ghost+ nil) (cons +faction-type-satanists+ nil))
                                               :scenario-faction-list (list +player-faction-church+)))

(set-faction-type (make-instance 'faction-type :id +faction-type-satanists+
                                               :name "Satanists"
                                               :faction-relations (list (cons +faction-type-satanists+ t) (cons +faction-type-demons+ t)
                                                                        (cons +faction-type-angels+ nil) (cons +faction-type-civilians+ nil) (cons +faction-type-animals+ nil) (cons +faction-type-military+ nil)
                                                                        (cons +faction-type-outsider-beasts+ nil) (cons +faction-type-criminals+ nil) (cons +faction-type-outsider-wisps+ nil) (cons +faction-type-eater+ nil)
                                                                        (cons +faction-type-ghost+ nil) (cons +faction-type-church+ nil))
                                               :scenario-faction-list (list +player-faction-satanist+)))
