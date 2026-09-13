# Personal Neovim Configuration

A focused Neovim setup for day-to-day coding, with fast navigation, LSP-backed editing, debugging, file browsing, and a theme workflow that is easy to switch without touching config files.

Requires Neovim 0.12 or newer.

## Showcase

| Start screen | Code editing |
| --- | --- |
| ![Start screen](showcase/start_screen.png) | ![Code editing](showcase/code_editing.png) |

| File tree | Theme picker |
| --- | --- |
| ![File tree](showcase/file_tree.png) | ![Theme picker](showcase/color_theme_selection.png) |

## Highlights

- Plugin management through [lazy.nvim](https://github.com/folke/lazy.nvim), bootstrapped automatically on first launch.
- Fuzzy finding, live grep, references, implementations, and diagnostics through Telescope.
- LSP setup for TypeScript, C/C++, Lua, Rust, Typst, Haskell, GDScript, and Godot shader files.
- Completion with `nvim-cmp`, LuaSnip snippets, path suggestions, buffer words, and LSP sources.
- Formatting through Conform, with project-aware Prettier and Stylua support plus LSP fallback.
- Treesitter highlighting for common web, systems, scripting, markdown, Haskell, and Godot filetypes.
- C/C++/Rust debugging through `nvim-dap`, with LLDB or CodeLLDB auto-detection.
- A custom theme picker with persisted selection and quick next/previous theme commands.
- Practical UI touches: file tree, bufferline, lualine, diagnostics, built-in marker folds, Markdown rendering, and quality-of-life editing plugins.

## Install

Back up your existing config first. If this configuration is part of your dotfiles repository, link it into Neovim's config directory:

```sh
ln -s "$PWD/.config/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

For a standalone Neovim configuration repository, clone it directly instead:

```sh
git clone <repo-url> "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

On first launch, `lazy.nvim` bootstraps itself and installs the configured plugins. Use `:Lazy sync` to synchronize them later.

### External tools

Some features work best when these tools are available on your `PATH`:

- `git`, `make`, and a C compiler for native plugin builds.
- `tree-sitter-cli` 0.26.1+ for installing the current Treesitter parsers.
- `stylua` for Lua formatting and `prettier` or `prettierd` for web-file formatting.
- Language servers such as `typescript-language-server`, `clangd`, `rust-analyzer`, `lua-language-server`, `tinymist`, and `haskell-language-server-wrapper`.
- Go support is optional; install `gopls` later through `:MasonInstall gopls`.
- `lldb-dap` or `codelldb` for debugging C, C++, and Rust.
- `gdshader-lsp` for Godot shader support.

Use `:Mason` to inspect language-server installations and `:checkhealth` when troubleshooting.

## Keybindings

Leader is `<Space>`.

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fc` | Search word under cursor |
| `<C-n>` | Toggle file tree |
| `<leader>e` | Focus file tree |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close current buffer |
| `<leader>ts` | Select theme |
| `<leader>tn` / `<leader>tp` | Next / previous theme |
| `<leader>f` | Format buffer |
| `<leader>gs` | Open Git status |
| `<leader>u` | Toggle UndoTree |
| `<leader>zz` | Toggle Zen mode |
| `gd`, `gD`, `gi`, `gt` | LSP navigation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>d` / `<leader>D` | Line / buffer diagnostics |
| `<leader>dc` | Continue debugger |
| `<leader>db` | Toggle breakpoint |
| `<leader>ds`, `<leader>di`, `<leader>do` | Step over / into / out |
| `<leader>dr`, `<leader>dt` | Restart / terminate debugger |
| `<leader>du` | Toggle DAP UI |

## Structure

```text
init.lua                 Entry point
lua/config/              Options, keymaps, theme state, filetype setup
lua/config/tools/        Small local helper tools
lua/plugins/             Plugin specifications
lua/plugins/lsp/         LSP and Mason setup
showcase/                README screenshots
```
