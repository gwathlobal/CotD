(in-package :cotd)

(defclass world-sector-type ()
  ((wtype :initform nil :initarg :wtype :accessor wtype)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (name :initform "" :initarg :name :accessor name :type string)
   (general-type :initform :world-sector-normal :initarg :general-type :accessor general-type :type world-sector-general-type)
   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; funcation that returns a list of (list <faction type id> <mission faction status id>)

   (sector-level-gen-func :initform nil :initarg :sector-level-gen-func :accessor sector-level-gen-func)
   (template-level-gen-func :initform nil :initarg :template-level-gen-func :accessor template-level-gen-func)
   (terrain-post-process-func-list :initform nil :initarg :terrain-post-process-func-list :accessor terrain-post-process-func-list)
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)
   (angel-disguised-mob-type-id :initform +mob-type-man+ :initarg :angel-disguised-mob-type-id :accessor angel-disguised-mob-type-id)
   (scenario-enabled-func :initform nil :initarg :scenario-enabled-func :accessor scenario-enabled-func)
   (always-lvl-mods-func :initform nil :initarg :always-lvl-mods-func :accessor always-lvl-mods-func)
   ))

(defparameter *world-sector-types* (make-hash-table))

(defmethod world-sector-normal-p ((world-sector-type world-sector-type))
  (eql (general-type world-sector-type) :world-sector-normal))

(defmethod world-sector-abandoned-p ((world-sector-type world-sector-type))
  (eql (general-type world-sector-type) :world-sector-abandoned))

(defmethod world-sector-corrupted-p ((world-sector-type world-sector-type))
  (eql (general-type world-sector-type) :world-sector-corrupted))

(defmethod world-sector-hell-p ((world-sector-type world-sector-type))
  (eql (general-type world-sector-type) :world-sector-hell))

