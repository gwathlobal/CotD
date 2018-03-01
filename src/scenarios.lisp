(in-package :cotd)

;;---------------------------------
;; SCENARIO-FEATURE-TYPE Constants
;;---------------------------------

(defconstant +scenario-feature-weather+ 0)
(defconstant +scenario-feature-city-layout+ 1)
(defconstant +scenario-feature-player-faction+ 2)
(defconstant +scenario-feature-time-of-day+ 3)

;;---------------------------------
;; SCENARIO-FEATURE Constants
;;---------------------------------

;; layout constants are used in highscores, so old ones should not be edited otherwise the the information presented from highscores table will be retroactively changed

(defconstant +weather-type-clear+ 0)
(defconstant +weather-type-snow+ 1)
(defconstant +city-layout-test+ 2)
(defconstant +city-layout-normal+ 3)
(defconstant +city-layout-river+ 4)
(defconstant +city-layout-port+ 5)
(defconstant +player-faction-player+ 6)
(defconstant +player-faction-test+ 7)
(defconstant +player-faction-angels+ 8)
(defconstant +player-faction-demons+ 9)
(defconstant +city-layout-forest+ 10)
(defconstant +city-layout-island+ 11)
(defconstant +player-faction-military-chaplain+ 12)
(defconstant +city-layout-barricaded-city+ 13)
(defconstant +player-faction-military-scout+ 14)
(defconstant +tod-type-night+ 15)
(defconstant +tod-type-day+ 16)
(defconstant +tod-type-morning+ 17)
(defconstant +tod-type-evening+ 18)
(defconstant +player-faction-thief+ 19)
(defconstant +player-faction-satanist+ 20)
(defconstant +player-faction-church+ 21)
(defconstant +player-faction-shadows+ 22)
(defconstant +player-faction-trinity-mimics+ 23)
(defconstant +weather-type-rain+ 24)
(defconstant +player-faction-eater+ 25)
(defconstant +player-faction-puppet+ 26)
(defconstant +player-faction-ghost+ 27)

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
    (adjust-array *scenario-features* (list (1+ (sf-id scenario-feature)))))
  (setf (aref *scenario-features* (sf-id scenario-feature)) scenario-feature))

(defun get-scenario-feature-by-id (scenario-feature-id)
  (aref *scenario-features* scenario-feature-id))

(defun get-all-scenario-features-by-type (scenario-feature-type-id &optional (include-debug t))
  (loop for sf across *scenario-features*
        when (or (and (= (sf-type sf) scenario-feature-type-id)
                      include-debug
                      (not (sf-disabled sf)))
                 (and (= (sf-type sf) scenario-feature-type-id)
                      (not include-debug)
                      (not (sf-debug sf))
                      (not (sf-disabled sf))))
          collect (sf-id sf)))

;;---------------------------------
;; Get max buildings functions
;;---------------------------------

(defun get-max-buildings-normal ()
  (let ((max-building-types (make-hash-table)))
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
    (setf (gethash +building-type-church+ max-building-types) 1)
    (setf (gethash +building-type-satanists+ max-building-types) 1)
    (setf (gethash +building-type-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-library+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-bank+ max-building-types) 0)
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
  building-type-hash-table)

(defun setup-objective-based-on-faction (mob-type-id mission-id)
  (second (find (faction (get-mob-type-by-id mob-type-id)) (objective-list (get-mission-scenario-by-id mission-id)) :key #'(lambda (a)
                                                                                                                             (first a)))))

(defun scenario-delayed-faction-setup (faction-list game-event-list)

  ;; add delayed military
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-delayed-arrival-military+ game-event-list))

  ;; add delayed angels
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (= (second a) +mission-faction-delayed+))
                       t
                       nil))
                 faction-list)
    (push +game-event-delayed-arrival-angels+ game-event-list))
  
  game-event-list)

