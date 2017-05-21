# A simple progress reporter for sh scripts

JFF.

Clone the repo & run `example-simple.sh`. It'll display something like

    Converting:                                                11%

and then (on the same line):

    Converting:                                                 ok

(It actually doesn't convert anything.)

## API

    . ./progress_reporter.sh

    progress_reporter_begin 'Some boring, long task: '
    pr=`progress_reporter_new 0 331`
    for i in `seq 0 331`; do
        progress_reporter_update $pr $i
    done
    progress_reporter_end 'ok'

## Requirements

* /bin/sh in FreeBSD or bash in Fedora.
* expr, seq, gawk.

## ffmpeg

For a more useful example, see `example-ffmpeg-mp3.sh`. The script
takes an audio file, for example `test/data/amwb-20110805.ogg` &
produces an .mp3. While ffmpeg is doing its job, the script hides all
the garbage that ffmpeg prints. The only thing the user sees is:

    ogg->mp3: 19%

<video src="https://zippy.gfycat.com/NeglectedDifferentHog.webm" autoplay="autoplay" loop="loop"></video>

## TODO

- shunit2 tests but today is a lazy August day;

## License

MIT.
