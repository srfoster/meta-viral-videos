#lang racket 

(provide
  billionare-1

  mvv-basic-base.mp4
  cat-event-3.mp4
  cat-event-2.mp4
  cat-event.mp4
  tierrasanta-qrcode.png)

(require racket/runtime-path
	 meta-viral-videos/templates/basic-clip
	 meta-viral-videos/util/youtube
	 meta-viral-videos/combiners/main
	 meta-viral-videos/filters
	 meta-viral-videos/constructors)

;TODO: Don't ship videos with repo.  Put them on YT instead
(define-runtime-path videos "../videos")

(define mvv-basic-base.mp4
  (build-path videos "mvv-basic-base.mp4"))

(define cat-event-3.mp4
  (build-path videos "cat-event-3.mp4"))

(define cat-event-2.mp4
  (build-path videos "cat-event-2.mp4"))

(define cat-event.mp4
  (build-path videos "cat-event.mp4"))

(define tierrasanta-qrcode.png
  (build-path videos "qrcode.png"))


(define (billionare-1 c1 c2)
  (tracks
    (playlist
      (blank "00:00:00.750")
      (size/position
	#:x 1116
	#:y 32
	#:w 771
	#:h 433
	(clip
	  c1
	  "00:00:00.0"
	  "00:00:01.0")))
    (playlist
      (blank "00:00:04.0")
      (size/position
	#:x 1116
	#:y 32
	#:w 771
	#:h 433
	(clip
	  c2
	  "00:00:00.0"
	  "00:00:01.0")))
    (yt-clip
      "KkThzx090Lw"
      "00:00:00.0"
      "00:00:05.50")))





