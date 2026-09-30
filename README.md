# Dotfiles

Modular, profile-based Linux dotfiles designed for both desktop (KDE Plasma) and laptop (Hyprland), with GNU Stow compatibility and pure Bash symlinking.

## Structure

```text
dotfiles/
├── shared/          # Core CLI & shell (Zsh, Neovim, Starship, Paru, scripts) — used on all machines
├── hypr/            # Hyprland laptop setup (Hyprland, Waybar, Kitty, Mako, Rofi, Cava, Htop, Obsidian)
├── kde/             # KDE Plasma desktop setup (Plasma, KWin, Konsole, Color schemes, Kate themes)
├── code/            # VS Code and VSCodium configuration & desktop entries
└── assets/          # Wallpapers, fonts, and images (non-linked)
```

## Quick Start

### On your Laptop (Arch + Hyprland):

```bash
git clone https://github.com/mohxmd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh --profile hyprland
```

> [!NOTE]
> If you installed Arch via `archinstall` with Hyprland and Kitty, `./setup.sh --profile hyprland` links your configurations instantly without reinstalling any system packages.
> To install any missing companion utilities (Waybar, Mako, Rofi, fonts), run:
> ```bash
> ./run hyprland
> ```

### On your Main PC (Arch + KDE Plasma):

```bash
git clone https://github.com/mohxmd/dotfiles.git ~/dotfiles
cd ~/dotfiles
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
- `.config/rofi/` & `.config/wofi/` (Application launcher & power menu)
- `.config/gtk-3.0/` & `.config/gtk-4.0/` (Consistent dark theme, cursor, and Papirus icons)
- `.config/kolourpaintrc` & `.config/user-dirs.locale`

## Useful options

```bash
./setup.sh --profile gnome --without code
./setup.sh --profile minimal --with nvim
./setup.sh --dry-run --profile kde
```

## Refresh repo from current machine

```bash
./scripts/sync-current-config.sh
```

The `ginit` Zsh helper creates private GitHub repositories by default. Use
`GITHUB_VISIBILITY=public ginit` only when a repository is intentionally public.

## Local secrets with Vaultlet

Vaultlet stores encrypted secrets outside this repository. The vault file and
Vaultlet configuration are intentionally never linked or synced by the
dotfiles setup.

Install it on Arch Linux or Arch WSL:

```bash
./run vaultlet
vaultlet init
vaultlet set github_token
vaultlet set openai_api_key
```

Retrieve a value only when needed:

```bash
vaultget github_token
vaultlet get openai_api_key --copy
ghv repo view
```

Secrets are not exported automatically. `ginit` uses `github_token` only for
the `gh` command, and `image-request` reads `openai_api_key` only when it runs.
Keep each WSL distribution's vault inside its Linux filesystem, not under
`/mnt/c`.

## Arch Run Tasks

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

Full bare-metal Linux bootstrap:

```bash
./arch-bootstrap
```

`arch-bootstrap` refuses to run inside WSL because it installs desktop-oriented
services and a local Docker daemon.

WSL bootstrap:

```bash
./wsl-bootstrap
```

Run `wsl-bootstrap` inside Arch WSL as a normal user with working `sudo`. If
the Arch image starts as `root`, create a regular user, grant it `sudo`, and
make it the WSL default user first. It installs WSL-relevant
packages, creates `/etc/wsl.conf` only when that file does not already exist,
enables systemd for the current user, installs Zsh dependencies, and applies
the `wsl` profile. Restart WSL from PowerShell with `wsl --shutdown` afterward.

The files in `wsl/` are templates for distribution-level `/etc/wsl.conf` and
host-level `%UserProfile%\.wslconfig`; they are not linked into `$HOME`.

On Windows, prefer Docker Desktop's WSL integration. The desktop-oriented
`firewall`, `bluetooth`, `dns-cloudflare`, `docker`, and `plasma` tasks are
intentionally not part of the WSL bootstrap.

VPS (Netcup / Hetzner / Cloud Arch Linux) bootstrap:

```bash
./vps-bootstrap
```

Runs a lean, production-oriented provisioning for headless servers. Installs Docker,
Docker Compose, Caddy, Nftables, Neovim, Zsh, and Starship, enables Docker and Caddy
services, and applies the `server` dotfiles profile without desktop bloat or AUR helpers.

Optional bootstrap extras:

```bash
ENABLE_DNS_CLOUDFLARE=1 ENABLE_BLUETOOTH=1 ./arch-bootstrap
```

Cloudflared multi-project templates:

```bash
cfd-init my-tunnel api.example.com http://localhost:8080
CLOUDFLARED_CONFIG=./cloudflared/configs/my-tunnel.yml ./run cloudflared
```

Java notes:

```bash
./run java
# default env is java-17-openjdk for React Native/Android compatibility
# override when needed:
JAVA_DEFAULT_ENV=java-24-openjdk ./run java
```

## Credits

- ICC profiles in `assets/icc/` are sourced from:
  https://github.com/ien646/gamma-icc
- See `assets/icc/LICENSE` and `assets/icc/README.md` for attribution and licensing.
