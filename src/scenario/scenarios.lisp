(in-package :cotd)

;;---------------------------------
;; SCENARIO-FEATURE-TYPE Constants
;;---------------------------------

(defconstant +scenario-feature-weather+ 0)
(defconstant +scenario-feature-city-layout+ 1)
(defconstant +scenario-feature-player-faction+ 2)
(defconstant +scenario-feature-time-of-day+ 3)
(defconstant +scenario-feature-mission+ 4)

;;---------------------------------
;; SCENARIO-FEATURE Constants
;;---------------------------------

;; layout constants are used in highscores, so old ones should not be edited otherwise the the information presented from highscores table will be retroactively changed

(defconstant +city-layout-test+ 2)
(defconstant +city-layout-normal+ 3)
(defconstant +city-layout-river+ 4)
(defconstant +city-layout-port+ 5)
(defconstant +city-layout-forest+ 10)
(defconstant +city-layout-island+ 11)
(defconstant +city-layout-barricaded-city+ 13)

(defconstant +weather-type-clear+ 15)
(defconstant +weather-type-snow+ 16)
(defconstant +weather-type-rain+ 17)

(defconstant +player-faction-test+ 20)

(defconstant +tod-type-night+ 21)
(defconstant +tod-type-day+ 22)
(defconstant +tod-type-morning+ 23)
(defconstant +tod-type-evening+ 24)

(defconstant +mission-sf-demonic-raid+ 25)
(defconstant +mission-sf-demonic-steal+ 26)
(defconstant +mission-sf-ruined-district+ 27)
(defconstant +mission-sf-irradiated-district+ 28)

(defconstant +sf-faction-demonic-attack-player+ 30)
(defconstant +sf-faction-demonic-attack-dead-player+ 31)
(defconstant +sf-faction-demonic-attack-angel-chrome+ 32)
(defconstant +sf-faction-demonic-attack-demon-crimson+ 33)
(defconstant +sf-faction-demonic-attack-military-chaplain+ 34)
(defconstant +sf-faction-demonic-attack-military-scout+ 35)
(defconstant +sf-faction-demonic-attack-thief+ 36)
(defconstant +sf-faction-demonic-attack-satanist+ 37)
(defconstant +sf-faction-demonic-attack-priest+ 38)
(defconstant +sf-faction-demonic-attack-demon-shadow+ 39)
(defconstant +sf-faction-demonic-attack-angel-trinity+ 40)
(defconstant +sf-faction-demonic-attack-eater+ 41)
(defconstant +sf-faction-demonic-attack-demon-malseraph+ 42)
(defconstant +sf-faction-demonic-attack-ghost+ 43)
(defconstant +sf-faction-demonic-attack-skinchanger+ 44)

(defconstant +sf-faction-demonic-raid-player+ 45)
(defconstant +sf-faction-demonic-raid-dead-player+ 46)
(defconstant +sf-faction-demonic-raid-angel-chrome+ 47)
(defconstant +sf-faction-demonic-raid-demon-crimson+ 48)
(defconstant +sf-faction-demonic-raid-military-chaplain+ 49)
(defconstant +sf-faction-demonic-raid-military-scout+ 50)
(defconstant +sf-faction-demonic-raid-thief+ 51)
(defconstant +sf-faction-demonic-raid-satanist+ 52)
(defconstant +sf-faction-demonic-raid-priest+ 53)
(defconstant +sf-faction-demonic-raid-demon-shadow+ 54)
(defconstant +sf-faction-demonic-raid-angel-trinity+ 55)
(defconstant +sf-faction-demonic-raid-eater+ 56)
(defconstant +sf-faction-demonic-raid-demon-malseraph+ 57)
(defconstant +sf-faction-demonic-raid-ghost+ 58)
(defconstant +sf-faction-demonic-raid-skinchanger+ 59)

(defconstant +sf-faction-demonic-steal-player+ 60)
(defconstant +sf-faction-demonic-steal-dead-player+ 61)
(defconstant +sf-faction-demonic-steal-angel-chrome+ 62)
(defconstant +sf-faction-demonic-steal-demon-crimson+ 63)
(defconstant +sf-faction-demonic-steal-military-chaplain+ 64)
(defconstant +sf-faction-demonic-steal-military-scout+ 65)
(defconstant +sf-faction-demonic-steal-thief+ 66)
(defconstant +sf-faction-demonic-steal-satanist+ 67)
(defconstant +sf-faction-demonic-steal-priest+ 68)
(defconstant +sf-faction-demonic-steal-demon-shadow+ 69)
(defconstant +sf-faction-demonic-steal-angel-trinity+ 70)
(defconstant +sf-faction-demonic-steal-eater+ 71)
(defconstant +sf-faction-demonic-steal-demon-malseraph+ 72)
(defconstant +sf-faction-demonic-steal-ghost+ 73)
(defconstant +sf-faction-demonic-steal-skinchanger+ 74)

(defconstant +sf-faction-demonic-conquest-player+ 75)
(defconstant +sf-faction-demonic-conquest-dead-player+ 76)
(defconstant +sf-faction-demonic-conquest-angel-chrome+ 77)
(defconstant +sf-faction-demonic-conquest-demon-crimson+ 78)
(defconstant +sf-faction-demonic-conquest-military-chaplain+ 79)
(defconstant +sf-faction-demonic-conquest-military-scout+ 80)
(defconstant +sf-faction-demonic-conquest-thief+ 81)
(defconstant +sf-faction-demonic-conquest-satanist+ 82)
(defconstant +sf-faction-demonic-conquest-priest+ 83)
(defconstant +sf-faction-demonic-conquest-demon-shadow+ 84)
(defconstant +sf-faction-demonic-conquest-angel-trinity+ 85)
(defconstant +sf-faction-demonic-conquest-eater+ 86)
(defconstant +sf-faction-demonic-conquest-demon-malseraph+ 87)
(defconstant +sf-faction-demonic-conquest-ghost+ 88)
(defconstant +sf-faction-demonic-conquest-skinchanger+ 89)

(defconstant +city-layout-ruined-normal+ 90)
(defconstant +city-layout-ruined-river+ 91)
(defconstant +city-layout-ruined-port+ 92)
(defconstant +city-layout-ruined-forest+ 93)
(defconstant +city-layout-ruined-island+ 94)

(defconstant +sf-faction-demonic-raid-ruined-player+ 100)
(defconstant +sf-faction-demonic-raid-ruined-dead-player+ 101)
(defconstant +sf-faction-demonic-raid-ruined-angel-chrome+ 102)
(defconstant +sf-faction-demonic-raid-ruined-demon-crimson+ 103)
(defconstant +sf-faction-demonic-raid-ruined-military-chaplain+ 104)
(defconstant +sf-faction-demonic-raid-ruined-military-scout+ 105)
(defconstant +sf-faction-demonic-raid-ruined-demon-shadow+ 106)
(defconstant +sf-faction-demonic-raid-ruined-angel-trinity+ 107)
(defconstant +sf-faction-demonic-raid-ruined-eater+ 108)
(defconstant +sf-faction-demonic-raid-ruined-demon-malseraph+ 110)
(defconstant +sf-faction-demonic-raid-ruined-skinchanger+ 111)

