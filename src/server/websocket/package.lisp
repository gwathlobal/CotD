(defpackage cotd/websocket
  (:use #:cl)
  (:export #:start-server #:stop-server #:define-handlers-for-url #:send-msg #:broadcast-to-all-clients
           #:make-rw-lock #:with-write-lock #:with-read-lock))
