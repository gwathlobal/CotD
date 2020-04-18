;;;; -*- Mode: Lisp -*-

;;;; lambda-list-parsing.lisp --
;;;;
;;;; See file COPYING for more information.

(in-package "DEFENUM")


;;;;===========================================================================
;;;; Types and Classes.

(deftype lambda-list-type ()
  '(member :ordinary
           :specialized
           :generic-function
           :destructuring
           :macro
           ))


(deftype lambda-list-var-type ()
  '(member &reqvar ; Just for symmetry.
           &whole
           &environment
           &optional
           &rest
           &body
           &key
           &allow-other-keys
           &aux
           ))


(defstruct (t_lambda-list
            (:conc-name ll-)
            (:constructor nil)
            (:copier nil))
  (ordinary-vars () :type list :read-only t)
  (optional-vars () :type list :read-only t)
  (keyword-vars () :type list :read-only t)
  (rest-var () :type list :read-only t)
  (auxiliary-vars () :type list :read-only t)
  (allow-other-keys nil :type boolean :read-only t)
  )


(defstruct (lambda-list-item
            (:conc-name lli-)
            (:constructor mkllitem (item kind &optional (form item))))
  (item nil :type (or symbol t_lambda-list list) :read-only t)
  (kind '&reqvar :type lambda-list-var-type :read-only t)
  (form () :type (or symbol cons) :read-only t)
  )


(defstruct (lambda-list-var
            (:include lambda-list-item)
            (:conc-name llv-)
            (:constructor mkllvar (item kind &optional (form item))))
  )


(declaim (inline lli-name llv-name))

(defun lli-name (lli)
  (declare (type lambda-list-item lli))
  (lli-item lli))


(defun llv-name (lli)
  (declare (type lambda-list-item lli))
  (llv-item lli))


(defstruct (ordinary-lambda-list
            (:include t_lambda-list)
            (:constructor
             make-ordinary-lambda-list (&optional
                                        ordinary-vars
                                        optional-vars
                                        rest-var
                                        keyword-vars
                                        allow-other-keys
                                        auxiliary-vars
                                        ))))


(defstruct (specialized-lambda-list
            (:include t_lambda-list)
            (:constructor
             make-specialized-lambda-list (&optional
                                           ordinary-vars
                                           optional-vars
                                           rest-var
                                           keyword-vars
                                           allow-other-keys
                                           auxiliary-vars
                                           ))))


(defstruct (generic-function-lambda-list
            (:include t_lambda-list)
            (:constructor
             make-generic-function-lambda-list (&optional
                                                ordinary-vars
                                                optional-vars
                                                rest-var
                                                keyword-vars
                                                allow-other-keys
                                                auxiliary-vars
                                                ))))


(defstruct (destructuring-lambda-list
            (:include t_lambda-list)
            (:constructor
             make-destructuring-lambda-list (&optional
                                             ordinary-vars
                                             optional-vars
                                             rest-var
                                             keyword-vars
                                             allow-other-keys
                                             auxiliary-vars
                                             ))))


(defstruct (macro-lambda-list
            (:include destructuring-lambda-list)
            (:constructor
             make-macro-lambda-list (&optional
                                     whole-var
                                     env-var
                                     ordinary-vars
                                     optional-vars
                                     rest-var
                                     body-var
                                     keyword-vars
                                     allow-other-keys
                                     auxiliary-vars
                                     )))
  (whole-var () :type list :read-only t)
  (env-var () :type list :read-only t)
  (body-var () :type list :read-only t)
  )


;;;;============================================================================
;;;; Lambda List Parsing.
;;;;
;;;; There ar essentially two types of lambda lists: destructuring and not.
;;;; The implementation choice is thus to have two main "parsing
;;;; functions" returning multiple values.
  
(defgeneric parse-ll (lltype ll))


(defmethod parse-ll ((lltype (eql :ordinary)) ll)
  (multiple-value-bind (wholevar
                        envvar
                        reqvars
                        optvars
                        restvar
                        bodyvar
                        keyvars
                        allow-other-keys
                        auxvars)
      (pll lltype ll nil)
    (declare (ignore wholevar envvar bodyvar))
    (make-ordinary-lambda-list reqvars
                               optvars
                               restvar
                               keyvars
                               (not (null allow-other-keys))
                               auxvars
                               )))


(defmethod parse-ll ((lltype (eql :specialized)) ll)
  (multiple-value-bind (wholevar
                        envvar
                        reqvars
                        optvars
                        restvar
                        bodyvar
                        keyvars
                        allow-other-keys
                        auxvars)
      (pll lltype ll nil)
    (declare (ignore wholevar envvar bodyvar))
    (make-specialized-lambda-list reqvars
                                  optvars
                                  restvar
                                  keyvars
                                  (not (null allow-other-keys))
                                  auxvars
                                  )))


(defmethod parse-ll ((lltype (eql :generic-function)) ll)
  (multiple-value-bind (wholevar
                        envvar
                        reqvars
                        optvars
                        restvar
                        bodyvar
                        keyvars
                        allow-other-keys
                        auxvars)
      (pll lltype ll nil)
    (declare (ignore wholevar envvar bodyvar))
    (make-specialized-lambda-list reqvars
                                  optvars
                                  restvar
                                  keyvars
                                  (not (null allow-other-keys))
                                  auxvars
                                  )))


(defmethod parse-ll ((lltype (eql :destructuring)) ll)
  (multiple-value-bind (wholevar
                        envvar
                        reqvars
                        optvars
                        restvar
                        bodyvar
                        keyvars
                        allow-other-keys
                        auxvars)
      (pll lltype ll t)
    (declare (ignore wholevar envvar bodyvar))
    (make-destructuring-lambda-list reqvars
                                    optvars
                                    restvar
                                    keyvars
                                    (not (null allow-other-keys))
                                    auxvars
                                    )))


(defmethod parse-ll ((lltype (eql :macro)) ll)
  (multiple-value-bind (wholevar
                        envvar
                        reqvars
                        optvars
                        restvar
                        bodyvar
                        keyvars
                        allow-other-keys
                        auxvars)
      (pll lltype ll t)
    (make-macro-lambda-list wholevar
                            envvar
                            reqvars
                            optvars
                            restvar
                            bodyvar
                            keyvars
                            (not (null allow-other-keys))
                            auxvars
                            )))


;;; pll --
;;; The actual work-horse.
;;; Let's try a different implementation than what tried previously.

(defun pll (ll-type ll &optional recur)
  (declare (type lambda-list-type ll-type)
           (type boolean recur))

  (let ((state '&reqvar)
        (wholevar ())
        (reqvars ())
        (optvars ())
        (restvar ())
        (bodyvar ())
        (keyvars ())
        (auxvars ())
        (envvar ())

        (allow-other-keys ())

        (destr-p ll-type #|(if recur
                               :destructuring
                               :non-destructuring)|#)
        )
    (declare (type lambda-list-var-type state)
             (type list wholevar reqvars optvars restvar bodyvar keyvars auxvars envvar)
             (type lambda-list-type destr-p)
             )
    (labels ((start (ll)
               (keep-parsing ll))

             (keep-parsing (ll)
               ;; (format t "||| ~A~%" ll)
               (if (null ll)
                   (finish)
                   (typecase ll
                     (symbol ; dotted-pair &rest-like variable.
                      (push (mkllvar ll '&rest) restvar)
                      (finish))
                     (list
                      ;; (format t ">>> ~A ~A~%" state (first ll))
                      (change-state (first ll) (rest ll))
                      ))
                   ))

             (change-state (v rest-ll)
               (let ((next-v nil))
                 (declare (type boolean next-v))
                 (macrolet ((test-and-change-state (s)
                              `(when (eq v ,s)
                                 (setf state ,s next-v t)))
                            )
                   (test-and-change-state '&reqvar)
                   (test-and-change-state '&whole)
                   (test-and-change-state '&environment)
                   (test-and-change-state '&optional)
                   (test-and-change-state '&key)
                   (test-and-change-state '&rest)
                   (test-and-change-state '&body)
                   (test-and-change-state '&aux)
                   (test-and-change-state '&allow-other-keys)

                   ;; (format t "<<< ~A ~A ~A~%" rest-ll state (first rest-ll))

                   (cond ((or (eq state '&reqvar)
                              (eq state '&allow-other-keys)
                              (null next-v))
                          (next state v rest-ll))

                         ((and (eq state '&key)
                               (eq (first rest-ll) '&allow-other-keys))
                          (setf state '&allow-other-keys)
                          (next state '&allow-other-keys (rest rest-ll)))
                          
                         (t (next state (first rest-ll) (rest rest-ll))))
                   ))
               )

             (next (s v rest-ll)
               (case s
                 (&reqvar
                  (etypecase v
                    (symbol (push (mkllvar v '&reqvar) reqvars))
                    (list (push (if recur
                                    (parse-ll destr-p v)
                                    (mkllvar (first v) '&reqvar v))
                                reqvars)))
                  )

                 (&key
                  (etypecase v
                    (symbol (push (mkllvar v '&key) keyvars))
                    (list
                     (destructuring-bind (k . iv-ksp)
                         v
                       (typecase k
                         (symbol (push (mkllvar k '&key v) keyvars))
                         (list
                          (push
                           (mkllvar (first k) ; This is what is "visible".
                                    '&key
                                    `((,(first k)
                                       ,(if recur
                                            (if (listp (second k)) 
                                                (parse-ll destr-p (second k))
                                                (parse-ll destr-p (rest k)) ; Faking a Lambda List.
                                                )
                                            (second k)
                                            ))
                                      ,@iv-ksp))
                           keyvars)))))
                    )
                  )

                 (&optional
                  (etypecase v
                    (symbol (push (mkllvar v '&optional) optvars))
                    (list
                     (destructuring-bind (o . iv-osp)
                         v
                       (typecase o
                         (symbol (push (mkllvar o '&optional v) optvars))
                         (list (push 
                                (mkllitem (if recur
                                              (parse-ll destr-p o) 
                                              o)
                                          '&optional
                                          iv-osp)
                                     optvars)))))
                    )
                  )
                
                 (&rest
                  (etypecase v
                    (symbol (push (mkllvar v s) restvar))
                    (list (push (if recur
                                    (parse-ll destr-p v)
                                    (mkllvar (first v) s v))
                                restvar)))
                  )

                 (&body
                  (etypecase v
                    (symbol (push (mkllvar v s) bodyvar))
                    (list (push (if recur
                                    (parse-ll destr-p v)
                                    (mkllvar (first v) s v))
                                bodyvar)))
                  )

                 #|
                 (&rest
                  (etypecase v
                    (symbol (push (mkllvar v s) restvar))
                    (list (push (mkllitem (parse-ll destr-p v) s) restvar)))
                  )

                 (&body
                  (etypecase v
                    (symbol (push (mkllvar v s) bodyvar))
                    (list (push (mkllitem (parse-ll destr-p v) s) bodyvar)))
                  )
                 |#

                 (&whole
                  (push (mkllvar v '&whole) wholevar))

                 (&environment
                  (push (mkllvar v '&whole) envvar))

                 (&aux
                  (typecase v
                    (symbol (push (mkllvar v '&aux) auxvars))
                    (list (push (mkllvar (first v) '&aux v) auxvars))))

                 (&allow-other-keys
                  (pushnew t allow-other-keys))
                 )
               (keep-parsing rest-ll))

             (finish ()
               (values wholevar
                       envvar
                       (nreverse reqvars)
                       (nreverse optvars)
                       restvar
                       bodyvar
                       (nreverse keyvars)
                       allow-other-keys
                       (nreverse auxvars)
                       ))

             )
      (start ll)
      )))


;;;---------------------------------------------------------------------------
;;; Utilities.

(defgeneric ll-vars (ll))

(defmethod ll-vars ((ll t_lambda-list))
  (nconc (mapcar #'lli-name (ll-ordinary-vars ll))
         (mapcar #'lli-name (ll-optional-vars ll))
         (mapcar #'lli-name (ll-rest-var ll))
         (mapcar #'lli-name (ll-keyword-vars ll))
         (mapcar #'lli-name (ll-auxiliary-vars ll)))
  )


(defmethod ll-vars ((lli lambda-list-item))
  (lli-name lli))


(defmethod ll-vars ((ll destructuring-lambda-list))
  (nconc (mapcar #'ll-vars (ll-ordinary-vars ll))
         (mapcar #'ll-vars (ll-optional-vars ll))
         (mapcar #'ll-vars (ll-rest-var ll))
         (mapcar #'ll-vars (ll-keyword-vars ll))
         (mapcar #'ll-vars (ll-auxiliary-vars ll)))
  )


(defmethod ll-vars ((ll macro-lambda-list))
  (nconc (mapcar #'ll-vars (macro-lambda-list-whole-var ll))
         (mapcar #'ll-vars (macro-lambda-list-env-var ll))
         (mapcar #'ll-vars (ll-ordinary-vars ll))
         (mapcar #'ll-vars (ll-optional-vars ll))
         (mapcar #'ll-vars (ll-rest-var ll))
         (mapcar #'ll-vars (macro-lambda-list-body-var ll))
         (mapcar #'ll-vars (ll-keyword-vars ll))
         (mapcar #'ll-vars (ll-auxiliary-vars ll)))
  )


(defgeneric ll-recall (ll)
  (:documentation
   "Produces an 'actual' argument list using the lambda list variables.

This function is useful in order to write code transformers. It
produces a proper argument list suitable for use with APPLY.

Examples:

 cl-prompt> (ll-recall (parse-ll :ordinary
                                 '(a b &optional (c 42) &key (baz 42) &aux (foo 123))))
 (A B C :BAZ BAZ ())

 cl-prompt> (ll-recall (parse-ll :ordinary
                                 '(a b &rest more)))
 (A B MORE)

 cl-prompt> (ll-recall (parse-ll :ordinary
                                 '(a b &rest keys &key (foo 42))))
 (A B :FOO FOO KEYS)
")
  )


(defmethod ll-recall ((ll t_lambda-list))
  (let* ((rest-var-name (mapcar #'lli-name (ll-rest-var ll)))
         (rest-var-name-l (or rest-var-name (list '())))
         )
    (nconc (mapcar #'lli-name (ll-ordinary-vars ll))
           (mapcar #'lli-name (ll-optional-vars ll))
           (mapcan #'list
                   (mapcar #'(lambda (kli)
                               (let ((form (lli-form kli)))
                                 (cond ((symbolp form)
                                        (intern (string form) "KEYWORD"))
                                       ((symbolp (first form))
                                        (intern (string (first form)) "KEYWORD"))
                                       (t
                                        (second (first form))))))
                           (ll-keyword-vars ll))
                   (mapcar #'lli-name (ll-keyword-vars ll)))
           rest-var-name-l
           )))

;;;; end of file -- lambda-list-parsing.lisp --