(defconstant +sf-faction-demonic-conquest-ruined-player+ 120)
(defconstant +sf-faction-demonic-conquest-ruined-dead-player+ 121)
(defconstant +sf-faction-demonic-conquest-ruined-angel-chrome+ 122)
(defconstant +sf-faction-demonic-conquest-ruined-demon-crimson+ 123)
(defconstant +sf-faction-demonic-conquest-ruined-military-chaplain+ 124)
(defconstant +sf-faction-demonic-conquest-ruined-military-scout+ 125)
(defconstant +sf-faction-demonic-conquest-ruined-demon-shadow+ 126)
(defconstant +sf-faction-demonic-conquest-ruined-angel-trinity+ 127)
(defconstant +sf-faction-demonic-conquest-ruined-eater+ 128)
(defconstant +sf-faction-demonic-conquest-ruined-demon-malseraph+ 129)
(defconstant +sf-faction-demonic-conquest-ruined-skinchanger+ 130)

(defconstant +sf-faction-military-conquest-ruined-player+ 140)
(defconstant +sf-faction-military-conquest-ruined-dead-player+ 141)
(defconstant +sf-faction-military-conquest-ruined-angel-chrome+ 142)
(defconstant +sf-faction-military-conquest-ruined-demon-crimson+ 143)
(defconstant +sf-faction-military-conquest-ruined-military-chaplain+ 144)
(defconstant +sf-faction-military-conquest-ruined-military-scout+ 145)
(defconstant +sf-faction-military-conquest-ruined-demon-shadow+ 146)
(defconstant +sf-faction-military-conquest-ruined-angel-trinity+ 147)
(defconstant +sf-faction-military-conquest-ruined-eater+ 148)
(defconstant +sf-faction-military-conquest-ruined-demon-malseraph+ 149)
(defconstant +sf-faction-military-conquest-ruined-skinchanger+ 150)

(defconstant +sf-faction-military-raid-ruined-player+ 160)
(defconstant +sf-faction-military-raid-ruined-dead-player+ 161)
(defconstant +sf-faction-military-raid-ruined-angel-chrome+ 162)
(defconstant +sf-faction-military-raid-ruined-demon-crimson+ 163)
(defconstant +sf-faction-military-raid-ruined-military-chaplain+ 164)
(defconstant +sf-faction-military-raid-ruined-military-scout+ 165)
(defconstant +sf-faction-military-raid-ruined-demon-shadow+ 166)
(defconstant +sf-faction-military-raid-ruined-angel-trinity+ 167)
(defconstant +sf-faction-military-raid-ruined-eater+ 168)
(defconstant +sf-faction-military-raid-ruined-demon-malseraph+ 169)
(defconstant +sf-faction-military-raid-ruined-skinchanger+ 170)

(defconstant +city-layout-corrupted-normal+ 180)
(defconstant +city-layout-corrupted-river+ 181)
(defconstant +city-layout-corrupted-port+ 182)
(defconstant +city-layout-corrupted-forest+ 183)
(defconstant +city-layout-corrupted-island+ 184)

(defconstant +sf-faction-demonic-conquest-corrupted-player+ 190)
(defconstant +sf-faction-demonic-conquest-corrupted-dead-player+ 191)
(defconstant +sf-faction-demonic-conquest-corrupted-angel-chrome+ 192)
(defconstant +sf-faction-demonic-conquest-corrupted-demon-crimson+ 193)
(defconstant +sf-faction-demonic-conquest-corrupted-military-chaplain+ 194)
(defconstant +sf-faction-demonic-conquest-corrupted-military-scout+ 195)
(defconstant +sf-faction-demonic-conquest-corrupted-demon-shadow+ 196)
(defconstant +sf-faction-demonic-conquest-corrupted-angel-trinity+ 197)
(defconstant +sf-faction-demonic-conquest-corrupted-eater+ 198)
(defconstant +sf-faction-demonic-conquest-corrupted-demon-malseraph+ 199)
(defconstant +sf-faction-demonic-conquest-corrupted-skinchanger+ 200)

(defconstant +sf-faction-military-conquest-corrupted-player+ 210)
(defconstant +sf-faction-military-conquest-corrupted-dead-player+ 211)
(defconstant +sf-faction-military-conquest-corrupted-angel-chrome+ 212)
(defconstant +sf-faction-military-conquest-corrupted-demon-crimson+ 213)
(defconstant +sf-faction-military-conquest-corrupted-military-chaplain+ 214)
(defconstant +sf-faction-military-conquest-corrupted-military-scout+ 215)
(defconstant +sf-faction-military-conquest-corrupted-demon-shadow+ 216)
(defconstant +sf-faction-military-conquest-corrupted-angel-trinity+ 217)
(defconstant +sf-faction-military-conquest-corrupted-eater+ 218)
(defconstant +sf-faction-military-conquest-corrupted-demon-malseraph+ 219)
(defconstant +sf-faction-military-conquest-corrupted-skinchanger+ 220)

(defconstant +sf-faction-angelic-conquest-corrupted-player+ 230)
(defconstant +sf-faction-angelic-conquest-corrupted-dead-player+ 231)
(defconstant +sf-faction-angelic-conquest-corrupted-angel-chrome+ 232)
(defconstant +sf-faction-angelic-conquest-corrupted-demon-crimson+ 233)
(defconstant +sf-faction-angelic-conquest-corrupted-military-chaplain+ 234)
(defconstant +sf-faction-angelic-conquest-corrupted-military-scout+ 235)
(defconstant +sf-faction-angelic-conquest-corrupted-demon-shadow+ 236)
(defconstant +sf-faction-angelic-conquest-corrupted-angel-trinity+ 237)
(defconstant +sf-faction-angelic-conquest-corrupted-eater+ 238)
(defconstant +sf-faction-angelic-conquest-corrupted-demon-malseraph+ 239)
(defconstant +sf-faction-angelic-conquest-corrupted-skinchanger+ 240)

(defconstant +city-layout-corrupted-steal-normal+ 250)
(defconstant +city-layout-corrupted-steal-river+ 251)
(defconstant +city-layout-corrupted-steal-port+ 252)
(defconstant +city-layout-corrupted-steal-forest+ 253)
(defconstant +city-layout-corrupted-steal-island+ 254)

(defconstant +sf-faction-angelic-steal-player+ 260)
(defconstant +sf-faction-angelic-steal-dead-player+ 261)
(defconstant +sf-faction-angelic-steal-angel-chrome+ 262)
(defconstant +sf-faction-angelic-steal-demon-crimson+ 263)
(defconstant +sf-faction-angelic-steal-demon-shadow+ 269)
(defconstant +sf-faction-angelic-steal-angel-trinity+ 270)
(defconstant +sf-faction-angelic-steal-eater+ 271)
(defconstant +sf-faction-angelic-steal-demon-malseraph+ 272)
(defconstant +sf-faction-angelic-steal-skinchanger+ 273)

(defconstant +city-layout-lake+ 280)
(defconstant +city-layout-ruined-lake+ 281)
(defconstant +city-layout-corrupted-lake+ 282)
(defconstant +city-layout-corrupted-steal-lake+ 283)
(defconstant +city-layout-lake-river+ 284)
(defconstant +city-layout-ruined-lake-river+ 285)
(defconstant +city-layout-corrupted-lake-river+ 286)
(defconstant +city-layout-corrupted-steal-lake-river+ 287)
(defconstant +city-layout-port-river+ 288)
(defconstant +city-layout-ruined-port-river+ 289)
(defconstant +city-layout-corrupted-port-river+ 290)
(defconstant +city-layout-corrupted-steal-port-river+ 291)

(defparameter *scenario-features* (make-array (list 0) :adjustable t))

(defstruct (scenario-feature (:conc-name sf-))
  (id)
  (name)
  (type)
  (debug nil :type boolean)
  (disabled nil :type boolean)
  (func nil))

(defun set-scenario-feature (scenario-feature)
  (when (>= (sf-id scenario-feature) (length *scenario-features*))
    (adjust-array *scenario-features* (list (1+ (sf-id scenario-feature))) :initial-element nil))
  (setf (aref *scenario-features* (sf-id scenario-feature)) scenario-feature))

