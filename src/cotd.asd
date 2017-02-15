;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(defpackage cotd  
  (:use :common-lisp :asdf)
  (:export :cotd-main
           :make-exec))  
 
(in-package :cotd)  

(defsystem cotd  
  :name "The City of the Damned"
  :description "A roguelike battle of Angels and Demons in the streets of a Human city."  
  :version "1.0.5"  
  :author "Gwathlobal"    
  :depends-on (lispbuilder-sdl bordeaux-threads)
  :components
    ((:file "logger")
     (:file "astar")
     (:file "message-box")
     (:file "globals")
     (:file "options")
     (:file "game-events")
     (:file "world" :depends-on ("globals"))
     (:file "mobs" :depends-on ("globals"))
     (:file "abilities" :depends-on ("globals"))
     (:file "terrain" :depends-on ("globals"))
     (:file "lvl-features" :depends-on ("globals"))
     (:file "los-fov" :depends-on ("globals" "world" "mobs"))
     (:file "base-methods" :depends-on ("message-box" "mobs" "world" "abilities" "terrain" "lvl-features" "los-fov"))
     (:file "buildings" :depends-on ("globals"))
     (:file "init-building-types" :depends-on ("buildings"))
     (:file "level-city" :depends-on ("init-building-types"))
     (:file "level-test" :depends-on ("base-methods"))
     (:file "scenarios" :depends-on ("buildings"))
     (:file "init-scenario-types" :depends-on ("scenarios"))
     (:file "dungeon-creation" :depends-on ("level-test" "level-city" "init-scenario-types"))
     (:file "init-mob-types" :depends-on ("base-methods"))
     (:file "init-ability-types" :depends-on ("base-methods"))
     (:file "init-feature-types" :depends-on ("base-methods"))
     (:file "init-terrain-types" :depends-on ("base-methods"))
     (:file "window-classes")
     (:file "window-methods" :depends-on ("window-classes" "base-methods"))
     (:file "window-start-game" :depends-on ("window-methods"))
     (:file "window-messages" :depends-on ("window-methods"))
     (:file "window-level" :depends-on ("window-methods"))
     (:file "window-map-select" :depends-on ("window-level"))
     (:file "window-loading" :depends-on ("window-methods"))
     (:file "window-character" :depends-on ("window-methods"))
     (:file "window-select-obj" :depends-on ("window-methods"))
     (:file "window-game-over" :depends-on ("window-methods"))
     (:file "window-help" :depends-on ("window-methods"))
     (:file "window-custom-scenario" :depends-on ("window-methods"))
     (:file "ai" :depends-on ("base-methods" "window-methods"))
     (:file "init-game-events" :depends-on ("game-events" "window-methods"))
     (:file "cotd")
     ))
