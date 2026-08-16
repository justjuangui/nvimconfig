# nvim

Personal Neovim configuration. Requires **Neovim 0.12+** (uses the native `lsp/` directory
and `vim.lsp.enable()`, added in 0.11).

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which bootstraps itself on first
launch. Plugin versions are pinned in `lazy-lock.json` — run `:Lazy restore` to match it
exactly, `:Lazy update` to bump it.

Leader and localleader are both `<Space>`.

## Layout

```
init.lua                   entry point, requires the five modules below in order
lazy-lock.json             pinned plugin commits

lua/config/
  settings_setup.lua       options + vim.diagnostic.config
  keymaps_setup.lua        global keymaps, yank highlight
  lazy.lua                 lazy.nvim bootstrap + setup
  lsp.lua                  LspAttach autocmd + vim.lsp.enable() list
  vulkan.lua               GLSL filetypes + glslc compile on save
  win_config.lua           PowerShell shell settings (loaded only when has('win32'))

lua/plugins/               one file per concern, auto-imported by lazy
  autocompletion.lua       blink.cmp + copilot
  autoformat.lua           conform.nvim
  dap_setup.lua            nvim-dap stack
  db_setup.lua             vim-dadbod
  general.lua              lualine, which-key, todo-comments, indent-blankline
  git.lua                  gitsigns, fugitive, rhubarb
  lsp.lua                  mason, mason-tool-installer, lazydev, rustaceanvim, crates
  markdown.lua             markdown-preview, render-markdown
  neotest.lua              neotest
  telescope.lua            telescope + extensions and all its keymaps
  tokyo.lua                tokyonight colorscheme
  treesitter.lua           nvim-treesitter + textobjects

lsp/                       one file per language server, read natively by Neovim
  gopls.lua  golangci_lint_ls.lua  lua_ls.lua  ts_ls.lua  jsonls.lua
  yamlls.lua  phpls.lua  svelte.lua  terraformls.lua  tflint.lua  regalls.lua
  glsl_analyzer.lua
```

Load order in `init.lua`: leader → `settings_setup` → `keymaps_setup` →
`win_config` (Windows only) → `lazy` → `lsp` → `vulkan`.