(defun get-scenario-feature-by-id (scenario-feature-id)
  (aref *scenario-features* scenario-feature-id))

(defun get-all-scenario-features-by-type (scenario-feature-type-id &optional (include-debug t))
  (loop for sf across *scenario-features*
        when (and sf
                  (or (and (= (sf-type sf) scenario-feature-type-id)
                           include-debug
                           (not (sf-disabled sf)))
                      (and (= (sf-type sf) scenario-feature-type-id)
                           (not include-debug)
                           (not (sf-debug sf))
                           (not (sf-disabled sf)))))
          collect (sf-id sf)))

;;---------------------------------
;; Get max buildings functions
;;---------------------------------

(defun get-max-buildings-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-house+ max-building-types) t)
    (setf (gethash +building-type-townhall+ max-building-types) t)
    (setf (gethash +building-type-park+ max-building-types) t)
    (setf (gethash +building-type-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-river ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-house+ max-building-types) t)
    (setf (gethash +building-type-townhall+ max-building-types) t)
    (setf (gethash +building-type-park+ max-building-types) t)
    (setf (gethash +building-type-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-house+ max-building-types) t)
    (setf (gethash +building-type-townhall+ max-building-types) t)
    (setf (gethash +building-type-park+ max-building-types) t)
    (setf (gethash +building-type-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    max-building-types))

(defun get-max-buildings-ruined-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-house+ max-building-types) t)
    (setf (gethash +building-type-ruined-townhall+ max-building-types) t)
    (setf (gethash +building-type-ruined-park+ max-building-types) t)
    (setf (gethash +building-type-ruined-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-ruined-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-ruined-library+ max-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-ruined-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-ruined-crater+ max-building-types) 4)
    (setf (gethash +building-type-ruined-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-ruined-river ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-house+ max-building-types) t)
    (setf (gethash +building-type-ruined-townhall+ max-building-types) t)
    (setf (gethash +building-type-ruined-park+ max-building-types) t)
    (setf (gethash +building-type-ruined-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-ruined-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-ruined-library+ max-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-ruined-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-ruined-crater+ max-building-types) 4)
    (setf (gethash +building-type-ruined-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-ruined-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-house+ max-building-types) t)
    (setf (gethash +building-type-ruined-townhall+ max-building-types) t)
    (setf (gethash +building-type-ruined-park+ max-building-types) t)
    (setf (gethash +building-type-ruined-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-ruined-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-ruined-library+ max-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-ruined-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-ruined-crater+ max-building-types) 4)
    (setf (gethash +building-type-ruined-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-river ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-steal-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-shrine+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-steal-river ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-shrine+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-steal-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-library+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-shrine+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-crater+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-crater-large+ max-building-types) 1)
    max-building-types))


;;---------------------------------
;; Get reserved buildings functions
;;---------------------------------

(defun get-reserved-buildings-normal ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 2)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-river ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-port ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-church+ reserved-building-types) 1)
    (setf (gethash +building-type-satanists+ reserved-building-types) 1)
    (setf (gethash +building-type-warehouse+ reserved-building-types) 0)
    (setf (gethash +building-type-library+ reserved-building-types) 1)
    (setf (gethash +building-type-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 0)
    reserved-building-types))

(defun get-reserved-buildings-ruined-normal ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-ruined-library+ reserved-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-ruined-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 2)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-ruined-river ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-ruined-library+ reserved-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-ruined-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-ruined-port ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-warehouse+ reserved-building-types) 0)
    (setf (gethash +building-type-ruined-library+ reserved-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-ruined-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-graveyard+ reserved-building-types) 0)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-normal ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 2)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-river ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-port ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 0)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-steal-normal ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 2)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-shrine+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-steal-river ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-shrine+ reserved-building-types) 1)
    reserved-building-types))

(defun get-reserved-buildings-corrupted-steal-port ()
  (let ((reserved-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-warehouse+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-library+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ reserved-building-types) 1)
    (setf (gethash +building-type-stables+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ reserved-building-types) 1)
    (setf (gethash +building-type-corrupted-lake+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-graveyard+ reserved-building-types) 0)
    (setf (gethash +building-type-corrupted-shrine+ reserved-building-types) 1)
    reserved-building-types))

;;---------------------------------
;; Auxuliary scenario functions
;;---------------------------------

(defun set-building-types-for-factions (faction-list building-type-hash-table)
  ;; satanists are absent
  (unless (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-satanists+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (setf (gethash +building-type-satanists+ building-type-hash-table) 0))
  ;; the church is absent
  (unless (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-church+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (setf (gethash +building-type-church+ building-type-hash-table) 0))
  ;; the lost soul is present so satanists' lair should also be present
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-ghost+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (setf (gethash +building-type-satanists+ building-type-hash-table) 1)
    (setf (gethash +building-type-library+ building-type-hash-table) 1))
  building-type-hash-table)

(defun get-objectives-based-on-faction (faction-id mission-id)
  (if (find faction-id (objective-list (get-mission-scenario-by-id mission-id)) :key #'(lambda (a) (first a)))
    (progn
      (second (find faction-id (objective-list (get-mission-scenario-by-id mission-id)) :key #'(lambda (a) (first a)))))
    nil))

(defun place-land-arrival-border (reserved-level)
  (let ((result))
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-land-border+)
             (setf (aref reserved-level x (1- (array-dimension reserved-level 1)) 2) +building-city-land-border+))

    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-land-border+)
             (setf (aref reserved-level (1- (array-dimension reserved-level 0)) y 2) +building-city-land-border+))

    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (= (aref reserved-level x y 2) +building-city-land-border+)
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-city-river-e (reserved-level)
  (let ((max-x (1- (truncate (array-dimension reserved-level 0) 2)))
        (min-x 0))
    (loop for x from min-x below max-x
          for building-type-id = (if (and (zerop (mod (1+ x) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2)) 2) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2) 2) building-type-id))))

(defun place-city-river-w (reserved-level)
  (let ((max-x (array-dimension reserved-level 0))
        (min-x (1- (truncate (array-dimension reserved-level 0) 2))))
    (loop for x from (+ min-x 2) below max-x
          for building-type-id = (if (and (zerop (mod (1+ (- x min-x)) 4))
                                        (/= x (1- max-x)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level x (1- (truncate (array-dimension reserved-level 1) 2)) 2) building-type-id)
             (setf (aref reserved-level x (truncate (array-dimension reserved-level 1) 2) 2) building-type-id))))
           
(defun place-city-river-n (reserved-level)
  (let ((max-y (1- (truncate (array-dimension reserved-level 1) 2)))
        (min-y 0))
    (loop for y from min-y below max-y
          for building-type-id = (if (and (zerop (mod (1+ y) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y 2) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y 2) building-type-id))))

(defun place-city-river-s (reserved-level)
  (let ((max-y (array-dimension reserved-level 1))
        (min-y (1- (truncate (array-dimension reserved-level 1) 2))))
    (loop for y from (+ min-y 2) below max-y
          for building-type-id = (if (and (zerop (mod (1+ (- y min-y)) 4))
                                        (/= y (1- max-y)))
                                   +building-city-bridge+
                                   +building-city-river+)
          do
             (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) y 2) building-type-id)
             (setf (aref reserved-level (1- (truncate (array-dimension reserved-level 0) 2)) y 2) building-type-id))))

