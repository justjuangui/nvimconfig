return {
	"nvim-neotest/neotest",
	-- The only adapter configured is rustaceanvim's, so there is nothing for neotest
	-- to do outside a Rust buffer. Without this it loaded on every launch and its
	-- config() pulled rustaceanvim's internals in with it.
	ft = "rust",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"mrcjkb/rustaceanvim",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("rustaceanvim.neotest"),
			},
		})
	end,
}