(defun set-world-sector-type (&key wtype glyph-idx glyph-color name general-type faction-list-func sector-level-gen-func template-level-gen-func terrain-post-process-func-list
                                   overall-post-process-func-list angel-disguised-mob-type-id scenario-enabled-func
                                   (always-lvl-mods-func #'(lambda (world-sector mission-type-id world-time)
                                                             (declare (ignore world-sector mission-type-id world-time))
                                                             nil)))
  (unless wtype (error ":WTYPE is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless glyph-idx (error ":GLYPH-IDX is an obligatory parameter!"))
  (unless glyph-color (error ":GLYPH-COLOR is an obligatory parameter!"))
  (unless general-type (error ":GENERAL-TYPE is an obligatory parameter!"))
  
  (setf (gethash wtype *world-sector-types*) (make-instance 'world-sector-type :wtype wtype :glyph-idx glyph-idx :glyph-color glyph-color :name name :general-type general-type
                                                                               :faction-list-func faction-list-func
                                                                               :sector-level-gen-func sector-level-gen-func
                                                                               :template-level-gen-func template-level-gen-func
                                                                               :terrain-post-process-func-list terrain-post-process-func-list
                                                                               :overall-post-process-func-list overall-post-process-func-list
                                                                               :angel-disguised-mob-type-id angel-disguised-mob-type-id
                                                                               :scenario-enabled-func scenario-enabled-func
                                                                               :always-lvl-mods-func always-lvl-mods-func
                                                                               )))

(defun get-world-sector-type-by-id (world-sector-type-id)
  (gethash world-sector-type-id *world-sector-types*))

(defun get-all-world-sector-types-list ()
  (loop for world-sector-type being the hash-values in *world-sector-types*
        collect world-sector-type))

(defclass world-sector ()
  ((wtype :initform nil :initarg :wtype :accessor wtype)
   (x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (feats :initform () :initarg :feats :accessor feats) ;; auxiliary features of the sector, like rivers present
   ;; ((+lm-feat-river+ (:n :s :w :e)) (+lm-feat-sea+ (:n :s :w :e)) (+lm-feat-barricade+ (:n :s :w :e)) (+lm-feat-church+) (+lm-feat-lair+) (+lm-feat-library+))
   (items :initform () :initarg :items :accessor items) ;; global items in in this sector
   ;; (<level modifier id of type :level-mod-sector-item ...)
   (controlled-by :initform +lm-controlled-by-none+ :initarg :controlled-by :accessor controlled-by)
   ;; <level modifier id of type :level-mod-controlled-by
   (mission :initform nil :initarg :mission :accessor mission)
   ))

(defun description (sector &key (reveal-lair nil))
  (let ((feats-list (copy-list (feats sector)))
        (feats-str (create-string))
        (feats-str-comma nil)
        (controlled-str (create-string))
        (items-str (create-string))
        (items-str-comma nil)
        (mission-str (create-string))
        (faction-str (create-string))
        (level-mod-str (create-string)))

    (setf feats-list (remove +lm-feat-sea+ feats-list :key #'(lambda (a) (first a))))
    (setf feats-list (remove-if #'(lambda (a)
                                    (if (and (= (first a) +lm-feat-lair+)
                                             (null reveal-lair)
                                             (not (mission sector)))
                                      t
                                      nil))
                                feats-list))
    
    (loop for l in feats-list 
          for lm-modifier-id = (first l)
          for name = (name (get-level-modifier-by-id lm-modifier-id))
          do
             (format feats-str "~A~A" (if feats-str-comma ", " (format nil "~%~%")) name)
             (setf feats-str-comma t)
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
            when (eq faction-presence :mission-faction-present)
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
            when (eq faction-presence :mission-faction-delayed)
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

(defmethod world-sector-normal-p ((world-sector world-sector))
  (eql (general-type (get-world-sector-type-by-id (wtype world-sector))) :world-sector-normal))

(defmethod world-sector-abandoned-p ((world-sector world-sector))
  (eql (general-type (get-world-sector-type-by-id (wtype world-sector))) :world-sector-abandoned))

(defmethod world-sector-corrupted-p ((world-sector world-sector))
  (eql (general-type (get-world-sector-type-by-id (wtype world-sector))) :world-sector-corrupted))

(defmethod world-sector-hell-p ((world-sector world-sector))
  (eql (general-type (get-world-sector-type-by-id (wtype world-sector))) :world-sector-hell))

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

  (log:info "Start")
  
  (let* ((sides-hash (make-hash-table))
         (demon-test-func #'(lambda (x y)
                              (if (and (<= (abs (- x (x world-sector))) 1) (<= (abs (- y (y world-sector))) 1)
                                       (or (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-demons+)
                                           (and (world-sector-corrupted-p (aref (cells (world-map world)) x y))
                                                (not (eql (wtype (aref (cells (world-map world)) x y)) :world-sector-corrupted-island)))))
                                t
                                nil)))
         (military-test-func #'(lambda (x y)
                                 (if (and (<= (abs (- x (x world-sector))) 1) (<= (abs (- y (y world-sector))) 1)
                                          (or (= (controlled-by (aref (cells (world-map world)) x y)) +lm-controlled-by-military+)
                                              (world-sector-normal-p (aref (cells (world-map world)) x y))))
                                   t
                                   nil)))
         (hash-print-func #'(lambda ()
                              (loop initially (log:debug "~%SIDES-HASH:")
                                    for side being the hash-keys in sides-hash do
                                      (log:debug "   ~A : ~A" side (gethash side sides-hash))
                                    finally (log:debug ""))))
         (side-party-list (list (list :demons +feature-delayed-demons-arrival-point+)
                                (list :military +feature-delayed-military-arrival-point+)
                                (list :angels +feature-delayed-angels-arrival-point+)
                                )))
    
    (when (or (not (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a))))
              (and (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                   (or (world-sector-abandoned-p world-sector)
                       (world-sector-corrupted-p world-sector))))
      (push (list :angels +feature-start-place-angels+) side-party-list))
    
    (unless (= (controlled-by world-sector) +lm-controlled-by-military+)
      (push (list :military +feature-start-place-military+) side-party-list))
	  
    (unless (= (controlled-by world-sector) +lm-controlled-by-demons+)
      (push (list :demons +feature-start-place-demons+) side-party-list))

    (setf (gethash :n sides-hash) ())
    (setf (gethash :s sides-hash) ())
    (setf (gethash :e sides-hash) ())
    (setf (gethash :w sides-hash) ())
    
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
    
    ;; PRINT
    (funcall hash-print-func)

    ;; reduce all sides to only one party per side
    (loop with parties = (list :angels :military :demons)
          with nums = (list :angels 0 :military 0 :demons 0)
          with has-overlapped = nil
          with count-nums-func = #'(lambda ()
                                     (loop initially (setf nums (list :angels 0 :military 0 :demons 0)
                                                           has-overlapped nil)
                                           for side being the hash-keys in sides-hash do
                                             (loop for party in parties
                                                   when (find party (gethash side sides-hash)) do
                                                     (incf (getf nums party)))
                                             (when (> (length (gethash side sides-hash)) 1)
                                               (setf has-overlapped t))
                                           finally (log:debug "Reduce counts:~%   ~A~%   Overlapped: ~A~%"
                                                              nums has-overlapped)))
            initially (funcall count-nums-func)
          while has-overlapped do
            (loop for party in parties do
              (loop with prev-num = 0
                    with cur-num = (getf nums party)
                    while (/= cur-num prev-num) do
                      (setf prev-num cur-num)
                      (loop for side being the hash-keys in sides-hash
                            when (and (> (length (gethash side sides-hash)) 1)
                                      (> cur-num 1)
                                      (find party (gethash side sides-hash)))
                              do
                                 (setf (gethash side sides-hash)
                                       (remove party (gethash side sides-hash)))
                                 
                                 (funcall count-nums-func)
                                 (funcall hash-print-func)
                                 (loop-finish))))
          )
    
    (log:debug "After reduce ")
    (funcall hash-print-func)

    ;; add parties that are absent at the moment
    (loop with absent-parties = (list :demons :angels :military)
          with free-sides = ()
          with excess-parties = ()
          with parties-hash = (make-hash-table)
          with count-nums-func = #'(lambda ()
                                     (setf (gethash :demons parties-hash) ())
                                     (setf (gethash :angels parties-hash) ())
                                     (setf (gethash :military parties-hash) ())
                                     (loop initially (setf absent-parties (list :demons :angels :military)
                                                           free-sides ()
                                                           excess-parties ())
                                           for side being the hash-keys in sides-hash
                                           when (find :demons (gethash side sides-hash)) do
                                             (setf absent-parties (remove :demons absent-parties))
                                             (push side (gethash :demons parties-hash))
                                           when (find :military (gethash side sides-hash)) do
                                             (setf absent-parties (remove :military absent-parties))
                                             (push side (gethash :military parties-hash))
                                           when (find :angels (gethash side sides-hash)) do
                                             (setf absent-parties (remove :angels absent-parties))
                                             (push side (gethash :angels parties-hash))
                                           when (null (gethash side sides-hash)) do
                                             (push side free-sides)
                                           finally (when (> (length (gethash :demons parties-hash)) 1)
                                                     (push :demons excess-parties))
                                                   (when (> (length (gethash :military parties-hash)) 1)
                                                     (push :military excess-parties))
                                                   (when (> (length (gethash :angels parties-hash)) 1)
                                                     (push :angels excess-parties))
                                                   (log:debug "Counts:~%   Absent parties: ~A, Free sides: ~A, Excess parties: ~A" absent-parties free-sides excess-parties)))
            initially (funcall count-nums-func)
          while absent-parties do
            
            (let ((random-party (nth (random (length absent-parties)) absent-parties))
                  (random-side nil)
                  (random-excess-party nil))
              ;; add an absent party to a free side
              (if free-sides
                (progn
                  (setf random-side (nth (random (length free-sides)) free-sides))
                  (setf (gethash random-side sides-hash) (list random-party))
                  )
                ;; if there are no free sides replace a side of the party that has more than one sides 
                (progn
                  (setf random-excess-party (nth (random (length excess-parties)) excess-parties))
                  (setf random-side (nth (random (length (gethash random-excess-party parties-hash))) (gethash random-excess-party parties-hash)))
                  (setf (gethash random-side sides-hash) (remove random-excess-party (gethash random-side sides-hash)))
                  (push random-party (gethash random-side sides-hash))
                  ))
              )
            (log:debug "After ")
            (funcall count-nums-func)
            (funcall hash-print-func)
          )
            
    ;; once we fixed everything - we can place arrival points
    (loop with party-list = side-party-list
          for (party arrival-point-feature-type-id) in party-list
          ;; north
          when (find party (gethash :n sides-hash)) do
            ;; replace feature arrival points
            (loop for feature-id in (feature-id-list level)
                  for feature = (get-feature-by-id feature-id)
                  when (= (feature-type feature) +feature-arrival-point-north+) do
                    (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x (x feature) :y (y feature) :z (z feature))))
            ;; place standard arrival points an the side
            (loop with y = 2
                  with z = 2
                  for x from 0 below (array-dimension (terrain level) 0) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            
            ;; south
          when (find party (gethash :s sides-hash)) do
             ;; replace feature arrival points
            (loop for feature-id in (feature-id-list level)
                  for feature = (get-feature-by-id feature-id)
                  when (= (feature-type feature) +feature-arrival-point-south+) do
                    (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x (x feature) :y (y feature) :z (z feature))))
            ;; place standard arrival points an the side
            (loop with y = (- (array-dimension (terrain level) 1) 3)
                  with z = 2
                  for x from 0 below (array-dimension (terrain level) 0) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            ;; west
          when (find party (gethash :w sides-hash)) do
            ;; replace feature arrival points
            (loop for feature-id in (feature-id-list level)
                  for feature = (get-feature-by-id feature-id)
                  when (= (feature-type feature) +feature-arrival-point-west+) do
                    (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x (x feature) :y (y feature) :z (z feature))))
            ;; place standard arrival points an the side
            (loop with x = 2
                  with z = 2
                  for y from 0 below (array-dimension (terrain level) 1) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
            ;; east
          when (find party (gethash :e sides-hash)) do
            ;; replace feature arrival points
            (loop for feature-id in (feature-id-list level)
                  for feature = (get-feature-by-id feature-id)
                  when (= (feature-type feature) +feature-arrival-point-east+) do
                    (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x (x feature) :y (y feature) :z (z feature))))
            ;; place standard arrival points an the side
            (loop with x = (- (array-dimension (terrain level) 1) 3)
                  with z = 2
                  for y from 0 below (array-dimension (terrain level) 1) by (+ 5 (random 3))
                  when (and (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                            (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+))
                    do
                       (add-feature-to-level-list level (make-instance 'feature :feature-type arrival-point-feature-type-id :x x :y y :z z)))
          )
    )
  )

(defun place-seaport-north (template-level warehouse-building-id-1 warehouse-building-id-2)
  (loop with max-x = (array-dimension template-level 0)
        for x from 0 below max-x
        for building-type-id = (if (and (zerop (mod x 5))
                                          (/= x 0)
                                          (/= x 9)
                                          (/= x 10)
                                          (/= x 11)
                                          (/= x (1- max-x)))
                                   +building-city-pier-north+
                                   +building-city-sea+)
        for random-warehouse-1 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        for random-warehouse-2 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        do
           (level-city-reserve-build-on-grid +building-city-sea+ x 0 2 template-level)
           (level-city-reserve-build-on-grid building-type-id x 1 2 template-level)
           (level-city-reserve-build-on-grid building-type-id x 2 2 template-level)
           
           (when (level-city-can-place-build-on-grid random-warehouse-1 x 3 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-1 x 3 2 template-level))
           (when (level-city-can-place-build-on-grid random-warehouse-2 x 5 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-2 x 5 2 template-level))))

(defun place-seaport-south (template-level warehouse-building-id-1 warehouse-building-id-2)
  (loop with max-x = (array-dimension template-level 0)
        with max-y = (array-dimension template-level 1)
        for x from 0 below max-x
        for building-type-id = (if (and (zerop (mod x 5))
                                          (/= x 0)
                                          (/= x 9)
                                          (/= x 10)
                                          (/= x 11)
                                          (/= x (1- max-x)))
                                   +building-city-pier-south+
                                   +building-city-sea+)
        for random-warehouse-1 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        for random-warehouse-2 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        do
           (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 1) 2 template-level)
           (level-city-reserve-build-on-grid building-type-id x (- max-y 2) 2 template-level)
           (level-city-reserve-build-on-grid building-type-id x (- max-y 3) 2 template-level)
           
           (when (level-city-can-place-build-on-grid random-warehouse-1 x (- max-y 5) 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-1 x (- max-y 5) 2 template-level))
           (when (level-city-can-place-build-on-grid random-warehouse-2 x (- max-y 7) 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-2 x (- max-y 7) 2 template-level))))

(defun place-seaport-east (template-level warehouse-building-id-1 warehouse-building-id-2)
  (loop with max-x = (array-dimension template-level 0)
        with max-y = (array-dimension template-level 1)
        for y from 0 below max-y
        for building-type-id = (if (and (zerop (mod y 5))
                                        (/= y 0)
                                        (/= y 9)
                                        (/= y 10)
                                        (/= y 11)
                                        (/= y (1- max-y)))
                                 +building-city-pier-east+
                                 +building-city-sea+)
        for random-warehouse-1 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        for random-warehouse-2 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        do
           (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 1) y 2 template-level)
           (level-city-reserve-build-on-grid building-type-id (- max-y 2) y 2 template-level)
           (level-city-reserve-build-on-grid building-type-id (- max-y 3) y 2 template-level)
           
           (when (level-city-can-place-build-on-grid random-warehouse-1 (- max-x 5) y 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-1 (- max-x 5) y 2 template-level))
           (when (level-city-can-place-build-on-grid random-warehouse-2 (- max-x 7) y 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-2 (- max-x 7) y 2 template-level))))

