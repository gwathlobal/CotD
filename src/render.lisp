(in-package :cl-user)

(defpackage :cotd-render
  (:use :cl)
  (:import-from #:sdl
   ;; window/video setup and the main event loop
   #:init-video #:window #:enable-key-repeat #:enable-unicode
   #:update-display #:with-events

   ;; surfaces and images
   #:load-image #:create-surface #:create-path #:fill-surface
   #:draw-surface-at-* #:set-cell-*

   ;; geometry
   #:rectangle #:rectangle-from-edges-* #:with-rectangle #:draw-rectangle #:draw-pixel-*
   #:x #:y #:width #:height

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

(defun packed-rgb (color)
  "COLOR as an #xRRGGBB integer. Accepts a packed integer already, or a COLOR."
  (if (integerp color)
      color
      (logior (ash (sdl:r color) 16) (ash (sdl:g color) 8) (sdl:b color))))

(defun rgb-color (packed)
  (sdl:color :r (ldb (byte 8 16) packed) :g (ldb (byte 8 8) packed) :b (ldb (byte 8 0) packed)))

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
                   (key (rgb-color (if (= packed-color 0) #xFFFFFF 0)))
                   (strip (create-surface w h :color-key key)))
              (fill-surface key :surface strip)
              (let ((fg (sdl:map-color (rgb-color packed-color) strip)))
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
         (strip (font-strip font (packed-rgb color)))
         (start-x (ecase justify
                    (:left x)
                    (:right (- x (* w (length string))))
                    (:center (- x (/ (* w (length string)) 2))))))
    (loop for c across string
          for cx from start-x by w
          for code = (char-code c)
          do (unless (< code 256)
               (error "COTD-RENDER: ~S has no glyph in the bitmap fonts" c))
             (set-cell-* (* code w) 0 w h :surface strip :index 0)
             (draw-surface-at-* strip cx y :surface surface))
    surface))
