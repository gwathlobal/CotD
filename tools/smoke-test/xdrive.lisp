;;;; Drive an X display the way a player would: synthetic key presses through
;;;; the XTest extension, and screenshots of the whole display. Meant for a
;;;; nested X server (Xephyr) that the game runs in, so the input goes through
;;;; the real window system - X11 key events, SDL's keysym and text input
;;;; translation, the game's event loop - which the headless oracles, on SDL's
;;;; dummy video driver, never exercise.
;;;;
;;;; Never point this at the desktop you are working in: XTest input goes to
;;;; whatever has the keyboard focus there.

(defpackage :cotd-xdrive
  (:use :cl)
  (:export #:open-display #:close-display #:with-display
           #:key #:type-text #:screenshot #:screen-colour-count
           #:keycodes-down #:release-all-keys))

(in-package :cotd-xdrive)

(cffi:define-foreign-library libx11
  (:unix (:or "libX11.so.6" "libX11.so"))
  (t (:default "libX11")))

(cffi:define-foreign-library libxtst
  (:unix (:or "libXtst.so.6" "libXtst.so"))
  (t (:default "libXtst")))

(cffi:use-foreign-library libx11)
(cffi:use-foreign-library libxtst)

;; the leading fields of XImage (X11/Xlib.h), as far as SCREENSHOT reads them
(cffi:defcstruct ximage
  (width :int)
  (height :int)
  (xoffset :int)
  (format :int)
  (data :pointer)
  (byte-order :int)
  (bitmap-unit :int)
  (bitmap-bit-order :int)
  (bitmap-pad :int)
  (depth :int)
  (bytes-per-line :int)
  (bits-per-pixel :int)
  (red-mask :unsigned-long)
  (green-mask :unsigned-long)
  (blue-mask :unsigned-long))

(defconstant +zpixmap+ 2)
(defconstant +all-planes+ #xFFFFFFFF)

(defstruct (display (:constructor %make-display (ptr root name)))
  ptr root name)

(defun open-display (name)
  "Connect to the X display NAME (e.g. \":5\"). Returns NIL if it isn't up."
  (let ((ptr (cffi:foreign-funcall "XOpenDisplay" :string name :pointer)))
    (unless (cffi:null-pointer-p ptr)
      (let ((display (%make-display ptr (cffi:foreign-funcall "XDefaultRootWindow" :pointer ptr :unsigned-long) name)))
        ;; with no window manager the keyboard focus follows the pointer, so
        ;; park the pointer inside the game window (which opens near the top
        ;; left of a display sized to it)
        (cffi:foreign-funcall "XTestFakeMotionEvent" :pointer ptr :int -1 :int 100 :int 100 :unsigned-long 0 :int)
        (sync display)
        display))))

(defun close-display (display)
  (cffi:foreign-funcall "XCloseDisplay" :pointer (display-ptr display) :int))

(defmacro with-display ((var name) &body body)
  `(let ((,var (or (open-display ,name)
                   (error "Cannot open X display ~A" ,name))))
     (unwind-protect (progn ,@body)
       (close-display ,var))))

(defun sync (display)
  (cffi:foreign-funcall "XSync" :pointer (display-ptr display) :int 0 :int))

(defun keycode (display keysym-name)
  "The keycode of the key whose keysym is called KEYSYM-NAME (X names: \"a\",
\"Return\", \"BackSpace\", \"Down\", \"slash\", \"Shift_L\", ...)."
  (let ((keysym (cffi:foreign-funcall "XStringToKeysym" :string keysym-name :unsigned-long)))
    (when (zerop keysym)
      (error "Unknown keysym ~S" keysym-name))
    (let ((code (cffi:foreign-funcall "XKeysymToKeycode" :pointer (display-ptr display) :unsigned-long keysym :uint8)))
      (when (zerop code)
        (error "No key produces keysym ~S on ~A" keysym-name (display-name display)))
      code)))

(defun fake-key (display code press)
  (cffi:foreign-funcall "XTestFakeKeyEvent" :pointer (display-ptr display)
                        :unsigned-int code :int (if press 1 0) :unsigned-long 0 :int))

(defun key (display keysym-name &key shift ctrl (wait 0.25))
  "Press and release the key KEYSYM-NAME, holding Shift and/or Ctrl around it,
then sleep WAIT seconds to let the game react."
  (let ((modifiers (append (when shift (list (keycode display "Shift_L")))
                           (when ctrl (list (keycode display "Control_L")))))
        (code (keycode display keysym-name)))
    (dolist (m modifiers) (fake-key display m t))
    (fake-key display code t)
    (fake-key display code nil)
    (dolist (m (reverse modifiers)) (fake-key display m nil))
    (sync display)
    (sleep wait)))

(defun type-text (display text &key (wait 0.15))
  "Type TEXT key by key: letters (capitals with Shift), digits, space and minus."
  (loop for char across text
        do (cond ((char= char #\Space) (key display "space" :wait wait))
                 ((char= char #\-) (key display "minus" :wait wait))
                 ((upper-case-p char) (key display (string (char-downcase char)) :shift t :wait wait))
                 (t (key display (string char) :wait wait)))))

(defun keycodes-down (display)
  "Keycodes the X server currently considers held down."
  (cffi:with-foreign-object (keymap :uint8 32)
    (cffi:foreign-funcall "XQueryKeymap" :pointer (display-ptr display) :pointer keymap :int)
    (loop for i below 256
          when (logbitp (mod i 8) (cffi:mem-aref keymap :uint8 (floor i 8)))
            collect i)))

(defun release-all-keys (display)
  "Send a release for every key the server thinks is held. A nested X server
takes its initial keyboard state from the host, so a key held (or stuck) on
the host shows up as held here and auto-repeats into the game. Returns the
keycodes released."
  (let ((down (keycodes-down display)))
    (dolist (code down)
      (fake-key display code nil))
    (sync display)
    down))

(defun mask-shift (mask)
  (loop for shift from 0 below 64 until (logbitp shift mask) finally (return shift)))

(defun read-screen (display width height)
  "The top-left WIDTH x HEIGHT of the screen as 8-bit RGB bytes, row-major."
  (let ((image (cffi:foreign-funcall "XGetImage" :pointer (display-ptr display) :unsigned-long (display-root display)
                                     :int 0 :int 0 :unsigned-int width :unsigned-int height
                                     :unsigned-long +all-planes+ :int +zpixmap+ :pointer)))
    (when (cffi:null-pointer-p image)
      (error "XGetImage failed on ~A" (display-name display)))
    (flet ((field (name) (cffi:foreign-slot-value image '(:struct ximage) name)))
      (unwind-protect
           (let ((data (field 'data))
                 (stride (field 'bytes-per-line))
                 (bytes (make-array (* width height 3) :element-type '(unsigned-byte 8))))
             (unless (= 32 (field 'bits-per-pixel))
               (error "Only 32-bit displays are supported, ~A has ~A bits per pixel"
                      (display-name display) (field 'bits-per-pixel)))
             (let ((masks (list (field 'red-mask) (field 'green-mask) (field 'blue-mask))))
               (dotimes (y height bytes)
                 (dotimes (x width)
                   (let ((pixel (cffi:mem-ref data :uint32 (+ (* y stride) (* 4 x))))
                         (i (* 3 (+ x (* y width)))))
                     (loop for mask in masks
                           for c from 0
                           do (setf (aref bytes (+ i c))
                                    (ldb (byte 8 0) (ash (logand pixel mask) (- (mask-shift mask)))))))))))
        ;; XDestroyImage is a macro; for an image from XGetImage it frees
        ;; exactly the data and the struct
        (cffi:foreign-funcall "XFree" :pointer (field 'data) :int)
        (cffi:foreign-funcall "XFree" :pointer image :int)))))

(defun screenshot (display path &key (width 1000) (height 600))
  "Save the top-left WIDTH x HEIGHT of the screen to PATH as a binary PPM."
  (let ((bytes (read-screen display width height)))
    (ensure-directories-exist path)
    (with-open-file (s path :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
      (write-sequence (map '(vector (unsigned-byte 8)) #'char-code (format nil "P6~%~D ~D~%255~%" width height)) s)
      (write-sequence bytes s))
    path))

(defun screen-colour-count (display &key (width 1000) (height 600) (limit 2))
  "How many distinct colours the screen shows, counting up to LIMIT. A screen
still at 1 has nothing drawn on it yet."
  (let ((bytes (read-screen display width height))
        (seen (make-hash-table)))
    (loop for i from 0 below (length bytes) by 3
          do (setf (gethash (logior (ash (aref bytes i) 16) (ash (aref bytes (+ i 1)) 8) (aref bytes (+ i 2))) seen) t)
          until (>= (hash-table-count seen) limit))
    (hash-table-count seen)))
