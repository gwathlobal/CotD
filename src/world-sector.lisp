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
   (overall-post-process-func-list :initform nil :initarg :overall-post-process-func-list :accessor overall-post-process-func-list)) 
  )

(defparameter *world-sector-types* (make-hash-table))

(defun set-world-sector-type (&key wtype glyph-idx glyph-color name faction-list-func sector-level-gen-func template-level-gen-func terrain-post-process-func-list
                                   overall-post-process-func-list)
  (unless wtype (error ":WTYPE is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless glyph-idx (error ":GLYPH-IDX is an obligatory parameter!"))
  (unless glyph-color (error ":GLYPH-COLOR is an obligatory parameter!"))
  
  (setf (gethash wtype *world-sector-types*) (make-instance 'world-sector-type :wtype wtype :glyph-idx glyph-idx :glyph-color glyph-color :name name
                                                                               :faction-list-func faction-list-func
                                                                               :sector-level-gen-func sector-level-gen-func
                                                                               :template-level-gen-func template-level-gen-func
                                                                               :terrain-post-process-func-list terrain-post-process-func-list
                                                                               :overall-post-process-func-list overall-post-process-func-list)))

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


