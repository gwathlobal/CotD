;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(defpackage cotd  
  (:use :common-lisp :asdf)
  (:export :cotd-main
           :make-exec))  
 
(in-package :cotd)  

(defsystem cotd  
  :name "The City of the Damned"
  :description "A cold-themed roguelike."  
  :version "0.1"  
  :author "Gwathlobal"    
  :depends-on (lispbuilder-sdl)
  :components
    ((:file "astar")
     (:file "message-box")
     (:file "globals")
     (:file "world" :depends-on ("globals"))
     (:file "mobs" :depends-on ("globals"))
     (:file "abilities" :depends-on ("globals"))
     (:file "terrain" :depends-on ("globals"))
     (:file "lvl-features" :depends-on ("globals"))
     (:file "base-methods" :depends-on ("astar" "message-box" "mobs" "world" "abilities" "terrain" "lvl-features"))
     (:file "level-city" :depends-on ("base-methods"))
     (:file "level-test" :depends-on ("base-methods"))
     (:file "dungeon-creation" :depends-on ("level-test" "level-city"))
     (:file "init-mob-types" :depends-on ("base-methods"))
     (:file "init-ability-types" :depends-on ("base-methods"))
     (:file "init-feature-types" :depends-on ("base-methods"))
     (:file "init-terrain-types" :depends-on ("base-methods"))
     (:file "window-classes")
     (:file "window-methods" :depends-on ("window-classes" "base-methods"))
     (:file "window-start-game" :depends-on ("window-methods"))
     (:file "window-level" :depends-on ("window-methods"))
     (:file "window-map-select" :depends-on ("window-level"))
     (:file "window-loading" :depends-on ("window-methods"))
     (:file "window-character" :depends-on ("window-methods"))
     (:file "window-select-obj" :depends-on ("window-methods"))
     (:file "window-game-over" :depends-on ("window-methods"))
     (:file "window-help" :depends-on ("window-methods"))
     (:file "ai" :depends-on ("base-methods" "window-methods"))
     (:file "win-condition" :depends-on ("base-methods" "window-methods")) 
     (:file "cotd")
     ))
