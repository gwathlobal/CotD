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
  ;; *OPTIONS* is normally set by COTD-INIT (from options.cfg); PRINT-VISIBLE-MESSAGE
  ;; and friends read it unconditionally, so anything that runs a real AI turn
  ;; headlessly - not just level generation - needs it bound to something.
  (unless (boundp '*options*)
    (setf *options* (make-options)))
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-posix))

;;; ---------------------------------------------------------------------
;;; Deliverable 3: type-table oracle (cheapest - run this one first).
;;;
;;; Dumps every registered type instance (terrain/feature/mob/item/ability/
;;; effect/card/animation/faction) plus every +...+ id constant, with TYPE-OF
;;; on every slot value as well as the value itself. TYPE-OF is what catches a
;;; slot's *representation* changing even when it prints the same, e.g. the
;;; glyph/back-color slots moving from SDL:COLOR objects to packed-color
;;; fixnums - exactly the case this oracle exists for.
;;; ---------------------------------------------------------------------

(defun type-table-fingerprint-value (value)
  "A representation-sensitive fingerprint of VALUE. Hash-tables and arrays
\(TRAIT, ABILITIES, AI-PACKAGES, ARMOR, ...) are walked recursively so a value
buried inside one of them is still compared; a function is reduced to a
marker since closures are never EQL across reloads and comparing them would
be pure noise."
  (typecase value
    (hash-table (list :hash-table (type-of value)
                       (sort (loop for k being the hash-key in value using (hash-value v)
                                   collect (cons k (type-table-fingerprint-value v)))
                             #'string< :key #'(lambda (e) (format nil "~S" (car e))))))
    (array (list :array (type-of value) (array-dimensions value)
                  (loop for i from 0 below (array-total-size value)
                        collect (type-table-fingerprint-value (row-major-aref value i)))))
    (cons (list :cons (type-of value) (mapcar #'type-table-fingerprint-value value)))
    (function (list :function))
    (t (list (type-of value) value))))

(defun type-table-fingerprint-instance (instance)
  "(TYPE-OF INSTANCE) plus every slot's fingerprint, sorted by slot name so
the order is stable regardless of how SBCL happens to lay out the class."
  (list (type-of instance)
        (sort (loop for slot in (sb-mop:class-slots (class-of instance))
                    for name = (sb-mop:slot-definition-name slot)
                    collect (list name
                                  (if (slot-boundp instance name)
                                    (type-table-fingerprint-value (slot-value instance name))
                                    :unbound)))
              #'string< :key #'(lambda (e) (symbol-name (first e))))))

(defun type-table-dump-array (array)
  "(index . fingerprint) for every non-NIL instance in ARRAY. *FACTION-TYPES*
in particular has NIL holes (unassigned faction ids), hence the guard."
  (loop for i from 0 below (length array)
        for instance = (aref array i)
        when instance
          collect (cons i (type-table-fingerprint-instance instance))))

(defun type-table-id-constants ()
  "Every +...+ constant interned in :COTD and its value, sorted by name. This
covers every DEFINE-TRAIT-IDS id space (terrain traits, feature traits, mob
abilities, AI packages, ...) and every hand-written +...-TYPE-...+ constant,
without hand-listing them, so appending/inserting/reordering any of them -
including the mob-ability ids that are hash keys in saved games - shows up as
a diff."
  (let (result)
    (do-symbols (sym (find-package :cotd))
      (let ((name (symbol-name sym)))
        (when (and (> (length name) 2)
                   (char= (char name 0) #\+)
                   (char= (char name (1- (length name))) #\+)
                   (constantp sym))
          (push (cons name (symbol-value sym)) result))))
    (sort result #'string< :key #'car)))

(defun type-table-checksum ()
  "A regression oracle for the type tables themselves: every terrain, feature,
mob, item, ability, effect, card and animation type, every faction, and every
id constant. Catches a changed initarg, a changed trait default, or an id
space that grew/reordered - the same kind of change RUN-HEADLESS-REGRESSION
cannot see because it only looks at generated levels, not the type data they
are built from."
  (list :terrain (type-table-dump-array *terrain-types*)
        :feature (type-table-dump-array *feature-types*)
        :mob (type-table-dump-array *mob-types*)
        :item (type-table-dump-array *item-types*)
        :ability (type-table-dump-array *ability-types*)
        :effect (type-table-dump-array *effect-types*)
        :card (type-table-dump-array *card-types*)
        :animation (type-table-dump-array *animation-types*)
        :faction (type-table-dump-array *faction-types*)
        :id-constants (type-table-id-constants)))

;;; ---------------------------------------------------------------------
;;; Deliverable 1: gameplay-turn oracle.
;;;
;;; RUN-HEADLESS-TURN-STEP mirrors the body of GAME-LOOP's main DO loop in
;;; cotd.lisp, one outer-loop iteration (one pass through MOB-ID-LIST) per
;;; call - NOT one full "every mob spends all its AP" turn, matching what
;;; GAME-LOOP itself calls one iteration (see its "REAL-GAME-TURN" log line).
;;; It must be kept in sync by hand if GAME-LOOP changes; the deviations from
;;; it, and why each one is safe, are:
;;;
;;;  - The player's AI-FUNCTION method (ai-player.lisp) calls MAKE-OUTPUT on
;;;    *CURRENT-WINDOW* and then blocks for real input, so it cannot run
;;;    headlessly. Every mob of type PLAYER - not just *PLAYER* itself, since
;;;    GAME-LOOP retargets *PLAYER* onto trinity-mimic/split-soul stand-ins
;;;    that are also PLAYER instances - instead does a deterministic wait via
;;;    (MOVE-MOB mob 5) (direction 5 is x-y-into-dir's wait-in-place case,
;;;    the same one immobile mobs use in ai-common.lisp). This still spends
;;;    the mob's AP through the real action path (MAKE-ACT, effect/on-tick
;;;    processing), not a faked (SETF (CUR-AP mob) 0).
;;;  - GAME-LOOP's player-died/outside-level block is a UI pause-and-poll
;;;    with no headless equivalent; this oracle instead just lets the mob
;;;    loop run (a dead *PLAYER* has CUR-AP <=0 already handled by the normal
;;;    skip condition) and leaves ending the run on a dead/outside player to
;;;    the caller, the same way a game event ending the mission is handled.
;;;
;;; PROCESS-ANIMATIONS-ON-LEVEL (base-methods.lisp) is called as GAME-LOOP
;;; calls it, unmodified: ability/attack code also calls it directly (not just
;;; GAME-LOOP), so draining ANIMATION-QUEUE by hand here instead would miss
;;; those calls. It was changed at the source instead - it now checks
;;; (BOUNDP '*GLYPH-FRONT*) and, when nothing has loaded the font strip (true
;;; for every headless caller that isn't RENDER-CHECKSUM), just drops the
;;; queue rather than blitting into render state that was never set up.
;;;
;;; Game events and win conditions DO run (unlike the two deviations above,
;;; this is a deliberate inclusion, not a simplification): that is more
;;; representative of a real turn and catches more. The cost is that a
;;; mission can end mid-run, which changes state for reasons unrelated to
;;; whatever is actually being tested - so RUN-HEADLESS-TURN-STEP returns
;;; whether this step ended the mission, and callers drop any seed where it
;;; did rather than comparing a checksum that depends on mission logic too.
;;; ---------------------------------------------------------------------

(defun headless-mission-win-triggered-p (world)
  "Mirrors the win-condition check at the top of GAME-LOOP: true if the
player's loyal faction has a win condition whose ON-CHECK currently holds."
  (and *player*
       (let ((win-cond (find (loyal-faction *player*)
                              (win-condition-list (get-mission-type-by-id (mission-type-id (mission (level world)))))
                              :key #'first)))
         (and win-cond
              (funcall (on-check (get-game-event-by-id (second win-cond))) world)))))

(defun run-headless-turn-step (world)
  "One iteration of GAME-LOOP's main loop body, adapted to run with no SDL
window - see the comment above this section for exactly how and why it
differs from GAME-LOOP. Returns T if a win condition or game event ended the
mission this step."
  (let ((turn-finished t)
        (level (level world))
        (mission-ended nil))

    (when (headless-mission-win-triggered-p world)
      (setf mission-ended t))

    ;; Most of a level's GAME-EVENTS are ordinary recurring mechanics (weather,
    ;; delayed reinforcements, ...) and their ON-TRIGGER is safe to run as-is.
    ;; But the SAME list also carries every win/loss event (e.g.
    ;; +GAME-EVENT-PLAYER-DIED+, the per-faction "...-WIN-FOR-..." events):
    ;; their ON-TRIGGER calls TRIGGER-GAME-OVER (init-game-events-common.lisp),
    ;; which ends in MAKE-OUTPUT/RUN-WINDOW on *CURRENT-WINDOW* - the same kind
    ;; of UI call the player's AI-FUNCTION needs and this harness cannot
    ;; provide. There is no cheap way to tell the two kinds of event apart
    ;; without running them, so ON-TRIGGER runs for real (keeping ordinary
    ;; events representative) and an error escaping it - which is what a
    ;; blocked UI call looks like here - is treated as the mission ending,
    ;; same as the win-condition check above.
    (loop for game-event-id of-type fixnum in (game-events level)
          for game-event = (get-game-event-by-id game-event-id)
          when (and (not (disabled game-event))
                    (funcall (on-check game-event) world))
            do
               (handler-case
                   (funcall (on-trigger game-event) world)
                 (error () (setf mission-ended t))))

    (setf (turn-finished world) nil)
    (process-animations-on-level level)

    (loop for mob-id in (mob-id-list level)
          for mob = (get-mob-by-id mob-id)
          do
      (when (and (not (check-dead mob))
                 (> (cur-ap mob) 0)
                 (not (is-merged mob)))

        (setf turn-finished nil)
        (setf (made-turn mob) nil)
        (set-message-this-turn nil)
        (setf (motion-set-p mob) nil)

        ;; for trinity mimics / split soul - set the current mob as the player,
        ;; same as GAME-LOOP
        (when (or (and (subtypep (type-of mob) 'player)
                       (mob-ability-p mob +mob-abil-trinity-mimic+)
                       (find (id mob) (mimic-id-list *player*)))
                  (and (subtypep (type-of mob) 'player)
                       (mob-effect-p mob +mob-effect-split-soul-target+))
                  (and (subtypep (type-of mob) 'player)
                       (mob-effect-p mob +mob-effect-split-soul-source+)))
          (setf *player* mob))

        (setf (if-cur-mob-seen-through-shared-vision *player*)
              (if (mounted-by-mob-id mob)
                (and (find (mounted-by-mob-id mob) (shared-visible-mobs *player*))
                     (not (find (mounted-by-mob-id mob) (proper-visible-mobs *player*))))
                (and (find (id mob) (shared-visible-mobs *player*))
                     (not (find (id mob) (proper-visible-mobs *player*))))))

        ;; the one real substitution: any PLAYER-type mob waits instead of
        ;; calling AI-FUNCTION, which would try to read real input
        (if (subtypep (type-of mob) 'player)
          (move-mob mob 5)
          (ai-function mob))

        (setf (heard-sounds mob) nil)
        (update-visible-mobs mob)
        (when (eq mob *player*)
          (update-visible-area level (x *player*) (y *player*) (z *player*)))

        (process-animations-on-level level)

        (when (<= (cur-ap mob) 0)
          (on-tick mob))))

    (when turn-finished
      (incf (player-game-time level))
      (when (check-dead *player*)
        (incf (world-game-time world) +normal-ap+))
      (setf (turn-finished world) t)
      (loop for mob-id in (mob-id-list level)
            for mob = (get-mob-by-id mob-id)
            do
        (when (and (not (check-dead mob))
                   (not (is-merged mob)))
          (incf (cur-ap mob) (max-ap mob))
          (when (worshiped-god mob)
            (funcall (piety-tick-func (get-god-by-id (get-worshiped-god-type (worshiped-god mob))))
                     (get-god-by-id (get-worshiped-god-type (worshiped-god mob)))
                     mob))))
      (loop for feature-id of-type fixnum in (feature-id-list level)
            for feature = (get-feature-by-id feature-id)
            when (and feature (on-tick-func feature))
              do (funcall (on-tick-func feature) level feature)))

    mission-ended))

(defun mob-effect-fingerprint (mob)
  "The content of every effect on MOB - effect-type, countdown, param1 -
sorted by effect-type for a deterministic order (EFFECTS is a hash-table,
which has none of its own). Deliberately excludes the EFFECT object's own ID:
EFFECTS maps effect-type to that global id, which is a monotonic counter
*EFFECTS* never resets between levels in the same image (see INIT-GAME), so
two otherwise-identical runs in one image get different ids for the same
effect - comparing it would make every same-image determinism check fail for
a reason that has nothing to do with gameplay."
  (sort (loop for effect-id being the hash-value in (effects mob)
              for effect = (get-effect-by-id effect-id)
              collect (list (effect-type effect) (cd effect) (param1 effect)))
        #'< :key #'first))

(defun turn-checksum (level)
  "A regression oracle for LEVEL after RUN-HEADLESS-TURN-STEP has advanced it:
per-mob position/stats/effects (exactly, so a diff says which mob and field
changed), a folded hash of the memo array's glyph/visibility/revealed/light
fields, PLAYER-GAME-TIME, and the mob/item/feature counts.

Deliberately excluded: the memo's glyph-color/back-color fields. The ongoing
packed-colour migration (see CLAUDE.md commit history) is what this oracle is
meant to stay decoupled from while that work is in flight, so colour is left
out on purpose rather than because of what the fields currently hold. Add
them back as the last step of that work, once the representation is settled
for good."
  (list :mobs (loop for mob-id in (mob-id-list level)
                     for mob = (get-mob-by-id mob-id)
                     collect (list (id mob) (x mob) (y mob) (z mob)
                                   (cur-hp mob) (cur-ap mob) (cur-fp mob)
                                   (check-dead mob)
                                   (mob-effect-fingerprint mob)))
        :memo (loop with sum of-type (unsigned-byte 32) = 0
                     for i from 0 below (array-total-size (memo level))
                     for single-memo = (row-major-aref (memo level) i)
                     do (setf sum (logand #xFFFFFFFF
                                           (+ (* sum 31)
                                              (sxhash (list (get-single-memo-glyph-idx single-memo)
                                                            (get-single-memo-visibility single-memo)
                                                            (get-single-memo-revealed single-memo)
                                                            (get-single-memo-light single-memo))))))
                     finally (return sum))
        :player-game-time (player-game-time level)
        :mobs-n (length (mob-id-list level))
        :items-n (length (item-id-list level))
        :features-n (length (feature-id-list level))))

(defparameter *headless-turn-user-dir* (merge-pathnames "cotd-headless-turn-oracle/" (uiop:temporary-directory))
  "Where RUN-HEADLESS-TURNS points *USER-DIR* for the duration of a run. A
win/loss game event's ON-TRIGGER can write a highscore record or dump a
morgue file (TRIGGER-GAME-OVER, init-game-events-common.lisp) before hitting
the UI call that errors out headlessly (see RUN-HEADLESS-TURN-STEP) - those
writes already happened by the time the error is caught. *USER-DIR* defaults
to the source tree itself in a dev image (see CLAUDE.md), so without this the
oracle would scribble real highscore/morgue files into the repo every run.")

(defun run-headless-turns (specific-faction-type &key seed (turns 50))
  "Generate a seeded headless level and advance it through TURNS calls to
RUN-HEADLESS-TURN-STEP (see that function and the comment above it for what
one call covers and how it differs from GAME-LOOP).

Returns (VALUES TURN-CHECKSUM MISSION-ENDED-P). MISSION-ENDED-P is T if a
game event or win condition ended the mission within TURNS steps; treat the
checksum as unusable for comparison in that case - it stopped changing for a
reason unrelated to whatever is actually under test, not because nothing
happened."
  (ensure-directories-exist *headless-turn-user-dir*)
  (let* ((*user-dir* *headless-turn-user-dir*)
         (level (generate-headless-level specific-faction-type :seed seed))
         (mission-ended nil))
    (loop for i from 0 below turns
          until mission-ended
          do (setf mission-ended (run-headless-turn-step *world*)))
    (values (turn-checksum level) mission-ended)))

(defparameter *headless-turn-quick-seeds* '(1 2)
  "A small seed subset for RUN-HEADLESS-TURN-REGRESSION's :QUICK use - fast
enough for a tight edit/test loop. Use *HEADLESS-TEST-SEEDS* for the full set
before a commit.")

(defun run-headless-turn-regression (&key (seeds *headless-test-seeds*) (faction-types *headless-test-faction-types*) (turns 50))
  "Cross product of SEEDS x FACTION-TYPES, each run through RUN-HEADLESS-TURNS.
Returns a list of (seed faction-type checksum mission-ended-p), usable as a
baseline the same way RUN-HEADLESS-REGRESSION is: call before a change and
after, diff with HEADLESS-TURN-REGRESSION-DIFF. Pass
:SEEDS *HEADLESS-TURN-QUICK-SEEDS* for a fast check; use the default (full)
seed list before a commit."
  (loop for faction-type in faction-types
        append (loop for seed in seeds
                     collect (multiple-value-bind (checksum mission-ended)
                                 (run-headless-turns faction-type :seed seed :turns turns)
                               (list seed faction-type checksum mission-ended)))))

(defun headless-turn-regression-diff (before after)
  "Like HEADLESS-REGRESSION-DIFF, but an entry whose MISSION-ENDED-P was T in
either run is skipped rather than compared - see RUN-HEADLESS-TURNS."
  (loop for b in before
        for a in after
        unless (or (fourth b) (fourth a) (equal b a))
          collect (list :before b :after a)))

;;; ---------------------------------------------------------------------
;;; Deliverable 2: render/pixel oracle.
;;;
;;; Four things that cost real time to find out, kept here so the next person
;;; doesn't have to re-discover them:
;;;  1. SDL_VIDEODRIVER=dummy lets SDL 1.2 initialize with no real display -
;;;     SDL 1.2's headless video driver, works in CI. Without it SDL:LOAD-IMAGE
;;;     and surface blits fail outright on a machine with no X server.
;;;  2. UPDATE-MAP-AREA (window-methods.lisp) has no :SURFACE parameter; the
;;;     surface only reaches DRAW-GLYPH through SDL:*DEFAULT-SURFACE*'s
;;;     default, so that special variable is rebound around the call instead
;;;     of threading a new keyword through every caller.
;;;  3. SDL:READ-PIXEL-* does not exist (CLAUDE.md used to say otherwise -
;;;     fixed). lispbuilder-sdl exports READ-PIXEL/WITH-PIXEL/WITH-PIXELS
;;;     (re-exported from lispbuilder-sdl-base; see sdl/package.lisp), and
;;;     READ-PIXEL takes a pixel context from WITH-PIXEL, not a surface and
;;;     coordinates directly.
;;;  4. COTD-INIT's render setup (glyph-w/h, *GLYPH-FRONT*, the strip cache,
;;;     *TEMP-RECT*) is needed here too; it is factored out as INIT-GLYPH-FRONT
;;;     in window-methods.lisp rather than duplicated.
;;; ---------------------------------------------------------------------

(defun render-checksum (specific-faction-type &key seed)
  "Generate a seeded headless level, render its map area exactly the way real
gameplay does (UPDATE-MAP-AREA / DRAW-GLYPH), and fold every pixel of the
result into one hash - a regression oracle for the render path itself,
independent of RUN-HEADLESS-TURNS/TURN-CHECKSUM which only checks gameplay
state. Does its own one-time SDL setup (see the comment above this section);
callers do not need SDL:WITH-INIT around this."
  (sb-posix:setenv "SDL_VIDEODRIVER" "dummy" 1)
  (cotd-render:with-init ()
    (cotd-render:window 1 1)
    (init-glyph-front)
    (let* ((level (generate-headless-level specific-faction-type :seed seed))
           (surface (cotd-render:create-surface (* *glyph-w* *max-x-view*) (* *glyph-h* *max-y-view*))))
      (declare (ignorable level))
      ;; A freshly generated level's MEMO is all default/unrevealed cells
      ;; (see GENERATE-LEVEL.LISP), which real gameplay never renders: the
      ;; player's own first AI-FUNCTION call (ai-player.lisp) always runs
      ;; UPDATE-VISIBLE-MOBS/UPDATE-VISIBLE-AREA before anything reaches
      ;; UPDATE-MAP-AREA. Do the same here so this renders what the game
      ;; would actually show, not an unreachable pre-FOV state.
      (update-visible-mobs *player*)
      (update-visible-area level (x *player*) (y *player*) (z *player*))
      (let ((cotd-render:*default-surface* surface))
        (update-map-area 0 0))
      ;; SDL:WITH-PIXEL is LISPBUILDER-SDL-BASE::WITH-PIXEL re-exported, and
      ;; the base package's WITH-LOCKED-SURFACE underneath it wants the raw
      ;; CFFI pointer, not the high-level SDL:SURFACE wrapper - hence (FP ...).
      (sdl:with-pixel (pix (sdl:fp surface))
        (loop with sum of-type (unsigned-byte 32) = 0
              for y from 0 below (cotd-render:height surface)
              do (loop for x from 0 below (cotd-render:width surface)
                       do (setf sum (logand #xFFFFFFFF (+ (* sum 31) (sdl:read-pixel pix x y)))))
              finally (return sum))))))

;;; ---------------------------------------------------------------------
;;; Deliverable 4: startup oracle.
;;;
;;; None of the three oracles above call COTD-INIT itself - they each do their
;;; own minimal SDL setup (SDL:WINDOW then INIT-GLYPH-FRONT, in that order) and
;;; call into generation/gameplay/render code below it. That is exactly why
;;; this harness did not catch a COTD-INIT regression that shipped alongside
;;; it: a refactor moved INIT-GLYPH-FRONT (which calls SDL:LOAD-IMAGE, i.e.
;;; creates an SDL surface) to the top of COTD-INIT, ahead of the SDL:WINDOW
;;; call that initializes the video subsystem - lispbuilder-sdl requires video
;;; to be initialized before any surface exists. The real executable crashed
;;; on startup; every oracle above stayed green because none of them run
;;; COTD-INIT's own ordering. RUN-HEADLESS-STARTUP-CHECK closes that gap by
;;; calling COTD-INIT exactly as COTD-MAIN does and is the first thing to run
;;; after touching COTD-INIT or anything it calls.
;;; ---------------------------------------------------------------------

(defparameter *headless-startup-user-dir* (merge-pathnames "cotd-headless-startup-oracle/" (uiop:temporary-directory))
  "Where RUN-HEADLESS-STARTUP-CHECK points *USER-DIR* for the duration of a
run, so COTD-INIT's options.cfg/highscores writes land outside the repo - see
*HEADLESS-TURN-USER-DIR* for the same reasoning.")

(defun run-headless-startup-check ()
  "Runs COTD-INIT exactly as COTD-MAIN does (SDL:WITH-INIT, then COTD-INIT),
with SDL_VIDEODRIVER=dummy so it needs no real display, and *USER-DIR*
pointed outside the repo. Signals whatever error COTD-INIT signals - callers
want it to fail loudly, not report T/NIL - and otherwise returns T, having
confirmed *WINDOW-WIDTH*/*WINDOW-HEIGHT*/*GLYPH-FRONT*/*START-LOGO* all ended
up bound. Run this first after any change to COTD-INIT, INIT-GLYPH-FRONT, or
their call order - it is cheap and it is the only oracle here that would have
caught the startup-ordering bug described above."
  (sb-posix:setenv "SDL_VIDEODRIVER" "dummy" 1)
  (ensure-directories-exist *headless-startup-user-dir*)
  (let ((*user-dir* *headless-startup-user-dir*))
    (cotd-render:with-init ()
      (cotd-init)
      (unless (and (boundp '*window-width*) (plusp *window-width*)
                   (boundp '*window-height*) (plusp *window-height*)
                   (boundp '*glyph-front*) *glyph-front*
                   (boundp '*start-logo*) *start-logo*)
        (error "RUN-HEADLESS-STARTUP-CHECK: COTD-INIT returned without setting up render state"))
      t)))

;;; ---------------------------------------------------------------------
;;; Deliverable 5: golden screens (sdl2 migration, phase 0).
;;;
;;; RENDER-CHECKSUM only covers the map area and only answers "same or not".
;;; Moving the render backend off lispbuilder-sdl touches everything drawn:
;;; text in both fonts, the logo, rectangles, every window's layout. So this
;;; renders a fixed set of whole screens through COTD-INIT and each window's
;;; real MAKE-OUTPUT, and saves each as an RGB PPM file. The old and the new
;;; backend cannot be loaded into one process (SDL 1.2 and SDL2 export the
;;; same C symbol names), so the files are what carries the baseline across
;;; builds: CAPTURE-GOLDEN-SCREENS on the code before a change, then
;;; COMPARE-GOLDEN-SCREENS after it. They are written to test/golden/, which
;;; is gitignored: baselines are captured locally, never committed.
;;;
;;; Pixels are stored decoded to 8-bit RGB, not as raw surface values, so the
;;; files do not depend on whichever pixel format a backend picks.
;;; ---------------------------------------------------------------------

(defparameter *golden-dir* (asdf:system-relative-pathname :cotd "../test/golden/")
  "Where CAPTURE-GOLDEN-SCREENS writes, and COMPARE-GOLDEN-SCREENS reads, the
baseline PPM files.")

(defparameter *golden-user-dir* (merge-pathnames "cotd-headless-golden-oracle/" (uiop:temporary-directory))
  "*USER-DIR* for a golden run: holds the options.cfg that selects the font,
and keeps COTD-INIT's highscores writes out of the repo.")

(defparameter *golden-fonts* '(font-6x13 font-8x13)
  "Both font options, since the font also decides the window size and every
text-based layout.")

(defparameter *golden-level-seeds* '(1 2 3))

(defun write-ppm (path bytes w h)
  (ensure-directories-exist path)
  (with-open-file (s path :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
    (write-sequence (map '(vector (unsigned-byte 8)) #'char-code (format nil "P6~%~D ~D~%255~%" w h)) s)
    (write-sequence bytes s))
  path)

(defun read-ppm (path)
  "Inverse of WRITE-PPM (binary P6, maxval 255, no comments). Returns BYTES, W, H."
  (with-open-file (s path :element-type '(unsigned-byte 8))
    (flet ((next-token ()
             (loop for c = (read-byte s)
                   while (member c '(9 10 13 32)))
             (file-position s (1- (file-position s)))
             (let ((chars (loop for c = (read-byte s)
                                until (member c '(9 10 13 32))
                                collect (code-char c))))
               (coerce chars 'string))))
      (unless (string= (next-token) "P6")
        (error "READ-PPM: ~A is not a binary PPM" path))
      (let* ((w (parse-integer (next-token)))
             (h (parse-integer (next-token)))
             (maxval (parse-integer (next-token)))
             (bytes (make-array (* w h 3) :element-type '(unsigned-byte 8))))
        (unless (= maxval 255)
          (error "READ-PPM: ~A has maxval ~A, expected 255" path maxval))
        (read-sequence bytes s)
        (values bytes w h)))))

(defun golden-screen-specs ()
  "The screens to capture, as (NAME . THUNK). Each thunk sets up whatever state
its window needs, sets *CURRENT-WINDOW*, and calls MAKE-OUTPUT; the caller then
reads the window's surface. Thunks run in order, after COTD-INIT, so the
level-based ones see the level the GOLDEN-LEVEL-n thunk before them generated."
  (flet ((show (win)
           (setf *current-window* win)
           (make-output win)))
    (append
     (list (cons "main-menu" (lambda () (show (make-instance 'main-menu-window))))
           (cons "highscores" (lambda () (show (make-instance 'highscores-window))))
           (cons "help" (lambda () (show (make-instance 'help-window))))
           (cons "input-str" (lambda ()
                               (show (make-instance 'input-str-window
                                                    :init-input "Golden"
                                                    :header-str "Choose name"
                                                    :main-str "Enter you name"
                                                    :prompt-str "[Enter] Confirm"))))
           (cons "display-msg" (lambda ()
                                 (show (make-instance 'display-msg-window
                                                      :msg-line "ERROR: a golden-screen test message, long enough to wrap across more than one line of the box."
                                                      :w (truncate (* *window-width* 2) 3)
                                                      :prompt-line "[Esc] Exit")))))
     (loop for seed in *golden-level-seeds*
           collect (let ((seed seed))
                     (cons (format nil "level-~D" seed)
                           (lambda ()
                             (generate-headless-level +specific-faction-type-player+ :seed seed)
                             (update-visible-mobs *player*)
                             (update-visible-area (level *world*) (x *player*) (y *player*) (z *player*))
                             (show (make-instance 'cell-window))))))
     ;; these read *PLAYER*/*WORLD*, i.e. the last level generated above
     (list (cons "character" (lambda () (show (make-instance 'character-window :return-to nil))))
           (cons "inventory" (lambda ()
                               ;; the selected item (the coin, first in the list) has
                               ;; a flavor quote, which is the only text drawn in the
                               ;; outlined *FONT-6X13O*/*FONT-8X13O* fonts
                               (dolist (item-type (list +item-type-smoke-bomb+ +item-type-medkit+ +item-type-coin+))
                                 (setf (inv *player*)
                                       (add-to-inv (make-instance 'item :item-type item-type :x (x *player*) :y (y *player*) :z (z *player*) :qty 3)
                                                   (inv *player*) (id *player*))))
                               (show (make-instance 'inventory-window :return-to nil))))
           (cons "journal" (lambda () (show (make-instance 'journal-window :return-to nil))))
           (cons "select-obj" (lambda ()
                                (show (make-instance 'select-obj-window
                                                     :return-to nil
                                                     :header-line "Are you sure you want to delete this game?"
                                                     :line-list (list "Yes" "No")
                                                     :prompt-list ()
                                                     :enter-func (lambda (cur-sel) (declare (ignore cur-sel)) nil)))))))))

(defun golden-screen-name (font name)
  (format nil "~(~A~)-~A" font name))

(defun call-with-golden-screens (fn)
  "For each font in *GOLDEN-FONTS*: fresh SDL init with the dummy driver,
COTD-INIT with that font selected, then each of GOLDEN-SCREEN-SPECS, calling
FN with the screen's full name and its RGB BYTES, W, H. A screen whose thunk
signals an error is reported to FN with BYTES = the condition, so one broken
window doesn't hide the rest."
  (sb-posix:setenv "SDL_VIDEODRIVER" "dummy" 1)
  (ensure-directories-exist *golden-user-dir*)
  (dolist (font *golden-fonts*)
    (with-open-file (s (merge-pathnames "options.cfg" *golden-user-dir*) :direction :output :if-exists :supersede)
      (format s "(font ~(~A~))~%(name \"Golden\")~%" font))
    ;; *COTD-RELEASE* hides the main menu's debug entries. GENERATE-HEADLESS-LEVEL
    ;; sets it globally, so without this binding the main menu came out
    ;; differently depending on whether anything had generated a level earlier
    ;; in the same process. Bound to T: capture what a player sees.
    (let ((*user-dir* *golden-user-dir*)
          (*current-window* nil)
          (*cotd-release* t))
      (cotd-render:with-init ()
        (cotd-init)
        (dolist (spec (golden-screen-specs))
          (let ((name (golden-screen-name font (car spec))))
            ;; screens must not depend on anything random left over from the
            ;; previous one (COTD-INIT seeds *RANDOM-STATE* from the clock)
            (setf *random-state* (sb-ext:seed-random-state 0))
            (handler-case
                (progn
                  (funcall (cdr spec))
                  ;; lispbuilder-sdl leaves *DEFAULT-SURFACE* NIL and draws to
                  ;; the window (*DEFAULT-DISPLAY*) when a surface argument is NIL
                  (multiple-value-bind (bytes w h) (cotd-render:surface-rgb-bytes (or cotd-render:*default-surface* sdl:*default-display*))
                    (funcall fn name bytes w h)))
              (error (c) (funcall fn name c nil nil)))))))))

(defun capture-golden-screens (&key (dir *golden-dir*))
  "Render every golden screen and write it to DIR as <font>-<screen>.ppm.
Run this on the code before a change. Returns the list of
(NAME :OK) / (NAME :ERROR condition-text)."
  (let ((results ()))
    (call-with-golden-screens
     (lambda (name bytes w h)
       (if (typep bytes 'condition)
           (push (list name :error (princ-to-string bytes)) results)
           (progn
             (write-ppm (merge-pathnames (format nil "~A.ppm" name) dir) bytes w h)
             (push (list name :ok) results)))))
    (nreverse results)))

(defun compare-golden-screens (&key (dir *golden-dir*) (write-actual t))
  "Render every golden screen and compare it pixel for pixel with DIR's PPM.
Returns a list of (NAME STATUS . DETAILS), STATUS one of :SAME, :SIZE (window
size differs), :DIFF (with the differing-pixel count and the first differing
x y), :MISSING (no baseline file) or :ERROR. With WRITE-ACTUAL, every screen
that is not :SAME is also written as <name>.actual.ppm next to the baseline,
for looking at."
  (let ((results ()))
    (call-with-golden-screens
     (lambda (name bytes w h)
       (let ((path (merge-pathnames (format nil "~A.ppm" name) dir)))
         (push
          (cond
            ((typep bytes 'condition) (list name :error (princ-to-string bytes)))
            ((not (probe-file path)) (list name :missing))
            (t (multiple-value-bind (gold gw gh) (read-ppm path)
                 (if (or (/= w gw) (/= h gh))
                     (list name :size (list gw gh) (list w h))
                     (let ((count 0) (first-diff nil))
                       (loop for i from 0 below (* w h)
                             unless (and (= (aref bytes (* 3 i)) (aref gold (* 3 i)))
                                         (= (aref bytes (+ 1 (* 3 i))) (aref gold (+ 1 (* 3 i))))
                                         (= (aref bytes (+ 2 (* 3 i))) (aref gold (+ 2 (* 3 i)))))
                               do (incf count)
                                  (unless first-diff
                                    (setf first-diff (list (mod i w) (floor i w)))))
                       (if (zerop count)
                           (list name :same)
                           (list name :diff count first-diff)))))))
          results)
         (when (and write-actual bytes (not (typep bytes 'condition))
                    (not (eq (second (first results)) :same)))
           (write-ppm (merge-pathnames (format nil "~A.actual.ppm" name) dir) bytes w h)))))
    (nreverse results)))
