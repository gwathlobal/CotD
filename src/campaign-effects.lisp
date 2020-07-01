(in-package :cotd)

(defenum:defenum campaign-effect-enum (:campaign-effect-satanist-lair-visible))

(defclass campaign-effect-type ()
  ((id :initarg :id :accessor campaign-effect-type/id :type campaign-effect-enum)
   (name :initarg :name :accessor campaign-effect-type/name)
   (descr :initarg :descr :accessor campaign-effect-type/descr)
   (merge-func :initform nil :initarg :merge-func :accessor campaign-effect-type/merge-func)))

(defun set-campaign-effect-type (&key id name descr merge-func)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless descr (error ":DESCR is an obligatory parameter!"))

  (setf (gethash id *campaign-effect-types*) (make-instance 'campaign-effect-type :id id :name name :descr descr :merge-func merge-func)))

(defun get-campaign-effect-type-by-id (campaign-effect-type-id)
  (gethash campaign-effect-type-id *campaign-effect-types*)) 

(defclass campaign-effect ()
  ((id :initform 0 :accessor campaign-effect/id :type campaign-effect-enum)
   (cd :initform nil :initarg :cd :accessor campaign-effect/cd :type '(or null fixnum))
   (param :initform nil :initarg :param :accessor campaign-effect/param)
   ))




