# Neovim (Nvim) Quick Reference & Shortcut Guide

> **Leader Key**: `Space` (`<leader>`)  
> Modern Lua configuration with Mason, LSP, Treesitter, Telescope, Bufferline, and Supermaven.

---

## 1. General & Navigation

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Ctrl + d` | Half-page down | Scrolls down and centers screen (`zz`) |
| `Ctrl + u` | Half-page up | Scrolls up and centers screen (`zz`) |
| `Alt + j` / `Alt + k` | Move line | Shift current line up / down (`mini.move`) |
| `Alt + h` / `Alt + l` | Move column | Shift line left / right (`mini.move`) |
| `J` *(visual)* | Shift selection down | Move selected lines down |
| `K` *(visual)* | Shift selection up | Move selected lines up |
| `Ctrl + k` / `Ctrl + j` | Quickfix list | Jump to next / previous quickfix item |
| `<leader>k` / `<leader>j` | Location list | Jump to next / previous location item |
| `<leader>X` | Make executable | Runs `chmod +x %` on current file |

---

## 2. Buffers & Tabs

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Tab` | Next buffer | Switch to next open buffer tab |
| `Shift + Tab` | Previous buffer | Switch to previous buffer tab |
| `<leader>x` | Close buffer | Closes current buffer (`bdelete`) |
| `<leader>h` | Move buffer left | Reorder tab to the left |
| `<leader>l` | Move buffer right | Reorder tab to the right |
| `<leader>n` | New tab | Opens a new tabpage |

---

## 3. Window Splits

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>sv` | Split vertically | Open vertical window split (`Ctrl+w v`) |
| `<leader>sh` | Split horizontally | Open horizontal window split (`Ctrl+w s`) |
| `<leader>se` | Equalize splits | Make all split windows equal size (`Ctrl+w =`) |
| `<leader>sx` | Close split | Close the active split window |
| `Ctrl + Up` / `Down` | Resize height | Increase / decrease window height (+/- 2) |
| `Ctrl + Left` / `Right` | Resize width | Make window narrower / wider (+/- 4) |

---

## 4. File Explorer & Search (Telescope / NvimTree)

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Ctrl + n` | Toggle file tree | Open / close NvimTree sidebar |
| `<leader>e` | Focus file tree | Jump focus into NvimTree explorer |
| `<leader>ff` | Find files | Fuzzy search files in workspace (Telescope) |
| `<leader>fw` | Live grep | Search text across all project files |
| `<leader>fc` | Search word under cursor | Find occurrences of current word |
| `<leader>u` | Undo tree | Toggle visual undo history (Undotree) |

---

## 5. LSP (Code Intelligence & Diagnostics)

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `gd` | Go to definition | Jump to symbol definition |
| `gD` | Go to declaration | Jump to symbol declaration |
| `gR` | References | List all references in Telescope |
| `gi` | Implementations | List interface implementations |
| `gt` | Type definition | Jump to type definition |
| `K` | Hover doc | View documentation & type signature |
| `<leader>ca` | Code actions | Quick fixes, import fixes, refactoring |
| `<leader>rn` | Rename symbol | Project-wide symbol rename |
| `<leader>d` | Floating diagnostic | View error / warning details under cursor |
| `<leader>D` | Buffer diagnostics | View all errors & warnings in file |
| `[d` / `]d` | Jump diagnostic | Jump to previous / next error or warning |
| `<leader>rs` | Restart LSP | Restart language servers |

---

## 6. Formatting & Git

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>f` | Format buffer | Formats via Conform (Prettier, Stylua, etc.) |
| `<leader>gs` | Git status | Interactive Git status window (Fugitive) |

---

## 7. AI Code Completion (Supermaven)

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Tab` *(insert)* | Accept suggestion | Accepts inline AI ghost text completion |
| `Ctrl + j` *(insert)* | Accept word | Accepts only the next suggested word |
| `Ctrl + ]` *(insert)* | Dismiss suggestion | Clears the current AI ghost suggestion |

---

## 8. Obsidian Notes Integration

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>oo` | Open in Obsidian | Open current note inside Obsidian app |
| `<leader>os` | Search notes | Fuzzy search text across Obsidian vault |
| `<leader>oq` | Quick switch | Rapidly switch between vault notes |
| `<leader>od` | Today's note | Open or create today's daily note |
| `<leader>ob` | Backlinks | View backlinks for current note |
| `<leader>ot` | Template | Insert an Obsidian note template |
| `<leader>oT` | Table of Contents | View markdown headings TOC |

---

## 9. Themes & Distraction-Free

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>ts` | Theme menu | Interactive popup to pick themes |
| `<leader>tn` | Next theme | Cycle to next theme |
| `<leader>tp` | Previous theme | Cycle to previous theme |
| `<leader>zz` | Zen Mode | Toggle centered, distraction-free editing |

---

## 10. Debugger (DAP)

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>db` | Toggle breakpoint | Set / remove breakpoint on line |
| `<leader>dc` | Continue / start | Start debugging or resume execution |
| `<leader>ds` | Step over | Execute next line without stepping in |
| `<leader>di` | Step into | Step inside function call |
| `<leader>do` | Step out | Step out of current function |
| `<leader>dr` | Restart | Restart debug session |
| `<leader>dt` | Terminate | Stop debugging session |
| `<leader>du` | Toggle debug UI | Show / hide DAP debugger panel |
