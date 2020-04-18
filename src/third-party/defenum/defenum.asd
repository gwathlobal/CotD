;;;; -*- Mode: Lisp -*-

;;;; defenum.asd --
;;;;
;;;; See the file COPYING for copyright and licensing information.

(asdf:defsystem "defenum"
  :author "Marco Antoniotti"
  :license "BSD"
  :description "The DEFENUM facility provides C++ and Java styled 'enum' in Common Lisp."
  :components ((:file "defenum-package")
               (:file "lambda-list-parsing"
                :depends-on ("defenum-package"))
               (:file "defenum"
                :depends-on ("defenum-package"
                             "lambda-list-parsing"))
               #+cl-enumerations
               (:file "enum-enumeration"
                :depends-on ("defenum"))
               )
  )

;;;; end of file -- defenum.asd --
