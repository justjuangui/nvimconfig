return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		branch = "master",
		lazy = false,
		opts = {
			ensure_installed = {
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
			},
			auto_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disabled = "ruby" },
		},
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
