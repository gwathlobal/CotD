(in-package :cotd)

;;--------------------------------------
;; GENERAL BUILDING TYPES
;;--------------------------------------

(defconstant +building-type-none+ 0)
(defconstant +building-type-house+ 1)
(defconstant +building-type-townhall+ 2)
(defconstant +building-type-park+ 3)
(defconstant +building-type-lake+ 4)
(defconstant +building-type-prison+ 5)
(defconstant +building-type-church+ 6)
(defconstant +building-type-library+ 7)
(defconstant +building-type-warehouse+ 8)
(defconstant +building-type-satanists+ 9)

;;--------------------------------------
;; SPECIFIC BUILDING TYPES
;;--------------------------------------
(defconstant +building-city-free+ 0)
(defconstant +building-city-reserved+ 1)
(defconstant +building-city-house-1+ 2)
(defconstant +building-city-house-2+ 3)
(defconstant +building-city-house-3+ 4)
(defconstant +building-city-house-4+ 5)
(defconstant +building-city-townhall-1+ 6)
(defconstant +building-city-park-1+ 7)
(defconstant +building-city-lake-1+ 8)
(defconstant +building-city-park-2+ 9)
(defconstant +building-city-prison-1+ 10)
(defconstant +building-city-church-1+ 11)
(defconstant +building-city-warehouse-1+ 12)
(defconstant +building-city-library-1+ 13)
(defconstant +building-city-park-3+ 14)
(defconstant +building-city-lake-2+ 15)
(defconstant +building-city-park-tiny+ 16)
(defconstant +building-city-townhall-2+ 17)
(defconstant +building-city-townhall-3+ 18)
(defconstant +building-city-townhall-4+ 19)
(defconstant +building-city-satan-lair-1+ 20)

(defparameter *level-grid-size* 5)

(defvar *building-types* (make-hash-table))
(defvar *general-building-types* (make-hash-table))

(defstruct building
  (id)       ;; building id 
  (grid-dim) ;; dimensions on a grid map, type (X . Y)
  (act-dim)  ;; dimensions on an actual map, type (X . Y)
  (func)     ;; function that places the building onto the actual map
  (type +building-type-none+)
  )

(defun get-building-grid-dim (building)
  (values (car (building-grid-dim building)) 
          (cdr (building-grid-dim building))))

(defun get-building-act-dim (building)
  (values (car (building-act-dim building)) 
          (cdr (building-act-dim building))))

(defun set-building-type (building)
  (destructuring-bind (adx . ady) (building-act-dim building)
    (destructuring-bind (gdx . gdy) (building-grid-dim building)
      (when (or (> adx (* gdx *level-grid-size*))
                (> ady (* gdy *level-grid-size*)))
        (error "Grid and actual dimensions do not match!"))))
  (unless (= (building-type building) +building-type-none+)
    (setf (gethash (building-type building) *general-building-types*) t))
  (setf (gethash (building-id building) *building-types*) building))

(defun get-building-type (building-type-id)
  (gethash building-type-id *building-types*))

(defun translate-build-to-template (x y build-template template-level)
  (loop for y1 from 0 below (length build-template) do
    (loop for c across (nth y1 build-template) 
          with x1 = 0
          do
             (cond
               ((char= c #\.) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-stone+))
               ((char= c #\#) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-wall-stone+))
               ((char= c #\T) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-tree-birch+))
               ((char= c #\,) (setf (aref template-level (+ x x1) (+ y y1)) (if (< (random 100) 20)
                                                                              +terrain-floor-dirt-bright+
                                                                              +terrain-floor-dirt+)))
               ((char= c #\_) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-water-lake+))
               ((char= c #\`) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-grass+))
               ((char= c #\-) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-wall-window+))
               ((char= c #\h) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-chair+))
               ((char= c #\t) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-table+))
               ((char= c #\b) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-bed+))
               ((char= c #\c) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-cabinet+))
               ((char= c #\C) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-crate+))
               ((char= c #\B) (setf (aref template-level (+ x x1) (+ y y1)) +terrain-floor-bookshelf+))
               )
             (incf x1)
          )))
