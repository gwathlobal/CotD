(in-package :cotd-sdl)

;; :string - the string to display

(defstruct message-box
  (had-message-this-turn nil :type boolean)
  (strings (make-colored-txt) :type colored-txt))

(defun add-message (str &optional (color sdl:*white*) (message-box-list (list (level/full-message-box (level *world*)) (level/small-message-box (level *world*)))))
  (log:info "~A" str)
  (loop for message-box in message-box-list do
    (add-colored-str (message-box-strings message-box) str color)))

(defun get-message-str (n &optional (message-box (level/full-message-box (level *world*))))
  (first (nth n (colored-txt-list (message-box-strings message-box)))))

(defun message-list-length (&optional (message-box (level/full-message-box (level *world*))))
  (length (colored-txt-list (message-box-strings message-box))))

(defun clear-message-list (&optional (message-box (level/full-message-box (level *world*))))
  (setf (colored-txt-list (message-box-strings message-box)) ())
  (setf (message-box-had-message-this-turn message-box) nil))

(defun set-message-this-turn (bool &optional (message-box (level/full-message-box (level *world*))))
  (setf (message-box-had-message-this-turn message-box) bool))

(defun get-message-this-turn (&optional (message-box (level/full-message-box (level *world*))))
  (message-box-had-message-this-turn message-box))

(defun get-msg-str-list (&optional (message-box (level/full-message-box (level *world*))))
  (loop with str = (make-array '(0) :element-type 'character :adjustable t :fill-pointer t)
        for (line color) in (reverse (colored-txt-list (message-box-strings message-box)))
        do
           (format str "~A" line)
        finally (return str)))

(defun prepend-article-func (article name &rest args)
  (let ((article-str (cond
                       ((and (= article +article-a+) (find (char (string-downcase name) 0) '(#\a #\u #\o #\i #\e))) "an ")
                       ((= article +article-a+) "a ")
                       ((= article +article-the+) "the ")
                       (t ""))))
    (when (or (find +noun-proper+ args)
              (and (find +noun-common+ args)
                   (find +noun-plural+ args)
                   (= article +article-a+)))
      (setf article-str ""))
    (format nil "~A~A" article-str name)))

(defmacro prepend-article (article name-func)
  `(multiple-value-call #'prepend-article-func ,article ,name-func))
