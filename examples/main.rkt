#lang racket

(require meta-viral-videos)

(basic-render "mvv.mlt"
  (mvv-basic-base
    "videos/mvv-basic-base.mp4" 
    "videos/cat-event-3.mp4" 
    "videos/cat-event-3.mp4" 
    "videos/qrcode.png" 
    "sweet URL!"))
