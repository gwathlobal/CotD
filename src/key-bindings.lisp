;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-

(in-package :cotd)

;;; Every window checks :key-down-event data through KEY= and the modifier
;;; predicates below instead of using SDL key constants directly. This is the
;;; single choke point for physical keys: the values are SDL2 keycodes (the
;;; key's unshifted symbol in the current layout) and the modifier masks are
;;; SDL2's KMOD bits. Remapping a key for a player means overriding one entry
;;; in *KEY-BINDINGS*.
;;;
;;; The numbers are SDL2's own, from SDL_keycode.h and SDL_scancode.h, and are
;;; ABI: they are what libSDL2 puts in an event, whatever it was built from.
;;; Spelling them out here is what keeps the game buildable without SDL2
;;; installed - render.lisp resolves the library's functions by name at the
;;; call, and these were the only values that used to need it at compile time.
;;; RUN-HEADLESS-EVENT-CHECK drives the whole table through the event loop.

(defconstant +sdlk-scancode-mask+ #x40000000
  "SDLK_SCANCODE_MASK: set in the keycode of a key that types no character,
over the key's scancode.")

(defparameter *key-bindings*
  ;; A key that types a character has that character's code for a keycode; the
  ;; four below type none but are ASCII control codes all the same; the rest
  ;; are a scancode with +SDLK-SCANCODE-MASK+ set, named in the comment.
  `((:key-2 . ,(char-code #\2))
    (:key-7 . ,(char-code #\7))
    (:key-a . ,(char-code #\a))
    (:key-b . ,(char-code #\b))
    (:key-backspace . 8)                                   ; SDLK_BACKSPACE
    (:key-c . ,(char-code #\c))
    (:key-comma . ,(char-code #\,))
    (:key-d . ,(char-code #\d))
    (:key-down . ,(logior +sdlk-scancode-mask+ 81))        ; SDL_SCANCODE_DOWN
    (:key-e . ,(char-code #\e))
    (:key-end . ,(logior +sdlk-scancode-mask+ 77))         ; SDL_SCANCODE_END
    (:key-escape . 27)                                     ; SDLK_ESCAPE
    (:key-f . ,(char-code #\f))
    (:key-g . ,(char-code #\g))
    (:key-h . ,(char-code #\h))
    (:key-home . ,(logior +sdlk-scancode-mask+ 74))        ; SDL_SCANCODE_HOME
    (:key-i . ,(char-code #\i))
    (:key-j . ,(char-code #\j))
    (:key-k . ,(char-code #\k))
    (:key-kp1 . ,(logior +sdlk-scancode-mask+ 89))         ; SDL_SCANCODE_KP_1
    (:key-kp2 . ,(logior +sdlk-scancode-mask+ 90))         ; SDL_SCANCODE_KP_2
    (:key-kp3 . ,(logior +sdlk-scancode-mask+ 91))         ; SDL_SCANCODE_KP_3
    (:key-kp4 . ,(logior +sdlk-scancode-mask+ 92))         ; SDL_SCANCODE_KP_4
    (:key-kp5 . ,(logior +sdlk-scancode-mask+ 93))         ; SDL_SCANCODE_KP_5
    (:key-kp6 . ,(logior +sdlk-scancode-mask+ 94))         ; SDL_SCANCODE_KP_6
    (:key-kp7 . ,(logior +sdlk-scancode-mask+ 95))         ; SDL_SCANCODE_KP_7
    (:key-kp8 . ,(logior +sdlk-scancode-mask+ 96))         ; SDL_SCANCODE_KP_8
    (:key-kp9 . ,(logior +sdlk-scancode-mask+ 97))         ; SDL_SCANCODE_KP_9
    (:key-kp-enter . ,(logior +sdlk-scancode-mask+ 88))    ; SDL_SCANCODE_KP_ENTER
    (:key-l . ,(char-code #\l))
    (:key-left . ,(logior +sdlk-scancode-mask+ 80))        ; SDL_SCANCODE_LEFT
    (:key-m . ,(char-code #\m))
    (:key-n . ,(char-code #\n))
    (:key-o . ,(char-code #\o))
    (:key-p . ,(char-code #\p))
    (:key-pagedown . ,(logior +sdlk-scancode-mask+ 78))    ; SDL_SCANCODE_PAGEDOWN
    (:key-pageup . ,(logior +sdlk-scancode-mask+ 75))      ; SDL_SCANCODE_PAGEUP
    (:key-period . ,(char-code #\.))
    (:key-q . ,(char-code #\q))
    (:key-question . ,(char-code #\?))
    (:key-r . ,(char-code #\r))
    (:key-return . 13)                                     ; SDLK_RETURN
    (:key-right . ,(logior +sdlk-scancode-mask+ 79))       ; SDL_SCANCODE_RIGHT
    (:key-s . ,(char-code #\s))
    (:key-slash . ,(char-code #\/))
    (:key-space . ,(char-code #\Space))
    (:key-t . ,(char-code #\t))
    (:key-tab . 9)                                         ; SDLK_TAB
    (:key-u . ,(char-code #\u))
    (:key-up . ,(logior +sdlk-scancode-mask+ 82))          ; SDL_SCANCODE_UP
    (:key-v . ,(char-code #\v))
    (:key-w . ,(char-code #\w))
    (:key-x . ,(char-code #\x))
    (:key-y . ,(char-code #\y))
    (:key-z . ,(char-code #\z)))
  "Maps our own key identifiers to SDL2 keycodes.")

;;; KMOD bits, from SDL_keycode.h. KMOD_SHIFT and KMOD_CTRL are the left and
;;; right bits of the one modifier together, which is why the predicates below
;;; test with LOGAND rather than EQL.

(defconstant +kmod-lshift+ #x0001)
(defconstant +kmod-rshift+ #x0002)
(defconstant +kmod-lctrl+ #x0040)
(defconstant +kmod-rctrl+ #x0080)
(defconstant +kmod-num+ #x1000)
(defconstant +kmod-shift+ (logior +kmod-lshift+ +kmod-rshift+))
(defconstant +kmod-ctrl+ (logior +kmod-lctrl+ +kmod-rctrl+))

(defun key= (key our-key)
  "True if KEY (from a :key-down-event) is the physical key bound to OUR-KEY in *KEY-BINDINGS*."
  (let ((binding (assoc our-key *key-bindings*)))
    (unless binding
      (error "No key binding registered for ~A" our-key))
    (eql key (cdr binding))))

(defun normalize-key-mod (mod)
  "Normalizes a raw SDL key modifier bitmask the way every window's key-down handler used to do inline."
  (loop while (>= mod +kmod-num+) do (decf mod +kmod-num+))
  mod)

(defun key-mod-shift-p (mod)
  (/= (logand mod +kmod-shift+) 0))

(defun key-mod-ctrl-p (mod)
  (/= (logand mod +kmod-ctrl+) 0))

(defun key-mod-none-p (mod)
  (= mod 0))

(defun key-mod-bits (&key shift ctrl)
  "A raw modifier bitmask with SHIFT and/or CTRL held, as a :key-down-event's
MOD would carry it - the inverse of KEY-MOD-SHIFT-P/KEY-MOD-CTRL-P. Only the
headless event check needs to build one."
  (logior (if shift +kmod-lshift+ 0)
          (if ctrl +kmod-lctrl+ 0)))
