(in-package :cotd-sdl)

;;---------------------------------
;; LEVEL-MOD-TYPE Constants
;;---------------------------------

(defenum:defenum level-mod-type-enum (:level-mod-controlled-by
                                      :level-mod-sector-feat
                                      :level-mod-sector-item
                                      :level-mod-tod
                                      :level-mod-weather
                                      :level-mod-player-placement
                                      :level-mod-misc))

(defconstant +level-mod-controlled-by+ 0)
(defconstant +level-mod-sector-feat+ 1)
(defconstant +level-mod-sector-item+ 2)
(defconstant +level-mod-time-of-day+ 3)
(defconstant +level-mod-weather+ 4)
(defconstant +level-mod-player-placement+ 5)
(defconstant +level-mod-misc+ 6)

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
(defconstant +lm-placement-player+ 17)
(defconstant +lm-placement-dead-player+ 18)
(defconstant +lm-placement-angel-chrome+ 19)
(defconstant +lm-placement-angel-trinity+ 20)
(defconstant +lm-placement-demon-crimson+ 21)
(defconstant +lm-placement-demon-shadow+ 22)
(defconstant +lm-placement-demon-malseraph+ 23)
(defconstant +lm-placement-military-chaplain+ 24)
(defconstant +lm-placement-military-scout+ 25)
(defconstant +lm-placement-priest+ 26)
(defconstant +lm-placement-satanist+ 27)
(defconstant +lm-placement-eater+ 28)
(defconstant +lm-placement-skinchanger+ 29)
(defconstant +lm-placement-thief+ 30)
(defconstant +lm-placement-ghost+ 31)
(defconstant +lm-placement-test+ 32)
(defconstant +lm-tod-hell+ 33)
(defconstant +lm-feat-hell-engine+ 34)
(defconstant +lm-feat-hell-flesh-storage+ 35)
(defconstant +lm-weather-acid-rain+ 36)
(defconstant +lm-misc-eater-incursion+ 37)
(defconstant +lm-misc-malseraphs-blessing+ 38)

(defparameter *level-modifiers* (make-array (list 0) :adjustable t))

(defclass level-modifier ()
  ((id :initarg :id :accessor id)
   (name :initarg :name :accessor name)
   (priority :initform 0 :initarg :priority :accessor priority)
   (lm-type :initarg :lm-type :accessor lm-type :type level-mod-type-enum)
   (lm-debug :initform nil :initarg :lm-debug :accessor lm-debug :type boolean)
   (disabled :initform nil :initarg :disabled :accessor disabled :type boolean)
   (template-level-gen-func :initform nil :initarg :template-level-gen-func :accessor template-level-gen-func)
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)
   (terrain-post-process-func-list :initform nil :initarg :terrain-post-process-func-list :accessor terrain-post-process-func-list)
   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; the func that takes world-sector-type and returns a list of faction-ids
   (is-available-for-mission :initform nil :initarg :is-available-for-mission :accessor is-available-for-mission) ;; takes world-sector-type-id, mission-type-id and world-time
   (random-available-for-mission :initform nil :initarg :random-available-for-mission :accessor random-available-for-mission)
   (scenario-enabled-func :initform nil :initarg :scenario-enabled-func :accessor scenario-enabled-func)
   (scenario-disabled-func :initform nil :initarg :scenario-disabled-func :accessor scenario-disabled-func)
   (depends-on-lvl-mod-func :initform nil :initarg :depends-on-lvl-mod-func :accessor depends-on-lvl-mod-func) ;; takes world-sector, mission-type-id and world-time
   (always-present-func :initform nil :initarg :always-present-func :accessor always-present-func) ;; takes world-sector, mission and world-time
   ))

(defun set-level-modifier (&key id name type debug disabled priority template-level-gen-func overall-post-process-func-list terrain-post-process-func-list faction-list-func
                                (is-available-for-mission #'(lambda (world-sector mission-type-id world-time)
                                                              (declare (ignore world-sector mission-type-id world-time))
                                                              t))
                                random-available-for-mission
                                scenario-enabled-func scenario-disabled-func
                                (depends-on-lvl-mod-func #'(lambda (world-sector mission-type-id world-time)
                                                             (declare (ignore world-sector mission-type-id world-time))
                                                             nil))
                                (always-present-func #'(lambda (world-sector mission world-time)
                                                         (declare (ignore world-sector mission world-time))
                                                         nil)))
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless type (error ":TYPE is an obligatory parameter!"))
  
  (when (>= id (length *level-modifiers*))
    (adjust-array *level-modifiers* (list (1+ id)) :initial-element nil))
  (setf (aref *level-modifiers* id) (make-instance 'level-modifier :id id :name name :lm-type type :lm-debug debug :disabled disabled :priority priority
                                                                   :template-level-gen-func template-level-gen-func
                                                                   :overall-post-process-func-list overall-post-process-func-list
                                                                   :terrain-post-process-func-list terrain-post-process-func-list
                                                                   :faction-list-func faction-list-func
                                                                   :is-available-for-mission is-available-for-mission
                                                                   :random-available-for-mission random-available-for-mission
                                                                   :scenario-enabled-func scenario-enabled-func
                                                                   :scenario-disabled-func scenario-disabled-func
                                                                   :depends-on-lvl-mod-func depends-on-lvl-mod-func
                                                                   :always-present-func always-present-func)))

(defun get-level-modifier-by-id (level-modifier-id)
  (aref *level-modifiers* level-modifier-id))

(defun get-all-lvl-mods-list (&key (include-disabled nil))
  (loop for lvl-mod across *level-modifiers*
        when (or (not include-disabled)
                 (and include-disabled
                      (disabled lvl-mod)))
        collect lvl-mod))

(defun change-level-to-snow (level world-sector mission world)
  (declare (ignore world-sector mission world))
  (loop for x from 0 below (array-dimension (terrain level) 0) do
    (loop for y from 0 below (array-dimension (terrain level) 1) do
      (loop for z from (1- (array-dimension (terrain level) 2)) downto 0 do
        (cond
          ((= (aref (terrain level) x y z) +terrain-border-floor+) (setf (aref (terrain level) x y z) +terrain-border-floor-snow+))
          ((= (aref (terrain level) x y z) +terrain-border-grass+) (setf (aref (terrain level) x y z) +terrain-border-floor-snow+))
          ((= (aref (terrain level) x y z) +terrain-floor-dirt+) (setf (aref (terrain level) x y z) +terrain-floor-snow+))
          ((= (aref (terrain level) x y z) +terrain-floor-dirt-bright+) (setf (aref (terrain level) x y z) +terrain-floor-snow+))
          ((= (aref (terrain level) x y z) +terrain-floor-grass+) (setf (aref (terrain level) x y z) +terrain-floor-snow+))
          ((= (aref (terrain level) x y z) +terrain-tree-birch+) (setf (aref (terrain level) x y z) +terrain-tree-birch-snow+))
          ((= (aref (terrain level) x y z) +terrain-water-liquid+) (progn
                                                                     (setf (aref (terrain level) x y z) +terrain-wall-ice+)
                                                                     (when (and (< z (1- (array-dimension (terrain level) 2)))
                                                                                (= (aref (terrain level) x y (1+ z)) +terrain-floor-air+))
                                                                       (setf (aref (terrain level) x y (1+ z)) +terrain-water-ice+))))
          ((= (aref (terrain level) x y z) +terrain-floor-leaves+) (setf (aref (terrain level) x y z) +terrain-floor-leaves-snow+))))))
  )
