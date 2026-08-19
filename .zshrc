# -----------------------------------
# Helper Functions
# -----------------------------------
add_to_path() {
  [[ -d "$1" ]] && export PATH="$1:$PATH"
}

mcd() {
  mkdir -p "$1" && cd "$1"
}

vaultget() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: vaultget <secret-name>" >&2
    return 2
  fi
  command -v vaultlet >/dev/null 2>&1 || {
    echo "vaultlet is not installed. Run: ./run vaultlet" >&2
    return 1
  }
  vaultlet get "$1" --raw
}

ghv() {
  command -v vaultlet >/dev/null 2>&1 || {
    echo "vaultlet is not installed. Run: ./run vaultlet" >&2
    return 1
  }

  local token
  token="$(vaultlet get github_token --raw)" || return 1
  [[ -n "$token" ]] || {
    echo "Vaultlet secret is empty: github_token" >&2
    return 1
  }

  GH_TOKEN="$token" gh "$@"
}

ginit() {
  local visibility="${GITHUB_VISIBILITY:-private}"
  if [[ "$visibility" != "private" && "$visibility" != "public" && "$visibility" != "internal" ]]; then
    echo "GITHUB_VISIBILITY must be private, public, or internal." >&2
    return 1
  fi

  git init
  git branch -M main
  git add .
  git commit -m "Initial commit"
  ghv repo create "$(basename "$PWD")" "--$visibility" --source=local --push
  echo "Project initialized and pushed to GitHub!"
}

# -----------------------------------
# Shell Options
# -----------------------------------
if [[ -z "${LANG:-}" ]]; then
  if locale -a 2>/dev/null | grep -qi '^en_US\.utf-8$'; then
    export LANG=en_US.UTF-8
  else
    export LANG=C.UTF-8
  fi
fi
export LC_ALL="${LC_ALL:-$LANG}"

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
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME=""

plugins=(
  git
)

[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

DISABLE_UPDATE_PROMPT=true
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# -----------------------------------
# Starship (prompt)
# -----------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

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
add_to_path "$HOME/.deno/bin"
add_to_path "$HOME/.bun/bin"
add_to_path "$HOME/Developer/flutter/bin"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/tools/bin"
add_to_path "$ANDROID_HOME/tools"
add_to_path "$ANDROID_HOME/emulator"

# NVM
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  source "$NVM_DIR/nvm.sh"
elif [[ -s /usr/share/nvm/init-nvm.sh ]]; then
  # shellcheck disable=SC1091
  source /usr/share/nvm/init-nvm.sh
elif [[ -s /usr/share/nvm/nvm.sh ]]; then
  # shellcheck disable=SC1091
  source /usr/share/nvm/nvm.sh
fi
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

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

# pnpm
export PNPM_HOME="/home/mohammedsh/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
