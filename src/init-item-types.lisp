(in-package :cotd)

(set-item-type (make-instance 'item-type :id +item-type-body-part-limb+
                                         :name "body part" :plural-name "body parts"
                                         :flavor-quote (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 1))

(set-item-type (make-instance 'item-type :id +item-type-body-part-half+
                                         :name "body part" :plural-name "body parts"
                                         :flavor-quote (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 2))

(set-item-type (make-instance 'item-type :id +item-type-body-part-body+
                                         :name "body part" :plural-name "body parts"
                                         :flavor-quote (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 3))

(set-item-type (make-instance 'item-type :id +item-type-body-part-full+
                                         :name "body part" :plural-name "body parts"
                                         :flavor-quote (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 4))

(set-item-type (make-instance 'item-type :id +item-type-coin+
                                         :name "coin" :plural-name "coins"
                                         :flavor-quote (format nil "\"I have money and so I can do whatever I like; I have money and so I will not perish and will not have to ask help from anyone; not having to ask for anyone's help is the highest freedom. Yet in essence this is not freedom but slavery once again, a slavery that comes from money.\"~%Fyodor Dostoevsky. A Writer's Diary.")
                                         :glyph-idx 4 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 10000 :value 1))

(set-item-type (make-instance 'item-type :id +item-type-medkit+
                                         :name "medkit" :plural-name "medkits"
                                         :descr "A medkit that can heal 3-5 HP. Usable by humans only. Unusable underwater."
                                         :flavor-quote (format nil "\"There was a large wound in his stomach. The King washed it as best he could, and bandaged it with his handkerchief and with a towel the hermit had. But the blood would not stop flowing, and the King again and again removed the bandage soaked with warm blood, and washed and rebandaged the wound. When at last the blood ceased flowing, the man revived and asked for something to drink.\"~%Leo Tolstoy. Three Questions.")
                                         :glyph-idx 1 :glyph-color sdl:*green* :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item target))
                                                     (let ((heal-pwr (+ 3 (random 3))))
                                                       (when (> (+ (cur-hp actor) heal-pwr)
                                                                (max-hp actor))
                                                         (setf heal-pwr (- (max-hp actor) (cur-hp actor))))
                                                       (incf (cur-hp actor) heal-pwr)
                                                                                                              
                                                       (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                                  (format nil "You hear some rustling sounds~A. " str)))
                                                       
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                              (format nil "~A uses a medkit to heal itself for ~A. " (capitalize-name (visible-name actor)) heal-pwr)))
                                                     ;; remove after use
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                       (mob-ability-p actor +mob-abil-human+))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   (or (and nearest-enemy
                                                                            (< (/ (cur-hp actor) (max-hp actor)) 
                                                                               0.7))
                                                                       (and (not nearest-enemy)
                                                                            (< (/ (cur-hp actor) (max-hp actor)) 
                                                                               0.5))))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-enemy nearest-ally check-result))
                                                             (mob-use-item actor nil item))))

(set-item-type (make-instance 'item-type :id +item-type-smoke-bomb+
                                         :name "smoke bomb" :plural-name "smoke bombs"
                                         :descr "A bomb that emits clouds of smoke to conceal you. Usable only by humans. Can not be used in water."
                                         :flavor-quote (format nil "\"All smoke and steam, he thought; all seems for ever changing, on all sides new forms, phantoms flying after phantoms, while in reality it is all the same and the same again; everything hurrying, flying towards something, and everything vanishing without a trace, attaining to nothing; another wind blows, and all is dashing in the opposite direction, and there again the same untiring, restless - and useless gambols!\"~%Ivan Turgenev. Smoke.")
                                         :glyph-idx 1 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore target item))
                                                     (when (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                       (let ((cell-list (list '(-1 -1 1) '(-1 0 1) '(-1 1 1) '(0 -1 1) '(0 0 1) '(0 1 1) '(1 -1 1) '(1 0 1) '(1 1 1)
                                                                              '(-1 -1 0) '(-1 0 0) '(-1 1 0) '(0 -1 0) '(0 0 0) '(0 1 0) '(1 -1 0) '(1 0 0) '(1 1 0)
                                                                              '(-1 -1 -1) '(-1 0 -1) '(-1 1 -1) '(0 -1 -1) '(0 0 -1) '(0 1 -1) '(1 -1 -1) '(1 0 -1) '(1 1 -1))))
                                                         (loop for cell in cell-list
                                                               for x = (+ (first cell) (x actor))
                                                               for y = (+ (second cell) (y actor))
                                                               for z = (+ (third cell) (z actor))
                                                               do
                                                                  (when (and (>= x 0) (>= y 0) (>= z 0)
                                                                             (< x (array-dimension (terrain (level *world*)) 0)) (< y (array-dimension (terrain (level *world*)) 1)) (< z (array-dimension (terrain (level *world*)) 2))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-projectiles+))
                                                                             (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-water+))
                                                                             (or (= (third cell) 0)
                                                                                 (and (> (third cell) 0)
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-opaque-floor+)))
                                                                                 (and (< (third cell) 0)
                                                                                      (not (get-terrain-type-trait (get-terrain-* (level *world*) x y (z actor)) +terrain-trait-opaque-floor+)))))
                                                                    
                                                                    (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-smoke-thick+ :x x :y y :z z :counter 4))))
                                                         
                                                         (generate-sound actor (x actor) (y actor) (z actor) 30 #'(lambda (str)
                                                                                                                    (format nil "You hear some hiss~A. " str)))
                                                         
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A uses a smoke bomb. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))))))
                                                     ;; remove after use
                                                     t)
                                         :on-check-applic (lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                       (mob-ability-p actor +mob-abil-human+))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   (not (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) (z actor)) +terrain-trait-water+))
                                                                   nearest-enemy
                                                                   (< (/ (cur-hp actor) (max-hp actor)) 
                                                                      0.4)
                                                                   (not (find +feature-smoke-thick+ (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                              :key #'(lambda (a)
                                                                                       (feature-type (get-feature-by-id a)))))
                                                                   (not (find +feature-smoke-thin+ (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                               :key #'(lambda (a)
                                                                                       (feature-type (get-feature-by-id a))))))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-enemy nearest-ally check-result))
                                                             (mob-use-item actor nil item))))

