# Load exports first to get HOMEBREW_PREFIX
[[ -r "$HOME/.exports" ]] && source "$HOME/.exports"

# Initialize Homebrew
# Location is configured in ~/.exports via HOMEBREW_PREFIX
if [[ -n "$HOMEBREW_PREFIX" ]] && [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi
