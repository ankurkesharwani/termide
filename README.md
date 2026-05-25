# termide

A hand-built Neovim configuration for C, Rust, Python, Shell, Java (Spring Boot), Go, and Frontend development.
Built incrementally from scratch — no framework like NVChad or LazyVim.

---

## Table of Contents

- [Plugin Manager](#plugin-manager)
- [Structure](#structure)
- [Plugins](#plugins)
- [Keybindings](#keybindings)
- [LSP Servers](#lsp-servers)
- [Debugging](#debugging)
- [Java & Lombok](#java--lombok)
- [Adding Go Later](#adding-go-later)
- [Tips & Tricks](#tips--tricks)

---

## Plugin Manager

Uses **[lazy.nvim](https://github.com/folke/lazy.nvim)** — bootstrapped automatically on first launch.
It clones itself into `~/.local/share/nvim/lazy/lazy.nvim` if not present, then installs all plugins.

To manage plugins:
- `:Lazy` — open the plugin manager UI
- `:Lazy update` — update all plugins
- `:Lazy clean` — remove unused plugins

Plugin versions are locked in `lazy-lock.json` — commit this file to reproduce the exact setup on another machine.

---

## Structure

Everything lives in a single file: `~/.config/nvim/init.lua`.

Options are set at the top before `lazy.setup()` so they survive any plugin errors.
The plugin list is passed directly to `lazy.setup({...})`.
Keymaps are at the bottom.

---

## Plugins

### File Explorer — nvim-tree
[nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

A file explorer sidebar. Opens automatically on startup and moves focus to the editor.
Uses `nvim-web-devicons` for file icons.

Configuration:
- Width: 30 columns
- Left side
- Shows dotfiles

### Buffer Tabs — bufferline.nvim
[akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)

Renders open buffers as tabs at the top of the screen.
Offset-aware: the tab bar starts after the nvim-tree sidebar, not behind it.
Filters out `[No Name]` buffers so empty scratch buffers don't appear as tabs.

### Syntax Highlighting — nvim-treesitter
[nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Tree-sitter based syntax highlighting — far more accurate than regex-based highlighting.
Parsers are auto-installed for: `c`, `rust`, `python`, `bash`, `make`, `java`, `go`, `html`, `css`,
`javascript`, `typescript`, `tsx`, `json`, `yaml`, `toml`, `xml`, `lua`, `vim`, `vimdoc`.

Also enables smarter indentation via `indent = { enable = true }`.

To manually install/update parsers: `:TSUpdate`
To check parser health: `:checkhealth nvim-treesitter`

### Colorschemes
Six themes are installed, all with full treesitter highlight group support:

| Theme | Variants |
|---|---|
| [tokyonight](https://github.com/folke/tokyonight.nvim) | `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon`, `tokyonight-day` |
| [catppuccin](https://github.com/catppuccin/nvim) | `catppuccin-mocha`, `catppuccin-macchiato`, `catppuccin-frappe`, `catppuccin-latte` |
| [kanagawa](https://github.com/rebelot/kanagawa.nvim) | `kanagawa-wave`, `kanagawa-dragon`, `kanagawa-lotus` |
| [rose-pine](https://github.com/rose-pine/neovim) | `rose-pine`, `rose-pine-moon`, `rose-pine-dawn` |
| [gruvbox](https://github.com/ellisonleao/gruvbox.nvim) | `gruvbox` |
| [onedark](https://github.com/navarasu/onedark.nvim) | `onedark` |

Default: `catppuccin`. To change permanently, update the `pcall(vim.cmd, "colorscheme ...")` line at the bottom of `init.lua`.

### Theme Switcher — telescope.nvim
[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Telescope is a fuzzy-finder framework used for multiple purposes:
- Theme switching with live preview (`<leader>th`)
- File search (`<leader>ff`)
- Content/grep search (`<leader>fg`)
- LSP references and implementations (`gr`, `gI`)

Requires **ripgrep** for content search: `sudo dnf install ripgrep`

### LSP + Completion
Three plugins work together:

**[mason.nvim](https://github.com/williamboman/mason.nvim)** — installs and manages LSP servers, DAP adapters, linters, formatters.
UI: `:Mason`

**[mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)** — bridges mason and nvim-lspconfig.
Ensures servers listed in `ensure_installed` are downloaded automatically.
`jdtls` is excluded from auto-enable (`automatic_enable.exclude`) because it needs special
startup handled by `nvim-jdtls`.

**[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** — provides default configurations
(cmd, filetypes, root detection) for each LSP server. In Neovim 0.11+, these are registered via
`vim.lsp.config` automatically when the plugin is in the runtimepath. Servers are started with
`vim.lsp.enable(server_name)`.

**[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** — completion engine with sources:
- `cmp-nvim-lsp` — LSP completions
- `cmp-buffer` — words from open buffers
- `cmp-path` — filesystem paths
- `cmp_luasnip` + `LuaSnip` — snippet expansion

Capabilities from `cmp_nvim_lsp` are passed to all LSP servers via `vim.lsp.config("*", { capabilities = ... })`.
LSP keymaps are set via the `LspAttach` autocommand — this fires every time an LSP client connects to a buffer.

### Java LSP — nvim-jdtls
[mfussenegger/nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

Standard `vim.lsp.enable("jdtls")` cannot be used for Java because jdtls requires:
- A **per-project isolated workspace** at `~/.local/share/nvim/jdtls-workspaces/<project-name>`
- A **Lombok javaagent** (`-javaagent:/path/to/lombok.jar`) passed at JVM startup
- The **java-debug-adapter** bundle loaded via `init_options.bundles`

`nvim-jdtls` handles all of this via `require("jdtls").start_or_attach(config)`.

The plugin loads on `ft = "java"`. The config function calls `start_jdtls()` immediately
(for the first Java file) and also registers a `FileType` autocmd (for subsequent Java files
in the same session).

**Lombok** is downloaded to `~/.local/share/nvim/lombok.jar`:
```bash
curl -L https://projectlombok.org/downloads/lombok.jar -o ~/.local/share/nvim/lombok.jar
```

**JDK discovery.** The config does not hardcode a JDK path. On `start_jdtls()` it scans
common install locations on macOS and Linux:
- `/Library/Java/JavaVirtualMachines/*/Contents/Home`
- `/usr/lib/jvm/*`
- `~/.sdkman/candidates/java/*`
- `~/.local/share/mise/installs/java/*`
- `~/.asdf/installs/java/*`

For each JDK it reads `release` to get the actual major version and vendor, then builds
one `JavaSE-<N>` entry per major version. jdtls picks the right one per project from
`pom.xml`/`build.gradle`.

**Choosing the default runtime** (used when a project doesn't declare a target):
1. If `$JAVA_HOME` is set and points to a real JDK, that one wins.
2. Otherwise, when multiple vendors share a major version, vendor preference
   (`temurin > corretto > zulu > openjdk > oracle`) breaks the tie. Edit the
   `vendor_rank` table in `init.lua` to change this.
3. If `$JAVA_HOME` is unset, the newest discovered version is marked default.

The recommended way to set `JAVA_HOME` per project is **direnv** (`brew install direnv` /
`dnf install direnv`). Add a gitignored `.envrc` to the project root:
```sh
export JAVA_HOME=/path/to/your/jdk
```
Run `direnv allow` once. The `.envrc` is per-machine so paths can differ across macOS/Fedora.

**Commands:**
- `:JdtlsWhichJava` — print `JAVA_HOME`, discovered runtimes (with the default starred),
  and currently attached jdtls clients. Use this first when diagnosing.
- `:JdtlsClearWorkspace` — stop jdtls, delete this project's workspace at
  `~/.local/share/nvim/jdtls-workspaces/<project-name>`, and restart. Use when jdtls
  behaves strangely after changing JDKs or build files.

**`.project`, `.classpath`, `.factorypath`, `.settings/` at the project root.** These
are generated by jdtls's Maven importer (m2e) and there is **no setting that disables
them for Maven/Gradle projects** —
[eclipse-jdtls#2095](https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/2095).
The accepted workaround is to gitignore them globally:
```sh
mkdir -p ~/.config/git
cat >> ~/.config/git/ignore <<'EOF'
.project
.classpath
.factorypath
.settings/
EOF
git config --global core.excludesfile ~/.config/git/ignore
```
After this they still get written, but git won't show them and you won't accidentally
commit them.

### Debugging — nvim-dap
[mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) +
[rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

DAP (Debug Adapter Protocol) client. The UI opens automatically when a debug session starts
and closes when it ends.

**[mason-nvim-dap](https://github.com/jay-babu/mason-nvim-dap.nvim)** installs debug adapters:
- `codelldb` — for C and Rust
- `python` (debugpy) — for Python
- `java-debug-adapter` — for Java (loaded as a bundle into jdtls)

**VSCode launch.json support:** `F5` auto-loads `.vscode/launch.json` from the project root
before starting a session. This is the same format as VSCode, so the file can be shared.

Example Spring Boot launch config:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Spring Boot - Dev",
      "request": "launch",
      "mainClass": "com.yourpackage.Application",
      "args": "--spring.profiles.active=dev",
      "env": {
        "DB_URL": "jdbc:postgresql://localhost:5432/mydb",
        "DB_PASSWORD": "secret"
      },
      "vmArgs": "-Xmx512m"
    }
  ]
}
```

### Terminal — toggleterm.nvim
[akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

A persistent terminal that opens as a horizontal split at the bottom.
The session persists between toggles — processes keep running.

### Buffer Close — bufdelete.nvim
[famiu/bufdelete.nvim](https://github.com/famiu/bufdelete.nvim)

Closes buffers correctly without leaving `[No Name]` ghost buffers behind.
Switches to the next buffer before deleting the current one.
When closing the last buffer, closes the window entirely (leaving only nvim-tree).

### Keybinding Helper — which-key.nvim
[folke/which-key.nvim](https://github.com/folke/which-key.nvim)

Press `<leader>` (Space) and pause — a popup shows all available keybindings with descriptions.
Works for any key sequence. Helps discover bindings without consulting this file.

---

## Keybindings

### General

| Key | Mode | Action |
|---|---|---|
| `Space` | — | Leader key |
| `Ctrl+b` | Normal | Toggle file explorer |
| `Tab` | Normal | Next buffer |
| `Shift+Tab` | Normal | Previous buffer |
| `Space x` | Normal | Close current buffer |
| `Ctrl+h/j/k/l` | Normal | Navigate between panes |
| `Ctrl+t` | Normal/Terminal | Toggle terminal |
| `Esc` | Terminal | Exit terminal insert mode |

### File Explorer (nvim-tree)

| Key | Action |
|---|---|
| `Enter` | Open file |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+x` | Open in horizontal split |
| `a` | Create file (end with `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |

### Search (Telescope)

| Key | Action |
|---|---|
| `Space ff` | Fuzzy find files by name |
| `Space fg` | Live grep (search file contents) |
| `Space th` | Theme switcher with live preview |

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gI` | Go to implementation (Telescope) |
| `gr` | Go to references (Telescope) |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space ca` | Code actions |
| `Space e` | Show diagnostic float |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |

### Java Specific

| Key | Action |
|---|---|
| `Space oi` | Organize imports |
| `Space tc` | Run test class |
| `Space tm` | Run nearest test method |

### Debugging

| Key | Action |
|---|---|
| `F5` | Start / continue (loads launch.json) |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `Space b` | Toggle breakpoint |
| `Space du` | Toggle debug UI |
| `Space de` | Evaluate expression under cursor |
| `Space de` (visual) | Evaluate selected expression |

### Completion (insert mode)

| Key | Action |
|---|---|
| `Tab` | Next completion item |
| `Shift+Tab` | Previous completion item |
| `Enter` | Confirm completion |
| `Ctrl+Space` | Force open completion |
| `Ctrl+e` | Abort completion |

---

## LSP Servers

| Server | Language | Installed via |
|---|---|---|
| `clangd` | C / C++ | Mason |
| `rust_analyzer` | Rust | Mason |
| `pyright` | Python | Mason |
| `bashls` | Bash / Shell | Mason |
| `ts_ls` | TypeScript / JavaScript | Mason |
| `html` | HTML | Mason |
| `cssls` | CSS | Mason |
| `lua_ls` | Lua | Mason |
| `jdtls` | Java | Mason + nvim-jdtls |

To add a new server:
1. Add the server name to `ensure_installed` in mason-lspconfig
2. Add it to the `vim.lsp.enable()` loop
3. Restart Neovim

---

## Debugging

### Debug Adapters

| Adapter | Language | Installed via |
|---|---|---|
| `codelldb` | C, Rust | mason-nvim-dap |
| `python` (debugpy) | Python | mason-nvim-dap |
| `java-debug-adapter` | Java | mason-nvim-dap |

### Per-project Configuration
Create `.vscode/launch.json` in your project root. `F5` loads it automatically.
Multiple configurations in one file are supported — you'll be prompted to choose.

---

## Adding Go Later

When you install Go:
1. Add `"gopls"` and `"gosum"`, `"gomod"` to mason-lspconfig `ensure_installed`
2. Add `"gopls"` to the `vim.lsp.enable()` loop
3. Add `"delve"` to mason-nvim-dap `ensure_installed` for debugging

---

## Tips & Tricks

- **Stuck in the wrong pane?** Use `Ctrl+h/j/k/l` to move around
- **Which-key popup:** Press `Space` and wait ~1 second to see available bindings
- **Theme not persisting?** Change `pcall(vim.cmd, "colorscheme ...")` in `init.lua`
- **jdtls errors after changing config?** Run `:JdtlsClearWorkspace` (or `rm -rf ~/.local/share/nvim/jdtls-workspaces/` for all projects) and restart
- **Wrong Java version in jdtls?** Run `:JdtlsWhichJava` to see what was discovered and which runtime is default
- **Missing parser?** Run `:TSInstall <language>` or `:TSUpdate`
- **LSP not starting?** Run `:checkhealth lsp` and `:Mason` to verify server is installed
- **See all LSP clients on current buffer:** `:lua vim.print(vim.lsp.get_clients())`
- **Reload config without restart:** `:source %` (only works for option/keymap changes, not plugins)
