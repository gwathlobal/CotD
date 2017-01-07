(in-package :cotd)

(defclass world-for-angels (world)
  ())

(defclass world-for-demons (world)
  ())

(defclass world-for-humans (world)
  ())

(defgeneric check-win (world))

(defgeneric check-lose (world))

(defmethod check-win ((world world))
  nil)

(defmethod check-win ((world world-for-angels))
  (if (or (zerop (total-demons world))
          (and (mob-ability-p *player* +mob-abil-angel+)
               (= (mob-type *player*) +mob-type-archangel+)
               (>= (cur-fp *player*) (max-fp *player*))))
    t
    nil))

(defmethod check-win ((world world-for-demons))
  (if (or (zerop (total-angels world))
          (and (mob-ability-p *player* +mob-abil-demon+)
               (= (mob-type *player*) +mob-type-archdemon+)
               (>= (cur-fp *player*) (max-fp *player*))))
    t
    nil))

(defmethod check-win ((world world-for-humans))
  (if (zerop (total-demons world))
    t
    nil))

(defmethod check-lose ((world world))
  (if (check-dead *player*)
    t
    nil))
