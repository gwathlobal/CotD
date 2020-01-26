(in-package :cotd)

(defconstant +world-sector-normal-residential+ 0)
(defconstant +world-sector-normal-sea+ 1)
(defconstant +world-sector-normal-island+ 2)
(defconstant +world-sector-normal-port+ 3)
(defconstant +world-sector-normal-lake+ 4)
(defconstant +world-sector-normal-forest+ 5)

(defconstant +world-sector-abandoned-residential+ 6)
(defconstant +world-sector-abandoned-island+ 7)
(defconstant +world-sector-abandoned-port+ 8)
(defconstant +world-sector-abandoned-lake+ 9)
(defconstant +world-sector-abandoned-forest+ 10)

(defconstant +world-sector-corrupted-residential+ 11)
(defconstant +world-sector-corrupted-island+ 12)
(defconstant +world-sector-corrupted-port+ 13)
(defconstant +world-sector-corrupted-lake+ 14)
(defconstant +world-sector-corrupted-forest+ 15)

(defconstant +world-sector-controlled-by-none+ 0)
(defconstant +world-sector-controlled-by-military+ 1)
(defconstant +world-sector-controlled-by-demons+ 2)
(defconstant +world-sector-controlled-by-angels+ 3)

(defclass world-sector-type ()
  ((wtype :initform nil :initarg :wtype :accessor wtype) ;; ids from feature-layout
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)) 
  )

(defparameter *world-sector-types* (make-hash-table))

(defun set-world-sector-type (world-sector-type)
  (setf (gethash (wtype world-sector-type) *world-sector-types*) world-sector-type))

(defun get-world-sector-type-by-id (world-sector-type-id)
  (gethash world-sector-type-id *world-sector-types*))

(defparameter *max-x-world-map* 5)
(defparameter *max-y-world-map* 5)

(defclass world-map ()
  ((cells :initform nil :accessor cells :type simple-array) ;; array of world-sector
   ))

