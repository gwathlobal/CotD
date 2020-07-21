(in-package :cotd)

(defenum:defenum save-game-type-enum (:save-game-campaign
                                      :save-game-scenario))

(defenum:defenum save-type-enum (:save-campaign
                                 :save-scenario))

(defclass serialized-game ()
  ((save-type :initform :save-scenario :initarg :save-type :accessor serialized-game/save-type :type save-type-enum)
   (world :initform *world* :initarg :world :accessor serialized-game/world :type world)
   (mobs :initform *mobs* :initarg :mobs :accessor serialized-game/mobs :type array)
   (items :initform *items* :initarg :items :accessor serialized-game/items :type array)
   (lvl-features :initform *lvl-features* :initarg :lvl-features :accessor serialized-game/lvl-features :type array)
   (effects :initform *effects* :initarg :effects :accessor serialized-game/effects :type array)))

(defclass serialized-save-descr ()
  ((id :initarg :id :accessor serialized-save-descr/id :type fixnum)
   (player-name :initarg :player-name :accessor serialized-save-descr/player-name :type string)
   (sector-name :initarg :sector-name :accessor serialized-save-descr/sector-name :type string)
   (mission-name :initarg :mission-name :accessor serialized-save-descr/mission-name :type string)
   (save-date :initarg :save-date :accessor serialized-save-descr/save-date :type fixnum)
   (world-date-str :initarg :world-date-str :accessor serialized-save-descr/world-date-str :type fixnum)
   (params :initarg :params :accessor serialized-save-descr/params :type list)))

(declaim (ftype (function (save-game-type-enum)
                          pathname)
                find-save-game-paths))

