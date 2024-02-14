(in-package :cotd-sdl)

(defclass ai-package ()
  ((id :initarg :id :accessor id)
   (priority :initform 0 :initarg :priority :accessor priority)
   (on-check-ai :initform nil :initarg :on-check-ai :accessor on-check-ai)  ;; a function that checks for the AI package if it can and should be invoked now
   (on-invoke-ai :initform nil :initarg :on-invoke-ai :accessor on-invoke-ai) ;; a function that invokes the AI package
   ))

(defun set-ai-package (ai-package)
  (when (>= (id ai-package) (length *ai-packages*))
    (adjust-array *ai-packages* (list (1+ (id ai-package)))))
  (setf (aref *ai-packages* (id ai-package)) ai-package))

(defun get-ai-package-by-id (ai-package-id)
  (aref *ai-packages* ai-package-id)) 
