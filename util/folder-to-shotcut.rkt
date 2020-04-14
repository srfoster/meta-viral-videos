#lang at-exp racket

(require 
  "util.rkt"
  "illustration-to-shotcut.rkt")

(provide combine
	 (except-out (struct-out illustration)
		     illustration)
	 (rename-out [make-illustration illustration]))

(struct illustration (length file-name))

(define (make-illustration length file-name)
  (when (mlt-file? file-name)
    (define my-length 
      (video-file-length file-name))

    (define requested-length
      (video-length-string->video-length length))

    (when (not (equal? my-length requested-length))
      (displayln (~a "Actual: " my-length))
      (displayln (~a "Requested: " requested-length))
      (define command 
        (~a 
	  "melt " file-name " -consumer avformat:" (string-replace file-name "mlt" "mp4")))

      (error (~a "Cannot change speed of MLT file.  Render it first? " command))))

  (illustration length file-name))

(define (file-name->mlt-file-name file-name)
  (~a file-name ".mlt")

  #;
  (~a (first (string-split file-name ".")) ".mlt"))

(define (combine . entries )
  (for ([e entries])
       (define new-len   (illustration-length e)) 
       (define file-name (illustration-file-name e)) 
       (define mlt-file-name (file-name->mlt-file-name file-name))

       (with-output-to-file 
	 #:exists 'replace
	 (build-path mlt-file-name)

	 (thunk*
	   (displayln
	     (speed-up-to file-name 
			  (video-length-string->video-length new-len))))))

  (displayln 
    (apply shotcut-simple-sequence 
	   entries))
  )



(define id -1)

(define (inc!)
  (set! id (add1 id)))

;Take a clip just in case we want to use that
; for id generation in the future.
(define (gen-id c)
  (if (= -1 id)
      (begin
	(inc!)
	(~a "tractor" 0)) 
      (begin
	(inc!)
	(~a "producer" (sub1 id)))))

(define (shotcut-simple-sequence . clips)
  (define ids (map gen-id clips))

  (define total-length
    (video-length->string
      (microseconds->video-length
	(foldl
	  (lambda (c total)
	    (+ total
	       (video-length->total-microseconds
		 (video-length-string->video-length 
		   (illustration-length c)))))
	  0
	  clips))))

  (define clip->producer
    (lambda (c i)
      (define vls (illustration-length c))
      (define vl (video-length-string->video-length vls))

      (define seconds  ;300?
	(/ (video-length->total-microseconds vl) 100)) 

      @~a{
      <producer id="@i" title="Shotcut version 19.12.31" in="00:00:00.000" out="@vls">
      <property name="length">@|seconds|</property>
      <property name="eof">pause</property>
      <property name="resource">@(file-name->mlt-file-name (illustration-file-name c))</property>
      <property name="mlt_service">xml</property>
      <property name="global_feed">1</property>
      <property name="shotcut">1</property>
      <property name="shotcut:projectAudioChannels">2</property>
      <property name="shotcut:projectFolder">0</property>
      <property name="xml">was here</property>
      <property name="seekable">1</property>
      <property name="shotcut:hash">63f9d82e087112ec47d98dfe1210f545</property>
      </producer>
      }))

  (define clip->playlist-entry
    (lambda (c i)
      (define vls (illustration-length c))
      (define vl (video-length-string->video-length vls))

      (define seconds  ;300?
	(/ (video-length->total-microseconds vl) 100)) 

      @~a{
      <entry producer="@i" in="00:00:00.000" out="@vls"/>
      }))

  (define first-producers
    (map clip->producer clips ids))

  (define first-playlist-entries
    (map clip->playlist-entry clips ids))

  ;Not sure why shotcut requires what appears to be
  ; the same information twice.  Maybe it's data for the in-editor playlist manager thingy 
  ; in the top left? 
  ;I'll just do what's necessary and not ask questions.
  (define more-ids (map gen-id clips))

  (define second-producers
    (map clip->producer clips more-ids))

  (define second-playlist-entries
    (map clip->playlist-entry clips more-ids))

  @~a{
<?xml version="1.0" encoding="utf-8"?>
<mlt LC_NUMERIC="C" version="6.19.0" title="Shotcut version 19.12.31" producer="main_bin">
  <profile description="HD 1080p 25 fps" width="1920" height="1080" progressive="1" sample_aspect_num="1" sample_aspect_den="1" display_aspect_num="16" display_aspect_den="9" frame_rate_num="60" frame_rate_den="1" colorspace="709"/>
  @(string-join first-producers "\n")
  <playlist id="main_bin" title="Shotcut version 19.12.31">
    <property name="shotcut:projectAudioChannels">2</property>
    <property name="shotcut:projectFolder">1</property>
    <property name="xml_retain">1</property>
    @(string-join first-playlist-entries "\n")
  </playlist>
  <producer id="black" in="00:00:00.000" out="@total-length">
    <property name="length">@|total-length|</property>
    <property name="eof">pause</property>
    <property name="resource">0</property>
    <property name="aspect_ratio">1</property>
    <property name="mlt_service">color</property>
    <property name="mlt_image_format">rgb24a</property>
    <property name="set.test_audio">0</property>
  </producer>
  <playlist id="background">
    <entry producer="black" in="00:00:00.000" out="@total-length"/>
  </playlist>
  @(string-join second-producers "\n")
  <playlist id="playlist0">
    <property name="shotcut:video">1</property>
    <property name="shotcut:name">V1</property>
    @(string-join second-playlist-entries "\n")
  </playlist>
  <tractor id="tractor1" title="Shotcut version 19.12.31" global_feed="1" in="00:00:00.000" out="@total-length">
    <property name="shotcut">1</property>
    <property name="shotcut:projectAudioChannels">2</property>
    <property name="shotcut:projectFolder">1</property>
    <track producer="background"/>
    <track producer="playlist0"/>
    <transition id="transition0">
      <property name="a_track">0</property>
      <property name="b_track">1</property>
      <property name="mlt_service">mix</property>
      <property name="always_active">1</property>
      <property name="sum">1</property>
    </transition>
    <transition id="transition1">
      <property name="a_track">0</property>
      <property name="b_track">1</property>
      <property name="version">0.9</property>
      <property name="mlt_service">frei0r.cairoblend</property>
      <property name="disable">1</property>
    </transition>
  </tractor>
</mlt>
  })