(defun place-city-river-center (reserved-level)
  (let ((x (1- (truncate (array-dimension reserved-level 0) 2)))
        (y (1- (truncate (array-dimension reserved-level 1) 2))))
    
    (setf (aref reserved-level (+ x 0) (+ y 0) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 0) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 0) (+ y 1) 2) +building-city-river+)
    (setf (aref reserved-level (+ x 1) (+ y 1) 2) +building-city-river+)))

(defun change-level-to-snow (template-level)
  (loop for x from 0 below (array-dimension template-level 0) do
    (loop for y from 0 below (array-dimension template-level 1) do
      (loop for z from (1- (array-dimension template-level 2)) downto 0 do
        (cond
          ((= (aref template-level x y z) +terrain-border-floor+) (setf (aref template-level x y z) +terrain-border-floor-snow+))
          ((= (aref template-level x y z) +terrain-border-grass+) (setf (aref template-level x y z) +terrain-border-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-dirt+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-dirt-bright+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-floor-grass+) (setf (aref template-level x y z) +terrain-floor-snow+))
          ((= (aref template-level x y z) +terrain-tree-birch+) (setf (aref template-level x y z) +terrain-tree-birch-snow+))
          ((= (aref template-level x y z) +terrain-water-liquid+) (progn (setf (aref template-level x y z) +terrain-water-ice+)
                                                                         (when (< z (1- (array-dimension template-level 2)))
                                                                           (setf (aref template-level x y (1+ z)) +terrain-water-ice+))))
          ((= (aref template-level x y z) +terrain-floor-leaves+) (setf (aref template-level x y z) +terrain-floor-leaves-snow+))))))
  template-level)

