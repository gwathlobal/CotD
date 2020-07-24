(in-package :cotd)

(defclass highscores-record ()
  ((player-name :initarg :player-name :accessor highscore-record/player-name :type string)
   (score :initarg :score :accessor highscore-record/score :type fixnum)
   (mob-type :initarg :mob-type :accessor highscore-record/mob-type :type string)
   (turns-num :initarg :turns-num :accessor highscore-record/turns-num :type fixnum)
   (result :initarg :result :accessor highscore-record/result :type string)
   (sector-name :initarg :sector-name :accessor highscore-record/sector-name :type string)
   (params :initform () :initarg :params :accessor highscore-record/params :type list)))

(defclass highscores-table ()
  ((version :initform 1 :initarg :version :accessor highscores-table/version :type fixnum)
   (records :initform () :initarg :records :accessor highscores-table/records :type list)
   (params :initform () :initarg :params :accessor highscores-table/params :type list)))

(defun save-highscores-to-disk ()
  (handler-case
      (let ((file-pathname (merge-pathnames (make-pathname :name *highscores-filename*) *current-dir*)))
        (cl-store:store *highscores* file-pathname))
    (t (c)
      (log:info (format nil "~%SAVE-HIGHSCORES-TO-DISK: Error occured while saving to file: ~A.~%~%" c))))
  nil)

(defun load-highscores-from-disk ()
  (let ((file-pathname (merge-pathnames (make-pathname :name *highscores-filename*) *current-dir*)))
    (handler-case
        (if (probe-file file-pathname)
          (setf *highscores* (cl-store:restore file-pathname))
          (progn
            (log:info (format nil "~%LOAD-HIGHSCORES-FROM-DISK: No file ~A to read the highscores from. Overwriting with defaults.~%~%" file-pathname))
            (save-highscores-to-disk)
            nil))
      (t (c)
        (log:info (format nil "~%LOAD-HIGHSCORES-FROM-DISK: Error occured while reading the highscores from file ~A: ~A. Overwriting with defaults.~%~%" file-pathname c))
        (save-highscores-to-disk)
        nil)))
  *highscores*)

(defun add-highscore-record (highscores &key name-str score mob-type-str turns result-str sector-name-str params)
  (let ((record (make-instance 'highscores-record
                               :player-name name-str
                               :score score
                               :mob-type mob-type-str
                               :turns-num turns
                               :result result-str
                               :sector-name sector-name-str
                               :params params))
        (pos 0))
    (push record (highscores-table/records highscores))

    (setf (highscores-table/records highscores) (stable-sort (highscores-table/records highscores) #'> :key #'(lambda (a) (highscore-record/score a))))

    (setf pos (position record (highscores-table/records highscores)))

    (when (and (> (length (highscores-table/records highscores)) 10)
               (< pos 10))
      (truncate-highscores highscores))
    
    pos))

(defun truncate-highscores (highscores)
  (setf (highscores-table/records highscores) (loop repeat 10
                                                    for record in (highscores-table/records highscores)
                                                    collect record)))

(defun write-highscore-record-to-str (highscores-record)
  (format nil "~10@<~D~> ~20@<~A~> ~20@<~A~> ~10@<~A~>  ~20@<~A~>~%      ~A~%"
          (highscore-record/score highscores-record)
          (highscore-record/player-name highscores-record)
          (highscore-record/mob-type highscores-record)
          (format nil "~D turn~:P" (highscore-record/turns-num highscores-record))
          (highscore-record/sector-name highscores-record)
          (highscore-record/result highscores-record)))

