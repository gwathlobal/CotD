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

(defun find-node-with-coords (x y z node-list)
  "Returns the node in NODE-LIST with the coordinates <X, Y, Z>.  Returns NIL if no such node was found."
  (find-if (lambda (node)
	     (and (= (node-x-pos node) x) (= (node-y-pos node) y) (= (node-z-pos node) z)))
	   node-list))

(defun a-star (start-coord goal-coord valid-func cost-func)
  (declare (optimize (speed 3))
           (type function valid-func cost-func))
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
    (declare (type list open-nodes closed-nodes))
    ;; The list of open nodes starts with the beginning coordinate
    (push start-node open-nodes)
    ;; Pop open nodes to check until we reach the goal coordinate
    (loop for node = (first open-nodes)
          while (and node (not (pos-equal node goal-node))) do

            (format t "OPEN-NODES = ~A~%" (length open-nodes))
            (format t "CLOSED-NODES = ~A~%~%" (length closed-nodes))
            
            (pop open-nodes)
            ;; Check all the adjacent coordinates.  This method counts
            ;; diagonals as well.  If you don't want diagonals, you can
            ;; change it here, or you can check it with the valid-func
            (loop for y-offset of-type fixnum from -1 to 1
                  as y of-type fixnum = (+ (node-y-pos node) y-offset) do
                  (loop for x-offset of-type fixnum from -1 to 1
                        as x of-type fixnum = (+ (node-x-pos node) x-offset) do
                        (loop for z-offset of-type fixnum from -1 to 1
                              as z of-type fixnum = (+ (node-z-pos node) z-offset)
                              ;; don't need to check the node itself
                              unless (and (zerop x-offset) (zerop y-offset) (zerop z-offset))
                              ;; don't need to check already closed nodes
                              unless (find-node-with-coords x y z closed-nodes)
                              ;; don't need to find already open nodes, either
                              unless (find-node-with-coords x y z open-nodes)
                              ;; only check valid coordinates
                              when (funcall valid-func x y z (node-x-pos node) (node-y-pos node) (node-z-pos node)) do
                                (push (make-new-node node x y z (first goal-coord) (second goal-coord) (third goal-coord) (funcall cost-func x y z)
                                                     )
                                      open-nodes))))
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
	 collect (list (node-x-pos trail) (node-y-pos trail) (node-z-pos trail)) into result
	 finally (return (cons start-coord (nreverse result)))))))

(defun diagonal (cur-x cur-y end-x end-y)
  (let* ((dx (abs (- cur-x end-x)))
	 (dy (abs (- cur-y end-y)))
	 (diag (min dx dy)) 
	 (straight (+ dx dy)))
    (+ (* (sqrt 2) diag) (* 1 (- straight (* 2 diag))))))

(defun path-distance (cur-x cur-y cur-z end-x end-y end-z)
  (declare (type fixnum cur-x cur-y cur-z end-x end-y end-z))
  (let ((dx (abs (- cur-x end-x)))
        (dy (abs (- cur-y end-y)))
        (dz (abs (- cur-z end-z))))
    (+ dx dy dz)))

(setf *h-func* #'path-distance)
