(in-package :cotd)

(set-city-type (make-city-type :id +city-type-random+))

(set-city-type (make-city-type :id +city-type-normal-summer+
                               :return-max-buildings #'(lambda ()
                                                         (let ((max-building-types (make-hash-table)))
                                                           (setf (gethash +building-type-church+ max-building-types) 1)
                                                           (setf (gethash +building-type-satanists+ max-building-types) 1)
                                                           (setf (gethash +building-type-warehouse+ max-building-types) 1)
                                                           (setf (gethash +building-type-library+ max-building-types) 1)
                                                           (setf (gethash +building-type-prison+ max-building-types) 1)
                                                           (setf (gethash +building-type-lake+ max-building-types) 4)
                                                           max-building-types))
                               :return-reserv-buildings #'(lambda ()
                                                            (let ((reserved-building-types (make-hash-table)))
                                                              (setf (gethash +building-type-church+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-satanists+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-library+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-prison+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-lake+ reserved-building-types) 2)
                                                              reserved-building-types))))

(set-city-type (make-city-type :id +city-type-normal-winter+
                               :return-max-buildings #'(lambda ()
                                                         (let ((max-building-types (make-hash-table)))
                                                           (setf (gethash +building-type-church+ max-building-types) 1)
                                                           (setf (gethash +building-type-satanists+ max-building-types) 1)
                                                           (setf (gethash +building-type-warehouse+ max-building-types) 1)
                                                           (setf (gethash +building-type-library+ max-building-types) 1)
                                                           (setf (gethash +building-type-prison+ max-building-types) 1)
                                                           (setf (gethash +building-type-lake+ max-building-types) 4)
                                                           max-building-types))
                               :return-reserv-buildings #'(lambda ()
                                                            (let ((reserved-building-types (make-hash-table)))
                                                              (setf (gethash +building-type-church+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-satanists+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-library+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-prison+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-lake+ reserved-building-types) 2)
                                                              reserved-building-types))
                               :post-processing-func #'(lambda (template-level)
                                                         (loop for x from 0 below (array-dimension template-level 0) do
                                                           (loop for y from 0 below (array-dimension template-level 1) do
                                                             (cond
                                                               ((= (aref template-level x y) +terrain-border-floor+) (setf (aref template-level x y) +terrain-border-floor-snow+))
                                                               ((= (aref template-level x y) +terrain-floor-dirt+) (setf (aref template-level x y) +terrain-floor-snow+))
                                                               ((= (aref template-level x y) +terrain-floor-dirt-bright+) (setf (aref template-level x y) +terrain-floor-snow+))
                                                               ((= (aref template-level x y) +terrain-floor-grass+) (setf (aref template-level x y) +terrain-floor-snow+))
                                                               ((= (aref template-level x y) +terrain-tree-birch+) (setf (aref template-level x y) +terrain-tree-birch-snow+))
                                                               ((= (aref template-level x y) +terrain-water-lake+) (setf (aref template-level x y) +terrain-water-ice+)))))
                                                         template-level)))
                                                               
                                                               
