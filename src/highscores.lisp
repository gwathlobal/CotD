(in-package :cotd)

(defstruct highscores
  (highscore-records ())
  (additional-record nil))

;; A highscore record is a list (s-expr) with the following content:
;;    player name - string
;;    score
;;    faction - string
;;    turns
;;    status
;;    layout

(defun read-highscore-record (s-expr)
  (logger (format nil "READ-HIGHSCORE-RECORD: S-EXPR = ~A~%" s-expr))
  (unless (or (typep s-expr 'list)
              (< (length s-expr) 6))
    (return-from read-highscore-record nil))
  
  s-expr
  )

(defun add-highscore-record (record highscores)
  (logger (format nil "ADD-HIGHSCORE-RECORD: S-EXPR = ~A~%" record))
  (if (and (highscores-highscore-records highscores)
           (= (length (highscores-highscore-records highscores)) 10)
           (>= (nth 1 (first (last (highscores-highscore-records highscores))))
               (nth 1 record)))
    (progn
      (setf (highscores-additional-record highscores) record)
      (return-from add-highscore-record 10))
    (progn
      (if (highscores-highscore-records highscores)
        (progn
          (loop for elem in (highscores-highscore-records highscores)
                for n from 1
                with list = (highscores-highscore-records highscores)
                when (< (second elem) (second record))
                  do
                     (setf (highscores-highscore-records highscores)
                           (concatenate 'list
                                        (subseq list 0 (1- n))
                                        (list record)
                                        (nthcdr (1- n) list)))
                     (when (> (length (highscores-highscore-records highscores)) 10)
                       (setf (highscores-highscore-records highscores) (butlast (highscores-highscore-records highscores))))
                     (return-from add-highscore-record (1- n)))
          (setf (highscores-highscore-records highscores) (append (highscores-highscore-records highscores) (list record)))
          (return-from add-highscore-record (1- (length (highscores-highscore-records highscores)))))
        (progn
          (push record (highscores-highscore-records highscores))
          (return-from add-highscore-record 0)))
      )))

(defun make-highscore-record (name score faction turns status layout)
  (list name score faction turns status layout))

(defun write-highscores-to-file (highscores)
  (with-open-file (file (merge-pathnames "scenario-highscores" *current-dir*) :direction :output :if-exists :supersede)
    (loop for record in (highscores-highscore-records highscores) do
      (print record file))))

(defun write-highscores-to-str (record)
  (format nil "~10@<~D~> ~20@<~A~> ~20@<~A~> ~10@<~A~>  ~20@<~A~>~%      ~A~%"
          (second record)
          (first record)
          (if (third record)
            (third record)
            "None")
          (format nil "~D turn~:P" (fourth record))
          (sf-name (get-scenario-feature-by-id (sixth record)))
          (fifth record)))
