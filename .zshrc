# ===============================================================
# DORIAN'S ZSHRC — minimal, fast, no fluff
# ===============================================================

# 1. PATH
typeset -aU path
path=($HOME/.local/bin $HOME/.cargo/bin /opt/homebrew/bin /usr/local/bin $path)
export PATH

# 2. CORE DEFAULTS
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS AUTO_CD
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history

# 3. VI MODE
bindkey -v
export KEYTIMEOUT=1
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Cursor: beam in insert, block in normal
zle-keymap-select() {
  [[ $KEYMAP = vicmd ]] && printf '\e[2 q' || printf '\e[6 q'
}
zle -N zle-keymap-select

# 4. PROMPT
PROMPT="%F{cyan}%n%f@%F{blue}%m%f %F{green}%1~%f $ "

# 5. FZF — lazy load completions only when needed
_fzf_init() {
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  source <(fzf --zsh 2>/dev/null)
  unset -f _fzf_init
}
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
autoload -Uz compinit && compinit -C -d ~/.zcompdump

# 6. ALIASES
alias ..='cd ..'
alias ...='cd ../..'
alias v='/run/current-system/sw/bin/nvim'
alias reload='source ~/.zshrc'
alias zconfig='v ~/.zshrc'

# eza aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'

# 7. PLUGINS — lazy load syntax highlighting (it runs on every keypress)
_zsh_syntax_highlight() {
  source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  unset -f _zsh_syntax_highlight
}
# Load autosuggestions synchronously (it's fast)
[[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# hop zsh integration
autoload -U add-zsh-hook
__hop_chpwd() { command hop add -- "$PWD" >/dev/null 2>&1 }
add-zsh-hook chpwd __hop_chpwd

__hop_cd() {
    if (( $# == 0 )); then
        local dir
        dir=$(command hop pick)
        [[ -n "$dir" ]] && builtin cd -- "$dir"
        return
    fi
    case "$1" in
        -|..|.|~|~/) builtin cd -- "$@"; return ;;
    esac
    if [[ -d "$1" ]]; then
        builtin cd -- "$@"
        return
    fi
    local dir
    dir=$(command hop p -- "$@")
    if [[ -n "$dir" ]]; then
        builtin cd -- "$dir"
    else
        builtin cd -- "$@"
    fi
}
alias cd='__hop_cd'
