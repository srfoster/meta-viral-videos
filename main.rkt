#lang racket

(provide (all-from-out meta-viral-videos/templates/mvv-basic-base)
	 (all-from-out meta-viral-videos/rendering)
	 

	 mvv-basic-base.mp4
	 cat-event-3.mp4
	 cat-event-2.mp4
	 cat-event.mp4
	 tierrasanta-qrcode.png)

(require meta-viral-videos/templates/mvv-basic-base
	 meta-viral-videos/rendering
	 racket/runtime-path)

(define-runtime-path videos "videos")

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