Note that `keymaps_setup` runs **before** plugins load, so any plugin that maps the same
key wins. See [Known issues](#known-issues).

## Languages

| Language | Server | Formatter | Debug | Test |
| --- | --- | --- | --- | --- |
| Go | `gopls`, `golangci_lint_ls` | goimports → gofumpt → golines | delve (`dap-go`) | — |
| Rust | `rust-analyzer` via `rustaceanvim` | rustfmt (LSP) | via rustaceanvim | neotest |
| Lua | `lua_ls` + `lazydev` | stylua | — | — |
| TypeScript / JS | `ts_ls` | prettier | — | — |
| Svelte | `svelte` | prettier | — | — |
| PHP | `intelephense` | php-cs-fixer | — | — |
| Terraform / HCL | `terraformls`, `tflint` | terraform fmt, terragrunt hclfmt† | — | — |
| Rego | `regal` | — | — | — |
| JSON | `jsonls` | — | — | — |
| YAML | `yamlls` (SchemaStore) | yamlfmt | — | — |
| GLSL | `glsl_analyzer` | — | — | compiled to SPIR-V on save |
| SQL | — (dadbod completion) | — | — | — |

† `terraform` and `terragrunt` are the only tools not installed by Mason — `terraform` is a
general infra CLI that belongs on the system PATH, and `terragrunt` is not in the Mason
registry at all. Install both yourself if you format HCL.

Everything else is installed by `mason-tool-installer` (see `lua/plugins/lsp.lua`), whose
`ensure_installed` is a superset of every binary referenced anywhere in this config.
Check state with `:Mason`, `:LspInfo`, `:ConformInfo`, `:checkhealth`.

## Keymaps

### Search — Telescope

| Key | Action |
| --- | --- |
| `<leader><leader>` | Existing buffers |
| `<leader>sf` | Find files (hidden included; `node_modules`, `target`, `.venv`, `.svelte-kit` excluded) |
| `<leader>sg` | Live grep |
| `<leader>sG` | Live grep from git root |
| `<leader>sw` | Grep word under cursor |
| `<leader>sd` | Diagnostics |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>ss` | Telescope builtins |
| `<leader>sr` | Resume last picker |
| `<leader>sn` | Find files in this config |
| `<leader>/` | Fuzzy find in current buffer |
| `<leader>?` | Recently opened files |
| `<leader>gs` | Git files |

### LSP — buffer-local, set on attach

| Key | Action |
| --- | --- |
| `gd` / `gr` / `gI` | Definition / references / implementations |
| `gD` | Declaration |
| `K` | Hover documentation — *what is this* |
| `gK` | Signature help — *what arguments does it take* |
| `<leader>D` | Type definition |
| `<leader>ds` / `<leader>ws` | Document / workspace symbols |
| `<leader>wd` | Workspace diagnostics |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action (normal **and** visual — select a range for `refactor.*`) |
| `<leader>th` | Toggle inlay hints |
| `<leader>wa` / `<leader>wr` / `<leader>wl` | Workspace folder add / remove / list |
| `<leader>td` | Debug nearest test (Rust only) |

Document highlight on `CursorHold` is enabled for any server that supports it.

Signature help while typing arguments is automatic — blink.cmp pops it on `(` and `,`.
Insert mode also has two manual keys that come for free: `<C-s>` is a Neovim global
default (`:help lsp-defaults`) and `<C-k>` comes from blink.cmp's `default` preset.

Neovim 0.11+ additionally ships global LSP defaults that overlap some bindings above:
`grn` rename, `gra` code action (normal **and** visual), `grr` references, `gri`
implementation, `grt` type definition, `grx` codelens, `gO` document symbols.

### Diagnostics, edit and motion

| Key | Action |
| --- | --- |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>e` | Floating diagnostic |
| `<leader>q` | Diagnostic loclist |
| `<leader>fd` | Format document (conform) |
| `<Esc>` | Clear search highlight |
| `J` / `K` (visual) | Move selected lines down / up |
| `<C-d>` / `<C-u>` | Half-page scroll, recentred |
| `n` / `N` | Next / previous match, recentred |
| `<leader>oex` | Open netrw explorer |
| arrow keys | Echo a reminder to use `hjkl` |

### Treesitter motions

Available in normal, visual and operator-pending mode, so `d]m` works.

| Key | Action |
| --- | --- |
| `]m` / `[m` | Next / previous function start |
| `]M` / `[M` | Next / previous function end |
| `]]` / `[[` | Next / previous class start |
| `][` / `[]` | Next / previous class end |
| `]o` | Next loop |
| `]s` | Next scope (`locals` query) |
| `]z` | Next fold (`folds` query) |
| `]i` / `[i` | Next / previous conditional, nearest edge |

### Windows

| Key | Action |
| --- | --- |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move to the left / lower / upper / right window |

### Git hunks — gitsigns, buffer-local

| Key | Action |
| --- | --- |
| `]c` / `[c` | Next / previous hunk (falls through to the built-in inside a real diff) |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk (normal **and** visual) |
| `<leader>hS` / `<leader>hR` | Stage / reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff against index |
| `<leader>hq` | Send hunks to quickfix |

### Debug — nvim-dap

| Key | Action |
| --- | --- |
| `<F5>` | Start / continue |
| `<F1>` / `<F2>` / `<F3>` | Step into / over / out |
| `<F7>` | Toggle DAP UI |
| `<leader>b` / `<leader>B` | Toggle breakpoint / conditional breakpoint |

### Commands

| Command | Action |
| --- | --- |
| `:LiveGrepGitRoot` | Live grep scoped to the git root |
| `:DBUI`, `:DBUIToggle` | Database UI |
| `:MarkdownPreview`, `:MarkdownPreviewToggle` | Markdown preview in browser |
| `:LspTypeScriptSourceAction` | TS/JS source actions: fix all, add missing imports, remove unused |
| `:LspMigrateToSvelte5` | Migrate component to Svelte 5 syntax |

## Conventions

- Hard tabs, width 4 (`expandtab = false`). `vim-sleuth` overrides per project.
- Relative line numbers, `signcolumn` always on, `scrolloff = 10`.
- System clipboard (`unnamedplus`), set inside `vim.schedule` to keep startup fast.
- `undofile` on; `inccommand = split` for live substitute preview.
- Colorscheme: `tokyonight-night`.
- Diagnostic signs: `✘` error, `▲` warn, `⚑` hint, `»` info.
- Diagnostics show as virtual *lines* on the cursor line only; virtual text is off.
- Completion is blink.cmp alone. Native `vim.lsp.completion` is deliberately not enabled.
- No format-on-save. Formatting is manual via `<leader>fd`.

## Known issues

Audited 2026-08-16 against Neovim 0.12.4; verified by running the config, not by reading it.
Numbering here is independent of the linked report, and renumbers as items are resolved.
Full report: <https://claude.ai/code/artifact/9f94da0d-32ae-45b2-a61d-57a870279f81>

### Broken — configured but does nothing

_None outstanding._

### Conflicts

_None outstanding._

### Dead code

_None outstanding._

### Hygiene

1. Deprecated APIs still in use: `vim.highlight.on_yank` → `vim.hl.on_yank`;
   `vim.diagnostic.goto_prev/goto_next` → `vim.diagnostic.jump({ count = ±1 })`.
2. The whole DAP stack and `rustaceanvim` load at startup in every project
   (~1/3 of the ~205 ms startup).
3. `glslc` compile-on-save has no `executable()` guard and discards exit code and stderr.
4. No `.stylua.toml` despite formatting Lua with stylua; `telescope.lua`, `db_setup.lua`
   and `tokyo.lua` use 2-space indent while everything else uses tabs.

### Resolved

- **Eight pieces of dead code, cleared in one pass.** Each was verified by running the
  config, not by reading it:
  - PHP `includePaths` pointed at four `C:/Users/JUANGUI/…` stub directories that do not
    exist on this machine. Removed; `intelephense` still attaches with `phpVersion = 8.2`.
  - `lua/config/win_config.lua` was never required. It is now loaded from `init.lua`
    behind `vim.fn.has("win32")`, so it works on Windows and stays inert here — `&shell`
    is still `/usr/bin/bash` after startup. The unrelated `vim.g.terminal_emulator = "wt"`
    in `settings_setup.lua` is gone; no such Neovim variable exists.
  - `tf = { "terraform_fmt" }` in conform: `tf` is not a filetype — a `.tf` file is
    `terraform`, which the next line already covered. Confirmed the `tf` key is gone and
    `terraform → terraform_fmt` survives. (`terraform_fmt` still reports
    `Command 'terraform' not found` — the deliberate non-Mason tool, not a regression.)
  - `indent.disabled = "ruby"` was an unknown key that nvim-treesitter silently dropped,
    so Ruby indent was never actually disabled. Now `disable = { "ruby" }`, and the
    loaded `indent` module reports it.
  - `mason-nvim-dap`'s `automatic_setup` was renamed upstream to
    `automatic_installation`. Renamed; `dap.adapters` still lists `go` and `delve`.
  - `luvit-meta` is archived and lazydev ships the `vim.uv` types itself. The library
    entry and the plugin are gone (`:Lazy clean`, lockfile updated), and hover on
    `vim.uv.new_timer` still returns the full signature and docs.
  - `lsp/regalls.lua` printed `regal: root_dir …` to `:messages` on every Rego root
    resolve. Removed; `regalls` attaches with an empty message log.
  - `glsl_analyzer` was installed by Mason but never enabled and had no file in `lsp/`.
    Added `lsp/glsl_analyzer.lua` and enabled it. Verified on a `.frag` buffer: the
    client attaches, resolves the git root, and serves 1375 completion items. Note it is
    a completion/navigation server — it publishes no diagnostics, so `glslc` on save is
    still what catches compile errors.
- **Window navigation `<C-h/j/k/l>` was dead** — Harpoon rebound all four during plugin
  load, shadowing `lua/config/keymaps_setup.lua:44-47`. Fixed by removing Harpoon.
- **All Treesitter textobject motions were unmapped** — `nvim-treesitter-textobjects` is
  on the `main` branch, which replaced the declarative `nvim-treesitter.configs` API with
  `setup()` for options plus explicit keymaps. The old call failed silently. Rewritten to
  the new API; `nvim-treesitter` stays on `master`, since the two plugins are decoupled
  (textobjects ships its own `textobjects.scm` and calls `vim.treesitter` directly, while
  `locals` and `folds` queries still come from nvim-treesitter). Conditionals moved from
  `]d`/`[d` to `]i`/`[i` to avoid shadowing diagnostic navigation.
- **Colorscheme load order was unpinned** — `lua/plugins/tokyo.lua` said `priotity`, an
  unknown key lazy.nvim ignores, and `lua/config/lazy.lua` named a colorscheme `"tokyo"`
  that does not exist. Fixed to `priority = 1000` with `lazy = false`, and the install
  fallback now names `tokyonight-night`.
- **The which-key `[G]it [H]unk` group was empty** — gitsigns ships no default keymaps
  and the config set only sign glyphs, so `<leader>h` opened onto nothing. Added an
  `on_attach` with stage/reset/preview/blame/diff plus `]c`/`[c` navigation. Uses
  `nav_hunk` and the toggling `stage_hunk` rather than the deprecated `next_hunk`,
  `prev_hunk` and `undo_stage_hunk`.
- **Conform loaded on every first save for nothing** — `format_on_save = nil` meant
  nothing formatted on write, yet `event = "BufWritePre"` still pulled the plugin in.
  Manual formatting is the intent, so `<leader>fd` is now the only lazy trigger and the
  dead commented-out `format_on_save` block is gone.
- **Two completion engines ran at once** — `vim.lsp.completion.enable(…, autotrigger = true)`
  on `LspAttach` alongside blink.cmp, both subscribing to the same LSP capability. The
  native call is gone; blink owns completion. Verified: the `nvim.lsp.completion_1`
  `InsertCharPre` autocmd is no longer registered (re-enabling it puts it straight back,
  which is how the contrast was confirmed). `omnifunc` stays at `v:lua.vim.lsp.omnifunc`
  — that is a Neovim default for manual `<C-x><C-o>` and does not conflict.
- **Every diagnostic rendered twice** — `virtual_lines` and `virtual_text` are
  alternatives, not complements. Now `virtual_lines = { current_line = true }` with
  `virtual_text = false`: full detail on the line you are on, quiet elsewhere. Verified
  by counting extmarks on a file with 4 diagnostics — 8 renderings before, 1 after.
- **Svelte LSP could not start, and 7 of 9 formatter chains had no binary** —
  `mason-tool-installer`'s `ensure_installed` listed only servers and linters, so
  `svelteserver` and every formatter conform referenced were simply absent. The manifest
  is now a superset of every binary named anywhere in the config, grouped by role.
  Verified end-to-end: lua, ts, yaml, php and go all format through `<leader>fd`, and
  the Svelte server attaches with `:LspMigrateToSvelte5` available.
  Two tools stay outside Mason on purpose — `terraform` (general infra CLI, belongs on
  the system PATH) and `terragrunt` (not in the Mason registry at all).
- **`ts_ls`'s `on_attach` never ran** — it sat *inside* the `handlers` table rather than
  beside it, so Neovim treated it as a response handler for an LSP method literally named
  `on_attach`, which no server sends. `:LspTypeScriptSourceAction` was therefore never
  created in any TS buffer. Fixed by moving it up one level. Verified: the command now
  exists, the `_typescript.rename` handler still registers, nothing leaks into `handlers`,
  and the command offers 4 source actions (fix all, add missing imports, remove unused
  code, remove unused imports).
- **`yamlls` was configured but never enabled** — `lsp/yamlls.lua` existed with
  SchemaStore on, and the server was installed, but the name was missing from
  `vim.lsp.enable()`. The same file also had `root_margers` for `root_markers`, so even
  once enabled it would have fallen back to single-file mode. Both fixed. Verified:
  yamlls attaches, `root_dir` resolves to the git root, and SchemaStore flags a bad key
  in a GitHub workflow as `yaml-schema: GitHub Workflow — Property stpes is not allowed`.
- **Signature help was unreachable** — `lua/config/lsp.lua:26` read `map("<C-k", ...)`,
  missing the closing `>`, so Neovim mapped four literal characters. Replaced with `gK`
  in normal mode, pairing with `K` for hover. Insert mode turned out to need nothing at
  all: `<C-s>` is a Neovim global default and blink.cmp's `default` preset already binds
  `<C-k>`. Also enabled blink.cmp's `signature` module so the parameter list appears
  automatically on `(` and `,`.
- **`<leader>ca` never worked in visual mode** — the `map()` helper in `lua/config/lsp.lua`
  computed `mode = mode or "n"` and then hardcoded `"n"` in the `vim.keymap.set` call, so
  the `{ "n", "x" }` at the call site was discarded. Lua reports nothing for an unused
  parameter, so it failed silently. Fixed by passing `mode or "n"` through. This restores
  the range-based code actions — with a selection, gopls offers `refactor.extract.variable`,
  `source.addTest`, `source.assembly` and `source.freesymbols`, none of which are
  reachable from a bare cursor position.

## Maintenance

After every `:Lazy update`, run:

```
:checkhealth
:LspInfo         " servers actually attached
:ConformInfo     " formatters actually resolved
:verbose map <C-h>
```

Dependency bumps are when branch APIs shift and keys get reclaimed — the treesitter
textobjects rewrite, the `mason-nvim-dap` option rename and the archived `luvit-meta`
all arrived that way.