(set-item-type (make-instance 'item-type :id +item-type-clothing+
                                         :name "civilian costume" :plural-name "civilian costumes"
                                         :flavor-quote (format nil "\"And what fine eyes he has, and how fine his whole face is!.. He is even better looking than Dounia... But, good heavens, what a suit - how terribly he's dressed! ... Vasya, the messenger boy in Afanasy Ivanitch's shop, is better dressed!\"~%Fyodor Dostoevsky. Crime and Punishment.")
                                         :glyph-idx 59 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 10 :value 5))

(set-item-type (make-instance 'item-type :id +item-type-disguise+
                                         :name "disguise" :plural-name "disguises"
                                         :descr "A special kit that lets you disguise yourself as an ordinary man or woman. Usable by humans and Malseraph's puppets only."
                                         :flavor-quote (format nil "\"The door opened and a masked corpulent stocky man, wearing a coachman's suit and a hat with peackock's feathers, entered the reading room. He was followed by two masked ladies and a servant holding a tray. On the tray, there stood a bellied bottle of liqueur, three bottles of red wine and several glasses.\"~%Anton Checkov. The Mask.")
                                         :glyph-idx 59 :glyph-color (sdl:color :r 100 :g 100 :b 100) :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore target item))
                                                     
                                                     (invoke-disguise actor)
                                                     ;; remove after use
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                            (declare (ignore item))
                                                            (if (and (not (mob-effect-p actor +mob-effect-disguised+))
                                                                     (or (mob-ability-p actor +mob-abil-human+)
                                                                         (= (mob-type actor) +mob-type-malseraph-puppet+)))
                                                              t
                                                              nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   (not nearest-enemy))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-enemy nearest-ally check-result))
                                                             (mob-use-item actor nil item))))

(set-item-type (make-instance 'item-type :id +item-type-deck-of-war+
                                         :name "deck of war" :plural-name "decks of war"
                                         :descr "A special deck of cards granted by Malseraph, the Demon God of Acting, Gambling and Violent Changes. The deck contains a random number of different cards, all devouted to combat and fighting. Each card has a special effect that will benefit those who use it."
                                         :flavor-quote (format nil "\"As for cards, there was no habit to play cards in those circles (mainly literary ones) where Fyodor Mikhailovich used to move. During our 14 years of marriage, my husband played preferans only once, at my relatives' place; and though he had not touched a card for more than 10 years, he played perfectly and even managed to win several roubles from his partners which embarrassed him greatly.\"~%Anna Dostoevskaya. Dostoevsky: Reminiscences.")
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1
                                         :abil-card (list +item-card-curse-other+ +item-card-blindness-other+ +item-card-fear-other+ +item-card-slow-other+ +item-card-silence-other+ +item-card-confuse-other+
                                                          +item-card-polymorph-other+ +item-card-irradiate-other+ +item-card-lignify-other+)
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore target))
                                                     (when (cards item)
                                                       (let ((card-type-id))
                                                         (setf card-type-id (pop (cards item)))
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A draws the ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                        (name (get-card-type-by-id card-type-id))))
                                                         (funcall (on-use (get-card-type-by-id card-type-id)) (get-card-type-by-id card-type-id) actor))
                                                       )

                                                     ;; remove if there are no cards in the deck
                                                     (if (cards item)
                                                       nil
                                                       t)
                                                     )
                                         :on-check-applic #'(lambda (actor item)
                                                            (declare (ignore actor))
                                                              (if (cards item)
                                                       t
                                                       nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   nearest-enemy
                                                                  (or (< (/ (cur-hp actor) (max-hp actor)) 
                                                                         0.5)
                                                                      (> (strength nearest-enemy) (strength actor))))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-enemy nearest-ally check-result))
                                                             (mob-use-item actor nil item))))