(defun place-seaport-west (template-level warehouse-building-id-1 warehouse-building-id-2)
  (loop with max-y = (array-dimension template-level 1)
        for y from 0 below max-y
        for building-type-id = (if (and (zerop (mod y 5))
                                        (/= y 0)
                                        (/= y 9)
                                        (/= y 10)
                                        (/= y 11)
                                        (/= y (1- max-y)))
                                 +building-city-pier-west+
                                 +building-city-sea+)
        for random-warehouse-1 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        for random-warehouse-2 = (if (zerop (random 2))
                                   warehouse-building-id-1
                                   warehouse-building-id-2)
        do
           (level-city-reserve-build-on-grid +building-city-sea+ 0 y 2 template-level)
           (level-city-reserve-build-on-grid building-type-id 1 y 2 template-level)
           (level-city-reserve-build-on-grid building-type-id 2 y 2 template-level)
           
           (when (level-city-can-place-build-on-grid random-warehouse-1 3 y 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-1 3 y 2 template-level))
           (when (level-city-can-place-build-on-grid random-warehouse-2 5 y 2 template-level)
             (level-city-reserve-build-on-grid random-warehouse-2 5 y 2 template-level))))

(defun place-coins-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))

  (log:info "Place coins")
  (let ((total-gold-items (loop for feature-id in (feature-id-list level)
                                for lvl-feature = (get-feature-by-id feature-id)
                                when (= (feature-type lvl-feature) +feature-start-gold-small+)
                                  count lvl-feature)))
    
    (loop for feature-id in (feature-id-list level)
          for lvl-feature = (get-feature-by-id feature-id)
          when (= (feature-type lvl-feature) +feature-start-gold-small+)
            do
               (add-item-to-level-list level (make-instance 'item :item-type +item-type-coin+ :x (x lvl-feature) :y (y lvl-feature) :z (z lvl-feature)
                                                                  :qty (+ (round 1250 total-gold-items) (random 51))))
               (remove-feature-from-level-list level lvl-feature)
          )
    ))

