(in-package :cl-user)

(defpackage :cotd-render
  (:use)
  (:import-from #:sdl
   ;; window/video setup and the main event loop
   #:with-init #:init-video #:window #:enable-key-repeat #:enable-unicode
   #:update-display #:with-events

   ;; surfaces and images
   #:load-image #:create-surface #:create-path #:fill-surface
   #:draw-surface-at-* #:set-cell-*

   ;; geometry
   #:rectangle #:rectangle-from-edges-* #:with-rectangle #:draw-rectangle #:draw-pixel-*
   #:x #:y #:width #:height

   ;; text and fonts
   #:draw-string-solid-* #:char-height #:char-width #:get-font-height
   #:initialise-default-font
   #:*default-font* #:*font-6x13* #:*font-8x13* #:*font-6x13o* #:*font-8x13o*

   ;; colours
   #:color #:*default-surface*
   #:*white* #:*black* #:*red* #:*yellow* #:*magenta* #:*green* #:*cyan* #:*blue*)
  (:export
   #:with-init #:init-video #:window #:enable-key-repeat #:enable-unicode
   #:update-display #:with-events
   #:load-image #:create-surface #:create-path #:fill-surface
   #:draw-surface-at-* #:set-cell-*
   #:rectangle #:rectangle-from-edges-* #:with-rectangle #:draw-rectangle #:draw-pixel-*
   #:x #:y #:width #:height
   #:draw-string-solid-* #:char-height #:char-width #:get-font-height
   #:initialise-default-font
   #:*default-font* #:*font-6x13* #:*font-8x13* #:*font-6x13o* #:*font-8x13o*
   #:color #:*default-surface*
   #:*white* #:*black* #:*red* #:*yellow* #:*magenta* #:*green* #:*cyan* #:*blue*))

;;;; The render backend boundary.
;;;;
;;;; Every call CotD makes into lispbuilder-sdl for actual rendering (window
;;;; setup, the event loop, surfaces/images, geometry, text, colours) goes
;;;; through this package instead of the sdl: package directly. Today these
;;;; are the exact same symbols, imported from :sdl, so this file is a
;;;; verified no-op - see headless-test.lisp. Swapping lispbuilder-sdl for
;;;; cl-sdl2 (TODO.txt) means reimplementing the exports above against
;;;; cl-sdl2 in this one file; no call site elsewhere needs to change, the
;;;; same way src/key-bindings.lisp already isolated key constants.
