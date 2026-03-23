# Dotfiles

Minimal dotfiles with profile-based symlinking.

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

`core shell setup` includes:
- `.zshrc`
- `.config/starship.toml`
- `.config/zsh/modules/adb-device.zsh`
- `.local/bin/fix-hdmi-audio`
- `.local/bin/search`
- `.local/bin/image-request`
- `.local/bin/video-to-ascii`
- `.local/bin/cloudflared-init`

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
./run nvm-node
./run zsh
./run dotfiles auto
```

Full bootstrap:

```bash
./arch-bootstrap
```

Optional bootstrap extras:

```bash
ENABLE_DNS_CLOUDFLARE=1 ENABLE_BLUETOOTH=1 ./arch-bootstrap
```

Cloudflared multi-project templates:

```bash
cloudflared-init my-tunnel api.example.com http://localhost:8080
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
