(in-package :cotd-sdl)

(set-campaign-command :id :campaign-command-angel-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Do nothing and wait.")
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
                                      "Do nothing and wait.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 4
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
                                      "Do nothing and wait.")
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
                                      "Do nothing and wait.")
                      :faction-type +faction-type-church+
                      :disabled nil
                      :cd 5
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore world campaign-command))
                                         t
                                         )
                      )

(set-campaign-command :id :campaign-command-eater-wait
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Wait & see")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Do nothing and wait.")
                      :faction-type +faction-type-eater+
                      :disabled nil
                      :cd 7
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
                      :cd 6
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
                                                 (add-message (format nil ".~%") sdl:*white* message-box-list))
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
                      :cd 12
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
                                                 (add-message (format nil ".~%") sdl:*white* message-box-list))
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
                      :cd 5
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((corrupted-sectors 0))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                            (world-sector-corrupted-p world-sector))
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
                                                                    (world-sector-corrupted-p world-sector))
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
                                                            (world-sector-corrupted-p world-sector))
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

(set-campaign-command :id :campaign-command-demon-corrupt-portals
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Corrupt divine portals")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Invoke the rites from the Book of Rituals to make angels arrive delayed whenever they are present. The enchantment lasts as long as the demons control the Holy Relic.")
                      :faction-type +faction-type-demons+
                      :disabled nil
                      :cd 5
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((relic-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-item-holy-relic+ (items world-sector))
                                                            (world-sector-corrupted-p world-sector))
                                                   (setf relic-sector t)))))
                                           
                                           (if (and relic-sector
                                                    (null (find-campaign-effects-by-id world :campaign-effect-demon-corrupt-portals)))
                                             t
                                             nil))
                                         )
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-demon-corrupt-portals :cd nil)
                                                 ))

(set-campaign-command :id :campaign-command-military-reveal-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reveal a satanists' lair")
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
                                                            (world-sector-normal-p world-sector))
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
                                                                    (world-sector-normal-p world-sector))
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
                                                            (world-sector-normal-p world-sector))
                                                   (incf residential-sectors)))))
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) *world* military-win-cond)
                                             (declare (ignore satanist-lairs-left))
                                             (if (and (> residential-sectors 0)
                                                      (not (zerop (world/cur-military-num world)))
                                                      (> corrupted-sectors-left normal-sectors-left))
                                               t
                                               nil))))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world)))
                                                       (residential-sector-list ())
                                                       (selected-sector nil))
                                                   (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                                     (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                                       (let ((world-sector (aref (cells (world-map world)) x y)))
                                                         (when (and (eq (controlled-by world-sector) +lm-controlled-by-none+)
                                                                    (world-sector-normal-p world-sector))
                                                           (push (list x y) residential-sector-list)))))
                                                                                                      
                                                   (setf selected-sector (nth (random (length residential-sector-list)) residential-sector-list))
                                                   
                                                   (setf (controlled-by (aref (cells (world-map world)) (first selected-sector) (second selected-sector))) +lm-controlled-by-military+)
                                                   
                                                   (add-message (format nil "The military have deployed ") sdl:*white* message-box-list)
                                                   (add-message (format nil "a new army") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " in ") sdl:*white* message-box-list)
                                                   (add-message (format nil "~(~A~)" (name (aref (cells (world-map world)) (first selected-sector) (second selected-sector)))) sdl:*yellow* message-box-list)
                                                   (add-message (format nil ".~%") sdl:*white* message-box-list))))

(set-campaign-command :id :campaign-command-priest-delay-demons
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Pray to thicken the Barrier")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Pray to make the Barrier between the Hell and human world thicker for 5 turns. This shall make demons arrive 30 turns later when they arrive delayed.")
                      :faction-type +faction-type-church+
                      :disabled nil
                      :cd 6
                      :priority 0
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((church-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                                                            (world-sector-normal-p world-sector))
                                                   (setf church-sector t)))))
                                           
                                           (if (and church-sector
                                                    (null (find-campaign-effects-by-id world :campaign-effect-demon-delayed)))
                                             t
                                             nil)))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-demon-delayed :cd 5)))

(set-campaign-command :id :campaign-command-priest-hasten-angels
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Pray for divine intervention")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Pray to make angels arrive 30 turns earlier when the they arrive delayed. This effect lasts for 5 turns.")
                      :faction-type +faction-type-church+
                      :disabled nil
                      :cd 6
                      :priority 0
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let ((church-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                                                            (world-sector-normal-p world-sector))
                                                   (setf church-sector t)))))
                                           
                                           (if (and church-sector
                                                    (null (find-campaign-effects-by-id world :campaign-effect-angel-hastened)))
                                             t
                                             nil)))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-angel-hastened :cd 5)))

