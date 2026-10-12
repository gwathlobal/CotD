(in-package :cotd)

;;----------------------
;; TERRAIN-TYPE
;;----------------------
(defclass terrain-type ()
  ((id :initarg :id :accessor id :type fixnum)
   (glyph-idx :initform 0 :initarg :glyph-idx :accessor glyph-idx :type fixnum)
   (glyph-color :initform +color-white+ :initarg :glyph-color :accessor glyph-color :type packed-color)
   (back-color :initform +color-black+ :initarg :back-color :accessor back-color :type packed-color)
   (name :initform "No name terrain" :initarg :name :accessor name)
   (on-step :initform nil :initarg :on-step :accessor on-step) ;; a function that takes (mob x y z)
   (on-use :initform nil :initarg :on-use :accessor on-use) ;; a function that takes (mob x y z)
   (on-bump-terrain :initform nil :initarg :on-bump-terrain :accessor on-bump-terrain) ;; a function that takes (mob x y z)
   ;; TRAIT is the authoritative table, populated by initialize-instance below;
   ;; set-terrain-type mirrors it into *terrain-trait-table* for fast reads.
   (trait :initform (make-hash-table) :initarg :trait :accessor trait)
   ;; Valid :trait-* initargs and their ids are generated from
   ;; *terrain-trait-specs* in globals.lisp; see define-trait-ids there.
   ))


(defun register-terrain-type-traits (terrain-type)
  "Mirror TERRAIN-TYPE's trait table into *terrain-trait-table*.
Terrain types are all registered at load time and their trait tables are never
touched afterwards, so this runs once per type and the table is read-only for
the rest of the session."
  (let* ((id (id terrain-type))
         (rows (array-dimension *terrain-trait-table* 0))
         (cols (array-dimension *terrain-trait-table* 1)))
    ;; grow the table if this id does not fit yet, or if the trait count has
    ;; changed. Never shrink: types do not register in id order, so (1+ id) can
    ;; be smaller than the rows already filled in.
    (when (or (>= id rows) (/= cols +terrain-trait-count+))
      (let* ((new-rows (max (1+ id) rows))
             (new (make-array (list new-rows +terrain-trait-count+) :initial-element nil)))
        (dotimes (i rows)
          (dotimes (k (min cols +terrain-trait-count+))
            (setf (aref new i k) (aref *terrain-trait-table* i k))))
        (setf *terrain-trait-table* new)))
    (dotimes (k +terrain-trait-count+)
      (setf (aref *terrain-trait-table* id k) nil))
    (loop for key being the hash-key in (trait terrain-type) using (hash-value value)
          do (unless (and (typep key 'fixnum)
                          (< -1 key +terrain-trait-count+))
               (error "Terrain type ~A declares trait id ~A, outside 0..~A. Add it to the ~
                       define-trait-ids list in globals.lisp rather than writing ~
                       the id directly."
                      id key (1- +terrain-trait-count+)))
             (setf (aref *terrain-trait-table* id key) value))))

(defun set-terrain-type (terrain-type)
  (when (>= (id terrain-type) (length *terrain-types*))
    (adjust-array *terrain-types* (list (1+ (id terrain-type)))))
  (setf (aref *terrain-types* (id terrain-type)) terrain-type)
  (register-terrain-type-traits terrain-type))

(defun get-terrain-type-by-id (terrain-type-id)
  (aref *terrain-types* terrain-type-id))

(define-trait-initializer terrain-type
    ((*terrain-trait-specs* trait))
    ())

(declaim (inline get-terrain-type-trait))
(defun get-terrain-type-trait (terrain-type-id key)
  "Value of trait KEY for TERRAIN-TYPE-ID, or NIL if it has no such trait.
TERRAIN-TYPE-ID may be NIL - get-terrain-* returns NIL for out-of-range
coordinates and most of the ~360 call sites pass its result straight in - in
which case there is no terrain and so no trait."
  (declare (type (or null fixnum) terrain-type-id) (type fixnum key)
           (optimize (speed 3)))
  (when terrain-type-id
    (aref (the (simple-array t (* *)) *terrain-trait-table*) terrain-type-id key)))

(defun get-terrain-name (terrain-type-id)
  (name (get-terrain-type-by-id terrain-type-id)))

(defun get-terrain-on-step (terrain-type-id)
  (on-step (get-terrain-type-by-id terrain-type-id)))

(defun get-terrain-on-use (terrain-type-id)
  (on-use (get-terrain-type-by-id terrain-type-id)))

(defun get-terrain-on-bump (terrain-type-id)
  (on-bump-terrain (get-terrain-type-by-id terrain-type-id)))


