# Dotfiles

My personal modular dotfiles for Arch Linux across my machines (KDE Plasma, Hyprland, WSL2, and personal VPS/servers), built with pure Bash symlinking.

Designed to keep my daily developer environment identical everywhere while keeping secrets and machine-specific setups isolated. Feel free to explore, fork, or adapt anything here for your own setup.

## Structure

```bash
dotfiles/
├── shared/          # Core CLI & shell (Zsh, Neovim, Starship, Paru, scripts) — used on all machines
├── hypr/            # Hyprland setup (Hyprland, Waybar, Kitty, Mako, Rofi, Cava, Htop, Obsidian)
├── kde/             # KDE Plasma setup (Plasma, KWin, Konsole, Color schemes, Kate themes)
├── code/            # VS Code and VSCodium configuration & desktop entries
└── assets/          # Wallpapers, fonts, and images (non-linked)
```

## Setup & Profiles

How I link my configurations depending on the environment:

```bash
git clone https://github.com/mohxmd/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### On Hyprland:

```bash
./setup.sh --profile hyprland
```

> [!TIP]
> On a clean Arch install (e.g. via `archinstall` with Hyprland and Kitty), `./setup.sh --profile hyprland` links configs immediately. To pull in all companion utilities (Waybar, Mako, Rofi, fonts), I run:
> ```bash
> ./run hyprland
> ```

### On KDE Plasma:

```bash
./setup.sh --profile kde
```

## Profiles

- `hyprland`: links `shared` + `hypr` + `code`
- `kde`: links `shared` + `kde` + `code`
- `gnome`: links `shared` + `code`
- `minimal`: links `shared` only
- `wsl`: links `shared` only
- `server`: links `shared` without desktop tools
- `auto`: detects environment automatically (Hyprland vs KDE vs WSL vs Mac vs Server)

`shared` package includes:
- `.zshrc` & `.config/zsh`
- `.config/nvim` (Neovim LSP, Completion, Treesitter, Telescope)
- `.config/starship.toml`
- `.config/paru/paru.conf`
- `.config/pgcli/config`
- `.config/htop/` (Process viewer)
- `.config/fastfetch/` (System summary)
- `.config/fontconfig/` (Crisp font rendering)
- `.config/cava/` (Audio visualizer)
- `.config/obs-studio/` (Screen recording)
- `.obsidian/` (Monochrome notes vault configuration)
- `.local/bin/` (`search`, `cfd-init`, `image-request`, `video-to-ascii`)

`hypr` package includes:
- `.config/hypr/` (`hyprland.conf`, `hyprpaper.conf`, `hyprlock.conf`, `set-wallpaper.sh`)
- `.config/waybar/` (Modular Waybar status bar with window rewrites)
- `.config/kitty/` (JetBrainsMono Nerd Font, low latency, dark monochrome)
- `.config/mako/` (Lightweight Wayland notification daemon)
- `.config/rofi/` (Application launcher & power menu)
- `.config/gtk-3.0/` & `.config/gtk-4.0/` (Consistent dark theme, cursor, and Papirus icons)
- `.config/kolourpaintrc` & `.config/user-dirs.locale`

## Setup Flags

Custom profile adjustments when needed:

```bash
./setup.sh --profile gnome --without code
./setup.sh --profile minimal --with nvim
./setup.sh --dry-run --profile kde
```

## Syncing Changes Back

When I make live adjustments to my desktop, Plasma, or shell configs that I want to commit back to the repo:

```bash
./scripts/sync-current-config.sh
```

My `ginit` Zsh helper creates private GitHub repositories by default (`GITHUB_VISIBILITY=public ginit` when creating an intentionally public repo).

## Local Secrets with Vaultlet

I keep encrypted secrets completely outside this repository using Vaultlet. Vault files and configurations are intentionally never committed or symlinked.

How I set up and store secrets on a fresh machine:

```bash
./run vaultlet
vaultlet init
vaultlet set github_token
vaultlet set openai_api_key
```

Retrieving values on demand:

```bash
vaultget github_token
vaultlet get openai_api_key --copy
ghv repo view
```

Secrets are never auto-exported globally. `ginit` uses `github_token` only when running `gh`, and `image-request` reads `openai_api_key` only during execution. On WSL, I store the vault in the Linux filesystem rather than `/mnt/c`.

## Arch Run Tasks

Modular tasks in `run.d/` for installing toolchains and services on Arch:

```bash
./run --list
./run dev
./run hyprland
./run firewall
./run dns-cloudflare
./run bluetooth
./run cloudflared
./run docker
./run java
./run postgres
./run rust
./run bun
./run deno
./run nvm-node
./run vaultlet
./run zsh
./run dotfiles auto
```

### System Bootstraps

Entrypoints for provisioning fresh machines:

#### 1. Bare-metal Arch Linux
```bash
./arch-bootstrap
```
Installs core dev packages, UFW firewall, Docker, Java, Zsh, and Vaultlet, then applies dotfiles. Optional flags:
```bash
ENABLE_DNS_CLOUDFLARE=1 ENABLE_BLUETOOTH=1 ./arch-bootstrap
```

#### 2. Arch WSL2 (Windows dev environment)
```bash
./wsl-bootstrap
```
How I bootstrap Arch inside WSL2. Installs CLI development tools, configures `/etc/wsl.conf` with systemd enabled, sets up Zsh, and applies the `wsl` profile. Desktop services (`firewall`, `bluetooth`, `docker`) are skipped because Windows handles them (e.g. Docker Desktop WSL integration).

The `wsl/` folder contains reference templates for `/etc/wsl.conf` and host `%UserProfile%\.wslconfig`.

#### 3. Arch Linux VPS (Headless servers)
```bash
./vps-bootstrap
```
Provisions headless servers (Netcup / Hetzner): Docker, Docker Compose, Caddy, Nftables, Neovim, Zsh, and Starship, and applies the `server` profile without desktop packages or AUR helpers.

### Cloudflare Tunnels

How I set up and run multi-project tunnels:

```bash
cfd-init my-tunnel api.example.com http://localhost:8080
CLOUDFLARED_CONFIG=./cloudflared/configs/my-tunnel.yml ./run cloudflared
```

### Java Environment

I keep OpenJDK 17 as default for React Native and Android builds, and override when needed:

```bash
./run java
# override:
JAVA_DEFAULT_ENV=java-24-openjdk ./run java
```

## Credits

- Wallpapers in `assets/wallpapers/` are sourced from:
  - [dharmx/walls](https://github.com/dharmx/walls)
  - [Alpha Coders](https://alphacoders.com)
  - Various community sources (Reddit, Pinterest, Wallpaper Flare)
- ICC profiles in `assets/icc/` are sourced from:
  https://github.com/ien646/gamma-icc
- See `assets/icc/LICENSE` and `assets/icc/README.md` for attribution and licensing.
