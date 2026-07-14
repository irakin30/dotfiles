# init check of dependencies, and to cache them 



fpath=("/nix/var/nix/profiles/default/share/zsh/site-functions" $fpath)

autoload -Uz compinit && compinit
zinit cdreplay -q

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light nix-community/nix-zsh-completions
zinit light Aloxaf/fzf-tab

NIX_PLUGIN_DIR=$HOME/.nix-profile/share/
source $HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh
source $HOME/.nix-profile/share/zsh
source $HOME/.nix-profile/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $HOME/.nix-profile/share/
source $HOME/.nix-profile/share/


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5A' up-line-or-history
bindkey '^[[1;5B' down-line-or-history


# Posted by mpy, modified by community. See post 'Timeline' for change history
# Retrieved 2026-03-02, License - CC BY-SA 4.0
autoload -Uz add_zsh_hook
filter_failed_or_unknown() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:complete:*' fzf-flags '--border'
zstyle ':fzf-tab:*' fzf-min-height 40

zstyle ':fzf-tab:complete:nix:*' fzf-preview '
[[ "$word" != -* ]] && nix help ${words[2,$CURRENT-1]}
'

# Aliases [NON-TTY]
if [[ "$TERM" != "linux" ]]; then
    alias ls='lsd'
fi


alias vim='nvim'
alias cat='bat --paging=always'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# nix related
alias ns='nix search nixpkgs'
alias nsh='nix-shell -p'
alias np='nix profile'

# EDITOR
alias emacs='emacs -nw'
alias doom='~/.config/emacs/bin/doom'
export EDITOR='emacs -nw'

add-zsh-hook zshaddhistory filter_failed_or_unknown

export PATH="$HOME/.local/bin:$PATH"

update() {
    echo "nix profile upgrade --all"
    nix profile upgrade --all
    echo "brew update"
    brew update
    echo "brew upgrade"
    brew upgrade
}
