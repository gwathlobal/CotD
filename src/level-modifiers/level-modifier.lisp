(in-package :cotd)

(defconstant +mission-faction-absent+ 0)
(defconstant +mission-faction-attacker+ 1)
(defconstant +mission-faction-defender+ 2)
(defconstant +mission-faction-delayed+ 3)
(defconstant +mission-faction-present+ 4)

;;---------------------------------
;; LEVEL-MOD-TYPE Constants
;;---------------------------------

(defconstant +level-mod-controlled-by+ 0)
(defconstant +level-mod-sector-feat+ 1)
(defconstant +level-mod-sector-item+ 2)
(defconstant +level-mod-time-of-day+ 3)
(defconstant +level-mod-weather+ 4)

;;---------------------------------
;; LEVEL-MODIFIER Constants
;;---------------------------------

(defconstant +lm-controlled-by-none+ 0)
(defconstant +lm-controlled-by-demons+ 1)
(defconstant +lm-controlled-by-military+ 2)
(defconstant +lm-feat-river+ 3)
(defconstant +lm-feat-sea+ 4)
(defconstant +lm-feat-barricade+ 5)
(defconstant +lm-feat-library+ 6)
(defconstant +lm-feat-church+ 7)
(defconstant +lm-feat-lair+ 8)
(defconstant +lm-item-book-of-rituals+ 9)
(defconstant +lm-item-holy-relic+ 10)
(defconstant +lm-tod-morning+ 11)
(defconstant +lm-tod-noon+ 12)
(defconstant +lm-tod-evening+ 13)
(defconstant +lm-tod-night+ 14)
(defconstant +lm-weather-rain+ 15)
(defconstant +lm-weather-snow+ 16)

(defparameter *level-modifiers* (make-array (list 0) :adjustable t))

(defclass level-modifier ()
  ((id :initarg :id :accessor id)
   (name :initarg :name :accessor name)
   (lm-type :initarg :lm-type :accessor lm-type)
   (lm-debug :initform nil :initarg :lm-debug :accessor lm-debug :type boolean)
   (disabled :initform nil :initarg :disabled :accessor disabled :type boolean)
   (lvl-func :initform nil :initarg :lvl-func :accessor lvl-func)
   (mob-func :initform nil :initarg :mob-func :accessor mob-func)
   (itm-func :initform nil :initarg :itm-func :accessor itm-func)
   (fet-func :initform nil :initarg :fet-func :accessor fet-func)
   (terrain-post-process-func :initform nil :initarg :terrain-post-process-func :accessor terrain-post-process-func)
   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; the func that takes world-sector and returns a list of faction-ids
   (is-available-for-mission :initform nil :initarg :is-available-for-mission :accessor is-available-for-mission) ;; takes world-sector and mission-type
  ))

(defun set-level-modifier (&key id name type debug disabled lvl-func mob-func itm-func fet-func terrain-post-process-func faction-list-func is-available-for-mission)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless type (error ":TYPE is an obligatory parameter!"))
  
  (when (>= id (length *level-modifiers*))
    (adjust-array *level-modifiers* (list (1+ id)) :initial-element nil))
  (setf (aref *level-modifiers* id) (make-instance 'level-modifier :id id :name name :lm-type type :lm-debug debug :disabled disabled
                                                                   :lvl-func lvl-func :mob-func mob-func :itm-func itm-func :fet-func fet-func
                                                                   :terrain-post-process-func terrain-post-process-func
                                                                   :faction-list-func faction-list-func
                                                                   :is-available-for-mission is-available-for-mission)))

(defun get-level-modifier-by-id (level-modifier-id)
  (aref *level-modifiers* level-modifier-id))