(defun scenario-present-faction-setup (player-faction-scenario-id faction-list mob-func-list)
  (push #'adjust-initial-visibility mob-func-list)
  (push #'replace-gold-features-with-items mob-func-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; populate the world with demonic runes
            (place-demonic-runes world))
        mob-func-list)

  ;; remove the land arrival feature and add delayed arrival points to level
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (= (feature-type lvl-feature) +feature-delayed-arrival-point+)
                            
                    do
                       (when (not (get-terrain-type-trait (get-terrain-* (level world) (x lvl-feature) (y lvl-feature) (z lvl-feature)) +terrain-trait-blocks-move+))
                         (push (list (x lvl-feature) (y lvl-feature) (z lvl-feature)) (delayed-arrival-points (level world))))
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)
  
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            ;; remove the player satanist starting feature
            (loop for feature-id in (feature-id-list (level world))
                  for lvl-feature = (get-feature-by-id feature-id)
                  when (get-feature-type-trait lvl-feature +feature-trait-remove-on-dungeon-generation+)
                    do
                       (remove-feature-from-level-list (level world) lvl-feature)
                       (remove-feature-from-world lvl-feature))
            )
        mob-func-list)

  ;; adjust coordinates of all horses to their riders, otherwise all horses created for scouts will have coords of (0, 0)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (loop for mob-id in (mob-id-list (level world))
                  for horse = (get-mob-by-id mob-id)
                  for rider = (if (mounted-by-mob-id horse)
                                (get-mob-by-id (mounted-by-mob-id horse))
                                nil)
                  when rider
                    do
                       (setf (x horse) (x rider) (y horse) (y rider) (z horse) (z rider)))
            ;; remove the glitch from (0, 0, 0)
            (setf (aref (mobs (level world)) 0 0 0) nil)
            )
        mob-func-list)
  
  ;; populate the world with 1 ghost
  (when (and (/= player-faction-scenario-id +player-faction-ghost+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-ghost+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-ghost+ 1))
                                        #'find-unoccupied-place-inside))
          mob-func-list))
  
  ;; populate the world with 1 eater of the dead
  (when (and (/= player-faction-scenario-id +player-faction-eater+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-eater+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-eater-of-the-dead+ 1))
                                        #'find-unoccupied-place-water))
          mob-func-list))
  
  ;; populate the world with 1 thief
  (when (and (/= player-faction-scenario-id +player-faction-thief+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-criminals+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-thief+ 1))
                                        #'find-unoccupied-place-on-top))
          mob-func-list))

  ;; populate the world with the 5 groups of military, where each group has 1 chaplain, 2 sargeants and 3 soldiers
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-military+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
              
              (loop repeat 5
                    do
                       (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+ :objectives (setup-objective-based-on-faction +mob-type-chaplain+
                                                                                                                                       (mission-scenario (level world))))))
                         (find-unoccupied-place-outside world chaplain)
                         (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                               (cons +mob-type-scout+ 1)
                                                               (cons +mob-type-soldier+ 2)
                                                               (cons +mob-type-gunner+ 1))
                                                   #'(lambda (world mob)
                                                       (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
              )
          mob-func-list))

  ;; add an additional group of military if there is no player chaplain
  (when (and (/= player-faction-scenario-id +player-faction-military-chaplain+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-military+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (let ((chaplain (make-instance 'mob :mob-type +mob-type-chaplain+ :objectives (setup-objective-based-on-faction +mob-type-chaplain+
                                                                                                                              (mission-scenario (level world))))))
                (find-unoccupied-place-outside world chaplain)
                (populate-world-with-mobs world (list (cons +mob-type-sergeant+ 1)
                                                      (cons +mob-type-scout+ 1)
                                                      (cons +mob-type-soldier+ 2)
                                                      (cons +mob-type-gunner+ 1))
                                          #'(lambda (world mob)
                                              (find-unoccupied-place-around world mob (x chaplain) (y chaplain) (z chaplain))))))
          mob-func-list))
  
  ;; populate the world with the outsider beasts, of which (humans / 15) will be fiends and 1 will be gargantaur
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (populate-world-with-mobs world (list (cons +mob-type-gargantaur+ 1)
                                                  (cons +mob-type-wisp+ (truncate (total-humans world) 15)))
                                      #'find-unoccupied-place-inside))
        mob-func-list))
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            
            (populate-world-with-mobs world (list (cons +mob-type-fiend+ (truncate (total-humans world) 15)))
                                      #'find-unoccupied-place-inside))
        mob-func-list))

  ;; populate the world with the number of angels = humans / 11
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-angels+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              (populate-world-with-mobs world (list (cons +mob-type-angel+ (- (truncate (total-humans world) 11) 1)))
                                        #'find-unoccupied-place-outside)
              )
          mob-func-list))
  
  ;; populate the world with trinity mimics
  (when (and (/= player-faction-scenario-id +player-faction-trinity-mimics+)
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-angels+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              
              ;; set up trinity mimics
              (let ((mob1 (make-instance 'mob :mob-type +mob-type-star-singer+ :objectives (setup-objective-based-on-faction +mob-type-star-singer+ (mission-scenario (level world)))))
                    (mob2 (make-instance 'mob :mob-type +mob-type-star-gazer+ :objectives (setup-objective-based-on-faction +mob-type-star-gazer+ (mission-scenario (level world)))))
                    (mob3 (make-instance 'mob :mob-type +mob-type-star-mender+ :objectives (setup-objective-based-on-faction +mob-type-star-mender+ (mission-scenario (level world))))))
                
                (setf (mimic-id-list mob1) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob2) (list (id mob1) (id mob2) (id mob3)))
                (setf (mimic-id-list mob3) (list (id mob1) (id mob2) (id mob3)))
                (setf (name mob2) (name mob1) (name mob3) (name mob1))
                
                (find-unoccupied-place-mimic world mob1 mob2 mob3 :inside nil)))
          mob-func-list))

  ;; populate the world with the number of demons = humans / 4, of which 1 will be an archdemon, 15 will be demons
  ;; make some of them shadow demons if there is dark in the city
  (when (find-if #'(lambda (a)
                     (if (and (= (first a) +faction-type-demons+)
                              (or (= (second a) +mission-faction-present+)
                                  (= (second a) +mission-faction-attacker+)
                                  (= (second a) +mission-faction-defender+)))
                       t
                       nil))
                 faction-list)
    (push #'(lambda (world mob-template-list)
              (declare (ignore mob-template-list))
              (multiple-value-bind (year month day hour min sec) (get-current-date-time (player-game-time world))
                (declare (ignore year month day min sec))
                (populate-world-with-mobs world (if (and (>= hour 7) (< hour 19))
                                                  (list (cons +mob-type-archdemon+ 1)
                                                        (cons +mob-type-demon+ 15)
                                                        (cons +mob-type-imp+ (- (truncate (total-humans world) 4) 16)))
                                                  (list (if (zerop (random 2)) (cons +mob-type-archdemon+ 1) (cons +mob-type-shadow-devil+ 1))
                                                        (cons +mob-type-demon+ 7)
                                                        (cons +mob-type-shadow-demon+ 8)
                                                        (cons +mob-type-imp+ (- (truncate (total-humans world) 8) 16))
                                                        (cons +mob-type-shadow-imp+ (- (truncate (total-humans world) 8) 16))))
                                          #'find-unoccupied-place-inside)))
          mob-func-list))

  ;; populate world with malseraph puppets
  (when (and (or (/= player-faction-scenario-id +player-faction-puppet+))
             (find-if #'(lambda (a)
                          (if (and (= (first a) +faction-type-demons+)
                                   (or (= (second a) +mission-faction-present+)
                                       (= (second a) +mission-faction-attacker+)
                                       (= (second a) +mission-faction-defender+)))
                            t
                            nil))
                      faction-list))
  (push #'(lambda (world mob-template-list)
            (declare (ignore mob-template-list))
            (populate-world-with-mobs world (list (cons +mob-type-malseraph-puppet+ 1))
                                      #'find-unoccupied-place-inside))
        mob-func-list))
  
  (push #'create-mobs-from-template mob-func-list)
  mob-func-list)

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

(defun place-reserved-buildings-port-n (reserved-level)
  (let ((result))
    (loop for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   +building-city-pier+
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

(defun place-reserved-buildings-port-s (reserved-level)
  (let ((result) (max-y (1- (array-dimension reserved-level 1))))
    (loop for x from 0 below (array-dimension reserved-level 0)
          for building-type-id = (if (and (zerop (mod (1+ x) 5))
                                          (/= x (1- (array-dimension reserved-level 0))))
                                   +building-city-pier+
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

(defun place-reserved-buildings-port-e (reserved-level)
  (let ((result) (max-x (1- (array-dimension reserved-level 0))))
    (loop for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   +building-city-pier+
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

(defun place-reserved-buildings-port-w (reserved-level)
  (let ((result))
    (loop for y from 0 below (array-dimension reserved-level 1)
          for building-type-id = (if (and (zerop (mod (1+ y) 5))
                                          (/= y (1- (array-dimension reserved-level 1))))
                                   +building-city-pier+
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

(defun create-mobs-from-template (world mob-template-list)
  (loop for (mob-type-id x y z) in mob-template-list 
        do
           (add-mob-to-level-list (level world) (make-instance 'mob :mob-type mob-type-id :x x :y y :z z))))

(defun populate-world-with-mobs (world mob-template-list placement-func)
  (loop for (mob-template-id . num) in mob-template-list do
    (loop repeat num
          do
             (funcall placement-func world (make-instance 'mob :mob-type mob-template-id :objectives (setup-objective-based-on-faction mob-template-id (mission-scenario (level world)))))))
  )

(defun adjust-initial-visibility (world mob-template-list)
  (declare (ignore mob-template-list))
  ;(format t "ADJUST-INITIAL-VISIBILITY~%")
  (loop for mob-id in (mob-id-list (level world))
        for mob = (get-mob-by-id mob-id)
        do
           (update-visible-mobs mob)))

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
                                            (< (get-distance x y (x feature) (y feature)) 15))
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
                                            (< (get-distance x y (x feature) (y feature)) 15))
                                    do
                                       (setf result nil)
                                       (loop-finish)
                                  finally (return result)))))
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
                                                                        (if (< (get-distance-3d (first a) (second a) (third a) (first b) (second b) (third b)) 10)
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
