# Simple progress reporter for sh scripts

JFF.

Clone the repo & run `example-simple.sh`. It displays something like

    Converting:                                                11%

and then *on the same line*:

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
* expr, seq, awk.

## ffmpeg

For more useful example, see `example-ffmpeg-mp3.sh`. The script takes
some audio file, for example `test/data/amwb-20110805.ogg` & with ffmpeg
help produces an .mp3 file. It does it with hiding all ffmpeg horrible
garbage. The only thing you will see is:

    ogg->mp3: 19%

## TODO

- shunit2 tests but today is a lazy August day;
- write a similar util for uraniacast.

## License

MIT.
