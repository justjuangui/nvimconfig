return {
	init_options = { hostInfo = "neovim" },
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	handlers = {
		['_typescript.rename'] = function(_, result, ctx)
			local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
			vim.lsp.util.show_document({
				uri = result.textDocument.uri,
				range = {
					start = result.position,
					["end"] = result.position,
				},
			}, client.offset_encoding)
			vim.lsp.buf.rename()
		end,
		on_attach = function(client, bufnr)
			vim.api.nvim_buf_create_user_command(bufnr, 'LspTypeScriptSourceAction', function()
				local source_actions = vim.tbl_filter(function(action)
					return vim.startswith(action, 'source.')
				end, client.server_capabilities.codeActionProvider.codeActionKinds)

				vim.lsp.buf.code_action({
					context = {
						only = source_actions,
					},
				})
			end, {})
		end,

	}
}
