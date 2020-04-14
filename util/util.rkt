#lang at-exp racket

(provide 
  mlt-file?
  video-length-string->video-length 
  video-length->string
  make-video-length-string
  video-length->total-microseconds
  video-file-length
  scale-video-length
  scale-video-length-string
  microseconds->video-length 

  video-length-hours
  video-length-minutes
  video-length-seconds
  video-length-microseconds
  )

(require gregor gregor/period)

(define (make-video-length-string h m s ms)
  (video-length->string
    (microseconds->video-length 
      ;Microsecond conversion hopefully normalizes things,
      ;  e.g. if the user passes in 70 minutes instead of 1 hour and 1 minutes...
      (video-length->total-microseconds
	(period
	  [hours h]
	  [minutes m]
	  [seconds s]
	  [microseconds ms])))))

;We'll represent a VideoLength as a gregor period 

;Path -> VideoLength
(define (video-file-length path)
  (define s (video-file-length-string path))

  (video-length-string->video-length s))


(define (video-length-string->video-length s)
  ;Len is something like: 0:10:36.135500
  ;  Let's parse it.
  (define parts
    (string-split s ":"))

  (define more-parts
    (map string->number
	 (flatten
	   (list-set
	     parts
	     2
	     (string-split 
	       (list-ref parts 2)
	       ".")))))

  (period
    [hours (list-ref more-parts 0)]
    [minutes (list-ref more-parts 1)]
    [seconds (list-ref more-parts 2)]
    [microseconds (list-ref more-parts 3)]))


(define (video-length->hash len)
  (make-hash
	 (period->list len)))

(define (video-length-hours len)
  (hash-ref (video-length->hash len)
	    'hours))

(define (video-length-minutes len)
  (hash-ref (video-length->hash len)
	    'minutes))

(define (video-length-seconds len)
  (hash-ref (video-length->hash len)
	    'seconds))

(define (video-length-microseconds len)
  (hash-ref (video-length->hash len)
	    'microseconds))

(define (video-length->total-microseconds len)
  (+ (* (video-length-hours len)        60 60 1000 1000)
     (* (video-length-minutes len)      60 1000 1000)
     (* (video-length-seconds len)      1000 1000)
     (* (video-length-microseconds len) 1)))



;Number -> VideoLength
(define (microseconds->video-length m)
  ;We use gregor to avoid a bit of sexagesimal arithmetic
  (define n (now))

  (period-between n 
		  (+period
		    n
                    (period 
		      [microseconds 
			(inexact->exact 
			  (round (exact->inexact m)))]))
		  '(hours minutes seconds microseconds)))


;Path -> VideoLengthString
(define (video-file-length-string path)
  (if (mlt-file? path)
      (mlt-file-length-string path)
      (ffprobe path)))

(define (mlt-file? path)
  (string-suffix? (~a (last (explode-path path))) ".mlt"))

(define (mlt-file-length-string path)
  (local-require xml)

  (define tractor 
    (last (path->xexpr path)))

  (when (not (eq? 'tractor (first tractor)))
    (error "I was hoping this would always be a <tractor/>...  I guess it's not..."))


  ;TODO: Lift this into an xml util.
  (define (get-attr x attr)
    (define pair
      (findf 
	(lambda (a)
	  (eq? (first a) attr))
	(second x)))
    
    (and pair (second pair)))

  (get-attr tractor 'out))

(define (path->xexpr p)
  (local-require xml)

  (collapse-whitespace #t)

  (define clean-xml
    (xml->xexpr
      ((eliminate-whitespace '(mlt tractor track transition producer playlist filter) )
       (document-element 
	 (read-xml
	   (open-input-file p))))))
  
  clean-xml)


(define (ffprobe path)
  (regexp-replace*
    #rx"[ \n]" 
    (with-output-to-string
      (thunk
	(system 
	  (~a 
	    "ffprobe -v error -show_entries format=duration -sexagesimal \
	    -of default=noprint_wrappers=1:nokey=1 "
	    path))))
      ""))


;VideoLength -> VideoLengthString

(define (video-length->string len)
  (define hours (video-length-hours len))
  (define minutes (video-length-minutes len))
  (define seconds (video-length-seconds len))
  (define microseconds (video-length-microseconds len))

  (~a (~a hours #:min-width 2 #:align 'right #:pad-string "0") 
      ":" 
      (~a minutes #:min-width 2 #:align 'right #:pad-string "0") 
      ":" 
      (~a seconds #:min-width 2 #:align 'right #:pad-string "0") 
      "." 
      (~a microseconds #:max-width 3)
      ))


;VideoLength Number -> VideoLength
(define (scale-video-length len n)
  (define m 
    (inexact->exact
      (* (video-length->total-microseconds len) n)))

  (microseconds->video-length m))

;VideoLengthString Number -> VideoLengthString
(define (scale-video-length-string s n)
  (video-length->string
    (scale-video-length 
      (video-length-string->video-length s)
      n)))


(module+ test
	 (require rackunit)

	 (define v
	   (build-path 
	     (current-directory)
	     "DSC_0253.MOV"))

	 (define vl 
	   (video-file-length v))

	 (define vlm
	   (video-length->total-microseconds vl))

	 (check-equal?
	   vl
	   (microseconds->video-length vlm))

	 (check-equal?
	   (video-length->string vl)
	   (video-file-length-string v))
	 

	 (define half-speed 
	   (scale-video-length vl 0.5))

         (check-equal? 
	   (video-length->total-microseconds vl)
	   (* 2
	      (video-length->total-microseconds half-speed)))
	 
	  
	 (check-equal?
	   (scale-video-length-string 
	     (video-file-length-string v)   
	     0.5)
	   (video-length->string half-speed)))




