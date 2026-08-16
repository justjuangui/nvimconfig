return {
	"stevearc/conform.nvim",
	-- Manual formatting only, so <leader>fd is the lazy trigger. No BufWritePre
	-- event: that loaded the plugin on the first save of every session for nothing.
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>fd",
			function()
				require("conform").format({ async = false, lsp_fallback = true })
			end,
			mode = "",
			desc = "[F]ormat [D]ocument",
		},
	},
	opts = {
		default_format_opts = {
			lsp_format = "fallback",
		},
		notify_on_error = true,
		-- Deliberately manual: format with <leader>fd, never on write.
		format_on_save = nil,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			svelte = { "prettier" },
			terraform = { "terraform_fmt" },
			hcl = { "terragrunt_hclfmt" },
			yaml = { "yamlfmt" },
			php = { "php_cs_fixer" },
			go = { "goimports", "gofumpt", "golines" },
		},
	},
}
