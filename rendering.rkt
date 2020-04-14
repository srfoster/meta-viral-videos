#lang racket

(provide basic-render)

(define (basic-render path content)
  (define out
    (build-path (current-directory) "out"))

  (when (not (directory-exists? out))
    (make-directory out))

  (with-output-to-file (build-path out path) 
		       #:exists 'replace
		       (thunk*
			 (displayln content))))
