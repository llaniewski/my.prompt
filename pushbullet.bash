#!/bin/bash

function pb_msg {
if test -z "$PB_TOKEN"
then
	>&2 echo "PushBullet: No PB token"
	return -1
fi

TITLE="$(echo "$1" | sed 's/"/\\"/g')"
shift
BODY="$(echo "$@" | sed 's/"/\\"/g')"

TMP=$(tempfile)

if ! test -z "$PB_LAST"
then
curl -s --header "Access-Token: $PB_TOKEN" \
	--header "Content-Type: application/json" \
	--data-binary '{"dismissed":true}' \
	--request POST \
	https://api.pushbullet.com/v2/pushes/$PB_LAST >$TMP
fi

curl -s --header "Access-Token: $PB_TOKEN" \
	--header "Content-Type: application/json" \
	--data-binary '{"body":"'"$BODY"'","title":"'"$TITLE"'","type":"note"}' \
	--request POST \
	https://api.pushbullet.com/v2/pushes >$TMP

test -f $TMP || exit -1
if grep -q '"active":true' $TMP
then
	PB_LAST=$(cat $TMP | sed -n 's/.*"iden":"\([^"]*\)".*/\1/p')
else
	>&2 echo "Something went wrong"
	>&2 cat $TMP
fi
rm $TMP

export PB_LAST
}

