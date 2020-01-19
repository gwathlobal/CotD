(in-package :cotd)

(defclass campaign-map ()
  ((cells :initform nil :accessor cells :type simple-array) ;; array of campaign-cells
   ))

(defclass campaign-cell ()
  ())
