# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# Options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt GLOB_DOTS
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# Completion
# Register third-party completions before compinit builds/loads its cache.
# This keeps command completion complete without re-scanning every shell launch.
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)
autoload -Uz compinit
_compcache="$HOME/.cache/zsh/compcache"
_compcache_version="$HOME/.cache/zsh/.compcache-v2"
if [[ ! -f "$_compcache_version" ]]; then
  compinit -d "$_compcache"
  touch "$_compcache_version"
else
  compinit -C -d "$_compcache"
fi
unset _compcache _compcache_version
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/compcache
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' format ' %F{cyan}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}Completing:%f %d'
zstyle ':completion:*:warnings' format '%F{red}No matches%f'
zstyle ':completion:*:functions' list-colors '=*=#cba6f7'
zstyle ':completion:*:directories' list-colors '=*=#89b4fa'
zstyle ':completion:*:commands' list-colors '=*=#f9e2af'
zstyle ':completion:*:kill:*' list-colors '=(#b) #0=0;font-weight=bold;fg=#f38ba8'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #0=0;type=service;fg=#a6e3a1'

# Plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[C' forward-word
bindkey '^[[D' backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^U' backward-kill-line
bindkey '^K' kill-line

# ── File Listing ──────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --group-directories-first --level=2'
alias lt3='eza -T --icons --group-directories-first --level=3'
alias la='eza -a --icons --group-directories-first'
alias l='eza -l --icons --group-directories-first --git'
alias l.='eza -d .* --icons --group-directories-first'
alias lx='eza -la --icons --group-directories-first --sort=extension'
alias lf='eza -la --icons --group-directories-first --sort=size'
alias lh='eza -la --icons --group-directories-first --sort=modified'

# ── Cat / Preview ─────────────────────────────────────────
alias cat='bat --paging=never --style=auto'
alias catp='bat --paging=never'
alias catg='bat --paging=never --style=numbers,grid'

# ── Search / Diff ─────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='delta'
alias pg='ps aux | grep'

# ── Navigation ────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'

# ── Safety ────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias ln='ln -iv'

# ── Network ───────────────────────────────────────────────
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='ip -brief addr'
alias ping3='ping -c 3'
alias fastping='ping -c 10 -s 1'

# ── Git ───────────────────────────────────────────────────
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -30'
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gb='git branch -vv'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gcp='git cherry-pick'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gbl='git blame -w'
alias gls='git ls-files --others --exclude-standard'

# ── NPM / Node ────────────────────────────────────────────
alias dev='npm run dev'
alias build='npm run build'
alias tst='npm test'
alias ni='npm install'
alias nis='npm install -S'
alias nid='npm install -D'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nnu='npm run lint:fix 2>/dev/null || npm run format 2>/dev/null || true'
alias nlg='npm list -g --depth=0'
alias ncu='ncu -i'

# ── Docker ────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dvol='docker volume ls'
alias dnet='docker network ls'
alias dup='docker compose up -d'
alias ddown='docker compose down'
alias drestart='docker compose restart'
alias dstats='docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'

# ── Tools ─────────────────────────────────────────────────
alias lg='lazygit'
alias bt='btop'
alias vim='nvim'
alias v='nvim'
alias vf='nvim $(fzf)'
alias yz='yazi'
alias tt='tmux attach -t 0 || tmux new-session'
alias tn='tmux new-session -s'

# ── Python / uv ───────────────────────────────────────────
alias py='python3'
alias pip='uv pip'
alias venv='uv venv'
alias avenv='source .venv/bin/activate'
alias uvinit='uv init'
alias uvadd='uv add'
alias uvsync='uv sync'

# ── System ────────────────────────────────────────────────
alias path='echo -e ${PATH//:/\\n}'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias mount='mount | column -t'
alias h='history -20'
alias j='jobs -l'
alias updatedb='sudo updatedb'

# ── Functions ─────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *.xz)      unxz "$1" ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ── Path ──────────────────────────────────────────────────
alias_path_add() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# ── fnm (Fast Node Manager) ───────────────────────────────
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

alias_path_add "$HOME/.local/bin"
alias_path_add "$HOME/.npm-global/bin"
alias_path_add "$HOME/.cargo/bin"
alias_path_add "$HOME/go/bin"

# ── uv (Fast Python) ─────────────────────────────────────
export UV_CACHE_DIR="$HOME/.cache/uv"

# ── Starship ──────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Zoxide ────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── FZF ───────────────────────────────────────────────────
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5c2e7 \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#45475a,separator:#45475a,scrollbar:#585b70 \
--color=label:#a6adc8 \
--multi \
--height=40% \
--layout=reverse \
--border=rounded \
--border-color='#45475a' \
--info=inline-right \
--prompt='[ Neil ]> ' \
--pointer=' ->' \
--marker=' *'"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

# ── Environment ───────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='sh -c "col -bx | bat -l man -p"'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TMPDIR=/tmp

# ── Cyberpunk Hub ─────────────────────────────────────────
cyber-hub() {
  if ! systemctl --user is-active cyberpunk-hub.service &>/dev/null; then
    systemctl --user start cyberpunk-hub.service
    echo "Starting Cyberpunk Hub..."
    sleep 1
  fi
  xdg-open http://127.0.0.1:7777 2>/dev/null || echo "Open http://127.0.0.1:7777"
}
cyber-stop() { systemctl --user stop cyberpunk-hub.service; echo "Cyberpunk Hub stopped"; }
cyber-status() { systemctl --user status cyberpunk-hub.service; }

# ── Utility Functions ─────────────────────────────────────
# Extract archive with auto-detection
ex() {
  if [ -f "$1" ]; then
    extract "$1"
  elif [ -d "$1" ]; then
    cd "$1"
  else
    echo "'$1' is not a valid file or directory"
  fi
}

# Create dir and cd into it
mk() { mkdir -p "$1" && cd "$1"; }

# Find file by name
ff() { find . -type f -iname "*$1*" 2>/dev/null; }

# Find directory by name
fdir() { find . -type d -iname "*$1*" 2>/dev/null; }

# Quick backup
bak() { cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}; }

# Show disk usage for current dir
usage() { du -sh * | sort -rh | head -20; }

# Git commit all with message
gcmall() { git add --all && git commit -m "$1"; }

# Docker cleanup
dclean() { docker system prune -af && docker volume prune -f; }

# ── Aliases ───────────────────────────────────────────────
alias keys="sys-manual"
alias health="sys-health"
alias clean="sys-clean"
alias runner="~/.local/bin/runner"
alias menu="~/.local/bin/runner"
alias os="~/.local/bin/runner"
alias scratch="~/.local/bin/scratch"
alias note="~/.local/bin/scratch"
alias cap="capture"
alias drill="mastery drill"
alias model="think"
alias flow="focus"
alias pj="proj"
alias ref="cheat"
alias ports="ss -tulpn"
alias myip="curl -s https://ipinfo.io/json | bat -l json"
alias bench="python3 -c 'import time; t0=time.time(); sum(i*i for i in range(20000000)); print(f\"CPU Compute: {time.time()-t0:.3f}s\")'"
alias pf='python3 -m http.server 8000'
alias reload='source ~/.zshrc && echo "Zsh config reloaded!"'