(defun find-save-game-path (save-game-type)
  (declare (type save-game-type-enum save-game-type))
  (let ((pathname-middle-section (case save-game-type
                                   (:save-game-campaign *campaign-saves-pathlist*)
                                   (:save-game-scenario *scenario-saves-pathlist*))))
    (merge-pathnames (make-pathname :directory (append '(:relative) pathname-middle-section)) *current-dir*)))

(declaim (ftype (function (save-game-type-enum)
                          list)
                find-all-save-game-paths))

(defun find-all-save-game-paths (save-game-type)
  (declare (type save-game-type-enum save-game-type))

  (directory (merge-pathnames (make-pathname :directory '(:relative :wild)) (find-save-game-path save-game-type)))
  )

(declaim (ftype (function (save-game-type-enum save-type-enum)
                          null)
                save-game-to-disk))

(defun save-game-to-disk (save-game-type save-type)
  (declare (type save-game-type-enum save-game-type)
           (type save-type-enum save-type))

  ;; if the save slot is not set, find all saves to determine the id of the next save slot
  (when (not (game-manager/game-slot-id *game-manager*))
    (loop with save-slots = ()
          for pathname in (find-all-save-game-paths save-game-type)
          for last-dir = (nth (1- (length (pathname-directory pathname))) (pathname-directory pathname))
          for final-num = nil
          do
             (handler-case
                 (setf final-num (parse-integer (string-left-trim *save-final-base-dirname* last-dir)))
               (t (c)
                 (logger (format nil "SAVE-GAME-TO-DISK: ~A in ~A does not end with an integer - ignored. Error: ~A~%" last-dir pathname c))))
             (when final-num
               (push final-num save-slots))
          finally
             ;; find a free save slot id
             (loop with n = 0
                   while (find n save-slots) do
                     (incf n)
                   finally (setf (game-manager/game-slot-id *game-manager*) n))))
  
  (handler-case
      (let* ((final-save-name (format nil "~A~A" *save-final-base-dirname* (game-manager/game-slot-id *game-manager*)))
             (dir-pathname (merge-pathnames (make-pathname :directory `(:relative ,final-save-name)) (find-save-game-path save-game-type)))
             (descr-file-pathname (merge-pathnames (make-pathname :name *save-descr-filename*) dir-pathname))
             (game-file-pathname (merge-pathnames (make-pathname :name *save-game-filename*) dir-pathname))
             (serialized-game (make-instance 'serialized-game :save-type save-type))
             (serialized-save-descr (make-instance 'serialized-save-descr
                                                   :id (game-manager/game-slot-id *game-manager*)
                                                   :player-name (if (eql save-type :save-scenario)
                                                                  (get-qualified-name *player*)
                                                                  (options-player-name *options*))
                                                   :sector-name (if (level *world*)
                                                                  (name (world-sector (level *world*)))
                                                                  nil)
                                                   :mission-name (if (level *world*)
                                                                   (name (mission (level *world*)))
                                                                   nil)
                                                   :save-date (get-universal-time)
                                                   :world-date-str (format nil "Game Time: ~A~A"
                                                                           (show-date-time-ymd (world-game-time *world*))
                                                                           (if (eql save-type :save-scenario)
                                                                             (format nil ", T: ~A" (player-game-time *world*))
                                                                             ""))
                                                   :params ())))
        (ensure-directories-exist dir-pathname)
        (cl-store:store serialized-save-descr descr-file-pathname)
        (cl-store:store serialized-game game-file-pathname))
    (t (c)
      (logger (format nil "~%SAVE-GAME-TO-DISK: Error occured while saving to file: ~A.~%~%" c))))
  nil
  )

(declaim (ftype (function (pathname)
                          (or null serialized-save-descr))
                load-descr-from-disk))

(defun load-descr-from-disk (descr-pathname)
  (declare (type pathname descr-pathname))
  (let ((saved-descr nil))
    (handler-case
        (if (probe-file descr-pathname)
          (setf saved-descr (cl-store:restore descr-pathname))
          (progn
            (logger (format nil "~%LOAD-DESCR-FROM-DISK: No file ~A to read the save description from.~%~%" descr-pathname))
            nil))
      (t (c)
        (logger (format nil "~%LOAD-DESCR-FROM-DISK: Error occured while reading the save description from file ~A.~%~%" descr-pathname))
        nil))
    saved-descr))

(declaim (ftype (function (pathname)
                          (or null serialized-game))
                load-game-from-disk))

(defun load-game-from-disk (game-pathname)
  (declare (type pathname game-pathname))
  (let ((saved-game nil))
    (handler-case
        (if (probe-file game-pathname)
          (setf saved-game (cl-store:restore game-pathname))
          (progn
            (logger (format nil "~%LOAD-GAME-FROM-DISK: No file ~A to read the saved game from.~%~%" game-pathname))
            nil))
      (t (c)
        (logger (format nil "~%LOAD-GAME-FROM-DISK: Error occured while reading the saved game from file ~A: ~A.~%~%" game-pathname c))
        nil))
    (when saved-game
      (loop for slot-name in '(save-type world mobs items lvl-features effects)
            when (null (slot-boundp saved-game slot-name)) do
              (logger (format nil "~%LOAD-GAME-FROM-DISK: Invalid saved game loaded from file ~A.~%~%" game-pathname))
              (setf saved-game nil)
              (loop-finish)))
    (when saved-game
      (with-slots (world mobs items lvl-features effects) saved-game
        (setf *world* world)
        (setf *mobs* mobs)
        (setf *items* items)
        (setf *lvl-features* lvl-features)
        (setf *effects* effects)
        (setf *player* (find 'player *mobs* :key #'(lambda (a)
                                                     (type-of a))))))
    saved-game))

(declaim (ftype (function (pathname)
                          (or null t))
                delete-descr-from-disk))

(defun delete-descr-from-disk (descr-pathname)
  (declare (type pathname descr-pathname))
  (handler-case
      (if (probe-file descr-pathname)
        (delete-file descr-pathname)
        (progn
          (logger (format nil "~%DELETE-DESCR-FROM-DISK: No file ~A to remove the saved description.~%~%" descr-pathname))
          nil))
    (t (c)
      (logger (format nil "~%DELETE-DESCR-FROM-DISK: Error occured while deleting the saved description from file ~A: ~A.~%~%" descr-pathname c))
      nil)))

(declaim (ftype (function (pathname)
                          (or null t))
                delete-game-from-disk))

(defun delete-game-from-disk (game-pathname)
  (declare (type pathname game-pathname))
  (handler-case
      (if (probe-file game-pathname)
        (delete-file game-pathname)
        (progn
          (logger (format nil "~%DELETE-GAME-FROM-DISK: No file ~A to remove the saved game.~%~%" game-pathname))
          nil))
    (t (c)
      (logger (format nil "~%DELETE-GAME-FROM-DISK: Error occured while deleting the saved game from file ~A: ~A.~%~%" game-pathname c))
      nil)))

(declaim (ftype (function (pathname)
                          (or null t))
                delete-dir-from-disk))

(defun delete-dir-from-disk (dir-pathname)
  (declare (type pathname dir-pathname))
  (handler-case
      (if (probe-file dir-pathname)
        (uiop:delete-directory-tree dir-pathname :validate t)
        (progn
          (logger (format nil "~%DELETE-DIR-FROM-DISK: No directory ~A to remove.~%~%" dir-pathname))
          nil))
    (t (c)
      (logger (format nil "~%DELETE-DIR-FROM-DISK: Error occured while deleting the directory ~A: ~A.~%~%" dir-pathname c))
      nil)))
