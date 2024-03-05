;;;; package.lisp

(defpackage cotd/scenario
  (:use #:cl)
  (:export #:create-scenario-generator #:get-available-and-current-mission #:get-available-and-current-sector
           #:get-available-and-current-month #:get-available-and-current-feats #:get-available-and-current-factions 
           #:get-available-and-current-specific-faction))
