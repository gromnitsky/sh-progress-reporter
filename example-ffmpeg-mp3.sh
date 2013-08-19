#!/bin/sh

# Convert ogg/mp4/whatever into mp3.
#
# External tools: ffmpeg, awk

SCRIPT_PATH=$(dirname $(realpath $0))
. $SCRIPT_PATH/progress_reporter.sh

conf_ffmpeg=ffmpeg
conf_stream=a:0
conf_bitrate=56

errx()
{
    echo "${0##*/} error: $1" 1>&2
    exit 1
}

usage()
{
	echo "Usage: ${0##*/} file [output-file]"
	exit 64
}

# $1 - file name
#
# Return a duration in seconds or nothing on error.
ffmpeg_getDuration()
{
	$conf_ffmpeg -i "$1" 2>&1 -vn | \
		awk '/Duration/ {
split(substr($2, 0, 2*3+2), time, ":");
printf "%d\n", time[1]*3600+time[2]*60+time[3]
}'

}

ffmpeg_convert()
{
	local line
	local ntimes=0

	$conf_ffmpeg -i "$1" -vn \
		-c:${conf_stream} libmp3lame \
		-b:${conf_stream} ${conf_bitrate}k \
		-ac:${conf_stream} 2 \
		-q:${conf_stream} 9 \
		-map_metadata 0:s:${conf_stream} \
		-y "$2" 2>&1 | {
		while read -d  line
		do
			echo $line | awk '/time=/ {
raw=gensub(/.*time=([0-9:.]+).*/, "\\1", "");
split(substr(raw, 0, 2*3+2), time, ":");
printf "%d\n", time[1]*3600+time[2]*60+time[3]
}' | progress_reporter_update $pr
			ntimes=$((ntimes+1))
		done

		[ $ntimes -eq 0 ] && return 1
		return 0
	}

	# the value of ntimes variable above was lost, because 'while read'
	# creates a subshell; so we group while loop with ntimes check
	return $?
}


#
# main
#

[ -z "$1" ] && usage

max=`ffmpeg_getDuration "$1"`
[ -z $max ] && errx "broken audio stream $conf_stream in: $1"

input_ext=${1##*.}
output=$2
[ -z "$output" ] && {
	output=${1%%.*}.mp3
	[ "$1" = "$output" ] && output=${1%%.*}.1.mp3
}

progress_reporter_begin "${input_ext}->mp3: "
pr=`progress_reporter_new 0 $max`

exit_code=0
ffmpeg_convert "$1" "$output"
if [ $? -eq 0 ] ; then
	progress_reporter_end 'done'
else
	progress_reporter_end 'conversion failed'
	exit_code=1
fi

echo ''
exit $exit_code
