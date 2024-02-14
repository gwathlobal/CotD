;;;; wrapper.lisp

(in-package :cotd)

(setf pws:*debug-on-error* t)

(defvar *server* nil)
(defvar *connections* (make-list 0))

(defun start-server (port)
  (if (or (null *server*) 
          (not (bt:thread-alive-p *server*)))
      (progn
        (setf *server* (pws:server port t))
        (log:info "Server started.")
        *server*)
      (progn
        (log:info "Attempting to start the server... Server is already running.")))
  )

(defun stop-server ()
  (if (and (not (null *server*))
           (bt:thread-alive-p *server*))
      (progn
        (loop for websocket in *connections* 
              finally (setf *connections* (make-list 0)) 
              do
                 (handler-case 
                     (pws:close websocket)
                   (error (c)
                     (log:warn "Error occurred wihile trying to close a socket: " c))))
        (pws:server-close *server*)
        (log:info "Server stopped."))
      (progn
        (log:info "Attempting to stop the server... Server is already stopped."))))

(defun define-handlers-for-url (url &key open message close error)
  (pws:define-resource url
    :open (if (null open)
              (lambda (websocket)
                (handle-new-connection websocket))
              (lambda (websocket)
                (handle-new-connection websocket)
                (funcall open websocket)))
    :message (if (null message)
                 (lambda (websocket message)
                   (declare (ignore websocket message)))
                 message)
    :close (if (null close)
               (lambda (websocket)
                 (handle-close-connection websocket))
               (lambda (websocket)
                 (handle-close-connection websocket)
                 (funcall close websocket)))
    :error (if (null error)
               (lambda (websocket condition)
                 (declare (ignore websocket condition)))
               error)))

(defun send-msg (client message)
  (when (/= 1 (pws:ready-state client))
    (log:error "Client is not OPEN.")
    (return-from send-msg))
  (pws:send client message))

(defun broadcast-to-all-clients (message)
  (log:info "Broadcasting to ~A clients: ~A" (length *connections*) message)
  (loop for client in *connections* do
           (send-msg client message)))

(defun handle-new-connection (websocket)
  (pushnew websocket *connections*)
  (log:info "New client connection established."))

(defun handle-close-connection (websocket)
  (setf *connections* (delete websocket *connections*))
  (log:info "Client connection closed."))