(set-item-type (make-instance 'item-type :id +item-type-deck-of-escape+
                                         :name "deck of escape" :plural-name "decks of escape"
                                         :descr "A special deck of cards granted by Malseraph, the Demon God of Acting, Gambling and Violent Changes. The deck contains a random number of different cards, all devouted to escapes and trickery. Each card has a special effect that will benefit those who use it."
                                         :flavor-quote (format nil "\"As for cards, there was no habit to play cards in those circles (mainly literary ones) where Fyodor Mikhailovich used to move. During our 14 years of marriage, my husband played preferans only once, at my relatives' place; and though he had not touched a card for more than 10 years, he played perfectly and even managed to win several roubles from his partners which embarrassed him greatly.\"~%Anna Dostoevskaya. Dostoevsky: Reminiscences.")
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1
                                         :abil-card (list +item-card-blink+ +item-card-teleport+ +item-card-sprint+ +item-card-flying+ +item-card-disguise+)
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore target))
                                                     (when (cards item)
                                                       (let ((card-type-id))
                                                         (setf card-type-id (pop (cards item)))
                                                         (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                                (format nil "~A draws the ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                        (name (get-card-type-by-id card-type-id))))
                                                         (funcall (on-use (get-card-type-by-id card-type-id)) (get-card-type-by-id card-type-id) actor)))

                                                     ;; remove if there are no cards in the deck
                                                     (if (cards item)
                                                       nil
                                                       t)
                                                     )
                                         :on-check-applic #'(lambda (actor item)
                                                            (declare (ignore actor))
                                                              (if (cards item)
                                                                t
                                                              nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   nearest-enemy
                                                                  (or (< (/ (cur-hp actor) (max-hp actor)) 
                                                                         0.5)
                                                                      (> (strength nearest-enemy) (strength actor))))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-enemy nearest-ally check-result))
                                                             (mob-use-item actor nil item))))

(set-item-type (make-instance 'item-type :id +item-type-eater-parasite+
                                         :name "parasite" :plural-name "parasites"
                                         :glyph-idx 1 :glyph-color sdl:*green* :back-color sdl:*black* :max-stack-num 1000
                                         :descr "A living itching creature that can be thrown by the Eater of the dead onto an enemy. A parasited character will have its direct resistances against flesh and acid reduced by 1, as well as always reveal its location to the primordial. Usable by primordials only."
                              :flavor-quote (format nil "\"The neckerchief around the baron's neck was no less remarkable. It was a phenomenon, though, for hygienic and aesthetic purposes, the neckerchief should have been replaced with a more durable and less soiled one. It was made from the remains of the great cape that Ernesto Rossi had donned when conversing with witches in \"Makbeth\". \"My neckerchief smells of King Duncan's blood!\" often said the old baron while looking for parasites in it.\"~%Anton Chekhov. The Baron.")
                                         :start-map-select-func #'player-start-map-select-nearest-hostile
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A throws a parasite onto ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                    (prepend-article +article-the+ (visible-name target))))
                                                     (set-mob-effect target :effect-type-id +mob-effect-parasite+ :actor-id (id actor) :cd 99)
                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                            (declare (ignore item))
                                                              (if (and (mob-ability-p actor +mob-abil-primordial+))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   nearest-enemy
                                                                   (not (mob-effect-p nearest-enemy +mob-effect-parasite+))
                                                                   (> (get-distance-3d (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 4)
                                                                   (let ((tx 0) (ty 0) (tz 0)
                                                                         (ex (x nearest-enemy)) (ey (y nearest-enemy)) (ez (z nearest-enemy)))
                                                                     (declare (type fixnum tx ty tz ex ey ez))
                                                                     (line-of-sight (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)
                                                                                    #'(lambda (dx dy dz prev-cell)
                                                                                        (declare (type fixnum dx dy dz))
                                                                                        (let ((exit-result t))
                                                                                          (block nil
                                                                                            (setf tx dx ty dy tz dz)
                                                                                            
                                                                                            (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                              (setf exit-result 'exit)
                                                                                              (return))
                                                                                            
                                                                                            )
                                                                                          exit-result)))
                                                                     (if (and (= tx ex)
                                                                              (= ty ey)
                                                                              (= tz ez))
                                                                       t
                                                                       nil)))
                                                            t
                                                            nil))
                                         :map-select-func #'(lambda (item)
                                                              (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                                (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                         mob
                                                                         (<= (get-distance-3d (x *player*) (y *player*) (z *player*) (x mob) (y mob) (z mob)) 8)
                                                                         (find (id mob) (visible-mobs *player*))
                                                                         (let ((tx 0) (ty 0) (tz 0)
                                                                               (ex (x mob)) (ey (y mob)) (ez (z mob)))
                                                                           (declare (type fixnum tx ty tz ex ey ez))
                                                                           (line-of-sight (x *player*) (y *player*) (z *player*) (x mob) (y mob) (z mob)
                                                                                          #'(lambda (dx dy dz prev-cell)
                                                                                              (declare (type fixnum dx dy dz))
                                                                                              (let ((exit-result t))
                                                                                                (block nil
                                                                                                  (setf tx dx ty dy tz dz)
                                                                                                  
                                                                                                  (unless (check-LOS-propagate dx dy dz prev-cell :check-projectile t)
                                                                                                    (setf exit-result 'exit)
                                                                                                    (return))
                                                                                                  
                                                                                                  )
                                                                                                exit-result)))
                                                                           (if (and (= tx ex)
                                                                                    (= ty ey)
                                                                                    (= tz ez))
                                                                             t
                                                                             nil)))
                                                                  (progn
                                                                    (clear-message-list *small-message-box*)
                                                                    (mob-use-item *player* mob item)
                                                                    t)
                                                                  (progn
                                                                    nil))))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally check-result))
                                                             (mob-use-item actor nearest-enemy item))))

