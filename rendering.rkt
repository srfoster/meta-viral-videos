#lang racket

(provide 
  video->mlt-file 
  video-preview!

  ;Deprecated?
  basic-render)

;People would need to override this if they
;  aren't using the st terminal...
;That's why it's exposed as as parameter
(define preview-function
  (make-parameter
    (lambda (v)
      (system (~a "st melt " (video->mlt-file v))))))

(define (video-preview! v)
  ((preview-function) v))

;A video is either an MLT file string already, or it is a function that returns one
(define (video->mlt-file v [file-name (~a (gensym 'video) ".mlt")])
  (define out
    (build-path (current-directory) "out"))

  (when (not (directory-exists? out))
    (make-directory out))

  (define output-file
    (build-path out file-name))

  (with-output-to-file output-file
		       #:exists 'replace
		       (thunk*
			 (if (procedure? v)
			     (displayln (v))
			     (displayln v))))
  
  output-file)

(define (basic-render path content)
  (define out
    (build-path (current-directory) "out"))

  (when (not (directory-exists? out))
    (make-directory out))

  (with-output-to-file (build-path out path) 
		       #:exists 'replace
		       (thunk*
			 (displayln content))))
