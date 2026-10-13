;;;; One-off tool, not part of the cotd system: export the four lispbuilder-sdl
;;;; built-in bitmap fonts CotD uses into src/data/fonts/*.bmp, so that text
;;;; rendering no longer depends on lispbuilder-sdl (sdl2 migration, phase 1).
;;;;
;;;; Kept as the record of where src/data/fonts/ came from. CotD no longer
;;;; depends on lispbuilder-sdl, so running it again needs lispbuilder-sdl
;;;; (and SDL 1.2) installed separately: (ql:quickload "lispbuilder-sdl").
;;;;
;;;; Each file is a single row of 256 glyphs, glyph N (char-code N) at
;;;; x = N * char-width: white (#xFFFFFF) where the glyph has a pixel, black
;;;; elsewhere. Run from a REPL with lispbuilder-sdl loaded:
;;;;
;;;;   (load "tools/export-lispbuilder-fonts.lisp")
;;;;   (export-lispbuilder-fonts "src/data/fonts/")

(defun export-lispbuilder-font (font-definition path)
  (let* ((w (sdl:char-width font-definition))
         (h (sdl:char-height font-definition))
         (pitch (sdl::char-pitch font-definition))
         (char-size (* pitch h))
         (data (sdl::data font-definition))
         (glyph-count (floor (length data) char-size))
         (surface (sdl:create-surface (* w glyph-count) h)))
    (assert (= glyph-count 256) () "~A: expected 256 glyphs, found ~A" path glyph-count)
    (sdl:fill-surface sdl:*black* :surface surface)
    (dotimes (code glyph-count)
      ;; same bit walk as LISPBUILDER-SDL::GET-CHARACTER: rows are PITCH bytes,
      ;; most significant bit first
      (let ((pos (* code char-size)))
        (dotimes (iy h)
          (dotimes (ix w)
            (when (logbitp (- 7 (mod ix 8)) (aref data (+ pos (* iy pitch) (floor ix 8))))
              (sdl:draw-pixel-* (+ (* code w) ix) iy :surface surface :color sdl:*white*))))))
    (ensure-directories-exist path)
    (sdl:save-image surface (namestring path))
    path))

(defun export-lispbuilder-fonts (dir)
  (sdl:with-init ()
    (sdl:window 1 1)
    (loop for (name def) in (list (list "font-6x13" sdl:*font-6x13*)
                                  (list "font-8x13" sdl:*font-8x13*)
                                  (list "font-6x13o" sdl:*font-6x13o*)
                                  (list "font-8x13o" sdl:*font-8x13o*))
          collect (export-lispbuilder-font def (merge-pathnames (format nil "~A.bmp" name) dir)))))
