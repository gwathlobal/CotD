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
                                                                               (setf (relic-id level) (id item))))
                                                                func-list)
                                                          (reverse func-list))))

(set-level-modifier :id +lm-item-holy-relic+ :type +level-mod-sector-item+
                    :name "Holy Relic"
                    :priority 100
                    :template-level-gen-func #'(lambda (template-level world-sector mission world)
                                                 (declare (ignore mission world))

                                                 (logger (format nil "TEMPLATE LEVEL FUNC: Lvl Mod Relic~%"))
                                                 
                                                 (when (or (= (wtype world-sector) +world-sector-corrupted-residential+)
                                                           (= (wtype world-sector) +world-sector-corrupted-island+)
                                                           (= (wtype world-sector) +world-sector-corrupted-port+)
                                                           (= (wtype world-sector) +world-sector-corrupted-lake+)
                                                           (= (wtype world-sector) +world-sector-corrupted-forest+))
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
                                                                               (setf (relic-id level) (id item))))
                                                                func-list)
                                                          (reverse func-list))))

