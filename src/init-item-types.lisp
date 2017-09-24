(in-package :cotd)

(set-item-type (make-instance 'item-type :id +item-type-body-part-limb+
                                         :name "body part" :plural-name "body parts"
                                         :descr (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 1))

(set-item-type (make-instance 'item-type :id +item-type-body-part-half+
                                         :name "body part" :plural-name "body parts"
                                         :descr (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 2))

(set-item-type (make-instance 'item-type :id +item-type-body-part-body+
                                         :name "body part" :plural-name "body parts"
                                         :descr (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 3))

(set-item-type (make-instance 'item-type :id +item-type-body-part-full+
                                         :name "body part" :plural-name "body parts"
                                         :descr (format nil "\"The dead man lay, as dead men always lie, in a specially heavy way, his rigid limbs sunk in the soft cushions of the coffin, with the head forever bowed on the pillow. <...> He was much changed and grown even thinner since Peter Ivanovich had last seen him, but, as is always the case with the dead, his face was handsomer and above all more dignified than when he was alive.\"~%Leo Tolstoy. Death of Ivan Ilych.")
                                         :glyph-idx 5 :glyph-color sdl:*red* :back-color sdl:*black* :abil-corpse 4))

(set-item-type (make-instance 'item-type :id +item-type-coin+
                                         :name "coin" :plural-name "coins"
                                         :descr (format nil "\"I have money and so I can do whatever I like; I have money and so I will not perish and will not have to ask help from anyone; not having to ask for anyone's help is the highest freedom. Yet in essence this is not freedom but slavery once again, a slavery that comes from money.\"~%Fyodor Dostoevsky. A Writer's Diary.")
                                         :glyph-idx 4 :glyph-color sdl:*yellow* :back-color sdl:*black* :max-stack-num 10000 :value 1))

(set-item-type (make-instance 'item-type :id +item-type-medkit+
                                         :name "medkit" :plural-name "medkits"
                                         :descr (format nil "A medkit that can heal 3-5 HP. Usable by humans only. Unusable underwater.~%~%\"There was a large wound in his stomach. The King washed it as best he could, and bandaged it with his handkerchief and with a towel the hermit had. But the blood would not stop flowing, and the King again and again removed the bandage soaked with warm blood, and washed and rebandaged the wound. When at last the blood ceased flowing, the man revived and asked for something to drink.\"~%Leo Tolstoy. Three Questions.")
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
                                                                              (format nil "~A uses a medkit to heal itself for ~A. " (capitalize-name (visible-name actor)) heal-pwr))))
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
                                         :descr (format nil "A bomb that emits clouds of smoke to conceal you. Usable only by humans. Can not be used in water.~%~%\"All smoke and steam, he thought; all seems for ever changing, on all sides new forms, phantoms flying after phantoms, while in reality it is all the same and the same again; everything hurrying, flying towards something, and everything vanishing without a trace, attaining to nothing; another wind blows, and all is dashing in the opposite direction, and there again the same untiring, restless - and useless gambols!\"~%Ivan Turgenev. Smoke.")
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
                                                                                (format nil "~A uses a smoke bomb. " (capitalize-name (visible-name actor)))))))
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
