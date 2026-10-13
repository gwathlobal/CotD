(asdf:defsystem #:cotd-smoke-test
  :description "Plays a fixed route through the real City of the Damned in a
nested X server (Xephyr), driving it with synthetic key presses, and checks
what can be checked automatically."
  :depends-on (cffi uiop)
  :serial t
  :components ((:file "xdrive")
               (:file "smoke-test")))
