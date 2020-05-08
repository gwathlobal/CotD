
(in-package :cotd)

(defparameter *max-x-world-map* 5)
(defparameter *max-y-world-map* 5)

(defclass world-map ()
  ((cells :initform nil :accessor cells :type simple-array) ;; array of world-sector
   ))

(defun generate-empty-world-map (world-map)
  (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))

  (loop for x from 0 below *max-x-world-map* do
    (loop for y from 0 below *max-y-world-map* do
      (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype +world-sector-normal-residential+ :x x :y y))))

  world-map)

(defun generate-normal-world-map (world)
  (with-slots (world-map) world
    (setf world-map (make-instance 'world-map))
    (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))
    
    ;; create a template map of world sector types
    (let ((template-map (make-array (list *max-x-world-map* *max-y-world-map*) :initial-element +world-sector-normal-residential+)))

      ;; determine if sea should be placed
      (when (zerop (random 2))
        ;; determine which side should have the sea
        (let* ((sides '(:n :s :w :e))
               (chosen-side (nth (random (length sides)) sides)))
          (case chosen-side
            (:n (loop with y = 0
                      with y1 = 1
                      for x from 0 below (array-dimension template-map 0)
                      do
                         (setf (aref template-map x y) +world-sector-normal-sea+)
                         (setf (aref template-map x y1) +world-sector-normal-port+)))
            (:s (loop with y = (1- (array-dimension template-map 1))
                      with y1 = (- (array-dimension template-map 1) 2)
                      for x from 0 below (array-dimension template-map 0)
                      do
                         (setf (aref template-map x y) +world-sector-normal-sea+)
                         (setf (aref template-map x y1) +world-sector-normal-port+)))
            (:w (loop with x = 0
                      with x1 = 1
                      for y from 0 below (array-dimension template-map 1)
                      do
                         (setf (aref template-map x y) +world-sector-normal-sea+)
                         (setf (aref template-map x1 y) +world-sector-normal-port+)))
            (:e (loop with x = (1- (array-dimension template-map 0))
                      with x1 = (- (array-dimension template-map 0) 2)
                      for y from 0 below (array-dimension template-map 1)
                      do
                         (setf (aref template-map x y) +world-sector-normal-sea+)
                         (setf (aref template-map x1 y) +world-sector-normal-port+)))))

        ;; place up to 2 islands on the sea tiles
        (loop with islands-num = (random 3)
              repeat islands-num
              do
                 (loop for x = (random (array-dimension template-map 0))
                       for y = (random (array-dimension template-map 1))
                       while (/= (aref template-map x y) +world-sector-normal-sea+)
                       finally (setf (aref template-map x y) +world-sector-normal-island+)))
        )

      ;; place outskirts on some of the borders
      (let* ((sides '(:n :s :w :e))
             (chosen-sides (loop for side in sides
                                 when (zerop (random 3))
                                   collect side)))
        (loop for side in chosen-sides do
          (case side
            (:n (loop with y = 0
                      for x from 0 below (array-dimension template-map 0)
                      when (and (= (aref template-map x y) +world-sector-normal-residential+)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) +world-sector-normal-forest+)))
            (:s (loop with y = (1- (array-dimension template-map 1))
                      for x from 0 below (array-dimension template-map 0)
                      when (and (= (aref template-map x y) +world-sector-normal-residential+)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) +world-sector-normal-forest+)))
            (:w (loop with x = 0
                      for y from 0 below (array-dimension template-map 1)
                      when (and (= (aref template-map x y) +world-sector-normal-residential+)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) +world-sector-normal-forest+)))
            (:e (loop with x = (1- (array-dimension template-map 0))
                      for y from 0 below (array-dimension template-map 1)
                      when (and (= (aref template-map x y) +world-sector-normal-residential+)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) +world-sector-normal-forest+))))))

      ;; place up to 3 lakes
      (loop with lakes-num = (random 3)
            repeat lakes-num
            do
               (loop for x = (random (array-dimension template-map 0))
                     for y = (random (array-dimension template-map 1))
                     while (not (or (= (aref template-map x y) +world-sector-normal-residential+)
                                    (= (aref template-map x y) +world-sector-normal-forest+)))
                     finally (setf (aref template-map x y) +world-sector-normal-lake+)))
      
      ;; translate the template map into the real world-map
      (loop for x from 0 below (array-dimension (cells world-map) 0) do
        (loop for y from 0 below (array-dimension (cells world-map) 1) do
          (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype (aref template-map x y) :x x :y y))))
      )

    ;; place up to 1-2 churches & 1 relic in one of them
    (loop with church-num = (1+ (random 2))
          with church-sectors = ()
          repeat church-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (= (wtype world-sector) +world-sector-normal-sea+)
                             (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a))))
                   finally (push (list +lm-feat-church+ nil) (feats world-sector))
                           (push world-sector church-sectors))
          finally (push +lm-item-holy-relic+ (items (nth (random (length church-sectors)) church-sectors))))
    
    ;; place 1 lair
    (loop with lair-num = 1
          repeat lair-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (= (wtype world-sector) +world-sector-normal-sea+)
                             (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
                   finally (push (list +lm-feat-lair+ nil) (feats world-sector))))

    ;; place 1 library & 1 book in it
    (loop with library-num = 1
          with library-sectors = ()
          repeat library-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (= (wtype world-sector) +world-sector-normal-sea+)
                             (find +lm-feat-library+ (feats world-sector) :key #'(lambda (a) (first a))))
                   finally (push (list +lm-feat-library+ nil) (feats world-sector))
                           (push world-sector library-sectors))
          finally (push +lm-item-book-of-rituals+ (items (nth (random (length library-sectors)) library-sectors))))

    ;; place 1 military
    (loop with military-num = 1
          repeat military-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (= (wtype world-sector) +world-sector-normal-sea+)
                             (/= (controlled-by world-sector) +lm-controlled-by-none+))
                   finally (setf (controlled-by world-sector) +lm-controlled-by-military+)))

    
    world-map))

