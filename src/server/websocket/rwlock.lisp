;;;; rwlock.lisp

(in-package :cotd)

;;;; https://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock#Using_a_condition_variable_and_a_mutex
;;;; Implementation of a read-writer-lock using a conditional variable and a mutex

;;;; Credits go to https://github.com/K1D77A/cl-read-writer-lock

(defclass rw-lock ()
  ((condition-var :accessor condition-var :initform (bt2:make-condition-variable))
   (g-lock :accessor g-lock :initform (bt2:make-lock) :type bt:lock)
   (readers-active :accessor readers-active :initform 0 :type integer)
   (writers-waiting :accessor writers-waiting :initform 0 :type integer)
   (active-writer-p :accessor active-writer-p :initform nil :type boolean)))

(defun make-rw-lock ()
  (make-instance 'rw-lock))

(defmacro while-loop (test &body body)
  `(loop :while ,test
         :do ,@body))

(defmacro with-write-lock (reader-writer-lock &body body)
  (let ((retval (gensym))
        (lock (gensym)))
    `(let ((,retval nil)
           (,lock ,reader-writer-lock))
       (with-accessors ((g g-lock)
                        (ra readers-active)
                        (ww writers-waiting)
                        (c-var condition-var))
           ,lock
         (bt2:with-lock-held (g)
           (unwind-protect
                (incf ww)
             (unwind-protect
                  (progn
                    (while-loop (> ra 0)
                                (bt2:condition-wait c-var g))
                    (setf ,retval (locally ,@body)))
               (decf ww)
               (bt2:condition-notify c-var)))))
       ,retval)))

(defmacro with-read-lock (reader-writer-lock &body body)
  (let ((retval (gensym))
        (lock (gensym)))
    `(let ((,retval ,nil)
           (,lock ,reader-writer-lock))
       (with-accessors ((g g-lock)
                        (ww writers-waiting)
                        (c-var condition-var)
                        (ra readers-active))
           ,lock
         (bt2:with-lock-held (g)
           (unwind-protect
                (while-loop (> ww 0)
                            (bt2:condition-wait c-var g))
             (unwind-protect
                  (progn (incf ra)
                         (setf ,retval (locally ,@body)))
               (decf ra)
               (when (zerop ra)
                 (bt2:condition-notify c-var))))))
       ,retval)))
