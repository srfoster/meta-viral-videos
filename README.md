Meta Viral Videos
====

# Installation / Hello World

1. First, [install Racket](https://download.racket-lang.org/).  Make sure you can run commands like `racket` and `raco` on your command line. 
   * If you don't know what a "command line" is -- it's not that hard.  And learning about your computer's command line is the perfect way to begin the lifelong and incredibly rewarding journey of becoming a computer scientist.  

2. Install `ffmpeg`.  It too needs to work on your command line.  See?  Command lines are important.  

3. Install my code by running `raco pkg install git@github.com:srfoster/meta-viral-videos.git` on your command line.  Gasp!  Command lines again!

4. Use a text editor of your choice (DrRacket is great -- and was installed during step 1).  Write some code that creates videos.  Here's a "Hello world" program using various defaults.

```
#lang racket

(require meta-viral-videos)

(basic-render "mvv.mlt"
  (mvv-basic-base
    mvv-basic-base.mp4
    cat-event-3.mp4
    cat-event-2.mp4
    tierrasanta-qrcode.png
    "Hello World"))
```

Put that in a file called `hello-world.rkt` and run `racket hello-world.rkt`.  You'll then be the proud owner of a file `out/mvv.mlt` -- which you can any of the following with (and more!):

* Edit as raw text
* Open in Shotcut (which you should also install -- even though it's not necessary for running this code)
* Run from the command line with `melt out/mvv.mlt`

Next steps would be to replace things like `cat-event-3.mp4` with your own mp4 file.  Be sure to put it in quotes, e.g.:


```
#lang racket

(require meta-viral-videos)

(basic-render "mvv.mlt"
  (mvv-basic-base
    mvv-basic-base.mp4
    "you-saying-your-name.mp4"
    "you-saying-your-location.mp4"
    "a-qr-code-you-generated.mp4"
    "A url for your group"))
```


# Development

(COMING SOON)





