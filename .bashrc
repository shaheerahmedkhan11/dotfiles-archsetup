#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── fnm (Fast Node Manager) ───────────────────────────────
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

# ── PATH ──────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# ── History ───────────────────────────────────────────────
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# ── File Listing ──────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --group-directories-first --level=2'
alias la='eza -a --icons --group-directories-first'
alias l='eza -l --icons --group-directories-first --git'
alias l.='eza -d .* --icons --group-directories-first'

# ── Cat / Preview ─────────────────────────────────────────
alias cat='bat --paging=never --style=auto'
alias catp='bat --paging=never'

# ── Search / Diff ─────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='delta'
alias pg='ps aux | grep'

# ── Navigation ────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ── Safety ────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# ── Network ───────────────────────────────────────────────
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='ip -brief addr'

# ── Git ───────────────────────────────────────────────────
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch -vv'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'

# ── Dev ───────────────────────────────────────────────────
alias dev='npm run dev'
alias build='npm run build'
alias tst='npm test'
alias ni='npm install'
alias nis='npm install -S'
alias nid='npm install -D'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'

# ── Docker ────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dup='docker compose up -d'
alias ddown='docker compose down'

# ── Tools ─────────────────────────────────────────────────
alias lg='lazygit'
alias bt='btop'
alias vim='nvim'
alias v='nvim'
alias yz='yazi'
alias reload='source ~/.bashrc && echo "Bash config reloaded!"'

# ── Python / uv ───────────────────────────────────────────
alias py='python3'
alias pip='uv pip'
alias venv='uv venv'
alias avenv='source .venv/bin/activate'
alias uvinit='uv init'
alias uvadd='uv add'
alias uvsync='uv sync'

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
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ── Environment ───────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='sh -c "col -bx | bat -l man -p"'

# ── FZF ───────────────────────────────────────────────────
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5c2e7 \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#45475a,separator:#45475a,scrollbar:#585b70 \
--multi \
--height=40% \
--layout=reverse \
--border=rounded \
--border-color='#45475a'"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

# ── Starship & Zoxide ────────────────────────────────────
eval "$(starship init bash)"
eval "$(zoxide init bash)"

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

