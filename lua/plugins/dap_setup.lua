return {
	"mfussenegger/nvim-dap",
	-- Lazy triggers. Without these the whole stack — dap, dap-ui, mason-nvim-dap,
	-- telescope-dap, dap-virtual-text, dap-go and nvim-nio — initialises on every
	-- launch in every project. The real keymaps are set in config() below; these
	-- entries only load the plugin and then replay the key.
	keys = {
		{ "<F5>", desc = "Debug: Start/Continue" },
		{ "<F1>", desc = "Debug: Step Into" },
		{ "<F2>", desc = "Debug: Step Over" },
		{ "<F3>", desc = "Debug: Step Out" },
		{ "<F7>", desc = "Debug: See last session result" },
		{ "<leader>b", desc = "Debug: Toggle BreakPoint" },
		{ "<leader>B", desc = "Debug: Set Breakpoint" },
	},
	-- Entering through a command rather than a key has to work too.
	cmd = {
		"DapContinue",
		"DapToggleBreakpoint",
		"DapToggleRepl",
		"DapStepOver",
		"DapStepInto",
		"DapStepOut",
		"DapTerminate",
		"DapShowLog",
	},
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"mason-org/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		"nvim-telescope/telescope.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		-- install debugers here
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("telescope").load_extension("dap")
		require("nvim-dap-virtual-text").setup({})

		require("mason-nvim-dap").setup({
			automatic_installation = true,
			handlers = {},
			ensure_installed = {
				"delve",
			},
		})

		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle BreakPoint" })
		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Debug: Set Breakpoint" })

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })
		vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Install golang specific config
		require("dap-go").setup({})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
