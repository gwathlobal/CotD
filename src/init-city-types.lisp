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

(set-city-type (make-city-type :id +city-type-river-summer+
                               :return-max-buildings #'(lambda ()
                                                         (let ((max-building-types (make-hash-table)))
                                                           (setf (gethash +building-type-church+ max-building-types) 1)
                                                           (setf (gethash +building-type-satanists+ max-building-types) 1)
                                                           (setf (gethash +building-type-warehouse+ max-building-types) 1)
                                                           (setf (gethash +building-type-library+ max-building-types) 1)
                                                           (setf (gethash +building-type-prison+ max-building-types) 1)
                                                           (setf (gethash +building-type-lake+ max-building-types) 0)
                                                           max-building-types))
                               :return-reserv-buildings #'(lambda ()
                                                            (let ((reserved-building-types (make-hash-table)))
                                                              (setf (gethash +building-type-church+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-satanists+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-library+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-prison+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-lake+ reserved-building-types) 0)
                                                              reserved-building-types))
                               :process-reserve-func #'(lambda (reserved-level)
                                                         (let ((result) (r) (n nil) (s nil) (w nil) (e nil))
                                                           (setf r (random 11))
                                                           (cond
                                                             ((= r 0) (setf w t e t))           ;; 0 - we
                                                             ((= r 1) (setf n t s t))           ;; 1 - ns
                                                             ((= r 2) (setf n t e t))           ;; 2 - ne
                                                             ((= r 3) (setf n t w t))           ;; 3 - nw
                                                             ((= r 4) (setf s t e t))           ;; 4 - se
                                                             ((= r 5) (setf s t w t))           ;; 5 - sw
                                                             ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                             ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                             ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                             ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                             ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe

                                                           (when n (place-city-river-n reserved-level))
                                                           (when s (place-city-river-s reserved-level))
                                                           (when w (place-city-river-w reserved-level))
                                                           (when e (place-city-river-e reserved-level))
                                                           (place-city-river-center reserved-level)

                                                           (loop for x from 0 below (array-dimension reserved-level 0) do
                                                             (loop for y from 0 below (array-dimension reserved-level 1) do
                                                               (when (or (= (aref reserved-level x y) +building-city-river+)
                                                                         (= (aref reserved-level x y) +building-city-bridge+))
                                                                 (push (list (aref reserved-level x y) x y) result))))
                                                           
                                                           result))))

(set-city-type (make-city-type :id +city-type-river-winter+
                               :return-max-buildings #'(lambda ()
                                                         (let ((max-building-types (make-hash-table)))
                                                           (setf (gethash +building-type-church+ max-building-types) 1)
                                                           (setf (gethash +building-type-satanists+ max-building-types) 1)
                                                           (setf (gethash +building-type-warehouse+ max-building-types) 1)
                                                           (setf (gethash +building-type-library+ max-building-types) 1)
                                                           (setf (gethash +building-type-prison+ max-building-types) 1)
                                                           (setf (gethash +building-type-lake+ max-building-types) 0)
                                                           max-building-types))
                               :return-reserv-buildings #'(lambda ()
                                                            (let ((reserved-building-types (make-hash-table)))
                                                              (setf (gethash +building-type-church+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-satanists+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-library+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-prison+ reserved-building-types) 1)
                                                              (setf (gethash +building-type-lake+ reserved-building-types) 0)
                                                              reserved-building-types))
                               :process-reserve-func #'(lambda (reserved-level)
                                                         (let ((result) (r) (n nil) (s nil) (w nil) (e nil))
                                                           (setf r (random 11))
                                                           (cond
                                                             ((= r 0) (setf w t e t))           ;; 0 - we
                                                             ((= r 1) (setf n t s t))           ;; 1 - ns
                                                             ((= r 2) (setf n t e t))           ;; 2 - ne
                                                             ((= r 3) (setf n t w t))           ;; 3 - nw
                                                             ((= r 4) (setf s t e t))           ;; 4 - se
                                                             ((= r 5) (setf s t w t))           ;; 5 - sw
                                                             ((= r 6) (setf n t w t e t))       ;; 6 - nwe
                                                             ((= r 7) (setf s t w t e t))       ;; 7 - swe
                                                             ((= r 8) (setf n t s t e t))       ;; 8 - nse
                                                             ((= r 9) (setf n t s t w t))       ;; 9 - nsw
                                                             ((= r 10) (setf n t s t w t e t))) ;; 10 - nswe

                                                           (when n (place-city-river-n reserved-level))
                                                           (when s (place-city-river-s reserved-level))
                                                           (when w (place-city-river-w reserved-level))
                                                           (when e (place-city-river-e reserved-level))
                                                           (place-city-river-center reserved-level)

                                                           (loop for x from 0 below (array-dimension reserved-level 0) do
                                                             (loop for y from 0 below (array-dimension reserved-level 1) do
                                                               (when (or (= (aref reserved-level x y) +building-city-river+)
                                                                         (= (aref reserved-level x y) +building-city-bridge+))
                                                                 (push (list (aref reserved-level x y) x y) result))))
                                                           
                                                           result))
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