(set-item-type (make-instance 'item-type :id +item-type-signal-flare+
                                         :name "signal flare" :plural-name "signal flares"
                                         :descr "A flare that gives a signal for the artillery to strike at the selected location. The flare may be used only by humans and only if there are no obstacles above you up to the highest Z level."
                                         :flavor-quote (format nil "\"In one place, a lightning struck a tree and burned it - and thus came fire. In another place, people dropped hay and it burned - and thus came fire. In a third place, trees rubbed its branches against each other - and caught fire. In a fourth place, iron struck against a rock - and sparkled fire.\"~%Leo Tolstoy. Where Did Fire Come From When People Knew No Fire.")
                                         :glyph-idx 1 :glyph-color sdl:*red* :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     (let ((x (+ (first target) (- (random 3) 1)))
                                                           (y (+ (second target) (- (random 3) 1))))

                                                       (loop with final-z = (third target)
                                                             for z from (1- (array-dimension (terrain (level *world*)) 2)) downto final-z
                                                             when (and (get-terrain-* (level *world*) x y z)
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+))
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-opaque-floor+))
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-projectiles+))
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-water+)))
                                                               do
                                                                  (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-smoke-flare+ :x x :y y :z z :counter 2))
                                                             when (and (get-terrain-* (level *world*) x y z)
                                                                       (or (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-opaque-floor+)))
                                                               do
                                                                  (loop-finish)
                                                             when (and (get-terrain-* (level *world*) x y z)
                                                                       (or (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-move+)
                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-blocks-projectiles+)
                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) x y z) +terrain-trait-water+)))
                                                               do
                                                                  (incf z)
                                                                  (loop-finish)
                                                             
                                                             finally
                                                                (when (< z (array-dimension (terrain (level *world*)) 2))
                                                                  (add-feature-to-level-list (level *world*) (make-instance 'feature :feature-type +feature-smoke-flare-final+ :x x :y y :z z :counter 2 :param1 (id actor)))))
                                                       
                                                       (generate-sound actor (x actor) (y actor) (z actor) 40 #'(lambda (str)
                                                                                                                  (format nil "You hear someone shooting~A. " str)))
                                                       
                                                       (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                              (format nil "~A uses a flare. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))))
                                                     
                                                     ;; remove after use
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (mob-ability-p actor +mob-abil-human+)
                                                                       (loop for z from (1+ (z actor)) below (array-dimension (terrain (level *world*)) 2)
                                                                             with clear-path = t
                                                                             when (and (get-terrain-* (level *world*) (x actor) (y actor) z)
                                                                                       (or (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-blocks-move+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-opaque-floor+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-blocks-projectiles+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x actor) (y actor) z) +terrain-trait-water+)))
                                                                               do
                                                                                  (setf clear-path nil)
                                                                                  (loop-finish)
                                                                             finally (return clear-path)))
                                                                t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   nearest-enemy
                                                                   (> (strength nearest-enemy) (* 2 (strength actor)))
                                                                   (< (get-distance-3d (x *player*) (y *player*) (z *player*) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 9)
                                                                   (loop for z from (1- (array-dimension (terrain (level *world*)) 2)) downto (1+ (z nearest-enemy))
                                                                             with clear-path = t
                                                                             when (and (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z)
                                                                                       (or (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-blocks-move+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-opaque-floor+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-blocks-projectiles+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (x nearest-enemy) (y nearest-enemy) z) +terrain-trait-water+)))
                                                                               do
                                                                                  (setf clear-path nil)
                                                                                  (loop-finish)
                                                                             finally (return clear-path)))
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally check-result))
                                                             (mob-use-item actor (list (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) item))
                                         :map-select-func #'(lambda (item)
                                                              (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 9)
                                                                       (loop for z from (1- (array-dimension (terrain (level *world*)) 2)) downto (1+ (view-z *player*))
                                                                             with clear-path = t
                                                                             when (and (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))
                                                                                       (or (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-blocks-move+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-opaque-floor+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-blocks-projectiles+)
                                                                                           (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) z) +terrain-trait-water+)))
                                                                               do
                                                                                  (setf clear-path nil)
                                                                                  (loop-finish)
                                                                             finally (return clear-path)))
                                                                (progn
                                                                  (clear-message-list *small-message-box*)
                                                                  (mob-use-item *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) item)
                                                                  t)
                                                                (progn
                                                                  nil)))))

