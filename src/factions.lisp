(in-package :cotd)

(defclass faction-type ()
  ((id :initarg :id :accessor id)
   (name :initarg :name :accessor name)
   (faction-relations :initarg :faction-relations :accessor faction-relations)
   (specific-faction-list :initform () :initarg :specific-faction-list :accessor specific-faction-list)))

(defmethod initialize-instance :after ((faction-type faction-type) &key)
  (let ((faction-table (make-hash-table)))
    (loop
      for (faction . rel) in (faction-relations faction-type) 
      do
         (setf (gethash faction faction-table) rel))
    (setf (faction-relations faction-type) faction-table)
    ))

(defun set-faction-type (faction-type)
  (when (>= (id faction-type) (length *faction-types*))
    (adjust-array *faction-types* (list (1+ (id faction-type))) :initial-element nil))
  (setf (aref *faction-types* (id faction-type)) faction-type))

(defun get-faction-type-by-id (faction-type-id)
  (aref *faction-types* faction-type-id)) 

;; values should be (faction . relation)
(defun set-faction-relations (faction-type &rest values)
  (let ((faction-table (make-hash-table)))
    (loop
      for (faction . rel) in values 
      do
         (setf (gethash faction faction-table) rel))
    (setf (faction-relations faction-type) faction-table)
  ))
  
(defun get-faction-relation (faction-type-id-1 faction-type-id-2)
  (if (null (faction-relations (get-faction-type-by-id faction-type-id-1)))
    ;; no relation set for faction-type-id-1, which means they are enemies to everybody 
    (return-from get-faction-relation nil)
    ;; return the relation for faction-type-id-2, if not set - then they are enemies
    (gethash faction-type-id-2 (faction-relations (get-faction-type-by-id faction-type-id-1))))
  )

(defun specific-belongs-to-general-faction (specific-faction-id)
  (loop for faction-type across *faction-types*
        when (and faction-type
                  (find specific-faction-id (specific-faction-list faction-type)))
          do
             (return-from specific-belongs-to-general-faction (id faction-type)))
  nil)
