return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>fd",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "[F]ormat [D]ocument",
		},
	},
	opts = {
		default_format_opts = {
			lsp_format = "fallback",
		},
		notify_on_error = false,
		format_on_save = nil,
		-- format_on_save = function(bufnr)
		-- 	local disable_filetypes = { c = true, cpp = true }
		-- 	local lsp_format_opt
		-- 	if disable_filetypes[vim.bo[bufnr].filetype] then
		-- 		lsp_format_opt = "never"
		-- 	else
		-- 		lsp_format_opt = "always"
		-- 	end
		-- 	return {
		-- 		timeout_ms = 500,
		-- 		lsp_format = lsp_format_opt,
		-- 	}
		-- end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = {"prettier"},
			typescript = {"prettier"},
			tf = { "terraform_fmt" },
			terraform = { "terraform_fmt" },
			hcl = { "terragrunt_hclfmt" },
			yaml = { "yamlfmt" },
			php = { "php_cs_fixer" }
		},
	},
}
