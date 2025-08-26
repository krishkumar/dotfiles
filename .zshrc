# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,functions,extra,git_aliases}; do
	[ -r "$file" ] && source "$file"
done
unset file
#
# prompt
eval "$(starship init zsh)"
# Customize to your needs...

# zoxide 
eval "$(zoxide init zsh)"

# ZSH idiosyncrasy
PROMPT_EOL_MARK=''

# turn off autocorrect
unsetopt CORRECT

## autocomplete
if [[ ! -o interactive ]]; then
    return
fi

# Enable Git completion with branch name support
# Use -C to skip security check and -i to ignore insecure directories
autoload -Uz compinit && compinit -C
autoload -Uz bashcompinit && bashcompinit

# Load Git completion
zstyle ':completion:*:*:git:*' script /opt/homebrew/share/zsh/site-functions/git-completion.bash
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# Enable menu selection and case-insensitive completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Git branch completion with slash support
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' tag-order 'heads'

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# history configure - martinheinz.dev/blog/110
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"
HIST_STAMPS="yyyy-mm-dd"

setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

plugins=(git fzf)

# Load zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-history-substring-search
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bind keys for history substring search
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
bindkey '^P' history-substring-search-up      # Ctrl+P
bindkey '^N' history-substring-search-down    # Ctrl+N

# Customize autosuggestion appearance
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# Enhanced fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

