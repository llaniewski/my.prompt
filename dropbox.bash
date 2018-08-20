DB_CURL_OPT="-s"

function db_err {
	>&2 echo "$@"
}

function db_token {
	if test -z "$DB_TOKEN"
	then
		db_err "DropBox: No PB token"
		return 255
	fi
	return 0
}

function db_resp_bool {
	cat "$1" | sed -n 's/.*"'"$2"'":\([^,{}]*\).*/\1/p'
}

function db_resp {
	cat "$1" | sed -n 's/.*"'"$2"'":"\([^"]*\)".*/\1/p'
}

function db_check_msg {
	TMP="$1"
	test -f $TMP || exit -1
	ACTIVE=$(db_resp_bool $TMP active)
	if [ "$ACTIVE" == "true" ]
	then
		DB_LAST=$(db_resp $TMP iden)
	else
		db_err "Something went wrong"
		>&2 cat $TMP
		db_err "--------------------"
	fi
	export DB_LAST
}

function db_file {
	db_token || return 255
	FILE="$1"
	BASE="$(basename $FILE)"
	test -z "$FILE" && return 255
	test -z "$BASE" && return 255
	if ! test -f "$FILE"
	then
		db_err "File doesn't exist: $FILE"
		return 255
	fi
	shift
	if test -z "$1"
	then
		DBPATH="/$BASE"
	else
		DBPATH="$1"
	fi
	TMP=$(mktemp)
	curl $DB_CURL_OPT \
		--header "Authorization: Bearer $DB_TOKEN" \
		--header "Dropbox-API-Arg: {\"path\": \"$DBPATH\", \"mode\": \"overwrite\"}" \
		--header "Content-Type: application/octet-stream" \
		--request POST \
		--data-binary "@$FILE" \
		https://content.dropboxapi.com/2/files/upload >$TMP 2>&1
#	db_check_msg $TMP || exit -1
	cat $TMP
	rm $TMP
}

