#
# Author: L Laniewski-Wollk
# Script which allow to print notice after a long running command
#

LONG_COMMAND=10
VERY_LONG_COMMAND=30
LONG_COMMAND_EXCEPTIONS="joe|vi|ssh|git commit|watch|top|atop"

function long_command_start {
	pb_clear
	[ -n "$COMP_LINE" ] && return  # do nothing if completing
	[ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause a preexec for $PROMPT_COMMAND        
	if [ -z "$BEFORE_SECONDS" ]
	then
		BEFORE_SECONDS="$SECONDS"
		BEFORE_COMMAND="$BASH_COMMAND"
	else
		BEFORE_COMMAND="... $BASH_COMMAND"
	fi
}

function long_command_finish {
	pb_clear
	EC=$?
	SEC="0"
	[ -z "$BEFORE_SECONDS" ] && return
	SEC=$(expr $SECONDS - $BEFORE_SECONDS)
	if [ "$SEC" -gt "$LONG_COMMAND" ]
	then
		[ $EC -ne 0 ] && FAIL=" failed"
		echo -e "\e[31mLast command$FAIL: $BEFORE_COMMAND ($SEC s)\e[0m"
	fi
	if [ "$SEC" -gt "$VERY_LONG_COMMAND" ]
	then
		LONG_COMMAND_PATTERN_="$LONG_COMMAND_PATTERN"
		[ -z "$LONG_COMMAND_PATTERN_" ] && LONG_COMMAND_PATTERN_="^ *(.*/|)($LONG_COMMAND_EXCEPTIONS)"
		if ! echo "$BEFORE_COMMAND" | grep -E "$LONG_COMMAND_PATTERN_" >/dev/null 2>&1
		then
			FIN="Finished"
			[ $EC -ne 0 ] && FIN="Failed"
			pb_msg "$BEFORE_COMMAND" "$FIN after ($SEC s)"
		fi
	fi
	BEFORE_SECONDS=""
	BEFORE_COMMAND=""
}

trap - DEBUG
trap long_command_start DEBUG
PROMPT_COMMAND="long_command_finish"
