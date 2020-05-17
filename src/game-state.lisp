(in-package :cotd)

(defclass game-manager ()
  ((game-slot-id :initform nil :initarg :game-slot-id :accessor game-manager/game-slot-id :type '(or null fixnum))))


