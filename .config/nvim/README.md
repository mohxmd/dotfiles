# Neovim (Custom Setup)

Modern, modular, and fast Neovim configuration built with `lazy.nvim`.

## Quick Start

1. Open Neovim: `nvim`
2. Sync plugins: `:Lazy sync`
3. Install LSPs: `:Mason` (Automatic for core languages)
4. Authenticate AI: `:SupermavenUseFree`

## Core Shortcuts

### File Navigation
- `<leader>pv`: Open Netrw (File Explorer)
- `<leader>pf`: Find files (Telescope)
- `<C-p>`: Git files (Telescope)
- `<leader>ps`: Live Grep (Telescope)

### LSP & Editing
- `gd`: Go to definition
- `K`: Hover documentation
- `<leader>vca`: Code actions
- `<leader>f`: Format current file (Conform)
- `<leader>s`: Search and replace word under cursor
- `J` / `K` (Visual Mode): Move selected lines up/down

### Git & Utilities
- `<leader>gs`: Git Status (Fugitive)
- `<leader>u`: Toggle UndoTree
- `<leader>zz`: Toggle Zen Mode
- `<C-f>`: Tmux Sessionizer

## File Structure

- `lua/config/`: Neovim options, core keymaps, and autocmds.
- `lua/plugins/`: Individual plugin specifications (LSP, CMP, Treesitter, etc.).
- `init.lua`: Main entry point.
