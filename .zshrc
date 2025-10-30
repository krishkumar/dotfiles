#!/usr/bin/env zsh

# =============================================================================
# ZSH Configuration
# =============================================================================
# Main zsh configuration file
# Loads dotfiles, configures shell options, initializes tools
# =============================================================================

# -----------------------------------------------------------------------------
# Load Dotfiles
# -----------------------------------------------------------------------------
# Load shell configuration files in order
# .path extends PATH, .exports sets variables, .aliases defines shortcuts

for file in ~/.{path,exports,aliases,functions,extra,git_aliases}; do
	[[ -r "$file" ]] && source "$file"
done
unset file

# -----------------------------------------------------------------------------
# Shell Options
# -----------------------------------------------------------------------------

# Turn off autocorrect
unsetopt CORRECT

# Customize ZSH prompt end-of-line marker
PROMPT_EOL_MARK=''

# Exit early if non-interactive
if [[ ! -o interactive ]]; then
    return
fi

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
# Enhanced history settings for better command recall
# Reference: martinheinz.dev/blog/110

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"
HIST_STAMPS="yyyy-mm-dd"

setopt EXTENDED_HISTORY       # Write history in ':start:elapsed;command' format
setopt INC_APPEND_HISTORY     # Write to history immediately, not on exit
setopt SHARE_HISTORY          # Share history between all sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicates
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to file
setopt HIST_VERIFY            # Don't execute immediately on history expansion
setopt APPEND_HISTORY         # Append to history file (default)
setopt HIST_NO_STORE          # Don't store history commands
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks

# -----------------------------------------------------------------------------
# Completion System
# -----------------------------------------------------------------------------

# Load completion system
autoload -Uz compinit && compinit -C  # -C skips security check for speed
autoload -Uz bashcompinit && bashcompinit

# Git completion
zstyle ':completion:*:*:git:*' script "$HOMEBREW_PREFIX/share/zsh/site-functions/git-completion.bash"
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

# Completion behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Git branch completion
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' tag-order 'heads'

# -----------------------------------------------------------------------------
# ZSH Plugins
# -----------------------------------------------------------------------------

# zsh-autosuggestions (fish-like suggestions)
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
fi

# zsh-history-substring-search
if [[ -f "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------

# History substring search (requires zsh-history-substring-search plugin)
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
bindkey '^P' history-substring-search-up      # Ctrl+P
bindkey '^N' history-substring-search-down    # Ctrl+N

# -----------------------------------------------------------------------------
# External Tool Initialization
# -----------------------------------------------------------------------------

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Zoxide (smarter cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF (fuzzy finder)
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# -----------------------------------------------------------------------------
# Language Version Managers
# -----------------------------------------------------------------------------

# rbenv (Ruby)
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init - zsh)"
fi

# pyenv (Python)
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init - zsh)"
fi

# NVM (Node.js)
# Note: Can be slow to load. Consider lazy-loading for better performance.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# -----------------------------------------------------------------------------
# System Tweaks
# -----------------------------------------------------------------------------

# Increase file descriptor limit (prevents "too many open files" errors)
ulimit -n 4096

# macOS fork safety for Objective-C runtime
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
