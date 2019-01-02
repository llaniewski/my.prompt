function parse_git_branch_and_add_brackets {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[\1\]/'
}

function parse_git_url {
	git config remote.origin.url 2> /dev/null
}

function parse_git_describe {
	git describe --tags 2> /dev/null
}

PS1='\e[0m[\t] \e[32m\h:\w \e[31m$(parse_git_describe) $(parse_git_branch_and_add_brackets)\e[0m\n > '
PS2="+> "
export PS1 PS2
