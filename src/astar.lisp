;; by Thomas Daniel Lowe, dlowe@bitmuse.com
;; edited by Gwathlobal

(in-package :cotd)

(defstruct node
  (x-pos 0 :type fixnum)
  (y-pos 0 :type fixnum)
  (z-pos 0 :type fixnum)
  (parent nil)
  (g-val 0)
  (f-val 0))

(defvar *h-func*)

(defun make-new-node (parent x y z end-x end-y end-z g-val)
  (declare (type fixnum x y z end-x end-y end-z))
  (make-node :x-pos x :y-pos y :z-pos z :parent parent
             :g-val (if parent
                      (+ (node-g-val parent) g-val)
                      0)
             :f-val (+ (if parent (+ (node-g-val parent) g-val) 0) (funcall *h-func* x y z end-x end-y end-z))))

(defun pos-equal (node-a node-b)
  "Returns true if node-a references the same position as node-b.  Otherwise, returns NIL."
  (and (= (node-x-pos node-a) (node-x-pos node-b))
       (= (node-y-pos node-a) (node-y-pos node-b))
       (= (node-z-pos node-a) (node-z-pos node-b))))

;;; ------------------------------------------------------------------
;;; Coordinate -> node hash tables for the open/closed sets.
;;;
;;; The old implementation kept OPEN-NODES/CLOSED-NODES as plain lists
;;; and used FIND-NODE-WITH-COORDS (a linear scan) to check whether a
;;; neighbor coordinate was already open/closed.  That made every node
;;; expansion O(n) in the number of nodes visited so far, and the whole
;;; search O(n^2).  A hash table keyed on the packed coordinate makes
;;; that check O(1).
;;; ------------------------------------------------------------------