(defun generate-test-world-map (world-map)
  (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))

  (setf (aref (cells world-map) 0 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+))
  (setf (aref (cells world-map) 1 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+))
  (setf (aref (cells world-map) 2 0) (make-instance 'world-sector :wtype +world-sector-normal-island+))
  (setf (aref (cells world-map) 3 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+))
  (setf (aref (cells world-map) 4 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+))

  (setf (aref (cells world-map) 0 1) (make-instance 'world-sector :wtype +world-sector-abandoned-port+))
  (setf (aref (cells world-map) 1 1) (make-instance 'world-sector :wtype +world-sector-abandoned-port+))
  (setf (aref (cells world-map) 2 1) (make-instance 'world-sector :wtype +world-sector-normal-port+ :feats (list (list :river nil))))
  (setf (aref (cells world-map) 3 1) (make-instance 'world-sector :wtype +world-sector-normal-port+))
  (setf (aref (cells world-map) 4 1) (make-instance 'world-sector :wtype +world-sector-normal-port+ :controlled-by +world-sector-controlled-by-angels+))

  (setf (aref (cells world-map) 0 2) (make-instance 'world-sector :wtype +world-sector-abandoned-forest+))
  (setf (aref (cells world-map) 1 2) (make-instance 'world-sector :wtype +world-sector-abandoned-residential+))
  (setf (aref (cells world-map) 2 2) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :feats (list (list :river nil)) :controlled-by +world-sector-controlled-by-demons+))
  (setf (aref (cells world-map) 3 2) (make-instance 'world-sector :wtype +world-sector-normal-lake+ :feats (list (list :river nil)) :controlled-by +world-sector-controlled-by-military+))
  (setf (aref (cells world-map) 4 2) (make-instance 'world-sector :wtype +world-sector-normal-forest+))

  (setf (aref (cells world-map) 0 3) (make-instance 'world-sector :wtype +world-sector-corrupted-forest+))
  (setf (aref (cells world-map) 1 3) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :controlled-by +world-sector-controlled-by-demons+))
  (setf (aref (cells world-map) 2 3) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :feats (list (list :river nil))))
  (setf (aref (cells world-map) 3 3) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :controlled-by +world-sector-controlled-by-demons+))
  (setf (aref (cells world-map) 4 3) (make-instance 'world-sector :wtype +world-sector-normal-forest+))

  (setf (aref (cells world-map) 0 4) (make-instance 'world-sector :wtype +world-sector-normal-lake+))
  (setf (aref (cells world-map) 1 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+))
  (setf (aref (cells world-map) 2 4) (make-instance 'world-sector :wtype +world-sector-corrupted-forest+ :feats (list (list :river nil)) :controlled-by +world-sector-controlled-by-demons+))
  (setf (aref (cells world-map) 3 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+))
  (setf (aref (cells world-map) 4 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+))

  (generate-feats-on-world-map world-map)
  world-map)

(defun generate-feats-on-world-map (world-map)
  (loop for y from 0 below *max-y-world-map* do
    (loop for x from 0 below *max-x-world-map*
          for river-feat = (find :river (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
          for sea-feat = (find :sea (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
          for barricade-feat = (find :barricade (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
          with can-barricade-func = #'(lambda (sx sy tx ty)
                                        (if (and (or (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-forest+)
                                                     (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-island+)
                                                     (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-lake+)
                                                     (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-port+)
                                                     (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-residential+)
                                                     (= (controlled-by (aref (cells world-map) sx sy)) +world-sector-controlled-by-military+))
                                                 (= (controlled-by (aref (cells world-map) tx ty)) +world-sector-controlled-by-demons+))
                                          t
                                          nil))
          do
             ;; add river features
             (when river-feat
               (when (and (>= (1- x) 0)
                          (find :river (feats (aref (cells world-map) (1- x) y)) :key #'(lambda (a) (first a))))
                 (setf (second river-feat) (append (second river-feat) '(:w))))
               (when (and (>= (1- y) 0)
                          (find :river (feats (aref (cells world-map) x (1- y))) :key #'(lambda (a) (first a))))
                 (setf (second river-feat) (append (second river-feat) '(:n))))
               (when (and (< (1+ x) *max-x-world-map*)
                          (find :river (feats (aref (cells world-map) (1+ x) y)) :key #'(lambda (a) (first a))))
                 (setf (second river-feat) (append (second river-feat) '(:e))))
               (when (and (< (1+ y) *max-y-world-map*)
                          (find :river (feats (aref (cells world-map) x (1+ y))) :key #'(lambda (a) (first a))))
                 (setf (second river-feat) (append (second river-feat) '(:s))))
               )

             ;; add sea features
             (when (and (>= (1- x) 0)
                        (or (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-sea+)
                            (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-island+)))
               (if sea-feat
                 (push :w (second sea-feat))
                 (progn
                   (push (list :sea (list :w)) (feats (aref (cells world-map) x y)))
                   (setf sea-feat (find :sea (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (>= (1- y) 0)
                        (or (= (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-sea+)
                            (= (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-island+)))
               (if sea-feat
                 (push :n (second sea-feat))
                 (progn
                   (push (list :sea (list :n)) (feats (aref (cells world-map) x y)))
                   (setf sea-feat (find :sea (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (< (1+ x) *max-x-world-map*)
                        (or (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-sea+)
                            (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-island+)))
               (if sea-feat
                 (push :e (second sea-feat))
                 (progn
                   (push (list :sea (list :e)) (feats (aref (cells world-map) x y)))
                   (setf sea-feat (find :sea (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (< (1+ y) *max-y-world-map*)
                        (or (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-sea+)
                            (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-island+)))
               (if sea-feat
                 (push :s (second sea-feat))
                 (progn
                   (push (list :sea (list :s)) (feats (aref (cells world-map) x y)))
                   (setf sea-feat (find :sea (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))

             ;; add barricade features
             (when (and (>= (1- x) 0)
                        (funcall can-barricade-func x y (1- x) y))
               (if barricade-feat
                 (push :w (second barricade-feat))
                 (progn
                   (push (list :barricade (list :w)) (feats (aref (cells world-map) x y)))
                   (setf barricade-feat (find :barricade (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (>= (1- y) 0)
                        (funcall can-barricade-func x y x (1- y)))
               (if barricade-feat
                 (push :n (second barricade-feat))
                 (progn
                   (push (list :barricade (list :n)) (feats (aref (cells world-map) x y)))
                   (setf barricade-feat (find :barricade (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (< (1+ x) *max-x-world-map*)
                        (funcall can-barricade-func x y (1+ x) y))
               (if barricade-feat
                 (push :e (second barricade-feat))
                 (progn
                   (push (list :barricade (list :e)) (feats (aref (cells world-map) x y)))
                   (setf barricade-feat (find :barricade (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             (when (and (< (1+ y) *max-y-world-map*)
                        (funcall can-barricade-func x y x (1+ y)))
               (if barricade-feat
                 (push :s (second barricade-feat))
                 (progn
                   (push (list :barricade (list :s)) (feats (aref (cells world-map) x y)))
                   (setf barricade-feat (find :barricade (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
             ))
  )

(defclass world-sector ()
  ((wtype :initform nil :initarg :wtype :accessor wtype) ;; ids from feature-layout
   (feats :initform () :initarg :feats :accessor feats) ;; auxiliary features of the sector, like rivers present
   ;; ((:river (:n :s :w :e)) (:sea (:n :s :w :e)) (:barricade (:n :s :w :e)))
   (controlled-by :initform +world-sector-controlled-by-none+ :initarg :controlled-by :accessor controlled-by)
   ))
