(in-package :cl-user)
(defpackage tacit-tales.web
  (:use :cl
        :caveman2
        :tacit-tales.config
        :tacit-tales.view
        :tacit-tales.db
	:tacit-tales.model
	:tacit-tales.lib
        :datafly
        :sxql
	:split-sequence
	:md5
	:cl-fad)
  (:export :*web*))
(in-package :tacit-tales.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))

(defroute "/pwd" ()
  (format nil "Working directory: ~a" (sb-posix:getcwd)))

(defroute "/posts/:category/:article" (&key category article)
  (file-string (format nil "./posts/~a/~a" category article)))

(defroute "/posts/:category/" (&key category)
  (render #P"directory.html"
	  (directory-listing (format nil "./posts/~a" category)))
  ;; (render #P"directory.html"
  ;; 	  (list
  ;; 	   :listing
  ;; 	   (mapcar #'file-namestring (list-directory (format nil "./posts/~a/" category)))))
  ;; (format nil "~{<a href=\"./~a\">~:*~a</a><br>~%~}~%"
  ;; 	  (mapcar #'file-namestring (list-directory (format nil "./posts/~a/" category))))
  )

;; (:directory (:subdirs (a b c)
;; 		      :files (d e f)))

(defroute "/posts/" ()
  (render #P"directory.html"
	  (directory-listing "./posts/")
	  ;; (list
	  ;;  :listing
	  ;;  (mapcar
	  ;;   (lambda (x) (car (last (remove "" (split-sequence #\/ (directory-namestring x)) :test #'equal))))
	  ;;   (list-directory "./posts")))
	  ))

;; (defroute "/posts/" ()
;;   (format nil "~{<a href=\"./~a/\">~:*~a</a><br>~%~}"
;; 	  (mapcar
;; 	   (lambda (x) (car (last (remove "" (split-sequence #\/ (directory-namestring x)) :test #'equal))))
;; 	   (list-directory "./posts"))))

;; (defroute "/compare/*" (&key splat)
;;   (format nil "We saw this in the URL: ~a" (car splat)))

;; (defroute "/compare/*" (&key splat)
;;   (let* ((language-list
;;           (remove "" (split-sequence #\/ (car splat)) :test #'equal))
;;          (stats (get-language-sub-stats language-list)))
;;     (format nil "<div style='font-size:.8em;'>~{~a<br>~%~}</div>"
;;             (get-language-sub-stats language-list))))

(defroute "/compare/*" (&key splat)
  (let* ((language-list
          (remove "" (split-sequence #\/ (car splat)) :test #'equal))
         (stats (get-language-sub-stats language-list))
         (pie-name (pie-chart stats)))
    (format nil "<img src='/images/~a.png' style='float:left;'>
<div style='font-size:.8em;'>~{~a<br>~%~}</div>"
            pie-name
            (get-language-sub-stats language-list))))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
