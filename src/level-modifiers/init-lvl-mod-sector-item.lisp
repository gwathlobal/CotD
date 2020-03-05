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
                    :name "relic"
                    :priority 100
                    :overall-post-process-func-list #'(lambda ()
                                                        (let ((func-list ()))
                                                          (push #'(lambda (level world-sector mission world)
                                                                    (declare (ignore world-sector mission world))
                                                                    (loop with item = nil
                                                                          for feature-id in (feature-id-list level)
                                                                          for lvl-feature = (get-feature-by-id feature-id)
                                                                          when (= (feature-type lvl-feature) +feature-start-place-church-relic+)
                                                                            do
                                                                               (setf item (make-instance 'item :item-type +item-type-church-reliс+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature))) 
                                                                               (add-item-to-level-list level item)
                                                                               (setf (relic-id level) (id item))))
                                                                func-list)
                                                          (reverse func-list))))

