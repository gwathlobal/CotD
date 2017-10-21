(in-package :cotd)

(defstruct options
  (tiles 'large) ;;; 'large - use small tiles 
                 ;;; 'small - use large tiles
  (font 'font-8x13) ;;; 'font-6x13 - use small font
                    ;;; 'font-8x13 - use large font
  (player-name "Player") ;;; default name of the player
  )

(defun read-options (s-expr options)
  (logger (format nil "READ-OPTIONS: S-EXPR = ~A~%" s-expr))
  (unless (typep s-expr 'list)
    (return-from read-options nil))
  
  (cond
    ((equal (first s-expr) 'tiles) (set-options-tiles s-expr options))
    ((equal (first s-expr) 'font) (set-options-font s-expr options))
    ((equal (first s-expr) 'name) (set-options-name s-expr options))
    )
  )

(defun set-options-tiles (s-expr options)
  (logger (format nil "SET-OPTIONS-TILES: S-EXPR = ~A~%" s-expr))
  (setf (options-tiles options) (second s-expr)))

(defun set-options-font (s-expr options)
  (logger (format nil "SET-OPTIONS-FONT: S-EXPR = ~A~%" s-expr))
  (setf (options-font options) (second s-expr)))

(defun set-options-name (s-expr options)
  (logger (format nil "SET-OPTIONS-NAME: S-EXPR = ~A~%" s-expr))
  (loop for c across (second s-expr)
        with str = ""
        when (and (or (find (string-downcase (string c)) *char-list* :test #'string=)
                      (char= c #\Space)
                      (char= c #\-))
                  (< (length str) *max-player-name-length*))
          do
             (setf str (format nil "~A~A" str (string c)))
        finally (setf (options-player-name options) str))
  )

(defun create-options-file-string (options)
  (let ((str (create-string)))
    (format str ";; FONT: Changes the size of text font~%;; Format (font <font type>)~%;; <font type> can be (without quotes) \"font-6x13\" or \"font-8x13\"~A~%" (new-line))
    (format str "(font ~A)~A~%~A~%" (string-downcase (string (options-font options))) (new-line) (new-line))
    (format str ";; NAME: Sets the default name of the player~%;; Format (name \"<player name>\"). Only alphabetical ASCII characters, spaces and minuses are allowed in names.~A~%" (new-line))
    (format str "(name \"~A\")~A~%~A~%" (options-player-name options) (new-line) (new-line))
    str))
