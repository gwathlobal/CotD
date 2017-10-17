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
                                         :on-use #'(lambda (actor item)
                                                     (declare (ignore item))
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
                                                            nil))))

(set-item-type (make-instance 'item-type :id +item-type-smoke-bomb+
                                         :name "smoke bomb" :plural-name "smoke bombs"
                                         :descr "A bomb that emits clouds of smoke to conceal you. Usable only by humans. Can not be used in water."
                                         :flavor-quote (format nil "\"All smoke and steam, he thought; all seems for ever changing, on all sides new forms, phantoms flying after phantoms, while in reality it is all the same and the same again; everything hurrying, flying towards something, and everything vanishing without a trace, attaining to nothing; another wind blows, and all is dashing in the opposite direction, and there again the same untiring, restless - and useless gambols!\"~%Ivan Turgenev. Smoke.")
                                         :glyph-idx 1 :glyph-color (sdl:color :r 200 :g 200 :b 200) :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor item)
                                                     (declare (ignore item))
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
                                                                      0.4))
                                                            t
                                                            nil))))

(set-item-type (make-instance 'item-type :id +item-type-clothing+
                                         :name "civilian costume" :plural-name "civilian costumes"
                                         :flavor-quote (format nil "\"And what fine eyes he has, and how fine his whole face is!.. He is even better looking than Dounia... But, good heavens, what a suit - how terribly he's dressed! ... Vasya, the messenger boy in Afanasy Ivanitch's shop, is better dressed!\"~%Fyodor Dostoevsky. Crime and Punishment.")
                                         :glyph-idx 59 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 10 :value 5))

(set-item-type (make-instance 'item-type :id +item-type-disguise+
                                         :name "disguise" :plural-name "disguises"
                                         :descr "A special kit that lets you disguise yourself as an ordinary man or woman. Usable by humans and Malseraph's puppets only."
                                         :flavor-quote (format nil "\"The door opened and a masked corpulent stocky man, wearing a coachman's suit and a hat with peackock's feathers, entered the reading room. He was followed by two masked ladies and a servant holding a tray. On the tray, there stood a bellied bottle of liqueur, three bottles of red wine and several glasses.\"~%Anton Checkov. The Mask.")
                                         :glyph-idx 59 :glyph-color (sdl:color :r 100 :g 100 :b 100) :back-color sdl:*black* :max-stack-num 10 :value 10
                                         :on-use #'(lambda (actor item)
                                                     (declare (ignore item))
                                                     
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
                                                            nil))))

(set-item-type (make-instance 'item-type :id +item-type-deck-of-war+
                                         :name "deck of war" :plural-name "decks of war"
                                         :descr "A special deck of cards granted by Malseraph, the Demon God of Acting, Gambling and Violent Changes. The deck contains a random number of different cards, all devouted to combat and fighting. Each card has a special effect that will benefit those who use it."
                                         :flavor-quote (format nil "\"As for cards, there was no habit to play cards in those circles (mainly literary ones) where Fyodor Mikhailovich used to move. During our 14 years of marriage, my husband played preferans only once, at my relatives' place; and though he had not touched a card for more than 10 years, he played perfectly and even managed to win several roubles from his partners which embarrassed him greatly.\"~%Anna Dostoevskaya. Dostoevsky: Reminiscences.")
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1
                                         :abil-card (list +item-card-curse-other+ +item-card-blindness-other+ +item-card-fear-other+ +item-card-slow-other+ +item-card-silence-other+ +item-card-confuse-other+
                                                          +item-card-polymorph-other+ +item-card-irradiate-other+)
                                         :on-use #'(lambda (actor item)

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
                                                            nil))))

(set-item-type (make-instance 'item-type :id +item-type-deck-of-escape+
                                         :name "deck of escape" :plural-name "decks of escape"
                                         :descr "A special deck of cards granted by Malseraph, the Demon God of Acting, Gambling and Violent Changes. The deck contains a random number of different cards, all devouted to escapes and trickery. Each card has a special effect that will benefit those who use it."
                                         :flavor-quote (format nil "\"As for cards, there was no habit to play cards in those circles (mainly literary ones) where Fyodor Mikhailovich used to move. During our 14 years of marriage, my husband played preferans only once, at my relatives' place; and though he had not touched a card for more than 10 years, he played perfectly and even managed to win several roubles from his partners which embarrassed him greatly.\"~%Anna Dostoevskaya. Dostoevsky: Reminiscences.")
                                         :glyph-idx 1 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 1
                                         :abil-card (list +item-card-blink+ +item-card-teleport+ +item-card-sprint+ +item-card-flying+ +item-card-disguise+)
                                         :on-use #'(lambda (actor item)

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
                                                            nil))))
