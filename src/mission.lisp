(in-package :cotd)

(defclass mission ()
  ((mission-type-id :initarg :mission-type-id :accessor mission-type-id)
   (x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (faction-list :initform () :initarg :faction-list :accessor faction-list) ;; list of faction-type-id
   (level-modifier-list :initform () :initarg :level-modifier-list :accessor level-modifier-list) ;; list of level-modifier-id
   ))

(defmethod name ((mission mission))
  (name (get-mission-type-by-id (mission-type-id mission))))