(set-campaign-command :id :campaign-command-eater-agitated
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Awaken Primordials")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Awaken Primordials to make the more present during missions.")
                      :faction-type +faction-type-military+
                      :disabled nil
                      :cd 9
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         (let* ((normal-sectors 0)
                                                (corrupted-sectors 0)
                                                (abandoned-sectors 0))
                                                
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (world-sector-normal-p world-sector)
                                                   (incf normal-sectors))
                                                 (when (world-sector-abandoned-p world-sector)
                                                   (incf abandoned-sectors))
                                                 (when (world-sector-corrupted-p world-sector)
                                                   (incf corrupted-sectors)))))
                                           (if (and (>= abandoned-sectors (+ corrupted-sectors normal-sectors))
                                                    (not (find-campaign-effects-by-id world :campaign-effect-eater-agitated)))
                                               t
                                               nil)))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (add-campaign-effect world :id :campaign-effect-eater-agitated :cd 5)))

(set-campaign-command :id :campaign-command-angel-reveal-lair
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Reveal a satanists' lair")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Shed divine light to allow humans instantly reveal the satanists' lair and make it vulnerable for attack.")
                      :faction-type +faction-type-angels+
                      :disabled nil
                      :cd 7
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         
                                         (let ((military-win-cond (get-win-condition-by-id :win-cond-military-campaign))
                                               (relic-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-item-holy-relic+ (items world-sector))
                                                            (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                                                            (world-sector-normal-p world-sector))
                                                   (setf relic-sector t)))))
                                           
                                           (multiple-value-bind (corrupted-sectors-left satanist-lairs-left) (funcall (win-condition/win-func military-win-cond) world military-win-cond)
                                             (declare (ignore corrupted-sectors-left))
                                             (if (and relic-sector
                                                      (not (zerop satanist-lairs-left))
                                                      (not (find-campaign-effects-by-id world :campaign-effect-satanist-lair-visible))
                                                      (< (world/random-number world) 15))
                                               t
                                               nil))))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                 (let ((message-box-list `(,(world/event-message-box world))))
                                                   (add-message (format nil "Angels have ") sdl:*white* message-box-list)
                                                   (add-message (format nil "revealed") sdl:*yellow* message-box-list)
                                                   (add-message (format nil " the place where the ") sdl:*white* message-box-list)
                                                   (add-message (format nil "satanists") sdl:*yellow* message-box-list)
                                                   (add-message (format nil "hide.~%") sdl:*white* message-box-list))
                                                 
                                                 (add-campaign-effect world :id :campaign-effect-satanist-lair-visible :cd 5)
                                                 (loop for campaign-effect in (find-campaign-effects-by-id world :campaign-effect-satanist-lair-hidden) do
                                                   (remove-campaign-effect world campaign-effect))
                                                 ))

(set-campaign-command :id :campaign-command-angel-divine-crusade
                      :name-func #'(lambda (world)
                                     (declare (ignore world))
                                     "Declare divine crusade")
                      :descr-func #'(lambda (world)
                                      (declare (ignore world))
                                      "Declare divine crusade to be able to initiate 1 more mission for 5 turns.")
                      :faction-type +faction-type-angels+
                      :disabled nil
                      :cd 9
                      :priority 1
                      :on-check-func #'(lambda (world campaign-command)
                                         (declare (ignore campaign-command))
                                         
                                         (let ((relic-sector nil))
                                           (loop for x from 0 below (array-dimension (cells (world-map world)) 0) do
                                             (loop for y from 0 below (array-dimension (cells (world-map world)) 1) do
                                               (let ((world-sector (aref (cells (world-map world)) x y)))
                                                 (when (and (find +lm-item-holy-relic+ (items world-sector))
                                                            (find +lm-feat-church+ (feats world-sector) :key #'(lambda (a) (first a)))
                                                            (world-sector-normal-p world-sector))
                                                   (setf relic-sector t)))))
                                           
                                           (if (and relic-sector
                                                    (not (find-campaign-effects-by-id world :campaign-effect-angel-crusade))
                                                    (> (world/random-number world) 85))
                                               t
                                               nil)))
                      :on-trigger-start-func #'(lambda (world campaign-command)
                                                 (declare (ignore campaign-command))
                                                                                                  
                                                 (add-campaign-effect world :id :campaign-effect-angel-crusade :cd 5)  
                                                 ))
