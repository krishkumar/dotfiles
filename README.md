# dotfiles

My personal dotfiles repository. Accumulated configuration wisdom from years of macOS development work, carefully curated and battle-tested.

This is the exact setup I use daily for building software. No aspirational configurations here, this is the real deal.

## The essentials

**Shell configuration**: Switched from bash to zsh years ago, never looked back. The `.zshrc` includes Starship prompt integration (git status without the oh-my-zsh performance hit), extensive history configuration that works as expected, auto-suggestions that feel magical.

**Git integration**: The `.gitconfig` contains aliases accumulated over years of usage. Some obvious (`co` for `checkout`), others workflow-specific. The `.gitexcludes` handles global ignore patterns like `.DS_Store`, misplaced node_modules.

**Development environment**: The `.exports` file handles environment variables and PATH configuration. Setup gracefully loads additional dotfiles (`.path`, `.functions`, `.extra`, `.git_aliases`) if they exist. Nice modular approach.

## What you won't find

I exclude the `.config/` directory. While my nvim configuration is sophisticated (LSP integration, tree-sitter), those configurations are highly personal and change frequently. This repository focuses on foundational shell and git setup that remains stable.

## Structure

Uses the "whitelist approach". The `.gitignore` blocks everything (`/*`) then explicitly includes tracked files. Prevents accidentally committing sensitive files while keeping the repository focused.

Pattern learned from [Zach Holman's dotfiles](https://github.com/holman/dotfiles) years ago. Much cleaner than maintaining an exhaustive blacklist.

## Installation

No automated installer script. Blindly running someone else's dotfile installer is disaster-prone. You end up with configurations you don't understand, changes you can't debug.

Instead: examine each file individually and cherry-pick what makes sense for your workflow. Shell configuration assumes Starship is installed (`brew install starship`). Zsh setup requires zsh-autosuggestions and zsh-history-substring-search from Homebrew.

The git configuration includes my name and email. Change those.

## Why share

I've learned more from reading other developers' dotfiles than almost any other source. Something uniquely valuable about seeing actual tools and shortcuts productive developers rely on daily.

These configurations represent thousands of refinement hours. If one alias or configuration option saves you time, this repository served its purpose.

