(in-package :cotd)

(defstruct options
  (tiles 'large) ;;; 'large - use small tiles 
                 ;;; 'small - use large tiles
  (font 'font-6x13) ;;; 'font-6x13 - use small font
                    ;;; 'font-8x13 - use large font
  )

(defun read-options (s-expr options)
  (format t "READ-OPTIONS: S-EXPR = ~A~%" s-expr)
  (unless (typep s-expr 'list)
    (return-from read-options nil))
  
  (cond
    ((equal (first s-expr) 'tiles) (set-options-tiles s-expr options))
    ((equal (first s-expr) 'font) (set-options-font s-expr options))
    )
  )

(defun set-options-tiles (s-expr options)
  (format t "SET-OPTIONS-TILES: S-EXPR = ~A~%" s-expr)
  (setf (options-tiles options) (second s-expr)))

(defun set-options-font (s-expr options)
  (format t "SET-OPTIONS-FONT: S-EXPR = ~A~%" s-expr)
  (setf (options-font options) (second s-expr)))
