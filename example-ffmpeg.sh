#!/bin/sh

. "$(dirname "$(realpath "$0")")/progress_reporter.sh"

pr=

main() {
    local OPTIND OPTARG opt input
    while getopts ":i:" opt; do
        [ "$opt" = "i" ] && { input=${OPTARG}; break; }
    done

    local max
    max=`duration "$input"`
    [ -z "$max" ] && errx "failed to get a duration of the input"

    log_new
    trap 'clean; errx "stopped by a signal"' 1 2 15

    progress_reporter_begin "ffmpeg ($input): "
    pr=`progress_reporter_new 0 $max`
    convert "$@"

    if [ $? -eq 0 ] ; then
        clean
        progress_reporter_end 'done'
        echo ''
    else
        progress_reporter_end "conversion failed, see $log_file"
        echo ''
        exit 1
    fi
}

progname=`basename "$0"`
log_file=
ffmpeg=${FFMPEG:-ffmpeg}

errx() { echo "$progname error: $*" 1>&2; exit 1; }
log_new() { log_file=`mktemp "/tmp/$progname.XXXXXXXXXX"`; }
clean() { rm -f "$log_file"; }

# $1 - file name
#
# return a duration in seconds or nothing on error
duration() {
    $ffmpeg -i "$1" 2>&1 -vn | \
        gawk '/Duration/ {
  split(substr($2, 0, 2*3+2), time, ":");
  printf "%d\n", time[1]*3600+time[2]*60+time[3]
}'
}

convert() {
    local line
    local ntimes=0

    $ffmpeg -y "$@" 2>&1 | tee $log_file | \
        gawk -v RS= '/time=/ {
raw=gensub(/.*time=([0-9:.]+).*/, "\\1", 1);
split(substr(raw, 0, 2*3+2), time, ":");
printf "%d\n", time[1]*3600+time[2]*60+time[3];
fflush()
}' | {
        while read -r line
        do
            echo $line | progress_reporter_update $pr
            ntimes=$((ntimes+1))
        done

        [ $ntimes -eq 0 ] && return 1
        return 0
    }

    # the value of the above var `ntimes` was lost, for a `while read
    # ...` loop creates a subshell, hence we need to group the while
    # loop & return a proper value from that group
    return $?
}


main "$@"
