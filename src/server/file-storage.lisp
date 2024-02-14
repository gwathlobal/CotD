(in-package :cotd)

(defun get-txt-from-file (filename)
  (with-open-file (file (merge-pathnames filename *current-dir*) :direction :input :if-does-not-exist nil)
    (when file 
      (loop for line = (read-line file nil)
            with str = (create-string "")
            while line do (format str "~A~%" line)
            finally (return str)))))

(defun populate-txt-from-filelist (file-path-list)
  (append (list nil) (map 'list #'get-txt-from-file file-path-list))
  )
