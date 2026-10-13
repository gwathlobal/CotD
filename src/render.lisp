(in-package :cl-user)

(defpackage :cotd-render
  (:use :cl)
  (:import-from #:sdl
   ;; window/video setup and the main event loop
   #:init-video #:window #:enable-key-repeat #:enable-unicode
   #:update-display

   ;; surfaces and images
   #:create-path #:*default-surface*

   ;; geometry
   #:rectangle #:rectangle-from-edges-* #:with-rectangle
   #:x #:y #:width #:height)
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
   #:surface-rgb-bytes))

;;;; The render backend boundary.
;;;;
;;;; Every call CotD makes into lispbuilder-sdl for actual rendering (window
;;;; setup, the event loop, surfaces/images, geometry, text, colours) goes
;;;; through this package instead of the sdl: package directly. Most exports
;;;; are still lispbuilder-sdl's own symbols, imported from :sdl. The rest are
;;;; defined below on top of a few lispbuilder primitives, so they keep
;;;; working once those primitives are reimplemented against cl-sdl2
;;;; (TODO.txt). No call site elsewhere needs to change, the same way
;;;; src/key-bindings.lisp already isolated key constants.
;;;;
;;;; Contract that is not visible from the symbol list, and that a
;;;; replacement must keep:
;;;;  - *DEFAULT-SURFACE* is NIL during normal play, and a NIL surface (the
;;;;    default of every :SURFACE keyword) means "draw to the window". Call
;;;;    sites pass :SURFACE COTD-RENDER:*DEFAULT-SURFACE* explicitly and rely
;;;;    on that NIL; only the headless oracles bind it to an offscreen surface.
;;;;
;;;; COMPARE-GOLDEN-SCREENS in headless-test.lisp checks a replacement against
;;;; whole-screen baselines captured from lispbuilder-sdl (test/golden/).

(in-package :cotd-render)

(defun target-surface (surface)
  "SURFACE, or the window when it is NIL (see the contract above)."
  (or surface sdl:*default-display*))

(defun blit (src x y &key (surface *default-surface*)
                          (src-x 0) (src-y 0) (src-w (width src)) (src-h (height src)))
  "Copy the SRC-W x SRC-H area at SRC-X SRC-Y of SRC (by default, all of it)
to X Y on SURFACE (NIL = the window). SRC's colour key, if any, applies."
  ;; lispbuilder-sdl blits whatever source rectangle ("cell") was last set on
  ;; the source surface; set it every time so no blit depends on an earlier one
  (sdl:set-cell-* src-x src-y src-w src-h :surface src :index 0)
  (sdl:draw-surface-at-* src x y :surface (target-surface surface)))

;;; ---------------------------------------------------------------------
;;; Colours.
;;;
;;; A colour is a packed #xRRGGBB integer everywhere in CotD (the same
;;; representation as COTD::PACKED-COLOR). Only this file converts one to the
;;; backend's own colour object, at the call into the backend.
;;; ---------------------------------------------------------------------

(declaim (inline color))
(defun color (&key (r 0) (g 0) (b 0))
  "The packed #xRRGGBB colour with these components."
  (declare (type (unsigned-byte 8) r g b))
  (logior (ash r 16) (ash g 8) b))

;; the same values as lispbuilder-sdl's colours of these names
(defparameter *black* #x000000)
(defparameter *white* #xFFFFFF)
(defparameter *red* #xFF0000)
(defparameter *green* #x00FF00)
(defparameter *blue* #x0000FF)
(defparameter *yellow* #xFFFF00)
(defparameter *cyan* #x00FFFF)
(defparameter *magenta* #xFF00FF)

(defvar *sdl-color-cache* (make-hash-table)
  "packed colour -> lispbuilder-sdl COLOR, so each distinct colour allocates once.")

(defun sdl-color (packed)
  "The backend colour object for the packed colour PACKED."
  (declare (type (unsigned-byte 24) packed))
  (or (gethash packed *sdl-color-cache*)
      (setf (gethash packed *sdl-color-cache*)
            (sdl:color :r (ldb (byte 8 16) packed) :g (ldb (byte 8 8) packed) :b (ldb (byte 8 0) packed)))))

(defun convert-color-arg (key args)
  "ARGS (a keyword argument list) with the colour under KEY, if there is one,
converted to a backend colour. The converted pair goes in front, and the first
occurrence of a keyword is the one that counts."
  (let ((packed (getf args key)))
    (if packed
        (list* key (sdl-color packed) args)
        args)))

(defun fill-surface (color &rest args &key template surface)
  "Fill SURFACE (NIL = the window), or the TEMPLATE rectangle of it, with COLOR."
  (declare (ignore template surface))
  (apply #'sdl:fill-surface (sdl-color color) args))

(defun draw-rectangle (rect &rest args &key color &allow-other-keys)
  (declare (ignore color))
  (apply #'sdl:draw-rectangle rect (convert-color-arg :color args)))

(defun draw-pixel-* (x y &rest args &key color &allow-other-keys)
  (declare (ignore color))
  (apply #'sdl:draw-pixel-* x y (convert-color-arg :color args)))

(defun create-surface (w h &rest args &key color-key &allow-other-keys)
  (declare (ignore color-key))
  (apply #'sdl:create-surface w h (convert-color-arg :color-key args)))

(defun load-image (path &rest args &key color-key &allow-other-keys)
  (declare (ignore color-key))
  (apply #'sdl:load-image path (convert-color-arg :color-key args)))

(defun surface-rgb-bytes (surface)
  "SURFACE's pixels as a fresh (UNSIGNED-BYTE 8) vector, 3 bytes (R G B) per
pixel, row-major, plus its width and height as the second and third values.
Decoding goes through SDL_GetRGB with the surface's own pixel format, so the
result does not depend on which pixel format the backend picked."
  (let* ((w (width surface))
         (h (height surface))
         (bytes (make-array (* w h 3) :element-type '(unsigned-byte 8)))
         (format (sdl-base::pixel-format (sdl:fp surface))))
    (cffi:with-foreign-objects ((r :unsigned-char) (g :unsigned-char) (b :unsigned-char))
      (sdl:with-pixel (pix (sdl:fp surface))
        (loop for y from 0 below h
              do (loop for x from 0 below w
                       for i = (* 3 (+ x (* y w)))
                       do (sdl-cffi::sdl-get-rgb (sdl:read-pixel pix x y) format r g b)
                          (setf (aref bytes i) (cffi:mem-ref r :unsigned-char)
                                (aref bytes (+ i 1)) (cffi:mem-ref g :unsigned-char)
                                (aref bytes (+ i 2)) (cffi:mem-ref b :unsigned-char))))))
    (values bytes w h)))

;;; ---------------------------------------------------------------------
;;; Bitmap fonts.
;;;
;;; These replace lispbuilder-sdl's built-in fonts of the same names, pixel
;;; for pixel: the glyph data was exported from lispbuilder-sdl into
;;; data/fonts/*.bmp by tools/export-lispbuilder-fonts.lisp. Each file is one
;;; row of 256 glyphs, glyph N (char-code N) at x = N * char-width, white where
;;; the glyph has a pixel and black elsewhere.
;;;
;;; Drawing text writes the text colour on the glyph's pixels and leaves every
;;; other pixel alone, like lispbuilder-sdl's DRAW-STRING-SOLID-*. For that,
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

(defmacro with-init ((&rest flags) &body body)
  `(sdl:with-init (,@flags)
     (reset-font-surfaces)
     (reset-frame-limiter)
     ,@body))

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
                  (sdl:free image)))))))

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
              (let ((fg (sdl:map-color (sdl-color packed-color) strip)))
                (sdl:with-pixel (pix (sdl:fp strip))
                  (dotimes (y h)
                    (dotimes (x w)
                      (when (= 1 (sbit bits (+ x (* y w))))
                        (sdl:write-pixel pix x y fg))))))
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
;;; WITH-EVENTS keeps the clause syntax of lispbuilder-sdl's macro of the same
;;; name, for the four clauses CotD uses:
;;;
;;;   (:quit-event () body)            - body's value T ends the loop
;;;   (:key-down-event (:key k :mod m :unicode u) body)  - any subset of keys
;;;   (:video-expose-event () body)
;;;   (:idle () body)                  - once per frame, after the queue is empty
;;;
;;; and its behaviour: in :POLL mode every pending event is dispatched (even
;;; ones still queued behind a quit), then, unless quitting, the :IDLE forms
;;; run and the loop sleeps to hold *FRAME-RATE*. :WAIT blocks for each event
;;; and has no idle step. Key values are the backend's own (*KEY-BINDINGS* in
;;; key-bindings.lisp translates them), MOD is a modifier bitmask and UNICODE
;;; the character code typed, 0 if none.
;;; ---------------------------------------------------------------------

(defvar *event* nil
  "Foreign buffer NEXT-EVENT reads each event into; allocated on first use.
Plain malloc'd memory, so it outlives SDL sessions. Event fields are copied
into the clause's variables before its body runs, so a WITH-EVENTS nested in
a clause body reusing the buffer is harmless.")

(defun next-event (wait)
  "Read the next event into *EVENT* and return its type, one of :QUIT,
:KEY-DOWN, :EXPOSE or :OTHER. Returns NIL when no event is pending (WAIT
false) or on an error (WAIT true, which otherwise blocks until one arrives)."
  (unless *event*
    (setf *event* (cffi:foreign-alloc '(:union sdl-cffi::sdl-event))))
  (if (= 0 (if wait
               (sdl-cffi::sdl-wait-event *event*)
               (sdl-cffi::sdl-poll-event *event*)))
      nil
      (case (sdl::event-type *event*)
        (:quit-event :quit)
        (:key-down-event :key-down)
        (:video-expose-event :expose)
        (t :other))))

(defun event-key () (sdl::key-key *event*))
(defun event-mod () (sdl::key-mod *event*))
(defun event-unicode () (sdl::key-unicode *event*))

(defun push-event-of-type (type)
  (let ((event (sdl::new-event type)))
    (sdl-cffi::sdl-push-event event)
    ;; SDL copies the event into its queue
    (cffi:foreign-free event)))

(defun push-quit-event () (push-event-of-type :quit-event))
(defun push-expose-event () (push-event-of-type :video-expose-event))

(defun push-key-down-event (key &key (mod 0) (unicode 0))
  "Queue a key press of KEY (a backend key value, as in *KEY-BINDINGS*) as if
typed with modifier bitmask MOD, producing character code UNICODE. For tests:
the headless event check drives WITH-EVENTS with these."
  (let* ((event (sdl::new-event :key-down-event))
         (keysym (cffi:foreign-slot-pointer event '(:struct sdl-cffi::sdl-keyboard-event) 'sdl-cffi::keysym)))
    (setf (cffi:foreign-slot-value keysym '(:struct sdl-cffi::sdl-key-sym) 'sdl-cffi::sym) key
          (cffi:foreign-slot-value keysym '(:struct sdl-cffi::sdl-key-sym) 'sdl-cffi::mod) mod
          (cffi:foreign-slot-value keysym '(:struct sdl-cffi::sdl-key-sym) 'sdl-cffi::unicode) unicode)
    (sdl-cffi::sdl-push-event event)
    (cffi:foreign-free event)))

(defun ticks () (sdl-cffi::sdl-get-ticks))

(defun delay (ms)
  "Sleep for MS milliseconds."
  (sdl-cffi::sdl-delay ms))

(defparameter *frame-rate* 30
  "Frames per second WITH-EVENTS holds its :POLL loop to (lispbuilder-sdl's default).")

(defvar *frame-count* 0)
(defvar *frame-base-ticks* nil)

(defun reset-frame-limiter ()
  (setf *frame-count* 0
        *frame-base-ticks* nil))

(defun run-frame (idle-fn)
  "Run IDLE-FN, then sleep for whatever is left of this frame. The schedule is
SDL_gfx's (as in lispbuilder-sdl): frame N is due at base + N * 1000/rate ms;
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
