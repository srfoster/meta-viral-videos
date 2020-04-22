#lang racket

(provide yt-clip
	 video-library-path
	 with-video-library)

(require meta-viral-videos/templates/basic-clip
	 meta-viral-videos/rendering
	 file/glob)

;CACHING
(define video-library-path (make-parameter (current-directory)))

(define-syntax-rule (with-video-library path lines ...)
  (parameterize ([video-library-path path])
    lines ...))

(define (get-from-cache id)
  (define matching-files
    (glob (~a (video-library-path) "/*" id "*")))

  (if (empty? matching-files)
      #f
      (first (glob 
	       (~a (video-library-path) "/*" id "*")))))
;End CACHING



(define (youtube-dl id)
  (or (get-from-cache id)
      (begin
	(system (~a "youtube-dl -q " 
		    "-o '" (video-library-path) "/%(title)s-%(id)s.%(ext)s' "
		    id ))
	(get-from-cache id))))

;Id StartTime EndTime -> (-> XML string)
(define (yt-clip id start end)
  (lambda ()
    (file->string
      (video->mlt-file
	(basic-clip-in-out
	  (youtube-dl id)
	  start end)))))

(module+ main
#|
  [https://www.youtube.com/watch?v=lOxBMrnbr9M 42-58]
  [https://www.youtube.com/watch?v=qSLh6mFUZ40 34-39]
  [https://www.youtube.com/watch?v=qSLh6mFUZ40 44-52]
  [https://www.youtube.com/watch?v=qSLh6mFUZ40 57-1:11]
|# 

  (parameterize ([video-library-path 
		   (build-path (find-system-path 'home-dir) 
			       "Videos" "COVID" "CodingVs" "video-library")])

    (displayln (yt-clip "lOxBMrnbr9M" "00:00:42.0" "00:00:58.0"))
    
    )

)
