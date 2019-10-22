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

For a more useful example, see `example-ffmpeg.sh`--a drop-in wrapper
around ffmpeg (tested w/ 4.1.4). The script passes down all CLAs to
ffmpeg, but hides all the garbage it prints. The only thing a user
sees is:

    ffmpeg (foobar.m4a): 19%

![gif](http://sigwait.tk/~alex/demo/misc/example-ffmpeg.sh.gif)

## TODO

- shunit2 tests but today (2013-08-19) is a lazy August day;

## License

MIT.
