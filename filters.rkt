#lang at-exp racket

(provide size/position)

(require meta-viral-videos/rendering
	 meta-viral-videos/util/util)

;A filter takes a video and returns a video...
;  -- an MLT String, or a function that would return one.

(define (size/position video 
		       #:x (x 0) 
		       #:y (y 0) 
		       #:w (w 500) 
		       #:h (h 500))
  (lambda ()
    (define outputted-video (video->mlt-file video))
    (define vl (video-file-length outputted-video))
    (define vls (video-length->string vl))

    ;Can abstract much of this....
    @~a{
<?xml version="1.0" encoding="utf-8"?>
<mlt LC_NUMERIC="C" version="6.19.0" title="Shotcut version 19.12.31" producer="main_bin">
	<profile description="HD 1080p 25 fps" width="1920" height="1080" progressive="1" sample_aspect_num="1" sample_aspect_den="1" display_aspect_num="16" display_aspect_den="9" frame_rate_num="60" frame_rate_den="1" colorspace="709"/>
	<playlist id="main_bin">
		<property name="xml_retain">1</property>
	</playlist>
	<producer id="black" in="00:00:00.000" out="@vls">
		<property name="length">@|vls|</property>
		<property name="eof">pause</property>
		<property name="resource">0</property>
		<property name="aspect_ratio">1</property>
		<property name="mlt_service">color</property>
		<property name="mlt_image_format">rgb24a</property>
		<property name="set.test_audio">0</property>
	</producer>
	<playlist id="background">
		<entry producer="black" in="00:00:00.000" out="@vls"/>
	</playlist>
	<producer id="tractor0" title="Shotcut version 19.12.31" in="00:00:00.000" out="@vls">
		<property name="length">@|vls|</property>
		<property name="eof">pause</property>
		<property name="resource">@(~a outputted-video)</property>
		<property name="mlt_service">xml</property>
		<property name="global_feed">1</property>
		<property name="shotcut">1</property>
		<property name="shotcut:projectAudioChannels">2</property>
		<property name="shotcut:projectFolder">0</property>
		<property name="xml">was here</property>
		<property name="seekable">1</property>
		<property name="shotcut:virtual">1</property>
		<property name="shotcut:hash">750ed697d39f75b5f5f480f60b4ae2a2</property>
		<property name="ignore_points">0</property>
	    <filter id="@(~a "filter" (gensym))" out="@(video-length->string vl)">
	    <property name="background">colour:0</property>
	    <property name="mlt_service">affine</property>
	    <property name="shotcut:filter">affineSizePosition</property>
	    <property name="transition.fill">1</property>
	    <property name="transition.distort">0</property>
	    <property name="transition.rect">@x @y @w @h 1</property>
	    <property name="transition.valign">top</property>
	    <property name="transition.halign">left</property>
	    <property name="shotcut:animIn">00:00:00.000</property>
	    <property name="shotcut:animOut">00:00:00.000</property>
	    <property name="transition.threads">0</property>
	    </filter>
	</producer>
	<playlist id="playlist0">
		<property name="shotcut:video">1</property>
		<property name="shotcut:name">V1</property>
		<entry producer="tractor0" in="00:00:00.000" out="@vls"/>
	</playlist>
	<tractor id="tractor1" title="Shotcut version 19.12.31" global_feed="1" in="00:00:00.000" out="@vls">
		<property name="shotcut">1</property>
		<property name="shotcut:projectAudioChannels">2</property>
		<property name="shotcut:projectFolder">0</property>
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


