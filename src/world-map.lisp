
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
      (setf (aref (cells world-map) x y) (make-instance 'world-sector :wtype :world-sector-normal-residential :x x :y y))))

  world-map)

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
                   (push (list +lm-feat-river+ nil) (feats (aref (cells world-map) sx sy)))
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
    (loop with lair-num = 1
          repeat lair-num
          do
             (loop for x = (random (array-dimension (cells world-map) 0))
                   for y = (random (array-dimension (cells world-map) 1))
                   for world-sector = (aref (cells world-map) x y)
                   while (or (eq (wtype world-sector) :world-sector-normal-sea)
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

(defun generate-feats-for-world-sector (world-sector world-map)
  (let* ((x (x world-sector))
         (y (y world-sector))
         (river-feat (find +lm-feat-river+ (feats world-sector) :key #'(lambda (a) (first a))))
         (sea-feat (find +lm-feat-sea+ (feats world-sector) :key #'(lambda (a) (first a))))
         (barricade-func #'(lambda ()
                             (find +lm-feat-barricade+ (feats (aref (cells world-map) x y)) :key #'(lambda (a) (first a)))))
         (can-barricade-func #'(lambda (sx sy tx ty)
                                 (if (and (or (eq (wtype (aref (cells world-map) sx sy)) :world-sector-normal-forest)
                                              (eq (wtype (aref (cells world-map) sx sy)) :world-sector-normal-lake)
                                              (eq (wtype (aref (cells world-map) sx sy)) :world-sector-normal-port)
                                              (eq (wtype (aref (cells world-map) sx sy)) :world-sector-normal-residential)
                                              (= (controlled-by (aref (cells world-map) sx sy)) +lm-controlled-by-military+))
                                          (or (= (controlled-by (aref (cells world-map) tx ty)) +lm-controlled-by-demons+)
                                              (eq (wtype (aref (cells world-map) tx ty)) :world-sector-corrupted-forest)
                                              (eq (wtype (aref (cells world-map) tx ty)) :world-sector-corrupted-lake)
                                              (eq (wtype (aref (cells world-map) tx ty)) :world-sector-corrupted-port)
                                              (eq (wtype (aref (cells world-map) tx ty)) :world-sector-corrupted-residential)))
                                   t
                                   nil))))
    ;; reset barricades
    (setf (feats world-sector) (remove +lm-feat-barricade+ (feats world-sector) :key #'(lambda (a) (first a))))
        
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
        (push (list +lm-feat-barricade+ (list :s)) (feats (aref (cells world-map) x y)))))
    
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
                                     when (and (is-available-func mission-type)
                                               (funcall (is-available-func mission-type) (world-map world) rx ry))
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

(defun reset-all-missions-on-world-map (world-map)
  (loop for x from 0 below *max-x-world-map* do
    (loop for y from 0 below *max-y-world-map* do
      (setf (mission (aref (cells world-map) x y)) nil)))
  world-map)

(defun message-box-add-transform-message (prev-wtype world-sector &key (message-box-list `(,(world/sitrep-message-box *world*))))
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
        (message-box-list `(,(world/sitrep-message-box *world*))))
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
                                    (when (and (or (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-forest)
                                                   (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-lake)
                                                   (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-residential)
                                                   (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-island)
                                                   (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-port))
                                               (not (and (= x dx) (= y dy)))
                                               (not (find +lm-item-holy-relic+ (items (aref (cells world-map) dx dy)))))
                                      (push (aref (cells world-map) dx dy) corrupted-district-list)))
                                finally (when corrupted-district-list
                                          (return (nth (random (length corrupted-district-list)) corrupted-district-list)))))
        (message-box-list `(,(world/sitrep-message-box *world*))))
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
                 (or (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-forest)
                     (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-lake)
                     (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-residential)
                     (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-island)
                     (eq (wtype (aref (cells world-map) x y)) :world-sector-normal-port))))
    (return-from move-relic-to-church nil))
  
  (let ((church-sector (loop with church-sector-list = ()
                             for dx from 0 below (array-dimension (cells world-map) 0) do
                               (loop for dy from 0 below (array-dimension (cells world-map) 1) do
                                 (when (and (or (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-forest)
                                                (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-lake)
                                                (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-residential)
                                                (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-island)
                                                (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-port))
                                            (not (and (= x dx) (= y dy)))
                                            (find +lm-feat-church+ (feats (aref (cells world-map) dx dy)) :key #'(lambda (a) (first a)))
                                            (not (find +lm-item-holy-relic+ (items (aref (cells world-map) dx dy)))))
                                   (push (aref (cells world-map) dx dy) church-sector-list)))
                             finally (when church-sector-list
                                       (return (nth (random (length church-sector-list)) church-sector-list)))))
        (message-box-list `(,(world/sitrep-message-box *world*))))
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
                                                                  (or (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-forest)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-lake)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-residential)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-island)
                                                                      (eq (wtype (aref (cells world-map) dx dy)) :world-sector-normal-port))
                                                                  (not (and (= x dx) (= y dy)))
                                                                  (eq (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-none+))
                                                         (push (aref (cells world-map) dx dy) free-sector-list))))
                       (if free-sector-list
                         (nth (random (length free-sector-list)) free-sector-list)
                         nil)))
        (message-box-list `(,(world/sitrep-message-box *world*))))

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
        (add-message (format nil " was ") sdl:*white* message-box-list)
        (add-message (format nil "slaughtered") sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list)))))

(defun move-demons-to-free-sector (world-map x y)
  (when (not (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-demons+))
    (return-from move-demons-to-free-sector nil))
  
  (let ((corrupted-sector (let ((corrupted-sector-list ()))
                            (check-surroundings x y nil #'(lambda (dx dy)
                                                            (when (and (>= dx 0) (>= dy 0) (< dx (array-dimension (cells world-map) 0)) (< dy (array-dimension (cells world-map) 1))
                                                                       (or (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-forest)
                                                                           (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-lake)
                                                                           (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-residential)
                                                                           (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-island)
                                                                           (eq (wtype (aref (cells world-map) dx dy)) :world-sector-corrupted-port))
                                                                       (not (and (= x dx) (= y dy)))
                                                                       (eq (controlled-by (aref (cells world-map) dx dy)) +lm-controlled-by-none+))
                                                              (push (aref (cells world-map) dx dy) corrupted-sector-list))))
                            (if corrupted-sector-list
                              (nth (random (length corrupted-sector-list)) corrupted-sector-list)
                              nil)))
        (message-box-list `(,(world/sitrep-message-box *world*))))
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
        (add-message (format nil " was ") sdl:*white* message-box-list)
        (add-message (format nil "slaughtered") sdl:*yellow* message-box-list)
        (add-message (format nil ".") sdl:*white* message-box-list)))))

(defun calc-all-military-on-world-map (world-map)
  (let ((military-sum 0)
        (military-sectors ()))
    (loop for x from 0 below (array-dimension (cells world-map) 0) do
      (loop for y from 0 below (array-dimension (cells world-map) 1) do
        (when (eq (controlled-by (aref (cells world-map) x y)) +lm-controlled-by-military+)
          (push (aref (cells world-map) x y) military-sectors)
          (incf military-sum))))
    (values military-sum military-sectors)))
