(in-package :cotd)

(defenum:defenum campaign-effect-enum (:campaign-effect-satanist-lair-visible
                                       :campaign-effect-satanist-sacrifice
                                       :campaign-effect-satanist-lair-hidden
                                       :campaign-effect-demon-protect-dimension
                                       :campaign-effect-demon-turmoil
                                       :campaign-effect-demons-delayed
                                       :campaign-effect-angels-hastened
                                       :campaign-effect-demon-corrupt-portals
                                       :campaign-effect-eater-agitated
                                       :campaign-effect-angel-crusade))

(defclass campaign-effect-type ()
  ((id :initarg :id :accessor campaign-effect-type/id :type campaign-effect-enum)
   (name :initarg :name :accessor campaign-effect-type/name)
   (descr :initarg :descr :accessor campaign-effect-type/descr)
   (merge-func :initform nil :initarg :merge-func :accessor campaign-effect-type/merge-func)
   (on-add-func :initform nil :initarg :on-add-func :accessor campaign-effect-type/on-add-func)
   (on-remove-func :initform nil :initarg :on-remove-func :accessor campaign-effect-type/on-remove-func)))

(defun set-campaign-effect-type (&key id name descr merge-func on-add-func on-remove-func)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name (error ":NAME is an obligatory parameter!"))
  (unless descr (error ":DESCR is an obligatory parameter!"))

  (setf (gethash id *campaign-effect-types*) (make-instance 'campaign-effect-type :id id :name name :descr descr :merge-func merge-func :on-add-func on-add-func :on-remove-func on-remove-func)))

(defun get-campaign-effect-type-by-id (campaign-effect-type-id)
  (gethash campaign-effect-type-id *campaign-effect-types*)) 

(defclass campaign-effect ()
  ((id :initarg :id :accessor campaign-effect/id :type campaign-effect-enum)
   (cd :initform nil :initarg :cd :accessor campaign-effect/cd :type '(or null fixnum))
   (param :initform nil :initarg :param :accessor campaign-effect/param)
   ))

(defmethod campaign-effect/name ((campaign-effect campaign-effect))
  (campaign-effect-type/name (get-campaign-effect-type-by-id (campaign-effect/id campaign-effect))))

(defmethod campaign-effect/descr ((campaign-effect campaign-effect))
  (campaign-effect-type/descr (get-campaign-effect-type-by-id (campaign-effect/id campaign-effect))))

(defmethod campaign-effect/on-add-func ((campaign-effect campaign-effect))
  (campaign-effect-type/on-add-func (get-campaign-effect-type-by-id (campaign-effect/id campaign-effect))))

(defmethod campaign-effect/on-remove-func ((campaign-effect campaign-effect))
  (campaign-effect-type/on-remove-func (get-campaign-effect-type-by-id (campaign-effect/id campaign-effect))))