(defun place-civilians-on-level (level world-sector mission world)
  (declare (ignore world-sector world))
  
  (log:info "Place civilians")
  (loop with civilians-present = nil
        for (faction-type faction-presence) in (faction-list mission)
        when (and (= faction-type +faction-type-civilians+)
                  (eq faction-presence :mission-faction-present))
          do
             (setf civilians-present t)
        finally
           (unless civilians-present (return))
           
           ;; find all civilian start points and place civilians there
           (loop for feature-id in (feature-id-list level)
                 for lvl-feature = (get-feature-by-id feature-id)
                 for x = (x lvl-feature)
                 for y = (y lvl-feature)
                 for z = (z lvl-feature)
                 when (= (feature-type lvl-feature) +feature-start-place-civilian-man+)
                   do
                      (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-man+
                                                                       :x x :y y :z z))
                 when (= (feature-type lvl-feature) +feature-start-place-civilian-woman+)
                   do
                      (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-woman+
                                                                       :x x :y y :z z))
                 when (= (feature-type lvl-feature) +feature-start-place-civilian-child+)
                   do
                      (add-mob-to-level-list level (make-instance 'mob :mob-type +mob-type-child+
                                                                       :x x :y y :z z)))
        ))

(defun place-outsider-beasts-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))

  (log:info "Place outsider beasts")
  
  (populate-level-with-mobs level (list (list +mob-type-gargantaur+ 1 nil)
                                        (list +mob-type-wisp+ 9 nil))
                            #'find-unoccupied-place-inside)

  (populate-level-with-mobs level (list (list +mob-type-fiend+ 16 nil))
                            #'find-unoccupied-place-inside)
  
  )

(defun place-demonic-sigils-on-level (level world-sector mission world)
  (declare (ignore world-sector mission))
  
  (log:info "Add demon sigils")
  
  (loop with sigil = nil
        for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        when (= (feature-type lvl-feature) +feature-start-sigil-point+)
          do
             (setf sigil (make-instance 'mob :mob-type +mob-type-demon-sigil+))
             (setf (x sigil) (x lvl-feature) (y sigil) (y lvl-feature) (z sigil) (z lvl-feature))
             (add-mob-to-level-list level sigil)
             (set-mob-effect sigil :effect-type-id +mob-effect-demonic-sigil+ :actor-id (id sigil) :cd t)

             (multiple-value-bind (year month day hour min sec) (get-current-date-time (world-game-time world))
               (declare (ignore year month day min sec))
               (let ((demon-list (if (and (>= hour 7) (< hour 19))
                                   (list (list +mob-type-demon+ 3 nil)
                                         (list +mob-type-imp+ 4 nil))
                                   (list (list +mob-type-demon+ 2 nil)
                                         (list +mob-type-shadow-demon+ 1 nil)
                                         (list +mob-type-imp+ 1 nil)
                                         (list +mob-type-shadow-imp+ 3 nil)))))
                 (place-mobs-on-level-immediate level
                                                :start-point-list (list (list (1+ (x sigil)) (1+ (y sigil)) (z sigil))
                                                                        (list (1- (x sigil)) (1+ (y sigil)) (z sigil))
                                                                        (list (1+ (x sigil)) (1- (y sigil)) (z sigil))
                                                                        (list (1- (x sigil)) (1- (y sigil)) (z sigil)))
                                                :create-player nil
                                                :mob-list demon-list
                                                :no-center nil))))
  )

(defun place-demonic-machines-on-level (level world-sector mission world)
  (declare (ignore world-sector world mission))
  
  (log:info (format nil "OVERALL-POST-PROCESS-FUNC: Add demon machines~%"))
  
  (loop with machine = nil
        for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        when (= (feature-type lvl-feature) +feature-start-machine-point+)
          do
             (setf machine (make-instance 'mob :mob-type +mob-type-demon-machine+))
             (setf (x machine) (x lvl-feature) (y machine) (y lvl-feature) (z machine) (z lvl-feature))
             (add-mob-to-level-list level machine)
             (set-mob-effect machine :effect-type-id +mob-effect-demonic-machine+ :actor-id (id machine) :cd t))
  )

(defun place-flesh-storages-on-level (level world-sector mission world)
  (declare (ignore world-sector world mission))
  
  (log:info (format nil "OVERALL-POST-PROCESS-FUNC: Add flesh storages~%"))
  
  (loop for feature-id in (feature-id-list level)
        for lvl-feature = (get-feature-by-id feature-id)
        when (= (feature-type lvl-feature) +feature-bomb-plant-target+)
          do
             (push feature-id (bomb-plant-locations level))
             ;; accumulate raw flesh terrain inside the feature parameter
             (loop for x from (+ (x lvl-feature) -5) to (+ (x lvl-feature) 5) do
               (loop for y from (+ (y lvl-feature) -5) to (+ (y lvl-feature) 5) do
                 (loop for z from (z lvl-feature) downto 0 do
                   (when (and (> x 0) (> y 0) (< x (array-dimension (terrain level) 0)) (< y (array-dimension (terrain level) 1))
                              (eq (get-terrain-* level x y z) +terrain-wall-raw-flesh+))
                     (push (list x y z) (param1 lvl-feature)))))))
  )

(defun place-blood-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))
  
  (log:info (format nil "OVERALL-POST-PROCESS-FUNC: Place blood spatters~%"))
  (let ((blood ())
        (max-blood (sqrt (* (array-dimension (terrain level) 0)
                            (array-dimension (terrain level) 1)))))
    (loop with max-x = (- (array-dimension (terrain level) 0) 2)
          with max-y = (- (array-dimension (terrain level) 1) 2)
          with max-z = (- (array-dimension (terrain level) 2) 2)
          with cur-blood = 0
          for x = (1+ (random max-x))
          for y = (1+ (random max-y))
          for z = (1+ (random max-z))
          while (< cur-blood max-blood) do
            (when (and (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move-floor+)
                       (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-blocks-move+))
                       (not (get-terrain-type-trait (get-terrain-* level x y z) +terrain-trait-water+)))
              (if (zerop (random 2))
                (push (list x y z +feature-blood-stain+) blood)
                (push (list x y z +feature-blood-old+) blood))
              (incf cur-blood)
              (check-surroundings x y nil #'(lambda (dx dy)
                                              (when (and (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-blocks-move-floor+)
                                                         (not (get-terrain-type-trait (get-terrain-* level dx dy z) +terrain-trait-water+)))
                                                (when (zerop (random 4))
                                                  (push (list dx dy z +feature-blood-old+) blood))))))
          )
    (loop for (x y z feature-type-id) in blood do
      ;;(format t "PLACE PORTAL ~A AT (~A ~A ~A)~%" (name (get-feature-type-by-id feature-type-id)) x y z)
      (add-feature-to-level-list level (make-instance 'feature :feature-type feature-type-id :x x :y y :z z)))))

(defun place-irradation-on-level (level world-sector mission world)
  (declare (ignore world-sector mission world))
  
  (log:info "Place irradiated spots")
  (loop with max-x = (- (array-dimension (terrain level) 0) 2)
        with max-y = (- (array-dimension (terrain level) 1) 2)
        with max-z = (- (array-dimension (terrain level) 2) 2)
        with cur-spot = 0
        with max-spots = (+ 3 (random 10))
        with func = #'(lambda (tx ty tz)
                        (labels ((recursive-func (tx ty tz)
                                   (set-terrain-* level tx ty tz +terrain-floor-creep-irradiated+)
                                   (check-surroundings tx ty nil #'(lambda (dx dy)
                                                                     (when (= (get-terrain-* level dx dy tz) +terrain-floor-creep+)
                                                                       (when (zerop (random 4))
                                                                         (recursive-func dx dy tz)))))))
                          (recursive-func tx ty tz)))
        for x = (1+ (random max-x))
        for y = (1+ (random max-y))
        for z = (1+ (random max-z))
        while (< cur-spot max-spots) do
          (when (= (get-terrain-* level x y z) +terrain-floor-creep+)
            (funcall func x y z)
            (incf cur-spot)))
  )

(defun place-lake-on-template-level (template-level building-lake-id)
    
  (let ((x (- (truncate (array-dimension template-level 0) 2) 2))
        (y (- (truncate (array-dimension template-level 1) 2) 2)))
    
    (level-city-reserve-build-on-grid building-lake-id x y 2 template-level)
    
    ))

(defun place-island-on-template-level (template-level world-sector mission world)
  (declare (ignore mission world mission world-sector))
  
  (log:info "Start")
  
  (let ((max-x (array-dimension template-level 0))
        (max-y (array-dimension template-level 1)))
    ;; place water along the borders
    (loop for x from 0 below max-x
          do
             (level-city-reserve-build-on-grid +building-city-sea+ x 0 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ x 1 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ x 2 2 template-level)
             
             (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 1) 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 2) 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ x (- max-y 3) 2 template-level))
    
    (loop for y from 0 below max-y
          do
             (level-city-reserve-build-on-grid +building-city-sea+ 0 y 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ 1 y 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ 2 y 2 template-level)
             
             (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 1) y 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 2) y 2 template-level)
             (level-city-reserve-build-on-grid +building-city-sea+ (- max-x 3) y 2 template-level))
    
    ;; place four piers - north, south, east, west
    (let ((min) (max) (r))
      ;; north
      (setf min 3 max (- (truncate max-x 2) 1))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-north+ r 1 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-north+ r 2 2 template-level)
      (setf min (+ (truncate max-x 2) 1) max (- max-x 3))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-north+ r 1 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-north+ r 2 2 template-level)
      
      ;; south
      (setf min 3 max (- (truncate max-x 2) 1))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 2) 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 3) 2 template-level)
      (setf min (+ (truncate max-x 2) 1) max (- max-x 3))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 2) 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-south+ r (- max-y 3) 2 template-level)
      
      ;; west
      (setf min 3 max (- (truncate max-y 2) 1))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-west+ 1 r 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-west+ 2 r 2 template-level)
      (setf min (+ (truncate max-y 2) 1) max (- max-y 3))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-west+ 1 r 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-west+ 2 r 2 template-level)
      
      ;; east
      (setf min 3 max (- (truncate max-y 2) 1))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 2) r 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 3) r 2 template-level)
      (setf min (+ (truncate max-y 2) 1) max (- max-y 3))
      (setf r (+ (random (- max min)) min))
      (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 2) r 2 template-level)
      (level-city-reserve-build-on-grid +building-city-pier-east+ (- max-x 3) r 2 template-level))
    )
  )

