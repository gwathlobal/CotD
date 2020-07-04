(in-package :cotd)

(defparameter *campaign-commands* (make-hash-table))

(defenum:defenum campaign-command-enum (:campaign-command-angel-wait
                                        :campaign-command-demon-wait
                                        :campagin-command-military-wait
                                        :campaign-command-satanist-wait
                                        :campaign-command-church-wait
                                        :campaign-command-satanist-sacrifice
                                        :campaign-command-satanist-hide-lair
                                        :campaign-command-demon-reform-lair
                                        :campaign-command-military-reveal-lair
                                        ))

(defclass campaign-command ()
  ((id :initarg :id :accessor campaign-command/id :type campaign-command-enum)
   (name-func :initarg :name-func :accessor campaign-command/name-func) ;; a lambda with world param
   (descr-func :initarg :descr-func :accessor campaign-command/descr-func) ;; a lambda with world param
   (faction-type :initarg :faction-type :accessor campaign-command/faction-type)
   (disabled :initform nil :initarg :disabled :accessor campaign-command/disabled)
   (trigger-on-start :initform t :initarg :trigger-on-start :accessor campaign-command/trigger-on-start)
   (cd :initform 0 :initarg :cd :accessor campaign-command/cd)
   (on-check-func :initarg :on-check-func :accessor campaign-command/on-check-func)
   (on-trigger-func :initarg :on-trigger-func :accessor campaign-command/on-trigger-func)))

(defun set-campaign-command (&key id name-func descr-func faction-type disabled trigger-on-start cd on-check-func on-trigger-func)
  (unless id (error ":ID is an obligatory parameter!"))
  (unless name-func (error ":NAME-FUNC is an obligatory parameter!"))
  (unless descr-func (error ":DESCR-FUNC is an obligatory parameter!"))
  (unless faction-type (error ":FACTION-TYPE is an obligatory parameter!"))

  (setf (gethash id *campaign-commands*) (make-instance 'campaign-command :id id :name-func name-func :descr-func descr-func :faction-type faction-type
                                                                          :disabled disabled :trigger-on-start trigger-on-start :cd cd :on-check-func on-check-func :on-trigger-func on-trigger-func)))

(defun get-campaign-command-by-id (campaign-command-id)
  (gethash campaign-command-id *campaign-commands*))
