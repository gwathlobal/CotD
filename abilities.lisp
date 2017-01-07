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
   (passive :initform t :initarg :passive :accessor passive) ;; passive abilities should have their cost set to 0
   (on-touch :initform nil :initarg :on-touch :accessor on-touch :type boolean) ;; if the abilities should be invoked, when actor bumps into target
   (final :initform t :initarg :final :accessor final :type boolean) ;; if the ability is invoked, no further abilities can be invoked
   (on-invoke :initform nil :initarg :on-invoke :accessor on-invoke) ;; a function that takes three parameters - ability-type, actor and target
   (on-check-applic :initform nil :initarg :on-check-applic :accessor on-check-applic) ;; a function that takes three parameters - ability type, actor and target
   (on-kill :initform nil :initarg :on-kill :accessor on-kill :type boolean) ;; if the ability should be invoked when actor kills target
   ))

(defun set-ability-type (ability-type)
  (setf (gethash (id ability-type) *ability-types*) ability-type))

(defun get-ability-type-by-id (ability-type-id)
  (gethash ability-type-id *ability-types*)) 

(defun can-invoke-ability (actor target ability-type-id)
  ;;(format t "CAN-INVOKE-ABILITY: (cur-fp mob) ~A, (cost (get-ability-type-by-id ability-type-id)) ~A, (abil-applicable-p (get-ability-type-by-id ability-type-id) mob) ~A~%" 
  ;;        (cur-fp mob) (cost (get-ability-type-by-id ability-type-id)) (abil-applicable-p (get-ability-type-by-id ability-type-id) mob))
  (if (and (abil-applic-cost-p ability-type-id actor)
           (abil-applicable-p (get-ability-type-by-id ability-type-id) actor target))
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
