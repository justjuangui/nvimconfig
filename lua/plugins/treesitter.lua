return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- Async; a no-op for parsers that are already installed.
			require("nvim-treesitter").install({
				"c",
				"cpp",
				"go",
				"lua",
				"python",
				"rust",
				"vim",
				"bash",
				"vimdoc",
				"php",
				"sql",
				"terraform",
				"hcl",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"yaml",
				"json",
				"toml",
				"svelte",
				"rego",
				"ebnf",
				"jinja",
				"glsl",
			})

			-- The `main` branch enables nothing on its own; highlighting and
			-- indenting are opt-in per buffer.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					-- Filetype != language ("sh" -> bash, "typescriptreact" -> tsx),
					-- so let Neovim map it instead of listing patterns by hand.
					local lang = vim.treesitter.language.get_lang(ev.match)

					-- No parser on disk: plugin/UI filetypes, anything not in the
					-- list above, or an `install()` that has not finished compiling
					-- yet. Keep legacy syntax; nothing to report.
					if not lang or #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 then
						vim.bo[ev.buf].syntax = "ON"
						return
					end

					-- A parser alone is not enough: `install()` also drops the queries
					-- into <data>/site/queries/<lang>, as a symlink into the plugin. When
					-- that link is missing or dangling, `query.get` returns nil, the
					-- highlighter attaches with nothing to match, and it still clears
					-- 'syntax' -- a silent plain-text buffer. Check before attaching.
					local ok, err = pcall(function()
						assert(vim.treesitter.query.get(lang, "highlights"), "no highlights query installed")
						vim.treesitter.start(ev.buf, lang)
					end)
					if not ok then
						vim.bo[ev.buf].syntax = "ON"
						vim.notify(
							("treesitter: %s highlighting failed, falling back to syntax\n%s"):format(lang, err),
							vim.log.levels.WARN
						)
						return
					end

					-- Treesitter indent is experimental upstream; c/cpp keep cindent.
					if ev.match == "c" or ev.match == "cpp" then
						vim.bo[ev.buf].indentexpr = ""
						vim.bo[ev.buf].cindent = true
					else
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- The `main` branch only takes behaviour options here; keymaps are ours to set.
			require("nvim-treesitter-textobjects").setup({
				move = { set_jumps = true }, -- whether to set jumps in the jumplist
			})

			local move = require("nvim-treesitter-textobjects.move")
			local function jump(key, fn, query, group)
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move[fn](query, group or "textobjects")
				end, { desc = "TS: " .. fn .. " " .. (type(query) == "table" and query[1] or query) })
			end

			jump("]m", "goto_next_start", "@function.outer")
			jump("]]", "goto_next_start", "@class.outer")
			jump("]o", "goto_next_start", { "@loop.inner", "@loop.outer" })
			-- `locals` and `folds` come from nvim-treesitter's own queries.
			jump("]s", "goto_next_start", "@local.scope", "locals")
			jump("]z", "goto_next_start", "@fold", "folds")

			jump("]M", "goto_next_end", "@function.outer")
			jump("][", "goto_next_end", "@class.outer")

			jump("[m", "goto_previous_start", "@function.outer")
			jump("[[", "goto_previous_start", "@class.outer")

			jump("[M", "goto_previous_end", "@function.outer")
			jump("[]", "goto_previous_end", "@class.outer")

			-- Go to whichever of start/end is closer.
			-- Not `]d`/`[d` — those are diagnostic navigation in keymaps_setup.lua.
			jump("]i", "goto_next", "@conditional.outer")
			jump("[i", "goto_previous", "@conditional.outer")
		end,
	},
}