(declaim (inline node-coord-key))
(defun node-coord-key (x y z)
  (declare (type fixnum x y z))
  "Packs X, Y, Z into a single non-negative fixnum for use as a hash key.
Each axis is masked to 20 bits (0..1048575), which comfortably covers
any realistic level size and is safe even for the transient,
possibly out-of-bounds neighbor coordinates that get looked up before
VALID-FUNC has a chance to reject them."
  (the fixnum (logior (ash (logand x #xFFFFF) 40)
                       (ash (logand y #xFFFFF) 20)
                       (logand z #xFFFFF))))

;;; ------------------------------------------------------------------
;;; A tiny array-backed binary min-heap keyed on NODE-F-VAL.
;;;
;;; The old implementation re-sorted the entire open list on every
;;; single node expansion ((sort open-nodes #'< :key #'node-f-val)),
;;; which is O(n log n) per pop instead of per search. A binary heap
;;; makes push/pop O(log n).
;;; ------------------------------------------------------------------

(defstruct node-heap
  (data (make-array 64 :adjustable t :fill-pointer 0) :type (array t (*))))

(declaim (inline heap-count))
(defun heap-count (heap)
  (declare (type node-heap heap))
  (fill-pointer (node-heap-data heap)))

(defun heap-push (heap node)
  (declare (optimize (speed 3) (safety 0))
           (type node-heap heap))
  (let ((data (node-heap-data heap)))
    (vector-push-extend node data)
    (let ((i (1- (fill-pointer data))))
      (declare (type fixnum i))
      (loop while (> i 0)
            for parent of-type fixnum = (ash (1- i) -1)
            while (< (node-f-val (aref data i)) (node-f-val (aref data parent)))
            do
               (rotatef (aref data i) (aref data parent))
               (setf i parent))))
  (values))

(defun heap-pop (heap)
  (declare (optimize (speed 3) (safety 0))
           (type node-heap heap))
  (let* ((data (node-heap-data heap))
         (n (fill-pointer data))
         (top (aref data 0)))
    (declare (type fixnum n))
    (setf (aref data 0) (aref data (1- n)))
    (decf (fill-pointer data))
    (decf n)
    (let ((i 0))
      (declare (type fixnum i))
      (loop
        (let ((l (+ (* i 2) 1)) (r (+ (* i 2) 2)) (smallest i))
          (declare (type fixnum l r smallest))
          (when (and (< l n) (< (node-f-val (aref data l)) (node-f-val (aref data smallest))))
            (setf smallest l))
          (when (and (< r n) (< (node-f-val (aref data r)) (node-f-val (aref data smallest))))
            (setf smallest r))
          (when (= smallest i) (return))
          (rotatef (aref data i) (aref data smallest))
          (setf i smallest))))
    top))

(defun a-star (start-coord goal-coord valid-func cost-func)
  (declare (optimize (speed 3) (safety 0))
           (type function valid-func cost-func))
  "   An implementation of the A* pathfinding algorithm by Daniel Lowe.
Given a 2 element list of START-COORD and GOAL-COORD, returns a list
of coordinates which form a path between them.  VALID-FUNC should
return t if a particular node should be considered as part of the
path, nil if not.  G-FUNC should return the distance of the given
path so far.  H-FUNC should return an estimate of the distance to
the goal, and may depend on many factors"
  (let* ((open-heap (make-node-heap))
         (open-table (make-hash-table :test 'eql))
         (closed-table (make-hash-table :test 'eql))
         (found-node nil)
         (start-node (make-new-node nil
                                (first start-coord)
                                (second start-coord)
                                (third start-coord)
                                (first goal-coord)
                                (second goal-coord)
                                (third goal-coord)
                                (funcall cost-func (first start-coord) (second start-coord) (third start-coord))
                                ))
         (goal-node (make-new-node nil
                               (first goal-coord)
                               (second goal-coord)
                               (third goal-coord)
                               (first goal-coord)
                               (second goal-coord)
                               (third goal-coord)
                               (funcall cost-func (first goal-coord) (second goal-coord) (third goal-coord))
                               )))
    ;; The open set starts with the beginning coordinate
    (heap-push open-heap start-node)
    (setf (gethash (node-coord-key (node-x-pos start-node) (node-y-pos start-node) (node-z-pos start-node)) open-table)
          start-node)

    ;; Pop open nodes to check until we reach the goal coordinate.  The
    ;; heap has no decrease-key, so an improved path to an already-open
    ;; coordinate is handled by lazy deletion: push a second, better node
    ;; for that key and let a stale pop of the old one be skipped via the
    ;; closed-table check below.  OPEN-TABLE always holds the *best* node
    ;; found so far for its key, which is what the "already open" check
    ;; needs to compare against.
    (loop while (> (heap-count open-heap) 0)
          for node = (heap-pop open-heap)
          for node-key of-type fixnum = (node-coord-key (node-x-pos node) (node-y-pos node) (node-z-pos node))
          unless (gethash node-key closed-table)
            do
             (when (pos-equal node goal-node)
               (setf found-node node)
               (return))

             ;; Check all the adjacent coordinates.  This method counts
             ;; diagonals as well.  If you don't want diagonals, you can
             ;; change it here, or you can check it with the valid-func
             (loop for (x-offset y-offset z-offset) of-type (fixnum fixnum fixnum) in '((-1 -1 -1) (-1 0 -1) (-1 1 -1) (0 -1 -1) (0 0 -1) (0 1 -1) (1 -1 -1) (1 0 -1) (1 1 -1)
                                                                                         (-1 -1 0) (-1 0 0) (-1 1 0) (0 -1 0) (0 0 0) (0 1 0) (1 -1 0) (1 0 0) (1 1 0)
                                                                                         (-1 -1 1) (-1 0 1) (-1 1 1) (0 -1 1) (0 0 1) (0 1 1) (1 -1 1) (1 0 1) (1 1 1))
                   for x of-type fixnum = (+ (node-x-pos node) x-offset)
                   for y of-type fixnum = (+ (node-y-pos node) y-offset)
                   for z of-type fixnum = (+ (node-z-pos node) z-offset)
                   for key of-type fixnum = (node-coord-key x y z)
                   unless (and (zerop x-offset) (zerop y-offset) (zerop z-offset))
                     ;; don't need to check already closed nodes
                     unless (gethash key closed-table)
                       ;; only check valid coordinates
                       when (funcall valid-func x y z (node-x-pos node) (node-y-pos node) (node-z-pos node))
                         do
                            (let ((new-node (make-new-node node x y z (first goal-coord) (second goal-coord) (third goal-coord) (funcall cost-func x y z)))
                                  (existing (gethash key open-table)))
                              ;; Only push if this is the first time we've
                              ;; reached KEY, or if it improves on the best
                              ;; G-VAL seen for it so far - needed because
                              ;; +terrain-trait-move-cost-factor+ makes step
                              ;; cost non-uniform, so the first path found
                              ;; to a node is not guaranteed to be cheapest.
                              (when (or (not existing) (< (node-g-val new-node) (node-g-val existing)))
                                (heap-push open-heap new-node)
                                (setf (gethash key open-table) new-node))))

             ;; We exhausted the possibilities of this node, so add it
             ;; to the closed nodes
             (setf (gethash node-key closed-table) node))

    ;; If a goal node was found, we traverse its parent chain in
    ;; reverse to obtain our path.
    (when found-node
      (loop for trail = found-node then (node-parent trail)
         until (pos-equal trail start-node)
         collect (list (node-x-pos trail) (node-y-pos trail) (node-z-pos trail)) into result
         finally (return (cons start-coord (nreverse result)))))))

(defun diagonal (cur-x cur-y end-x end-y)
  (let* ((dx (abs (- cur-x end-x)))
	 (dy (abs (- cur-y end-y)))
	 (diag (min dx dy))
	 (straight (+ dx dy)))
    (+ (* (sqrt 2) diag) (* 1 (- straight (* 2 diag))))))

(defun path-distance (cur-x cur-y cur-z end-x end-y end-z)
  "Chebyshev distance: admissible for 26-way diagonal movement, where a
single step can reduce every axis by 1 at once. Manhattan (dx+dy+dz)
over-estimates a diagonal step by up to 3x, making A* non-optimal."
  (declare (type fixnum cur-x cur-y cur-z end-x end-y end-z))
  (let ((dx (abs (- cur-x end-x)))
        (dy (abs (- cur-y end-y)))
        (dz (abs (- cur-z end-z))))
    (max dx dy dz)))

(setf *h-func* #'path-distance)
