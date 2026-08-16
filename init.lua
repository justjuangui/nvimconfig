vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Settings ]] --
require("config.settings_setup")

-- [[ Basic Keymaps ]] --
require("config.keymaps_setup")

-- PowerShell shell settings; a no-op everywhere but Windows.
if vim.fn.has("win32") == 1 then
	require("config.win_config")
end

require("config.lazy")

require("config.lsp")

require("config.vulkan")
-- vim: ts=2 sts=2 sw=2 et
