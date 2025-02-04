;;; tide-nav.el --- Navigate between Typescript classes and methods


;;; Commentary:
;;; Uses tide for parsing

(require 'dash)
(require 'tide)

;;; Code:

(defun tide-nav-which-class ()
  "Show the current class that you are in the mini-bar."
  (interactive)
  (message (tide-nav--format-class
            (tide-nav--which-class))))

(defun tide-nav-which-function ()
  "Show the current function or method in the mini-bar."
  (interactive)
  (let ((function (tide-nav--which-function)))
    (if function
        (message (tide-nav--format-function function))
      (message "Not in a function"))))

(defun tide-nav--which-function ()
  (tide-nav--point-node (tide-nav-get-functions)))

(defun tide-nav-which-block ()
  "Show the current classes, namespaces and methods in the mini-bar."
  (interactive)
  (let ((x (tide-nav--point-node (tide-nav-get-blocks))))
    (if x
        (message (tide-nav--format-block x))
      (message "Not in a block"))))

(defun tide-nav-back-class ()
  "Go back to the class definition; or to the previous class definition."
  (interactive)
  (let ((line (save-excursion (previous-line) (tide-nav--start-line (tide-nav--which-class)))))
    (if line
      (goto-line line)
      (message "No previous class"))))

(defun tide-nav-back-function ()
  "Go back to the class definition; or to the previous class definition."
  (interactive)
  (let ((line (save-excursion (previous-line) (tide-nav--start-line (tide-nav--which-function)))))
    (if line
      (goto-line line)
      (message "No previous class"))))

(defun tide-nav-back-block ()
  "Go back to a function, method, class or namespace."
  (interactive)
  (let ((line (save-excursion (previous-line) (tide-nav--start-line (tide-nav--which-block)))))
    (if line
      (goto-line line)
      (message "No previous block"))))

(defun tide-nav--which-class ()
  "Return the current class object."
  (tide-nav--point-node (tide-nav-get-classes)))

(defun tide-nav--which-block ()
  "Return the current block (class, method, namespace, etc) node."
  (tide-nav--point-node (tide-nav-get-blocks)))

(defun tide-nav--which-node ()
  "Return the current node at the point."
  (tide-nav--point-node (tide-nav-get-node)))


(defun tide-nav--start-line (x)
  "Return the start line for a node, X."
  (tide-nav--pget (car (tide-nav--pget x :spans))
                 :start :line))


(defun tide-nav--end-line (x)
  "Return the end line for a node, X."
    (tide-nav--pget
     (car (tide-nav--pget x :spans))
     :end :line))


(defun tide-nav--point-node (nodes)
  "Get the node at point from amongst NODES."
  (car (last (tide-nav--point-nodes nodes))))


(defun tide-nav--point-nodes (nodes)
  "Return all the nodes in NODES that contain the point."
  (let ((line-num (line-number-at-pos)))
    (mapcar 'caddr
            (-filter (lambda (x) (and
                                  (<= (car x) line-num)
                                  (>= (cadr x) line-num)))
                     (mapcar (lambda (x) (list
                                          (tide-nav--start-line x)
                                          (tide-nav--end-line x)
                                          x))
                             nodes)))))

(defun tide-nav-get-classes (&optional forest)
  "Get all the class nodes in the file (or within a FOREST of nodes)."
  (tide-nav--get-nodes
   (lambda (x) (equal (plist-get x :kind) "class"))
   forest))


(defun tide-nav-get-functions (&optional forest)
  "Get all the functions and methods in the file (or within a FOREST of nodes)."
  (tide-nav--get-nodes
   'tide-nav--is-function
   forest))

(defun tide-nav-get-blocks (&optional forest)
  "Get all the the blocks (namespaces, classes functions) in the current file (or the FOREST of nodes)."
  (tide-nav--get-nodes
   (lambda (x) (tide-nav--is-block x))
   forest))

(defun tide-nav--is-block (node)
  "Check if the NODE is a block."
  (or
   (member (plist-get node :kind) (list "module" "class" "function" "method"))
   ;; lambdas are "consts' that span multiple lines
   (and (equal (plist-get node :kind) "const")
        (> (- (tide-nav--end-line node) (tide-nav--start-line node)) 0))))

(defun tide-nav--is-function (node)
  "Check if NODE is a function."
  (or
   (member (plist-get node :kind) (list "function" "method" ))
   (and
    (equal (plist-get node :kind) "const")
    (> (- (tide-nav--end-line node) (tide-nav--start-line node)) 0))))


(defun tide-nav-get-nodes (&optional forest)
  "Get all the nodes in the file (or under the FOREST of nodes)."
  (tide-nav--get-nodes
   (lambda (x) 't)
   forest))

(defun tide-nav--format-class (&optional node)
  "Format a class NODE."
  (s-join "." (append
   (mapcar (lambda (y) (tide-nav--format-node y)) (plist-get node :route))
   (list (plist-get node :text)))))


(defun tide-nav--format-function (&optional node)
  "Format function NODE."
  (s-join "." (append
   (mapcar (lambda (y) (tide-nav--format-node y)) (plist-get node :route))
   (list (plist-get node :text)))))

(defun tide-nav--format-block (&optional node)
  "Format a block NODE."
  (s-join "." (append
   (mapcar (lambda (y) (tide-nav-block--format-node y)) (plist-get node :route))
   (list (tide-nav-block--format-node node)))))


(defun tide-nav--format-node (node)
  "Format a NODE."
  (pcase (plist-get node :kind)
    ("class" (plist-get node :text))
    ("module" (plist-get node :text))
    ("method" (s-concat (plist-get node :text) "()"))
    ("function" (s-concat (plist-get node :text) "()"))))

(defun tide-nav-block--format-node (node)
  "Format a NODE when formatting a block."
  (pcase (plist-get node :kind)
    ("class" (plist-get node :text))
    ("module" (plist-get node :text))
    ("const" (s-concat (plist-get node :text) "()"))
    ("method" (s-concat (plist-get node :text) "()"))
    ("function" (s-concat (plist-get node :text) "()"))))

(defun tide-nav--get-nodes (predicate &optional forest)
  "Get all the nodes in file (or under a FOREST of nodes )that match a PREDICATE. Store :route to nodes."
  (setq forest (or forest (tide-nav--pget (tide-command:navbar) :body :childItems)))
  (mapcar 'tide-nav--reverse-route
          (apply 'append
                 (mapcar
                  (lambda (x) (tide-nav--get-nodes-inner predicate x))
                  forest))))


(defun tide-nav--get-nodes-inner (predicate x &optional route)
  "Convenience function for `tide-nav--get-nodes` using PREDICATE, X, and ROUTE."
  (let ((child-results (apply 'append
                              (mapcar (lambda (y) (tide-nav--get-nodes-inner predicate y (cons x route)))
                                      (plist-get x :childItems)))))t
  (if (funcall predicate x)
      (cons (plist-put (copy-list x) :route route) child-results)
    child-results)))


(defun tide-nav--reverse-route (node)
  "Reverse the route property in a NODE."
  (plist-put (copy-list node) :route (reverse (plist-get node :route))))

(defun tide-nav--get-kinds (&optional forest)
  "Get all the kinds of nodes in the file (or under a FOREST of nodes)."
  (setq forest (or forest (tide-nav--pget (tide-command:navbar) :body :childItems)))
  (delete-dups (apply 'append (mapcar 'tide-nav-get-kinds-inner forest))))

(defun tide-nav--get-kinds-inner (x)
  "Convenience function for tide-nav--get-kinds using X."
  (let ((child-results (apply 'append (mapcar 'tide-nav-get-kinds-inner (plist-get x :childItems)))))
      (cons (plist-get x :kind) child-results)))


(defun tide-nav--pget (plist &rest options)
  "Recursively get a number of OPTIONS within a PLIST."
  (if (null options)
      plist
    (apply 'tide-nav--pget (cons (plist-get plist (car options)) (cdr options)))))

(provide 'tide-nav)
;;; tide-nav.el ends here
