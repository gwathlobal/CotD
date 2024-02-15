(in-package :cotd)

(defparameter *rwlock* (cotd/websocket:make-rw-lock))
(defparameter *game-loop-thread* nil)
(defparameter *game-loop-cond-var* (bt2:make-condition-variable))

(defun str-to-keyword (string)
  (if (or (null string)
          (string= string ""))
      nil
      (intern (string-upcase string) '#:keyword)))

;; (defun process-game-loop ()
;;   (loop with l = (bt2:make-lock)
;;         with any-moved = nil
;;         do
;;            (alexandria:cswitch ((get-game-loop-state))
;;              (+game-loop-init+ (log:info "*game-loop-state* = +GAME-LOOP-INIT+, -> +GAME-LOOP-PLAYER-TURN+~%")
;;                                (setf any-moved nil)
;;                                (with-write-lock *rwlock*
;;                                  ;; TODO: solve issue when the player is null
;;                                  ;(update-visible-map *player*)
;;                                  ;(broadcast-game-state)
;;                                  ;(broadcast-player-turn-availability nil)
                                 
;;                                  ;; skip player turn if no player is available or player can not act
;;                                  (if (or (null *player*)
;;                                          ;(skip-turn-p *player*)
;;                                          )
;;                                      (set-game-loop-state +game-loop-init+ +game-loop-other-turn+)
;;                                      (set-game-loop-state +game-loop-init+ +game-loop-player-turn+))))
;;              (+game-loop-player-turn+ (bt2:with-lock-held (l)
;;                                         ;; player turn here, *game-loop-state* moves forward from client requests
;;                                         (loop while (= (get-game-loop-state) +game-loop-player-turn+)
;;                                               do
;;                                                  ;(broadcast-player-turn-availability t)
;;                                                  (bt2:condition-wait *game-loop-cond-var* l)
;;                                                  (setf any-moved t))))
;;              (+game-loop-other-turn+ (with-write-lock *rwlock*
;;                                        (log:info "*game-loop-state* = +GAME-LOOP-OTHER-TURN+~%")
;;                                        ;; do all AI here
;;                                        ;; (loop for mob-id in (mob-id-list *level*)
;;                                        ;;       for mob = (get-mob-by-id mob-id)
;;                                        ;;       when (and (not (eq mob *player*))
;;                                        ;;                 (not (skip-turn-p mob)))
;;                                        ;;       do
;;                                        ;;          (ai-function mob)
;;                                        ;;          (setf any-moved t)
;;                                        ;;          (broadcast-game-state))
;;                                        (log:info "*game-loop-state* +GAME-LOOP-OTHER-TURN+ -> +GAME-LOOP-FINALIZE-TURN+~%")
;;                                        (set-game-loop-state +game-loop-other-turn+ +game-loop-finalize-turn+)))
;;              (+game-loop-finalize-turn+ (with-write-lock *rwlock*
;;                                           (log:info "*game-loop-state* = +GAME-LOOP-FINALIZE-TURN+~%")
                                          
;;                                           (when (null any-moved)
;;                                             (log:info "Nobody can act any more, finalizing turn...")
;;                                             ;; (loop for mob-id in (mob-id-list *level*)
;;                                             ;;       for mob = (get-mob-by-id mob-id)
;;                                             ;;       do
;;                                             ;;          (incf (ap mob) +max-ap+))
;;                                             ;;(incf (cur-turn *level*))
;;                                             )
;;                                           (log:info "*game-loop-state* +GAME-LOOP-FINALIZE-TURN+ -> +GAME-LOOP-INIT-TURN+~%")
;;                                           (set-game-loop-state +game-loop-finalize-turn+ +game-loop-init+))))))

(defun process-request-faction-options (client parsed-msg)
  (let ((option (str-to-keyword (gethash :option parsed-msg))))
    (when (null option)
      (log:error "No option :option in parsed message.")
      (return-from process-request-faction-options))

    (flet ((quick-scenario-option-func ()
             (multiple-value-bind (quick-scenario-items quick-scenario-funcs quick-scenario-descrs)
                 (quick-scenario-menu-items)
               (declare (ignore quick-scenario-funcs))
               (let ((msg (yason:with-output-to-string* ()
                            (yason:with-object ()
                              (yason:encode-object-element :c :response-faction-options)
                              (yason:encode-object-element :menu-items quick-scenario-items)
                              (yason:encode-object-element :menu-descrs quick-scenario-descrs)))))
                 (cotd/websocket:send-msg client msg)))))
      
      (case option
        (:quick-scenario (quick-scenario-option-func))
        (t (log:warn "Unknown option ~A in :request-faction-option command." option))))))

(defun process-client-message (client message)
  (log:info "Raw msg received: " message)
  
  (let ((parsed-msg (yason:parse message)))
    (when (null parsed-msg)
      (log:error "Parsed message empty.")
      (return-from process-client-message))

    (let ((cmd (str-to-keyword (gethash :c parsed-msg)))
          (write-operation nil)
          (read-operation nil))
      (when (null cmd)
        (log:error "No command :c in parsed message.")
        (return-from process-client-message))
      
      (case cmd
        (:request-faction-options (setf read-operation (lambda () 
                                                         (process-request-faction-options client parsed-msg)))))
      (unless (null write-operation)
         (cotd/websocket:with-write-lock *rwlock*
        ;;   ;; the write lock was released in another thread, and this thread has acquired the lock
        ;;   ;; but we need to check that another thread has not moved the game loop forward
        ;;   ;(when (/= (get-game-loop-state) +game-loop-player-turn+)
        ;;   ;  (return-from process-client-message))
           (when (funcall write-operation)
        ;;     ;(update-visible-map *player*)
        ;;     ;(broadcast-game-state)
        ;;     ;(broadcast-player-turn-availability nil)
        ;;     ;(set-game-loop-state +game-loop-player-turn+ +game-loop-other-turn+)
        ;;     ;(bt2:condition-notify *game-loop-cond-var*)
             (log:info "*game-loop-state* +GAME-LOOP-PLAYER-TURN+ -> +GAME-LOOP-OTHER-TURN+~%")))
        (return-from process-client-message))

      (unless (null read-operation)
        (cotd/websocket:with-read-lock *rwlock*
          (funcall read-operation))
        (return-from process-client-message)))
    ))

(defun define-client-server-communication ()
  (define-handlers-for-url "/"
    :open (lambda (client)
            )
    :message (lambda (client message)
               (process-client-message client message)
               )))

(defun start-server ()
  "Starts a CotD websocket server."

  (setf yason:*parse-object-key-fn* #'str-to-keyword)
  (setf yason:*symbol-key-encoder* #'yason:encode-symbol-as-lowercase)
  (setf yason:*symbol-encoder* #'yason:encode-symbol-as-lowercase)

  ;(setf *level* (make-level))
  ;(set-terrain-* *level* 2 2 :terrain-wall)
  ;(set-terrain-* *level* 3 2 :terrain-wall)
  
  ;(adjust-array *mobs* 0)
  ;(let ((player (make-mob :mob-type-player)))
  ;  (setf (x player) 1 (y player) 1)
  ;  (setf *player* player)
  ;  (add-mob-to-level *level* *player*))
  
  ;(let ((mob (make-mob :mob-type-imp)))
  ;  (setf (x mob) 5 (y mob) 5)
  ;  (add-mob-to-level *level* mob))
  
  (setf *rwlock* (cotd/websocket:make-rw-lock))
  ;(reset-game-loop-state)
  
  (define-client-server-communication)
  
  ;(when (or (null *game-loop-thread*)
  ;          (not (bt2:thread-alive-p *game-loop-thread*)))
  ;  (setf *game-loop-thread* (bt2:make-thread #'process-game-loop :name "game loop thread")))
  (cotd/websocket:start-server 32167))

(defun stop-server ()
  "Stops CotD websocket server."
  
  ;(when (and (not (null *game-loop-thread*))
  ;           (bt2:thread-alive-p *game-loop-thread*))
  ;  (bt2:destroy-thread *game-loop-thread*))
  (cotd/websocket:stop-server))