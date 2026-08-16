return {
	{ "tpope/vim-sleuth" },
	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons", "AndreM222/copilot-lualine" },
		config = function()
			require("lualine").setup({
				sections = {
					lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
				},
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			icons = {
				mappings = true,
				keys = {},
			},
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
}
