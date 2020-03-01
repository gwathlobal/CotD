(in-package :cotd)

(defconstant +mission-type-none+ -1)
(defconstant +mission-type-demonic-attack+ 0)
(defconstant +mission-type-demonic-raid+ 1)
(defconstant +mission-type-demonic-conquest+ 2)
(defconstant +mission-type-demonic-thievery+ 3)
(defconstant +mission-type-military-raid+ 4)
(defconstant +mission-type-military-conquest+ 5)
(defconstant +mission-type-celestial-purge+ 6)
(defconstant +mission-type-celestial-retrieval+ 7)

(defclass mission-type ()
  ((id :initform +mission-type-none+ :initarg :id :accessor id)
   (name :initform "Mission type name" :initarg :name :accessor name)
   (is-available-func :initform #'(lambda (world-map x y) (declare (ignore world-map x y)) t) :initarg :is-available-func :accessor is-available-func)
   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; the func that takes world-sector and returns a list of faction-ids

   (template-level-gen-func :initform nil :initarg :template-level-gen-func :accessor template-level-gen-func)
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)
   (terrain-post-process-func-list :initform nil :initarg :terrain-post-process-func-list :accessor terrain-post-process-func-list)
   (scenario-faction-list :initform nil :initarg :scenario-faction-list :accessor scenario-faction-list)
   (ai-package-list :initform nil :initarg :ai-package-list :accessor ai-package-list)
   (win-condition-list :initform nil :initarg :win-condition-list :accessor win-condition-list)
   ))

(defparameter *mission-types* (make-hash-table))

(defun set-mission-type (&key id name is-available-func faction-list-func template-level-gen-func overall-post-process-func-list terrain-post-process-func-list
                              scenario-faction-list ai-package-list win-condition-list)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  
  (setf (gethash id *mission-types*) (make-instance 'mission-type :id id :name name
                                                                  :is-available-func is-available-func
                                                                  :faction-list-func faction-list-func
                                                                  :template-level-gen-func template-level-gen-func
                                                                  :overall-post-process-func-list overall-post-process-func-list
                                                                  :terrain-post-process-func-list terrain-post-process-func-list
                                                                  :faction-list-func faction-list-func
                                                                  :scenario-faction-list scenario-faction-list
                                                                  :ai-package-list ai-package-list
                                                                  :win-condition-list win-condition-list
                                                                  )))

(defun get-mission-type-by-id (mission-type-id)
  (gethash mission-type-id *mission-types*))


(defun get-ai-based-on-faction (faction-id mission-type-id)
  (if (find faction-id (ai-package-list (get-mission-type-by-id mission-type-id)) :key #'(lambda (a) (first a)))
    (progn
      (second (find faction-id (ai-package-list (get-mission-type-by-id mission-type-id)) :key #'(lambda (a) (first a)))))
    nil))

;;========================================
;; MISSION-DISTRICTS
;;========================================

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

(defconstant +mission-scenario-test+ 0)
(defconstant +mission-scenario-demon-attack+ 1)
(defconstant +mission-scenario-demon-raid+ 2)
(defconstant +mission-scenario-demon-steal+ 3)
(defconstant +mission-scenario-demon-conquest+ 4)
(defconstant +mission-scenario-demon-raid-ruined+ 5)
(defconstant +mission-scenario-demon-conquest-ruined+ 6)
(defconstant +mission-scenario-military-conquest-ruined+ 7)
(defconstant +mission-scenario-military-raid-ruined+ 8)
(defconstant +mission-scenario-demon-conquest-corrupted+ 9)
(defconstant +mission-scenario-military-conquest-corrupted+ 10)
(defconstant +mission-scenario-angelic-conquest-corrupted+ 11)
(defconstant +mission-scenario-angelic-steal-corrupted+ 12)

(defclass mission-scenario ()
  ((id :initarg :id :accessor id :type fixnum)
   (name :initarg :name :accessor name :type string)
   (enabled :initform t :initarg :enabled :accessor enabled)
   (district-layout-list :initarg :district-layout-list :accessor district-layout-list)
   (faction-list :initarg :faction-list :accessor faction-list)
   (scenario-faction-list :initarg :scenario-faction-list :accessor scenario-faction-list)
   (objective-list :initform () :initarg :objective-list :accessor objective-list) ;; of type ((<faction-id> <objective-type-id>)...)
   (win-condition-list :initform () :initarg :win-condition-list :accessor win-condition-list) ;; of type ((<faction-id> <game-event-id>)...)
   (post-sf-list :initform () :initarg :post-sf-list :accessor post-sf-list)  ;; a list of scenario ids
   (win-value-func :initform nil :initarg :win-value-func :accessor win-value-func) ;; a lambda with no params
   (angel-disguised-mob-type-id :initform nil :initarg :angel-disguised-mob-type-id :accessor angel-disguised-mob-type-id)
   ))

(defparameter *mission-scenarios* (make-array (list 0) :adjustable t))

(defun set-mission-scenario (mission-scenario)
  (when (>= (id mission-scenario) (length *mission-scenarios*))
    (adjust-array *mission-scenarios* (list (1+ (id mission-scenario)))))
  (setf (aref *mission-scenarios* (id mission-scenario)) mission-scenario))

(defun get-mission-scenario-by-id (mission-scenario-id)
  (aref *mission-scenarios* mission-scenario-id))

(defun get-all-mission-scenarios-list ()
  (loop for id from 0 below (length *mission-scenarios*)
        when (enabled (get-mission-scenario-by-id id))
        collect id))