(defun place-outskirts-on-template-level (template-level building-border-id building-park-id)
    
  ;; place building-park-id along the borders
  (loop with y1 = 0
        with y2 = (array-dimension template-level 1)
        for x from 0 below (array-dimension template-level 0)
        do
           (level-city-reserve-build-on-grid building-border-id x y1 2 template-level)
           (level-city-reserve-build-on-grid building-border-id x (- y2 1) 2 template-level)
           
           (when (level-city-can-place-build-on-grid building-park-id x (+ y1 1) 2 template-level)
             (level-city-reserve-build-on-grid building-park-id x (+ y1 1) 2 template-level))
           (when (level-city-can-place-build-on-grid building-park-id x (- y2 3) 2 template-level)
             (level-city-reserve-build-on-grid building-park-id x (- y2 3) 2 template-level)))
  
  (loop with x1 = 0
        with x2 = (array-dimension template-level 0)
        for y from 0 below (array-dimension template-level 1)
        do
           (level-city-reserve-build-on-grid building-border-id x1 y 2 template-level)
           (level-city-reserve-build-on-grid building-border-id (- x2 1) y 2 template-level)
           
           (when (level-city-can-place-build-on-grid building-park-id (+ x1 1) y 2 template-level)
             (level-city-reserve-build-on-grid building-park-id (+ x1 1) y 2 template-level))
           (when (level-city-can-place-build-on-grid building-park-id (- x2 3) y 2 template-level)
             (level-city-reserve-build-on-grid building-park-id (- x2 3) y 2 template-level)))
  
  )

