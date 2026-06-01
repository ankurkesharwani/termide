# Neovim Usage Guide

This guide covers how to use Neovim day-to-day with this configuration. It
assumes you are new to Neovim and covers everything from the basics to
advanced workflows.

> Open this guide anytime from inside Neovim with `:Guide`.

--------------------------------------------------------------------------------

## Table of Contents

- [The Golden Rule: Modes](#the-golden-rule-modes)
- [Opening Neovim](#opening-neovim)
- [The Layout](#the-layout)
- [Working with Files](#working-with-files)
- [Working with Buffers (Tabs)](#working-with-buffers-tabs)
- [Working with Splits](#working-with-splits)
- [Editing Basics](#editing-basics)
- [Saving and Quitting](#saving-and-quitting)
- [Navigation Inside a File](#navigation-inside-a-file)
- [Code Folding](#code-folding)
- [Search and Replace](#search-and-replace)
- [LSP Features](#lsp-features)
- [Debugging](#debugging)
- [Terminal](#terminal)
- [Git](#git)
- [Themes](#themes)
- [Common Workflows](#common-workflows)

--------------------------------------------------------------------------------

## The Golden Rule: Modes

Neovim is modal — the keyboard behaves differently depending on which mode
you are in. This is the most important concept to understand.

| Mode            | How to enter        | What it does                                     |
|-----------------|---------------------|--------------------------------------------------|
| **Normal**      | `Esc` from any mode | Navigate, run commands. This is the default mode |
| **Insert**      | `i` in Normal       | Type text                                        |
| **Visual**      | `v` in Normal       | Select text                                      |
| **Visual Line** | `V` in Normal       | Select whole lines                               |
| **Command**     | `:` in Normal       | Run Ex commands (`:w`, `:q`, etc.)               |

**Always return to Normal mode with `Esc` before doing anything else.** If
something feels broken, press `Esc` a couple of times and you will be back in
Normal mode.

--------------------------------------------------------------------------------

## Opening Neovim

```bash
nvim                        # open with file explorer
nvim myfile.rs              # open a specific file
nvim .                      # open current directory
```

On startup:

- The **file explorer** opens on the left automatically
- Focus starts in the **editor area** on the right
- Use `Ctrl+h` to move focus to the file explorer, `Ctrl+l` to move back

--------------------------------------------------------------------------------

## The Layout

```
┌─────────────────┬──────────────────────────────────┐
│                 │  buffer1.rs  │  buffer2.java  │  │  ← Buffer tabs
│                 ├──────────────────────────────────┤
│  File Explorer  │                                  │
│  (nvim-tree)    │         Editor area              │
│                 │                                  │
│                 │                                  │
├─────────────────┴──────────────────────────────────┤
│              Terminal (toggleterm)                 │  ← Ctrl+t to toggle
└────────────────────────────────────────────────────┘
```

--------------------------------------------------------------------------------

## Working with Files

### Opening files

In the **file explorer** (press `Ctrl+b` to toggle, `Ctrl+h` to focus it):

| Key      | Action                              |
|----------|-------------------------------------|
| `Enter`  | Open file in current editor window  |
| `l`      | Expand folder / open file           |
| `h`      | Collapse current folder (to parent) |
| `Ctrl+v` | Open file in a new vertical split   |
| `Ctrl+x` | Open file in a new horizontal split |

### Finding files by name

Press **`Space ff`** from anywhere — a fuzzy finder opens. Start typing part
of the filename and the list filters in real time. Press `Enter` to open the
selected file, `Esc` to cancel.

### Searching inside files

Press **`Space fg`** — a live grep window opens. Type a search term and it
searches across all files in the project instantly. Navigate results with
arrow keys or `Ctrl+j/k`, press `Enter` to jump to the match.

### Jumping to a method in the current file

Press **`Space fm`** (or run `:FindMethods`) — opens a picker listing every
method / function / constructor in the current buffer. Type to fuzzy-filter,
press `Enter` to jump. Requires an LSP server attached to the buffer.

Requires `ripgrep`: `sudo dnf install ripgrep`

### Creating, renaming, deleting files

Focus the file explorer (`Ctrl+h`) and navigate to the folder:

| Key                         | Action                                         |
|-----------------------------|------------------------------------------------|
| `a`                         | Create a new file (type name and press Enter)  |
| `a` then name ending in `/` | Create a new folder                            |
| `r`                         | Rename the file/folder under cursor            |
| `d`                         | Delete (confirms with `y`/`n`)                 |
| `x`                         | Cut (for moving)                               |
| `p`                         | Paste (after cut)                              |
| `c`                         | Copy                                           |

--------------------------------------------------------------------------------

## Working with Buffers (Tabs)

A **buffer** is an open file. The tabs at the top show all open buffers.

| Key         | Action                   |
|-------------|--------------------------|
| `Tab`       | Go to next buffer        |
| `Shift+Tab` | Go to previous buffer    |
| `Space x`   | Close the current buffer |

When you close the last buffer, the editor pane closes and you are left with
the file explorer.

--------------------------------------------------------------------------------

## Working with Splits

You can have multiple files open side by side.

| Command / Key             | Action                                  |
|---------------------------|-----------------------------------------|
| `:vsp filename`           | Open file in vertical split (side)      |
| `:sp filename`            | Open file in horizontal split (top/bot) |
| `Ctrl+v` in file explorer | Open file in vertical split             |
| `Ctrl+x` in file explorer | Open file in horizontal split           |
| `Ctrl+h`                  | Move focus left                         |
| `Ctrl+l`                  | Move focus right                        |
| `Ctrl+j`                  | Move focus down                         |
| `Ctrl+k`                  | Move focus up                           |
| `Space w`                 | Enter resize submode — then tap `h`/`l` to adjust width, `j`/`k` for height, `=` to equalize, any other key exits |
| `:q`                      | Close current split                     |
| `:only`                   | Close all splits except the current one |

--------------------------------------------------------------------------------

## Editing Basics

### Entering and exiting insert mode

| Key   | Action                     |
|-------|----------------------------|
| `i`   | Insert before cursor       |
| `a`   | Insert after cursor        |
| `o`   | New line below and insert  |
| `O`   | New line above and insert  |
| `Esc` | Return to Normal mode      |

### Copying, cutting, pasting

Neovim uses "yank" for copy and "delete" for cut.

| Key   | Action                    |
|-------|---------------------------|
| `yy`  | Copy (yank) current line  |
| `y3j` | Yank 3 lines down         |
| `dd`  | Cut (delete) current line |
| `d3j` | Cut 3 lines down          |
| `p`   | Paste after cursor        |
| `P`   | Paste before cursor       |

In **Visual mode** (`v` to select, then):

| Key | Action                                          |
|-----|-------------------------------------------------|
| `y` | Yank selection                                  |
| `d` | Delete selection                                |
| `c` | Change selection (delete and enter insert mode) |

### Undo and redo

| Key      | Action |
|----------|--------|
| `u`      | Undo   |
| `Ctrl+r` | Redo   |

--------------------------------------------------------------------------------

## Saving and Quitting

| Command | Action                                       |
|---------|----------------------------------------------|
| `:w`    | Save current file                            |
| `:wa`   | Save all open files                          |
| `:q`    | Quit (close current window/split)            |
| `:qa`   | Quit all (close Neovim)                      |
| `:wq`   | Save and quit                                |
| `:qa!`  | Force quit all, discard unsaved changes      |

You can also map `:w` to a key if you prefer — ask Claude to add it.

--------------------------------------------------------------------------------

## Navigation Inside a File

### Basic movement (Normal mode)

| Key             | Action                                     |
|-----------------|--------------------------------------------|
| `h` `j` `k` `l` | Left, down, up, right (or use arrow keys)  |
| `w`             | Jump forward one word                      |
| `b`             | Jump backward one word                     |
| `0`             | Start of line                              |
| `$`             | End of line                                |
| `gg`            | Top of file                                |
| `G`             | Bottom of file                             |
| `Ctrl+d`        | Scroll half page down                      |
| `Ctrl+u`        | Scroll half page up                        |
| `{` / `}`       | Jump between empty lines (paragraphs)      |

### Go Back / Go Forward (jumplist)

Just like **Go Back / Go Forward** in VSCode, Neovim remembers a history of
your cursor jumps so you can retrace your steps — even across different files.

| Key      | Action       |
|----------|--------------|
| `Ctrl+o` | Jump back    |
| `Ctrl+p` | Jump forward |

Only **big** jumps are recorded — go-to-definition, searches (`/`), `gg`, `G`,
`{` / `}`, `:42`, and so on. Ordinary `h` `j` `k` `l` line moves are *not*
tracked, so the history stays useful.

Example: press `gd` to jump to a function's definition, then `Ctrl+o` to return
to where you were, and `Ctrl+p` to go forward to the definition again.

> `Ctrl+o` is Vim's built-in "jump back". `Ctrl+p` is bound in this config to
> Vim's built-in forward jump (`Ctrl+i`).

### Jumping to a line

Type `:42` and press Enter to jump to line 42. Or type `42G` in Normal mode.

### Line numbers

The config shows **relative line numbers** — the current line shows its
absolute number, all other lines show their distance from the cursor. This
makes commands like `5dd` (delete 5 lines) very easy — just look at the
number next to the line.

--------------------------------------------------------------------------------

## Code Folding

Folds are powered by treesitter, so they wrap around real code structures
(functions, classes, blocks) rather than indentation.

Files **open fully unfolded** by default. Folding is something you reach for
when you want to collapse noise — not something that hides code on every
file open.

### Folding by depth

`Space z<N>` (where N is `0`–`9`) sets how deep the buffer is unfolded — like
a zoom dial. Treesitter assigns each structure a depth: a class is depth 1,
methods inside it are depth 2, blocks inside methods are depth 3, and so on.

| Key                     | Result                                                |
|-------------------------|-------------------------------------------------------|
| `Space z0`              | Fold **everything** (only first lines visible)        |
| `Space z1`              | Show top-level only — in class-based code (Java,      |
|                         | Kotlin, Python) this folds every method body          |
| `Space z2`              | Show two levels — methods visible, inner blocks fold  |
| `Space z3` … `Space z9` | Progressively reveal more nesting; `z9` ~= "open all" |

In files with top-level functions (Go, Rust, C), those functions *are* depth
1 — so `Space z1` folds them entirely. Use `Space z2` instead if you want to
keep function signatures + bodies visible.

### Manual folding

| Key  | Action                                                          |
|------|-----------------------------------------------------------------|
| `za` | Toggle the fold under the cursor (close if open, open if close) |
| `zc` | Close fold under cursor                                         |
| `zo` | Open fold under cursor                                          |
| `zM` | Close **all** folds in the buffer                               |
| `zR` | Open **all** folds in the buffer                                |
| `zm` | Close one more level (fold deeper)                              |
| `zr` | Open one more level (unfold)                                    |

### Navigating folds

| Key  | Action                     |
|------|----------------------------|
| `zj` | Jump to the next fold      |
| `zk` | Jump to the previous fold  |

### Tip

If `zc` ever reports `E490: No fold found`, the cursor isn't sitting inside
any foldable structure for that filetype. Try moving inside a function or
class body, or run `:set foldexpr?` to confirm folding is using treesitter
(`v:lua.vim.treesitter.foldexpr()`).

--------------------------------------------------------------------------------

## Search and Replace

### Searching in the current file

| Key                       | Action                    |
|---------------------------|---------------------------|
| `/searchterm` then Enter  | Search forward            |
| `?searchterm` then Enter  | Search backward           |
| `n`                       | Next match                |
| `N`                       | Previous match            |
| `:noh`                    | Clear search highlighting |

### Replace in current file

```
:%s/old/new/g        replace all occurrences in file
:%s/old/new/gc       replace with confirmation for each
:10,20s/old/new/g    replace only in lines 10-20
```

### Search across project files

Use **`Space fg`** (Telescope live grep) — find any string across all
project files.

--------------------------------------------------------------------------------

## LSP Features

These features require the LSP server to be running (happens automatically
when you open a supported file). You can see the LSP status in the bottom
status line.

### Navigation

| Key      | Action                                                        |
|----------|---------------------------------------------------------------|
| `gd`     | Go to definition — jumps to where a function/class is defined |
| `gI`     | Go to implementation — for interfaces, jumps to concrete impl |
| `gr`     | Go to references — shows all places this symbol is used       |
| `Ctrl+o` | Jump back (after a `gd`/`gI` jump)                            |
| `Ctrl+i` | Jump forward                                                  |

### Information

| Key       | Action                                                |
|-----------|-------------------------------------------------------|
| `K`       | Show documentation/signature for symbol under cursor  |
| `Space e` | Show full diagnostic (error/warning) message in float |
| `]d`      | Jump to next diagnostic                               |
| `[d`      | Jump to previous diagnostic                           |

### Editing

| Key        | Action                                                  |
|------------|---------------------------------------------------------|
| `Space rn` | Rename symbol — renames across all files in the project |
| `Space ca` | Code actions — fix imports, generate boilerplate, etc.  |

### Completion

Completion triggers automatically as you type. When the completion menu
appears:

| Key          | Action                                          |
|--------------|-------------------------------------------------|
| `Tab`        | Select next item                                |
| `Shift+Tab`  | Select previous item                            |
| `Enter`      | Confirm and insert the selected completion      |
| `Ctrl+Space` | Manually trigger completion                     |
| `Ctrl+e`     | Dismiss completion menu                         |

### Java specific

| Key        | Action                              |
|------------|-------------------------------------|
| `Space oi` | Organize imports (removes unused)   |
| `Space tc` | Run the test class                  |
| `Space tm` | Run the nearest test method         |

#### Java commands

- `:JdtlsWhichJava` — Show `JAVA_HOME`, all discovered JDK runtimes (with
  the default starred), and the currently attached jdtls client. Run this
  first when something looks off.
- `:JdtlsClearWorkspace` — Delete this project's jdtls workspace at
  `~/.local/share/nvim/jdtls-workspaces/<project>` and restart jdtls. Use
  it after switching JDKs or when jdtls behaves strangely.

The default JDK is picked from `$JAVA_HOME` if set, else by vendor
preference (`temurin > corretto > zulu > openjdk > oracle`). The
recommended way to pin a JDK per project is **direnv** with a gitignored
`.envrc` containing `export JAVA_HOME=/path/to/jdk`. See the README for
details.

--------------------------------------------------------------------------------

## Debugging

### Starting a debug session

1. Set a breakpoint: move cursor to the line and press **`Space b`**
   - A red dot appears in the gutter
   - Press again to remove it
2. Press **`F5`** to start debugging
   - If a `.vscode/launch.json` exists, it loads the config automatically
   - For Java, you will be asked to choose the main class if not specified
     in launch.json
3. The debug UI opens automatically showing: variables, call stack,
   breakpoints, watches

### Stepping through code

| Key   | Action                                               |
|-------|------------------------------------------------------|
| `F5`  | Continue (run to next breakpoint)                    |
| `F10` | Step over (execute line, don't enter function calls) |
| `F11` | Step into (enter the function call on this line)     |
| `F12` | Step out (run until the current function returns)    |

### Inspecting values

| Key                 | Action                                       |
|---------------------|----------------------------------------------|
| `Space de`          | Evaluate expression under cursor in a float  |
| `Space de` (Visual) | Evaluate highlighted expression              |
| `Space du`          | Toggle the debug UI panels manually          |

You can also type expressions directly in the **REPL** panel in the debug
UI.

### Project-specific debug config (.vscode/launch.json)

Create this file in your project root to define how to launch your app for
debugging. It uses the exact same format as VSCode — you can copy configs
between them.

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
        "DB_URL": "jdbc:postgresql://localhost:5432/mydb"
      }
    }
  ]
}
```

For **Rust / C** with codelldb:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "codelldb",
      "name": "Debug binary",
      "request": "launch",
      "program": "${workspaceFolder}/target/debug/my-binary",
      "args": ["--flag", "value"],
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

For **Python**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "python",
      "name": "Run script",
      "request": "launch",
      "program": "${workspaceFolder}/main.py",
      "args": ["--env", "dev"],
      "env": { "API_KEY": "abc123" }
    }
  ]
}
```

--------------------------------------------------------------------------------

## Terminal

| Key      | Action                                          |
|----------|-------------------------------------------------|
| `Ctrl+t` | Toggle terminal open/closed                     |
| `i`      | Enter insert mode (start typing commands)       |
| `Esc`    | Exit insert mode (back to Normal in terminal)   |
| `Ctrl+k` | Move focus from terminal back to editor         |

The terminal session persists — if you run a server in it, it keeps running
when you hide it. Toggle it back with `Ctrl+t` to see the output.

> **Git operations:** For git commands that open an editor (interactive rebase,
> commit, reword), use `:Git` from the editor instead of running `git` from the
> terminal. See the [Git](#git) section below.

--------------------------------------------------------------------------------

## Git

Git integration is provided by **vim-fugitive** and **gitsigns**.

### vim-fugitive — running git commands

Use `:Git <command>` instead of running git from the terminal whenever the
command needs to open an editor. This opens files as normal Neovim buffers
with full editing support.

| Command | Action |
|---|---|
| `:Git rebase -i HEAD~1` | Interactive rebase — opens rebase file as a normal buffer |
| `:Git commit` | Commit with message — opens commit buffer |
| `:Git diff` | Show diff in a split |
| `:Git log` | Show log |
| `:Git blame` | Line-by-line blame for current file |
| `:Git` | Git status summary |

For interactive rebase: change `pick` to `r` (reword), `s` (squash), etc.,
then `:wq`. Each subsequent editor step (commit message, etc.) opens
automatically. `:wq` each one and git completes.

### gitsigns — hunk operations

Changes in the current file are shown in the sign column (left gutter).

| Key | Action |
|---|---|
| `]h` | Jump to next changed hunk |
| `[h` | Jump to previous changed hunk |
| `Space hp` | Preview the hunk diff in a float |
| `Space hs` | Stage the hunk under cursor |
| `Space hr` | Reset (undo) the hunk under cursor |
| `Space hb` | Show git blame for the current line |

--------------------------------------------------------------------------------

## Themes

Press **`Space th`** to open the theme picker. Scroll through themes — the
editor live-previews each one as you move the cursor. Press `Enter` to
select, `Esc` to cancel.

Your selection is **automatically saved** and restored on next launch — no
config change needed.

A large selection is available including: `tokyonight-night/storm/moon`,
`catppuccin-mocha/macchiato/frappe`, `kanagawa-wave/dragon`, `rose-pine`,
`gruvbox`, `onedark`, `nightfox`, `everforest`, `sonokai`, `dracula`,
`nord`, `github-dark`, `monokai`, `eldritch`, `vesper`, `iceberg`, and more.

--------------------------------------------------------------------------------

## Common Workflows

### Opening a project

```bash
cd ~/Projects/myproject
nvim
```

The file explorer shows the project tree. Use `Space ff` to quickly open
any file.

### Jumping to a definition and back

1. Place cursor on a function call or type
2. Press `gd` — jumps to the definition
3. Press `Ctrl+o` — jumps back to where you were

### Renaming a symbol across the project

1. Place cursor on the variable/function/class name
2. Press `Space rn`
3. Type the new name and press `Enter`
4. All references in all files are updated

### Fixing an import / running a code action

1. Place cursor on the underlined symbol (or anywhere on the error line)
2. Press `Space ca`
3. A menu appears with available fixes — select one with arrow keys and
   `Enter`

### Debugging a Spring Boot app

1. Create `.vscode/launch.json` in the project root (see example above)
2. Open a Java file (jdtls must be running — check bottom status line, or
   run `:JdtlsWhichJava`)
3. Set breakpoints with `Space b` on the lines you want to pause at
4. Press `F5` — the app starts, debug UI opens
5. When execution hits a breakpoint, use `F10`/`F11`/`F12` to step through
6. Hover `Space de` over variables to inspect their values
7. Press `F5` again to continue to the next breakpoint
8. Press `Shift+F5` or `:DapTerminate` to stop the session

### Interactive git rebase

1. From anywhere in Neovim, run `:Git rebase -i HEAD~3` (or however many commits)
2. The rebase todo file opens as a normal buffer — change `pick` to `r`, `s`, `f`, etc.
3. `:wq` — git proceeds to the next step (e.g., commit message for a reword)
4. Edit and `:wq` each subsequent file — git completes when all steps are done

Never use `git rebase -i` from the terminal inside Neovim — use `:Git rebase -i` instead.

### Comparing two files side by side

1. Open the first file normally
2. Press `Ctrl+v` to open a vertical split (or use file explorer `Ctrl+v`)
3. Open the second file in the right split
4. Use `Ctrl+h` and `Ctrl+l` to switch between them

### Discovering available keybindings

Press **`Space`** and pause for ~1 second — a popup shows all bindings that
start with Space. Works for any key: press `g` and pause to see all
`g`-prefixed bindings.
