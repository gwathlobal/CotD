(in-package :cotd)

;; Runs level generation with no SDL window and no display, so it works from a
;; plain SBCL REPL or a batch script. Three things make this possible:
;;  - INIT-GAME's screen-update closure is injectable (see its :SCREEN-UPDATE-FUNC
;;    argument), so headless callers don't have to go through MAKE-OUTPUT on a
;;    live window.
;;  - FIND-RANDOM-SCENARIO-OPTIONS drives the same scenario setup the main menu
;;    uses, so PLAYER-LVL-MOD-PLACEMENT-ID ends up set correctly.
;;  - *COTD-RELEASE* skips the per-mob debug invariants, which assume a fully
;;    played turn rather than a freshly generated level.
;;
;; Generation is seeded via SB-EXT:SEED-RANDOM-STATE, so the same seed
;; reproduces an identical level across runs and across builds: a terrain
;; checksum plus mob/item/feature counts is a cheap, deterministic regression
;; oracle. Run RUN-HEADLESS-REGRESSION before and after a change and diff the
;; two results with HEADLESS-REGRESSION-DIFF - any difference is a behavior
;; change in level generation, not noise.

(defun generate-headless-level (specific-faction-type &key seed)
  "Generate one level with no SDL window, for profiling or regression tests.
SPECIFIC-FACTION-TYPE is one of the +specific-faction-type-...+ constants.
Returns the generated LEVEL."
  (setf *cotd-release* t)
  (when seed
    (setf *random-state* (sb-ext:seed-random-state seed)))
  (multiple-value-bind (mission world-sector) (find-random-scenario-options specific-faction-type)
    (init-game mission world-sector :screen-update-func #'(lambda (str) (declare (ignore str)) nil))
    (level *world*)))

(defun level-checksum (level)
  "A cheap regression oracle for a generated LEVEL: a terrain checksum plus
mob/item/feature counts. Two runs with the same seed must return the same
value; any difference means level generation changed."
  (list :terrain (loop with sum of-type (unsigned-byte 32) = 0
                        for i from 0 below (array-total-size (terrain level))
                        do (setf sum (logand #xFFFFFFFF (+ (* sum 31) (row-major-aref (terrain level) i))))
                        finally (return sum))
        :mobs (length (mob-id-list level))
        :items (length (item-id-list level))
        :features (length (feature-id-list level))))

(defparameter *headless-test-seeds* '(1 2 3 4 5 6 7 8))

(defparameter *headless-test-faction-types*
  (list +specific-faction-type-player+
        +specific-faction-type-demon-crimson+
        +specific-faction-type-angel-chrome+
        +specific-faction-type-military-chaplain+
        +specific-faction-type-satanist+
        +specific-faction-type-ghost+))

(defun run-headless-regression (&key (seeds *headless-test-seeds*) (faction-types *headless-test-faction-types*))
  "Generate one level per (seed x faction-type) combination and checksum each.
Returns a list of (seed faction-type checksum) usable as a baseline: call this
before a change and after it, and diff the two with HEADLESS-REGRESSION-DIFF."
  (loop for faction-type in faction-types
        append (loop for seed in seeds
                     collect (list seed faction-type (level-checksum (generate-headless-level faction-type :seed seed))))))

(defun headless-regression-diff (before after)
  "Compare two results of RUN-HEADLESS-REGRESSION. Returns the entries whose
checksum differs between the two runs, or NIL if nothing changed."
  (loop for b in before
        for a in after
        unless (equal b a)
          collect (list :before b :after a)))
