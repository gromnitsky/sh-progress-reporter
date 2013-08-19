# Simple progress reporter for sh scripts.
#
# Functions/variables that contain '__' in their names are private, all
# others are public API.
#
# Uses sh-subset w/o bash extensions. External utils: seq, awk.
# Tested on FreeBSD & Fedora.

progress_reporter_width=4

progress_reporter__width_cur() {
	echo $(($progress_reporter_width-1))
}

progress_reporter__errx()
{
    echo "${0##*/} error: $1" 1>&2
    exit 1
}

progress_reporter__next()
{
	local s=''
	# erase characters on a terminal
	if [ -t 1 ] ; then
		for i in `seq $progress_reporter_width`; do s="$s"; done
		printf $s
	else
		printf '\n'
	fi
}

# $1 - message (optional)
progress_reporter_begin()
{
	[ -z "$1" ] || printf '%s' "$1"
	printf "%${progress_reporter_width}s" ' '
	progress_reporter__next
	printf "%`progress_reporter__width_cur`d%%" 0
}

# $1 - min value
# $2 - max value
#
# Return a tuple with 2 numbers
progress_reporter_new()
{
	[ -z $1 ] && progress_reporter__errx 'progress_reporter_new: $1 is invalid'
	[ -z $2 ] && progress_reporter__errx 'progress_reporter_new: $2 is invalid'
	echo $1 $2
}

# $1 - result from progress_reporter_new() in double quotes
# $2 - current value
progress_reporter_update()
{
	local min
	local max
	local cur

	min=${1% [0-9]*}
	[ -z $min ] && progress_reporter__errx 'progress_reporter_update: $1 is invalid'
	max=${1#[0-9]* }
	[ -z $max ] && progress_reporter__errx 'progress_reporter_update: $1 is invalid'

	cur=$2
	[ -z $cur ] && progress_reporter__errx 'progress_reporter_update: $2 is invalid'

	[ $cur -lt $min ] && cur=$min
	[ $cur -gt $max ] && cur=$max

	progress_reporter__next
	echo $cur $max | awk "{printf \"%`progress_reporter__width_cur`d%%\", (\$1/\$2) * 100}"
}

# $1 - message (optional)
progress_reporter_end()
{
	progress_reporter__next
	[ -z "$1" ] && return
	printf "%${progress_reporter_width}s" "$1"
}
