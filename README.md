# nvim

Personal Neovim configuration. Requires **Neovim 0.12+** (uses the native `lsp/` directory
and `vim.lsp.enable()`, added in 0.11).

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which bootstraps itself on first
launch. Plugin versions are pinned in `lazy-lock.json` — run `:Lazy restore` to match it
exactly, `:Lazy update` to bump it.

Leader and localleader are both `<Space>`.

## Layout

```
init.lua                   entry point, requires the modules below in order
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
| `j` / `k` | Move by *screen* line when no count is given (`gj` / `gk`) |
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
Hygiene numbering matches the linked report one-for-one, so the two can be read together.
Full report: <https://claude.ai/code/artifact/9f94da0d-32ae-45b2-a61d-57a870279f81>

### Broken — configured but does nothing

_None outstanding._

### Conflicts

_None outstanding._

### Dead code

_None outstanding._

### Hygiene

Nothing here breaks a feature or fights another subsystem. Items 1 and 2 are the only ones
with a deadline or a measurable payoff; the rest are preference.

1. **Deprecated APIs** (`lua/config/keymaps_setup.lua:6, 25-26`). Both still work in 0.12.4
   and both are on the removal track: `vim.highlight.on_yank` → `vim.hl.on_yank`, and
   `vim.diagnostic.goto_prev/goto_next` → `vim.diagnostic.jump({ count = ±1 })`.
2. **The DAP stack and `rustaceanvim` load at startup in every project**
   (`lua/plugins/dap_setup.lua`, `lua/plugins/lsp.lua:9-13`). `dap_setup.lua` declares no
   `event`, `cmd` or `keys`, so nvim-dap, dap-ui, mason-nvim-dap, telescope-dap,
   dap-virtual-text, dap-go and nvim-nio all initialise whether or not you intend to
   debug; `rustaceanvim` is `lazy = false` and pulls `neotest` in with it, in Go and PHP
   projects too. That stack is ~88 ms of self-time out of a ~249 ms profile — about a
   third. `mason-nvim-dap.mappings.configurations` alone is the largest single entry.
   Binding the spec to `keys = { "<F5>", "<leader>b" }` reclaims it.
   *Treat the absolute figure as unreliable:* it has read 149, 205, 150 and 249 ms across
   measurements on an idle machine. The ~1/3 share is what has held steady.
3. **lazy.nvim checks GitHub for updates on every start** (`lua/config/lazy.lua:22`).
   `checker = { enabled = true }` with no `notify = false`. Given everything is pinned in
   `lazy-lock.json` and updated deliberately, `{ enabled = true, notify = false }` — or a
   `frequency` — is the quieter equivalent.
4. **`glslc` compile-on-save has no guard and discards its errors**
   (`lua/config/vulkan.lua:15-19`). No `executable()` check, no `on_exit`, no `on_stderr`,
   and the `.spv` lands next to the source. This matters more than it looks: `glsl_analyzer`
   publishes no diagnostics, so this job is the *only* thing that can tell you a shader
   failed to compile — and right now it fails silently.
5. **`jsonls` runs without any schemas** (`lsp/jsonls.lua`). `yamlls` enables SchemaStore;
   `jsonls` has no equivalent, so there is no validation or completion for `package.json`,
   `tsconfig.json`, GitHub workflows and so on — the highest-value thing a JSON server does.
   `b0o/schemastore.nvim` feeding `settings.json.schemas` would serve both servers.
6. **The DAP keys are invisible to which-key and `<leader>sk`**
   (`lua/plugins/dap_setup.lua:31-38`, `lua/plugins/general.lua`). The bindings carry
   descriptions, but no which-key group covers `<F1>`–`<F7>` or `<leader>b`, so they never
   surface next to the groups that are declared.
7. **No `.stylua.toml` despite formatting Lua with stylua.** `telescope.lua`,
   `db_setup.lua` and `tokyo.lua` use 2-space indent, and `lsp/jsonls.lua` uses single
   quotes, while everything else uses tabs and double quotes — the kickstart-derived files,
   never reformatted. `vim-sleuth` is installed and will infer the *wrong* indent from
   whichever of them you open first.

### Resolved

21 findings, all confirmed at runtime rather than by reading the source. One-line summaries
below; the [full report](https://claude.ai/code/artifact/9f94da0d-32ae-45b2-a61d-57a870279f81)
has the diagnosis and the check for each, and the commit messages carry the proofs.

**Broken — the feature did not exist at runtime**

- `<C-h/j/k/l>` window navigation was dead: Harpoon rebound all four during plugin load,
  after `keymaps_setup` had already run. Removed Harpoon, which was not in use. (`98ea65a`)
- Every Treesitter textobject motion was unmapped: the plugin is on the `main` branch,
  which replaced the declarative API with `setup()` plus your own keymaps, so the old call
  returned without error and mapped nothing. Ported; conditionals moved to `]i`/`[i` to
  avoid shadowing diagnostic navigation. (`6957054`)
- `<leader>ca` never worked in visual mode: the `map()` helper computed `mode or "n"` and
  then hardcoded `"n"` in the call, discarding the `{ "n", "x" }` at the call site.
  (`d1e812a`)
- Signature help was unreachable: `map("<C-k", …)` was missing its closing `>`, so four
  literal characters were mapped. Now `gK`, pairing with `K`. Insert mode needed nothing —
  `<C-s>` and blink.cmp's `<C-k>` already existed. (`c7b32af`)
- `yamlls` was fully configured but missing from `vim.lsp.enable()`, and `root_margers`
  would have forced single-file mode even once enabled. (`830c5d3`)
- `ts_ls`'s `on_attach` sat *inside* the `handlers` table, so Neovim treated it as a
  response handler for an LSP method no server sends. `:LspTypeScriptSourceAction` was
  never created. (`c2ffeab`)
- Svelte's server could not start and 7 of 9 formatter chains had no binary:
  `ensure_installed` listed only servers and linters. It is now a superset of every binary
  named anywhere in this config. (`6cb5b20`)
- The which-key `[G]it [H]unk` group opened onto nothing: gitsigns ships no default
  keymaps and the config set only sign glyphs. Added an `on_attach`. (`9adddf3`)

**Conflicts — two things doing the same job**

- Two completion engines ran at once: `vim.lsp.completion.enable(…)` on `LspAttach`
  alongside blink.cmp. The native call is gone; blink owns completion. (`07f124c`)
- Every diagnostic rendered twice: `virtual_lines` and `virtual_text` are alternatives,
  not complements. Now full detail on the cursor line, quiet elsewhere. (`07f124c`)
- Colorscheme load order was unpinned: `priotity` is an unknown key lazy.nvim ignores, and
  the install fallback named a scheme (`"tokyo"`) that does not exist. (`9adddf3`)
- Conform loaded on the first save of every session for nothing: `format_on_save = nil`,
  yet `event = "BufWritePre"` still pulled the plugin in. (`9adddf3`)

**Dead code — read and ignored** (all `3221a0e`)

- PHP `includePaths` pointed at four `C:/Users/JUANGUI/…` stub directories.
- `win_config.lua` was never required; now loaded behind `vim.fn.has("win32")`.
- `vim.g.terminal_emulator` — no such Neovim variable.
- conform's `tf` key — a `.tf` file is filetype `terraform`, already covered.
- `indent.disabled = "ruby"` was an unknown key, so Ruby indent was never actually
  disabled — the line did the opposite of what it read. Now `disable = { "ruby" }`.
- `mason-nvim-dap`'s `automatic_setup`, renamed upstream to `automatic_installation`.
- `luvit-meta`, archived — lazydev ships the `vim.uv` types itself.
- `glsl_analyzer` was installed by Mason but never enabled and had no file in `lsp/`.
  Now wired up. Note it serves completion only and publishes no diagnostics.

## Maintenance

After every `:Lazy update`, run:

```
:checkhealth
:LspInfo         " servers actually attached, not just configured
:ConformInfo     " formatters actually resolved to a binary
:Lazy            " orphaned plugins; :Lazy clean removes them
:verbose map <C-h>
```

Dependency bumps are when branch APIs shift and keys get reclaimed — the treesitter
textobjects rewrite, the `mason-nvim-dap` option rename and the archived `luvit-meta`
all arrived that way.

**The failure mode to watch for.** Almost every issue found in the audit was a key or a
name that was *read and silently ignored* — never an error. `priotity`, `root_margers`,
`indent.disabled`, `automatic_setup`, `tf`, `map("<C-k")` missing its `>`, and an
`on_attach` nested one level too deep inside `handlers`. Lua reports nothing for an
unknown table key, and neither lazy.nvim nor Neovim validates spec fields, so a typo and a
renamed option look identical to correct config until you check the runtime. The checks
above are worth more than re-reading the source: ask what is *attached*, *mapped* and
*resolved*, not what is written down.
