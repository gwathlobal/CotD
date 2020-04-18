;;;; -*- Mode: Lisp -*-

;;;; defenum-package.lisp --
;;;; Enum Types for Common Lisp.
;;;;
;;;; See file COPYING for copyright and licensing information.

(defpackage "IT.UNIMIB.DISCO.MA.COMMON-LISP.EXTENSIONS.DATA-AND-CONTROL-FLOW.DEFENUM"
  (:use "CL")

  (:documentation "The package containing the DEFENUM reference implementation.")

  (:nicknames "DEFENUM"
   "COMMON-LISP.EXTENSIONS.DEFENUM"
   "CL.EXT.DEFENUM"
   "ENUM-TYPES")
  
  (:export "ENUM"
   "ENUM-NAME"
   "FIND-ENUM")

  (:export "TAG-P"
   "TAG-NAME")

  (:export "TAGS"
   "ENUM-VALUES"
   "TAG-OF"
   "NTH-ENUM-TAG"
   "PREVIOUS-ENUM-TAG"
   "NEXT-ENUM-TAG"
   )

  (:export "DEFENUM")
  )

;;;; end of file -- defenum-package.lisp --
