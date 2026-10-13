;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(in-package :cotd)

;;; Every window checks :key-down-event data through KEY= and the modifier
;;; predicates below instead of using SDL key constants directly. This is the
;;; single choke point for physical keys: the values are SDL2 keycodes (the
;;; key's unshifted symbol in the current layout, as SDL 1.2's keysyms were),
;;; and the modifier masks are SDL2's KMOD bits, which have the same values as
;;; SDL 1.2's. Remapping a key for a player means overriding one entry in
;;; *KEY-BINDINGS*.

(defparameter *key-bindings*
  `((:key-2 . ,sdl2-ffi:+sdlk-2+)
    (:key-7 . ,sdl2-ffi:+sdlk-7+)
    (:key-a . ,sdl2-ffi:+sdlk-a+)
    (:key-b . ,sdl2-ffi:+sdlk-b+)
    (:key-backspace . ,sdl2-ffi:+sdlk-backspace+)
    (:key-c . ,sdl2-ffi:+sdlk-c+)
    (:key-comma . ,sdl2-ffi:+sdlk-comma+)
    (:key-d . ,sdl2-ffi:+sdlk-d+)
    (:key-down . ,sdl2-ffi:+sdlk-down+)
    (:key-e . ,sdl2-ffi:+sdlk-e+)
    (:key-end . ,sdl2-ffi:+sdlk-end+)
    (:key-escape . ,sdl2-ffi:+sdlk-escape+)
    (:key-f . ,sdl2-ffi:+sdlk-f+)
    (:key-g . ,sdl2-ffi:+sdlk-g+)
    (:key-h . ,sdl2-ffi:+sdlk-h+)
    (:key-home . ,sdl2-ffi:+sdlk-home+)
    (:key-i . ,sdl2-ffi:+sdlk-i+)
    (:key-j . ,sdl2-ffi:+sdlk-j+)
    (:key-k . ,sdl2-ffi:+sdlk-k+)
    (:key-kp1 . ,sdl2-ffi:+sdlk-kp-1+)
    (:key-kp2 . ,sdl2-ffi:+sdlk-kp-2+)
    (:key-kp3 . ,sdl2-ffi:+sdlk-kp-3+)
    (:key-kp4 . ,sdl2-ffi:+sdlk-kp-4+)
    (:key-kp5 . ,sdl2-ffi:+sdlk-kp-5+)
    (:key-kp6 . ,sdl2-ffi:+sdlk-kp-6+)
    (:key-kp7 . ,sdl2-ffi:+sdlk-kp-7+)
    (:key-kp8 . ,sdl2-ffi:+sdlk-kp-8+)
    (:key-kp9 . ,sdl2-ffi:+sdlk-kp-9+)
    (:key-kp-enter . ,sdl2-ffi:+sdlk-kp-enter+)
    (:key-l . ,sdl2-ffi:+sdlk-l+)
    (:key-left . ,sdl2-ffi:+sdlk-left+)
    (:key-m . ,sdl2-ffi:+sdlk-m+)
    (:key-n . ,sdl2-ffi:+sdlk-n+)
    (:key-o . ,sdl2-ffi:+sdlk-o+)
    (:key-p . ,sdl2-ffi:+sdlk-p+)
    (:key-pagedown . ,sdl2-ffi:+sdlk-pagedown+)
    (:key-pageup . ,sdl2-ffi:+sdlk-pageup+)
    (:key-period . ,sdl2-ffi:+sdlk-period+)
    (:key-q . ,sdl2-ffi:+sdlk-q+)
    (:key-question . ,sdl2-ffi:+sdlk-question+)
    (:key-r . ,sdl2-ffi:+sdlk-r+)
    (:key-return . ,sdl2-ffi:+sdlk-return+)
    (:key-right . ,sdl2-ffi:+sdlk-right+)
    (:key-s . ,sdl2-ffi:+sdlk-s+)
    (:key-slash . ,sdl2-ffi:+sdlk-slash+)
    (:key-space . ,sdl2-ffi:+sdlk-space+)
    (:key-t . ,sdl2-ffi:+sdlk-t+)
    (:key-tab . ,sdl2-ffi:+sdlk-tab+)
    (:key-u . ,sdl2-ffi:+sdlk-u+)
    (:key-up . ,sdl2-ffi:+sdlk-up+)
    (:key-v . ,sdl2-ffi:+sdlk-v+)
    (:key-w . ,sdl2-ffi:+sdlk-w+)
    (:key-x . ,sdl2-ffi:+sdlk-x+)
    (:key-y . ,sdl2-ffi:+sdlk-y+)
    (:key-z . ,sdl2-ffi:+sdlk-z+))
  "Maps our own key identifiers to SDL2 keycodes.")

(defun key= (key our-key)
  "True if KEY (from a :key-down-event) is the physical key bound to OUR-KEY in *KEY-BINDINGS*."
  (let ((binding (assoc our-key *key-bindings*)))
    (unless binding
      (error "No key binding registered for ~A" our-key))
    (eql key (cdr binding))))

(defun normalize-key-mod (mod)
  "Normalizes a raw SDL key modifier bitmask the way every window's key-down handler used to do inline."
  (loop while (>= mod sdl2-ffi:+kmod-num+) do (decf mod sdl2-ffi:+kmod-num+))
  mod)

(defun key-mod-shift-p (mod)
  (/= (logand mod sdl2-ffi:+kmod-shift+) 0))

(defun key-mod-ctrl-p (mod)
  (/= (logand mod sdl2-ffi:+kmod-ctrl+) 0))

(defun key-mod-none-p (mod)
  (= mod 0))

(defun key-mod-bits (&key shift ctrl)
  "A raw modifier bitmask with SHIFT and/or CTRL held, as a :key-down-event's
MOD would carry it - the inverse of KEY-MOD-SHIFT-P/KEY-MOD-CTRL-P. Only the
headless event check needs to build one."
  (logior (if shift sdl2-ffi:+kmod-lshift+ 0)
          (if ctrl sdl2-ffi:+kmod-lctrl+ 0)))
