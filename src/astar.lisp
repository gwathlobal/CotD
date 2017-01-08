;; by Thomas Daniel Lowe, dlowe@bitmuse.com
;; edited by Gwathlobal

(in-package :cotd)

(defstruct node
  (x-pos 0 :type fixnum)
  (y-pos 0 :type fixnum)
  (parent nil)
  (g-val 0 :type fixnum)
  (f-val 0 :type fixnum))
   
(defvar *h-func*)

(defun make-new-node (parent x y end-x end-y)
  (declare (type fixnum x y end-x end-y))
  (make-node :x-pos x :y-pos y :parent parent 
             :g-val (if parent 
                      (+ (node-g-val parent) 1)
                      0)
             :f-val (+ (if parent (+ (node-g-val parent) 1) 0) (funcall *h-func* x y end-x end-y))))

(defun pos-equal (node-a node-b)
  "Returns true if node-a references the same position as node-b.  Otherwise, returns NIL."
  (and (= (node-x-pos node-a) (node-x-pos node-b))
       (= (node-y-pos node-a) (node-y-pos node-b))))

(defun find-node-with-coords (x y node-list)
  "Returns the node in NODE-LIST with the coordinates <X, Y>.  Returns NIL if no such node was found."
  (find-if (lambda (node)
	     (and (= (node-x-pos node) x) (= (node-y-pos node) y)))
	   node-list))

(defun a-star (start-coord goal-coord valid-func)
  (declare (optimize (speed 3))
           (type function valid-func))
  "   An implementation of the A* pathfinding algorithm by Daniel Lowe.
Given a 2 element list of START-COORD and GOAL-COORD, returns a list
of coordinates which form a path between them.  VALID-FUNC should
return t if a particular node should be considered as part of the
path, nil if not.  G-FUNC should return the distance of the given
path so far.  H-FUNC should return an estimate of the distance to
the goal, and may depend on many factors"
  (let* ((open-nodes '())
	 (closed-nodes '())
	 (start-node (make-new-node nil
				(first start-coord)
				(second start-coord)
				(first goal-coord)
				(second goal-coord)))
	 (goal-node (make-new-node nil
			       (first goal-coord)
			       (second goal-coord)
			       (first goal-coord)
			       (second goal-coord))))
    (declare (type list open-nodes closed-nodes))
    ;; The list of open nodes starts with the beginning coordinate
    (push start-node open-nodes)
    ;; Pop open nodes to check until we reach the goal coordinate
    (loop for node = (first open-nodes)
       while (and node (not (pos-equal node goal-node))) do
	 
	 (pop open-nodes)
       ;; Check all the adjacent coordinates.  This method counts
       ;; diagonals as well.  If you don't want diagonals, you can
       ;; change it here, or you can check it with the valid-func
	 (loop for y-offset of-type fixnum from -1 to 1
               as y of-type fixnum = (+ (node-y-pos node) y-offset) do
               (loop for x-offset of-type fixnum from -1 to 1
		 as x of-type fixnum = (+ (node-x-pos node) x-offset)
		 ;; don't need to check the node itself
		 unless (and (zerop x-offset) (zerop y-offset))
		 ;; don't need to check already closed nodes
		 unless (find-node-with-coords x y closed-nodes)
		 ;; don't need to find already open nodes, either
		 unless (find-node-with-coords x y open-nodes)
		 ;; only check valid coordinates
		 when (funcall valid-func x y) do
   		   (push (make-new-node node x y (first goal-coord) (second goal-coord)) open-nodes)))
       ;; We exhausted the possibilities of this node, so add it
       ;; to the closed nodes
	 (push node closed-nodes)
       ;; If node-f increments steadily, we don't need to do
       ;; this. However, we can't really count on it in a generic
       ;; solution.
	 (setf open-nodes (sort open-nodes #'< :key #'node-f-val)))
    
    ;; If open-nodes is non-empty, a solution was found.  We
    ;; traverse them in reverse to obtain our path.
    (when open-nodes
      (loop for trail = (first open-nodes) then (node-parent trail)
	 until (pos-equal trail start-node)
	 collect (list (node-x-pos trail) (node-y-pos trail)) into result
	 finally (return (cons start-coord (nreverse result)))))))

(defun diagonal (cur-x cur-y end-x end-y)
  (let* ((dx (abs (- cur-x end-x)))
	 (dy (abs (- cur-y end-y)))
	 (diag (min dx dy)) 
	 (straight (+ dx dy)))
    (+ (* (sqrt 2) diag) (* 1 (- straight (* 2 diag))))))

(defun path-distance (cur-x cur-y end-x end-y)
  (declare (type fixnum cur-x cur-y end-x end-y))
  (let ((dx (abs (- cur-x end-x)))
        (dy (abs (- cur-y end-y))))
    (+ dx dy)))

(setf *h-func* #'path-distance)
