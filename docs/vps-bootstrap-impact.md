# Server Environment & VPS Provisioning

Specification and operational reference for headless Arch Linux server provisioning via `vps-bootstrap` and the `server` dotfiles profile.

---

## Overview

- **Target**: Cloud / VPS instances running Arch Linux (headless).
- **Entrypoint**: `./vps-bootstrap`
- **Dotfiles Profile**: `server` (`./setup.sh --profile server`)
- **Scope**: Base server packages, container runtime, reverse proxy, shell environment, and editor configuration. Excludes all graphical, desktop (KDE/Plasma), and audio components.

---

## Production Constraints

1. **Official Repositories Only**: All system packages are installed via `pacman -Syu`. No AUR helpers (e.g. `paru`) and no local builds are introduced on production servers.
2. **Headless Isolation**: Desktop-only assets, GUI configs, display-scale factors, and Plasma applets are excluded at the profile level.
3. **Secret Separation**: No tokens, private keys, or credentials exist in this repository. Host-specific secrets are managed via local `.env` files or Vaultlet outside git.
4. **Safe Symlinks**: Dotfiles are linked relatively into `$HOME`. Pre-existing real files are backed up to timestamped copies (`*.pre-dotfiles-<timestamp>`).

---

## Provisioning Pipeline (`vps-bootstrap`)

### 1. System Packages

| Domain | Packages | Role |
|---|---|---|
| **Container Engine** | `docker`, `docker-compose`, `docker-buildx` | Application deployment and orchestration |
| **Reverse Proxy** | `caddy` | Automatic TLS termination and routing |
| **Firewall & Net** | `nftables`, `curl` | Kernel-level packet filtering and network utilities |
| **Shell & Prompt** | `zsh`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting` | Interactive CLI runtime |
| **Terminal & Editor** | `neovim`, `tmux`, `htop`, `git` | Background sessions, monitoring, code inspection |

### 2. Services & User Privileges

- **Docker**: Enabled and started (`systemctl enable --now docker.service`).
- **Caddy**: Installed via pacman; service startup is deferred until production `Caddyfile` is deployed.
- **User Group**: Current user added to the `docker` group for socket access without `sudo`.
- **Login Shell**: User shell updated to `/usr/bin/zsh`.
- **Oh My Zsh**: Installed in unattended mode if absent; official Arch plugin packages linked into OMZ custom directory.

### 3. Profile Link Mapping (`--profile server`)

#### Linked Targets
| Dotfiles Source | Destination | Purpose |
|---|---|---|
| `.zshrc` | `~/.zshrc` | Shell configuration, shared history, and operational aliases |
| `.config/starship.toml` | `~/.config/starship.toml` | Prompt theme with SSH host identification |
| `.config/nvim` | `~/.config/nvim` | Neovim editor configuration |
| `.config/pgcli/config` | `~/.config/pgcli/config` | PostgreSQL CLI styling and state path redirection |
| `.local/bin/cfd-init` | `~/.local/bin/cfd-init` | Cloudflare tunnel configuration template generator |

#### Excluded Targets (Desktop / Non-Server)
- `.config/paru/paru.conf` (AUR helper configuration; server uses official repositories only)
- `.config/plasma-org.kde.plasma.desktop-appletsrc` (KDE Plasma panels)
- `.config/kwinrulesrc` (KWin rules)
- `.local/share/plasma/plasmoids`, `.local/share/color-schemes`, `.local/share/konsole`
- `.config/Code/User/*` (VS Code GUI settings and keybindings)
- `.local/bin/fix-hdmi-audio`, `.local/bin/search`, `.local/bin/image-request`, `.local/bin/video-to-ascii`

---

## Runtime Behavior

### Shell & Prompt
- Prompt format: `user@hostname dir ➜` with active Git branch status. Host badge displays automatically under SSH sessions.
- History options: `INC_APPEND_HISTORY` and `SHARE_HISTORY` persist commands immediately across concurrent terminal windows.

### Aliases
- **Docker**: `dk` (`docker`), `dkps` (`docker ps`), `dklogs` (`docker logs -f`), `dkexec` (`docker exec -it`), `dkprune` (`docker system prune -af`)
- **Docker Compose**: `dkc` (`docker compose`), `dkcu` (`up -d`), `dkcd` (`down`), `dkcr` (`restart`), `dkcl` (`logs -f`), `dkcb` (`build`)
- **Git**: `gs` (`status -s`), `gd` (`diff`), `gl` (`log --graph`), `gp` (`push`), `gpl` (`pull`)

### Session Persistence
- Long-running jobs and builds run inside `tmux` sessions to prevent interruption on SSH disconnect.

---

## Execution

### Initial Setup
```bash
git clone https://github.com/mohxmd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./vps-bootstrap
exit
```

### Applying Configuration Updates
```bash
cd ~/dotfiles
git pull
./setup.sh --profile server
```
