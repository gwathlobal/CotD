(in-package :cotd)

(defparameter *game-events* (make-hash-table))

(defconstant +game-event-demon-attack-win-for-angels+ 0)
(defconstant +game-event-demon-attack-win-for-demons+ 1)
(defconstant +game-event-demon-attack-win-for-military+ 2)
(defconstant +game-event-lose-game-died+ 3)
(defconstant +game-event-snow-falls+ 4)
(defconstant +game-event-lose-game-possessed+ 5)
(defconstant +game-event-adjust-outdoor-light+ 6)
(defconstant +game-event-win-for-thief+ 7)
(defconstant +game-event-rain-falls+ 8)
(defconstant +game-event-win-for-eater+ 9)
(defconstant +game-event-win-for-ghost+ 10)
(defconstant +game-event-unnatural-darkness+ 11)
(defconstant +game-event-constant-reanimation+ 12)


(defconstant +game-event-player-died+ 15)
(defconstant +game-event-demon-attack-win-for-church+ 16)
(defconstant +game-event-demon-attack-win-for-satanists+ 17)
(defconstant +game-event-demon-raid-win-for-angels+ 18)
(defconstant +game-event-demon-raid-win-for-demons+ 19)
(defconstant +game-event-demon-raid-win-for-military+ 20)
(defconstant +game-event-demon-raid-win-for-church+ 21)
(defconstant +game-event-demon-raid-win-for-satanists+ 22)
(defconstant +game-event-demon-steal-win-for-angels+ 23)
(defconstant +game-event-demon-steal-win-for-demons+ 24)
(defconstant +game-event-demon-steal-win-for-military+ 25)
(defconstant +game-event-demon-steal-win-for-church+ 26)
(defconstant +game-event-demon-steal-win-for-satanists+ 27)
(defconstant +game-event-demon-conquest-win-for-angels+ 28)
(defconstant +game-event-demon-conquest-win-for-demons+ 29)
(defconstant +game-event-demon-conquest-win-for-military+ 30)
(defconstant +game-event-demon-conquest-win-for-church+ 31)
(defconstant +game-event-demon-conquest-win-for-satanists+ 32)
(defconstant +game-event-military-conquest-win-for-angels+ 33)
(defconstant +game-event-military-conquest-win-for-demons+ 34)
(defconstant +game-event-military-conquest-win-for-military+ 35)
(defconstant +game-event-military-conquest-win-for-satanists+ 36)
(defconstant +game-event-military-raid-win-for-angels+ 37)
(defconstant +game-event-military-raid-win-for-demons+ 38)
(defconstant +game-event-military-raid-win-for-military+ 39)
(defconstant +game-event-military-raid-win-for-satanists+ 40)
(defconstant +game-event-angelic-steal-win-for-angels+ 41)
(defconstant +game-event-angelic-steal-win-for-demons+ 42)
(defconstant +game-event-angelic-steal-win-for-military+ 43)
(defconstant +game-event-angelic-steal-win-for-satanists+ 44)
(defconstant +game-event-delayed-arrival-military+ 45)
(defconstant +game-event-delayed-arrival-angels+ 46)
(defconstant +game-event-delayed-arrival-demons+ 47)

(defconstant +game-event-campaign-demon-win+ 48)
(defconstant +game-event-campaign-military-win+ 49)
(defconstant +game-event-campaign-angel-win+ 50)

(defconstant +game-event-eliminate-satanists-win-for-angels+ 51)
(defconstant +game-event-eliminate-satanists-win-for-demons+ 52)
(defconstant +game-event-eliminate-satanists-win-for-military+ 53)
(defconstant +game-event-eliminate-satanists-win-for-church+ 54)
(defconstant +game-event-eliminate-satanists-win-for-satanists+ 55)

(defconstant +game-event-campaign-satanists-move+ 56)
(defconstant +game-event-campaign-flesh-gathered+ 57)
(defconstant +game-event-campaign-move-military+ 58)
(defconstant +game-event-campaign-move-demons+ 59)

(defconstant +game-event-angelic-sabotage-win-for-angels+ 60)
(defconstant +game-event-angelic-sabotage-win-for-demons+ 61)

(defconstant +game-event-military-sabotage-win-for-demons+ 62)
(defconstant +game-event-military-sabotage-win-for-military+ 63)

(defenum:defenum game-over-enum (:game-over-player-dead
                                 :game-over-demons-won
                                 :game-over-angels-won
                                 :game-over-military-won
                                 :game-over-church-won
                                 :game-over-satanists-won
                                 :game-over-player-possessed
                                 :game-over-thief-won
                                 :game-over-eater-won
                                 :game-over-ghost-won))

(defenum:defenum campaign-over-enum (:campaign-over-demons-conquer
                                     :campaign-over-demons-gather
                                     :campaign-over-angels-won
                                     :campaign-over-military-won
                                     ))

(defclass game-event ()
  ((id :initarg :id :accessor id)
   (descr-func :initarg :descr-func :accessor descr-func) ;; a lambda with no params
   (disabled :initform nil :initarg :disabled :accessor disabled)
   (on-check :initarg :on-check :accessor on-check)
   (on-trigger :initarg :on-trigger :accessor on-trigger)))

(defun set-game-event (game-event)
  (setf (gethash (id game-event) *game-events*) game-event))

(defun get-game-event-by-id (game-event-id)
  (gethash game-event-id *game-events*))
