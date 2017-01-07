(in-package :cotd)

;;--------------------
;; FEATURE-TYPE Declarations
;;-------------------- 

(set-feature-type (make-instance 'feature-type :id +feature-blood-old+ :glyph-idx nil :glyph-color (sdl:color :r 150 :b 0 :b 0) :back-color nil :name "Bloodstain"))
(set-feature-type (make-instance 'feature-type :id +feature-blood-fresh+ :glyph-idx nil :glyph-color (sdl:color :r 250 :b 0 :b 0) :back-color nil :name "Bloodstain"))
(set-feature-type (make-instance 'feature-type :id +feature-blood-stain+ :glyph-idx 106 :glyph-color (sdl:color :r 250 :b 0 :b 0) :back-color sdl:*black* :name "Bloodstain"))
(set-feature-type (make-instance 'feature-type :id +feature-final-altar+ :glyph-idx 11 :glyph-color sdl:*cyan* :back-color sdl:*black* :name "Final Seal" :func #'(lambda () (funcall *game-won-func*))))
								