(set-item-type (make-instance 'item-type :id +item-type-eater-scarab-egg+
                                         :name "scarab egg" :plural-name "scarab eggs"
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1000
                                         :descr "An egg that can quickly develop into a full-grown creature that will move to the target and explode splashing acid around. Usable by primordials only."
                                         :flavor-quote (format nil "\"Tappity-tappity-tappity,\" went one egg, then another, in the first chamber. In fact, this on-the-spot spectacle of new life being born in a thin shining shell was so intriguing that they all sat for a long time on the upturned empty crates, watching the crimson eggs mature in the mysterious glimmering light.\"~%Mikhail Bulgakov. The Fatal Eggs.")
                                         :start-map-select-func #'player-start-map-select-nearest-hostile
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*) 
                                                                            (format nil "~A spawns a scarab and sets it on ~A. " (capitalize-name (prepend-article +article-the+ (visible-name actor)))
                                                                                    (prepend-article +article-the+ (visible-name target))))
                                                     (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                (format nil "You hear some burping~A. " str)))
                                                     
                                                     (let ((scarab-mob) (final-cell))
                                                       (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                       (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                         (when (and terrain
                                                                                                                    (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                    (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                    (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                           (when (null final-cell)
                                                                                                             (setf final-cell (list dx dy (z actor))))
                                                                                                           (when (< (get-distance-3d dx dy (z actor) (x target) (y target) (z target))
                                                                                                                    (get-distance-3d (first final-cell) (second final-cell) (third final-cell)
                                                                                                                                     (x target) (y target) (z target)))
                                                                                                             (setf final-cell (list dx dy (z actor))))))))
                                                       (when final-cell
                                                         (if (mob-ability-p actor +mob-abil-fast-scarabs+)
                                                           (setf scarab-mob (make-instance 'mob :mob-type +mob-type-fast-scarab+ :x (first final-cell) :y (second final-cell) :z (third final-cell)))
                                                           (setf scarab-mob (make-instance 'mob :mob-type +mob-type-scarab+ :x (first final-cell) :y (second final-cell) :z (third final-cell))))
                                                         (setf (order scarab-mob) (list +mob-order-target+ (id target)))
                                                         (add-mob-to-level-list (level *world*) scarab-mob)))
                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (let ((empty-cell nil))
                                                                (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                                (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                                  (when (and terrain
                                                                                                                             (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                             (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                             (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                                    (setf empty-cell t)))))
                                                                (if (and (mob-ability-p actor +mob-abil-primordial+)
                                                                         empty-cell)
                                                                  t
                                                                  nil)))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   nearest-enemy
                                                                   (>= (get-distance-3d (x actor) (y actor) (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy)) 2))
                                                            t
                                                            nil))
                                         :map-select-func #'(lambda (item)
                                                              (let ((mob (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*))))
                                                                (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                         mob
                                                                         (not (eq mob *player*))
                                                                         (find (id mob) (visible-mobs *player*))
                                                                         (< (get-distance-3d (x *player*) (y *player*) (z *player*) (x mob) (y mob) (z mob)) 7))
                                                                  (progn
                                                                    (clear-message-list *small-message-box*)
                                                                    (mob-use-item *player* mob item)
                                                                    t)
                                                                  (progn
                                                                    nil))))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally check-result))
                                                             (mob-use-item actor nearest-enemy item))))

