(in-package :cotd)

;;============
;; NORMAL
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-residential+
                                      :glyph-idx 40
                                      :glyph-color sdl:*white*
                                      :name "An ordinary district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-port+
                                      :glyph-idx 48
                                      :glyph-color sdl:*white*
                                      :name "A seaport district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-forest+
                                      :glyph-idx 38
                                      :glyph-color sdl:*white*
                                      :name "The outskirts of the city"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-lake+
                                      :glyph-idx 44
                                      :glyph-color sdl:*white*
                                      :name "A district upon a lake"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-sea+
                                      :glyph-idx 51
                                      :glyph-color sdl:*white*
                                      :name "Sea"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-normal-island+
                                      :glyph-idx 41
                                      :glyph-color sdl:*white*
                                      :name "An island district"))

;;============
;; ABANDONED
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-residential+
                                      :glyph-idx 40
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)
                                      :name "An abandoned district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-port+
                                      :glyph-idx 48
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)
                                      :name "An abandoned seaport district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-forest+
                                      :glyph-idx 38
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)
                                      :name "The abandoned outskirts of the city"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-lake+
                                      :glyph-idx 44
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)
                                      :name "An abandoned district upon a lake"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-abandoned-island+
                                      :glyph-idx 41
                                      :glyph-color (sdl:color :r 150 :g 150 :b 150)
                                      :name "An abandoned island district"))

;;============
;; CORRUPTED
;;============

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-residential+
                                      :glyph-idx 40
                                      :glyph-color sdl:*magenta*
                                      :name "A corrupted district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-port+
                                      :glyph-idx 48
                                      :glyph-color sdl:*magenta*
                                      :name "A corrupted seaport district"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-forest+
                                      :glyph-idx 38
                                      :glyph-color sdl:*magenta*
                                      :name "The corrupted outskirts of the city"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-lake+
                                      :glyph-idx 44
                                      :glyph-color sdl:*magenta*
                                      :name "A corrupted district upon a lake"))

(set-world-sector-type (make-instance 'world-sector-type
                                      :wtype +world-sector-corrupted-island+
                                      :glyph-idx 41
                                      :glyph-color sdl:*magenta*
                                      :name "A corrupted island district"))
