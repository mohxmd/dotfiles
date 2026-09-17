# Dotfiles

Personal Linux dotfiles with profile-based symlinking and a lightweight WSL profile.

## Structure

- `./.config`, `./.local`, and `./.zshrc`: linkable config files
- `./assets`: non-link files (wallpapers, fonts, avatars, images, ICC)

## Install

```bash
git clone https://github.com/mohxmd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh --profile auto
```

## Profiles

- `kde`: links Plasma + Code + VSCodium + nvim + core shell setup
- `gnome`: links Code + nvim + core shell setup
- `mac`: links Code + nvim + core shell setup
- `minimal`: links core shell setup only
- `wsl`: links core shell setup and Neovim, without desktop/KDE configuration
- `server`: links core shell setup (zsh + starship) and Neovim, without GUI/desktop tools

`core shell setup` includes:
- `.zshrc`
- `.config/starship.toml`
- `.config/zsh/modules/adb-device.zsh`
- `.local/bin/fix-hdmi-audio`
- `.local/bin/search`
- `.local/bin/image-request`
- `.local/bin/video-to-ascii`
- `.local/bin/cfd-init`
- `.config/pgcli/config` (pgcli config)
- `.config/paru/paru.conf` (paru configuration)

`plasma` (KDE specific setup) includes:
- `.config/plasma-org.kde.plasma.desktop-appletsrc` (Plasma config)
- `.config/kwinrulesrc` (KWin window rules)
- `.local/share/plasma/plasmoids` (Plasma widgets)
- `.local/share/color-schemes` (Global themes including BuraqDark & BuraqLight)
- `.local/share/konsole` (Konsole profiles)
- `.local/share/org.kde.syntax-highlighting/themes` (Kate themes)

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
