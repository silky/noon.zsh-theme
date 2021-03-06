ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"

# Compacted $PWD
# For some reason this number is correlated to the auto-complete colour
# problem.
# pwd="%{%F{14}%}%c%{$reset_color%}"
pwd="%{$fg[green]%}%c%{$reset_color%}"

# The time in a sensible format
time="%{$fg[blue]%}%D{%I:%M %p}%{$reset_color%}"

# Elaborate exitcode on the right when >0
return_code_enabled="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
return_code_disabled="%{$fg[blue]%}%D{%a %b %d}%{$reset_color%}"
return_code=$return_code_disabled

# Default username
user="%(!.%{$fg[cyan]%}.%{$fg[cyan]%})%n φ %{$reset_color%}"

# Aws profile
aws_profle=""
aws-export-profile () {
    if [[ "$1" = '' ]]
    then
        echo "Usage: aws-export-profile [profile-name]"
    else
        eval $(
            cat ~/.aws/credentials \
            | sed  -n "/$1/,/\[/ p" \
            | grep = \
            | sed 's/ //g; s/^/export /'
        )
        aws_profile="%{$fg[blue]%}(aws:$1)%{$reset_color%} "
    fi
}

# Prompts
PROMPT='\
${aws_profile}\
${time} \
${user}\
${pwd}\
%{$fg[yellow]%}$(git_prompt_info)%{$reset_color%}\
%{$fg[red]%} %{$reset_color%}'

RPROMPT='${return_code}'

# Magic to get rid of the return code once, and colour things if we can sudo.
function maybe-sudo-color () {
    if [ "$(sudo -n echo 1 2>/dev/null)" = "1" ]; then
        user="%(!.%{$fg[cyan]%}.%{$fg[red]%})%n φ %{$reset_color%}"
    else
        user="%(!.%{$fg[cyan]%}.%{$fg[cyan]%})%n φ %{$reset_color%}"
    fi
}

function accept-line-or-clear-warning () {
    maybe-sudo-color

	if [[ -z $BUFFER ]]; then
		# time=$time_disabled
		return_code=$return_code_disabled
	else
		# time=$time_enabled
		return_code=$return_code_enabled
	fi
	zle accept-line
}

zle -N accept-line-or-clear-warning
bindkey '^M' accept-line-or-clear-warning

# Format is:
#   <foreground><background>
#
# where the colours are these:
#  - https://www.norbauer.com/rails-consulting/notes/ls-colors-and-terminal-app.html
#
# export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
