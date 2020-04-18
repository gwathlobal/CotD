;;;; -*- Mode: Lisp -*-

;;;; enum-enumeration.lisp --

(in-package "DEFENUM")


;;;; enum-enumeration --

(defclass enum-enumeration (enum:bounded-enumeration)
  ()
  (:documentation "The Enum Enumeration Class.

An interface for the CL-ENUMERATION library.")
  )


(defgeneric enum-enumeration-p (x)
  (:method ((x enum-enumeration)) t)
  (:method ((x t)) nil))


(defmethod initialize-instance :after ((x enum-enumeration) &key)
  (with-slots ((e enum::enumerated-object)
               (start enum::start)
               (end enum::end)
               (cursor enum::cursor)
               )
      x
    (let ((tags (tags e)))
      (typecase start
        (fixnum (multiple-value-bind (start-tag foundp)
                    (nth-enum-tag start e)
                  (if foundp
                      (setf cursor start-tag
                            start start-tag)
                      (error "No tag in enumeration ~S at position ~D."
                             x start))))
        ((or symbol tag) (let ((start-tag (tag-of e start t)))
                           (setf cursor start-tag
                                 start start-tag)))
        )

      (typecase end
        (null (setf end (first (last tags))))
        (fixnum (if (< end (enum-length e))
                    (setf end (nth-enum-tag end e))
                    (setf end (first (last tags)))))
        ((or symbol tag) (let ((end-tag (tag-of e end t)))
                           (setf end end-tag)))
        )
      )))


(defmethod enum:enumerate ((e enum) &key (start 0) end &allow-other-keys)
  (make-instance 'enum-enumeration :object e :start start :end end)
  )
       

(defmethod enum:has-more-elements-p ((x enum-enumeration))
  (not (eq (enum::enumeration-cursor x) (enum::enumeration-end x))))


(defmethod enum:has-next-p ((x enum-enumeration))
  (not (eq (enum::enumeration-cursor x) (enum::enumeration-end x))))


(defmethod enum:next ((x enum-enumeration) &optional default)
  (declare (ignore default))
  (prog1 (enum::enumeration-cursor x)
    (setf (enum::enumeration-cursor x)
          (next-enum-tag (enum::enumeration-object x)
                         (enum::enumeration-cursor x)))))


(defmethod enum:current ((x enum-enumeration) &optional (errorp t) (default nil))
  (cond ((and errorp (not (enum:has-more-elements-p x)))
         (error 'enum::no-such-element :enumeration x))
        ((and (not errorp) (not (enum:has-more-elements-p x)))
         default)
        (t (enum::enumeration-cursor x))))


(defmethod reset ((x enum-enumeration))
  (setf (enum::enumeration-cursor x) (enum::enumeration-start x)))


;;;; end of file -- enum-enumeration.lisp --
