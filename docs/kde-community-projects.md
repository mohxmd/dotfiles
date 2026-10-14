# KDE Plasma Community Projects Roadmap

A curated roadmap of high-impact open-source KDE Plasma 6 tools and extensions designed for power users, developers, and the wider Linux community.

Each project solves a real usability gap between modern tiling workflows (Hyprland / i3) and the KDE Plasma 6 desktop environment.

---

## 1. `krunner-browser-profiles`

> **Category**: KRunner Search Provider<br>
> **Target Audience**: Developers, multi-account users, remote workers<br>
> **Core Tech**: C++ (`KRunner::AbstractRunner`) or Rust (via `org.kde.krunner1` D-Bus)

### Problem Statement
In KDE Plasma 6, KRunner (`Alt+Space`) only launches default browser instances. Users who maintain separate workspaces (Personal, Work, Client, Testing) across Firefox, Helium, Chrome, Brave, Chromium, or Zen must either open the browser first or manually navigate profile selectors.

### Key Features
* Type `p work` or `firefox personal` in KRunner to list matching browser profiles instantly.
* Displays browser branding icon alongside profile name.
* Direct launch with flags:
  * Gecko: `firefox -P "<profile>" --no-remote`
  * Chromium: `helium --profile-directory="<folder>"`
* Zero manual configuration: dynamically parses `profiles.ini` and `Local State`.

### Architecture & KDE APIs
* **KRunner Framework**: Implements KDE's [`KRunner::AbstractRunner`](https://develop.kde.org/docs/plasma/krunner/).
* **Alternative D-Bus Implementation**: Uses `zbus` (Rust) or `python-dbus` implementing `org.kde.krunner1` (`Match`, `Actions`, `Run`).
* **Metadata**: JSON metadata specifying `X-Plasma-Runner-Syntax` and trigger keywords.

### Implementation Phases
1. **Core Parser**: Standalone engine detecting installed browser binaries and profile registries.
2. **KRunner Integration**: Hooking search queries to return `QueryMatch` results.
3. **Packaging**: CMake build system and KDE Store (`store.kde.org`) metadata packaging.

---

## 2. `plasma-matugen`

> **Category**: Dynamic Wallpaper Theming Daemon<br>
> **Target Audience**: r/unixporn, rice enthusiasts, custom desktop users<br>
> **Core Tech**: Rust or C++ (Qt6 / QDBus / KConfig)

### Problem Statement
In tiling environments (Hyprland/Sway), utilities like `matugen` generate dynamic Material You palettes from wallpapers and apply them system-wide. On KDE Plasma 6, dynamic wallpaper color syncing either requires broken legacy scripts or lacks automatic integration with Plasma's accent color and KWin border engine.

### Key Features
* Listens to Plasma wallpaper changes in real time via D-Bus.
* Extracts harmonious Material You / Tokyo Night color palettes using `matugen`.
* Automatically updates:
  * KDE Plasma 6 Accent Color.
  * Active and inactive window border colors (`[WM]` in `kdeglobals`).
  * Konsole terminal profiles and Kitty color schemes.
* Zero desktop freeze: asynchronous background execution.

### Architecture & KDE APIs
* **D-Bus Listener**: Monitors `org.kde.plasmashell` wallpaper change signals.
* **KConfig Integration**: Programmatic modification of `kdeglobals` via `KConfigGroup` or `kwriteconfig6`.
* **KWin DBus Refresh**: Triggers `org.kde.KWin.reconfigure` to apply border colors without logging out.

### Implementation Phases
1. **Event Watcher**: D-Bus daemon listening to wallpaper updates.
2. **Palette Generator**: Subprocess integration with `matugen` CLI.
3. **Plasma Apply Engine**: Updating accent color and KWin window decoration colors.

---

## 3. `kwin-border-manager`

> **Category**: KDE System Settings Module (KCM) / Window Decorator Helper<br>
> **Target Audience**: Tiling window manager users (Polonium / Bismuth / Krohnkite)<br>
> **Core Tech**: QML + Kirigami (UI), C++ / Qt6 (KConfig Backend)

### Problem Statement
Achieving Hyprland-style titlebar-less windows with distinct active/inactive colored borders in KDE Plasma 6 requires manually editing regex masks in `~/.config/breezerc` and raw RGB integers in `~/.config/kdeglobals`. No native visual interface exists in Plasma 6 to configure this.

### Key Features
* Clean System Settings UI under **Appearance** $\rightarrow$ **Window Borders**.
* One-click toggle: **Hide Titlebars for Tiled Windows**.
* Color pickers for:
  * **Active Focused Border** (color & opacity).
  * **Inactive Border** (subtle slate/gray).
* Border thickness slider (1px, 2px, 3px, 4px).
* Presets: Hyprland Minimal, Tokyo Night, Catppuccin, Gruvbox.

### Architecture & KDE APIs
* **KCM Plugin**: Implements [`KQuickConfigModule`](https://develop.kde.org/docs/plasma/kcm/) using Kirigami components.
* **Backend**: Reads and writes `breezerc` (`[Windeco Exception 0]`) and `kdeglobals` (`[WM]`).
* **Live Preview**: QML mock window demonstrating border thickness and colors before applying.

### Implementation Phases
1. **Kirigami QML UI**: Controls for thickness, color pickers, and exception toggles.
2. **KConfig C++ Controller**: Safe reading/writing to `breezerc` and `kdeglobals`.
3. **KCM Registration**: `.desktop` and JSON metadata registering the module into KDE System Settings.

---

## 4. `krunner-dev-projects`

> **Category**: KRunner Developer Productivity Runner<br>
> **Target Audience**: Programmers, DevOps engineers, multi-repo developers<br>
> **Core Tech**: Rust (fast filesystem traversal) or C++ (`QThreadPool`)

### Problem Statement
Developers frequently switch between dozens of Git repositories and coding projects spread across `~/Projects/`, `~/dev/`, and `~/dotfiles/`. Launching them requires opening a terminal first and running editor commands.

### Key Features
* Type `proj <query>` in KRunner (`Alt+Space`) to find matching repositories.
* Multi-action buttons on every result:
  * 🚀 **Neovim** (opens inside Kitty / Konsole)
  * 💻 **VS Code** (`code <path>`)
  * 🌿 **LazyGit** (opens terminal in repo with `lazygit`)
  * 📂 **Dolphin** (reveals files in file manager)
* Automatically detects project type (Rust `Cargo.toml`, Node `package.json`, Python `pyproject.toml`, Go `go.mod`) and shows relevant badge icons.

### Architecture & KDE APIs
* **KRunner Framework**: Uses `KRunner::QueryMatch::setActions()` to provide contextual action buttons.
* **Fast Scanner**: Parallel directory crawler with configurable ignore lists (`.git`, `node_modules`, `target`).

### Implementation Phases
1. **Crawler Engine**: Fast repository scanner with cache support (`~/.cache/krunner-projects.json`).
2. **Action Dispatcher**: Launcher executing selected editor/terminal command lines.
3. **KRunner Plugin**: Presentation and search matching algorithm.

---

## Suggested Execution Order

```text
Phase 1: krunner-browser-profiles ──▶ Solve multi-profile launcher challenge
Phase 2: kwin-border-manager      ──▶ GUI for Hyprland-style KDE borders
Phase 3: plasma-matugen           ──▶ Dynamic wallpaper color synchronization
Phase 4: krunner-dev-projects     ──▶ Developer workspace search & jump
```