(set-item-type (make-instance 'item-type :id +item-type-eater-locust-egg+
                                         :name "locust egg" :plural-name "locust eggs"
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1000
                                         :descr "An egg that can spawn a locust next to you. The locust is a small short-lived creature that will attack all enemies in sight until it dies. Usable by primordials only."
                                         :flavor-quote (format nil "\"Tappity-tappity-tappity,\" went one egg, then another, in the first chamber. In fact, this on-the-spot spectacle of new life being born in a thin shining shell was so intriguing that they all sat for a long time on the upturned empty crates, watching the crimson eggs mature in the mysterious glimmering light.\"~%Mikhail Bulgakov. The Fatal Eggs.")
                                         :start-map-select-func #'player-start-map-select-self
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     ;; target is (x y z)
                                                     (logger (format nil "ITEM-SPAWN-LOCUST: ~A [~A] spawns a locust at (~A ~A ~A).~%" (name actor) (id actor) (first target) (second target) (third target)))
                                                     ;; target here is the item to be reanimated
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                            (format nil "One of the orifices of ~A spawns a small, but repulsive creature. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                            :observed-mob actor)
                                                     (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                (format nil "You hear some burping~A. " str)))
                                                     (let ((locust-mob))
                                                       (if (mob-ability-p actor +mob-abil-acid-locusts+)
                                                         (setf locust-mob (make-instance 'mob :mob-type +mob-type-acid-locust+ :x (first target) :y (second target) :z (third target)))
                                                         (setf locust-mob (make-instance 'mob :mob-type +mob-type-locust+ :x (first target) :y (second target) :z (third target))))
                                                       (if (mob-ability-p actor +mob-abil-tougher-locusts+)
                                                         (progn
                                                           (setf (cur-hp locust-mob) 14)
                                                           (setf (max-hp locust-mob) 14)
                                                           (set-mob-effect locust-mob :effect-type-id +mob-effect-mortality+ :actor-id (id locust-mob) :cd 15))
                                                         (set-mob-effect locust-mob :effect-type-id +mob-effect-mortality+ :actor-id (id locust-mob) :cd 10))
                                                       (add-mob-to-level-list (level *world*) locust-mob))
                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (mob-ability-p actor +mob-abil-primordial+)
                                                                  t
                                                                  nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (let ((final-cell nil))
                                                            (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                            (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                              (when (and terrain
                                                                                                                         (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                         (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                         (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                                (when (null final-cell)
                                                                                                                  (setf final-cell (list dx dy (z actor))))
                                                                                                                (when (and nearest-enemy
                                                                                                                           (< (get-distance-3d dx dy (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))
                                                                                                                              (get-distance-3d (first final-cell) (second final-cell) (third final-cell)
                                                                                                                                               (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))))
                                                                                                                  (setf final-cell (list dx dy (z actor))))))))
                                                            (if (and (funcall (on-check-applic item) actor item)
                                                                     nearest-enemy
                                                                     final-cell)
                                                              final-cell
                                                              nil)))
                                         :map-select-func #'(lambda (item)
                                                              (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 2)
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +terrain-trait-blocks-move+)))
                                                                (progn
                                                                  (clear-message-list *small-message-box*)
                                                                  (mob-use-item *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) item)
                                                                  t)
                                                                (progn
                                                                  nil)))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally nearest-enemy))
                                                             (mob-use-item actor check-result item))))

