#!/bin/sh

SCRIPT_PATH=$(dirname $(realpath $0))
. $SCRIPT_PATH/progress_reporter.sh

progress_reporter_setWidth 50
progress_reporter_begin 'Converting: '
pr=`progress_reporter_new 0 331`
for i in `seq 0 331`; do
	progress_reporter_update $pr $i
done
progress_reporter_end 'ok'

echo ''
