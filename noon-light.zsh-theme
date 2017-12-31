ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"

# Compacted $PWD
pwd="%{%F{202}%}%c%{$reset_color%}"

# The time in a sensible format
time_enabled="%(?.%{$fg[cyan]%}.%{$fg[red]%}⚡ )%D{%I:%M %p}%{$reset_color%}"
time_disabled="%{$fg[cyan]%}%D{%I:%M %p}%{$reset_color%}"
time=$time_enabled

# Elaborate exitcode on the right when >0
return_code_enabled="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
return_code_disabled="%{$fg[magenta]%}%D{%a %b %d}%{$reset_color%}"
return_code=$return_code_disabled

# Default username
user="%(!.%{%F{19}%}.%{%F{19}%})%n ∈ %{$reset_color%}"

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
%{%F{21}%}$(git_prompt_info)%{$reset_color%}\
%{$fg[yellow]%} ♫ %{$reset_color%}'

RPROMPT='${return_code}'

# Magic to get rid of the return code once, and colour things if we can sudo.
function maybe-sudo-color () {
    if [ "$(sudo -n echo 1 2>/dev/null)" = "1" ]; then
        user="%(!.%{%F{19}%}.%{$fg[red]%})%n ∈ %{$reset_color%}"
    else
        user="%(!.%{%F{19}%}.%{%F{19}%})%n ∈ %{$reset_color%}"
    fi
}

function accept-line-or-clear-warning () {
    maybe-sudo-color

	if [[ -z $BUFFER ]]; then
		time=$time_disabled
		return_code=$return_code_disabled
	else
		time=$time_enabled
		return_code=$return_code_enabled
	fi
	zle accept-line
}

zle -N accept-line-or-clear-warning
bindkey '^M' accept-line-or-clear-warning
