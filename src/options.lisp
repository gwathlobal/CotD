(in-package :cotd)

(defstruct options
  (tiles 'large) ;;; 'large - use small tiles 
                 ;;; 'small - use large tiles
  )

(defun read-options (s-expr options)
  (format t "READ-OPTIONS: S-EXPR = ~A~%" s-expr)
  (unless (typep s-expr 'list)
    (return-from read-options nil))
  
  (cond
    ((equal (first s-expr) 'tiles) (set-options-tiles s-expr options))
    )
  )

(defun set-options-tiles (s-expr options)
  (format t "SET-OPTIONS-TILES: S-EXPR = ~A~%" s-expr)
  (setf (options-tiles options) (second s-expr)))
