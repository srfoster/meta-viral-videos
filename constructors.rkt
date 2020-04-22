#lang at-exp racket

(provide blank)

(require meta-viral-videos/util/util)

(define (blank vl)
  (define vls (video-length->string vl))

  @~a{
  <?xml version="1.0" encoding="utf-8"?>
  <mlt LC_NUMERIC="C" version="6.19.0" title="Shotcut version 19.12.31" producer="main_bin">
  <profile description="HD 1080p 25 fps" width="1920" height="1080" progressive="1" sample_aspect_num="1" sample_aspect_den="1" display_aspect_num="16" display_aspect_den="9" frame_rate_num="
  60" frame_rate_den="1" colorspace="709"/>
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
  <tractor id="tractor0" title="Shotcut version 19.12.31" global_feed="1" in="00:00:00.000" out="@vls">
  <property name="shotcut">1</property>
  <property name="shotcut:projectAudioChannels">2</property>
  <property name="shotcut:projectFolder">0</property>
  <track producer="background"/>
  </tractor>
  </mlt>

  })
