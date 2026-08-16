vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("justjuangui", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

		local builtin = require("telescope.builtin")
		map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
		map("gr", builtin.lsp_references, "[G]oto [R]eference")
		map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]efinition")

		map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

		map("<leader>wd", builtin.diagnostics, "[W]orkspace [D]iagnostics")

		-- help
		-- K = what is this. gK = what arguments does it take.
		-- Insert mode is already covered: <C-s> is a Neovim global default
		-- (see :help lsp-defaults), and blink.cmp's `default` preset binds <C-k>.
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gK", vim.lsp.buf.signature_help, "Signature Documentation")

		-- other functionality
		map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
		map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
		map("<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "[W]orkspace [L]ist Folders")

		-- Format document
		-- map('<leader>fd', vim.lsp.buf.format, '[F]ormat [D]ocument')

		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

		if client and client.name == "rust-analyzer" then
			local neotest = require("neotest")
			map("<leader>td", function()
				neotest.run.run({ strategy = "dap" })
			end, "Debug nearest rust test")
		end

		-- No vim.lsp.completion.enable() here: blink.cmp owns completion and already
		-- consumes the lsp source. Enabling both makes them race over the same
		-- capability. See lua/plugins/autocompletion.lua.

		if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local highlight_autogroup = vim.api.nvim_create_augroup("justjuangui-lsp-highlight", { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_autogroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_autogroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("justjuangui-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "justjuangui-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[Toggle] Inlay [H]ints")
		end
	end,
})

vim.lsp.enable({
	"gopls",
	"terraformls",
	"lua_ls",
	"phpls",
	"ts_ls",
	"tflint",
	"regalls",
	"jsonls",
	"yamlls",
	"svelte",
	"golangci_lint_ls",
	"glsl_analyzer",
})
