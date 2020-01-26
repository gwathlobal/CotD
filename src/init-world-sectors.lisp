(in-package :cotd)

;;============
;; NORMAL
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-residential+
                                      :glyph-idx 40
                                      :glyph-color sdl:*white*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-port+
                                      :glyph-idx 48
                                      :glyph-color sdl:*white*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-forest+
                                      :glyph-idx 38
                                      :glyph-color sdl:*white*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-lake+
                                      :glyph-idx 44
                                      :glyph-color sdl:*white*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-sea+
                                      :glyph-idx 51
                                      :glyph-color sdl:*white*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-island+
                                      :glyph-idx 41
                                      :glyph-color sdl:*white*))

;;============
;; ABANDONED
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-residential+
                                      :glyph-idx 40
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-port+
                                      :glyph-idx 48
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-forest+
                                      :glyph-idx 38
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-lake+
                                      :glyph-idx 44
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-island+
                                      :glyph-idx 41
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)))

;;============
;; CORRUPTED
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-residential+
                                      :glyph-idx 40
                                      :glyph-color sdl:*magenta*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-port+
                                      :glyph-idx 48
                                      :glyph-color sdl:*magenta*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-forest+
                                      :glyph-idx 38
                                      :glyph-color sdl:*magenta*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-lake+
                                      :glyph-idx 44
                                      :glyph-color sdl:*magenta*))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-island+
                                      :glyph-idx 41
                                      :glyph-color sdl:*magenta*))
