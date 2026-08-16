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
  win_config.lua           PowerShell shell settings (not loaded)

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
```

Load order in `init.lua`: leader → `settings_setup` → `keymaps_setup` → `lazy` →
`lsp` → `vulkan`.

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
| Terraform / HCL | `terraformls`, `tflint` | terraform fmt, terragrunt hclfmt | — | — |
| Rego | `regal` | — | — | — |
| JSON | `jsonls` | — | — | — |
| YAML | `yamlls` (SchemaStore) | yamlfmt | — | — |
| GLSL | — | — | — | compiled to SPIR-V on save |
| SQL | — (dadbod completion) | — | — | — |

External tooling is installed by `mason-tool-installer` (see `lua/plugins/lsp.lua`).
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
| `:LspMigrateToSvelte5` | Migrate component to Svelte 5 syntax |

## Conventions

- Hard tabs, width 4 (`expandtab = false`). `vim-sleuth` overrides per project.
- Relative line numbers, `signcolumn` always on, `scrolloff = 10`.
- System clipboard (`unnamedplus`), set inside `vim.schedule` to keep startup fast.
- `undofile` on; `inccommand = split` for live substitute preview.
- Colorscheme: `tokyonight-night`.
- Diagnostic signs: `✘` error, `▲` warn, `⚑` hint, `»` info.

## Known issues

Audited 2026-08-16 against Neovim 0.12.4; verified by running the config, not by reading it.
Numbering here is independent of the linked report, and renumbers as items are resolved.
Full report: <https://claude.ai/code/artifact/9f94da0d-32ae-45b2-a61d-57a870279f81>

### Broken — configured but does nothing

1. **`ts_ls`'s `on_attach` is dead.** `lsp/ts_ls.lua:18` nests it inside `handlers`, so
   Neovim treats it as a response handler for a nonexistent method and
   `:LspTypeScriptSourceAction` is never created.
2. **Svelte LSP cannot start.** `svelteserver` is not installed and
   `svelte-language-server` is missing from `mason-tool-installer`'s `ensure_installed`.
3. **7 of 9 formatter chains have no binary.** `ensure_installed` lists only servers and
   linters. Missing: `stylua`, `prettier`, `yamlfmt`, `php-cs-fixer`, `gofumpt`,
   `golines`, `terragrunt`. Only `goimports` resolves.

### Conflicts

4. **Two completion engines.** `vim.lsp.completion.enable(…, autotrigger = true)` at
   `lua/config/lsp.lua:47-49` runs alongside `blink.cmp`.
5. **Diagnostics render twice.** `virtual_lines` and `virtual_text` are both `true` in
   `lua/config/settings_setup.lua:59-60`. They are alternatives.
6. **Colorscheme load order unpinned.** `lua/plugins/tokyo.lua:3` says `priotity`, not
   `priority`. And `lua/config/lazy.lua:21` names colorscheme `"tokyo"`, which does not
   exist — it is `tokyonight-night`.
7. **which-key `<leader>h` "Git Hunk" group is empty.** gitsigns sets no keymaps and
    ships no defaults.
8. **Format-on-save is off** (`format_on_save = nil`) while conform still lazy-loads on
    `BufWritePre`. Manual `<leader>fd` only.

### Dead code

9. PHP stub `includePaths` point at `C:/Users/JUANGUI/…` (`lsp/phpls.lua:12-17`).
10. `lua/config/win_config.lua` is unreferenced; `vim.g.terminal_emulator` is not a real
    Neovim variable.
11. `tf = { "terraform_fmt" }` — `tf` is not a filetype; line 40 already covers it.
12. `indent.disabled = "ruby"` should be `indent.disable = { "ruby" }`.
13. `mason-nvim-dap`'s `automatic_setup` was renamed to `automatic_installation`.
14. `luvit-meta` is archived — lazydev ships `vim.uv` types itself.
15. `lsp/regalls.lua:14` has a leftover `vim.print` on every Rego root resolve.
16. `glsl_analyzer` is installed by Mason but never enabled and has no file in `lsp/`.

### Hygiene

17. Deprecated APIs still in use: `vim.highlight.on_yank` → `vim.hl.on_yank`;
    `vim.diagnostic.goto_prev/goto_next` → `vim.diagnostic.jump({ count = ±1 })`.
18. The whole DAP stack and `rustaceanvim` load at startup in every project
    (~1/3 of the 149 ms startup).
19. `glslc` compile-on-save has no `executable()` guard and discards exit code and stderr.
20. No `.stylua.toml` despite formatting Lua with stylua; `telescope.lua`, `db_setup.lua`
    and `tokyo.lua` use 2-space indent while everything else uses tabs.

### Resolved

- **Window navigation `<C-h/j/k/l>` was dead** — Harpoon rebound all four during plugin
  load, shadowing `lua/config/keymaps_setup.lua:44-47`. Fixed by removing Harpoon.
- **All Treesitter textobject motions were unmapped** — `nvim-treesitter-textobjects` is
  on the `main` branch, which replaced the declarative `nvim-treesitter.configs` API with
  `setup()` for options plus explicit keymaps. The old call failed silently. Rewritten to
  the new API; `nvim-treesitter` stays on `master`, since the two plugins are decoupled
  (textobjects ships its own `textobjects.scm` and calls `vim.treesitter` directly, while
  `locals` and `folds` queries still come from nvim-treesitter). Conditionals moved from
  `]d`/`[d` to `]i`/`[i` to avoid shadowing diagnostic navigation.
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

Dependency bumps are when branch APIs shift and keys get reclaimed — items 1, 2, 7 and 8
above all arrived that way.
