(in-package :cotd)

(defclass item-type ()
  ((id :initarg :id :accessor id)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name item" :initarg :name :accessor name)
   (descr :initform nil :initarg :descr :accessor descr)
   (max-stack-num :initform 1 :initarg :max-stack-num :accessor max-stack-num)
   (value :initform 0 :initarg :value :accessor value)
   (abilities :initform (make-hash-table) :accessor abilities)
   ;; abil-corpse - +item-abil-corpse+
   (on-use :initform nil :initarg :on-use :accessor on-use)
   (on-check-applic :initform nil :initarg :on-check-applic :accessor on-check-applic)
   (on-check-ai :initform nil :initarg :on-check-ai :accessor on-check-ai)
   ))

(defmethod initialize-instance :after ((item-type item-type) &key abil-corpse)
  (when abil-corpse
    (setf (gethash +item-abil-corpse+ (abilities item-type)) abil-corpse))
  )

(defun get-item-type-by-id (mob-type-id)
  (aref *item-types* mob-type-id))

(defun set-item-type (item-type)
  (when (>= (id item-type) (length *item-types*))
    (adjust-array *item-types* (list (1+ (id item-type)))))
  (setf (aref *item-types* (id item-type)) item-type))

(defun remove-item-from-world (item)
  (setf (aref *items* (id item)) nil))

(defclass item ()
  ((id :initform 0 :accessor id :type fixnum)
   (name :initform nil :accessor name)
   (alive-name :initform "" :accessor alive-name)
   (item-type :initform 0 :initarg :item-type :accessor item-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   (z :initarg :z :initform 0 :accessor z :type fixnum)
   (inv-id :initform nil :accessor inv-id) ;; id of the mob that has this item in its inventory
   (qty :initform 1 :initarg :qty :accessor qty)
   ))

(defmethod initialize-instance :after ((item item) &key)
  (setf (id item) (find-free-id *items*))
  (setf (aref *items* (id item)) item)

  (setf (name item) (format nil "~A" (name (get-item-type-by-id (item-type item)))))
  (when (> (qty item) (max-stack-num item))
    (setf (qty item) (max-stack-num item)))
  )

(defun copy-item (item)
  (let ((new-item))
    (setf new-item (make-instance 'item :item-type (item-type item) :x (x item) :y (y item) :z (z item) :qty (qty item)))
    (setf (name new-item) (format nil "~A" (name item)))
    (setf (inv-id new-item) (inv-id item))
    new-item))

(defun get-item-by-id (item-id)
  (aref *items* item-id))

(defmethod glyph-idx ((item item))
  (glyph-idx (get-item-type-by-id (item-type item))))

(defmethod glyph-color ((item item))
  (glyph-color (get-item-type-by-id (item-type item))))

(defmethod back-color ((item item))
  (back-color (get-item-type-by-id (item-type item))))

(defmethod max-stack-num ((item item))
  (max-stack-num (get-item-type-by-id (item-type item))))

(defmethod value ((item item))
  (* (qty item) (value (get-item-type-by-id (item-type item)))))

(defmethod on-use ((item item))
  (on-use (get-item-type-by-id (item-type item))))

(defmethod on-check-ai ((item item))
  (on-check-ai (get-item-type-by-id (item-type item))))

(defmethod on-check-applic ((item item))
  (on-check-applic (get-item-type-by-id (item-type item))))

(defmethod descr ((item item))
  (descr (get-item-type-by-id (item-type item))))

(defun get-item-descr (item)
  (let ((str (create-string)))
    (format str "~A~%~%~AQty: ~A~A" (name item)
            (if (descr item)
              (format nil "~A~%" (descr item))
              "")
            (qty item)
            (if (not (zerop (value item)))
              (format nil " Value: ~A" (value item))
              ""))
    str))

(defun get-inv-item-by-id (inv item-id)
  (if (find item-id inv)
    (get-item-by-id item-id)
    nil))

(defun get-inv-item-by-pos (inv n)
  (if (and (>= n 0)
             (< n (length inv)))
    (get-item-by-id (nth n inv))
    nil))

(defun get-inv-items-by-type (inv item-type)
  (loop for item-id in inv
        for item = (get-item-by-id item-id)
        when (= item-type (item-type item))
          collect item))

(defun add-to-inv (item inv inv-id)
  ;(unless (inv-id item)
  ;  (remove-item-from-level-list (level *world*) item))
  ;(unless (eq inv-id (inv-id item))
    ;; find the same item type
    (let ((incomplete-stacks (remove-if #'(lambda (a)
                                            (if (= (max-stack-num a) (qty a))
                                              t
                                              nil))
                                        (get-inv-items-by-type inv (item-type item)))))
      (if (null incomplete-stacks)
        (progn
          (push (id item) inv)
          (setf (inv-id item) inv-id))
        (progn
          (incf (qty (first incomplete-stacks)) (qty item))
          (setf (qty item) 0)
          (when (> (qty (first incomplete-stacks)) (max-stack-num (first incomplete-stacks)))
            (setf (qty item) (- (qty (first incomplete-stacks)) (max-stack-num (first incomplete-stacks))))
            (setf (qty (first incomplete-stacks)) (max-stack-num (first incomplete-stacks))))
          (if (zerop (qty item))
            (progn
              (remove-item-from-world item))
            (progn
              (push (id item) inv)
              (setf (inv-id item) inv-id)))))
      )
  ;)
  inv)

(defun remove-from-inv (item inv &key (qty (qty item)))
  (when (zerop qty)
    (return-from remove-from-inv nil))
  (if (/= qty (qty item))
    (progn
      (let ((new-item (copy-item item)))
        (push (id new-item) inv)
        (setf (qty new-item) (- (qty new-item) qty))
        (setf (qty item) qty)
        (setf (inv-id item) nil)
        (remove (id item) inv)))
    (progn
      (setf (inv-id item) nil)
      (remove (id item) inv)))
  )

(defmethod visible-name ((item item))
  (format nil "~A~A"
          (name item)
          (if (> (qty item) 1)
            (format nil " x~A" (qty item))
            "")))

(defun get-overall-value (inv)
  (loop for item-id in inv
        for item = (get-item-by-id item-id)
        sum (value item)))

(defun item-ability-p (item ability-type-id)
  (gethash ability-type-id (abilities (get-item-type-by-id (item-type item)))))
