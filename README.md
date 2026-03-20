# Dotfiles

Minimal dotfiles with profile-based symlinking.

## Structure

- `./.config` and `./.zshrc`: linkable config files
- `./assets`: non-link files (wallpapers, fonts, avatars, images, ICC)

## Install

```bash
git clone https://github.com/mhdZhHan/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh --profile auto
```

## Profiles

- `kde`: links Plasma + Code + VSCodium + nvim + shell
- `gnome`: links Code + nvim + shell
- `mac`: links Code + nvim + shell
- `minimal`: links shell only

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
