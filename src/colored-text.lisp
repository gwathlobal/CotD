(in-package :cotd)

(defstruct colored-txt
  (list () :type list))

(defun add-colored-str (colored-txt str &optional (color cotd-render:*white*))
  (setf (colored-txt-list colored-txt) (append (colored-txt-list colored-txt)
                                               (list (list str color)))))