(set-item-type (make-instance 'item-type :id +item-type-eater-larva-egg+
                                         :name "seeker larva egg" :plural-name "seeker larva eggs"
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1000
                                         :descr "An egg that can spawn a larva next to you. The larva is a small fragile creature that will eat corpses and collect their power for you. Usable by primordials only."
                                         :flavor-quote (format nil "\"Tappity-tappity-tappity,\" went one egg, then another, in the first chamber. In fact, this on-the-spot spectacle of new life being born in a thin shining shell was so intriguing that they all sat for a long time on the upturned empty crates, watching the crimson eggs mature in the mysterious glimmering light.\"~%Mikhail Bulgakov. The Fatal Eggs.")
                                         :start-map-select-func #'player-start-map-select-self
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     ;; target is (x y z)
                                                     (logger (format nil "ITEM-SPAWN-LARVA: ~A [~A] spawns a larva at (~A ~A ~A).~%" (name actor) (id actor) (first target) (second target) (third target)))
                                                     ;; target here is the item to be reanimated
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                            (format nil "One of the orifices of ~A spawns a small harmless creature. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                            :observed-mob actor)
                                                     (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                (format nil "You hear some burping~A. " str)))
                                                     (let ((larva-mob))
                                                       (setf larva-mob (make-instance 'mob :mob-type +mob-type-seeker-larva+ :x (first target) :y (second target) :z (third target)))
                                                       (set-mob-effect larva-mob :effect-type-id +mob-effect-primordial-transfer+ :actor-id (id actor) :cd t)
                                                       (add-mob-to-level-list (level *world*) larva-mob))
                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (mob-ability-p actor +mob-abil-primordial+)
                                                                  t
                                                                  nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (let ((final-cell nil))
                                                            (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                            (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                              (when (and terrain
                                                                                                                         (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                         (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                         (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                                (when (null final-cell)
                                                                                                                  (setf final-cell (list dx dy (z actor))))
                                                                                                                (when (and nearest-enemy
                                                                                                                           (< (get-distance-3d dx dy (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))
                                                                                                                              (get-distance-3d (first final-cell) (second final-cell) (third final-cell)
                                                                                                                                               (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))))
                                                                                                                  (setf final-cell (list dx dy (z actor))))))))
                                                            (if (and (funcall (on-check-applic item) actor item)
                                                                     nearest-enemy
                                                                     final-cell)
                                                              final-cell
                                                              nil)))
                                         :map-select-func #'(lambda (item)
                                                              (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 2)
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +terrain-trait-blocks-move+)))
                                                                (progn
                                                                  (clear-message-list *small-message-box*)
                                                                  (mob-use-item *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) item)
                                                                  t)
                                                                (progn
                                                                  nil)))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally nearest-enemy))
                                                             (mob-use-item actor check-result item))))

(set-item-type (make-instance 'item-type :id +item-type-eater-colony-egg+
                                         :name "spore colony egg" :plural-name "spore colony eggs"
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1000
                                         :descr "An egg that can spawn a spore colony next to you. The colony is large immobile creature that spits acid at the enemies of the primordial's in sight. Usable by primordials only."
                                         :flavor-quote (format nil "\"Tappity-tappity-tappity,\" went one egg, then another, in the first chamber. In fact, this on-the-spot spectacle of new life being born in a thin shining shell was so intriguing that they all sat for a long time on the upturned empty crates, watching the crimson eggs mature in the mysterious glimmering light.\"~%Mikhail Bulgakov. The Fatal Eggs.")
                                         :start-map-select-func #'player-start-map-select-self
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore item))
                                                     ;; target is (x y z)
                                                     (logger (format nil "ITEM-SPAWN-COLONY: ~A [~A] spawns a larva at (~A ~A ~A).~%" (name actor) (id actor) (first target) (second target) (third target)))
                                                     ;; target here is the item to be reanimated
                                                     (print-visible-message (x actor) (y actor) (z actor) (level *world*)
                                                                            (format nil "One of the orifices of ~A spawns a huge hideous creature. " (capitalize-name (prepend-article +article-the+ (visible-name actor))))
                                                                            :observed-mob actor)
                                                     (generate-sound actor (x actor) (y actor) (z actor) 60 #'(lambda (str)
                                                                                                                (format nil "You hear some burping~A. " str)))
                                                     (let ((larva-mob))
                                                       (setf larva-mob (make-instance 'mob :mob-type +mob-type-spore-colony+ :x (first target) :y (second target) :z (third target)))
                                                       (add-mob-to-level-list (level *world*) larva-mob))
                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (mob-ability-p actor +mob-abil-primordial+)
                                                                  t
                                                                  nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-ally))
                                                          (let ((final-cell nil))
                                                            (check-surroundings (x actor) (y actor) nil #'(lambda (dx dy)
                                                                                                            (let ((terrain (get-terrain-* (level *world*) dx dy (z actor))))
                                                                                                              (when (and terrain
                                                                                                                         (get-terrain-type-trait terrain +terrain-trait-opaque-floor+)
                                                                                                                         (not (get-terrain-type-trait terrain +terrain-trait-blocks-move+))
                                                                                                                         (not (get-mob-* (level *world*) dx dy (z actor))))
                                                                                                                (when (null final-cell)
                                                                                                                  (setf final-cell (list dx dy (z actor))))
                                                                                                                (when (and nearest-enemy
                                                                                                                           (< (get-distance-3d dx dy (z actor) (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))
                                                                                                                              (get-distance-3d (first final-cell) (second final-cell) (third final-cell)
                                                                                                                                               (x nearest-enemy) (y nearest-enemy) (z nearest-enemy))))
                                                                                                                  (setf final-cell (list dx dy (z actor))))))))
                                                            (if (and (funcall (on-check-applic item) actor item)
                                                                     (loop for mob-id in (visible-mobs actor)
                                                                           for mob = (get-mob-by-id mob-id)
                                                                           with no-colony-in-sight = t
                                                                           when (= (mob-type mob) +mob-type-spore-colony+)
                                                                             do
                                                                                (setf no-colony-in-sight nil)
                                                                                (loop-finish)
                                                                           finally (return no-colony-in-sight))
                                                                     final-cell)
                                                              final-cell
                                                              nil)))
                                         :map-select-func #'(lambda (item)
                                                              (if (and (get-single-memo-visibility (get-memo-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (not (get-mob-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)))
                                                                       (< (get-distance-3d (x *player*) (y *player*) (z *player*) (view-x *player*) (view-y *player*) (view-z *player*)) 2)
                                                                       (not (get-terrain-type-trait (get-terrain-* (level *world*) (view-x *player*) (view-y *player*) (view-z *player*)) +terrain-trait-blocks-move+)))
                                                                (progn
                                                                  (clear-message-list *small-message-box*)
                                                                  (mob-use-item *player* (list (view-x *player*) (view-y *player*) (view-z *player*)) item)
                                                                  t)
                                                                (progn
                                                                  nil)))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally nearest-enemy))
                                                             (mob-use-item actor check-result item))))

