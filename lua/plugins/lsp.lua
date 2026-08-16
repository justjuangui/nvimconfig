return {
	{
		"saecki/crates.nvim",
		tag = "stable",
		config = function()
			require("crates").setup()
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{ "mason-org/mason.nvim", opts = {} },
	{ "j-hui/fidget.nvim", config = true },
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"golangci-lint",
				"golangci-lint-langserver",
				"gopls",
				"json-lsp",
				"intelephense",
				"regal",
				"yaml-language-server",
				"typescript-language-server",
				"tflint",
				"terraform-ls",
				"glsl_analyzer",
			},
		},
	},
}
