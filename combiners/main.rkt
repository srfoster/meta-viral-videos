#lang at-exp racket

(provide playlist
	 tracks)

(require meta-viral-videos/rendering)
(require meta-viral-videos/util/util)


(define (playlist . videos)
  (lambda ()
    (define outputted-videos (map video->mlt-file videos))

    (define total-length
      (video-length->string
	(microseconds->video-length
	  (foldl
	    (lambda (c total)
	      (+ total
		 (video-length->total-microseconds
		   (video-file-length c))))
	    0
	    outputted-videos))))

    (define clip->producer
      (lambda (c)
	(define vl (video-file-length c))
	(define vls (video-length->string vl))

	(define seconds  ;300?
	  (/ (video-length->total-microseconds vl) 100)) 

	@~a{
	<producer id="@(~a c)" title="Shotcut version 19.12.31" in="00:00:00.000" out="@vls">
	<property name="length">@|seconds|</property>
	<property name="eof">pause</property>
	<property name="resource">@(~a c)</property>
	<property name="mlt_service">xml</property>
	<property name="global_feed">1</property>
	<property name="shotcut">1</property>
	<property name="shotcut:projectAudioChannels">2</property>
	<property name="shotcut:projectFolder">0</property>
	<property name="xml">was here</property>
	<property name="seekable">1</property>
	<property name="shotcut:hash">@(random 1000000)</property>
	</producer>
	}))

    (define clip->playlist-entry
      (lambda (c)
	(define vl (video-file-length c))
	(define vls (video-length->string vl))

	(define seconds  ;300?
	  (/ (video-length->total-microseconds vl) 100)) 

	@~a{
	<entry producer="@(~a c)" in="00:00:00.000" out="@vls"/>
	}))

    (define first-producers
      (map clip->producer outputted-videos))

    (define first-playlist-entries
      (map clip->playlist-entry outputted-videos))

    (define more-outputted-videos (map video->mlt-file videos))

    (define second-producers
      (map clip->producer more-outputted-videos ))

    (define second-playlist-entries
      (map clip->playlist-entry more-outputted-videos))

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
    }))

(define (tracks . videos)
  (lambda ()
    (define outputted-videos (reverse (map video->mlt-file videos)))

    (define total-length ;Length of all tracks together is the length of the longest
      (video-length->string
	(microseconds->video-length
	  (apply max
		 (map (compose 
			video-length->total-microseconds
			video-file-length) 
		      outputted-videos)))))

    (define clip->producer+playlist
      (lambda (c)
	(define vl (video-file-length c))
	(define vls (video-length->string vl))

	(define seconds  ;300?
	  (/ (video-length->total-microseconds vl) 100)) 

	@~a{
	<producer id="producer:@(~a c)" title="Shotcut version 19.12.31" in="00:00:00.000" out="@vls">
	<property name="length">@|seconds|</property>
	<property name="eof">pause</property>
	<property name="resource">@(~a c)</property>
	<property name="mlt_service">xml</property>
	<property name="global_feed">1</property>
	<property name="shotcut">1</property>
	<property name="shotcut:projectAudioChannels">2</property>
	<property name="shotcut:projectFolder">0</property>
	<property name="xml">was here</property>
	<property name="seekable">1</property>
	<property name="shotcut:hash">@(random 1000000)</property>
	</producer>
	<playlist id="playlist:@(~a c)">
	<property name="shotcut:video">1</property>
	<property name="shotcut:name">V1</property>
	<entry producer="producer:@(~a c)" in="00:00:00.000" out="@vls"/>
	</playlist>
	}))

    (define clip->track
      (lambda (c)
	@~a{<track producer="playlist:@(~a c)"/>}))

    (define producers+playlists
      (map clip->producer+playlist outputted-videos))

    (define tracks
      (map clip->track outputted-videos))



    ;I have no idea what these mysterious transitions do.
    ;But I'll just reverse engineer what works... :)

    (define (transition:0->x n)
      @~a{
      <transition id="@(gensym 'transition)">
      <property name="a_track">0</property>
      <property name="b_track">@|n|</property>
      <property name="mlt_service">mix</property>
      <property name="always_active">1</property>
      <property name="sum">1</property>
      </transition>
      })

    (define (transition:1->x n)
      @~a{
      <transition id="@(gensym 'transition)">
      <property name="a_track">1</property>
      <property name="b_track">@|n|</property>
      <property name="version">0.9</property>
      <property name="mlt_service">frei0r.cairoblend</property>
      <property name="disable">0</property>
      </transition>
      })

    (define transions:0->x
      (map transition:0->x
	   (range 2 (add1 (length outputted-videos)))))

    (define transions:1->x
      (map transition:1->x
	   (range 2 (add1 (length outputted-videos)))))


    (apply string-append
	   (flatten
	     (list
	       @~a{
	       <?xml version="1.0" encoding="utf-8"?>
	       <mlt LC_NUMERIC="C" version="6.19.0" title="Shotcut version 19.12.31" producer="main_bin">
	       <profile description="HD 1080p 25 fps" width="1920" height="1080" progressive="1" sample_aspect_num="1" sample_aspect_den="1" display_aspect_num="16" display_aspect_den="9" frame_rate_num="60" frame_rate_den="1" colorspace="709"/>
	       <playlist id="main_bin">
	       <property name="xml_retain">1</property>
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
	       </playlist>}

	       @producers+playlists

	       @~a{
	       <tractor id="tractor0" title="Shotcut version 19.12.31" global_feed="1" in="00:00:00.000" out="@total-length">
	       <property name="shotcut">1</property>
	       <property name="shotcut:projectAudioChannels">2</property>
	       <property name="shotcut:projectFolder">0</property>
	       <track producer="background"/>
	       }

	       @tracks 

	       @~a{
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
	       }

	       @transions:0->x
	       @transions:1->x

	       @~a{
	       </tractor>
	       </mlt>
	       })))))