(defun place-reserved-buildings-river (reserved-level)
  (let ((result) (r) (n nil) (s nil) (w nil) (e nil))

    (place-land-arrival-border reserved-level)
    
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
        (when (or (= (aref reserved-level x y 2) +building-city-river+)
                  (= (aref reserved-level x y 2) +building-city-bridge+)
                  (= (aref reserved-level x y 2) +building-city-land-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-lake (reserved-level)
  (let ((result))

    (place-land-arrival-border reserved-level)

    (let ((x (- (truncate (array-dimension reserved-level 0) 2) 2))
          (y (- (truncate (array-dimension reserved-level 1) 2) 2)))

      (loop for dx from 0 to 3 do
        (loop for dy from 0 to 3 do
          (setf (aref reserved-level (+ x dx) (+ y dy) 2) +building-city-central-lake+)))

      (loop for x from 0 below (array-dimension reserved-level 0) do
        (loop for y from 0 below (array-dimension reserved-level 1) do
          (when (= (aref reserved-level x y 2) +building-city-land-border+)
            (push (list (aref reserved-level x y 2) x y 2) result))))
      
      (push (list +building-city-central-lake+ x y 2) result)
      )  
    
    result))

(defun place-reserved-buildings-lake-corrupted (reserved-level)
  (let ((result))

    (place-land-arrival-border reserved-level)

    (let ((x (- (truncate (array-dimension reserved-level 0) 2) 2))
          (y (- (truncate (array-dimension reserved-level 1) 2) 2)))

      (loop for dx from 0 to 3 do
        (loop for dy from 0 to 3 do
          (setf (aref reserved-level (+ x dx) (+ y dy) 2) +building-city-corrupted-central-lake+)))

      (loop for x from 0 below (array-dimension reserved-level 0) do
        (loop for y from 0 below (array-dimension reserved-level 1) do
          (when (= (aref reserved-level x y 2) +building-city-land-border+)
            (push (list (aref reserved-level x y 2) x y 2) result))))
      
      (push (list +building-city-corrupted-central-lake+ x y 2) result)
      )
    
    result))

(defun place-reserved-buildings-lake-river (reserved-level)
  (let ((result))

    (place-reserved-buildings-river reserved-level)

    (let ((x (- (truncate (array-dimension reserved-level 0) 2) 2))
          (y (- (truncate (array-dimension reserved-level 1) 2) 2)))

      (loop for dx from 0 to 3 do
        (loop for dy from 0 to 3 do
          (setf (aref reserved-level (+ x dx) (+ y dy) 2) +building-city-central-lake+)
              ))

      (loop for x from 0 below (array-dimension reserved-level 0) do
        (loop for y from 0 below (array-dimension reserved-level 1) do
          (when (or (= (aref reserved-level x y 2) +building-city-river+)
                    (= (aref reserved-level x y 2) +building-city-bridge+)
                    (= (aref reserved-level x y 2) +building-city-land-border+))
            (push (list (aref reserved-level x y 2) x y 2) result))))
      
      (push (list +building-city-central-lake+ x y 2) result)
      )  
    
    result))

(defun place-reserved-buildings-lake-river-corrupted (reserved-level)
  (let ((result))

    (place-reserved-buildings-river reserved-level)

    (let ((x (- (truncate (array-dimension reserved-level 0) 2) 2))
          (y (- (truncate (array-dimension reserved-level 1) 2) 2)))

      (loop for dx from 0 to 3 do
        (loop for dy from 0 to 3 do
          (setf (aref reserved-level (+ x dx) (+ y dy) 2) +building-city-corrupted-central-lake+)
              ))

      (loop for x from 0 below (array-dimension reserved-level 0) do
        (loop for y from 0 below (array-dimension reserved-level 1) do
          (when (or (= (aref reserved-level x y 2) +building-city-river+)
                    (= (aref reserved-level x y 2) +building-city-bridge+)
                    (= (aref reserved-level x y 2) +building-city-land-border+))
            (push (list (aref reserved-level x y 2) x y 2) result))))
      
      (push (list +building-city-corrupted-central-lake+ x y 2) result)
      )  
    
    result))

(defun place-reserved-buildings-port-n (reserved-level &optional (skip-second-pier nil))
  (let ((result))
    (loop with count-piers = 0
          for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level x 0 2) +building-city-sea+)
             (setf (aref reserved-level x 1 2) building-type-id)
             (setf (aref reserved-level x 2 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (push (list random-warehouse-1 x 3 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (push (list random-warehouse-2 x 5 2) result)))
    
    result))

(defun place-reserved-buildings-port-s (reserved-level &optional (skip-second-pier nil))
  (let ((result) (max-y (1- (array-dimension reserved-level 1))))
    (loop with count-piers = 0
          for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level x (- max-y 0) 2) +building-city-sea+)
             (setf (aref reserved-level x (- max-y 1) 2) building-type-id)
             (setf (aref reserved-level x (- max-y 2) 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (push (list random-warehouse-1 x (- max-y 4) 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (push (list random-warehouse-2 x (- max-y 6) 2) result)))
    
    result))

(defun place-reserved-buildings-port-e (reserved-level &optional (skip-second-pier nil))
  (let ((result) (max-x (1- (array-dimension reserved-level 0))))
    (loop with count-piers = 0
          for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          do
             (setf (aref reserved-level (- max-x 0) y 2) +building-city-sea+)
             (setf (aref reserved-level (- max-x 1) y 2) building-type-id)
             (setf (aref reserved-level (- max-x 2) y 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (push (list random-warehouse-1 (- max-x 4) y 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (push (list random-warehouse-2 (- max-x 6) y 2) result)))
    
    result))

(defun place-reserved-buildings-port-w (reserved-level &optional (skip-second-pier nil))
  (let ((result))
    (loop with count-piers = 0
          for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-warehouse-port-1+
                                     +building-city-warehouse-port-2+)
          with z = 2
          do
             (setf (aref reserved-level 0 y z) +building-city-sea+)
             (setf (aref reserved-level 1 y z) building-type-id)
             (setf (aref reserved-level 2 y z) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 3 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 3 y z reserved-level)
               (push (list random-warehouse-1 3 y z) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 5 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 5 y z reserved-level)
               (push (list random-warehouse-2 5 y z) result)))
    
    result))

(defun place-reserved-buildings-ruined-port-n (reserved-level &optional (skip-second-pier nil))
  (let ((result))
    (loop with count-piers = 0
          for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          do
             (setf (aref reserved-level x 0 2) +building-city-sea+)
             (setf (aref reserved-level x 1 2) building-type-id)
             (setf (aref reserved-level x 2 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x 3 2 reserved-level)
               (push (list random-warehouse-1 x 3 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x 5 2 reserved-level)
               (push (list random-warehouse-2 x 5 2) result)))
    
    result))

(defun place-reserved-buildings-ruined-port-s (reserved-level &optional (skip-second-pier nil))
  (let ((result) (max-y (1- (array-dimension reserved-level 1))))
    (loop with count-piers = 0
          for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          do
             (setf (aref reserved-level x (- max-y 0) 2) +building-city-sea+)
             (setf (aref reserved-level x (- max-y 1) 2) building-type-id)
             (setf (aref reserved-level x (- max-y 2) 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 x (- max-y 4) 2 reserved-level)
               (push (list random-warehouse-1 x (- max-y 4) 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 x (- max-y 6) 2 reserved-level)
               (push (list random-warehouse-2 x (- max-y 6) 2) result)))
    
    result))

(defun place-reserved-buildings-ruined-port-e (reserved-level &optional (skip-second-pier nil))
  (let ((result) (max-x (1- (array-dimension reserved-level 0))))
    (loop with count-piers = 0
          for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          do
             (setf (aref reserved-level (- max-x 0) y 2) +building-city-sea+)
             (setf (aref reserved-level (- max-x 1) y 2) building-type-id)
             (setf (aref reserved-level (- max-x 2) y 2) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 (- max-x 4) y 2 reserved-level)
               (push (list random-warehouse-1 (- max-x 4) y 2) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 (- max-x 6) y 2 reserved-level)
               (push (list random-warehouse-2 (- max-x 6) y 2) result)))
    
    result))

(defun place-reserved-buildings-ruined-port-w (reserved-level &optional (skip-second-pier nil))
  (let ((result))
    (loop with count-piers = 0
          for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   (progn
                                     (incf count-piers)
                                     (if (and skip-second-pier
                                              (= count-piers 2))
                                       +building-city-sea+
                                       +building-city-pier+))
                                   +building-city-sea+)
          for random-warehouse-1 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          for random-warehouse-2 = (if (zerop (random 2))
                                     +building-city-ruined-warehouse-port-1+
                                     +building-city-ruined-warehouse-port-2+)
          with z = 2
          do
             (setf (aref reserved-level 0 y z) +building-city-sea+)
             (setf (aref reserved-level 1 y z) building-type-id)
             (setf (aref reserved-level 2 y z) building-type-id)
             (when (level-city-can-place-build-on-grid random-warehouse-1 3 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-1 3 y z reserved-level)
               (push (list random-warehouse-1 3 y z) result))
             (when (level-city-can-place-build-on-grid random-warehouse-2 5 y z reserved-level)
               (level-city-reserve-build-on-grid random-warehouse-2 5 y z reserved-level)
               (push (list random-warehouse-2 5 y z) result)))
    
    result))

(defun create-mobs-from-template (world mob-template-list)
  (loop for (mob-type-id x y z) in mob-template-list
        when (null (get-mob-* (level world) x y z))
        do
           (add-mob-to-level-list (level world) (make-instance 'mob :mob-type mob-type-id :x x :y y :z z))))

(defun populate-world-with-mobs (world mob-template-list placement-func)
  (loop for (mob-template-id . num) in mob-template-list do
    (loop repeat num
          do
             (funcall placement-func world (make-instance 'mob :mob-type mob-template-id))))
  )

(defun adjust-mobs-after-creation (world mob-template-list)
  (declare (ignore mob-template-list))
  (loop for mob-id in (mob-id-list (level world))
        for mob = (get-mob-by-id mob-id)
        do
           (update-visible-mobs mob)
           ))

(defun find-unoccupied-place-around (world mob sx sy sz)
  (loop with min-x = sx
        with max-x = sx
        with min-y = sy
        with max-y = sy
        with max-x-level = (array-dimension (terrain (level *world*)) 0)
        with max-y-level = (array-dimension (terrain (level *world*)) 1)
        for cell-list = nil
        do
           ;; prepare the list of cells
           ;; north 
           (setf cell-list (append cell-list (loop with y = min-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; east
           (setf cell-list (append cell-list (loop with x = max-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))
           ;; south
           (setf cell-list (append cell-list (loop with y = max-y
                                                   for x from min-x to max-x
                                                   collect (cons x y))))
           ;; west
           (setf cell-list (append cell-list (loop with x = min-x
                                                   for y from min-y to max-y
                                                   collect (cons x y))))

           ;; iterate through the list of cells
           (loop for (x . y) in cell-list
                 when (and (>= x 0) (< x max-x-level) (>= y 0) (< y max-y-level)
                           (eq (check-move-on-level mob x y sz) t)
                           ;(not (get-mob-* (level world) x y))
                           (get-terrain-type-trait (get-terrain-* (level world) x y sz) +terrain-trait-opaque-floor+)
                           (/= (get-level-connect-map-value (level world) x y sz (if (riding-mob-id mob)
                                                                                   (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                                   (map-size mob))
                                                            (get-mob-move-mode mob))
                               +connect-room-none+))
                   do
                      (setf (x mob) x (y mob) y (z mob) sz)
                      (add-mob-to-level-list (level world) mob)
                      (return-from find-unoccupied-place-around mob))

           ;; if the loop is not over - increase the boundaries
           (decf min-x)
           (decf min-y)
           (incf max-x)
           (incf max-y)
           ))
 
(defun find-unoccupied-place-outside (world mob)
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (not (and (> x 7) (< x (- max-x 7)) (> y 7) (< y (- max-y 7))))
                   (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* (level world) x y z))
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (not (mob-ability-p mob +mob-abil-demon+))
                       (and (mob-ability-p mob +mob-abil-demon+)
                            (loop for feature-id in (feature-id-list (level world))
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-mimic (world mob1 mob2 mob3 &key (inside nil))
  ;; function specifically for mimics
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (if inside
                     (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                     (not (and (> x 7) (< x (- max-x 7)) (> y 7) (< y (- max-y 7)))))
                     
                   (eq (check-move-on-level mob1 (1- x) (1- y) z) t)
                   (eq (check-move-on-level mob2 (1+ x) (1- y) z) t)
                   (eq (check-move-on-level mob3 x (1+ y) z) t)

                   (not (get-mob-* (level world) (1- x) (1- y) z))
                   (not (get-mob-* (level world) (1+ x) (1- y) z))
                   (not (get-mob-* (level world) x (1+ y) z))

                   (get-terrain-type-trait (get-terrain-* (level world) (1- x) (1- y) z) +terrain-trait-opaque-floor+)
                   (get-terrain-type-trait (get-terrain-* (level world) (1+ x) (1- y) z) +terrain-trait-opaque-floor+)
                   (get-terrain-type-trait (get-terrain-* (level world) x (1+ y) z) +terrain-trait-opaque-floor+)

                   (/= (get-level-connect-map-value (level world) (1- x) (1- y) z (if (riding-mob-id mob1)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob1)))
                                                                          (map-size mob1))
                                                    (get-mob-move-mode mob1))
                       +connect-room-none+)
                   (/= (get-level-connect-map-value (level world) (1+ x) (1- y) z (if (riding-mob-id mob2)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob2)))
                                                                          (map-size mob2))
                                                    (get-mob-move-mode mob2))
                       +connect-room-none+)
                   (/= (get-level-connect-map-value (level world) x (1+ y) z (if (riding-mob-id mob3)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob3)))
                                                                          (map-size mob3))
                                                    (get-mob-move-mode mob3))
                       +connect-room-none+)
                   )
        finally (setf (x mob1) (1- x) (y mob1) (1- y) (z mob1) z)
                (add-mob-to-level-list (level world) mob1)
                (setf (x mob2) (1+ x) (y mob2) (1- y) (z mob2) z)
                (add-mob-to-level-list (level world) mob2)
                (setf (x mob3) x (y mob3) (1+ y) (z mob3) z)
                (add-mob-to-level-list (level world) mob3)
        ))

(defun find-unoccupied-place-inside (world mob)
  (loop with max-x = (array-dimension (terrain (level world)) 0)
        with max-y = (array-dimension (terrain (level world)) 1)
        for x = (random max-x)
        for y = (random max-y)
        for z = 2
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* (level world) x y z))
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (and (not (mob-ability-p mob +mob-abil-demon+))
                            (not (mob-ability-p mob +mob-abil-angel+)))
                       (and (or (mob-ability-p mob +mob-abil-demon+)
                                (mob-ability-p mob +mob-abil-angel+))
                            (loop for feature-id in (feature-id-list (level world))
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  when (and (= (feature-type feature) +feature-start-strong-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) *repel-demons-dist-strong*))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-portal (world mob)
  (loop with portals-list = (loop for feature-id in (feature-id-list (level world))
                                  for feature = (get-feature-by-id feature-id)
                                  when (= (feature-type feature) +feature-demonic-portal+)
                                    collect feature)
        for portal = (nth (random (length portals-list)) portals-list)
        for x = (+ (1- (x portal)) (random 3))
        for y = (+ (1- (y portal)) (random 3))
        for z = 2
        until (and (or (/= x (x portal)) (/= y (y portal)))
                   (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* (level world) x y z))
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   )
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-demon-point (world mob)
  (loop with points-list = (loop for feature-id in (feature-id-list (level world))
                                  for feature = (get-feature-by-id feature-id)
                                  when (= (feature-type feature) +feature-start-demon-point+)
                                    collect feature)
        for point = (nth (random (length points-list)) points-list)
        for x = (x point)
        for y = (y point)
        for z = 2
        until (and (eq (check-move-on-level mob x y z) t)
                   (not (get-mob-* (level world) x y z))
                   (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-opaque-floor+)
                   (/= (get-level-connect-map-value (level world) x y z (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   )
        finally (setf (x mob) x (y mob) y (z mob) z)
                (add-mob-to-level-list (level world) mob)))

(defun find-unoccupied-place-on-top (world mob)
  ;(setf (z mob) (1- (array-dimension (terrain (level *world*)) 2)))
  
  (loop with max-x = (array-dimension (terrain (level *world*)) 0)
        with max-y = (array-dimension (terrain (level *world*)) 1)
        with nz = nil
        for x = (random max-x)
        for y = (random max-y)
        for z = (1- (array-dimension (terrain (level *world*)) 2))
        do
           (setf (x mob) x (y mob) y (z mob) z)
           (setf nz (apply-gravity mob)) 
        until (and (and (> x 10) (< x (- max-x 10)) (> y 10) (< y (- max-y 10)))
                   (get-terrain-type-trait (get-terrain-* (level world) x y nz) +terrain-trait-opaque-floor+)
                   nz
                   (> nz 2)
                   (not (get-mob-* (level world) x y nz))
                   (eq (check-move-on-level mob x y nz) t)
                   (/= (get-level-connect-map-value (level world) x y nz (if (riding-mob-id mob)
                                                                          (map-size (get-mob-by-id (riding-mob-id mob)))
                                                                          (map-size mob))
                                                    (get-mob-move-mode mob))
                       +connect-room-none+)
                   (or (not (mob-ability-p mob +mob-abil-demon+))
                       (and (mob-ability-p mob +mob-abil-demon+)
                            (loop for feature-id in (feature-id-list (level world))
                                  for feature = (get-feature-by-id feature-id)
                                  with result = t
                                  when (and (= (feature-type feature) +feature-start-repel-demons+)
                                            (< (get-distance x y (x feature) (y feature)) 15))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
        finally (setf (x mob) x (y mob) y (z mob) nz)
                (add-mob-to-level-list (level world) mob)))

(defun find-player-start-position (world mob feature-type-id)
  (loop for feature-id in (feature-id-list (level world))
        for feature = (get-feature-by-id feature-id)
        when (= (feature-type feature) feature-type-id)
          do
             (setf (x mob) (x feature) (y mob) (y feature) (z mob) (z feature))
             (add-mob-to-level-list (level world) mob)
             (loop-finish)))

(defun find-unoccupied-place-water (world mob)
  (let ((water-cells nil)
        (r-cell))
    (loop for x from 0 below (array-dimension (terrain (level *world*)) 0) do
      (loop for y from 0 below (array-dimension (terrain (level *world*)) 1) do
        (loop for z from 0 below (array-dimension (terrain (level *world*)) 2)
              when (and (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-water+)
                        (eq (check-move-on-level mob x y z) t))
                do
                   (push (list x y z) water-cells))))
    (if water-cells
      (progn
        (setf r-cell (nth (random (length water-cells)) water-cells))
        (setf (x mob) (first r-cell) (y mob) (second r-cell) (z mob) (third r-cell))
        (add-mob-to-level-list (level world) mob))
      (progn
        (find-unoccupied-place-outside world mob)))
    )
  )

(defun place-demonic-runes (world)
  (let ((demonic-runes ())
        (rune-list (list +feature-demonic-rune-flesh+ +feature-demonic-rune-flesh+
                         +feature-demonic-rune-invite+ +feature-demonic-rune-invite+
                         +feature-demonic-rune-away+ +feature-demonic-rune-away+
                         +feature-demonic-rune-transform+ +feature-demonic-rune-transform+
                         +feature-demonic-rune-barrier+ +feature-demonic-rune-barrier+
                         +feature-demonic-rune-all+ +feature-demonic-rune-all+
                         +feature-demonic-rune-decay+ +feature-demonic-rune-decay+)))
    (loop with max-x = (array-dimension (terrain (level *world*)) 0)
          with max-y = (array-dimension (terrain (level *world*)) 1)
          with max-z = (array-dimension (terrain (level *world*)) 2)
          with cur-rune = 0
          for x = (random max-x)
          for y = (random max-y)
          for z = (random max-z)
          while (< (length demonic-runes) (length rune-list)) do
            (when (and (get-terrain-type-trait (get-terrain-* (level world) x y z) +terrain-trait-can-have-rune+)
                       (null (find (list x y z) demonic-runes :test #'(lambda (a b)
                                                                        (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 6)
                                                                          t
                                                                          nil)
                                                                        ))))
              (push (list x y z (nth cur-rune rune-list)) demonic-runes)
              (incf cur-rune)))
    (loop for (x y z feature-type-id) in demonic-runes do
      ;;(format t "PLACE RUNE ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id feature-type-id)) x y z)
      (add-feature-to-level-list (level world) (make-instance 'feature :feature-type feature-type-id :x x :y y :z z))
      )))
            
          

(defun place-reserved-buildings-forest (reserved-level)
  (let ((result))
    ;; place +building-city-park-tiny+ and +building-city-park-3+ along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-forest-border+)
             (setf (aref reserved-level x (1- (array-dimension reserved-level 1)) 2) +building-city-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-park-3+ x 1 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ x 1 2 reserved-level)
               (push (list +building-city-park-3+ x 1 2) result))
             (when (level-city-can-place-build-on-grid +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (push (list +building-city-park-3+ x (- (array-dimension reserved-level 1) 3) 2) result)))
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-forest-border+)
             (setf (aref reserved-level (1- (array-dimension reserved-level 0)) y 2) +building-city-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-park-3+ 1 y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ 1 y 2 reserved-level)
               (push (list +building-city-park-3+ 1 y 2) result))
             (when (level-city-can-place-build-on-grid +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (push (list +building-city-park-3+ (- (array-dimension reserved-level 0) 3) y 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-park-tiny+)
                  (= (aref reserved-level x y 2) +building-city-forest-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-ruined-forest (reserved-level)
  (let ((result))
    ;; place +building-city-park-tiny+ and +building-city-park-3+ along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-forest-border+)
             (setf (aref reserved-level x (1- (array-dimension reserved-level 1)) 2) +building-city-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-ruined-park-3+ x 1 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-ruined-park-3+ x 1 2 reserved-level)
               (push (list +building-city-ruined-park-3+ x 1 2) result))
             (when (level-city-can-place-build-on-grid +building-city-ruined-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-ruined-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (push (list +building-city-ruined-park-3+ x (- (array-dimension reserved-level 1) 3) 2) result)))
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-forest-border+)
             (setf (aref reserved-level (1- (array-dimension reserved-level 0)) y 2) +building-city-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-ruined-park-3+ 1 y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-ruined-park-3+ 1 y 2 reserved-level)
               (push (list +building-city-ruined-park-3+ 1 y 2) result))
             (when (level-city-can-place-build-on-grid +building-city-ruined-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-ruined-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (push (list +building-city-ruined-park-3+ (- (array-dimension reserved-level 0) 3) y 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-park-tiny+)
                  (= (aref reserved-level x y 2) +building-city-forest-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-corrupted-forest (reserved-level)
  (let ((result))
    ;; place +building-city-park-tiny+ and +building-city-park-3+ along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-corrupted-forest-border+)
             (setf (aref reserved-level x (1- (array-dimension reserved-level 1)) 2) +building-city-corrupted-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-corrupted-park-3+ x 1 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-corrupted-park-3+ x 1 2 reserved-level)
               (push (list +building-city-corrupted-park-3+ x 1 2) result))
             (when (level-city-can-place-build-on-grid +building-city-corrupted-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-corrupted-park-3+ x (- (array-dimension reserved-level 1) 3) 2 reserved-level)
               (push (list +building-city-corrupted-park-3+ x (- (array-dimension reserved-level 1) 3) 2) result)))
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-forest-border+)
             (setf (aref reserved-level (1- (array-dimension reserved-level 0)) y 2) +building-city-corrupted-forest-border+)
             (when (level-city-can-place-build-on-grid +building-city-corrupted-park-3+ 1 y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-corrupted-park-3+ 1 y 2 reserved-level)
               (push (list +building-city-corrupted-park-3+ 1 y 2) result))
             (when (level-city-can-place-build-on-grid +building-city-corrupted-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (level-city-reserve-build-on-grid +building-city-corrupted-park-3+ (- (array-dimension reserved-level 0) 3) y 2 reserved-level)
               (push (list +building-city-corrupted-park-3+ (- (array-dimension reserved-level 0) 3) y 2) result)))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-corrupted-park-tiny+)
                  (= (aref reserved-level x y 2) +building-city-corrupted-forest-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-island (reserved-level)
  (let ((result))
    ;; place water along the borders
    (loop for x from 0 below (array-dimension reserved-level 0)
          do
             (setf (aref reserved-level x 0 2) +building-city-sea+)
             (setf (aref reserved-level x 1 2) +building-city-sea+)
             (setf (aref reserved-level x 2 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 1) 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 2) 2) +building-city-sea+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 3) 2) +building-city-sea+))
            
    (loop for y from 0 below (array-dimension reserved-level 1)
          do
             (setf (aref reserved-level 0 y 2) +building-city-sea+)
             (setf (aref reserved-level 1 y 2) +building-city-sea+)
             (when (and (>= y 2) (<= y (- (array-dimension reserved-level 1) 3)))
               (setf (aref reserved-level 2 y 2) +building-city-sea+))
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 1) y 2) +building-city-sea+)
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) y 2) +building-city-sea+)
             (when (and (>= y 2) (<= y (- (array-dimension reserved-level 1) 3)))
               (setf (aref reserved-level (- (array-dimension reserved-level 0) 3) y 2) +building-city-sea+)))

    ;; place four piers - north, south, east, west
    (let ((min) (max) (r))
      ;; north
      (setf min 3 max (- (array-dimension reserved-level 0) 3))
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level r 1 2) +building-city-pier+)
      (setf (aref reserved-level r 2 2) +building-city-pier+)
      
      ;; south
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level r (- (array-dimension reserved-level 1) 2) 2) +building-city-pier+)
      (setf (aref reserved-level r (- (array-dimension reserved-level 1) 3) 2) +building-city-pier+)
      
      ;; west
      (setf min 3 max (- (array-dimension reserved-level 1) 3))
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level 1 r 2) +building-city-pier+)
      (setf (aref reserved-level 2 r 2) +building-city-pier+)

      ;; east
      (setf r (+ (random (- max min)) min))
      (setf (aref reserved-level (- (array-dimension reserved-level 1) 2) r 2) +building-city-pier+)
      (setf (aref reserved-level (- (array-dimension reserved-level 1) 3) r 2) +building-city-pier+))
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-sea+)
                  (= (aref reserved-level x y 2) +building-city-pier+)
                  (= (aref reserved-level x y 2) +building-city-island-ground-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defun place-reserved-buildings-barricaded-city (reserved-level)
  (let ((result))

    (place-land-arrival-border reserved-level)
   
    (loop for x from 1 below (1- (array-dimension reserved-level 0))
          do
             (setf (aref reserved-level x 1 2) +building-city-barricade-we+)
             (setf (aref reserved-level x (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-we+))

     ;; making lines along the city borders - west & east
    (loop for y from 1 below (1- (array-dimension reserved-level 1))
          do
             (setf (aref reserved-level 1 y 2) +building-city-barricade-ns+)
             (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) y 2) +building-city-barricade-ns+))

    ;; making barricade corners
    (setf (aref reserved-level 1 1 2) +building-city-barricade-se+)
    (setf (aref reserved-level 1 (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-ne+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) 1 2) +building-city-barricade-sw+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) (- (array-dimension reserved-level 1) 2) 2) +building-city-barricade-nw+)

    ;; making entrances to the city
    (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) 1 2) +building-city-reserved+)
    (setf (aref reserved-level 1 (truncate (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    (setf (aref reserved-level (- (array-dimension reserved-level 0) 2) (truncate (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    (setf (aref reserved-level (truncate (array-dimension reserved-level 0) 2) (- (array-dimension reserved-level 1) 2) 2) +building-city-reserved+)
    
    (loop for x from 0 below (array-dimension reserved-level 0) do
      (loop for y from 0 below (array-dimension reserved-level 1) do
        (when (or (= (aref reserved-level x y 2) +building-city-barricade-ns+)
                  (= (aref reserved-level x y 2) +building-city-barricade-we+)
                  (= (aref reserved-level x y 2) +building-city-barricade-ne+)
                  (= (aref reserved-level x y 2) +building-city-barricade-se+)
                  (= (aref reserved-level x y 2) +building-city-barricade-sw+)
                  (= (aref reserved-level x y 2) +building-city-barricade-nw+)
                  (= (aref reserved-level x y 2) +building-city-land-border+))
          (push (list (aref reserved-level x y 2) x y 2) result))))
    result))

(defconstant +reserved-building-army-post+ 0)
(defconstant +reserved-building-sigil-post+ 1)

(defun place-reserved-buildings-for-factions (faction-list reserved-level init-place-func &optional (buildings (list +reserved-building-army-post+ +building-city-army-post+
                                                                                                                     +reserved-building-sigil-post+ +building-city-sigil-post+)))
  (let ((building-list) (removed-build-coords ()) (added-builds ()))
    (setf building-list (funcall init-place-func reserved-level))

    (cond
      ;; if the military are defender - place army posts in the district
      ((find-if #'(lambda (a)
                    (if (and (= (first a) +faction-type-military+)
                             (= (second a) +mission-faction-defender+))
                      t
                      nil))
                faction-list)
       (progn
         (setf (aref reserved-level 4 4 2) (getf buildings +reserved-building-army-post+))
         (setf (aref reserved-level (- (array-dimension reserved-level 0) 5) 4 2) (getf buildings +reserved-building-army-post+))
         (setf (aref reserved-level 4 (- (array-dimension reserved-level 1) 5) 2) (getf buildings +reserved-building-army-post+))
         (setf (aref reserved-level (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 5) 2) (getf buildings +reserved-building-army-post+))
         
         (setf removed-build-coords (list (list 4 4 2)
                                          (list 4 5 2)
                                          (list 5 4 2)
                                          (list 5 5 2)
                                          (list (- (array-dimension reserved-level 0) 5) 4 2)
                                          (list (- (array-dimension reserved-level 0) 5) 5 2)
                                          (list (- (array-dimension reserved-level 0) 6) 4 2)
                                          (list (- (array-dimension reserved-level 0) 6) 5 2)
                                          (list 4 (- (array-dimension reserved-level 1) 5) 2)
                                          (list 5 (- (array-dimension reserved-level 1) 6) 2)
                                          (list 4 (- (array-dimension reserved-level 1) 6) 2)
                                          (list 5 (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 6) 2)
                                          (list (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 6) 2)))
         
         (loop for (x y z) in removed-build-coords do
           (setf (aref reserved-level x y z) (getf buildings +reserved-building-army-post+)))
         
         (setf added-builds (list (list (getf buildings +reserved-building-army-post+) 4 4 2)
                                  (list (getf buildings +reserved-building-army-post+) (- (array-dimension reserved-level 0) 6) 4 2)
                                  (list (getf buildings +reserved-building-army-post+) 4 (- (array-dimension reserved-level 1) 6) 2)
                                  (list (getf buildings +reserved-building-army-post+) (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 6) 2)
                                  ))))
      
      ;; if the demons are defender - place sigil posts in the district
      ((find-if #'(lambda (a)
                    (if (and (= (first a) +faction-type-demons+)
                             (= (second a) +mission-faction-defender+))
                      t
                      nil))
                faction-list)
       (progn
         (setf (aref reserved-level 4 4 2) (getf buildings +reserved-building-sigil-post+))
         (setf (aref reserved-level (- (array-dimension reserved-level 0) 5) 4 2) (getf buildings +reserved-building-sigil-post+))
         (setf (aref reserved-level 4 (- (array-dimension reserved-level 1) 5) 2) (getf buildings +reserved-building-sigil-post+))
         (setf (aref reserved-level (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 5) 2) (getf buildings +reserved-building-sigil-post+))
         
         (setf removed-build-coords (list (list 4 4 2)
                                          (list 4 5 2)
                                          (list 5 4 2)
                                          (list 5 5 2)
                                          (list (- (array-dimension reserved-level 0) 5) 4 2)
                                          (list (- (array-dimension reserved-level 0) 5) 5 2)
                                          (list (- (array-dimension reserved-level 0) 6) 4 2)
                                          (list (- (array-dimension reserved-level 0) 6) 5 2)
                                          (list 4 (- (array-dimension reserved-level 1) 5) 2)
                                          (list 5 (- (array-dimension reserved-level 1) 6) 2)
                                          (list 4 (- (array-dimension reserved-level 1) 6) 2)
                                          (list 5 (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 5) 2)
                                          (list (- (array-dimension reserved-level 0) 5) (- (array-dimension reserved-level 1) 6) 2)
                                          (list (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 6) 2)))
         
         (loop for (x y z) in removed-build-coords do
           (setf (aref reserved-level x y z) (getf buildings +reserved-building-sigil-post+)))
         
         (setf added-builds (list (list (getf buildings +reserved-building-sigil-post+) 4 4 2)
                                  (list (getf buildings +reserved-building-sigil-post+) (- (array-dimension reserved-level 0) 6) 4 2)
                                  (list (getf buildings +reserved-building-sigil-post+) 4 (- (array-dimension reserved-level 1) 6) 2)
                                  (list (getf buildings +reserved-building-sigil-post+) (- (array-dimension reserved-level 0) 6) (- (array-dimension reserved-level 1) 6) 2)
                                  )))))
    
    ;; remove the buildings from the designated places if there were any
    (loop for (x y z) in removed-build-coords do
      (setf building-list (remove (find-if #'(lambda (a)
                                               (multiple-value-bind (bw bh) (get-building-grid-dim (get-building-type (first a)))
                                                 (if (and (>= x (second a)) (< x (+ (second a) bw))
                                                          (>= y (third a)) (< y (+ (third a) bh))
                                                          (= (fourth a) z))
                                                   t
                                                   nil)))
                                           building-list)
                                  building-list)))

    (when added-builds
      (setf building-list (append building-list added-builds)))
    
    building-list))

(defun set-up-outdoor-light (level light-power)
  (setf (outdoor-light level) light-power)

  ;; propagate light from above to determine which parts of the map are outdoor and which are "inside"
  ;; also set up all stationary light sources
  (loop for x from 0 below (array-dimension (light-map level) 0) do
    (loop for y from 0 below (array-dimension (light-map level) 1)
          for light-pwr = 100
          do
             (loop for z from (1- (array-dimension (light-map level) 2)) downto 0
                   do
                      (setf (aref (light-map level) x y z) light-pwr)
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+)
                        (setf light-pwr 0))
                      (when (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+)
                        (add-light-source level (make-light-source x y z (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-light-source+))))
                   )))

  )

(defun replace-gold-features-with-items (world mob-template-list)
  (declare (ignore mob-template-list))
  ;; remove the gold starting feature and replace it with actual gold so that there are guaranteed 1500$ on the level
  (let ((total-gold-items (loop for feature-id in (feature-id-list (level world))
                                for lvl-feature = (get-feature-by-id feature-id)
                                when (= (feature-type lvl-feature) +feature-start-gold-small+)
                                  count lvl-feature)))
    
    (loop for feature-id in (feature-id-list (level world))
          for lvl-feature = (get-feature-by-id feature-id)
          when (= (feature-type lvl-feature) +feature-start-gold-small+)
            do
               (add-item-to-level-list (level world) (make-instance 'item :item-type +item-type-coin+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature)
                                                                          :qty (+ (round 1250 total-gold-items) (random 51))))
               (remove-feature-from-level-list (level world) lvl-feature)
               (remove-feature-from-world lvl-feature)
          )
    ))

(defun set-up-win-conditions (game-event-list faction-list mission-id)
  (loop for (faction-id game-event-id) in (win-condition-list (get-mission-scenario-by-id mission-id))
        when (find-if #'(lambda (a)
                          (if (and (= (first a) faction-id)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)
                                       (= (second a) +mission-faction-delayed+)))
                            t
                            nil))
                      faction-list)
          do
             (pushnew game-event-id game-event-list))
  game-event-list)
