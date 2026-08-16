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
| YAML | `yamlls` | yamlfmt | — | — |
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
| `K` | Hover documentation |
| `<leader>D` | Type definition |
| `<leader>ds` / `<leader>ws` | Document / workspace symbols |
| `<leader>wd` | Workspace diagnostics |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>th` | Toggle inlay hints |
| `<leader>wa` / `<leader>wr` / `<leader>wl` | Workspace folder add / remove / list |
| `<leader>td` | Debug nearest test (Rust only) |

Document highlight on `CursorHold` is enabled for any server that supports it.

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
The report below is numbered independently of the linked one, which predates the Harpoon removal.
Full report: <https://claude.ai/code/artifact/9f94da0d-32ae-45b2-a61d-57a870279f81>

### Broken — configured but does nothing

1. **All Treesitter textobject motions are unmapped** (`]m [m ]] [[ ]o ]s ]z ]d` …).
   `lazy-lock.json` pins `nvim-treesitter` to `master` but `nvim-treesitter-textobjects`
   to `main`; the main branch dropped the `require("nvim-treesitter.configs").setup{}`
   API that `lua/plugins/treesitter.lua:49` calls. Fails silently.
2. **`<leader>ca` never works in visual mode.** The `map()` helper at
   `lua/config/lsp.lua:4-7` computes `mode = mode or "n"` and then hardcodes `"n"`, so
   the `{ "n", "x" }` passed on line 10 is discarded.
3. **Signature help is unreachable.** `lua/config/lsp.lua:26` reads `map("<C-k", ...)` —
   missing `>`. Note that `<C-k>` is now the "move to upper window" key, so fixing the
   typo alone would shadow it — signature help needs a different binding.
4. **`yamlls` is never enabled.** `lsp/yamlls.lua` exists and the server is installed, but
   the name is absent from `vim.lsp.enable()` at `lua/config/lsp.lua:82-93`. That file
   also has `root_margers` instead of `root_markers` on line 4.
5. **`ts_ls`'s `on_attach` is dead.** `lsp/ts_ls.lua:18` nests it inside `handlers`, so
   Neovim treats it as a response handler for a nonexistent method and
   `:LspTypeScriptSourceAction` is never created.
6. **Svelte LSP cannot start.** `svelteserver` is not installed and
   `svelte-language-server` is missing from `mason-tool-installer`'s `ensure_installed`.
7. **7 of 9 formatter chains have no binary.** `ensure_installed` lists only servers and
   linters. Missing: `stylua`, `prettier`, `yamlfmt`, `php-cs-fixer`, `gofumpt`,
   `golines`, `terragrunt`. Only `goimports` resolves.

### Conflicts

8. **Two completion engines.** `vim.lsp.completion.enable(…, autotrigger = true)` at
   `lua/config/lsp.lua:47-49` runs alongside `blink.cmp`.
9. **Diagnostics render twice.** `virtual_lines` and `virtual_text` are both `true` in
   `lua/config/settings_setup.lua:59-60`. They are alternatives.
10. **Colorscheme load order unpinned.** `lua/plugins/tokyo.lua:3` says `priotity`, not
    `priority`. And `lua/config/lazy.lua:21` names colorscheme `"tokyo"`, which does not
    exist — it is `tokyonight-night`.
11. **which-key `<leader>h` "Git Hunk" group is empty.** gitsigns sets no keymaps and
    ships no defaults.
12. **Format-on-save is off** (`format_on_save = nil`) while conform still lazy-loads on
    `BufWritePre`. Manual `<leader>fd` only.

### Dead code

13. PHP stub `includePaths` point at `C:/Users/JUANGUI/…` (`lsp/phpls.lua:12-17`).
14. `lua/config/win_config.lua` is unreferenced; `vim.g.terminal_emulator` is not a real
    Neovim variable.
15. `tf = { "terraform_fmt" }` — `tf` is not a filetype; line 40 already covers it.
16. `indent.disabled = "ruby"` should be `indent.disable = { "ruby" }`.
17. `dependecies` typo in the textobjects spec (`lua/plugins/treesitter.lua:47`).
18. `mason-nvim-dap`'s `automatic_setup` was renamed to `automatic_installation`.
19. `luvit-meta` is archived — lazydev ships `vim.uv` types itself.
20. `lsp/regalls.lua:14` has a leftover `vim.print` on every Rego root resolve.
21. `glsl_analyzer` is installed by Mason but never enabled and has no file in `lsp/`.

### Hygiene

22. Deprecated APIs still in use: `vim.highlight.on_yank` → `vim.hl.on_yank`;
    `vim.diagnostic.goto_prev/goto_next` → `vim.diagnostic.jump({ count = ±1 })`.
23. The whole DAP stack and `rustaceanvim` load at startup in every project
    (~1/3 of the 149 ms startup).
24. `glslc` compile-on-save has no `executable()` guard and discards exit code and stderr.
25. No `.stylua.toml` despite formatting Lua with stylua; `telescope.lua`, `db_setup.lua`
    and `tokyo.lua` use 2-space indent while everything else uses tabs.

### Resolved

- **Window navigation `<C-h/j/k/l>` was dead** — Harpoon rebound all four during plugin
  load, shadowing `lua/config/keymaps_setup.lua:44-47`. Fixed by removing Harpoon.

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
