# ── Environment ───────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER 'sh -c "col -bx | bat -l man -p"'
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# ── PATH ──────────────────────────────────────────────────
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.npm-global/bin

# ── Starship Prompt ───────────────────────────────────────
starship init fish | source

# ── Zoxide ────────────────────────────────────────────────
zoxide init fish | source

# ── FZF ───────────────────────────────────────────────────
set -gx FZF_DEFAULT_OPTS "\
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
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

# ── Vi Mode ───────────────────────────────────────────────
fish_vi_key_bindings

# ── Aliases: File Listing ─────────────────────────────────
alias ls 'eza --icons --group-directories-first'
alias ll 'eza -la --icons --group-directories-first --git'
alias lt 'eza -T --icons --group-directories-first --level=2'
alias la 'eza -a --icons --group-directories-first'
alias l 'eza -l --icons --group-directories-first --git'
alias l. 'eza -d .* --icons --group-directories-first'

# ── Aliases: Cat / Preview ────────────────────────────────
alias cat 'bat --paging=never --style=auto'
alias catp 'bat --paging=never'

# ── Aliases: Search / Diff ────────────────────────────────
alias grep 'grep --color=auto'
alias diff 'delta'
alias pg 'ps aux | grep'

# ── Aliases: Navigation ───────────────────────────────────
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# ── Aliases: Safety ───────────────────────────────────────
alias rm 'rm -i'
alias cp 'cp -i'
alias mv 'mv -i'
alias mkdir 'mkdir -pv'

# ── Aliases: Network ──────────────────────────────────────
alias localip 'ip -brief addr'

# ── Aliases: Git ──────────────────────────────────────────
alias gs 'git status -sb'
alias ga 'git add'
alias gaa 'git add --all'
alias gc 'git commit'
alias gcm 'git commit -m'
alias gca 'git commit --amend'
alias gp 'git push'
alias gpf 'git push --force-with-lease'
alias gl 'git log --oneline --graph --decorate -20'
alias gla 'git log --oneline --graph --decorate --all -30'
alias gd 'git diff'
alias gds 'git diff --staged'
alias gdw 'git diff --word-diff'
alias gb 'git branch -vv'
alias gco 'git checkout'
alias gcb 'git checkout -b'
alias gst 'git stash'
alias gstp 'git stash pop'
alias gstl 'git stash list'

# ── Aliases: Dev ──────────────────────────────────────────
alias dev 'npm run dev'
alias build 'npm run build'
alias tst 'npm test'
alias ni 'npm install'
alias nis 'npm install -S'
alias nid 'npm install -D'
alias nrd 'npm run dev'
alias nrb 'npm run build'
alias nrt 'npm run test'

# ── Aliases: Docker ───────────────────────────────────────
alias d 'docker'
alias dc 'docker compose'
alias dps 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa 'docker ps -a'
alias di 'docker images'
alias dex 'docker exec -it'
alias dlog 'docker logs -f'
alias dprune 'docker system prune -af'
alias dup 'docker compose up -d'
alias ddown 'docker compose down'
alias drestart 'docker compose restart'
alias dstats 'docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'

# ── Aliases: Tools ────────────────────────────────────────
alias lg 'lazygit'
alias bt 'btop'
alias vim 'nvim'
alias v 'nvim'
alias yz 'yazi'
alias tt 'tmux attach -t 0; or tmux new-session'
alias tn 'tmux new-session -s'

# ── Aliases: Python ───────────────────────────────────────
alias py 'python3'
alias pip 'pip3'
alias venv 'python3 -m venv .venv'
alias avenv 'source .venv/bin/activate'

# ── Aliases: System ───────────────────────────────────────
alias path 'echo -e $PATH | tr \":\" \"\n\"'
alias now 'date "+%Y-%m-%d %H:%M:%S"'
alias reload 'source ~/.config/fish/config.fish; and echo "Fish config reloaded!"'
alias keys 'sys-manual'
alias health 'sys-health'
alias clean 'sys-clean'
alias runner '~/.local/bin/runner'
alias menu '~/.local/bin/runner'
alias os '~/.local/bin/runner'
alias scratch '~/.local/bin/scratch'
alias note '~/.local/bin/scratch'
alias cap 'capture'
alias drill 'mastery drill'
alias model 'think'
alias flow 'focus'
alias pj 'proj'
alias ref 'cheat'
alias ports 'ss -tulpn'
alias myip 'curl -s https://ipinfo.io/json | bat -l json'
alias bench 'python3 -c "import time; t0=time.time(); sum(i*i for i in range(20000000)); print(f\"CPU Compute: {time.time()-t0:.3f}s\")"'

# ── Completions ───────────────────────────────────────────
complete -c gcm -x -a '(git branch --format="%(refname:short)" 2>/dev/null)'
complete -c gco -x -a '(git branch --format="%(refname:short)" 2>/dev/null)'
complete -c gcb -x
complete -c gstp -x -a '(git stash list --format="%(gdref:short)" 2>/dev/null)'

# ── Functions ─────────────────────────────────────────────
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'; tar xjf $argv[1]
            case '*.tar.gz';  tar xzf $argv[1]
            case '*.tar.xz';  tar xJf $argv[1]
            case '*.bz2';     bunzip2 $argv[1]
            case '*.rar';     unrar x $argv[1]
            case '*.gz';      gunzip $argv[1]
            case '*.tar';     tar xf $argv[1]
            case '*.zip';     unzip $argv[1]
            case '*.7z';      7z x $argv[1]
            case '*';         echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

function ex
    if test -f $argv[1]
        extract $argv[1]
    else if test -d $argv[1]
        cd $argv[1]
    else
        echo "'$argv[1]' is not a valid file or directory"
    end
end

function ff
    find . -type f -iname "*$argv[1]*" 2>/dev/null
end

function bak
    cp $argv[1]{,.bak-(date +%Y%m%d-%H%M%S)}
end

function usage
    du -sh * | sort -rh | head -20
end

function gcmall
    git add --all; and git commit -m "$argv[1]"
end

function dclean
    docker system prune -af; and docker volume prune -f
end

function pf
    python3 -m http.server 8000
end
