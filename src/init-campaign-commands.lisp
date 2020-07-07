(in-package :cotd)

(set-campaign-command :id :campaign-command-angel-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-angels+
                      :disabled nil
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      )

(set-campaign-command :id :campaign-command-demon-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      )

(set-campaign-command :id :campaign-command-military-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      )

(set-campaign-command :id :campaign-command-church-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Wait for 5 turns.")
                      :faction-type +faction-type-church+
                      :disabled nil
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      )

(set-campaign-command :id :campaign-command-satanist-sacrifice
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Sacrifice a citizen")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Find a new citizen and sacrifice them to give demons more opportunities to invade.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :cd 10
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (not (zerop satanist-lairs-left))
                                               t
                                               nil)))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-satanist-sacrifice :cd 5)
                                                 ))

(set-campaign-command :id :campaign-command-satanist-hide-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Hide a lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Increase the paranoia level of your fellow cultists to protect the lair from infiltration.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :cd 7
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and (not (zerop satanist-lairs-left))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible)))
                                               t
                                               nil)))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-satanist-lair-hidden :cd 5)
                                                 ))

(set-campaign-command :id :campaign-command-satanist-reform-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reform a satanist' lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Seduce willing undividuals to recreate the once destroyed satanist' lair.")
                      :faction-type +faction-type-satanists+
                      :disabled nil
                      :cd 12
                      :priority 10
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (zerop satanist-lairs-left)
                                               t
                                               nil))))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world))))
                                                   (add-message (format nil "There are whispers about ") sdl:*white* message-box-list)
                                                   (add-message (format nil "satanists reforming their hideout") sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list)))
                      :on-trigger-end-func #'(lambda (world campaign-command)
                                               (declare (ignore campaign-command))
                                               (place-satanist-lair-on-map (world-map world) 1)
                                               (let ((message-box-list `(,(world/event-message-box world))))
                                                 (add-message (format nil "The ") sdl:*white* message-box-list)
                                                 (add-message (format nil "satanists' lair") sdl:*yellow* message-box-list)
                                                 (add-message (format nil " has been ") sdl:*white* message-box-list)
                                                 (add-message (format nil "reformed") sdl:*yellow* message-box-list)
                                                 (add-message (format nil ".~%") sdl:*yellow* message-box-list))
                                               ))

(set-campaign-command :id :campaign-command-demon-rebuild-engine
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Rebuild a dimensional engine")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Rebuild a destroyed dimensional engine.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 15
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (if (not (zerop (world/machine-destroyed world)))
                                           t
                                           nil))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world))))
                                                   (add-message (format nil "There are whispers about ") sdl:*white* message-box-list)
                                                   (add-message (format nil "demons rebuilding") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " one of their ") sdl:*white* message-box-list)
                                                   (add-message (format nil "dimensional engines") sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list)))
                      :on-trigger-end-func #'(lambda (world campaign-command)
                                               (declare (ignore campaign-command))
                                               (decf (world/machine-destroyed world))
                                               (let ((message-box-list `(,(world/event-message-box world))))
                                                 (add-message (format nil "Demons have ") sdl:*white* message-box-list)
                                                 (add-message (format nil "rebuilt") sdl:*yellow* message-box-list)
                                                 (add-message (format nil " their ") sdl:*white* message-box-list)
                                                 (add-message (format nil "dimensional engine") sdl:*yellow* message-box-list)
                                                 (add-message (format nil ".~%") sdl:*yellow* message-box-list))
                                               ))

(set-campaign-command :id :campaign-command-demon-add-army
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Raise a demonic army")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "March a demonic army onto Earth to control one of the corrupted districts.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 6
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((corrupted-sectors 0))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                            (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                                (eq (wtype world-sector) :world-sector-corrupted-port)
                                                                (eq (wtype world-sector) :world-sector-corrupted-island)
                                                                (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                                (eq (wtype world-sector) :world-sector-corrupted-lake)))
                                                   (incf corrupted-sectors)))))
                                           
                                           (if (and (> corrupted-sectors 0)
                                                    (null (find-campaign-effects-by-id world :campaign-effect-demon-turmoil)))
                                             t
                                             nil))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world)))
                                                       (corrupted-sector-list ())
                                                       (selected-sector nil))
                                                   (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                     (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                       (let ((world-sector (aref (cells (world-map world)) x y)))
                                                         (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                                    (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                                        (eq (wtype world-sector) :world-sector-corrupted-port)
                                                                        (eq (wtype world-sector) :world-sector-corrupted-island)
                                                                        (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                                        (eq (wtype world-sector) :world-sector-corrupted-lake)))
                                                           (push (list x y) corrupted-sector-list)))))
                                                   
                                                   (setf selected-sector (nth (random (length corrupted-sector-list)) corrupted-sector-list))
                                                   
                                                   (setf (controlled-by (aref (cells (world-map world)) (first selected-sector) (second selected-sector))) +lm-controlled-by-demons+)
                                                   
                                                   (add-message (format nil "A ") sdl:*white* message-box-list)
                                                   (add-message (format nil "demon army") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " has entered ") sdl:*white* message-box-list)
                                                   (add-message (format nil "~(~A~)" (name (aref (cells (world-map world)) (first selected-sector) (second selected-sector)))) sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list)))
                      )

