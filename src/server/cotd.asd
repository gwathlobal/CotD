;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(defpackage cotd  
  (:use :common-lisp :asdf)

  (:export #:cotd-main #:make-exec #:start-server #:stop-server))
 
(in-package :cotd)  

(defsystem cotd  
  :name "The City of the Damned"
  :description "A roguelike battle of Angels and Demons in the streets of a Human city."  
  :version "1.0.5"  
  :author "Gwathlobal"    
  :depends-on (lispbuilder-sdl bordeaux-threads defenum cl-store log4cl portal yason)
  :components
  ((:module "websocket"
    :components ((:file "package")
                 (:file "rwlock")
                 (:file "server")))
   (:file "astar")
   (:file "glyph-globals")
   (:file "globals")
   (:file "world-globals")
   (:file "colored-text")
   (:file "message-box")
   (:file "options")
   (:file "game-events/game-events")
   (:file "file-storage")
   (:file "world" :depends-on ("globals"))
   (:file "save-load-game" :depends-on ("world"))
   (:file "factions" :depends-on ("globals"))
   (:file "mobs" :depends-on ("globals"))
   (:file "abilities" :depends-on ("globals"))
   (:file "effects" :depends-on ("globals"))
   (:file "terrain" :depends-on ("globals"))
   (:file "lvl-features" :depends-on ("globals"))
   (:file "items" :depends-on ("globals"))
   (:file "cards" :depends-on ("globals"))
   (:file "gods" :depends-on ("globals"))
   (:file "los-fov" :depends-on ("globals" "world" "mobs"))
   (:file "hearing" :depends-on ("los-fov"))
   (:file "animations" :depends-on ("globals"))
   (:file "base-methods" :depends-on ("message-box" "mobs" "world" "abilities" "terrain" "animations" "lvl-features" 
                                      "los-fov"))
   (:file "character-dump" :depends-on ("base-methods"))
   (:module "buildings" :depends-on ("globals")
    :components ((:file "buildings")
                 (:file "init-common-building-types" :depends-on ("buildings"))
                 (:file "init-normal-building-types" :depends-on ("buildings"))
                 (:file "init-ruined-building-types" :depends-on ("buildings"))
                 (:file "init-corrupted-building-types" :depends-on ("buildings"))
                 (:file "init-hell-building-types" :depends-on ("buildings"))))
   (:file "level-city" :depends-on ("buildings"))
   (:file "level-test" :depends-on ("base-methods"))
   (:module "level-modifiers"
    :components ((:file "level-modifier")
                 (:file "init-lvl-mod-controlled-by" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-sector-feat" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-sector-item" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-time-of-day" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-weather" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-player-placement" :depends-on ("level-modifier"))
                 (:file "init-lvl-mod-misc" :depends-on ("level-modifier"))))
   (:file "mission-type")
   (:file "highscores")
   (:file "mission")
   (:file "world-sector")
   (:file "world-map")
   (:file "win-condition")
   (:file "generate-level")
   (:file "random-scenario")
   (:file "campaign-effects")
   (:file "campaign-command")
   (:file "init-win-conditions" :depends-on ("win-condition"))
   (:file "init-world-sectors" :depends-on ("world-map"))
   (:file "init-faction-types" :depends-on ("base-methods"))
   (:file "init-mob-types" :depends-on ("base-methods"))
   (:file "init-feature-types" :depends-on ("base-methods"))
   (:file "init-terrain-types" :depends-on ("base-methods"))
   (:file "init-item-types" :depends-on ("base-methods"))
   (:file "init-card-types" :depends-on ("base-methods"))
   (:file "init-gods" :depends-on ("base-methods"))
   (:file "init-mission-types" :depends-on ("mission-type"))
   (:file "init-campaign-effect-types" :depends-on ("campaign-effects"))
   (:file "init-campaign-commands" :depends-on ("campaign-command"))
   (:file "game-state")
   (:module "windows" :depends-on ("base-methods")
    :components ((:file "window-classes")
                 (:file "window-methods" :depends-on ("window-classes"))
                 (:file "window-display-msg" :depends-on ("window-classes"))
                 (:file "window-main-menu" :depends-on ("window-methods"))
                 (:file "window-select-faction" :depends-on ("window-methods"))
                 (:file "window-messages" :depends-on ("window-methods"))
                 (:file "window-level" :depends-on ("window-methods"))
                 (:file "window-map-select" :depends-on ("window-level"))
                 (:file "window-loading" :depends-on ("window-methods"))
                 (:file "window-character" :depends-on ("window-methods"))
                 (:file "window-select-obj" :depends-on ("window-methods"))
                 (:file "window-game-over" :depends-on ("window-methods"))
                 (:file "window-help" :depends-on ("window-methods"))
                 (:file "window-custom-scenario" :depends-on ("window-methods"))
                 (:file "window-inventory" :depends-on ("window-methods"))
                 (:file "window-input-str" :depends-on ("window-methods"))
                 (:file "window-highscores" :depends-on ("window-methods"))
                 (:file "window-settings" :depends-on ("window-methods"))
                 (:file "window-journal" :depends-on ("window-methods"))
                 (:file "window-campaign" :depends-on ("window-methods"))
                 (:file "window-load-game" :depends-on ("window-methods"))
                 (:file "window-campaign-over" :depends-on ("window-methods"))))
   (:module "ai" :depends-on ("base-methods" "windows")
    :components ((:file "ai-common")
                 (:file "ai-packages" :depends-on ("ai-common"))
                 (:file "ai-npc" :depends-on ("ai-common"))
                 (:file "ai-player" :depends-on ("ai-common"))
                 (:file "init-ai-packages" :depends-on ("ai-packages"))))
   (:file "game-events/init-game-events-common" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-demonic-attack" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-demonic-raid" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-demonic-steal" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-demonic-conquest" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-military-conquest" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-military-raid" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-angelic-steal" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-eliminate-satanists" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-angelic-sabotage" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-military-sabotage" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-campaign-win" :depends-on ("game-events/game-events" "windows"))
   (:file "game-events/init-game-events-campaign" :depends-on ("game-events/game-events" "windows"))
   (:file "init-animation-types" :depends-on ("animations" "windows"))
   (:file "init-ability-types" :depends-on ("base-methods" "windows"))
   (:file "init-effect-types" :depends-on ("base-methods" "windows"))
   (:file "game-loop-state")
   (:file "cotd-server" :depends-on ("websocket"))
   (:file "cotd")
   ))
