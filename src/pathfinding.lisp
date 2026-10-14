;;;; Weighted grid pathfinding over a level's 26-neighbourhood.
;;;;
;;;; This is the game's own implementation, written against the plain
;;;; description of best-first search; it shares no code with any third-party
;;;; pathfinder.
;;;;
;;;; Shape of the search:
;;;;  - A cell is identified by a single packed fixnum (CELL-KEY), so all of the
;;;;    per-cell bookkeeping lives in three EQL hash tables rather than in
;;;;    allocated node objects: cheapest cost known, previous cell, and whether
;;;;    the cell has already been expanded.
;;;;  - The frontier is an array-backed binary min-heap (CELL-QUEUE) over
;;;;    parallel simple vectors - one of keys, one of priorities.
;;;;  - The heap has no decrease-key. An improved route to a cell that is still
;;;;    on the frontier is handled by inserting a second, cheaper entry for it;
;;;;    the stale entry is discarded when it surfaces, because its cell is
;;;;    already marked expanded by then.
;;;;  - Step costs are whatever the caller's COST-FN returns, and priorities
;;;;    are compared with generic < rather than coerced to floats. The AI's
;;;;    cost-fn (ai-common.lisp) divides a terrain factor by +NORMAL-AP+, which
;;;;    is an exact ratio for every terrain but water, whose factor is itself a
;;;;    float (*WATER-MOVE-FACTOR*) - so a priority is a ratio on land and a
;;;;    single-float in water.
;;;;
;;;; That last point is why the three functions below ask the compiler not to
;;;; report its optimization notes: at (SPEED 3) SBCL quite correctly points
;;;; out that it cannot open-code arithmetic on a value that is sometimes a
;;;; rational and sometimes a float, and there is nothing to fix short of
;;;; giving up either the exactness of the land costs or the fractional water
;;;; cost. The muffling is per-function on purpose, so a new note anywhere else
;;;; in the file still gets reported.

(in-package :cotd)

;;; 20 bits per axis, each biased by half its range before packing. The bias is
;;; what lets the transient, out-of-bounds coordinates produced while scanning a
;;; border cell's neighbourhood round-trip through a key: they get looked up in
;;; the tables before PASSABLE-FN ever sees them. Three biased 20-bit fields fit
;;; in 60 bits, well inside a 62-bit SBCL fixnum.

(defconstant +cell-key-bits+ 20)
(defconstant +cell-key-bias+ (ash 1 (1- +cell-key-bits+)))
(defconstant +cell-key-mask+ (1- (ash 1 +cell-key-bits+)))

(declaim (inline cell-key cell-key-x cell-key-y cell-key-z chebyshev-distance))

(defun cell-key (x y z)
  "Pack the cell <X, Y, Z> into one fixnum usable as an EQL hash key."
  (declare (type fixnum x y z))
  (the fixnum
       (logior (ash (logand (+ x +cell-key-bias+) +cell-key-mask+) (* 2 +cell-key-bits+))
               (ash (logand (+ y +cell-key-bias+) +cell-key-mask+) +cell-key-bits+)
               (logand (+ z +cell-key-bias+) +cell-key-mask+))))

(defun cell-key-x (key)
  (declare (type fixnum key))
  (the fixnum (- (logand (ash key (- (* 2 +cell-key-bits+))) +cell-key-mask+) +cell-key-bias+)))

(defun cell-key-y (key)
  (declare (type fixnum key))
  (the fixnum (- (logand (ash key (- +cell-key-bits+)) +cell-key-mask+) +cell-key-bias+)))

(defun cell-key-z (key)
  (declare (type fixnum key))
  (the fixnum (- (logand key +cell-key-mask+) +cell-key-bias+)))

(defun chebyshev-distance (x y z goal-x goal-y goal-z)
  "Steps needed to reach <GOAL-X, GOAL-Y, GOAL-Z> from <X, Y, Z> when a single
step may change all three axes at once - the largest per-axis gap. Manhattan
distance would charge up to 3 for one diagonal step and so over-estimate."
  (declare (type fixnum x y z goal-x goal-y goal-z))
  (the fixnum (max (abs (- x goal-x)) (abs (- y goal-y)) (abs (- z goal-z)))))

