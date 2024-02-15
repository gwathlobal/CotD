;;;; client.lisp

(in-package :cotd-sdl/websocket)

(defvar *client* nil)

(defun str-to-keyword (string)
  (if (or (null string)
          (string= string ""))
      nil
      (intern (string-upcase string) '#:keyword)))

(defun start-client (port on-message-func)
  (if (not (client-available-p))
      (progn
        (let ((url (format nil "ws://localhost:~A/" port)))
          (setf *client* (wsd:make-client url :max-length 655350))
          (wsd:on :message *client* on-message-func)
          (wsd:start-connection *client*)
          (log:info "Starting a client to ~A." url)))
      (progn
        (log:info "Trying to start client... Client is already started."))))

(defun client-available-p ()
  (and *client*
       (not (eq (wsd:ready-state *client*) :closed))))

(defun send-msg-to-server (msg)
  (when (not (client-available-p))
    (return-from send-msg-to-server nil))
  
  (wsd:send-text *client* msg))

(defun close-client ()
  (if (client-available-p)
      (progn
        (wsd:close-connection *client*)
        (log:info "Stopping client."))
      (progn
        (log:info "Trying stop client... Client already stopped."))))

