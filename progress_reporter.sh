# Simple progress reporter for sh scripts.
#
# Functions/variables that contain '__' in their names are private, all
# others are public API.
#
# Uses sh-subset w/o bash extensions. External utils: expr, seq, awk.
# Tested on FreeBSD & Fedora.

progress_reporter__errx()
{
    echo "${0##*/} error: $1" 1>&2
    exit 1
}

progress_reporter_setWidth() {
	[ `expr "$1" : '[0-9]*$'` = 0 ] && \
		progress_reporter__errx 'progress_reporter_setWidth: $1 is invalid'
	[ $1 -lt 4 ] && progress_reporter__errx 'progress_reporter_setWidth: min width=4'

	PROGRESS_REPORTER__WIDTH=$1
	PROGRESS_REPORTER__WIDTH_CUR=$(($PROGRESS_REPORTER__WIDTH-1))

	PROGRESS_REPORTER__ERASER=''
	for i in `seq ${PROGRESS_REPORTER__WIDTH}`; do
		PROGRESS_REPORTER__ERASER="$PROGRESS_REPORTER__ERASER"
	done
}
progress_reporter_setWidth 4

progress_reporter__next()
{
	# erase characters on a terminal
	if [ -t 1 ] ; then
		printf $PROGRESS_REPORTER__ERASER
	else
		printf '\n'
	fi
}

# $1 - message (optional)
progress_reporter_begin()
{
	[ -z "$1" ] || printf '%s' "$1"
	printf "%${PROGRESS_REPORTER__WIDTH}s" ' '
	progress_reporter__next
	printf "%${PROGRESS_REPORTER__WIDTH_CUR}d%%" 0
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
	echo $cur $max | awk "{printf \"%${PROGRESS_REPORTER__WIDTH_CUR}d%%\", (\$1/\$2) * 100}"
}

# $1 - message (optional)
progress_reporter_end()
{
	progress_reporter__next
	[ -z "$1" ] && return
	printf "%${PROGRESS_REPORTER__WIDTH}s" "$1"
}
