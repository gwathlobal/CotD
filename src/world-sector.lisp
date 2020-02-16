(in-package :cotd)

(defconstant +world-sector-normal-residential+ 0)
(defconstant +world-sector-normal-sea+ 1)
(defconstant +world-sector-normal-island+ 2)
(defconstant +world-sector-normal-port+ 3)
(defconstant +world-sector-normal-lake+ 4)
(defconstant +world-sector-normal-forest+ 5)

(defconstant +world-sector-abandoned-residential+ 6)
(defconstant +world-sector-abandoned-island+ 7)
(defconstant +world-sector-abandoned-port+ 8)
(defconstant +world-sector-abandoned-lake+ 9)
(defconstant +world-sector-abandoned-forest+ 10)

(defconstant +world-sector-corrupted-residential+ 11)
(defconstant +world-sector-corrupted-island+ 12)
(defconstant +world-sector-corrupted-port+ 13)
(defconstant +world-sector-corrupted-lake+ 14)
(defconstant +world-sector-corrupted-forest+ 15)

(defclass world-sector-type ()
  ((wtype :initform nil :initarg :wtype :accessor wtype)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (name :initform "" :initarg :name :accessor name :type string)

   (faction-list-func :initform nil :initarg :faction-list-func :accessor faction-list-func) ;; funcation that returns a list of (list <faction type id> <mission faction status id>)

   (sector-level-gen-func :initform nil :initarg :sector-level-gen-func :accessor sector-level-gen-func)
   (item-process-func :initform nil :initarg :item-process-func :accessor item-process-func)
   (mob-process-func :initform nil :initarg :mob-process-func :accessor mob-process-func)
   (feature-process-func :initform nil :initarg :feature-process-func :accessor feature-process-func)
   (terrain-post-process-func :initform nil :initarg :terrain-post-process-func :accessor terrain-post-process-func)) 
  )

(defparameter *world-sector-types* (make-hash-table))

(defun set-world-sector-type (world-sector-type)
  (setf (gethash (wtype world-sector-type) *world-sector-types*) world-sector-type))

(defun get-world-sector-type-by-id (world-sector-type-id)
  (gethash world-sector-type-id *world-sector-types*))

(defclass world-sector ()
  ((wtype :initform nil :initarg :wtype :accessor wtype) ;; ids from feature-layout
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