(defun place-demonic-sigils-on-template-level (template-level)
  (let ((building-id +building-city-sigil-post+)
        (x-w 4)
        (y-n 4)
        (x-e (- (array-dimension template-level 0) 5))
        (y-s (- (array-dimension template-level 1) 5)))
    ;; place nw post
    (when (level-city-can-place-build-on-grid building-id x-w y-n 2 template-level)
      (level-city-reserve-build-on-grid building-id x-w y-n 2 template-level))
    
    ;; place ne post
    (when (level-city-can-place-build-on-grid building-id x-e y-n 2 template-level)
      (level-city-reserve-build-on-grid building-id x-e y-n 2 template-level))
    
    ;; place sw post
    (when (level-city-can-place-build-on-grid building-id x-w y-s 2 template-level)
      (level-city-reserve-build-on-grid building-id x-w y-s 2 template-level))
    
    ;; place se post
    (when (level-city-can-place-build-on-grid building-id x-e y-s 2 template-level)
      (level-city-reserve-build-on-grid building-id x-e y-s 2 template-level))
    
    ))

(defun place-demonic-machines-on-template-level (template-level)
  (let ((building-id-list (get-all-building-ids-by-type +building-type-hell-machine+))
        (x-w 4)
        (y-n 4)
        (x-e (- (array-dimension template-level 0) 5))
        (y-s (- (array-dimension template-level 1) 5))
        (building-id))
    ;; place nw post
    (setf building-id (nth (random (length building-id-list)) building-id-list))
    (when (level-city-can-place-build-on-grid building-id x-w y-n 2 template-level)
      (level-city-reserve-build-on-grid building-id x-w y-n 2 template-level))
    
    ;; place ne post
    (setf building-id (nth (random (length building-id-list)) building-id-list))
    (when (level-city-can-place-build-on-grid building-id x-e y-n 2 template-level)
      (level-city-reserve-build-on-grid building-id x-e y-n 2 template-level))
    
    ;; place sw post
    (setf building-id (nth (random (length building-id-list)) building-id-list))
    (when (level-city-can-place-build-on-grid building-id x-w y-s 2 template-level)
      (level-city-reserve-build-on-grid building-id x-w y-s 2 template-level))
    
    ;; place se post
    (setf building-id (nth (random (length building-id-list)) building-id-list))
    (when (level-city-can-place-build-on-grid building-id x-e y-s 2 template-level)
      (level-city-reserve-build-on-grid building-id x-e y-s 2 template-level))
    
    ))

