(in-package :cotd)

(defstruct colored-txt
  (list () :type list))

(defun add-colored-str (colored-txt str &optional (color sdl:*white*))
  (setf (colored-txt-list colored-txt) (append (colored-txt-list colored-txt)
                                               (list (list str color)))))
