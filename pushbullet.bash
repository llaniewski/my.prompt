#!/bin/bash

PB_CURL_OPT="-s"

function pb_err {
	>&2 echo "$@"
}

function pb_token {
	if test -z "$PB_TOKEN"
	then
		pb_err "PushBullet: No PB token"
		return -1
	fi
	return 0
}

function pb_resp_bool {
	cat "$1" | sed -n 's/.*"'"$2"'":\([^,{}]*\).*/\1/p'
}

function pb_resp {
	cat "$1" | sed -n 's/.*"'"$2"'":"\([^"]*\)".*/\1/p'
}

function pb_check_msg {
	TMP="$1"
	test -f $TMP || exit -1
	ACTIVE=$(pb_resp_bool $TMP active)
	if [ "$ACTIVE" == "true" ]
	then
		PB_LAST=$(pb_resp $TMP iden)
	else
		pb_err "Something went wrong"
		>&2 cat $TMP
		pb_err "--------------------"
	fi
	export PB_LAST
}

function pb_msg {
	pb_token || return -1
	TITLE="$(echo "$1" | sed 's/"/\\"/g')"
	shift
	BODY="$(echo "$@" | sed 's/"/\\"/g')"
	TMP=$(mktemp)
	pb_clear
	curl $PB_CURL_OPT --header "Access-Token: $PB_TOKEN" \
		--header "Content-Type: application/json" \
		--data-binary '{"body":"'"$BODY"'","title":"'"$TITLE"'","type":"note"}' \
		--request POST \
		https://api.pushbullet.com/v2/pushes >$TMP 2>&1
	pb_check_msg $TMP || exit -1
	rm $TMP
}

function pb_clear {
	[ -z "$PB_LAST" ] && return 0
	pb_token || return -1
	curl $PB_CURL_OPT --header "Access-Token: $PB_TOKEN" \
		--header "Content-Type: application/json" \
		--data-binary '{"dismissed":true}' \
		--request POST \
		https://api.pushbullet.com/v2/pushes/$PB_LAST >/dev/null
	PB_LAST=""
	export PB_LAST
}

function pb_upload_file {
	pb_token || return -1
	FILE="$1"
	if ! test -f "$FILE"
	then
		pb_err "File doesn't exist in pb_upload_file: $FILE"
		return -1
	fi
	TMP=$(mktemp)
	MIME=$(file -b --mime-type "$FILE")
	NAME=$(basename "$FILE")
	curl $PB_CURL_OPT --header "Access-Token: $PB_TOKEN" \
		--header "Content-Type: application/json" \
		--data-binary '{"file_name":"'"$NAME"'","file_type":"'"$MIME"'"}' \
		--request POST \
		https://api.pushbullet.com/v2/upload-request >$TMP
	UPLOAD_URL=$(pb_resp $TMP upload_url)
	FILE_URL=$(pb_resp $TMP file_url)
	if test -z "$UPLOAD_URL"
	then
		pb_err "No upload_url - probably request failed"
		return -1
	fi
	curl $PB_CURL_OPT --request POST \
		--form file=@"$FILE" \
		$UPLOAD_URL >/dev/null || return -1
	echo $FILE_URL
	export FILE_URL FILE NAME MIME
	return 0
}


function pb_file {
	pb_token || return -1
	TITLE="$(echo "$1" | sed 's/"/\\"/g')"
	shift
	FILE="$1"
	shift
	BODY="$(echo "$@" | sed 's/"/\\"/g')"
	pb_upload_file "$FILE" >/dev/null || return -1
	TMP=$(mktemp)
	pb_clear
	curl $PB_CURL_OPT --header "Access-Token: $PB_TOKEN" \
		--header "Content-Type: application/json" \
		--data-binary '{"title":"'"$TITLE"'","body":"'"$BODY"'","tile_name":"'"$NAME"'","file_type":"'"$MIME"'","file_url":"'"$FILE_URL"'","type":"file"}' \
		--request POST \
		https://api.pushbullet.com/v2/pushes >$TMP
	pb_check_msg $TMP || exit -1
	rm $TMP
}

