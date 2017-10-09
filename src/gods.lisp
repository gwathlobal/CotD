(in-package :cotd)

(defconstant +malseraphs-piety-very-low+ 40)
(defconstant +malseraphs-piety-low+ 80)
(defconstant +malseraphs-piety-medium+ 120)
(defconstant +malseraphs-piety-high+ 160)
(defconstant +malseraphs-piety-very-high+ 200)

(defclass god ()
  ((id :initarg :id :accessor id)
   (name :initform "Unnamed god" :initarg :name :accessor name)
   (piety-level-func :initform #'(lambda (god piety-num)
                                   (declare (ignore god piety-num))
                                   "")
                     :initarg :piety-level-func :accessor piety-level-func)
   (piety-str-func :initform #'(lambda (god piety-num)
                                 (declare (ignore god piety-num))
                                 "")
                   :initarg :piety-str-func :accessor piety-str-func)
   (piety-tick-func :initform #'(lambda (god mob)
                                  (declare (ignore god mob))
                                  nil)
                    :initarg :piety-tick-func :accessor piety-tick-func)
   (piety-change-str-func :initform #'(lambda (god piety-num-new piety-num-old)
                                        (declare (ignore god piety-num-new piety-num-old))
                                        "")
                          :initarg :piety-change-str-func :accessor piety-change-str-func)
   ))

(defun get-god-by-id (god-id)
  (aref *gods* god-id))

(defun set-god-type (god)
  (when (>= (id god) (length *gods*))
    (adjust-array *gods* (list (1+ (id god)))))
  (setf (aref *gods* (id god)) god))

(defun return-piety-str (god-id piety-num)
  (funcall (piety-str-func (get-god-by-id god-id)) (get-god-by-id god-id) piety-num))

(defun get-worshiped-god-type (worshiped-god)
  (first worshiped-god))

(defun get-worshiped-god-piety (worshiped-god)
  (second worshiped-god))

(defun get-worshiped-god-param1 (worshiped-god)
  (third worshiped-god))

(defun check-piety-level-changed (god-id piety-num-old piety-num-new)
  (let ((god (get-god-by-id god-id)))
    (if (/= (funcall (piety-level-func god) god piety-num-old)
            (funcall (piety-level-func god) god piety-num-new))
      t
      nil)))

(defun return-piety-change-str (god-id piety-num-new piety-num-old)
  (funcall (piety-change-str-func (get-god-by-id god-id)) (get-god-by-id god-id) piety-num-new piety-num-old))

(defun increase-piety-for-god (god-id mob piety-inc)
  (when (and (worshiped-god mob)
             (= (get-worshiped-god-type (worshiped-god mob)) god-id))
    (set-mob-piety mob (+ (get-worshiped-god-piety (worshiped-god mob)) piety-inc))))
