
(in-package :cotd-sdl)

(defparameter *max-x-world-map* 5)
(defparameter *max-y-world-map* 5)

(defclass world-map ()
  ((cells :initform nil :accessor cells :type (or simple-array null)) ;; array of world-sector
   (random-state :initform (make-random-state t) :accessor world-map/random-state)
   ))

(defun generate-empty-world-map (world-map)
  (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))

  (loop for x from 0 below *max-x-world-map* do
    (loop for y from 0 below *max-y-world-map* do
      (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype :world-sector-normal-residential :x x :y y))))

  world-map)

(defun place-satanist-lair-on-map (world-map lair-num)
  (loop repeat lair-num
        do
           (loop for x = (random (array-dimension (cells world-map) 0))
                 for y = (random (array-dimension (cells world-map) 1))
                 for world-sector = (aref (cells world-map) x y)
                 while (or (eq (wtype world-sector) :world-sector-normal-sea)
                           (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
                 finally (push (list +lm-feat-lair+ nil) (feats world-sector)))))

(defun generate-normal-world-map (world)
  (with-slots (world-map) world
    (setf world-map (make-instance 'world-map))
    (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))
    
    ;; create a template map of world sector types
    (let ((template-map (make-array (list *max-x-world-map* *max-y-world-map*) :initial-element :world-sector-normal-residential)))

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
                         (setf (aref template-map x y) :world-sector-normal-sea)
                         (setf (aref template-map x y1) :world-sector-normal-port)))
            (:s (loop with y = (1- (array-dimension template-map 1))
                      with y1 = (- (array-dimension template-map 1) 2)
                      for x from 0 below (array-dimension template-map 0)
                      do
                         (setf (aref template-map x y) :world-sector-normal-sea)
                         (setf (aref template-map x y1) :world-sector-normal-port)))
            (:w (loop with x = 0
                      with x1 = 1
                      for y from 0 below (array-dimension template-map 1)
                      do
                         (setf (aref template-map x y) :world-sector-normal-sea)
                         (setf (aref template-map x1 y) :world-sector-normal-port)))
            (:e (loop with x = (1- (array-dimension template-map 0))
                      with x1 = (- (array-dimension template-map 0) 2)
                      for y from 0 below (array-dimension template-map 1)
                      do
                         (setf (aref template-map x y) :world-sector-normal-sea)
                         (setf (aref template-map x1 y) :world-sector-normal-port)))))

        ;; place up to 2 islands on the sea tiles
        (loop with islands-num = (random 3)
              repeat islands-num
              do
                 (loop for x = (random (array-dimension template-map 0))
                       for y = (random (array-dimension template-map 1))
                       while (not (eq (aref template-map x y) :world-sector-normal-sea))
                       finally (setf (aref template-map x y) :world-sector-normal-island)))
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
                      when (and (eq (aref template-map x y) :world-sector-normal-residential)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) :world-sector-normal-forest)))
            (:s (loop with y = (1- (array-dimension template-map 1))
                      for x from 0 below (array-dimension template-map 0)
                      when (and (eq (aref template-map x y) :world-sector-normal-residential)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) :world-sector-normal-forest)))
            (:w (loop with x = 0
                      for y from 0 below (array-dimension template-map 1)
                      when (and (eq (aref template-map x y) :world-sector-normal-residential)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) :world-sector-normal-forest)))
            (:e (loop with x = (1- (array-dimension template-map 0))
                      for y from 0 below (array-dimension template-map 1)
                      when (and (eq (aref template-map x y) :world-sector-normal-residential)
                                (not (zerop (random 4))))
                      do
                         (setf (aref template-map x y) :world-sector-normal-forest))))))

      ;; place up to 3 lakes
      (loop with lakes-num = (random 3)
            repeat lakes-num
            do
               (loop for x = (random (array-dimension template-map 0))
                     for y = (random (array-dimension template-map 1))
                     while (not (or (eq (aref template-map x y) :world-sector-normal-residential)
                                    (eq (aref template-map x y) :world-sector-normal-forest)))
                     finally (setf (aref template-map x y) :world-sector-normal-lake)))
      
      ;; translate the template map into the real world-map
      (loop for x from 0 below (array-dimension (cells world-map) 0) do
        (loop for y from 0 below (array-dimension (cells world-map) 1) do
          (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype (aref template-map x y) :x x :y y))))
      )

    ;; place rivers
    (let ((river-origin-list ()))
      ;; find all river origins
      (loop for x from 0 below (array-dimension (cells world-map) 0) do
        (loop for y from 0 below (array-dimension (cells world-map) 1) do
          (when (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port)
                    (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake))
            (push (list x y) river-origin-list))))

      ;; choose 1-3 of them
      (loop with max-origins = (1+ (random 3))
            while (> (length river-origin-list) max-origins) do
              (setf river-origin-list (remove (nth (random (length river-origin-list)) river-origin-list) river-origin-list)))

      (labels ((make-river (sx sy)
                 (let ((dirs)
                       (r (random 5)))
                   (when (not (find +lm-feat-river+ (feats (aref (cells world-map) sx sy)) :key #'(lambda (a) (first a))))
                     (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) sx sy))))
                   (setf dirs (loop for (dx dy) in '((1 0) (-1 0) (0 1) (0 -1))
                                    when (and (> (+ sx dx) 0) (> (+ sy dy) 0)
                                              (< (+ sx dx) (array-dimension (cells world-map) 0))
                                              (< (+ sy dy) (array-dimension (cells world-map) 1))
                                              (or (eq (wtype (aref (cells world-map) (+ sx dx) (+ sy dy))) :world-sector-normal-residential)
                                                  (eq (wtype (aref (cells world-map) (+ sx dx) (+ sy dy))) :world-sector-normal-forest)
                                                  (eq (wtype (aref (cells world-map) (+ sx dx) (+ sy dy))) :world-sector-normal-lake))
                                              (not (find +lm-feat-river+ (feats (aref (cells world-map) (+ sx dx) (+ sy dy))) :key #'(lambda (a) (first a)))))
                                      collect (list dx dy)))
                   (when (zerop r)
                     (when dirs
                       (let* ((dir (nth (random (length dirs)) dirs))
                              (dx (first dir))
                              (dy (second dir)))
                         (setf dirs (remove dir dirs))
                         (make-river (+ sx dx) (+ sy dy)))))
                   
                   (when (or (= r 1)
                             (= r 2))
                     (when dirs
                       (let* ((dir (nth (random (length dirs)) dirs))
                              (dx (first dir))
                              (dy (second dir)))
                         (setf dirs (remove dir dirs))
                         (make-river  (+ sx dx) (+ sy dy)))))
                   )))
        (loop for (ox oy) in river-origin-list
              do
                 (make-river ox oy)))
      )
    
    ;; place up to 1-2 churches & 1 relic in one of them
    (loop with church-num = (1+ (random 2))
          with church-sectors = ()
          repeat church-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (eq (wtype world-sector) :world-sector-normal-sea)
                             (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a))))
                   finally (push (list +lm-feat-church+ nil) (feats world-sector))
                           (push world-sector church-sectors))
          finally (push +lm-item-holy-relic+ (items (nth (random (length church-sectors)) church-sectors))))
    
    ;; place 1 lair
    (place-satanist-lair-on-map world-map 1)
    
    ;; place 1 library & 1 book in it
    (loop with library-num = 1
          with library-sectors = ()
          repeat library-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (eq (wtype world-sector) :world-sector-normal-sea)
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
                   while (or (eq (wtype world-sector) :world-sector-normal-sea)
                             (/= (controlled-by world-sector) +lm-controlled-by-none+))
                   finally (setf (controlled-by world-sector) +lm-controlled-by-military+)))

    (generate-feats-on-world-map world-map)
    
    world-map))