(defun generate-test-world-map (world)
  (with-slots (world-map) world
    (setf world-map (make-instance 'world-map))
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
    
    ;;(generate-missions-on-world-map world)
    
    world-map))

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

(defun generate-missions-on-world-map (world)
  (dotimes (i (+ 3 (random 3)))
    (loop for rx = (random *max-x-world-map*)
          for ry = (random *max-y-world-map*)
          for avail-missions = (loop for mission-type being the hash-values in *mission-types*
                                     when (funcall (is-available-func mission-type) (world-map world) rx ry)
                                       collect (id mission-type))
          for world-sector = (aref (cells (world-map world)) rx ry)
          until (and (not (mission world-sector))
                     avail-missions)
          finally
             (let ((mission-type-id (nth (random (length avail-missions)) avail-missions)))

               (setf (mission world-sector)
                     (generate-mission-on-world-map world rx ry mission-type-id))
               ))))

(defun generate-mission-on-world-map (world-param x y mission-type-id)
  (let ((scenario (make-instance 'scenario-gen-class)))
    (with-slots (world mission world-sector avail-tod-list avail-weather-list) scenario
      (setf world world-param)
      
      (setf world-sector (aref (cells (world-map world)) x y))

      (scenario-create-mission scenario mission-type-id :x x :y y)

      ;; set up random factions
      (scenario-adjust-factions scenario)

      (scenario-set-avail-lvl-mods scenario)

      ;; a time of day
      (scenario-add/remove-lvl-mod scenario (nth (random (length avail-tod-list)) avail-tod-list) :apply-scenario-func nil)

      ;; add a random weather
      (loop for lvl-mod in avail-weather-list
            when (or (not (random-available-for-mission lvl-mod))
                     (funcall (random-available-for-mission lvl-mod)))
              do
                 (scenario-add/remove-lvl-mod scenario lvl-mod :apply-scenario-func nil))
      
      mission)))
