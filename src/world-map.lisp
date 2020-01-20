(in-package :cotd)


(defclass world-map ()
  ((cells :initform nil :accessor cells :type simple-array) ;; array of world-sector
   ))

(defclass world-sector ()
  ((wtype :initform nil :initarg :wtype :accessor wtype) ;; ids from feature-layout
   ))