(defun generate-test-world-map (world)
  (with-slots (world-map) world
    (setf world-map (make-instance 'world-map))
    (setf (cells world-map) (make-array (list *max-x-world-map* *max-y-world-map*) :element-type '(or world-sector null) :initial-element nil))
    
    (setf (aref (cells world-map) 0 0) (make-instance 'world-sector :wtype :world-sector-normal-sea :x 0 :y 0))
    (setf (aref (cells world-map) 1 0) (make-instance 'world-sector :wtype :world-sector-normal-sea :x 1 :y 0))
    (setf (aref (cells world-map) 2 0) (make-instance 'world-sector :wtype :world-sector-normal-island :x 2 :y 0))
    (setf (aref (cells world-map) 3 0) (make-instance 'world-sector :wtype :world-sector-normal-sea :x 3 :y 0))
    (setf (aref (cells world-map) 4 0) (make-instance 'world-sector :wtype :world-sector-normal-sea :x 4 :y 0))
    
    (setf (aref (cells world-map) 0 1) (make-instance 'world-sector :wtype :world-sector-abandoned-port :x 0 :y 1))
    (setf (aref (cells world-map) 1 1) (make-instance 'world-sector :wtype :world-sector-abandoned-port :x 1 :y 1))
    (setf (aref (cells world-map) 2 1) (make-instance 'world-sector :wtype :world-sector-abandoned-port :x 2 :y 1
                                                                    :feats (list (list +lm-feat-river+ nil))))
    (setf (aref (cells world-map) 3 1) (make-instance 'world-sector :wtype :world-sector-normal-port :x 3 :y 1))
    (setf (aref (cells world-map) 4 1) (make-instance 'world-sector :wtype :world-sector-normal-port :x 4 :y 1))
    
    (setf (aref (cells world-map) 0 2) (make-instance 'world-sector :wtype :world-sector-abandoned-forest :x 0 :y 2))
    (setf (aref (cells world-map) 1 2) (make-instance 'world-sector :wtype :world-sector-corrupted-residential :x 1 :y 2
                                                                    :feats (list (list +lm-feat-library+))
                                                                    :items (list +lm-item-holy-relic+)))
    (setf (aref (cells world-map) 2 2) (make-instance 'world-sector :wtype :world-sector-corrupted-residential :x 2 :y 2
                                                                    :feats (list (list +lm-feat-river+ nil))
                                                                    :controlled-by +lm-controlled-by-demons+))
    (setf (aref (cells world-map) 3 2) (make-instance 'world-sector :wtype :world-sector-normal-lake :x 3 :y 2
                                                                    :feats (list (list +lm-feat-river+ nil))
                                                                    :controlled-by +lm-controlled-by-military+))
    (setf (aref (cells world-map) 4 2) (make-instance 'world-sector :wtype :world-sector-normal-forest :x 4 :y 2
                                                                    :feats (list (list +lm-feat-lair+))))
    
    (setf (aref (cells world-map) 0 3) (make-instance 'world-sector :wtype :world-sector-corrupted-forest :x 0 :y 3))
    (setf (aref (cells world-map) 1 3) (make-instance 'world-sector :wtype :world-sector-corrupted-residential :x 1 :y 3
                                                                    :controlled-by +lm-controlled-by-demons+))
    (setf (aref (cells world-map) 2 3) (make-instance 'world-sector :wtype :world-sector-normal-residential :x 2 :y 3
                                                                    :feats (list (list +lm-feat-river+ nil) (list +lm-feat-lair+) (list +lm-feat-church+))
                                                                    :items (list +lm-item-holy-relic+)
                                                                    :controlled-by +lm-controlled-by-military+))
    (setf (aref (cells world-map) 3 3) (make-instance 'world-sector :wtype :world-sector-corrupted-residential :x 3 :y 3
                                                                    :controlled-by +lm-controlled-by-demons+))
    (setf (aref (cells world-map) 4 3) (make-instance 'world-sector :wtype :world-sector-normal-forest :x 4 :y 3))
    
    (setf (aref (cells world-map) 0 4) (make-instance 'world-sector :wtype :world-sector-normal-lake :x 0 :y 4
                                                                    :feats (list (list +lm-feat-library+))
                                                                    :items (list +lm-item-book-of-rituals+)))
    (setf (aref (cells world-map) 1 4) (make-instance 'world-sector :wtype :world-sector-normal-forest :x 1 :y 4))
    (setf (aref (cells world-map) 2 4) (make-instance 'world-sector :wtype :world-sector-corrupted-forest :x 2 :y 4
                                                                    :feats (list (list +lm-feat-river+ nil))
                                                                    :controlled-by +lm-controlled-by-demons+))
    (setf (aref (cells world-map) 3 4) (make-instance 'world-sector :wtype :world-sector-normal-forest :x 3 :y 4))
    (setf (aref (cells world-map) 4 4) (make-instance 'world-sector :wtype :world-sector-normal-forest :x 4 :y 4))
    
    (generate-feats-on-world-map world-map)
    
    ;;(generate-missions-on-world-map world)
    
    world-map))

(defun regenerate-transient-feats-for-world-sector (world-sector world-map)
  (let* ((x (x world-sector))
         (y (y world-sector))
         (barricade-func #'(lambda ()
                             (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))
         (can-barricade-func #'(lambda (sx sy tx ty)
                                 (if (and 
                                          (or (and (world-sector-normal-p (aref (cells world-map) sx sy))
                                                   (not (eq (wtype (aref (cells world-map) sx sy)) :world-sector-normal-island)))
                                              (= (controlled-by (aref (cells world-map) sx sy)) +lm-controlled-by-military+))
                                          (or (= (controlled-by (aref (cells world-map) tx ty)) +lm-controlled-by-demons+)
                                              (and (world-sector-corrupted-p (aref (cells world-map) sx sy))
                                                   (not (eq (wtype (aref (cells world-map) sx sy)) :world-sector-corrupted-island)))))
                                   t
                                   nil))))
  ;; reset barricades
  (setf (feats world-sector) (remove +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))
  
  ;; add barricade features
    (when (and (>= (1- x) 0)
               (funcall can-barricade-func x y (1- x) y))
      (if (funcall barricade-func)
        (push :w (second (funcall barricade-func)))
        (push (list +lm-feat-barricade+ (list :w)) (feats (aref (cells world-map) x y)))))
    (when (and (>= (1- y) 0)
               (funcall can-barricade-func x y x (1- y)))
      (if (funcall barricade-func)
        (push :n (second (funcall barricade-func)))
        (push (list +lm-feat-barricade+ (list :n)) (feats (aref (cells world-map) x y)))))
    (when (and (< (1+ x) *max-x-world-map*)
               (funcall can-barricade-func x y (1+ x) y))
      (if (funcall barricade-func)
        (push :e (second (funcall barricade-func)))
        (push (list +lm-feat-barricade+ (list :e)) (feats (aref (cells world-map) x y)))))
    (when (and (< (1+ y) *max-y-world-map*)
               (funcall can-barricade-func x y x (1+ y)))
      (if (funcall barricade-func)
        (push :s (second (funcall barricade-func)))
        (push (list +lm-feat-barricade+ (list :s)) (feats (aref (cells world-map) x y))))))

  world-sector)

(defun generate-feats-for-world-sector (world-sector world-map)
  (let* ((x (x world-sector))
         (y (y world-sector))
         (river-feat (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))
         (sea-feat (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a)))))
    
    ;; add river features
    (when river-feat
      (when (and (>= (1- x) 0)
                 (or (find +lm-feat-river+ (feats (aref (cells world-map) (1- x) y)) :key #'(lambda (a) (first a)))
                     (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-normal-sea)
                     (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-normal-island)
                     (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-abandoned-island)
                     (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-corrupted-island)))
        (setf (second river-feat) (append (second river-feat) '(:w))))
      (when (and (>= (1- y) 0)
                 (or (find +lm-feat-river+ (feats (aref (cells world-map) x (1- y))) :key #'(lambda (a) (first a)))
                     (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-normal-sea)
                     (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-normal-island)
                     (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-abandoned-island)
                     (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-corrupted-island)))
        (setf (second river-feat) (append (second river-feat) '(:n))))
      (when (and (< (1+ x) *max-x-world-map*)
                 (or (find +lm-feat-river+ (feats (aref (cells world-map) (1+ x) y)) :key #'(lambda (a) (first a)))
                     (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-normal-sea)
                     (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-normal-island)
                     (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-abandoned-island)
                     (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-corrupted-island)))
        (setf (second river-feat) (append (second river-feat) '(:e))))
      (when (and (< (1+ y) *max-y-world-map*)
                 (or (find +lm-feat-river+ (feats (aref (cells world-map) x (1+ y))) :key #'(lambda (a) (first a)))
                     (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-normal-sea)
                     (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-normal-island)
                     (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-abandoned-island)
                     (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-corrupted-island)))
        (setf (second river-feat) (append (second river-feat) '(:s))))
      )

    ;; add sea features
    (when (and (>= (1- x) 0)
               (or (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-normal-sea)
                   (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-normal-island)
                   (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-abandoned-island)
                   (eq (wtype (aref (cells world-map) (1- x) y)) :world-sector-corrupted-island)))
      (if sea-feat
        (push :w (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :w)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (>= (1- y) 0)
               (or (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-normal-sea)
                   (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-normal-island)
                   (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-abandoned-island)
                   (eq (wtype (aref (cells world-map) x (1- y))) :world-sector-corrupted-island)))
      (if sea-feat
        (push :n (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :n)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ x) *max-x-world-map*)
               (or (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-normal-sea)
                   (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-normal-island)
                   (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-abandoned-island)
                   (eq (wtype (aref (cells world-map) (1+ x) y)) :world-sector-corrupted-island)))
      (if sea-feat
        (push :e (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :e)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    (when (and (< (1+ y) *max-y-world-map*)
               (or (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-normal-sea)
                   (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-normal-island)
                   (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-abandoned-island)
                   (eq (wtype (aref (cells world-map) x (1+ y))) :world-sector-corrupted-island)))
      (if sea-feat
        (push :s (second sea-feat))
        (progn
          (push (list +lm-feat-sea+ (list :s)) (feats (aref (cells world-map) x y)))
          (setf sea-feat (find +lm-feat-sea+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))))
    
    (regenerate-transient-feats-for-world-sector world-sector world-map)
    
    world-sector))

(defun generate-feats-on-world-map (world-map)
  (loop for y from 0 below *max-y-world-map* do
    (loop for x from 0 below *max-x-world-map* do
      (generate-feats-for-world-sector (aref (cells world-map) x y) world-map)))
  )

(defun recalculate-present-forces (world)

  (setf (world/cur-military-num world) 0)
  (setf (world/cur-demons-num world) 0)
  
  (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
    (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
      (let ((world-sector (aref (cells (world-map world)) x y)))
        (when (= (controlled-by world-sector) +lm-controlled-by-demons+)
          (incf (world/cur-demons-num world)))
        (when (= (controlled-by world-sector) +lm-controlled-by-military+)
          (incf (world/cur-military-num world))))
          )))

(defun recalculate-mission-limits (world)
  (with-slots (demons-mission-limit military-mission-limit angels-mission-limit) world
    ;; demon limits
    (setf demons-mission-limit 0)

    ;; if the sacrifice was made - add # of dimensional engines for demons for each sacrifice
    (let* ((angels-win-cond (get-win-condition-by-id :win-cond-angels-campaign))
           (machines-left (funcall (win-condition/win-func angels-win-cond) world angels-win-cond)))
      (incf demons-mission-limit (* machines-left (length (find-campaign-effects-by-id world :campaign-effect-satanist-sacrifice)))))
        
    ;; if satanists are present - add 1 to demons
    (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
      (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
        (let ((world-sector (aref (cells (world-map world)) x y)))
          (when (find +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a)))
            (incf demons-mission-limit)))))

    ;; add the number of demonic forces present in the city
    (incf demons-mission-limit (world/cur-demons-num world))
    
    ;; military limits
    (setf military-mission-limit 0)
    
    ;; add the number of military forces present in the city
    (incf military-mission-limit (world/cur-military-num world))

    ;; angel limits
    (setf angels-mission-limit 1)

    ;; if the relic is in the residential church - add 1 to angels, if the relic is in the corrupted district - add 1 to demons
    (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
      (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
        (let ((world-sector (aref (cells (world-map world)) x y)))
          (when (and (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                     (find +lm-item-holy-relic+ (items world-sector))
                     (world-sector-normal-p world-sector))
            (incf angels-mission-limit))
          
          (when (and (find +lm-item-holy-relic+ (items world-sector))
                     (world-sector-corrupted-p world-sector))
            (incf demons-mission-limit)))))
    ))

(defun generate-missions-on-world-map (world)
  (recalculate-present-forces world)
  (recalculate-mission-limits world)

  
  ;; check what kind of missions are available on the map
  (let ((avail-mission-slots ())
        (demons-mission-limit (world/demons-mission-limit world))
        (military-mission-limit (world/military-mission-limit world))
        (angels-mission-limit (world/angels-mission-limit world)))
    (flet ((calc-avail-mission-slots ()
             (setf avail-mission-slots ())
             (loop for mission-slot-type in (list :mission-slot-demons-city :mission-slot-angels-city :mission-slot-military-city :mission-slot-angels-offworld :mission-slot-military-offworld) do
               (setf (getf avail-mission-slots mission-slot-type) 0))
             
             (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
               (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                 (let ((world-sector (aref (cells (world-map world)) x y)))
                   ;; calculate how many mission-slots can missions fill for city missions 
                   (loop for mission-slot-type in (list :mission-slot-demons-city :mission-slot-angels-city :mission-slot-military-city) do
                     (loop for mission-type-id in (getf (world/missions-by-slot-type world) mission-slot-type)
                           for mission-type = (get-mission-type-by-id mission-type-id)
                           when (and (null (mission world-sector))
                                     (is-available-func mission-type)
                                     (funcall (is-available-func mission-type) world-sector world))
                             do
                                (incf (getf avail-mission-slots (mission-slot-type mission-type)))
                                (loop-finish)))
                   ;; calculate available number of mission slots for offworld mission 
                   (loop for mission-slot-type in (list :mission-slot-angels-offworld :mission-slot-military-offworld) do
                     (loop for mission-type-id in (getf (world/missions-by-slot-type world) mission-slot-type)
                           for mission-type = (get-mission-type-by-id mission-type-id)
                           when (and (null (mission world-sector))
                                     (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                     (world-sector-corrupted-p world-sector))
                             do
                                (incf (getf avail-mission-slots (mission-slot-type mission-type)))
                                (loop-finish)))))))
           
           (create-city-mission (mission-slot-type)
             (loop for rx = (random *max-x-world-map*)
                   for ry = (random *max-y-world-map*)
                   for world-sector = (aref (cells (world-map world)) rx ry)
                   for avail-missions = (loop for mission-type-id in (getf (world/missions-by-slot-type world) mission-slot-type)
                                              for mission-type = (get-mission-type-by-id mission-type-id)
                                              when (and (is-available-func mission-type)
                                                        (funcall (is-available-func mission-type) world-sector world))
                                                collect (id mission-type))
                   until (and (null (mission world-sector))
                              avail-missions)
                   finally
                      (let ((mission-type-id (nth (random (length avail-missions)) avail-missions)))
                        (setf (mission world-sector)
                              (generate-mission-on-world-map world rx ry mission-type-id :off-map nil))
                        (push (mission world-sector) (world/present-missions world)))
                      (case mission-slot-type
                        (:mission-slot-demons-city (decf demons-mission-limit))
                        (:mission-slot-military-city (decf military-mission-limit))
                        (:mission-slot-angels-city (decf angels-mission-limit))
                        (t (error "Wrong mission-slot-type supplied: only :MISSION-SLOT-DEMONS-CITY, :MISSION-SLOT-MILITARY-CITY or :MISSION-SLOT-ANGELS-CITY are allowed!")))))
           
           (create-offworld-mission (mission-slot-type)
             (loop with avail-missions = (loop for mission-type-id in (getf (world/missions-by-slot-type world) mission-slot-type)
                                               for mission-type = (get-mission-type-by-id mission-type-id)
                                               for off-sector = (make-instance 'world-sector :wtype (first (world-sector-for-custom-scenario mission-type)) :x 0 :y 0)
                                               when (and (is-available-func mission-type)
                                                         (funcall (is-available-func mission-type) off-sector world))
                                                 collect (id mission-type))
                   for rx = (random *max-x-world-map*)
                   for ry = (random *max-y-world-map*)
                   for world-sector = (aref (cells (world-map world)) rx ry)
                   until (and (null (mission world-sector))
                              (eq (controlled-by world-sector) +lm-controlled-by-none+)
                              (world-sector-corrupted-p world-sector))
                   finally
                      (when avail-missions
                        (let ((mission-type-id (nth (random (length avail-missions)) avail-missions)))
                          (setf (mission world-sector)
                                (generate-mission-on-world-map world rx ry mission-type-id :off-map t))
                          (push (mission world-sector) (world/present-missions world)))
                        (case mission-slot-type
                          (:mission-slot-military-offworld (decf military-mission-limit))
                          (:mission-slot-angels-offworld (decf angels-mission-limit))
                          (t (error "Wrong mission-slot-type supplied: only :MISSION-SLOT-MILITARY-OFFWORLD or :MISSION-SLOT-ANGELS-OFFWORLD are allowed!"))))))

           (fill-slot-quota (mission-slot-type mission-limit-num create-mission-func &key do-once)
             (loop repeat (if (> (getf avail-mission-slots mission-slot-type)
                                 mission-limit-num)
                            mission-limit-num
                            (getf avail-mission-slots mission-slot-type))
                   do
                      (funcall create-mission-func mission-slot-type)
                      (when do-once (loop-finish)))))

      ;; loop for all mission slot types in the supplied order (order is important)
      (loop for mission-slot-type in (list :mission-slot-demons-city :mission-slot-military-offworld :mission-slot-military-city :mission-slot-angels-offworld :mission-slot-angels-city)
            do
               (calc-avail-mission-slots)
               (case mission-slot-type
                 (:mission-slot-demons-city (fill-slot-quota mission-slot-type demons-mission-limit #'create-city-mission))
                 (:mission-slot-military-city (fill-slot-quota mission-slot-type military-mission-limit #'create-city-mission))
                 (:mission-slot-angels-city (fill-slot-quota mission-slot-type angels-mission-limit #'create-city-mission))
                 ;; add 1 offworld military mission - 15% chance & dimension not protected
                 (:mission-slot-military-offworld (when (and (< (random 100) 15)
                                                             (not (find-campaign-effects-by-id world :campaign-effect-demon-protect-dimension)))
                                                    (fill-slot-quota mission-slot-type military-mission-limit #'create-offworld-mission :do-once t)))
                 ;; add 1 offworld angel mission - 15% chance & dimension not protected
                 (:mission-slot-angels-offworld (when (and (< (random 100) 15)
                                                           (not (find-campaign-effects-by-id world :campaign-effect-demon-protect-dimension)))
                                                    (fill-slot-quota mission-slot-type angels-mission-limit #'create-offworld-mission :do-once t)))))
      )
    )
  )

(defun generate-mission-on-world-map (world-param x y mission-type-id &key (off-map nil))
  (let ((scenario (make-instance 'scenario-gen-class)))
    (with-slots (world mission world-sector avail-feats-list avail-items-list avail-controlled-list avail-tod-list avail-weather-list avail-world-sector-type-list) scenario
      (setf world world-param)

      (scenario-create-mission scenario mission-type-id :x x :y y)
      
      (if off-map
        (progn
          (scenario-set-avail-world-sector-types scenario)
          (setf world-sector (make-instance 'world-sector :wtype (wtype (nth (random (length avail-world-sector-type-list)) avail-world-sector-type-list))
                                                          :x x :y y)))
        (progn
          (setf world-sector (aref (cells (world-map world)) x y))))
      
      ;; make angels delayed if portals are corrupted
      (when (and (find-campaign-effects-by-id world :campaign-effect-demon-corrupt-portals)
                 (not (eql mission-type-id :mission-type-celestial-purge))
                 (not (eql mission-type-id :mission-type-celestial-sabotage))
                 (not (eql mission-type-id :mission-type-celestial-retrieval)))
        (loop for faction-obj in (faction-list mission)
              when (and (eql (first faction-obj) +faction-type-angels+)
                        (eql (second faction-obj) :mission-faction-present))
                do
                   (setf (second faction-obj) :mission-faction-delayed)))

      (scenario-set-avail-lvl-mods scenario)

      (when off-map
        ;; set a random controlled-by lvl-mod
        (scenario-add/remove-lvl-mod scenario (nth (random (length avail-controlled-list)) avail-controlled-list) :apply-scenario-func nil)

        ;; add random feats lvl-mods
        (loop for lvl-mod in avail-feats-list
              when (zerop (random 4)) do
                (scenario-add/remove-lvl-mod scenario lvl-mod :apply-scenario-func nil))

        ;; add random items lvl-mods
        (loop for lvl-mod in avail-items-list
            when (zerop (random 4)) do
              (scenario-add/remove-lvl-mod scenario lvl-mod :apply-scenario-func nil))

        (scenario-adjust-lvl-mods-after-sector-regeneration scenario)
        
        )

      ;; a time of day
      (scenario-add/remove-lvl-mod scenario (nth (random (length avail-tod-list)) avail-tod-list) :apply-scenario-func nil)

      ;; add a random weather
      (loop for lvl-mod in avail-weather-list
            when (or (not (random-available-for-mission lvl-mod))
                     (funcall (random-available-for-mission lvl-mod)))
              do
                 (scenario-add/remove-lvl-mod scenario lvl-mod :apply-scenario-func nil))

      ;; set up special lvl mods
      (if (find-campaign-effects-by-id world :campaign-effect-eater-agitated)
        (progn
          (scenario-add/remove-lvl-mod scenario (get-level-modifier-by-id +lm-misc-eater-incursion+) :apply-scenario-func nil))
        (progn
          (scenario-add/remove-lvl-mod scenario (get-level-modifier-by-id +lm-misc-eater-incursion+) :apply-scenario-func nil :add-general nil)))

      (if (find-campaign-effects-by-id world :campaign-effect-demon-malseraph-blessing)
        (progn
          (scenario-add/remove-lvl-mod scenario (get-level-modifier-by-id +lm-misc-malseraphs-blessing+) :apply-scenario-func nil))
        (progn
          (scenario-add/remove-lvl-mod scenario (get-level-modifier-by-id +lm-misc-malseraphs-blessing+) :apply-scenario-func nil :add-general nil)))

      (setf (world-sector mission) world-sector)
      (setf (mission (world-sector mission)) mission)
      
      ;; set up random functions
      (scenario-adjust-factions scenario)
      
      mission)))

(defun reset-all-missions-on-world-map (world)
  (loop for x from 0 below *max-x-world-map* do
    (loop for y from 0 below *max-y-world-map* do
      (setf (mission (aref (cells (world-map world)) x y)) nil)))
  (setf (world/present-missions world) ())
  (world-map world))

(defun auto-resolve-mission (world mission)
  (let ((faction-base-chances (list (list +faction-type-angels+ 100)
                                    (list +faction-type-demons+ 100)
                                    (list +faction-type-military+ 100)
                                    (list +faction-type-church+ 50)
                                    (list +faction-type-satanists+ 50)
                                    (list +faction-type-eater+ 50)))
        (faction-multipliers (list (list +faction-type-angels+ 100)
                                   (list +faction-type-demons+ 100)
                                   (list +faction-type-military+ 100)
                                   (list +faction-type-church+ 100)
                                   (list +faction-type-satanists+ 100)
                                   (list +faction-type-eater+ 100)))
        (faction-chances ())
        (max-n 0)
        (faction-winner nil)
        (mission-result nil))
    (log:info "Start")
    ;; base chances depending on faction presence
    (loop for (faction-id faction-present) in (faction-list mission)
          for chance = (second (find faction-id faction-base-chances :key #'(lambda (a) (first a))))
          when (and (not (eq faction-present :mission-faction-absent))
                    chance)
            do
               (when (eq faction-present :mission-faction-present)
                 (setf chance (* chance 2)))
               (push (list faction-id chance) faction-chances))

    (loop initially (log:info "   Init chances")
          with str-table = (list (list +faction-type-angels+ :game-over-angels-won)
                                 (list +faction-type-demons+ :game-over-demons-won)
                                 (list +faction-type-military+ :game-over-military-won)
                                 (list +faction-type-church+ :game-over-church-won)
                                 (list +faction-type-satanists+ :game-over-satanists-won)
                                 (list +faction-type-eater+ :game-over-eater-won))
          for (faction-id base-chance) in faction-chances
          do
             (log:info "      ~A: ~A"
                             (second (find faction-id str-table
                                           :key (lambda (a) (first a))))
                             base-chance))

    ;; it is harder for non-demons in hell districts -60%
    (when (and (world-sector mission)
               (world-sector-hell-p (world-sector mission)))
      (loop for faction-id in (list +faction-type-angels+ +faction-type-military+ +faction-type-church+)
            do
               (log:info "   Corrupted district -60% to non-demons")
               (when (find faction-id faction-chances :key #'(lambda (a) (first a)))
                 (decf (second (find faction-id faction-multipliers :key #'(lambda (a) (first a))))
                       60))))
    
    ;; it is harder for non-demons in corrupted districts -30%
    (when (and (world-sector mission)
               (world-sector-corrupted-p (world-sector mission)))
      (loop for faction-id in (list +faction-type-angels+ +faction-type-military+ +faction-type-church+)
            do
               (log:info "   Corrupted district -30% to non-demons")
               (when (find faction-id faction-chances :key #'(lambda (a) (first a)))
                 (decf (second (find faction-id faction-multipliers :key #'(lambda (a) (first a))))
                       30))))

    ;; it is harder for non-demons in abandoned districts -15%
    (when (and (world-sector mission)
               (world-sector-abandoned-p (world-sector mission)))
      (loop for faction-id in (list +faction-type-angels+ +faction-type-military+ +faction-type-church+)
            do
               (log:info "   Abandonded district -15% to non-demons")
               (when (find faction-id faction-chances :key #'(lambda (a) (first a)))
                 (decf (second (find faction-id faction-multipliers :key #'(lambda (a) (first a))))
                       15))))
    ;; primordial incursion makes it easier for primordials +100%
    (when (find +lm-misc-eater-incursion+ (level-modifier-list mission))
      (log:info "   Primordial incursion +100% to primordials")
      (incf (second (find +faction-type-eater+ faction-multipliers :key #'(lambda (a) (first a))))
            100))

    ;; :campaign-effect-demon-delayed make it harder for delayed demons -30%
    (when (and (find-campaign-effects-by-id world :campaign-effect-demon-delayed)
               (find +faction-type-demons+ (faction-list mission) :key #'(lambda (a) (first a)))
               (eql (find +faction-type-demons+ (faction-list mission) :key #'(lambda (a) (first a))) :mission-faction-delayed))
      (log:info "   Demons delayed effect -30% to delayed demons")
      (decf (second (find +faction-type-demons+ faction-multipliers :key #'(lambda (a) (first a))))
            30))

    ;; :campaign-effect-angel-hastened make it easier for delayed angels +30%
    (when (and (find-campaign-effects-by-id world :campaign-effect-angel-hastened)
               (find +faction-type-angels+ (faction-list mission) :key #'(lambda (a) (first a)))
               (eql (find +faction-type-angels+ (faction-list mission) :key #'(lambda (a) (first a))) :mission-faction-delayed))
      (log:info "   Angels hastened effect +30% to delayed angels")
      (incf (second (find +faction-type-angels+ faction-multipliers :key #'(lambda (a) (first a))))
            30))

    ;; malseraphs blessing makes it easier for demons
    (when (find +lm-misc-malseraphs-blessing+ (level-modifier-list mission))
      (log:info "   Malseraph's blessing +10% to demons")
      (incf (second (find +faction-type-demons+ faction-multipliers :key #'(lambda (a) (first a))))
            10))

    ;; apply multipliers
    (loop with chances-multiplied = ()
          with multiplier = nil
          for (faction-id base-chance) in faction-chances
          do
             (if (find faction-id faction-multipliers :key #'(lambda (a) (first a)))
               (setf multiplier (second (find faction-id faction-multipliers :key #'(lambda (a) (first a)))))
               (setf multiplier 100))
             (when (minusp multiplier)
               (setf multiplier 0))
             (setf base-chance (truncate (* base-chance (/ multiplier 100))))
             (unless (zerop base-chance)
               (push (list faction-id base-chance) chances-multiplied))
          finally
             (setf faction-chances chances-multiplied))

    
    (loop initially (log:info "   Final chances")
          with str-table = (list (list +faction-type-angels+ :game-over-angels-won)
                                 (list +faction-type-demons+ :game-over-demons-won)
                                 (list +faction-type-military+ :game-over-military-won)
                                 (list +faction-type-church+ :game-over-church-won)
                                 (list +faction-type-satanists+ :game-over-satanists-won)
                                 (list +faction-type-eater+ :game-over-eater-won))
          for (faction-id base-chance) in faction-chances
          do
             (log:info "      ~A: ~A"
                             (second (find faction-id str-table
                                           :key (lambda (a) (first a))))
                             base-chance))

    ;; calculate winner
    (setf max-n (loop for (faction-id chance) in faction-chances
                      sum chance))

    (unless (zerop max-n)
      
      (loop with n = (random max-n)
            with lower-border = 0
            with upper-border = 0
            for (faction-id chance) in faction-chances
            do
               (setf upper-border (+ lower-border chance))
               (if (and (>= n lower-border)
                        (< n upper-border))
                 (progn
                   (setf faction-winner faction-id)
                   (loop-finish))
                 (progn
                   (setf lower-border upper-border)))
            finally (log:info "   Chance is ~A out of ~A" n max-n)))

    (when faction-winner
      (setf (getf mission-result :mission-result) (second (find faction-winner (list (list +faction-type-angels+ :game-over-angels-won)
                                                                                     (list +faction-type-demons+ :game-over-demons-won)
                                                                                     (list +faction-type-military+ :game-over-military-won)
                                                                                     (list +faction-type-church+ :game-over-church-won)
                                                                                     (list +faction-type-satanists+ :game-over-satanists-won)
                                                                                     (list +faction-type-eater+ :game-over-eater-won))
                                                                :key (lambda (a) (first a))))))
    mission-result))

(defun message-box-add-transform-message (prev-wtype world-sector &key (message-box-list `(,(world/mission-message-box *world*))))
  (when (not (eq prev-wtype (wtype world-sector)))
    (add-message (format nil " The sector has become ") sdl:*white* message-box-list)
    (add-message (format nil "~(~A~)" (name world-sector)) sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list)))

(defun transform-residential-sector-to-abandoned (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-normal-residential (setf (wtype world-sector) :world-sector-abandoned-residential))
      (:world-sector-normal-forest (setf (wtype world-sector) :world-sector-abandoned-forest))
      (:world-sector-normal-port (setf (wtype world-sector) :world-sector-abandoned-port))
      (:world-sector-normal-island (setf (wtype world-sector) :world-sector-abandoned-island))
      (:world-sector-normal-lake (setf (wtype world-sector) :world-sector-abandoned-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun transform-residential-sector-to-corrupted (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-normal-residential (setf (wtype world-sector) :world-sector-corrupted-residential))
      (:world-sector-normal-forest (setf (wtype world-sector) :world-sector-corrupted-forest))
      (:world-sector-normal-port (setf (wtype world-sector) :world-sector-corrupted-port))
      (:world-sector-normal-island (setf (wtype world-sector) :world-sector-corrupted-island))
      (:world-sector-normal-lake (setf (wtype world-sector) :world-sector-corrupted-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun transform-abandoned-sector-to-residential (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-abandoned-residential (setf (wtype world-sector) :world-sector-normal-residential))
      (:world-sector-abandoned-forest (setf (wtype world-sector) :world-sector-normal-forest))
      (:world-sector-abandoned-port (setf (wtype world-sector) :world-sector-normal-port))
      (:world-sector-abandoned-island (setf (wtype world-sector) :world-sector-normal-island))
      (:world-sector-abandoned-lake (setf (wtype world-sector) :world-sector-normal-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun transform-abandoned-sector-to-corrupted (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-abandoned-residential (setf (wtype world-sector) :world-sector-corrupted-residential))
      (:world-sector-abandoned-forest (setf (wtype world-sector) :world-sector-corrupted-forest))
      (:world-sector-abandoned-port (setf (wtype world-sector) :world-sector-corrupted-port))
      (:world-sector-abandoned-island (setf (wtype world-sector) :world-sector-corrupted-island))
      (:world-sector-abandoned-lake (setf (wtype world-sector) :world-sector-corrupted-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun transform-corrupted-sector-to-residential (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-corrupted-residential (setf (wtype world-sector) :world-sector-normal-residential))
      (:world-sector-corrupted-forest (setf (wtype world-sector) :world-sector-normal-forest))
      (:world-sector-corrupted-port (setf (wtype world-sector) :world-sector-normal-port))
      (:world-sector-corrupted-island (setf (wtype world-sector) :world-sector-normal-island))
      (:world-sector-corrupted-lake (setf (wtype world-sector) :world-sector-normal-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun transform-corrupted-sector-to-abandoned (world-map x y)
  (let* ((world-sector (aref (cells world-map) x y))
         (prev-wtype (wtype world-sector)))
    (case (wtype world-sector)
      (:world-sector-corrupted-residential (setf (wtype world-sector) :world-sector-abandoned-residential))
      (:world-sector-corrupted-forest (setf (wtype world-sector) :world-sector-abandoned-forest))
      (:world-sector-corrupted-port (setf (wtype world-sector) :world-sector-abandoned-port))
      (:world-sector-corrupted-island (setf (wtype world-sector) :world-sector-abandoned-island))
      (:world-sector-corrupted-lake (setf (wtype world-sector) :world-sector-abandoned-lake)))

    (message-box-add-transform-message prev-wtype world-sector)))

(defun remove-satanist-lair-from-map (world-map x y)
  (let ((world-sector (aref (cells world-map) x y))
        (message-box-list `(,(world/mission-message-box *world*))))
    (setf (feats world-sector) (remove +lm-feat-lair+ (feats world-sector) :key #'(lambda (a) (first a))))
    
    (add-message (format nil " The ") sdl:*white* message-box-list)
    (add-message (format nil "satanist lair") sdl:*yellow* message-box-list)
    (add-message (format nil " has been destroyed.") sdl:*white* message-box-list)))

(defun move-relic-to-corrupted-district (world-map x y)
  (when (not (find +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
    (return-from move-relic-to-corrupted-district nil))
  
  (let ((corrupted-sector (loop with corrupted-district-list = ()
                                for dx from 0 below (array-dimension (cells world-map) 0) do
                                  (loop for dy from 0 below (array-dimension (cells world-map) 1) do
                                    (when (and (world-sector-corrupted-p (aref (cells world-map) dx dy))
                                               (not (and (= x dx) (= y dy)))
                                               (not (find +lm-item-holy-relic+ (items (aref (cells world-map) dx dy)))))
                                      (push (aref (cells world-map) dx dy) corrupted-district-list)))
                                finally (when corrupted-district-list
                                          (return (nth (random (length corrupted-district-list)) corrupted-district-list)))))
        (message-box-list `(,(world/mission-message-box *world*))))
    (when corrupted-sector
      (setf (items (aref (cells world-map) x y)) (remove +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
      (push +lm-item-holy-relic+ (items corrupted-sector))

      (add-message (format nil " The ") sdl:*white* message-box-list)
      (add-message (format nil "relic") sdl:*yellow* message-box-list)
      (add-message (format nil " was taken and moved to ") sdl:*white* message-box-list)
      (add-message (format nil "~(~A~)" (name corrupted-sector)) sdl:*yellow* message-box-list)
      (add-message (format nil ".") sdl:*white* message-box-list))))

(defun move-relic-to-church (world-map x y)
  (when (or (not (find +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
            (and (find +lm-item-holy-relic+ (items (aref (cells world-map) x y)))
                 (find +lm-feat-church+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))
                 (world-sector-normal-p (aref (cells world-map) x y))))
    (return-from move-relic-to-church nil))
  
  (let ((church-sector (loop with church-sector-list = ()
                             for dx from 0 below (array-dimension (cells world-map) 0) do
                               (loop for dy from 0 below (array-dimension (cells world-map) 1) do
                                 (when (and (world-sector-normal-p (aref (cells world-map) dx dy))
                                            (not (and (= x dx) (= y dy)))
                                            (find +lm-feat-church+ (feats (aref (cells world-map) dx dy)) :key #'(lambda (a) (first a)))
                                            (not (find +lm-item-holy-relic+ (items (aref (cells world-map) dx dy)))))
                                   (push (aref (cells world-map) dx dy) church-sector-list)))
                             finally (when church-sector-list
                                       (return (nth (random (length church-sector-list)) church-sector-list)))))
        (message-box-list `(,(world/mission-message-box *world*))))
    (when church-sector
      (setf (items (aref (cells world-map) x y)) (remove +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
      (push +lm-item-holy-relic+ (items church-sector))

      (add-message (format nil " The ") sdl:*white* message-box-list)
      (add-message (format nil "relic") sdl:*yellow* message-box-list)
      (add-message (format nil " was moved back into the church in ") sdl:*white* message-box-list)
      (add-message (format nil "~(~A~)" (name church-sector)) sdl:*yellow* message-box-list)
      (add-message (format nil ".") sdl:*white* message-box-list))))

(defun move-military-to-free-sector (world-map x y)
  (when (not (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-military+))
    (return-from move-military-to-free-sector nil))

  (let ((free-sector (let ((free-sector-list ()))
                       (check-surroundings x y nil #'(lambda (dx dy)
                                                       (when (and (>= dx 0) (>= dy 0) (< dx (array-dimension (cells world-map) 0)) (< dy (array-dimension (cells world-map) 1))
                                                                  (world-sector-normal-p (aref (cells world-map) dx dy))
                                                                  (not (and (= x dx) (= y dy)))
                                                                  (eq (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-none+))
                                                         (push (aref (cells world-map) dx dy) free-sector-list))))
                       (if free-sector-list
                         (nth (random (length free-sector-list)) free-sector-list)
                         nil)))
        (message-box-list `(,(world/mission-message-box *world*))))

    (if free-sector
      (progn
        (setf (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-none+)
        (setf (controlled-by free-sector) +lm-controlled-by-military+)
        
        (add-message (format nil " The ") sdl:*white* message-box-list)
        (add-message (format nil "military") sdl:*yellow* message-box-list)
        (add-message (format nil " were pushed away into ") sdl:*white* message-box-list)
        (add-message (format nil "~(~A~)" (name free-sector)) sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list))
      (progn
        (setf (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-none+)
        
        (add-message (format nil " The ") sdl:*white* message-box-list)
        (add-message (format nil "military army") sdl:*yellow* message-box-list)
        (add-message (format nil " present there was ") sdl:*white* message-box-list)
        (add-message (format nil "slaughtered") sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list)))))

(defun move-demons-to-free-sector (world-map x y)
  (when (not (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-demons+))
    (return-from move-demons-to-free-sector nil))
  
  (let ((corrupted-sector (let ((corrupted-sector-list ()))
                            (check-surroundings x y nil #'(lambda (dx dy)
                                                            (when (and (>= dx 0) (>= dy 0) (< dx (array-dimension (cells world-map) 0)) (< dy (array-dimension (cells world-map) 1))
                                                                       (world-sector-corrupted-p (aref (cells world-map) dx dy))
                                                                       (not (and (= x dx) (= y dy)))
                                                                       (eq (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-none+))
                                                              (push (aref (cells world-map) dx dy) corrupted-sector-list))))
                            (if corrupted-sector-list
                              (nth (random (length corrupted-sector-list)) corrupted-sector-list)
                              nil)))
        (message-box-list `(,(world/mission-message-box *world*))))
    (if corrupted-sector
      (progn
        (setf (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-none+)
        (setf (controlled-by corrupted-sector) +lm-controlled-by-demons+)
        
        (add-message (format nil " The ") sdl:*white* message-box-list)
        (add-message (format nil "demons") sdl:*yellow* message-box-list)
        (add-message (format nil " were pushed away into ") sdl:*white* message-box-list)
        (add-message (format nil "~(~A~)" (name corrupted-sector)) sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list))
      (progn
        (setf (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-none+)
                
        (add-message (format nil " The ") sdl:*white* message-box-list)
        (add-message (format nil "demon army") sdl:*yellow* message-box-list)
        (add-message (format nil " present there was ") sdl:*white* message-box-list)
        (add-message (format nil "slaughtered") sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list)))))

(defun remove-hell-engine (world-map x y)
  (declare (ignore world-map x y)) 
  (let* ((angels-win-cond (get-win-condition-by-id :win-cond-angels-campaign))
         (machines-left (funcall (win-condition/win-func angels-win-cond) *world* angels-win-cond)))
    (when (<= machines-left 0)
      (return-from remove-hell-engine nil)))

  (incf (world/machine-destroyed *world*))

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " The ") sdl:*white* message-box-list)
    (add-message (format nil "dimensional engine") sdl:*yellow* message-box-list)
    (add-message (format nil " was ") sdl:*white* message-box-list)
    (add-message (format nil "shattered") sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list))
  )

(defun throw-hell-in-turmoil (world-map x y)
  (declare (ignore world-map x y)) 

  (add-campaign-effect *world* :id :campaign-effect-demon-turmoil :cd 3)

  )

(defun demons-capture-book-of-rituals (world-map x y)
  (when (not (find +lm-item-book-of-rituals+ (items (aref (cells world-map) x y))))
    (return-from demons-capture-book-of-rituals nil)) 

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " Demons have ") sdl:*white* message-box-list)
    (add-message (format nil "captured") sdl:*yellow* message-box-list)
    (add-message (format nil " the ") sdl:*white* message-box-list)
    (add-message (format nil "Book of Rituals") sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list))
  )

(defun demons-capture-relic (world-map x y)
  (when (not (find +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
    (return-from demons-capture-relic nil)) 

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " Demons have ") sdl:*white* message-box-list)
    (add-message (format nil "captured") sdl:*yellow* message-box-list)
    (add-message (format nil " the ") sdl:*white* message-box-list)
    (add-message (format nil "holy relic") sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list))
  )

(defun humans-capture-book-of-rituals (world-map x y)
  (when (not (find +lm-item-book-of-rituals+ (items (aref (cells world-map) x y))))
    (return-from humans-capture-book-of-rituals nil))

  (loop for campaign-effect in (find-campaign-effects-by-id *world* :campaign-effect-demon-protect-dimension) do
    (remove-campaign-effect *world* campaign-effect))

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " Humans have ") sdl:*white* message-box-list)
    (add-message (format nil "captured") sdl:*yellow* message-box-list)
    (add-message (format nil " the ") sdl:*white* message-box-list)
    (add-message (format nil "Book of Rituals") sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list))
  )

(defun humans-capture-relic (world-map x y)
  (when (not (find +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
    (return-from humans-capture-relic nil))

  (loop for campaign-effect in (find-campaign-effects-by-id *world* :campaign-effect-demon-corrupt-portals) do
    (remove-campaign-effect *world* campaign-effect))

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " Humans have ") sdl:*white* message-box-list)
    (add-message (format nil "captured") sdl:*yellow* message-box-list)
    (add-message (format nil " the ") sdl:*white* message-box-list)
    (add-message (format nil "holy relic") sdl:*yellow* message-box-list)
    (add-message (format nil ".") sdl:*white* message-box-list))
  )

(defun neutrals-capture-book-of-rituals (world-map x y)
  (when (not (find +lm-item-book-of-rituals+ (items (aref (cells world-map) x y))))
    (return-from neutrals-capture-book-of-rituals nil)) 

  (loop for campaign-effect in (find-campaign-effects-by-id *world* :campaign-effect-demon-protect-dimension) do
    (remove-campaign-effect *world* campaign-effect))
  
  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " The ") sdl:*white* message-box-list)
    (add-message (format nil "Book of Rituals") sdl:*yellow* message-box-list)
    (add-message (format nil " is ") sdl:*white* message-box-list)
    (add-message (format nil "not controlled") sdl:*yellow* message-box-list)
    (add-message (format nil " by any faction.") sdl:*white* message-box-list))
  )

(defun neutrals-capture-relic (world-map x y)
  (when (not (find +lm-item-holy-relic+ (items (aref (cells world-map) x y))))
    (return-from neutrals-capture-relic nil))

  (loop for campaign-effect in (find-campaign-effects-by-id *world* :campaign-effect-demon-corrupt-portals) do
    (remove-campaign-effect *world* campaign-effect))

  (let ((message-box-list `(,(world/mission-message-box *world*))))
    (add-message (format nil " The ") sdl:*white* message-box-list)
    (add-message (format nil "holy relic") sdl:*yellow* message-box-list)
    (add-message (format nil " is ") sdl:*white* message-box-list)
    (add-message (format nil "not controlled") sdl:*yellow* message-box-list)
    (add-message (format nil " by any faction.") sdl:*white* message-box-list))
  )

(defun remove-raw-flesh-from-demons (world-map x y)
  (declare (ignore world-map x y)) 
  (when (<= (world/flesh-points *world*) 0)
    (return-from remove-raw-flesh-from-demons nil))

  (let ((pts-to-remove (+ (random 300) 100)))
    (when (< (- (world/flesh-points *world*) pts-to-remove) 0)
      (setf pts-to-remove (world/flesh-points *world*)))
    
    (decf (world/flesh-points *world*) pts-to-remove)

    (let ((message-box-list `(,(world/mission-message-box *world*))))
      (add-message (format nil " The ") sdl:*white* message-box-list)
      (add-message (format nil "raw flesh stockpiles") sdl:*yellow* message-box-list)
      (add-message (format nil " were blown up. ") sdl:*white* message-box-list)
      (add-message (format nil "~A flesh point~:P" pts-to-remove) sdl:*yellow* message-box-list)
      (add-message (format nil " were destroyed.") sdl:*white* message-box-list))
  ))

(defun calc-all-military-on-world-map (world-map)
  (let ((military-sum 0)
        (military-sectors ()))
    (loop for x from 0 below (array-dimension (cells world-map) 0) do
      (loop for y from 0 below (array-dimension (cells world-map) 1) do
        (when (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-military+)
          (push (aref (cells world-map) x y) military-sectors)
          (incf military-sum))))
    (values military-sum military-sectors)))

(defun calc-all-demons-on-world-map (world-map)
  (let ((demons-sum 0)
        (demons-sectors ()))
    (loop for x from 0 below (array-dimension (cells world-map) 0) do
      (loop for y from 0 below (array-dimension (cells world-map) 1) do
        (when (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-demons+)
          (push (aref (cells world-map) x y) demons-sectors)
          (incf demons-sum))))
    (values demons-sum demons-sectors)))

(defun find-campaign-effects-by-id (world campaign-effect-id)
  (loop for campaign-effect in (world/campaign-effects world)
        when (eq (campaign-effect/id campaign-effect) campaign-effect-id)
          collect campaign-effect))

(defun add-campaign-effect (world &key id cd param)
  (unless id (error ":ID is an obligatory parameter!"))

  (let ((new-effect (make-instance 'campaign-effect :id id :cd cd :param param))
        (old-effect (find-campaign-effects-by-id world id)))
    (if (and old-effect
             (campaign-effect-type/merge-func (get-campaign-effect-type-by-id id)))
      (funcall (campaign-effect-type/merge-func (get-campaign-effect-type-by-id id)) world new-effect (first old-effect))
      (progn
        (push new-effect (world/campaign-effects world))
        (when (campaign-effect/on-add-func new-effect)
          (funcall (campaign-effect/on-add-func new-effect) world new-effect))))
    ))

(defun remove-campaign-effect (world campaign-effect)
  (with-slots (campaign-effects) world
    (when (campaign-effect/on-remove-func campaign-effect)
      (funcall (campaign-effect/on-remove-func campaign-effect) world campaign-effect))
    (setf campaign-effects (remove campaign-effect campaign-effects))))

(defun find-specific-world-sectors (world &rest args)
  (let ((cells (cells (world-map world)))
        (world-sector nil)
        (result (make-list (length args))))
    (loop for x from 0 below (array-dimension cells 0) do
      (loop for y from 0 below (array-dimension cells 1) do
        (setf world-sector (aref cells x y))
        ;; each argument of the args shall be a function
        (loop for func in args
              for i from 0
              do
                 (when (funcall func world-sector x y)
                   (push world-sector (nth i result))))))
    result))
