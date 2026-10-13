(in-package :cl-user)

(defpackage :cotd-render
  (:use :cl)
  (:export
   #:with-init #:init-video #:window #:enable-key-repeat #:enable-unicode
   #:update-display #:with-events #:delay
   #:push-key-down-event #:push-expose-event #:push-quit-event
   #:load-image #:create-surface #:create-path #:fill-surface #:blit
   #:rectangle #:rectangle-from-edges-* #:with-rectangle #:draw-rectangle #:draw-pixel-*
   #:x #:y #:width #:height
   #:draw-string-solid-* #:char-height #:char-width #:get-font-height
   #:initialise-default-font #:*font-directory*
   #:*default-font* #:*font-6x13* #:*font-8x13* #:*font-6x13o* #:*font-8x13o*
   #:color #:*default-surface*
   #:*white* #:*black* #:*red* #:*yellow* #:*magenta* #:*green* #:*cyan* #:*blue*
   #:surface-rgb-bytes #:window-surface #:renderer-name))

;;;; The render backend boundary.
;;;;
;;;; Every call CotD makes into SDL - window setup, the event loop,
;;;; surfaces/images, geometry, text, colours - goes through this package, and
;;;; this file is the only one that talks to SDL itself (key-bindings.lisp
;;;; holds the matching key constants). The backend is SDL2 with software
;;;; rendering: everything is drawn into SDL surfaces, the window's own
;;;; surface among them, and UPDATE-DISPLAY presents it. libSDL2 is loaded by
;;;; cl-sdl2 (the SDL2 system's SDL2::LIBSDL2); the calls below go through
;;;; CFFI directly with raw pointers rather than through cl-sdl2's wrappers,
;;;; because DRAW-GLYPH alone makes thousands of them per frame and because
;;;; cl-sdl2's WITH-INIT runs its body on a thread of its own, which would lose
;;;; the caller's dynamic bindings.
;;;;
;;;; Contract that is not visible from the symbol list:
;;;;  - *DEFAULT-SURFACE* is NIL during normal play, and a NIL surface (the
;;;;    default of every :SURFACE keyword) means "draw to the window". Call
;;;;    sites pass :SURFACE COTD-RENDER:*DEFAULT-SURFACE* explicitly and rely
;;;;    on that NIL; only the headless oracles bind it to an offscreen surface.
;;;;  - Colours are packed #xRRGGBB integers.
;;;;
;;;; Checks: COMPARE-GOLDEN-SCREENS (whole screens) and RUN-HEADLESS-EVENT-CHECK
;;;; (the event loop) in headless-test.lisp. Both run on SDL's dummy video
;;;; driver; tools/smoke-test runs the real game on a real X display, which
;;;; is the only way to see the window system's side of this file.

(in-package :cotd-render)

;;; ---------------------------------------------------------------------
;;; SDL2 declarations. Values and layouts are SDL 2.0's; the struct layouts
;;; below give the leading fields only, as far as this file reads them.
;;; ---------------------------------------------------------------------

(defconstant +sdl-init-video+ #x20)
(defconstant +sdl-quit+ #x100)
(defconstant +sdl-windowevent+ #x200)
(defconstant +sdl-keydown+ #x300)
(defconstant +sdl-textinput+ #x303)
(defconstant +sdl-windowevent-exposed+ 3)
(defconstant +sdl-peekevent+ 1)
(defconstant +sdl-getevent+ 2)
(defconstant +sdl-firstevent+ 0)
(defconstant +sdl-lastevent+ #xFFFF)
(defconstant +sdl-pixelformat-rgb888+ #x16161804)
(defconstant +sdl-windowpos-centered+ #x2FFF0000)
(defconstant +sdl-window-shown+ 4)
(defconstant +sdl-textureaccess-streaming+ 1)
(defconstant +sdl-pressed+ 1)
(defconstant +sdl-event-size+ 56)

(cffi:defcstruct sdl-surface
  (flags :uint32)
  (format :pointer)
  (w :int)
  (h :int)
  (pitch :int)
  (pixels :pointer))

(cffi:defcstruct sdl-pixel-format
  (format :uint32)
  (palette :pointer)
  (bits-per-pixel :uint8)
  (bytes-per-pixel :uint8))

(cffi:defcstruct sdl-keyboard-event
  (type :uint32)
  (timestamp :uint32)
  (window-id :uint32)
  (state :uint8)
  (repeat :uint8)
  (padding2 :uint8)
  (padding3 :uint8)
  ;; SDL_Keysym, inline
  (scancode :int32)
  (sym :int32)
  (mod :uint16))

(cffi:defcstruct sdl-text-input-event
  (type :uint32)
  (timestamp :uint32)
  (window-id :uint32)
  (text :char :count 32))

(cffi:defcstruct sdl-window-event
  (type :uint32)
  (timestamp :uint32)
  (window-id :uint32)
  (event :uint8))

;; the pointer-free layouts are the same on every platform SDL2 supports
(assert (= 20 (cffi:foreign-slot-offset '(:struct sdl-keyboard-event) 'sym)))
(assert (= 24 (cffi:foreign-slot-offset '(:struct sdl-keyboard-event) 'mod)))
(assert (= 12 (cffi:foreign-slot-offset '(:struct sdl-text-input-event) 'text)))
(assert (= 12 (cffi:foreign-slot-offset '(:struct sdl-window-event) 'event)))

(defmacro without-fp-traps (&body body)
  "Run BODY with floating point traps masked (the mask set is cl-sdl2's)."
  #+sbcl
  `(sb-int:with-float-traps-masked (:underflow :overflow :inexact :invalid :divide-by-zero)
     ,@body)
  #-sbcl
  `(progn ,@body))

;;; Every call into SDL in this file goes through SDL-CALL - never CFFI's
;;; FOREIGN-FUNCALL directly (the check at the end of this file enforces it).
;;;
;;; Why: SBCL runs with floating point traps enabled, so a NaN or an infinity
;;; signals an error instead of quietly propagating. C code is written for the
;;; opposite, and SDL's video drivers (X11 at least) produce such values in
;;; passing - with traps on, SDL_Init on a real display signals
;;; FLOATING-POINT-INVALID-OPERATION. So SDL-CALL masks the traps for the
;;; duration of the call, by default for every SDL function. The few that
;;; never reach a video driver and are called per glyph or per pixel are
;;; listed in *TRAP-SAFE-SDL-FUNCTIONS* and skip the masking, for speed.
;;; Forgetting to list a function only costs a little time; it can't crash.
;;; CotD's own code is never masked, so its float errors still signal.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *trap-safe-sdl-functions*
    '("SDL_UpperBlit" "SDL_FillRect" "SDL_MapRGB" "SDL_GetRGB")
    "SDL functions SDL-CALL calls without masking floating point traps. Only
pure software surface operations, which never touch the window system, may
be listed - and only hot ones, since the masking is what keeps the rest safe."))

(defmacro sdl-call (name &rest args)
  "Call the SDL2 C function NAME (a literal string) with ARGS as for
CFFI:FOREIGN-FUNCALL: argument type/value pairs, then the return type. Floating
point traps are masked during the call unless NAME is one of
*TRAP-SAFE-SDL-FUNCTIONS*."
  (check-type name string)
  (if (member name *trap-safe-sdl-functions* :test #'string=)
      `(cffi:foreign-funcall ,name ,@args)
      `(without-fp-traps (cffi:foreign-funcall ,name ,@args))))

(defun sdl-error ()
  (sdl-call "SDL_GetError" :string))

;;; ---------------------------------------------------------------------
;;; Session state: SDL init/quit, and the foreign scratch buffers the hot
;;; paths reuse. The buffers are allocated per session rather than at load
;;; time, so none of them is a stale pointer inside a saved executable image.
;;; ---------------------------------------------------------------------

(defvar *sdl-active* nil
  "True inside the outermost WITH-INIT. A nested WITH-INIT (COTD-EXEC wraps
COTD-MAIN, which has its own) reuses that session: SDL_Quit is not
reference-counted, so only the outermost one may call it.")

(defvar *window* nil "The SDL_Window pointer, once WINDOW has run.")
(defvar *renderer* nil "The window's SDL_Renderer pointer, once WINDOW has run.")
(defvar *texture* nil "The streaming SDL_Texture UPDATE-DISPLAY uploads to.")
(defvar *window-surface* nil "The window's SURFACE, once WINDOW has run.")

(defvar *src-rect* nil)
(defvar *dst-rect* nil)
(defvar *event* nil "Buffer NEXT-EVENT polls into.")
(defvar *peek-event* nil "Buffer NEXT-EVENT peeks at the following event with.")

(defmacro with-init ((&rest flags) &body body)
  "Run BODY with SDL's video subsystem initialized, and shut SDL down after."
  (when flags
    (error "COTD-RENDER:WITH-INIT takes no flags, got ~S" flags))
  `(call-with-init (lambda () ,@body)))

(defun call-with-init (fn)
  (if *sdl-active*
      (funcall fn)
      (progn
        (unless (zerop (sdl-call "SDL_Init" :uint32 +sdl-init-video+ :int))
          (error "COTD-RENDER: SDL_Init failed: ~A" (sdl-error)))
        (let ((*sdl-active* t))
          (unwind-protect
               (progn
                 (setf *src-rect* (cffi:foreign-alloc :int :count 4)
                       *dst-rect* (cffi:foreign-alloc :int :count 4)
                       *event* (cffi:foreign-alloc :uint8 :count +sdl-event-size+)
                       *peek-event* (cffi:foreign-alloc :uint8 :count +sdl-event-size+))
                 (reset-font-surfaces)
                 (reset-frame-limiter)
                 (funcall fn))
            (destroy-window)
            (dolist (buffer (list *src-rect* *dst-rect* *event* *peek-event*))
              (when buffer
                (cffi:foreign-free buffer)))
            (setf *src-rect* nil *dst-rect* nil *event* nil *peek-event* nil)
            (sdl-call "SDL_Quit" :void))))))

(defun init-video ()
  (unless (zerop (sdl-call "SDL_InitSubSystem" :uint32 +sdl-init-video+ :int))
    (error "COTD-RENDER: SDL_InitSubSystem failed: ~A" (sdl-error))))

;;; ---------------------------------------------------------------------
;;; Surfaces and rectangles.
;;; ---------------------------------------------------------------------

(defstruct (surface (:constructor %make-surface (ptr w h)))
  (ptr nil :read-only t)
  (w 0 :type fixnum :read-only t)
  (h 0 :type fixnum :read-only t))

(defun wrap-surface (ptr what)
  "A SURFACE for the SDL_Surface pointer PTR that WHAT returned; signals SDL's
error if PTR is null."
  (when (cffi:null-pointer-p ptr)
    (error "COTD-RENDER: ~A failed: ~A" what (sdl-error)))
  (%make-surface ptr
                 (cffi:foreign-slot-value ptr '(:struct sdl-surface) 'w)
                 (cffi:foreign-slot-value ptr '(:struct sdl-surface) 'h)))

(defun surface-format (surface)
  (cffi:foreign-slot-value (surface-ptr surface) '(:struct sdl-surface) 'format))

(defun free-surface (surface)
  (sdl-call "SDL_FreeSurface" :pointer (surface-ptr surface) :void))

(defvar *default-surface* nil
  "The surface drawing goes to by default; NIL means the window.")

(defun window-surface ()
  "The window's own surface: what is on screen after UPDATE-DISPLAY."
  *window-surface*)

(defun target-surface (surface)
  "SURFACE, or the window when it is NIL (see the contract above)."
  (or surface *window-surface*))

(defstruct (rect (:constructor rectangle (&key (x 0) (y 0) (w 0) (h 0))))
  (x 0 :type fixnum)
  (y 0 :type fixnum)
  (w 0 :type fixnum)
  (h 0 :type fixnum))

(defmacro with-rectangle ((var &optional (form '(rectangle))) &body body)
  `(let ((,var ,form))
     ,@body))

(defun rectangle-from-edges-* (x1 y1 x2 y2)
  "The rectangle with corners X1 Y1 and X2 Y2, both inclusive."
  (rectangle :x x1 :y y1 :w (1+ (abs (- x2 x1))) :h (1+ (abs (- y2 y1)))))

(declaim (inline x y (setf x) (setf y) width height (setf width) (setf height)))
(defun x (rect) (rect-x rect))
(defun y (rect) (rect-y rect))
(defun (setf x) (value rect) (setf (rect-x rect) value))
(defun (setf y) (value rect) (setf (rect-y rect) value))
(defun width (thing)
  "Width of a rectangle or a surface."
  (etypecase thing
    (rect (rect-w thing))
    (surface (surface-w thing))))
(defun height (thing)
  "Height of a rectangle or a surface."
  (etypecase thing
    (rect (rect-h thing))
    (surface (surface-h thing))))
(defun (setf width) (value rect) (setf (rect-w rect) value))
(defun (setf height) (value rect) (setf (rect-h rect) value))

(declaim (inline set-foreign-rect))
(defun set-foreign-rect (ptr x y w h)
  (setf (cffi:mem-aref ptr :int 0) x
        (cffi:mem-aref ptr :int 1) y
        (cffi:mem-aref ptr :int 2) w
        (cffi:mem-aref ptr :int 3) h)
  ptr)

;;; ---------------------------------------------------------------------
;;; Colours.
;;; ---------------------------------------------------------------------

(declaim (inline color))
(defun color (&key (r 0) (g 0) (b 0))
  "The packed #xRRGGBB colour with these components."
  (declare (type (unsigned-byte 8) r g b))
  (logior (ash r 16) (ash g 8) b))

(defparameter *black* #x000000)
(defparameter *white* #xFFFFFF)
(defparameter *red* #xFF0000)
(defparameter *green* #x00FF00)
(defparameter *blue* #x0000FF)
(defparameter *yellow* #xFFFF00)
(defparameter *cyan* #x00FFFF)
(defparameter *magenta* #xFF00FF)

(defun map-color (surface packed)
  "PACKED as a pixel value in SURFACE's pixel format."
  (declare (type (unsigned-byte 24) packed))
  (sdl-call "SDL_MapRGB" :pointer (surface-format surface)
            :uint8 (ldb (byte 8 16) packed) :uint8 (ldb (byte 8 8) packed) :uint8 (ldb (byte 8 0) packed)
            :uint32))

(defun set-color-key (surface packed)
  (sdl-call "SDL_SetColorKey" :pointer (surface-ptr surface) :int 1 :uint32 (map-color surface packed) :int))

;;; ---------------------------------------------------------------------
;;; Drawing.
;;; ---------------------------------------------------------------------

(defun fill-xywh (surface x y w h color)
  (sdl-call "SDL_FillRect" :pointer (surface-ptr surface)
            :pointer (set-foreign-rect *dst-rect* x y w h)
            :uint32 (map-color surface color) :int))

(defun fill-surface (color &key template (surface *default-surface*))
  "Fill SURFACE (NIL = the window), or the TEMPLATE rectangle of it, with COLOR."
  (let ((surface (target-surface surface)))
    (if template
        (fill-xywh surface (rect-x template) (rect-y template) (rect-w template) (rect-h template) color)
        (sdl-call "SDL_FillRect" :pointer (surface-ptr surface) :pointer (cffi:null-pointer)
                  :uint32 (map-color surface color) :int))))

(defun draw-rectangle (rect &key (color *white*) (surface *default-surface*))
  "The 1-pixel outline of RECT, its right and bottom edges at x+w-1 / y+h-1."
  (let ((surface (target-surface surface))
        (x (rect-x rect)) (y (rect-y rect)) (w (rect-w rect)) (h (rect-h rect)))
    (fill-xywh surface x y w 1 color)
    (fill-xywh surface x (+ y h -1) w 1 color)
    (fill-xywh surface x y 1 h color)
    (fill-xywh surface (+ x w -1) y 1 h color)))

(defun draw-pixel-* (x y &key (color *white*) (surface *default-surface*))
  (fill-xywh (target-surface surface) x y 1 1 color))

(defun blit (src x y &key (surface *default-surface*)
                          (src-x 0) (src-y 0) (src-w (surface-w src)) (src-h (surface-h src)))
  "Copy the SRC-W x SRC-H area at SRC-X SRC-Y of SRC (by default, all of it)
to X Y on SURFACE (NIL = the window). SRC's colour key, if any, applies."
  (sdl-call "SDL_UpperBlit"
            :pointer (surface-ptr src) :pointer (set-foreign-rect *src-rect* src-x src-y src-w src-h)
            :pointer (surface-ptr (target-surface surface)) :pointer (set-foreign-rect *dst-rect* x y 0 0)
            :int))

(defun create-surface (w h &key color-key)
  "A new W x H surface, all black, in the window's 32-bit RGB format.
With COLOR-KEY, pixels of that colour are transparent when it is blitted."
  (let ((surface (wrap-surface (sdl-call "SDL_CreateRGBSurfaceWithFormat"
                                         :uint32 0 :int w :int h :int 32
                                         :uint32 +sdl-pixelformat-rgb888+ :pointer)
                               "SDL_CreateRGBSurfaceWithFormat")))
    (when color-key
      (set-color-key surface color-key))
    surface))

(defun create-path (filename directory)
  (merge-pathnames filename directory))

(defun load-image (path &key color-key)
  "The BMP file PATH as a surface (converted to the 32-bit RGB format all
surfaces here use). With COLOR-KEY, pixels of that colour are transparent."
  (let ((rw (sdl-call "SDL_RWFromFile" :string (uiop:native-namestring path) :string "rb" :pointer)))
    (when (cffi:null-pointer-p rw)
      (error "COTD-RENDER: cannot open ~A: ~A" path (sdl-error)))
    ;; the 1 makes SDL_LoadBMP_RW close RW itself
    (let ((loaded (wrap-surface (sdl-call "SDL_LoadBMP_RW" :pointer rw :int 1 :pointer)
                                (format nil "loading ~A" path))))
      (unwind-protect
           (let ((surface (wrap-surface (sdl-call "SDL_ConvertSurfaceFormat"
                                                  :pointer (surface-ptr loaded)
                                                  :uint32 +sdl-pixelformat-rgb888+ :uint32 0 :pointer)
                                        "SDL_ConvertSurfaceFormat")))
             (when color-key
               (set-color-key surface color-key))
             surface)
        (free-surface loaded)))))

(defmacro with-locked-pixels ((pixels pitch surface) &body body)
  "Run BODY with PIXELS bound to SURFACE's pixel memory and PITCH to its row
length in bytes. Surfaces here are 32 bits per pixel."
  (let ((s (gensym "SURFACE-")))
    `(let ((,s ,surface))
       (assert (= 4 (cffi:foreign-slot-value (surface-format ,s) '(:struct sdl-pixel-format) 'bytes-per-pixel)))
       (sdl-call "SDL_LockSurface" :pointer (surface-ptr ,s) :int)
       (unwind-protect
            (let ((,pixels (cffi:foreign-slot-value (surface-ptr ,s) '(:struct sdl-surface) 'pixels))
                  (,pitch (cffi:foreign-slot-value (surface-ptr ,s) '(:struct sdl-surface) 'pitch)))
              ,@body)
         (sdl-call "SDL_UnlockSurface" :pointer (surface-ptr ,s) :void)))))

(defun surface-rgb-bytes (surface)
  "SURFACE's pixels as a fresh (UNSIGNED-BYTE 8) vector, 3 bytes (R G B) per
pixel, row-major, plus its width and height as the second and third values.
Decoding goes through SDL_GetRGB with the surface's own pixel format, so the
result does not depend on which pixel format the backend picked."
  (let* ((w (surface-w surface))
         (h (surface-h surface))
         (bytes (make-array (* w h 3) :element-type '(unsigned-byte 8)))
         (format (surface-format surface)))
    (cffi:with-foreign-objects ((r :uint8) (g :uint8) (b :uint8))
      (with-locked-pixels (pixels pitch surface)
        (dotimes (y h)
          (dotimes (x w)
            (let ((i (* 3 (+ x (* y w)))))
              (sdl-call "SDL_GetRGB" :uint32 (cffi:mem-ref pixels :uint32 (+ (* y pitch) (* 4 x)))
                        :pointer format :pointer r :pointer g :pointer b :void)
              (setf (aref bytes i) (cffi:mem-ref r :uint8)
                    (aref bytes (+ i 1)) (cffi:mem-ref g :uint8)
                    (aref bytes (+ i 2)) (cffi:mem-ref b :uint8)))))))
    (values bytes w h)))

;;; ---------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------

;;; Drawing is all software, into *WINDOW-SURFACE* - an ordinary surface of
;;; our own, not the one SDL_GetWindowSurface would give. UPDATE-DISPLAY
;;; uploads it to a streaming texture and presents that through an
;;; SDL_Renderer, which on a real display is OpenGL or Direct3D. Presenting
;;; the window surface directly would go through X11 or GDI instead, and the
;;; Steam overlay, which hooks the GPU APIs' present, would never be drawn.
;;; SDL falls back to its software renderer where there is no GPU API (the
;;; dummy driver the headless checks use).

(defun destroy-window ()
  "Destroy the window and everything WINDOW made for it, if there is one."
  (when *texture*
    (sdl-call "SDL_DestroyTexture" :pointer *texture* :void))
  (when *renderer*
    (sdl-call "SDL_DestroyRenderer" :pointer *renderer* :void))
  (when *window*
    (sdl-call "SDL_DestroyWindow" :pointer *window* :void))
  (when *window-surface*
    (free-surface *window-surface*))
  (setf *texture* nil *renderer* nil *window* nil *window-surface* nil))

(defun created (ptr what)
  "PTR, which WHAT returned; signals SDL's error if it is null."
  (when (cffi:null-pointer-p ptr)
    (error "COTD-RENDER: ~A failed: ~A" what (sdl-error)))
  ptr)

(defun window (w h &key (title-caption "") icon-caption)
  "Open the W x H game window (replacing any earlier one) and return its surface."
  (declare (ignore icon-caption))
  (destroy-window)
  (setf *window* (created (sdl-call "SDL_CreateWindow" :string title-caption
                                    :int +sdl-windowpos-centered+ :int +sdl-windowpos-centered+
                                    :int w :int h :uint32 +sdl-window-shown+ :pointer)
                          "SDL_CreateWindow")
        *renderer* (created (sdl-call "SDL_CreateRenderer" :pointer *window* :int -1 :uint32 0 :pointer)
                            "SDL_CreateRenderer")
        *texture* (created (sdl-call "SDL_CreateTexture" :pointer *renderer*
                                     :uint32 +sdl-pixelformat-rgb888+
                                     :int +sdl-textureaccess-streaming+ :int w :int h :pointer)
                           "SDL_CreateTexture")
        *window-surface* (create-surface w h)))

(defun renderer-name ()
  "The name of the SDL renderer presenting the window (\"opengl\", \"direct3d\",
\"software\"...), or NIL before WINDOW. Only a GPU one shows the Steam overlay."
  (when *renderer*
    ;; SDL_RendererInfo starts with its const char *name
    (cffi:with-foreign-object (info :uint8 128)
      (unless (zerop (sdl-call "SDL_GetRendererInfo" :pointer *renderer* :pointer info :int))
        (error "COTD-RENDER: SDL_GetRendererInfo failed: ~A" (sdl-error)))
      (cffi:foreign-string-to-lisp (cffi:mem-ref info :pointer)))))

(defun update-display ()
  "Show what has been drawn to the window's surface."
  (when *window*
    (let ((ptr (surface-ptr *window-surface*)))
      (sdl-call "SDL_UpdateTexture" :pointer *texture* :pointer (cffi:null-pointer)
                :pointer (cffi:foreign-slot-value ptr '(:struct sdl-surface) 'pixels)
                :int (cffi:foreign-slot-value ptr '(:struct sdl-surface) 'pitch) :int)
      (sdl-call "SDL_RenderCopy" :pointer *renderer* :pointer *texture*
                :pointer (cffi:null-pointer) :pointer (cffi:null-pointer) :int)
      (sdl-call "SDL_RenderPresent" :pointer *renderer* :void))))

(defun enable-key-repeat (&rest args)
  "No-op: SDL2 always delivers key repeats, at the OS's rate."
  (declare (ignore args))
  nil)

(defun enable-unicode ()
  "Turn on SDL2's text input, which supplies the UNICODE of key-down events."
  (sdl-call "SDL_StartTextInput" :void))

;;; ---------------------------------------------------------------------
;;; Bitmap fonts.
;;;
;;; Four fixed-size fonts - 6x13 and 8x13, and their oblique variants 6x13o
;;; and 8x13o - each a file in data/fonts/: one row of 256 glyphs, glyph N
;;; (char-code N) at x = N * char-width, white where the glyph has a pixel and
;;; black elsewhere.
;;;
;;; Drawing text writes the text colour on the glyph's pixels and leaves every
;;; other pixel alone. For that,
;;; each (font, colour) pair gets a strip of all 256 glyphs already in that
;;; colour, on a colour-keyed background, built once from the glyph bits; a
;;; character is then one blit out of the strip.
;;; ---------------------------------------------------------------------

(defvar *font-directory* nil
  "Directory holding the font BMP files. Set by the game before any text is
drawn (INIT-GLYPH-FRONT does it, from *ASSET-DIR*).")

(defstruct (bitmap-font (:constructor make-bitmap-font (file char-width char-height)))
  (file "" :type string)
  (char-width 0 :type fixnum)
  (char-height 0 :type fixnum)
  ;; glyph pixels of the whole strip, row-major, 1 = glyph. Read once from
  ;; FILE; plain lisp data, so it outlives SDL sessions.
  (bits nil :type (or null simple-bit-vector))
  ;; packed text colour -> tinted strip surface. Surfaces die with the SDL
  ;; session, so WITH-INIT clears these.
  (strips (make-hash-table) :type hash-table))

(defvar *font-6x13* (make-bitmap-font "font-6x13.bmp" 6 13))
(defvar *font-8x13* (make-bitmap-font "font-8x13.bmp" 8 13))
(defvar *font-6x13o* (make-bitmap-font "font-6x13o.bmp" 6 13))
(defvar *font-8x13o* (make-bitmap-font "font-8x13o.bmp" 8 13))

(defvar *default-font* nil
  "The font text is drawn in unless a call says otherwise. Set with
INITIALISE-DEFAULT-FONT.")

(defun all-fonts ()
  (list *font-6x13* *font-8x13* *font-6x13o* *font-8x13o*))

(defun reset-font-surfaces ()
  "Drop every tinted strip. Called on each new SDL session, since surfaces from
a previous session are no longer valid."
  (dolist (font (all-fonts))
    (clrhash (bitmap-font-strips font))))

(defun char-width (font) (bitmap-font-char-width font))
(defun char-height (font) (bitmap-font-char-height font))

(defun get-font-height (&key (font *default-font*))
  (char-height font))

(defun initialise-default-font (font)
  "Make FONT the default font. Returns FONT."
  (setf *default-font* font))

(defun font-bits (font)
  "FONT's glyph bits, reading its BMP file the first time."
  (or (bitmap-font-bits font)
      (setf (bitmap-font-bits font)
            (progn
              (unless *font-directory*
                (error "COTD-RENDER: *FONT-DIRECTORY* is not set, cannot load ~A" (bitmap-font-file font)))
              (let ((image (load-image (merge-pathnames (bitmap-font-file font) *font-directory*))))
                (unwind-protect
                     (multiple-value-bind (bytes w h) (surface-rgb-bytes image)
                       (unless (and (= w (* 256 (char-width font))) (= h (char-height font)))
                         (error "COTD-RENDER: ~A is ~Ax~A, expected ~Ax~A"
                                (bitmap-font-file font) w h (* 256 (char-width font)) (char-height font)))
                       (let ((bits (make-array (* w h) :element-type 'bit)))
                         (dotimes (i (* w h) bits)
                           (setf (sbit bits i) (if (plusp (aref bytes (* 3 i))) 1 0)))))
                  (free-surface image)))))))

(defun font-strip (font packed-color)
  "All 256 glyphs of FONT in PACKED-COLOR on a colour-keyed background,
built the first time this colour is asked for."
  (or (gethash packed-color (bitmap-font-strips font))
      (setf (gethash packed-color (bitmap-font-strips font))
            (let* ((bits (font-bits font))
                   (w (* 256 (char-width font)))
                   (h (char-height font))
                   ;; any colour but the text colour will do as the key
                   (key (if (= packed-color 0) #xFFFFFF 0))
                   (strip (create-surface w h :color-key key)))
              (fill-surface key :surface strip)
              (let ((fg (map-color strip packed-color)))
                (with-locked-pixels (pixels pitch strip)
                  (dotimes (y h)
                    (dotimes (x w)
                      (when (= 1 (sbit bits (+ x (* y w))))
                        (setf (cffi:mem-ref pixels :uint32 (+ (* y pitch) (* 4 x))) fg))))))
              strip))))

(defun draw-string-solid-* (string x y &key (justify :left) (surface *default-surface*)
                                           (font *default-font*) (color *white*))
  "Draw STRING with its top-left at X Y (:LEFT), its top-right at X Y (:RIGHT)
or centred on X (:CENTER), in FONT and COLOR, onto SURFACE (NIL = the window).
Only the glyph pixels are written."
  (let* ((surface (target-surface surface))
         (w (char-width font))
         (h (char-height font))
         (strip (font-strip font color))
         (start-x (ecase justify
                    (:left x)
                    (:right (- x (* w (length string))))
                    (:center (- x (/ (* w (length string)) 2))))))
    (loop for c across string
          for cx from start-x by w
          for code = (char-code c)
          do (unless (< code 256)
               (error "COTD-RENDER: ~S has no glyph in the bitmap fonts" c))
             (blit strip cx y :surface surface :src-x (* code w) :src-w w :src-h h))
    surface))

;;; ---------------------------------------------------------------------
;;; Events and the frame loop.
;;;
;;; WITH-EVENTS is the event loop of every window. Its clauses:
;;;
;;;   (:quit-event () body)            - body's value T ends the loop
;;;   (:key-down-event (:key k :mod m :unicode u) body)  - any subset of keys
;;;   (:video-expose-event () body)
;;;   (:idle () body)                  - once per frame, after the queue is empty
;;;
;;; In :POLL mode every pending event is dispatched (even
;;; ones still queued behind a quit), then, unless quitting, the :IDLE forms
;;; run and the loop sleeps to hold *FRAME-RATE*. :WAIT blocks for each event
;;; and has no idle step. KEY is an SDL2 keycode (*KEY-BINDINGS* in
;;; key-bindings.lisp names them), MOD the modifier bitmask, UNICODE the code
;;; of the character the key typed, 0 if none.
;;;
;;; SDL2 sends that character as a separate SDL_TEXTINPUT event right behind
;;; the SDL_KEYDOWN. NEXT-EVENT pairs
;;; the two back up. Text input that arrives with no key event in front of it
;;; (an input method composing a character, say) becomes a key-down event of
;;; its own with KEY 0, which matches no binding, so it only ever reaches
;;; code that reads UNICODE. Keys that type no printable character (Enter,
;;; Escape, Ctrl+letter) get UNICODE 0.
;;; ---------------------------------------------------------------------

(defvar *event-key* 0)
(defvar *event-mod* 0)
(defvar *event-unicode* 0)

(defun event-type (buffer)
  (cffi:mem-ref buffer :uint32 0))

(defun text-input-code (buffer)
  "Code of the first character of a SDL_TEXTINPUT event's UTF-8 text, or 0."
  (let* ((pointer (cffi:foreign-slot-pointer buffer '(:struct sdl-text-input-event) 'text))
         ;; the text is NUL-terminated inside a 32-byte array; what follows the
         ;; NUL is leftover bytes, not text (FOREIGN-STRING-TO-LISP with :COUNT
         ;; would decode those too)
         (length (or (loop for i below 32
                           when (zerop (cffi:mem-aref pointer :uint8 i)) return i)
                     32))
         (text (cffi:foreign-string-to-lisp pointer :count length :encoding :utf-8)))
    (if (plusp (length text))
        (char-code (char text 0))
        0)))

(defun take-following-text-input ()
  "If the next queued event is a SDL_TEXTINPUT, remove it and return its
character code; otherwise 0."
  (if (and (= 1 (sdl-call "SDL_PeepEvents" :pointer *peek-event* :int 1 :int +sdl-peekevent+
                          :uint32 +sdl-firstevent+ :uint32 +sdl-lastevent+ :int))
           (= +sdl-textinput+ (event-type *peek-event*)))
      (progn
        (sdl-call "SDL_PeepEvents" :pointer *peek-event* :int 1 :int +sdl-getevent+
                  :uint32 +sdl-textinput+ :uint32 +sdl-textinput+ :int)
        (text-input-code *peek-event*))
      0))

(defun next-event (wait)
  "Take the next event and return its type, one of :QUIT, :KEY-DOWN, :EXPOSE
or :OTHER; for :KEY-DOWN, EVENT-KEY/EVENT-MOD/EVENT-UNICODE then hold its
fields. Returns NIL when no event is pending (WAIT false) or on an error
(WAIT true, which otherwise blocks until one arrives)."
  (if (zerop (if wait
                 (sdl-call "SDL_WaitEvent" :pointer *event* :int)
                 (sdl-call "SDL_PollEvent" :pointer *event* :int)))
      nil
      (let ((type (event-type *event*)))
        (cond
          ((= type +sdl-quit+) :quit)
          ((= type +sdl-keydown+)
           (setf *event-key* (cffi:foreign-slot-value *event* '(:struct sdl-keyboard-event) 'sym)
                 *event-mod* (cffi:foreign-slot-value *event* '(:struct sdl-keyboard-event) 'mod)
                 *event-unicode* (take-following-text-input))
           :key-down)
          ((= type +sdl-textinput+)
           (setf *event-key* 0
                 *event-mod* (sdl-call "SDL_GetModState" :int)
                 *event-unicode* (text-input-code *event*))
           :key-down)
          ((and (= type +sdl-windowevent+)
                (= +sdl-windowevent-exposed+ (cffi:foreign-slot-value *event* '(:struct sdl-window-event) 'event)))
           :expose)
          (t :other)))))

(defun event-key () *event-key*)
(defun event-mod () *event-mod*)
(defun event-unicode () *event-unicode*)

(defun push-event (fill-fn)
  "Queue an event, after FILL-FN has filled in a zeroed event buffer."
  (cffi:with-foreign-object (event :uint8 +sdl-event-size+)
    (dotimes (i +sdl-event-size+)
      (setf (cffi:mem-aref event :uint8 i) 0))
    (funcall fill-fn event)
    (when (minusp (sdl-call "SDL_PushEvent" :pointer event :int))
      (error "COTD-RENDER: SDL_PushEvent failed: ~A" (sdl-error)))))

(defun push-quit-event ()
  (push-event (lambda (event) (setf (cffi:mem-ref event :uint32 0) +sdl-quit+))))

(defun push-expose-event ()
  (push-event (lambda (event)
                (setf (cffi:foreign-slot-value event '(:struct sdl-window-event) 'type) +sdl-windowevent+
                      (cffi:foreign-slot-value event '(:struct sdl-window-event) 'event) +sdl-windowevent-exposed+))))

(defun push-key-down-event (key &key (mod 0) (unicode 0))
  "Queue a press of KEY (an SDL2 keycode, as in *KEY-BINDINGS*) with modifier
bitmask MOD, followed - as SDL2 itself does it - by a text input event for
character code UNICODE unless that is 0. For tests: the headless event check
drives WITH-EVENTS with these."
  (push-event (lambda (event)
                (setf (cffi:foreign-slot-value event '(:struct sdl-keyboard-event) 'type) +sdl-keydown+
                      (cffi:foreign-slot-value event '(:struct sdl-keyboard-event) 'state) +sdl-pressed+
                      (cffi:foreign-slot-value event '(:struct sdl-keyboard-event) 'sym) key
                      (cffi:foreign-slot-value event '(:struct sdl-keyboard-event) 'mod) mod)))
  (when (plusp unicode)
    (push-event (lambda (event)
                  (setf (cffi:foreign-slot-value event '(:struct sdl-text-input-event) 'type) +sdl-textinput+)
                  ;; real text events carry leftover bytes after the text's
                  ;; NUL; so do these, so the reading side has to stop at it
                  (let ((text (cffi:foreign-slot-pointer event '(:struct sdl-text-input-event) 'text)))
                    (dotimes (i 32)
                      (setf (cffi:mem-aref text :uint8 i) #xFF)))
                  (cffi:lisp-string-to-foreign (string (code-char unicode))
                                               (cffi:foreign-slot-pointer event '(:struct sdl-text-input-event) 'text)
                                               32 :encoding :utf-8)))))

(defun ticks ()
  (sdl-call "SDL_GetTicks" :uint32))

(defun delay (ms)
  "Sleep for MS milliseconds."
  (sdl-call "SDL_Delay" :uint32 ms :void))

(defparameter *frame-rate* 30
  "Frames per second WITH-EVENTS holds its :POLL loop to.")

(defvar *frame-count* 0)
(defvar *frame-base-ticks* nil)

(defun reset-frame-limiter ()
  (setf *frame-count* 0
        *frame-base-ticks* nil))

(defun run-frame (idle-fn)
  "Run IDLE-FN, then sleep for whatever is left of this frame. The schedule is
SDL_gfx's: frame N is due at base + N * 1000/rate ms;
a frame that is already late restarts the schedule from now instead of
trying to catch up."
  (let ((now (ticks)))
    (funcall idle-fn)
    (if (null *frame-base-ticks*)
        (setf *frame-count* 0
              *frame-base-ticks* now)
        (let ((delta (- (+ *frame-base-ticks* (* (incf *frame-count*) (truncate 1000 *frame-rate*)))
                        now)))
          (if (> delta 0)
              (delay (min delta 500))
              (setf *frame-count* 0
                    *frame-base-ticks* now))))))

(defun key-down-bindings (params)
  (loop for (key var) on params by #'cddr
        collect (list var (ecase key
                            (:key '(event-key))
                            (:mod '(event-mod))
                            (:unicode '(event-unicode))))))

(defmacro with-events ((&optional (type :poll)) &body clauses)
  (check-type type (member :poll :wait))
  (let ((quit (gensym "QUIT-"))
        (event-type (gensym "EVENT-TYPE-"))
        (idle ())
        (cases ()))
    (dolist (clause clauses)
      (destructuring-bind (kind params &rest body) clause
        (unless (or (eq kind :key-down-event) (null params))
          (error "WITH-EVENTS: ~S takes no parameters, got ~S" kind params))
        (ecase kind
          (:quit-event (push `(:quit (setf ,quit (progn ,@body))) cases))
          (:key-down-event (push `(:key-down (let ,(key-down-bindings params) ,@body)) cases))
          (:video-expose-event (push `(:expose ,@body) cases))
          (:idle (setf idle body)))))
    (let ((dispatch `(case ,event-type ,@(reverse cases))))
      `(let ((,quit nil))
         (loop until ,quit
               do ,(if (eq type :poll)
                       `(loop for ,event-type = (next-event nil)
                              while ,event-type
                              do ,dispatch)
                       `(loop for ,event-type = (and (not ,quit) (next-event t))
                              while ,event-type
                              do ,dispatch))
                  ,@(when (eq type :poll)
                      `((unless ,quit
                          (run-frame (lambda () ,@idle))))))))))

;;; Enforce the rule above: the only calls to CFFI:FOREIGN-FUNCALL in this file
;;; are the two in SDL-CALL. A direct call elsewhere would bypass the trap
;;; masking and only fail on a real display, which no headless check runs; it
;;; is caught here instead, as a build warning (the build is kept at zero).
(eval-when (:compile-toplevel)
  (let* ((source (uiop:read-file-string *compile-file-truename*))
         (pattern (concatenate 'string "(" "cffi:foreign-funcall"))
         (count (loop for start = 0 then (1+ found)
                      for found = (search pattern source :start2 start)
                      while found count t)))
    (unless (= count 2)
      (warn "render.lisp calls CFFI:FOREIGN-FUNCALL directly ~D time~:P outside SDL-CALL; ~
             call SDL through SDL-CALL instead" (- count 2)))))
