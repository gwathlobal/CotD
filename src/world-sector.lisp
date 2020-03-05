(in-package :cotd)

(defclass world-sector-type ()
  ((wtype :initform nil :initarg :wtype :accessor wtype)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (name :initform "" :initarg :name :accessor name :type string)

   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; funcation that returns a list of (list <faction type id> <mission faction status id>)

   (sector-level-gen-func :initform nil :initarg :sector-level-gen-func :accessor sector-level-gen-func)
   (template-level-gen-func :initform nil :initarg :template-level-gen-func :accessor template-level-gen-func)
   (terrain-post-process-func-list :initform nil :initarg :terrain-post-process-func-list :accessor terrain-post-process-func-list)
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)
   (angel-disguised-mob-type-id :initform +mob-type-man+ :initarg :angel-disguised-mob-type-id :accessor angel-disguised-mob-type-id)
   ) 
  )

(defparameter *world-sector-types* (make-hash-table))

(defun set-world-sector-type (&key wtype glyph-idx glyph-color name faction-list-func sector-level-gen-func template-level-gen-func terrain-post-process-func-list
                                   overall-post-process-func-list angel-disguised-mob-type-id)
  (unless wtype (error ":WTYPE is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless glyph-idx (error ":GLYPH-IDX is an obligatory parameter!"))
  (unless glyph-color (error ":GLYPH-COLOR is an obligatory parameter!"))
  
  (setf (gethash wtype *world-sector-types*) (make-instance 'world-sector-type :wtype wtype :glyph-idx glyph-idx :glyph-color glyph-color :name name
                                                                               :faction-list-func faction-list-func
                                                                               :sector-level-gen-func sector-level-gen-func
                                                                               :template-level-gen-func template-level-gen-func
                                                                               :terrain-post-process-func-list terrain-post-process-func-list
                                                                               :overall-post-process-func-list overall-post-process-func-list
                                                                               :angel-disguised-mob-type-id angel-disguised-mob-type-id
                                                                               )))

(defun get-world-sector-type-by-id (world-sector-type-id)
  (gethash world-sector-type-id *world-sector-types*))

(defclass world-sector ()
  ((wtype :initform nil :initarg :wtype :accessor wtype) ;; ids from feature-layout
   (x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (feats :initform () :initarg :feats :accessor feats) ;; auxiliary features of the sector, like rivers present
   ;; ((+lm-feat-river+ (:n :s :w :e)) (+lm-feat-sea+ (:n :s :w :e)) (+lm-feat-barricade+ (:n :s :w :e)) (+lm-feat-church+) (+lm-feat-lair+) (+lm-feat-library+))
   (items :initform () :initarg :items :accessor items) ;; global items in in this sector
   ;; (<level modifier id of type +level-mod-sector-item+> ...)
   (controlled-by :initform +lm-controlled-by-none+ :initarg :controlled-by :accessor controlled-by)
   ;; <level modifier id of type +level-mod-controlled-by+>
   (mission :initform nil :initarg :mission :accessor mission)
   ))

(defmethod descr ((sector world-sector))
  (let ((feats-str (create-string))
        (feats-str-comma nil)
        (controlled-str (create-string))
        (items-str (create-string))
        (items-str-comma nil)
        (mission-str (create-string))
        (faction-str (create-string))
        (level-mod-str (create-string)))

    (loop for l in (feats sector)
          for lm-modifier-id = (first l)
          for name = (name (get-level-modifier-by-id lm-modifier-id))
          do
             (unless (= lm-modifier-id +lm-feat-sea+)
               (format feats-str "~A~A" (if feats-str-comma ", " (format nil "~%~%")) name)
               (setf feats-str-comma t))
          finally (when feats-str-comma (format feats-str ".")))

    (loop for lm-modifier-id in (items sector)
          for name = (name (get-level-modifier-by-id lm-modifier-id))
          do
             (format items-str "~A~A" (if items-str-comma ", " (format nil "~%~%Available items:~%   ")) (capitalize-name (prepend-article +article-a+ name)))
             (setf items-str-comma t)
          finally (when items-str-comma (format items-str ".")))

    (unless (= (controlled-by sector) +lm-controlled-by-none+)
      (format controlled-str "~%~%~A." (name (get-level-modifier-by-id (controlled-by sector)))))
   
    (when (mission sector)
      (format mission-str "~%~%Available mission:~%   ~A.~%" (name (mission sector)))

      (loop with first-line = t
            with faction-comma = nil
            for (faction-type faction-presence) in (faction-list (mission sector))
            for faction-name = (name (get-faction-type-by-id faction-type))
            when (= faction-presence +mission-faction-present+)
              do
                 (when first-line
                   (format faction-str "~%   Present factions:~%      ")
                   (setf first-line nil))
                 (format faction-str "~A~A" (if faction-comma ", " "") faction-name)
                 (setf faction-comma t)
            finally (when faction-comma (format faction-str "~%")))

      (loop with first-line = t
            with faction-comma = nil
            for (faction-type faction-presence) in (faction-list (mission sector))
            for faction-name = (name (get-faction-type-by-id faction-type))
            when (= faction-presence +mission-faction-delayed+)
              do
                 (when first-line
                   (format faction-str "~%   Delayed arrival:~%      ")
                   (setf first-line nil))
                 (format faction-str "~A~A" (if faction-comma ", " "") faction-name)
                 (setf faction-comma t)
            finally (when faction-comma (format faction-str "~%")))

      (loop with first-line = t
            with comma = nil
            for lvl-mod-id in (level-modifier-list (mission sector))
            for lvl-mod-name = (name (get-level-modifier-by-id lvl-mod-id))
            do
               (when first-line
                 (format level-mod-str "~%   Features:~%      ")
                 (setf first-line nil))
               (format level-mod-str "~A~A" (if comma ", " "") lvl-mod-name)
               (setf comma t)
            finally (when comma (format level-mod-str "~%"))))
    
    (format nil "~A.~A~A~A~A~A~A"
            (name (get-world-sector-type-by-id (wtype sector)))
            feats-str
            items-str
            controlled-str
            mission-str
            faction-str
            level-mod-str)))

(defun add-item-to-sector (world-sector item-type-id)
  (push (items world-sector) item-type-id))

(defun remove-item-from-sector (world-sector item-type-id)
  (setf (items world-sector) (remove item-type-id (items world-sector))))

(defmethod angel-disguised-mob-type-id ((world-sector world-sector))
  (angel-disguised-mob-type-id (get-world-sector-type-by-id (wtype world-sector))))

(defmethod name ((world-sector world-sector))
  (name (get-world-sector-type-by-id (wtype world-sector))))

(defun world-find-sides-for-world-sector (world-sector world-map
                                          test-north-func test-south-func test-west-func test-east-func
                                          call-north-func call-south-func call-west-func call-east-func)
  ;; test-func takes (x y)

  ;; find sectors to the east, west, north, south that satisfy the test
  ;; if found place do something to that side of the level
  (let ((max-world-x (array-dimension (cells world-map) 0))
        (max-world-y (array-dimension (cells world-map) 1)))
    ;; find west
    (loop named loop
          for x from 0 below (x world-sector) do
            (loop for y from 0 below max-world-y do
              (when (funcall test-west-func x y)
                (funcall call-west-func)
                (return-from loop nil)
          )))
    ;; find east
    (loop named loop
          for x from (1+ (x world-sector)) below max-world-x do
            (loop for y from 0 below max-world-y do
              (when (funcall test-east-func x y)
                (funcall call-east-func)
                (return-from loop nil)
          )))
    ;; find north
    (loop named loop
          for x from 0 below max-world-x do
            (loop for y from 0 below (y world-sector) do
              (when (funcall test-north-func x y)
                (funcall call-north-func)
                (return-from loop nil)
          )))
    ;; find south
    (loop named loop
          for x from 0 below max-world-x do
            (loop for y from (1+ (y world-sector)) below max-world-y do
              (when (funcall test-south-func x y)
                (funcall call-south-func)
                (return-from loop nil)
          )))
    )
  )

(defun add-arrival-points-on-level (level world-sector mission world)
  (declare (ignore mission))

  (format t "ADD-ARRIVAL-POINTS-ON-LEVEL: Start~%")
  
  (let* ((sides-hash (make-hash-table))
         (demon-test-func #'(lambda (x y)
                              (if (or (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-demons+)
                                      (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-forest+)
                                      (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-port+)
                                      (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-residential+)
                                      (= (wtype (aref (cells (world-map world)) x y)) +world-sector-corrupted-lake+))
                                t
                                nil)))
         (military-test-func #'(lambda (x y)
                                 (if (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-military+)
                                   t
                                   nil)))
         (hash-print-func #'(lambda ()
                              (loop initially (format t "~%SIDES-HASH: ")
                                    for side being the hash-keys in sides-hash do
                                      (format t "   ~A : (~A)~%" side (gethash side sides-hash))
                                    finally (format t "~%"))))
         (side-party-list (list (list :demons +feature-demons-arrival-point+)
                                (list :military +feature-delayed-military-arrival-point+)
                                (list :angels +feature-delayed-angels-arrival-point+))))
    
    (unless (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
      (push (list :angels +feature-start-place-angels+) side-party-list))
    
    (unless (= (controlled-by world-sector) +lm-controlled-by-military+)
      (push (list :military +feature-start-military-point+) side-party-list))
    
    ;; find all sides from which demons can arrive
    (world-find-sides-for-world-sector world-sector (world-map world)
                                       demon-test-func
                                       demon-test-func
                                       demon-test-func
                                       demon-test-func
                                       #'(lambda ()
                                           (if (gethash :n sides-hash)
                                             (push :demons (gethash :n sides-hash))
                                             (setf (gethash :n sides-hash) (list :demons))))
                                       #'(lambda ()
                                           (if (gethash :s sides-hash)
                                             (push :demons (gethash :s sides-hash))
                                             (setf (gethash :s sides-hash) (list :demons))))
                                       #'(lambda ()
                                           (if (gethash :w sides-hash)
                                             (push :demons (gethash :w sides-hash))
                                             (setf (gethash :w sides-hash) (list :demons))))
                                       #'(lambda ()
                                           (if (gethash :e sides-hash)
                                             (push :demons (gethash :e sides-hash))
                                             (setf (gethash :e sides-hash) (list :demons)))))
    
    ;; find all sides from which military can arrive
    (world-find-sides-for-world-sector world-sector (world-map world)
                                       military-test-func
                                       military-test-func
                                       military-test-func
                                       military-test-func
                                       #'(lambda ()
                                           (if (gethash :n sides-hash)
                                             (push :military (gethash :n sides-hash))
                                             (setf (gethash :n sides-hash) (list :military))))
                                       #'(lambda ()
                                           (if (gethash :s sides-hash)
                                             (push :military (gethash :s sides-hash))
                                             (setf (gethash :s sides-hash) (list :military))))
                                       #'(lambda ()
                                           (if (gethash :w sides-hash)
                                             (push :military (gethash :w sides-hash))
                                             (setf (gethash :w sides-hash) (list :military))))
                                       #'(lambda ()
                                           (if (gethash :e sides-hash)
                                             (push :military (gethash :e sides-hash))
                                             (setf (gethash :e sides-hash) (list :military)))))
    
    ;; fill the all sides with angels
    (if (gethash :n sides-hash)
      (push :angels (gethash :n sides-hash))
      (setf (gethash :n sides-hash) (list :angels)))
    (if (gethash :s sides-hash)
      (push :angels (gethash :s sides-hash))
      (setf (gethash :s sides-hash) (list :angels)))
    (if (gethash :w sides-hash)
      (push :angels (gethash :w sides-hash))
      (setf (gethash :w sides-hash) (list :angels)))
    (if (gethash :e sides-hash)
      (push :angels (gethash :e sides-hash))
      (setf (gethash :e sides-hash) (list :angels)))
    
    ;; PRINT
    (funcall hash-print-func)
    
    ;; if all sides have only one party, we are good to go, otherwise we need rearrangements
    (loop with demons-num = 0
          with military-num = 0
          with angels-num = 0
          with has-overlapped = nil
          with count-nums-func = #'(lambda ()
                                     (loop initially (setf demons-num 0
                                                           military-num 0
                                                           angels-num 0
                                                           has-overlapped nil)
                                           for side being the hash-keys in sides-hash
                                           when (find :demons (gethash side sides-hash))
                                             do
                                                (incf demons-num)
                                           when (find :military (gethash side sides-hash))
                                             do
                                                (incf military-num)
                                           when (find :angels (gethash side sides-hash))
                                             do
                                                (incf angels-num)
                                           when (> (length (gethash side sides-hash)) 1)
                                             do
                                                (setf has-overlapped t)
                                           finally (format t
                                                           "Counts:~%   Demons: ~A~%   Angels: ~A~%   Military:~A~%   Overlapped: ~A~%"
                                                           demons-num angels-num military-num has-overlapped)))
          with reduce-nums-func = #'(lambda ()
                                      (format t "Reduce angels:~%")
                                      ;; reduce angels
                                      (loop with prev-angels-num = 0
                                            while (/= angels-num prev-angels-num) do
                                              (setf prev-angels-num angels-num)
                                              (loop for side being the hash-keys in sides-hash
                                                    when (and (> (length (gethash side sides-hash)) 1)
                                                              (> angels-num 1)
                                                              (find :angels (gethash side sides-hash)))
                                                      do
                                                         (setf (gethash side sides-hash)
                                                               (remove :angels (gethash side sides-hash)))
                                                         
                                                         (funcall count-nums-func)
                                                         (loop-finish)))
                                      (funcall hash-print-func)
                                      (format t "Reduce military:~%")
                                      ;; reduce military
                                      (loop with prev-military-num = 0
                                            while (/= military-num prev-military-num) do
                                              (setf prev-military-num military-num)
                                        (loop for side being the hash-keys in sides-hash
                                              when (and (> (length (gethash side sides-hash)) 1)
                                                        (> military-num 1)
                                                        (find :military (gethash side sides-hash)))
                                                do
                                                   (setf (gethash side sides-hash)
                                                         (remove :military (gethash side sides-hash)))
                                                   
                                                   (funcall count-nums-func)
                                                   (loop-finish)))
                                      (funcall hash-print-func)
                                      (format t "Reduce demons:~%")
                                      ;; reduce demons
                                      (loop with prev-demons-num = 0
                                            while (/= demons-num prev-demons-num) do
                                              (setf prev-demons-num demons-num)
                                        (loop for side being the hash-keys in sides-hash
                                              when (and (> (length (gethash side sides-hash)) 1)
                                                        (> demons-num 1)
                                                        (find :demons (gethash side sides-hash)))
                                                do
                                                   (setf (gethash side sides-hash)
                                                         (remove :demons (gethash side sides-hash)))
                                                   
                                                   (funcall count-nums-func)
                                                   (loop-finish)))
                                      (funcall hash-print-func)
                                      
                                      )
            initially (funcall count-nums-func)
          while has-overlapped do
            ;; reduce all parties to a minimum
            (funcall reduce-nums-func)
            (format t "After reduce:~%")
            (funcall hash-print-func)
            (unless has-overlapped (loop-finish))
            ;; if it still does not help, add a random party to a free side
            (loop with party-list = (list :angels :military :demons)
                  with selected-pick = (nth (random (length party-list)) party-list)
                  for side being the hash-keys in sides-hash
                  when (= (length (gethash side sides-hash)) 0)
                    do
                       (setf (gethash side sides-hash) (list selected-pick))
                       (loop-finish))
            ;; on the next iteration we reduce again and see if it helped
            (format t "After addition:~%")
            (funcall hash-print-func)
          )
    
    ;; once we fixed everything - we can place arrival points
    (loop with party-list = side-party-list
          for (party arrival-point-feature-type-id) in party-list
          ;; north
          when (find party (gethash :n sides-hash)) do
            (loop with y = 2
                  with z = 2
                  for x from 0 below (array-dimension (terrain level) 0) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            
            ;; south
          when (find party (gethash :s sides-hash)) do
            (loop with y = (- (array-dimension (terrain level) 1) 3)
                  with z = 2
                  for x from 0 below (array-dimension (terrain level) 0) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            ;; west
          when (find party (gethash :w sides-hash)) do
            (loop with x = 2
                  with z = 2
                  for y from 0 below (array-dimension (terrain level) 1) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            ;; east
          when (find party (gethash :e sides-hash)) do
            (loop with x = (- (array-dimension (terrain level) 1) 3)
                  with z = 2
                  for y from 0 below (array-dimension (terrain level) 1) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-opaque-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
          )
    )
  )