;;; ------------------------------------------------------------------
;;; Frontier: binary min-heap of cell keys ordered by priority.
;;; ------------------------------------------------------------------

(defstruct (cell-queue (:constructor make-cell-queue ()))
  (keys (make-array 256 :element-type 'fixnum) :type (simple-array fixnum (*)))
  (ranks (make-array 256 :initial-element 0) :type simple-vector)
  (size 0 :type fixnum))

(defun cell-queue-expand (queue)
  "Double the backing vectors of QUEUE, preserving the heap."
  (declare (type cell-queue queue))
  (let* ((room (* 2 (length (cell-queue-keys queue))))
         (keys (make-array room :element-type 'fixnum))
         (ranks (make-array room :initial-element 0)))
    (replace keys (cell-queue-keys queue))
    (replace ranks (cell-queue-ranks queue))
    (setf (cell-queue-keys queue) keys
          (cell-queue-ranks queue) ranks))
  (values))

(defun cell-queue-insert (queue key rank)
  "Add KEY to QUEUE under priority RANK, then float it up to its place."
  (declare (optimize (speed 3) (safety 0))
           (type cell-queue queue)
           (type fixnum key)
           ;; priorities are rational-or-float: see the note at the top
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (when (= (cell-queue-size queue) (length (cell-queue-keys queue)))
    (cell-queue-expand queue))
  (let ((keys (cell-queue-keys queue))
        (ranks (cell-queue-ranks queue))
        (slot (cell-queue-size queue)))
    (declare (type fixnum slot))
    (setf (aref keys slot) key
          (svref ranks slot) rank
          (cell-queue-size queue) (1+ slot))
    (loop
      (when (zerop slot) (return))
      (let ((above (ash (1- slot) -1)))
        (declare (type fixnum above))
        (when (>= (svref ranks slot) (svref ranks above)) (return))
        (rotatef (aref keys slot) (aref keys above))
        (rotatef (svref ranks slot) (svref ranks above))
        (setf slot above))))
  (values))

(defun cell-queue-take (queue)
  "Remove and return the key of QUEUE's cheapest entry. QUEUE must not be empty."
  (declare (optimize (speed 3) (safety 0))
           (type cell-queue queue)
           ;; priorities are rational-or-float: see the note at the top
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (let* ((keys (cell-queue-keys queue))
         (ranks (cell-queue-ranks queue))
         (cheapest (aref keys 0))
         (last (1- (cell-queue-size queue))))
    (declare (type fixnum cheapest last))
    ;; Move the tail entry to the root, drop the tail, then sink the root.
    (setf (aref keys 0) (aref keys last)
          (svref ranks 0) (svref ranks last)
          (svref ranks last) 0
          (cell-queue-size queue) last)
    (let ((slot 0))
      (declare (type fixnum slot))
      (loop
        (let ((left (+ (* 2 slot) 1))
              (winner slot))
          (declare (type fixnum left winner))
          (when (and (< left last) (< (svref ranks left) (svref ranks winner)))
            (setf winner left))
          (let ((right (1+ left)))
            (declare (type fixnum right))
            (when (and (< right last) (< (svref ranks right) (svref ranks winner)))
              (setf winner right)))
          (when (= winner slot) (return))
          (rotatef (aref keys slot) (aref keys winner))
          (rotatef (svref ranks slot) (svref ranks winner))
          (setf slot winner))))
    cheapest))

;;; ------------------------------------------------------------------
;;; The search itself.
;;; ------------------------------------------------------------------

(defun retrace-route (came-from goal-key start-key)
  "Walk CAME-FROM backwards from GOAL-KEY to START-KEY and return the cells in
travel order, START-KEY's cell first."
  (declare (type hash-table came-from)
           (type fixnum goal-key start-key))
  (let ((route nil)
        (key goal-key))
    (declare (type fixnum key))
    (loop until (= key start-key)
          do (push (list (cell-key-x key) (cell-key-y key) (cell-key-z key)) route)
             (setf key (the fixnum (gethash key came-from))))
    (cons (list (cell-key-x start-key) (cell-key-y start-key) (cell-key-z start-key))
          route)))

(defun find-path (start goal passable-fn cost-fn)
  "Cheapest route from START to GOAL as a list of (X Y Z) cells, START first and
GOAL last, or NIL when no route exists.

START and GOAL are (X Y Z) lists. PASSABLE-FN is called as
(PASSABLE-FN to-x to-y to-z from-x from-y from-z) and says whether that one step
may be taken; it is the only thing keeping the search inside the level, so it
must reject out-of-bounds coordinates. COST-FN is called as (COST-FN x y z) and
returns the cost of entering that cell.

Cells are expanded cheapest-estimate-first, the estimate being cost-so-far plus
CHEBYSHEV-DISTANCE to GOAL. That estimate never exceeds the true remaining cost
as long as COST-FN stays at or above 1 per step, so the first route to reach
GOAL is a cheapest one. A COST-FN that can dip below 1 still terminates and
still returns a route, just not necessarily the cheapest."
  (declare (optimize (speed 3) (safety 0))
           (type function passable-fn cost-fn)
           ;; costs are rational-or-float: see the note at the top
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (let* ((frontier (make-cell-queue))
         (cheapest (make-hash-table :test 'eql))  ; cell -> best cost known to reach it
         (came-from (make-hash-table :test 'eql)) ; cell -> cell it was reached from
         (expanded (make-hash-table :test 'eql))  ; cell -> T once its neighbours were scanned
         (goal-x (first goal))
         (goal-y (second goal))
         (goal-z (third goal))
         (start-key (cell-key (first start) (second start) (third start))))
    (declare (type fixnum goal-x goal-y goal-z start-key))
    (setf (gethash start-key cheapest) 0)
    (cell-queue-insert frontier start-key
                       (chebyshev-distance (first start) (second start) (third start)
                                           goal-x goal-y goal-z))
    (labels ((reach (from-key from-x from-y from-z spent nx ny nz)
               ;; Consider the single step from <FROM-X, FROM-Y, FROM-Z>, reached
               ;; at cost SPENT, into <NX, NY, NZ>.
               (declare (type fixnum from-key from-x from-y from-z nx ny nz))
               (let ((nkey (cell-key nx ny nz)))
                 (declare (type fixnum nkey))
                 (when (and (not (gethash nkey expanded))
                            (funcall passable-fn nx ny nz from-x from-y from-z))
                   (let ((cost (+ spent (funcall cost-fn nx ny nz)))
                         (known (gethash nkey cheapest)))
                     ;; Step costs are not uniform (terrain carries
                     ;; +terrain-trait-move-cost-factor+), so the first route
                     ;; found to a cell need not be its cheapest one: keep
                     ;; relaxing it until it is expanded.
                     (when (or (null known) (< cost known))
                       (setf (gethash nkey cheapest) cost
                             (gethash nkey came-from) from-key)
                       (cell-queue-insert frontier nkey
                                          (+ cost (chebyshev-distance nx ny nz
                                                                      goal-x goal-y goal-z))))))))
             (expand (key)
               ;; Scan the 26 cells around KEY, skipping KEY itself.
               (declare (type fixnum key))
               (let ((x (cell-key-x key))
                     (y (cell-key-y key))
                     (z (cell-key-z key))
                     (spent (gethash key cheapest)))
                 (declare (type fixnum x y z))
                 (loop for dz of-type fixnum from -1 to 1
                       do (loop for dx of-type fixnum from -1 to 1
                                do (loop for dy of-type fixnum from -1 to 1
                                         unless (and (zerop dx) (zerop dy) (zerop dz))
                                           do (reach key x y z spent
                                                     (+ x dx) (+ y dy) (+ z dz))))))))
      (loop
        (when (zerop (cell-queue-size frontier))
          (return nil))
        (let ((key (cell-queue-take frontier)))
          (declare (type fixnum key))
          ;; A cell can sit in the frontier more than once; only its cheapest
          ;; entry, which surfaces first, is worth expanding.
          (unless (gethash key expanded)
            (setf (gethash key expanded) t)
            (when (and (= (cell-key-x key) goal-x)
                       (= (cell-key-y key) goal-y)
                       (= (cell-key-z key) goal-z))
              (return (retrace-route came-from key start-key)))
            (expand key)))))))
