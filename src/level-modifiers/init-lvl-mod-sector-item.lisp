(in-package :cotd)

;;---------------------------------
;; Sector Item level modifiers
;;---------------------------------

(set-level-modifier :id +lm-item-book-of-rituals+ :type +level-mod-sector-item+
                    :name "Book of Rituals"
                    :priority 100
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))
                                                                    (loop with item = nil
                                                                          for feature-id in (feature-id-list level)
                                                                          for lvl-feature = (get-feature-by-id feature-id)
                                                                          when (= (feature-type lvl-feature) +feature-start-place-book-of-rituals+)
                                                                            do
                                                                               (setf item (make-instance 'item :item-type +item-type-book-of-rituals+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature))) 
                                                                               (add-item-to-level-list level item)
                                                                               (setf (level/book-id level) (id item))))
                                                                func-list)
                                                          (reverse func-list)))
                    :depends-on-lvl-mod-func #'(lambda (world-sector mission-type-id world-time)
                                                 (declare (ignore world-sector mission-type-id world-time))
                                                 (list +lm-feat-library+))
                    )

(set-level-modifier :id +lm-item-holy-relic+ :type +level-mod-sector-item+
                    :name "Holy Relic"
                    :priority 100
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: Lvl Mod Relic~%"))
                                                 
                                                 (when (or (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                           (eq (wtype world-sector) :world-sector-corrupted-island)
                                                           (eq (wtype world-sector) :world-sector-corrupted-port)
                                                           (eq (wtype world-sector) :world-sector-corrupted-lake)
                                                           (eq (wtype world-sector) :world-sector-corrupted-forest))
                                                   (logger (format nil "   TEMPLATE LEVEL FUNC: Lvl Mod Relic in Corrupted District~%"))
                                                 
                                                   (loop with shrine-types = (prepare-spec-build-id-list +building-type-corrupted-shrine+)
                                                         for x = (random (array-dimension template-level 0))
                                                         for y = (random (array-dimension template-level 1))
                                                         for selected-shrine-type = (nth (random (length shrine-types)) shrine-types)
                                                         until (level-city-can-place-build-on-grid selected-shrine-type x y 2 template-level)
                                                         finally
                                                            (level-city-reserve-build-on-grid selected-shrine-type x y 2 template-level))
                                                   ))
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))
                                                                    (loop with item = nil
                                                                          for feature-id in (feature-id-list level)
                                                                          for lvl-feature = (get-feature-by-id feature-id)
                                                                          when (= (feature-type lvl-feature) +feature-start-place-relic+)
                                                                            do
                                                                               (setf item (make-instance 'item :item-type +item-type-church-reliс+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature))) 
                                                                               (add-item-to-level-list level item)
                                                                               (setf (level/relic-id level) (id item))))
                                                                func-list)
                                                          (reverse func-list)))
                    :depends-on-lvl-mod-func #'(lambda (world-sector mission-type-id world-time)
                                                 (declare (ignore mission-type-id world-time))
                                                 (if (not (or (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                              (eq (wtype world-sector) :world-sector-corrupted-island)
                                                              (eq (wtype world-sector) :world-sector-corrupted-port)
                                                              (eq (wtype world-sector) :world-sector-corrupted-lake)
                                                              (eq (wtype world-sector) :world-sector-corrupted-forest)))
                                                   (list +lm-feat-church+)
                                                   nil))
                    :always-present-func #'(lambda (world-sector mission world-time)
                                             (declare (ignore world-sector world-time))
                                             (if (or (eq (mission-type-id mission) :mission-type-demonic-thievery)
                                                     (eq (mission-type-id mission) :mission-type-celestial-retrieval))
                                               t
                                               nil)))

