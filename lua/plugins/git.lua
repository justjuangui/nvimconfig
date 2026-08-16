return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			-- Fills the [G]it [H]unk group declared in which-key. gitsigns ships no
			-- default keymaps, so without these the group opens empty.
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, keys, func, desc, extra)
					local o = vim.tbl_extend("force", { buffer = bufnr, desc = "Git: " .. desc }, extra or {})
					vim.keymap.set(mode, keys, func, o)
				end

				-- navigation. nav_hunk, not the deprecated next_hunk/prev_hunk.
				-- expr so the built-in ]c / [c still work inside a real diff.
				map("n", "]c", function()
					if vim.wo.diff then return "]c" end
					vim.schedule(function() gs.nav_hunk("next") end)
					return "<Ignore>"
				end, "Next hunk", { expr = true })
				map("n", "[c", function()
					if vim.wo.diff then return "[c" end
					vim.schedule(function() gs.nav_hunk("prev") end)
					return "<Ignore>"
				end, "Previous hunk", { expr = true })

				-- stage_hunk toggles on staged signs, so no undo_stage_hunk needed.
				map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "[S]tage hunk")
				map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "[R]eset hunk")
				map("n", "<leader>hS", gs.stage_buffer, "[S]tage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "[R]eset buffer")
				map("n", "<leader>hp", gs.preview_hunk, "[P]review hunk")
				map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "[B]lame line")
				map("n", "<leader>hd", gs.diffthis, "[D]iff against index")
				map("n", "<leader>hq", gs.setqflist, "Hunks to [Q]uickfix")
			end,
		},
	},
	{
		"tpope/vim-fugitive",
	},
	{ "tpope/vim-rhubarb" },
}
