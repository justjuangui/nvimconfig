vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Settings ]] --
require("config.settings_setup")

-- [[ Basic Keymaps ]] --
require("config.keymaps_setup")

-- require("config.win_config")
require("config.lazy")

require("config.lsp")
-- vim: ts=2 sts=2 sw=2 et