(set-campaign-command :id :campaign-command-demon-protect-dimension
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Protect the Hell Dimension")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Invoke the rites from the Book of Rituals to prevent anybody from entering the Hell Dimension. The enchantment lasts as long as the demons control the Book of Rituals.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 5
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((book-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-item-book-of-rituals+ (items world-sector))
                                                            (or (eq (wtype world-sector) :world-sector-corrupted-forest)
                                                                (eq (wtype world-sector) :world-sector-corrupted-port)
                                                                (eq (wtype world-sector) :world-sector-corrupted-island)
                                                                (eq (wtype world-sector) :world-sector-corrupted-residential)
                                                                (eq (wtype world-sector) :world-sector-corrupted-lake)))
                                                   (setf book-sector t)))))
                                           
                                           (if (and book-sector
                                                    (null (find-campaign-effects-by-id world :campaign-effect-demon-protect-dimension)))
                                             t
                                             nil))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-demon-protect-dimension :cd nil)
                                                 ))

(set-campaign-command :id :campaign-command-military-reveal-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reveal a satanist' lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Infiltrate the satanists' lair and make it vulnerable for attack.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :cd 6
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign)))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and (not (zerop satanist-lairs-left))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-hidden)))
                                               t
                                               nil))))
                      :on-trigger-end-func #'(lambda (world campaign-command)
                                               (declare (ignore campaign-command))
                                               (add-campaign-effect world :id :campaign-effect-satanist-lair-visible :cd 5)  
                                               ))

(set-campaign-command :id :campaign-command-military-reform-army
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reform an army")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Recruit new soldiers to recreate a previously destroyed army.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :cd 6
                      :priority 10
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((residential-sectors 0))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                            (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                                (eq (wtype world-sector) :world-sector-normal-port)
                                                                (eq (wtype world-sector) :world-sector-normal-island)
                                                                (eq (wtype world-sector) :world-sector-normal-residential)
                                                                (eq (wtype world-sector) :world-sector-normal-lake)))
                                                   (incf residential-sectors)))))
                                           
                                           (if (and (> residential-sectors 0)
                                                    (zerop (world/cur-military-num world)))
                                             t
                                             nil))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world)))
                                                       (residential-sector-list ())
                                                       (selected-sector nil))
                                                   (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                     (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                       (let ((world-sector (aref (cells (world-map world)) x y)))
                                                         (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                                    (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                                (eq (wtype world-sector) :world-sector-normal-port)
                                                                (eq (wtype world-sector) :world-sector-normal-island)
                                                                (eq (wtype world-sector) :world-sector-normal-residential)
                                                                (eq (wtype world-sector) :world-sector-normal-lake)))
                                                           (push (list x y) residential-sector-list)))))
                                                                                                      
                                                   (setf selected-sector (nth (random (length residential-sector-list)) residential-sector-list))
                                                   
                                                   (setf (controlled-by (aref (cells (world-map world)) (first selected-sector) (second selected-sector))) +lm-controlled-by-military+)
                                                   
                                                   (add-message (format nil "The military have drafted ") sdl:*white* message-box-list)
                                                   (add-message (format nil "a new army") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " in ") sdl:*white* message-box-list)
                                                   (add-message (format nil "~(~A~)" (name (aref (cells (world-map world)) (first selected-sector) (second selected-sector)))) sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list)))
                      )

(set-campaign-command :id :campaign-command-military-add-army
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Call for a new army")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Reinforce the military with an additional army deployed in one of the inhabited districts.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :cd 7
                      :priority 2
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((residential-sectors 0)
                                                (demon-win-cond (get-win-condition-by-id :win-cond-demon-campaign))
                                                (military-win-cond (get-win-condition-by-id :win-cond-military-campaign))
                                                (normal-sectors-left (funcall (win-condition/win-func demon-win-cond) *world* demon-win-cond)))
                                                
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                            (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                                (eq (wtype world-sector) :world-sector-normal-port)
                                                                (eq (wtype world-sector) :world-sector-normal-island)
                                                                (eq (wtype world-sector) :world-sector-normal-residential)
                                                                (eq (wtype world-sector) :world-sector-normal-lake)))
                                                   (incf residential-sectors)))))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) *world* military-win-cond)
                                             (declare (ignore satanist-lairs-left))
                                             (if (and (> residential-sectors 0)
                                                      (not (zerop (world/cur-military-num world)))
                                                      (> corrupted-sectors-left normal-sectors-left))
                                               t
                                               nil)))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world)))
                                                       (residential-sector-list ())
                                                       (selected-sector nil))
                                                   (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                     (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                       (let ((world-sector (aref (cells (world-map world)) x y)))
                                                         (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                                    (or (eq (wtype world-sector) :world-sector-normal-forest)
                                                                (eq (wtype world-sector) :world-sector-normal-port)
                                                                (eq (wtype world-sector) :world-sector-normal-island)
                                                                (eq (wtype world-sector) :world-sector-normal-residential)
                                                                (eq (wtype world-sector) :world-sector-normal-lake)))
                                                           (push (list x y) residential-sector-list)))))
                                                                                                      
                                                   (setf selected-sector (nth (random (length residential-sector-list)) residential-sector-list))
                                                   
                                                   (setf (controlled-by (aref (cells (world-map world)) (first selected-sector) (second selected-sector))) +lm-controlled-by-military+)
                                                   
                                                   (add-message (format nil "The military have deployed ") sdl:*white* message-box-list)
                                                   (add-message (format nil "a new army") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " in ") sdl:*white* message-box-list)
                                                   (add-message (format nil "~(~A~)" (name (aref (cells (world-map world)) (first selected-sector) (second selected-sector)))) sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list)))
                      )
