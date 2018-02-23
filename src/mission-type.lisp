(in-package :cotd)

;;========================================
;; MISSION-DISTRICTS
;;========================================

(defconstant +mission-type-demon-raid-1+ 0)
(defconstant +mission-type-demon-raid-2+ 1)
(defconstant +mission-type-demon-raid-3+ 2)
(defconstant +mission-type-demon-raid-4+ 3)
(defconstant +mission-type-demon-raid-5+ 4)

(defconstant +mission-type-district-layout-living+ 0)
(defconstant +mission-type-district-layout-abandoned+ 1)
(defconstant +mission-type-district-layout-corrupted+ 2)

(defconstant +mission-faction-absent+ 0)
(defconstant +mission-faction-attacker+ 1)
(defconstant +mission-faction-defender+ 2)
(defconstant +mission-faction-delayed+ 3)
(defconstant +mission-faction-present+ 4)

(defclass mission-district ()
  ((id :initarg :id :accessor id :type fixnum)
   (faction-list :initarg :faction-list :accessor faction-list)))

(defparameter *mission-districts* (make-array (list 0) :adjustable t))

(defun set-mission-district (mission-district)
  (when (>= (id mission-district) (length *mission-districts*))
    (adjust-array *mission-districts* (list (1+ (id mission-district))) :initial-element nil))
  (setf (aref *mission-districts* (id mission-district)) mission-district))

(defun get-mission-district-by-id (mission-district-id)
  (aref *mission-districts* mission-district-id))

;;========================================
;; MISSION-SCENARIOS
;;========================================

(defconstant +mission-scenario-demon-attack+ 0)

(defclass mission-scenario ()
  ((id :initarg :id :accessor id :type fixnum)
   (name :initarg :name :accessor name :type string)
   (district-layout-list :initarg :district-layout-list :accessor district-layout-list)
   (faction-list :initarg :faction-list :accessor faction-list)))

(defparameter *mission-scenarios* (make-array (list 0) :adjustable t))

(defun set-mission-scenario (mission-scenario)
  (when (>= (id mission-scenario) (length *mission-scenarios*))
    (adjust-array *mission-scenarios* (list (1+ (id mission-scenario)))))
  (setf (aref *mission-scenarios* (id mission-scenario)) mission-scenario))

(defun get-mission-scenario-by-id (mission-scenario-id)
  (aref *mission-scenarios* mission-scenario-id))

(defun get-all-mission-scenarios-list ()
  (loop for id from 0 below (length *mission-scenarios*)
        collect id))
