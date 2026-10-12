;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(in-package :cotd)

;;; Every window checks :key-down-event data through KEY= and the modifier
;;; predicates below instead of calling SDL:KEY= / SDL-CFFI:: constants
;;; directly. This is the single choke point for physical keys: swapping
;;; lispbuilder-sdl for cl-sdl2 means updating *KEY-BINDINGS*'s values and
;;; these few functions, not every window file; remapping a key for a player
;;; means overriding one entry in *KEY-BINDINGS*.

(defparameter *key-bindings*
  '((:key-2 . :sdl-key-2)
    (:key-7 . :sdl-key-7)
    (:key-a . :sdl-key-a)
    (:key-b . :sdl-key-b)
    (:key-backspace . :sdl-key-backspace)
    (:key-c . :sdl-key-c)
    (:key-comma . :sdl-key-comma)
    (:key-d . :sdl-key-d)
    (:key-down . :sdl-key-down)
    (:key-e . :sdl-key-e)
    (:key-end . :sdl-key-end)
    (:key-escape . :sdl-key-escape)
    (:key-f . :sdl-key-f)
    (:key-g . :sdl-key-g)
    (:key-h . :sdl-key-h)
    (:key-home . :sdl-key-home)
    (:key-i . :sdl-key-i)
    (:key-j . :sdl-key-j)
    (:key-k . :sdl-key-k)
    (:key-kp1 . :sdl-key-kp1)
    (:key-kp2 . :sdl-key-kp2)
    (:key-kp3 . :sdl-key-kp3)
    (:key-kp4 . :sdl-key-kp4)
    (:key-kp5 . :sdl-key-kp5)
    (:key-kp6 . :sdl-key-kp6)
    (:key-kp7 . :sdl-key-kp7)
    (:key-kp8 . :sdl-key-kp8)
    (:key-kp9 . :sdl-key-kp9)
    (:key-kp-enter . :sdl-key-kp-enter)
    (:key-l . :sdl-key-l)
    (:key-left . :sdl-key-left)
    (:key-m . :sdl-key-m)
    (:key-n . :sdl-key-n)
    (:key-o . :sdl-key-o)
    (:key-p . :sdl-key-p)
    (:key-pagedown . :sdl-key-pagedown)
    (:key-pageup . :sdl-key-pageup)
    (:key-period . :sdl-key-period)
    (:key-q . :sdl-key-q)
    (:key-question . :sdl-key-question)
    (:key-r . :sdl-key-r)
    (:key-return . :sdl-key-return)
    (:key-right . :sdl-key-right)
    (:key-s . :sdl-key-s)
    (:key-slash . :sdl-key-slash)
    (:key-space . :sdl-key-space)
    (:key-t . :sdl-key-t)
    (:key-tab . :sdl-key-tab)
    (:key-u . :sdl-key-u)
    (:key-up . :sdl-key-up)
    (:key-v . :sdl-key-v)
    (:key-w . :sdl-key-w)
    (:key-x . :sdl-key-x)
    (:key-y . :sdl-key-y)
    (:key-z . :sdl-key-z))
  "Maps our own key identifiers to the underlying lispbuilder-sdl key constants.")

(defconstant +sdl-key-mod-num+ (cffi:foreign-enum-value 'sdl-cffi::Sdl-Mod :SDL-KEY-MOD-NUM))

(defun key= (key our-key)
  "True if KEY (from a :key-down-event) is the physical key bound to OUR-KEY in *KEY-BINDINGS*."
  (let ((binding (assoc our-key *key-bindings*)))
    (unless binding
      (error "No key binding registered for ~A" our-key))
    (sdl:key= key (cdr binding))))

(defun normalize-key-mod (mod)
  "Normalizes a raw SDL key modifier bitmask the way every window's key-down handler used to do inline."
  (loop while (>= mod +sdl-key-mod-num+) do (decf mod +sdl-key-mod-num+))
  mod)

(defun key-mod-shift-p (mod)
  (/= (logand mod sdl-cffi::sdl-key-mod-shift) 0))

(defun key-mod-ctrl-p (mod)
  (/= (logand mod sdl-cffi::sdl-key-mod-ctrl) 0))

(defun key-mod-none-p (mod)
  (= mod 0))
