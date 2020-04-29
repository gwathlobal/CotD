
(in-package :cotd)

(defparameter *max-x-world-map* 5)
(defparameter *max-y-world-map* 5)

(defclass world-map ()
  ((cells :initform nil :accessor cells :type simple-array) ;; array of world-sector
   ))

(defun generate-empty-world-map (world-map world-time)
  (declare (ignore world-time))
  (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))

  (loop for x from 0 below *max-x-world-map* do
    (loop for y from 0 below *max-y-world-map* do
      (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x x :y y))))

  world-map)

(defun generate-test-world-map (world-map)
  (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))

  (setf (aref (cells world-map) 0 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+ :x 0 :y 0))
  (setf (aref (cells world-map) 1 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+ :x 1 :y 0))
  (setf (aref (cells world-map) 2 0) (make-instance 'world-sector :wtype +world-sector-normal-island+ :x 2 :y 0))
  (setf (aref (cells world-map) 3 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+ :x 3 :y 0))
  (setf (aref (cells world-map) 4 0) (make-instance 'world-sector :wtype +world-sector-normal-sea+ :x 4 :y 0))

  (setf (aref (cells world-map) 0 1) (make-instance 'world-sector :wtype +world-sector-abandoned-port+ :x 0 :y 1))
  (setf (aref (cells world-map) 1 1) (make-instance 'world-sector :wtype +world-sector-abandoned-port+ :x 1 :y 1))
  (setf (aref (cells world-map) 2 1) (make-instance 'world-sector :wtype +world-sector-abandoned-port+ :x 2 :y 1
                                                                  :feats (list (list +lm-feat-river+ (list :n)))))
  (setf (aref (cells world-map) 3 1) (make-instance 'world-sector :wtype +world-sector-normal-port+ :x 3 :y 1))
  (setf (aref (cells world-map) 4 1) (make-instance 'world-sector :wtype +world-sector-normal-port+ :x 4 :y 1))

  (setf (aref (cells world-map) 0 2) (make-instance 'world-sector :wtype +world-sector-abandoned-forest+ :x 0 :y 2))
  (setf (aref (cells world-map) 1 2) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :x 1 :y 2
                                                                  :feats (list (list +lm-feat-library+))
                                                                  :items (list +lm-item-holy-relic+)))
  (setf (aref (cells world-map) 2 2) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :x 2 :y 2
                                                                  :feats (list (list +lm-feat-river+ nil))
                                                                  :controlled-by +lm-controlled-by-demons+))
  (setf (aref (cells world-map) 3 2) (make-instance 'world-sector :wtype +world-sector-normal-lake+ :x 3 :y 2
                                                                  :feats (list (list +lm-feat-river+ nil))
                                                                  :controlled-by +lm-controlled-by-military+))
  (setf (aref (cells world-map) 4 2) (make-instance 'world-sector :wtype +world-sector-normal-forest+ :x 4 :y 2
                                                                  :feats (list (list +lm-feat-lair+))))

  (setf (aref (cells world-map) 0 3) (make-instance 'world-sector :wtype +world-sector-corrupted-forest+ :x 0 :y 3))
  (setf (aref (cells world-map) 1 3) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :x 1 :y 3
                                                                  :controlled-by +lm-controlled-by-demons+))
  (setf (aref (cells world-map) 2 3) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x 2 :y 3
                                                                  :feats (list (list +lm-feat-river+ nil) (list +lm-feat-lair+) (list +lm-feat-church+))
                                                                  :items (list +lm-item-holy-relic+)
                                                                  :controlled-by +lm-controlled-by-military+))
  (setf (aref (cells world-map) 3 3) (make-instance 'world-sector :wtype +world-sector-corrupted-residential+ :x 3 :y 3
                                                                  :controlled-by +lm-controlled-by-demons+))
  (setf (aref (cells world-map) 4 3) (make-instance 'world-sector :wtype +world-sector-normal-forest+ :x 4 :y 3))

  (setf (aref (cells world-map) 0 4) (make-instance 'world-sector :wtype +world-sector-normal-lake+ :x 0 :y 4
                                                                  :feats (list (list +lm-feat-library+))
                                                                  :items (list +lm-item-book-of-rituals+)))
  (setf (aref (cells world-map) 1 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+ :x 1 :y 4))
  (setf (aref (cells world-map) 2 4) (make-instance 'world-sector :wtype +world-sector-corrupted-forest+ :x 2 :y 4
                                                                  :feats (list (list +lm-feat-river+ nil))
                                                                  :controlled-by +lm-controlled-by-demons+))
  (setf (aref (cells world-map) 3 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+ :x 3 :y 4))
  (setf (aref (cells world-map) 4 4) (make-instance 'world-sector :wtype +world-sector-normal-forest+ :x 4 :y 4))

  (generate-feats-on-world-map world-map)
  
  ;;(generate-missions-on-world-map world-map world-time)

  
  
  world-map)

(defun generate-feats-for-world-sector (world-sector world-map)
  (let ((x (x world-sector))
        (y (y world-sector))
        (river-feat (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))
        (sea-feat (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a))))
        (barricade-feat (find +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))
        (can-barricade-func #'(lambda (sx sy tx ty)
                                (if (and (or (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-forest+)
                                             (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-lake+)
                                             (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-port+)
                                             (= (wtype (aref (cells world-map) sx sy)) +world-sector-normal-residential+)
                                             (= (controlled-by (aref (cells world-map) sx sy)) +lm-controlled-by-military+))
                                         (or (= (controlled-by (aref (cells world-map) tx ty)) +lm-controlled-by-demons+)
                                             (= (wtype (aref (cells world-map) tx ty)) +world-sector-corrupted-forest+)
                                             (= (wtype (aref (cells world-map) tx ty)) +world-sector-corrupted-lake+)
                                             (= (wtype (aref (cells world-map) tx ty)) +world-sector-corrupted-port+)
                                             (= (wtype (aref (cells world-map) tx ty)) +world-sector-corrupted-residential+)))
                                  t
                                  nil))))
    ;; add river features
    (when river-feat
      (when (and (>= (1- x) 0)
                 (find +lm-feat-river+ (feats (aref (cells world-map) (1- x) y)) :key #'(lambda (a) (first a))))
        (setf (second river-feat) (append (second river-feat) '(:w))))
      (when (and (>= (1- y) 0)
                 (find +lm-feat-river+ (feats (aref (cells world-map) x (1- y))) :key #'(lambda (a) (first a))))
        (setf (second river-feat) (append (second river-feat) '(:n))))
      (when (and (< (1+ x) *max-x-world-map*)
                 (find +lm-feat-river+ (feats (aref (cells world-map) (1+ x) y)) :key #'(lambda (a) (first a))))
        (setf (second river-feat) (append (second river-feat) '(:e))))
      (when (and (< (1+ y) *max-y-world-map*)
                 (find +lm-feat-river+ (feats (aref (cells world-map) x (1+ y))) :key #'(lambda (a) (first a))))
        (setf (second river-feat) (append (second river-feat) '(:s))))
      )

    ;; add sea features
    (when (and (>= (1- x) 0)
               (or (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-sea+)
                   (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-normal-island+)
                   (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-abandoned-island+)
                   (= (wtype (aref (cells world-map) (1- x) y)) +world-sector-corrupted-island+)))
      (if sea-feat
        (push :w (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :w)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (>= (1- y) 0)
               (or (= (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-sea+)
                   (= (wtype (aref (cells world-map) x (1- y))) +world-sector-normal-island+)
                   (= (wtype (aref (cells world-map) x (1- y))) +world-sector-abandoned-island+)
                   (= (wtype (aref (cells world-map) x (1- y))) +world-sector-corrupted-island+)))
      (if sea-feat
        (push :n (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :n)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ x) *max-x-world-map*)
               (or (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-sea+)
                   (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-normal-island+)
                   (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-abandoned-island+)
                   (= (wtype (aref (cells world-map) (1+ x) y)) +world-sector-corrupted-island+)))
      (if sea-feat
        (push :e (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :e)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ y) *max-y-world-map*)
               (or (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-sea+)
                   (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-normal-island+)
                   (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-abandoned-island+)
                   (= (wtype (aref (cells world-map) x (1+ y))) +world-sector-corrupted-island+)))
      (if sea-feat
        (push :s (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :s)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    
    ;; add barricade features
    (when (and (>= (1- x) 0)
               (funcall can-barricade-func x y (1- x) y))
      (if barricade-feat
        (push :w (second barricade-feat))
        (progn
          (push (list +lm-feat-barricade+ (list :w)) (feats (aref (cells world-map) x y)))
          (setf barricade-feat (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (>= (1- y) 0)
               (funcall can-barricade-func x y x (1- y)))
      (if barricade-feat
        (push :n (second barricade-feat))
        (progn
          (push (list +lm-feat-barricade+ (list :n)) (feats (aref (cells world-map) x y)))
          (setf barricade-feat (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ x) *max-x-world-map*)
               (funcall can-barricade-func x y (1+ x) y))
      (if barricade-feat
        (push :e (second barricade-feat))
        (progn
          (push (list +lm-feat-barricade+ (list :e)) (feats (aref (cells world-map) x y)))
          (setf barricade-feat (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ y) *max-y-world-map*)
               (funcall can-barricade-func x y x (1+ y)))
      (if barricade-feat
        (push :s (second barricade-feat))
        (progn
          (push (list +lm-feat-barricade+ (list :s)) (feats (aref (cells world-map) x y)))
          (setf barricade-feat (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    
    world-sector))

(defun generate-feats-on-world-map (world-map)
  (loop for y from 0 below *max-y-world-map* do
    (loop for x from 0 below *max-x-world-map* do
      (generate-feats-for-world-sector (aref (cells world-map) x y) world-map)))
  )

(defun generate-missions-on-world-map (world-map world-time)
  (dotimes (i (+ 3 (random 3)))
    (loop for rx = (random *max-x-world-map*)
          for ry = (random *max-y-world-map*)
          for avail-missions = (loop for mission-type being the hash-values in *mission-types*
                                     when (funcall (is-available-func mission-type) world-map rx ry)
                                       collect (id mission-type))
          for world-sector = (aref (cells world-map) rx ry)
          until (and (not (mission world-sector))
                     avail-missions)
          finally
             (let ((mission-type-id (nth (random (length avail-missions)) avail-missions)))

               (setf (mission world-sector)
                     (generate-mission-on-world-map world-map rx ry mission-type-id world-time))
               ))))

(defun generate-mission-on-world-map (world-map x y mission-type-id world-time)
  (let ((world-sector (aref (cells world-map) x y))
        (final-faction-list nil)
        (level-modifier-list nil)
        (mission nil))
    
    (loop with sector-factions = (if (faction-list-func (get-world-sector-type-by-id (wtype world-sector)))
                                   (funcall (faction-list-func (get-world-sector-type-by-id (wtype world-sector))))
                                   nil)
          
          with controlled-by-factions = (if (faction-list-func (get-level-modifier-by-id (controlled-by world-sector)))
                                          (funcall (faction-list-func (get-level-modifier-by-id (controlled-by world-sector))) (wtype world-sector))
                                          nil)
          
          with feats-factions = (loop for (feat-id) in (feats world-sector)
                                      when (faction-list-func (get-level-modifier-by-id feat-id))
                                        append (funcall (faction-list-func (get-level-modifier-by-id feat-id)) (wtype world-sector)))
          
          with items-factions = (loop for item-id in (items world-sector)
                                      when (faction-list-func (get-level-modifier-by-id item-id))
                                        append (funcall (faction-list-func (get-level-modifier-by-id item-id)) (wtype world-sector)))
          
          with mission-factions = (if (faction-list-func (get-mission-type-by-id mission-type-id))
                                    (funcall (faction-list-func (get-mission-type-by-id mission-type-id)) world-sector)
                                    nil)
          
          with overall-factions = (append sector-factions controlled-by-factions feats-factions items-factions mission-factions)
          with tmp-factions-hash = (make-hash-table)
          for (faction-type-id faction-present) in overall-factions
          unless (gethash faction-type-id tmp-factions-hash)
            do
               (setf (gethash faction-type-id tmp-factions-hash) (list faction-present))
          when (and (gethash faction-type-id tmp-factions-hash)
                    (not (find faction-present (gethash faction-type-id tmp-factions-hash))))
            do
               (push faction-present (gethash faction-type-id tmp-factions-hash))
          finally
             (loop for faction-type-id being the hash-keys in tmp-factions-hash using (hash-value faction-present-list)
                   for selected-present = (nth (random (length faction-present-list)) faction-present-list)
                   unless (= selected-present +mission-faction-absent+)
                     do
                        (setf final-faction-list (append final-faction-list `((,faction-type-id ,selected-present)))))
             (setf final-faction-list (stable-sort final-faction-list #'(lambda (a b)
                                                                          (if (= (second a) +mission-faction-present+)
                                                                            (if (string-lessp (name (get-faction-type-by-id (first a)))
                                                                                              (name (get-faction-type-by-id (first b))))
                                                                              t
                                                                              nil)
                                                                            nil)))))
    
    (loop with tod-lvl-mods = ()
          for lvl-mod across *level-modifiers*
          for lvl-mod-id = (id lvl-mod)
          when (and (= (lm-type lvl-mod) +level-mod-time-of-day+)
                    (is-available-for-mission lvl-mod)
                    (funcall (is-available-for-mission lvl-mod) (wtype world-sector) mission-type-id world-time))
            do
               (setf tod-lvl-mods (append tod-lvl-mods (list lvl-mod-id)))
          finally
             (setf level-modifier-list (list (nth (random (length tod-lvl-mods)) tod-lvl-mods))))
    
    (loop for lvl-mod across *level-modifiers*
          for lvl-mod-id = (id lvl-mod)
          when (and (or (= (lm-type lvl-mod) +level-mod-weather+))
                    (is-available-for-mission lvl-mod)
                    (funcall (is-available-for-mission lvl-mod) (wtype world-sector) mission-type-id world-time)
                    (or (not (random-available-for-mission lvl-mod))
                        (funcall (random-available-for-mission lvl-mod))))
            do
               (setf level-modifier-list (append level-modifier-list (list lvl-mod-id))))
    
    (setf mission (make-instance 'mission :mission-type-id mission-type-id
                                          :x x :y y
                                          :faction-list final-faction-list
                                          :level-modifier-list level-modifier-list))
    mission))
