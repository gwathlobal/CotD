(in-package :cotd)

;;----------------------
;; FEATURE-TYPE
;;----------------------

(defclass feature-type ()
  ((id :initarg :id :accessor id :type fixnum)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx)
   (glyph-color :initform sdl:*white* :initarg :glyph-color :accessor glyph-color :type sdl:color)
   (back-color :initform sdl:*black* :initarg :back-color :accessor back-color :type sdl:color)
   (name :initform "No name feature" :initarg :name :accessor name)
   (func :initform nil :initarg :func :accessor func)
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; :trait-blocks-vision - +feature-trait-blocks-vision+
   ;; :trait-smoke - +feature-trait-smoke+
   ;; :trait-no-gravity - +feature-trait-no-gravity+
   (can-merge-func :initform #'(lambda (level feature-new)
                                 (let ((result nil))
                                   (loop for feat-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                         for feat-old = (get-feature-by-id feat-old-id)
                                         when (= (feature-type feature-new) (feature-type feat-old))
                                           do
                                              (setf result t)
                                              (loop-finish)
                                         )
                                   result))
                   :initarg :can-merge-func :accessor can-merge-func)
   (merge-func :initform #'(lambda (level feature-new)
                             (loop for feat-old-id in (aref (features level) (x feature-new) (y feature-new) (z feature-new))
                                   for feat-old = (get-feature-by-id feat-old-id)
                                   when (= (feature-type feature-new) (feature-type feat-old))
                                     do
                                        (remove-feature-from-level-list (level *world*) feature-new)
                                        (remove-feature-from-world feature-new)
                                        (loop-finish)
                                   )
                             )
               :initarg :merge-func :accessor merge-func)
   ))

(defun get-feature-type-by-id (feature-type-id)
  (aref *feature-types* feature-type-id))

(defun set-feature-type (feature-type)
  (when (>= (id feature-type) (length *feature-types*))
    (adjust-array *feature-types* (list (1+ (id feature-type)))))
  (setf (aref *feature-types* (id feature-type)) feature-type))

(defmethod initialize-instance :after ((feature-type feature-type) &key trait-blocks-vision trait-smoke trait-no-gravity)
  
  (when trait-blocks-vision
    (setf (gethash +feature-trait-blocks-vision+ (trait feature-type)) trait-blocks-vision))
  (when trait-smoke
    (setf (gethash +feature-trait-smoke+ (trait feature-type)) trait-smoke))
  (when trait-no-gravity
    (setf (gethash +feature-trait-no-gravity+ (trait feature-type)) trait-no-gravity))
  )

;;--------------------
;; FEATURE
;;--------------------

(defclass feature ()
  ((id :initform 0 :initarg :id :accessor id :type fixnum)
   (feature-type :initform 0 :initarg :feature-type :accessor feature-type :type fixnum)
   (x :initarg :x :initform 0 :accessor x :type fixnum)
   (y :initarg :y :initform 0 :accessor y :type fixnum)
   (z :initarg :z :initform 0 :accessor z :type fixnum)
   (counter :initform 0 :initarg :counter :accessor counter :type fixnum)
   ))

(defmethod initialize-instance :after ((feature feature) &key)
  (setf (id feature) (find-free-id *lvl-features*))
  (setf (aref *lvl-features* (id feature)) feature)

  (when (and (zerop (counter feature))
             (get-feature-type-trait feature +feature-trait-smoke+))
    (setf (counter feature) 1))
  )

(defun get-feature-by-id (feature-id)
  (aref *lvl-features* feature-id))

(defun remove-feature-from-world (feature)
  (setf (aref *lvl-features* (id feature)) nil))

(defmethod name ((feature feature))
  (name (get-feature-type-by-id (feature-type feature))))

(defmethod func ((feature feature))
  (func (get-feature-type-by-id (feature-type feature))))

(defmethod can-merge-func ((feature feature))
  (can-merge-func (get-feature-type-by-id (feature-type feature))))

(defmethod merge-func ((feature feature))
  (merge-func (get-feature-type-by-id (feature-type feature))))

(defun get-feature-type-trait (feature feature-trait-id)
  (gethash feature-trait-id (trait (get-feature-type-by-id (feature-type feature)))))