(set-item-type (make-instance 'item-type :id +item-type-book-of-rituals+
                                         :name "Book of Rituals" :plural-name "Books of Rituals"
                                         :glyph-idx 125 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 300
                                         :descr "A black leather book. It seems to be whispering something to you. In the languages you do not understand. Only the ghost can use it on the sacrificial circle, the place of its creation."
                                         :flavor-quote (format nil "\"He quickly went into a stall, drew a circle round him with his finger, uttered some prayers and formulas for exorcism, and then began to read the prayers for the dead in a loud voice and with the fixed resolution not to look up from the book nor take notice of anything.\"~%Nikolai Gogol. The Viy.")
                                         :on-use #'(lambda (actor target item)
                                                     (declare (ignore target item))

                                                     (set-mob-effect actor :effect-type-id +mob-effect-rest-in-peace+ :actor-id (id actor) :cd t)

                                                     ;; always remove 1 item
                                                     t)
                                         :on-check-applic #'(lambda (actor item)
                                                              (declare (ignore item))
                                                              (if (and (mob-ability-p actor +mob-abil-ghost-possess+)
                                                                       (find-if #'(lambda (a)
                                                                                    (if (= (feature-type a) +feature-sacrificial-circle+)
                                                                                      t
                                                                                      nil))
                                                                                (get-features-* (level *world*) (x actor) (y actor) (z actor))
                                                                                :key #'(lambda (a)
                                                                                         (get-feature-by-id a))))
                                                                  t
                                                                nil))
                                         :on-check-ai #'(lambda (actor item nearest-enemy nearest-ally)
                                                          (declare (ignore nearest-enemy nearest-ally))
                                                          (if (and (funcall (on-check-applic item) actor item)
                                                                   )
                                                            t
                                                            nil))
                                         :ai-invoke-func #'(lambda (actor item nearest-enemy nearest-ally check-result)
                                                             (declare (ignore nearest-ally nearest-enemy))
                                                             (mob-use-item actor check-result item))))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-flesh+
                                         :name "scroll with a demonic rune Un" :plural-name "scrolls with a demonic rune Un"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Un inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-invite+
                                         :name "scroll with a demonic rune Ged" :plural-name "scrolls with a demonic rune Ged"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Ged inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-away+
                                         :name "scroll with a demonic rune Veh" :plural-name "scrolls with a demonic rune Veh"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Veh inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-transform+
                                         :name "scroll with a demonic rune Med" :plural-name "scrolls with a demonic rune Med"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Med inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-barrier+
                                         :name "scroll with a demonic rune Gon" :plural-name "scrolls with a demonic rune Gon"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Gon inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-decay+
                                         :name "scroll with a demonic rune Drux" :plural-name "scrolls with a demonic rune Drux"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Drux inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))

(set-item-type (make-instance 'item-type :id +item-type-scroll-demonic-rune-all+
                                         :name "scroll with a demonic rune Tal" :plural-name "scrolls with a demonic rune Tal"
                                         :glyph-idx 31 :glyph-color sdl:*magenta* :back-color sdl:*black* :max-stack-num 1 :value 50
                                         :descr "A scroll with a demonic rune Tal inscribed on it. Looking at it makes you feel as if it is looking back at you."
                                         :flavor-quote (format nil "\"Then she began to murmur in an undertone, and terrible words escaped her lips - words that sounded like the bubbling of boiling pitch. The philosopher did not know their meaning, but he knew that they signified something terrible, and were intended to counteract his exorcisms.\"~%Nikolai Gogol. The Viy.")
                              ))