(defun place-flesh-storages-on-template-level (template-level)
  (let* ((building-id-list (get-all-building-ids-by-type +building-type-hell-storage+))
         (x-step (truncate (array-dimension template-level 0) 4))
         (y-step (truncate (array-dimension template-level 1) 4))
         (x1 (1- (* x-step 1)))
         (x2 (1- (* x-step 2)))
         (x3 (1- (* x-step 3)))
         (y1 (1- (* y-step 1)))
         (y2 (1- (* y-step 2)))
         (y3 (1- (* y-step 3)))
         (variant1 `((,x1 ,y1) (,x1 ,y3) (,x3 ,y2)))
         (variant2 `((,x1 ,y2) (,x3 ,y1) (,x3 ,y3)))
         (variant3 `((,x2 ,y1) (,x1 ,y3) (,x3 ,y3)))
         (variant4 `((,x1 ,y1) (,x3 ,y1) (,x2 ,y3)))
         (variants (list variant1 variant2 variant3 variant4))
         (building-id))

    (loop for (x y) in (nth (random (length variants)) variants)
          do
             (setf building-id (nth (random (length building-id-list)) building-id-list))
             (when (level-city-can-place-build-on-grid building-id x y 2 template-level)
               (level-city-reserve-build-on-grid building-id x y 2 template-level)))
    ))

