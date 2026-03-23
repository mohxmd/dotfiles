# -----------------------------------
# Helper Functions
# -----------------------------------
add_to_path() {
  [[ -d "$1" ]] && export PATH="$1:$PATH"
}

mcd() {
  mkdir -p "$1" && cd "$1"
}

ginit() {
  git init
  git branch -M main
  gh repo create "$(basename "$PWD")" --public --source=local
  git add .
  git commit -m "Initial commit"
  git push -u origin main
  echo "Project initialized and pushed to GitHub!"
}

# -----------------------------------
# Shell Options
# -----------------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
unsetopt inc_append_history
unsetopt BEEP

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
export COMPLETION_WAIT=0.1
export KEYTIMEOUT=10

# -----------------------------------
# Oh My Zsh (plugins & framework)
# -----------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
DISABLE_UPDATE_PROMPT=true

# -----------------------------------
# Starship (prompt)
# -----------------------------------
eval "$(starship init zsh)"

# -----------------------------------
# PATH
# -----------------------------------
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  export FPATH="$HOME/.zsh/completions:$FPATH"
fi

export ANDROID_HOME="$HOME/Android/Sdk"

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.opencode/bin"
add_to_path "$HOME/.turso"
add_to_path "$HOME/.bun/bin"
add_to_path "$HOME/Developer/flutter/bin"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/tools/bin"
add_to_path "$ANDROID_HOME/tools"
add_to_path "$ANDROID_HOME/emulator"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
add_to_path "$PNPM_HOME"

# Bun
add_to_path "$HOME/.bun/bin"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# -----------------------------------
# Aliases
# -----------------------------------
alias c='clear'
alias la='ls -A'
alias lsd='ls -d */'
alias codium='codium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime'

# Git
alias gs='git status --short'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'
alias gfa='git fetch --all'
alias gr='git remote -v'
alias gm='git merge'
alias grb='git rebase'

# Turso
alias t='turso'
alias tdb='turso db'
alias tls='turso db list'
alias tsh='turso db shell'
alias twho='turso auth whoami'

# Docker
alias dk='docker'
alias dki='docker images'
alias dkps='docker ps'
alias dkpa='docker ps -a'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkstop='docker stop'
alias dklogs='docker logs -f'
alias dkexec='docker exec -it'
alias dkprune='docker system prune -af'

# Docker Compose
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  alias dkc='docker compose'
  alias dkcu='docker compose up -d'
  alias dkcd='docker compose down'
  alias dkcr='docker compose restart'
  alias dkcl='docker compose logs -f'
  alias dkcps='docker compose ps'
  alias dkcb='docker compose build'
else
  alias dkc='docker-compose'
  alias dkcu='docker-compose up -d'
  alias dkcd='docker-compose down'
  alias dkcr='docker-compose restart'
  alias dkcl='docker-compose logs -f'
  alias dkcps='docker-compose ps'
  alias dkcb='docker-compose build'
fi

# -----------------------------------
# Custom Modules
# -----------------------------------
for script in ~/.config/zsh/modules/*.zsh(N); do
  source "$script"
done

export QT_SCALE_FACTOR=1.3
