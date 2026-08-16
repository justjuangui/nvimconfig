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
			-- Superset of every binary referenced anywhere in this config:
			-- servers in lsp/*.lua and formatters in plugins/autoformat.lua.
			-- Two tools are deliberately absent, see the note at the bottom.
			ensure_installed = {
				-- language servers
				"lua-language-server",
				"gopls",
				"json-lsp",
				"intelephense",
				"regal",
				"svelte-language-server",
				"yaml-language-server",
				"typescript-language-server",
				"terraform-ls",
				"glsl_analyzer",

				-- linters
				"golangci-lint",
				"golangci-lint-langserver",
				"tflint",

				-- formatters (conform.nvim)
				"stylua",
				"prettier",
				"yamlfmt",
				"php-cs-fixer",
				"goimports",
				"gofumpt",
				"golines",
			},
		},
		-- Not installed here, on purpose:
		--   terraform  — general infra CLI, belongs on the system PATH, not just in nvim
		--   terragrunt — not in the Mason registry at all; install it yourself for
		--                conform's `terragrunt_hclfmt` on hcl files
	},
}