(defun get-max-buildings-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-house+ max-building-types) t)
    (setf (gethash +building-type-townhall+ max-building-types) t)
    (setf (gethash +building-type-park+ max-building-types) t)
    (setf (gethash +building-type-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-house+ max-building-types) t)
    (setf (gethash +building-type-townhall+ max-building-types) t)
    (setf (gethash +building-type-park+ max-building-types) t)
    (setf (gethash +building-type-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    max-building-types))

(defun get-reserved-buildings-normal ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-reserved-buildings-port ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-max-buildings-ruined-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-house+ max-building-types) t)
    (setf (gethash +building-type-ruined-townhall+ max-building-types) t)
    (setf (gethash +building-type-ruined-park+ max-building-types) t)
    (setf (gethash +building-type-ruined-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-ruined-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-ruined-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-ruined-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    (setf (gethash +building-type-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-crater+ max-building-types) 4)
    (setf (gethash +building-type-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-ruined-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-ruined-house+ max-building-types) t)
    (setf (gethash +building-type-ruined-townhall+ max-building-types) t)
    (setf (gethash +building-type-ruined-park+ max-building-types) t)
    (setf (gethash +building-type-ruined-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-ruined-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-ruined-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 1)
    (setf (gethash +building-type-ruined-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-crater+ max-building-types) 4)
    (setf (gethash +building-type-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-reserved-buildings-ruined-normal ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-reserved-buildings-ruined-port ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-max-buildings-corrupted-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 1)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 4)
    (setf (gethash +building-type-corrupted-graveyard+ max-building-types) 1)
    (setf (gethash +building-type-crater+ max-building-types) 4)
    (setf (gethash +building-type-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-corrupted-port ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-corrupted-house+ max-building-types) t)
    (setf (gethash +building-type-corrupted-townhall+ max-building-types) t)
    (setf (gethash +building-type-corrupted-park+ max-building-types) t)
    (setf (gethash +building-type-corrupted-mansion+ max-building-types) t)
    
    (setf (gethash +building-type-corrupted-warehouse+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-prison+ max-building-types) 1)
    (setf (gethash +building-type-stables+ max-building-types) 0)
    (setf (gethash +building-type-corrupted-bank+ max-building-types) 1)
    (setf (gethash +building-type-lake+ max-building-types) 0)
    (setf (gethash +building-type-crater+ max-building-types) 4)
    (setf (gethash +building-type-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-max-buildings-hell-normal ()
  (let ((max-building-types (make-hash-table)))
    (setf (gethash +building-type-hell-structure+ max-building-types) t)
    (setf (gethash +building-type-hell-growth+ max-building-types) t)
    (setf (gethash +building-type-hell-struct-growth+ max-building-types) t)

    (setf (gethash +building-type-hell-slime-pool+ max-building-types) 4)
    (setf (gethash +building-type-crater+ max-building-types) 4)
    (setf (gethash +building-type-crater-large+ max-building-types) 1)
    max-building-types))

(defun get-reserved-buildings-corrupted-normal ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-reserved-buildings-corrupted-port ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))

(defun get-reserved-buildings-hell-normal ()
  (let ((reserved-building-types (make-hash-table)))
    reserved-building-types))
