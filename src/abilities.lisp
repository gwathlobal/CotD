(in-package :cotd)

;;--------------------
;; ABILITY-TYPE
;;--------------------

(defclass ability-type ()
  ((id :initarg :id :accessor id)
   (name :initarg :name :accessor name)
   (descr :initform "" :initarg :descr :accessor descr)
   (cost :initform 0 :initarg :cost :accessor cost)
   (spd :initform +normal-ap+ :initarg :spd :accessor spd)
   (cd :initform 0 :initarg :cd :accessor cd)
   (motion :initform 0 :initarg :motion :accessor motion)
   (passive :initform t :initarg :passive :accessor passive) ;; passive abilities should have their cost set to 0
   (on-touch :initform nil :initarg :on-touch :accessor on-touch :type boolean) ;; if the abilities should be invoked, when actor bumps into target
   (final :initform t :initarg :final :accessor final :type boolean) ;; if the ability is invoked, no further abilities can be invoked
   (removes-disguise :initform nil :initarg :removes-disguise :accessor removes-disguise :type boolean) ;; if this ability is invoked, the disguise effect is removed
   (on-invoke :initform nil :initarg :on-invoke :accessor on-invoke) ;; a function that takes three parameters - ability-type, actor and target
   (on-check-applic :initform nil :initarg :on-check-applic :accessor on-check-applic) ;; a function that takes three parameters - ability type, actor and target
   (on-kill :initform nil :initarg :on-kill :accessor on-kill :type boolean) ;; if the ability should be invoked when actor kills target
   (on-check-ai :initform nil :initarg :on-check-ai :accessor on-check-ai)  ;; a function that checks for the AI if it can and should invoke the ability now
   (on-invoke-ai :initform nil :initarg :on-invoke-ai :accessor on-invoke-ai) ;; a function that invokes the ability for the ai
   (map-select-func :initform nil :initarg :map-select-func :accessor map-select-func) ;; a function that is invoked when the player needs to select the target for the ability, also indicates that this is a targeted ability
   (obj-select-func :initform nil :initarg :obj-select-func :accessor obj-select-func) ;; a function that is invoked when the player needs to select some other object after choosing this ability
   ))

(defun set-ability-type (ability-type)
  (when (>= (id ability-type) (length *ability-types*))
    (adjust-array *ability-types* (list (1+ (id ability-type)))))
  (setf (aref *ability-types* (id ability-type)) ability-type))

(defun get-ability-type-by-id (ability-type-id)
  (aref *ability-types* ability-type-id)) 

(defun can-invoke-ability (actor target ability-type-id)
  (if (and (abil-applic-cost-p ability-type-id actor)
           (abil-applicable-p (get-ability-type-by-id ability-type-id) actor target)
           (abil-applic-cd-p ability-type-id actor))
    t
    nil))

(defun abil-applic-cost-p (ability-type-id mob)
  (if (>= (cur-fp mob)
          (cost (get-ability-type-by-id ability-type-id)))
    t
    nil))

(defun abil-applicable-p (ability-type actor target)
  (if (or (eq (on-check-applic ability-type) nil)
          (and (on-check-applic ability-type)
               (funcall (on-check-applic ability-type) ability-type actor target)))
    t
    nil))

(defun abil-passive-p (ability-type-id)
  (passive (get-ability-type-by-id ability-type-id)))

(defun abil-on-touch-p (ability-type-id)
  (on-touch (get-ability-type-by-id ability-type-id)))

(defun abil-on-kill-p (ability-type-id)
  (on-kill (get-ability-type-by-id ability-type-id)))

(defun abil-final-p (ability-type-id)
  (final (get-ability-type-by-id ability-type-id)))

(defun abil-spd-p (ability-type-id)
  (spd (get-ability-type-by-id ability-type-id)))

(defun abil-max-cd-p (ability-type-id)
  (cd (get-ability-type-by-id ability-type-id)))

(defun abil-cur-cd-p (mob ability-type-id)
  (if (gethash ability-type-id (abilities-cd mob))
    (gethash ability-type-id (abilities-cd mob))
    0))

(defun set-abil-cur-cd (mob ability-type-id value)
  (setf (gethash ability-type-id (abilities-cd mob)) value))

(defun abil-applic-cd-p (ability-type-id mob)
  (if (zerop (abil-cur-cd-p mob ability-type-id))
    t
    nil))

(defun abil-motion-p (ability-type-id)
  (motion (get-ability-type-by-id ability-type-id)))

(defmethod abilities ((mob mob))
  (abilities (get-mob-type-by-id (mob-type mob))))

(defun get-mob-all-abilities (mob)
  (loop
    for ability-type-id being the hash-key in (abilities mob)
    when (gethash ability-type-id (abilities mob))
      collect ability-type-id))

(defun get-mob-applic-abilities (actor target)
  (loop
    for ability-type-id being the hash-key in (abilities actor)
    when (and (gethash ability-type-id (abilities actor))
              (abil-applicable-p (get-ability-type-by-id ability-type-id) actor target))
      collect ability-type-id))

(defun copy-hash-table (hash-table)
  (let ((new-table (make-hash-table)))
    (loop for key being the hash-key in hash-table using (hash-value value) do
      (setf (gethash key new-table) value))
    new-table))
