#lang racket


;This file is a WIP.
;It will, one day, grow up to be an API for working with shotcut.
;Currently: Undocumented and unused

(require meta-viral-videos/util/util)

;A struct for a video that plays some content for some amount of time,
;  with some events that happen during that duration...
(struct video (content hours minutes seconds microseconds events))

;A struct for an event that occurs at a particular time
;  showing some content video (whose duration is determined by its content's duration)
(struct event (content hours minutes seconds microseconds))

;TODO: Filters?  Do we store that data in the video struct?

;Util
(define (pathify x)
  (cond 
    [(string? x) (build-path (current-directory) x)]
    [(path? x) x]
    [(video? x) x]
    [else (error "That can't be a path...")]))

;Constructor for a video
(define (mvv path-or-video
	     #:hours (hours 0) 
	     #:minutes (minutes 0) 
	     #:seconds (seconds 0) 
	     #:microseconds (microseconds 0) 
	     . events)

  (define total (+ hours minutes seconds microseconds))

  (if (zero? total)
      (let ([len (video-file-length (pathify path-or-video))])
	(video (pathify path-or-video) 
	       (video-length-hours len) 
	       (video-length-minutes len) 
	       (video-length-seconds len) 
	       (video-length-microseconds len) 
	       events))
      (video (pathify path-or-video) 
	     hours minutes seconds microseconds events))
  )

(define show mvv) ;Alias



;Constructor for a basic event
(define (at #:hours (hours 0) 
	    #:minutes (minutes 1) 
	    #:seconds (seconds 0) 
	    #:microseconds (microseconds 0) 
	    path-or-video)
  (event (pathify path-or-video) 
	 hours minutes seconds microseconds))


(define output-folder (make-parameter #f))

;Will spit a bunch of Shotcut MLT files into the specified out directory.
(define (render #:to (to "out") video)
  (when (not (directory-exists? to))
    (make-directory to))

  (parameterize ([output-folder to])
    (render-video video)))

(define (render-video v)

  ;TODO: Recursively render the events and nested videos too

  ;Base case...

  (cond
    [(basic-clip? v) (render-basic-clip v)]
    [else (error "TODO")] 
    )
  )

(define (basic-clip? v)
  (path? (video-content v)))

(define (render-basic-clip v)
  (local-require meta-viral-videos/templates/basic-clip)
  (to-file (video-content v)
	   (basic-clip (video-content v)
		       (make-video-length-string
			 (video-hours v)
			 (video-minutes v)
			 (video-seconds v)
			 (video-microseconds v)))))

(define (to-file name stuff)
  (with-output-to-file 
    (build-path (output-folder)
		(~a (gensym 'clip) ".mlt")) 
    #:exists 'replace
    (thunk*
      (displayln stuff)))) 

(module+ 
  main
  (render (mvv "videos/mvv-basic-base.mp4"
	       (at 
		 #:seconds 5
		 (show "videos/cat-event.mp4")
		 ))))


