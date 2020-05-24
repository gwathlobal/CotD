(in-package :cotd)

(defenum:defenum game-state-enum (:game-state-start
                                  :game-state-init
                                  :game-state-main-menu
                                  :game-state-custom-scenario
                                  :game-state-campaign-map
                                  :game-state-campaign-scenario
                                  :game-state-quit))

(defclass game-manager ()
  ((game-state :initform :game-state-start :accessor game-manager/game-state :type game-state-enum)
   (game-slot-id :initform nil :initarg :game-slot-id :accessor game-manager/game-slot-id :type '(or null fixnum))))

(defun game-state-start->init ()
  (with-slots (game-state) *game-manager*
    (when (not (eq game-state :game-state-start))
      (error (format nil "GAME-STATE-START->INIT: Game state is ~A, not GAME-STATE-START" game-state)))
    (setf game-state :game-state-init)))

(defun game-state-init->menu ()
  (with-slots (game-state) *game-manager*
    (when (not (eq game-state :game-state-init))
      (error (format nil "GAME-STATE-INIT->MENU: Game state is ~A, not GAME-STATE-INIT" game-state)))
    (setf game-state :game-state-main-menu)))

(defun game-state-menu->quit ()
  (with-slots (game-state) *game-manager*
    (when (not (eq game-state :game-state-main-menu))
      (error (format nil "GAME-STATE-MENU->QUIT: Game state is ~A, not GAME-STATE-MAIN-MENU" game-state)))
    (setf game-state :game-state-quit)))

(defun game-state-menu->custom-scenario ()
  (with-slots (game-state) *game-manager*
    (when (not (eq game-state :game-state-main-menu))
      (error (format nil "GAME-STATE-MENU->CUSTOM-SCENARIO: Game state is ~A, not GAME-STATE-MAIN-MENU" game-state)))
    (setf game-state :game-state-custom-scenario)))

(defun game-state-custom-scenario->menu ()
  (with-slots (game-state) *game-manager*
    (when (not (eq game-state :game-state-custom-scenario))
      (error (format nil "GAME-STATE-CUSTOM-SCENARIO->MENU: Game state is ~A, not GAME-STATE-CUSTOM-SCENARIO" game-state)))
    (setf game-state :game-state-main-menu)))
