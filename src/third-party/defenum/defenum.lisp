;;;; -*- Mode: Lisp -*-

;;;; defenum.lisp --
;;;; Enum Types for Common Lisp.
;;;;
;;;; See file COPYING for copyright and licensing information.


(in-package "DEFENUM")

;;;;===========================================================================
;;;; "enum" types and functions.

;;;;---------------------------------------------------------------------------
;;;; ENUMs

(defstruct (enum (:constructor nil)
                 (:copier nil))
  "The (abstract) Enum Structure.

Every enum will be derived from this structure, which cannot be
instantiated.  All enums will be singletons and stored in an 'enum
namespace'."

  (name nil :type symbol :read-only t)
  (tags () :type list :read-only t)
  (constructor-arguments () :type list :read-only t)
  (length 0 :type fixnum :read-only t)
  (id-map (make-hash-table :test #'eql)) ; FTTB.
  )


(defun tags (e)
  "Returns the tags of an enum."
  (declare (type (or symbol enum) e))
  (etypecase e
    (enum (enum-tags e))
    (symbol (enum-tags (find-enum e t)))))


(defvar *enums-namespace* (make-hash-table :test #'eq)
  "The 'enum namespace'.")


(defun find-enum (name &optional errorp environment)
  "Finds an enum with name NAME in the system.

FIND-ENUM behaves like FIND-CLASS.  If ERRORP is true and no enum is
found in the system an error is signaled.  ENVIRONMENT is present for
symmetry with FIND-CLASS and it is currently unused.

Arguments and Values:

NAME : a SYMBOL
ERRORP : a generalized boolean
ENVIRONMENT : an environment object (or NIL)
result : an ENUM instance or NIL.
"
  (declare (ignore environment))
  (or (gethash name *enums-namespace*)
      (and errorp (error "No enum named ~S found." name))))


(defun (setf find-enum) (enum-object name &optional errorp environment)
  (declare (ignore errorp environment))
  (setf (gethash name *enums-namespace*) enum-object))


(defun get-tag-from-id (enum id)
  (declare (type enum enum)
           (type fixnum id))
  (gethash id (enum-id-map enum)))


(defun (setf get-tag-from-id) (tag enum id)
  (declare (type enum enum)
           (type fixnum id))
  (setf (gethash id (enum-id-map enum)) tag))


(defmethod print-object ((e enum) stream)
  (print-unreadable-object (e stream)
    (format stream "ENUM ~S ~S"
            (enum-name e)
            (mapcar #'tag-name (tags e)))))


;;;;---------------------------------------------------------------------------
;;;; TAGs

(defstruct (tag (:constructor nil)
                (:conc-name %tag-)
                (:predicate %tag-p)
                (:copier nil))
  (enum nil :type symbol)
  (name nil :type symbol :read-only t))


;;; tag-p --
;;; The predicate checks some more....

(defun tag-p (s)
  "Checks whether the argument is a valid tag for an enum."
  (or (and (symbolp s)
           (get s '%%enum%%)
           t)
      (%tag-p s)))


;;; tag-enum, tag-name --

(defun tag-enum (td &optional errorp)
  "Returns the enum type where the tag designator TD belongs.

If TD is not a tag in an enum and ERRORP is non-NIL, an error is
signaled.  Otherwise NIL is returned.

Arguments and Values:

TD : a 'tag designator'
ERRORP : a generalized boolean (default NIL).
result : the ENUM object or NULL
"
  (cond ((tag-p td) (if (symbolp td)
                       (get td '%%enum%%)
                       (%tag-enum td)))
        (errorp
         (if (not (tag-p td))
             (error "~S is not an ENUM tag." td)
             (error "No parent ENUM found for ~S." td)))
        (t nil)))


(defun tag-name (e)
  (declare (type (or symbol tag) e))
  (etypecase e
    (symbol (if (tag-p e)
                e
                (error "~S is not a tag of an enum." e)))
    (tag (%tag-name e))))


(defun tag-name-internal (e) ; Like TAG-NAME, but no error raised.
  (declare (type (or symbol tag) e))
  (etypecase e
    (symbol e)
    (tag (%tag-name e))))

#|
(defmethod print-object ((tag tag) stream)
  (let* ((te (tag-enum tag))
         (en (and te (enum-name te)))
         )
    (print-unreadable-object (tag stream)
      (format stream "TAG ~S~@[ of ~S~]"
              (%tag-name tag)
              en))))
|#


(defmethod print-object ((tag tag) stream)
  (print-unreadable-object (tag stream)
    (format stream "~@[~S ~]TAG ~S"
            (tag-enum tag)
            (%tag-name tag))))


;;;;---------------------------------------------------------------------------
;;;; tag specs
;;;; Syntax element.  This is an 'internal' data structure.
;;;; A "canonicalized" tag-spec is a list like
;;;;
;;;;    (tag N (init1 init2 ... initk) M1 M2 M3 ... MN)
;;;; 
;;;; The surface syntax can be any of the following:
;;;;
;;;;    tag
;;;;
;;;;    (tag N)
;;;;
;;;;    (tag (init1 init2 ... initk))
;;;;
;;;;    (tag (init1 init2 ... initk) M1 M2 M3 ... MN)
;;;;
;;;;    (tag N (init1 init2 ... initk) M1 M2 M3 ... MN)
;;;;
;;;; where 'tag' is a SYMBOL.
;;;; Note that N can either be an integer or a (EQL form)

(defstruct (tag-spec
            (:constructor make-tag-spec (tag id &optional args &rest methods))
            (:type list))
  (tag nil :type symbol :read-only t)
  (id 0 :type fixnum :read-only t)
  (args () :type list :read-only t)
  (methods () :type list :read-only t)
  )


;;;;---------------------------------------------------------------------------
;;;; method specs
;;;; Syntax element.  This is an 'internal' data structure.
;;;; A method-spec is a list built from a list like:
;;;;
;;;;    (:method method-name [q1 q2 ... qm] (arg0 arg1 ... argk) . body)

(defstruct (method-spec
            (:constructor make-method-spec (name quals args &rest body))
            (:type list))
  (method-keyword :method :type keyword :read-only t)
  (name nil :type symbol :read-only t)
  (quals () :type list :read-only t)
  (args () :type list :read-only t)
  (body () :type list :read-only t)
  )


(defun parse-method-spec (ms)
  (destructuring-bind (m-kwd m-name &rest qs-as-b)
      ms
    (unless (eq m-kwd :method)
      (error "Unrecognized method specification keyword ~S." m-kwd))
    (unless (symbolp m-name)
      (error "Method name ~S is not a symbol." m-name))

    (let ((quals ())
          (as-b ())
          )
      (loop for (ms-e . more-ms-es) on qs-as-b
            while (symbolp ms-e)
            collect ms-e into qs
            finally (setf quals qs
                          as-b (cons ms-e more-ms-es)))
      (apply #'make-method-spec m-name quals (first as-b) (rest as-b)))
    ))


;;;;---------------------------------------------------------------------------
;;;; types
;;;; Implementation types.  Not exported.

(deftype enum-designator ()
  '(or symbol enum))


(deftype tag-designator ()
  '(or symbol tag))


;;;;---------------------------------------------------------------------------
;;;; enum functions.

(defun tag-of (e tag &optional errorp)
  "Returns the tag object designated by TAG in enum E.

Arguments and Values:

E : an enum designator (either an ENUM object or a SYMBOL).
TAG : a tag designator (either a TAG object or a SYMBOL) or a FIXNUM.
ERRORP : a boolean.
RESULT : a tag designator.
"
  (declare (type enum-designator e)
           (type (or fixnum tag-designator) tag)
           (type boolean errorp))

  (let* ((e (if (enum-p e) e (find-enum e t)))
         (tags (enum-tags e))
         )
    (declare (type enum e)
             (type list tags))
    (or (etypecase tag
          (symbol (find tag tags :test #'eq :key #'tag-name-internal))
          (tag    (find tag tags :test #'eq))
          (fixnum (find (gethash tag (enum-id-map e)) tags))
          )
        (and errorp
             (error "No tag designated by ~S in enum ~S."
                    tag
                    e))
        )))


(defun nth-enum-tag (n enum)
  "Returns the N-th tag in enum ENUM.

Arguments and Values:

N : a FIXNUM
ENUM : an enum designator (either an ENUM object or a SYMBOL).
result1 : a tag designator.
result2 : whether a tag was actually found.
"
  (declare (type enum-designator enum)
           (type fixnum n))
  (let* ((enum (etypecase enum
                 (symbol (find-enum enum))
                 (enum enum)))
         (in-bounds-p (<= 0 n (1- (enum-length enum))))
         )
    (values (nth n (enum-tags enum)) in-bounds-p)))


(defun previous-enum-tag (e tag)
  "Given a tag designator TAG, returns the 'previous' tag in the enum
E or NIL.

Arguments and Values:

enum : an enum designator (either an ENUM object or a SYMBOL).
tag : a tag designator (either a TAG object or a SYMBOL) or a FIXNUM.
result : a tag designator or NIL.
"
  (declare (type enum-designator tag)
           (type (or fixnum tag-designator) tag))
  (etypecase e
    (enum
     (let* ((tag (tag-of e tag))
            (ts (enum-tags e))
            (tp (position tag ts :test #'eq))
            )
       (declare (type tag-designator tag)
                (type list ts)
                (type (or null (integer 0)) tp))
       (when (and tp (< 0 tp (enum-length e)))
         (nth (1- tp) ts))))

    (symbol
     (previous-enum-tag (find-enum e t) tag))
    ))


(defun next-enum-tag (e tag)
  "Given a tag designator TAG, returns the 'next' tag in the enum E or NIL. 

Arguments and Values:

enum : an enum designator (either an ENUM object or a SYMBOL).
tag : a tag designator (either a TAG object or a SYMBOL) or a FIXNUM.
result : a tag designator or NIL.
"
  (declare (type enum-designator tag)
           (type (or fixnum tag-designator) tag))
  (etypecase e
    (enum
     (let* ((tag (tag-of e tag))
            (ts (enum-tags e))
            (tp (position tag ts :test #'eq))
            )
       (declare (type tag-designator tag)
                (type list ts)
                (type (or null (integer 0)) tp))
       (when (and tp (< -1 tp (1- (enum-length e))))
         (nth (1+ tp) ts))))

    (symbol
     (next-enum-tag (find-enum e t) tag))
    ))


;;;; DEFENUM --
;;;; The main macro.
;;;; The macro expands into:
;;;;
;;;; 1 - a DEFTYPE for the enumeration
;;;; 2 - a DEFSTRUCT for the enumeration structure (*)
;;;; 2.a - a DEFSTRUCT for each tag instance if needed;
;;;;       i.e., when the enumeration has slots.
;;;; 3 - The initialization of the enum structure with:
;;;; 3.a - The (optional) creation of the tags instances
;;;; 3.b - The creation of the 'enum function'.
;;;; 4 - The (optional) creation of the enum slot readers and methods.

(defmacro defenum (name (&rest tags-specs)
                        &optional slots
                        &rest options-and-methods
                        &aux canonicalized-tags-specs
                        )
  "The DEFENUM macro defines an extended enumerated type in the environment.

The extnded enumerated types are called 'enums' and they are akin to
both C/C++ enums and Java (5.0 and later).  The main idea is to provide an
enumerated type with symbolic tags and a number of auxiliary
functionality in order to make this concept available in Common Lisp.

The DEFENUM macro is the entry point in the enum types definition.
The syntax accomodates both the very simple cases and the more
sophisticated ones.

NAME names the enum type and eventually also a
function that will map 'tags' to their 'implementation'. Tags can be
'simple', i.e., symbolic, or 'structured, in which case they are
actually structure objects that are themselves the 'range' of an
implicit 'map' with symbols in the 'domain'.

TAGS-SPECS is a list of tag specifications (tag-spec).  A tag-spec has
the following (Common Lisp) syntax

<pre>
    tag-spec ::= SYMBOL
             |   (SYMBOL)
             |   (SYMBOL N)
             |   (SYMBOL (&rest args) &rest tag-methods)
             |   (SYMBOL N (&rest args) &rest tag-methods)
</pre>

Each SYMBOL is the symbolic tag.  N is an integer constant.  The first
three forms are the 'simple' case, which corresponds to the
traditional C/C++ case.  The other two cases correspond to
the 'structured' case. 'args' is a list of arguments to be be passed
to the structured tag constructor, 'tag-methods' is a list of methods
specs similar to the 'enum methods' specified in OPTIONS-AND-METHODS (see below)
that will be EQL-specialized on the symbolic and associated fixnum
values; these methods' specifications admit a simplified lambda
arguments list; the simplified lambda list has an implicit first
argument that is provided by DEFENUM.

SLOTS is a list of 'slot specifications' like those in DEFSTRUCT;
specifing any slot ensures that the implementation will generate a
number of specialized functions and methods that will be able to deal
with 'structured tags'.  Each slot has a 'slot-name' and is specified as
read-only. Each slot has a reader named NAME-slot-name; all slots are
automatically declared 'read only'.

OPTIONS-AND-METHODS is a list of 'options' and 'enum methods'.  The options
are lists with a keyword in first position.  The only option
recognized at this time is :DOCUMENTATION, with a second argument a
(doc) string, which will be associated to the enum type.  The 'enum
methods' specifications have the following form:

<pre>
    enum-meth-spec ::= (:method M-NAME QUAL* ARGS &BODY M-BODY)
</pre>

M-NAME is the method name, QUAL is a method qualifier (zero or more),
ARGS is a specialized lambda-list, whose first argument is trated
sepcially, and M-BODY is a normal method body.  The first argument of
the lambda list is treated specially if it is specialized on T (cfr.,
not specialized) or it is specialized on the enum type NAME.
References to slot names in M-BODY are substituted with appropriate
calls to the slot reader functions.

Arguments and Values:

NAME : a SYMBOL.
TAG-SPECS : a list of 'enum tags' specifications.
SLOTS : a list of 'slot specifications'.
OPTIONS-AND-METHODS : a list of 'options' and (enum specific) 'methods'. 

Examples:

cl-prompt> (defenum seasons (spring summer autumn winter))
#<ENUM SEASONS (SPRING SUMMER AUTUMN WINTER)>
 
cl-prompt> (seasons 'spring)
SPRING
 
cl-prompt> winter
3
 
cl-prompt> (seasons-p 'winter)
T
 
cl-prompt> (seasons winter) ; No quote.
WINTER
 
cl-prompt> (defenum operation
                    ((PLUS ()   (:method evaluate (x y) (+ x y)))
                     (MINUS ()  (:method evaluate (x y) (- x y)))
                     (TIMES ()  (:method evaluate (x y) (* x y)))
                     (DIVIDE () (:method evaluate (x y) (/ x y)))
                     ))
#<ENUM OPERATION (PLUS MINUS TIMES DIVIDE)>
 
cl-prompt> (typep 'divide 'operation)
T
 
cl-prompt> (evaluate times 2 pi)
6.283185307179586D0
 
cl-prompt> (evaluate 'plus 40 2)
42
 
cl-prompt> (defenum (colors (:initargs (r g b)))
                    ((red (255 0 0))
                     (green (0 255 0))
                     (blue (0 0 255))
                     (white (255 255 255))
                     (black (0 0 0))
                     )
                    ((r 0 :type (integer 0 255) :read-only t)
                     (g 0 :type (integer 0 255) :read-only t)
                     (b 0 :type (integer 0 255) :read-only t)
                     )
                 (:documentation \"The Colors Enum.\"))
#<ENUM COLORS (RED GREEN BLUE WHITE BLACK)>
 
cl-prompt>  (colors-r red)
255
 
cl-prompt> (colors-g white)
255
 
cl-prompt> (documentation 'colors 'type)
\"The Colors Enum.\"
 
cl-prompt> (previous-enum-tag 'colors 'green)
#<COLORS TAG RED>
 
cl-prompt> (previous-enum-tag 'colors *)
NIL


Notes:

The DEFENUM macro is inspired by Java 'enum' classes; it offers
all the facilities of the Java version, while also retaining the C/C++
'enum tags are integers' feature.

The use of the DEFENUM enumeration types has some limitations, due, of
course, to Common Lisp slack typing and a few implementation choices.

The slot name references in the enum and tag methods are done via
SYMBOL-MACROLET.
"

  (when (symbolp name)
    (setf name (list name)))

  (setf tags-specs
        (loop for ts in tags-specs
              if (symbolp ts)
              collect (list ts)
              else
              collect ts))

  (setf canonicalized-tags-specs
        (canonicalize-tags-specs tags-specs))

  (setf slots
        (mapcar (lambda (s)
                  (if (symbolp s)
                      (list s)
                      s))
                slots))

  (when (and slots (member (caar slots) '(:method :documentation) :test #'eq))
    (error "DEFENUM ~S slot specification starts with :METHOD or :DOCUMENTATION.~@
            Maybe an empty slot specification is missing."
           name))

  (destructuring-bind (name &rest name-options)
      name
    (let ((initargs (find :initargs name-options
                          :key #'first
                          :test #'eq))
          (documentation (find :documentation options-and-methods
                               :key #'first
                               :test #'eq))
          (init-code (remove :initialize options-and-methods
                             :key #'first
                             :test (complement #'eq)))
          (methods (remove :method options-and-methods
                           :key #'first
                           :test (complement #'eq)))
          ) ; Just to separate the handling of the surface syntax.

      (let* ((symbolic-tags-p (null slots))
             (tags (mapcar #'first tags-specs))
             (enum-defstruct-name (new-symbol "~A/ENUM" name))
             (enum-defstruct-cons-name (new-symbol "%MAKE-~A" enum-defstruct-name))
             (tag-defstruct-name (and (not symbolic-tags-p)
                                      (new-symbol "~A/INSTANCE" name)))
             (tag-defstruct-cons-name (and (not symbolic-tags-p)
                                           (new-symbol "%MAKE-~A" tag-defstruct-name)))
             )
        `(eval-when (:compile-toplevel :load-toplevel :execute)
           
           ;; 1 - Define the type...

           ,(build-enum-deftype name tags (second documentation))

           ,(build-enum-predicate name)

           ;; 2 - Build the enum DEFSTRUCT...

           ,(build-enum-defstruct name
                                  enum-defstruct-name
                                  enum-defstruct-cons-name)

           ;; 2.a - Build the tag instance DEFSTRUCT.  It returns a list
           ;;       to be spliced in.

           ,@(build-enum-tag-defstruct name
                                       tag-defstruct-name
                                       tag-defstruct-cons-name
                                       symbolic-tags-p
                                       initargs
                                       slots)



           ;; 3/3.a - Build initialization.

           ,@(build-enum-initialization name
                                        symbolic-tags-p
                                        enum-defstruct-cons-name
                                        tag-defstruct-cons-name
                                        canonicalized-tags-specs)

           ;; 3.b - Build the 'enum' function.

           ,(build-enum-function name)

           ;; 4 - Build enum slot-readers and methods.

           ,@(build-enum-tag-slot-readers name
                                          tags
                                          tag-defstruct-name
                                          slots)

           ,@(build-enum-methods name
                                 methods
                                 tag-defstruct-name
                                 tags
                                 canonicalized-tags-specs
                                 slots)

           ,@(nconc (mapcan #'rest init-code))
           
           (find-enum ',name)
           )
        ))))


(defun canonicalize-tags-specs (tags-specs)
  (loop for tag-number from 0
        for (tag . rest-tag) in tags-specs
        for (tag-next . tag-tail) = rest-tag

        if (numberp tag-next) ; N
        collect (apply #'make-tag-spec tag tag-next tag-tail)
        and do (setf tag-number tag-next)
        else if (and (listp tag-next) (eq 'eql (first tag-next))) ; (eql <form>)
        collect (apply #'make-tag-spec tag tag-next tag-tail)
        else
        collect (apply #'make-tag-spec tag tag-number rest-tag)))


(defun build-enum-deftype (name tags documentation)
  (declare (type (or null string) documentation))
  `(deftype ,name ()
     ,(or documentation (format nil "The ~A Enum." name))
     '(member ,.(copy-list tags))))


(defun build-enum-predicate (name)
  (let ((predicate-name (new-symbol "~A-P" name)))
    `(defun ,predicate-name (x)
       (typep x ',name))))


(defun build-enum-defstruct (name
                             enum-defstruct-name
                             enum-defstruct-cons-name)
  `(defstruct
       (,enum-defstruct-name
        (:include enum)
        (:constructor ,enum-defstruct-cons-name (tags
                                                 &aux
                                                 (name ',name)
                                                 (length
                                                  (list-length tags))))
        )))


(defun build-enum-tag-defstruct (enum-name
                                 tag-defstruct-name
                                 tag-defstruct-cons-name
                                 symbolic-tags-p
                                 initargs
                                 slots)
  (unless (or symbolic-tags-p (null slots))
    (let ((struct-def
           `(defstruct (,tag-defstruct-name (:constructor ,tag-defstruct-cons-name
                                             (name ,@(second initargs)
                                                   &aux (enum ',enum-name)))
                                            (:include tag))
              ,@slots
              ))
          )
      (list struct-def))))


(defun build-enum-tag-slot-readers (name
                                    tags
                                    tag-defstruct-name
                                    slots)
  ;; Come back later and optimize.
  ;; In this case it is sufficient to have one method on SYMBOL and
  ;; one on FIXNUM.
  (let ((tag-self-var (gensym "TAG-")))
    (loop for (slot-name . nil) in slots
          for reader = (new-symbol "~A-~A" name slot-name)
          for tag-reader = (new-symbol "~A-~A" tag-defstruct-name slot-name)
          nconc (loop for tag in tags
                      collect `(defmethod ,reader ((,tag-self-var (eql ',tag)))
                                 (,tag-reader (tag-of ',name ',tag))) ; This could be pre-computed.
                      into slot-readers
                      finally (return
                               (nconc slot-readers
                                      `((defmethod ,reader
                                                   ((,tag-self-var fixnum))
                                          (,tag-reader (tag-of ',name ,tag-self-var)))
                                        (defmethod ,reader
                                                   ((,tag-self-var ,tag-defstruct-name))
                                          (,tag-reader ,tag-self-var))
                                        )))
                      ))))


(defun build-enum-initialization (name
                                  symbolic-tags-p
                                  enum-defstruct-cons-name
                                  tag-defstruct-cons-name
                                  tags-specs)
  
  ;; Error checking.
  (loop for (tag) in tags-specs
        for tag-enum = (tag-enum tag nil)
        when (and tag-enum (not (eq (enum-name tag-enum) name)))
        do (error "Tag ~S is part of enum ~S; it cannot be added to enum ~S."
                  tag
                  (enum-name tag-enum)
                  name))

  ;; Building init code.
  (let ((tags-defconstants
         (loop for (tag tag-id) in tags-specs
               unless (keywordp tag)
               if (numberp tag-id)
               collect `(defconstant ,tag ,tag-id)
               else if (and (listp tag-id) (eq 'eql (first tag-id)))
               collect `(defconstant ,tag ,(second tag-id))))
        )
    `((setf (find-enum ',name)
            #| Not evaluated args
            (,enum-defstruct-cons-name
             ,(if symbolic-tags-p
                  `(mapcar #'tag-spec-tag ',tags-specs)
                  `(mapcar (lambda (ts)
                             (apply #',tag-defstruct-cons-name
                                    (tag-spec-tag ts)
                                    (tag-spec-args ts)))
                           ',tags-specs)))
            |#

            #| Evaluated args |#
            (,enum-defstruct-cons-name
             (list
              ,@(if symbolic-tags-p
                    (mapcar (lambda (ts) `',(tag-spec-tag ts)) tags-specs)
                    (mapcar (lambda (ts)
                              `(funcall #',tag-defstruct-cons-name
                                        ',(tag-spec-tag ts)
                                        ,@(tag-spec-args ts)))
                            tags-specs))))
            )
      (let* ((e (find-enum ',name))
             (id-map (enum-id-map e))
             )
        (loop for (tag tag-id) in ',tags-specs do
              (setf (get tag '%%enum%%) e
                    (gethash tag-id id-map) (tag-of e (the symbol tag))))
        )

      ,@tags-defconstants
      )))


(defun build-enum-function (name)
  `(defun ,name (tag-designator)
     (declare (type (or symbol fixnum tag) tag-designator))
     (tag-of ',name tag-designator t)))


(defun build-enum-methods (name
                           methods
                           tag-defstruct-name
                           tag-names
                           tag-specs
                           slots)
  (let* ((slot-names (mapcar (lambda (s)
                               (etypecase s
                                 (symbol s)
                                 (list (first s))))
                             slots))
         (slot-accessors
          (mapcar (lambda (sn)
                    (new-symbol "~A-~A"
                                tag-defstruct-name
                                sn))
                  slot-names))
         (all-methods ())
         (other-methods ())
         (tag-self-var (gensym "TAG-"))
         (tag-methods-table (make-hash-table :test #'eq))
         )

    ;; Build the methods...
    ;; While we go, we need to remember which methods have already
    ;; been specialized on a tag, in order to avoid duplications.


    ;; Build the tag-specified methods...
    ;; These are the methods that are defined as part of a tag.
    (loop for (tag-name tag-id nil tag-spec-methods) in tag-specs
          nconc (loop for (#| :method |# nil method-name quals args body)
                      in (mapcar #'parse-method-spec tag-spec-methods)

                      do (setf (gethash tag-name tag-methods-table) method-name)
                      collect `(defmethod ,method-name ,@quals
                                 ((,tag-self-var (eql ',tag-name)) ,@args)
                                 ,@body)
                      collect `(defmethod ,method-name ,@quals
                                 ((,tag-self-var (eql ,tag-id)) ,@args)
                                 ,@body)
                      )
          into tag-specified-methods
          finally (setf all-methods
                        tag-specified-methods))

    ;; Now build the methods defined in the enum "body"...

    ;; Build the methods specialized on a tag...
    (loop for m in methods
          for (#| :method |# nil m-name quals (first-arg . args) m-body)
          = (parse-method-spec m)
          if (and (consp first-arg)
                  (eq (first first-arg) 'quote)
                  (member (second first-arg) tag-names :test #'eq))
          do (unless quals ; collect only primary methods.
               (setf (gethash (second first-arg) tag-methods-table) m-name))

          and collect `(defmethod ,m-name ,@quals ((,tag-self-var (eql ,first-arg))
                                                   ,@args)
                         ,@(build-enum-method-body name
                                                   tag-self-var
                                                   slot-names
                                                   slot-accessors
                                                   m-body))
          into tag-methods

          and collect (let ((tag-id (second (find (second first-arg)
                                                  tag-specs
                                                  :key #'first)))
                            )
                        `(defmethod ,m-name ,@quals ((,tag-self-var (eql ,tag-id))
                                                     ,@args)
                           ,@(build-enum-method-body name
                                                     tag-self-var
                                                     slot-names
                                                     slot-accessors
                                                     m-body)))
          into tag-methods

          else

          collect m into regular-methods
          finally (setf all-methods
                        (nconc all-methods tag-methods)

                        other-methods
                        regular-methods)
          )

    ;; Build the remaining mehtods...
    (loop for m in (mapcar #'parse-method-spec other-methods)
          collect (build-enum-method name m tag-defstruct-name slot-names slot-accessors)
          into methods-defs

          nconc (build-enum-tag-methods name
                                        m
                                        tag-defstruct-name
                                        tag-names
                                        tag-methods-table)
          into methods-defs

          collect (build-enum-fixnum-method name m)
          into methods-defs

          finally (setf all-methods
                        (nconc all-methods methods-defs))
          )

    all-methods))


(defun build-enum-method-body (name self-variable slot-names slot-accessors m-body)
  (if (and slot-names slot-accessors)
      `((let ((,self-variable (,name ,self-variable)))
         (symbol-macrolet ,(mapcar (lambda (sn sa)
                                     `(,sn (,sa ,self-variable)))
                                   slot-names
                                   slot-accessors)
           ,@m-body)))
      m-body))


(defun build-enum-method-redispatch-body (name method-name tag-self-var args)
  (let ((mll (parse-ll :specialized args)))
    (if (ll-rest-var mll) ; Minimal optimization.
        `(apply (function ,method-name)
                (,name ,tag-self-var)
                ,@(ll-recall mll))
        `(,method-name (,name ,tag-self-var)
                       ,@(rest (butlast (ll-recall mll)))))))


(defun build-enum-method (name m tag-defstruct-name slot-names slot-accessors)
  (destructuring-bind (method-kwd m-name quals args mb)
      m
    (declare (ignore method-kwd))
    (when (and slot-names slot-accessors)
      (let ((self-variable (first args))
            )
        (cond ((eq self-variable name)
               `(defmethod ,m-name ,@quals
                  ((,self-variable ,tag-defstruct-name) ,@(rest args))
                  (symbol-macrolet ,(mapcar (lambda (sn sa)
                                              `(,sn (,sa ,self-variable)))
                                            slot-names
                                            slot-accessors)
                    ,@mb)))
              ((and (listp self-variable)
                    (eq (second self-variable) name))
               `(defmethod ,m-name ,@quals
                  ((,(first self-variable) ,tag-defstruct-name) ,@(rest args))
                  (symbol-macrolet ,(mapcar (lambda (sn sa)
                                              `(,sn (,sa ,(first self-variable))))
                                            slot-names
                                            slot-accessors)
                    ,@mb))
               )
              (t
               `(defmethod ,m-name ,@quals ,args ,@mb))))
      )))


(defun build-enum-tag-methods (name m tag-defstruct-name tags-names tags-methods-table)
  (loop with m-name = (method-spec-name m)
        for tag in tags-names
        for tag-meths = (gethash tag tags-methods-table)
        unless (find m-name tag-meths :test #'eq)
        collect (build-enum-tag-method name m tag-defstruct-name tag)))


(defun build-enum-tag-method (name m tag-defstruct-name tag)
  (declare (ignore tag-defstruct-name)) ; FTTB.
  (destructuring-bind (method-kwd m-name quals args mb)
      m
    (declare (ignore method-kwd mb))
    `(defmethod ,m-name ,@quals ((,name (eql ',tag)) ,@(rest args))
       ,(build-enum-method-redispatch-body name m-name name args)
       )))


(defun build-enum-fixnum-method (name m)
  (destructuring-bind (method-kwd m-name quals args mb)
      m
    (declare (ignore method-kwd mb))
    `(defmethod ,m-name ,@quals ((,name fixnum) ,@(rest args))
       ,(build-enum-method-redispatch-body name m-name name args)
       )))


;;;;===========================================================================
;;;; Utilities.
;;;; Scrap utilities to avoid dependencies...

(defun new-symbol (template &rest args)
  (declare (type string template))
  (intern (apply #'format nil template args) *package*))


;;;;===========================================================================
;;;; Testing


;;;; end of file -- defenum.lisp --
