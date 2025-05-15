vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Settings ]] --
require("config.settings_setup")

-- [[ Basic Keymaps ]] --
require("config.keymaps_setup")

-- require("config.win_config")
require("config.lazy")

-- [[ Configure Treesitter ]] --
-- vim.defer_fn(function()
--   require('nvim-treesitter.configs').setup {
--     ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'vim', 'bash', 'vimdoc', 'php', 'sql', 'terraform', 'javascript', 'typescript', 'tsx', 'html', 'css', 'json', 'toml', 'svelte' },
--     auto_install = false,
--     highlight = { enable = true },
--     indent = { enable = true },
--     incremental_selection = {
--       enable = true,
--       keymaps = {
--         init_selection = '<leader>pti',
--         node_incremental = '<leader>ptn',
--         scope_incremental = '<leader>pts',
--         node_decremental = '<leader>ptd',
--       },
--     },
--     textobjects = {
--       select = {
--         enable = true,
--         lookahead = true,
--         keymaps = {
--           ['aa'] = '@parameter.outer',
--           ['ia'] = '@parameter.inner',
--           ['af'] = '@function.outer',
--           ['if'] = '@function.inner',
--           ['ac'] = '@class.outer',
--           ['ic'] = '@class.inner',
--         },
--       },
--       move = {
--         enable = true,
--         set_jumps = true,
--         goto_next_start = {
--           [']m'] = '@function.outer',
--           [']]'] = '@class.outer',
--         },
--         goto_next_end = {
--           [']M'] = '@function.outer',
--           [']['] = '@class.outer',
--         },
--         goto_previous_start = {
--           ['[m'] = '@function.outer',
--           ['[['] = '@class.outer',
--         },
--         goto_previous_end = {
--           ['[M'] = '@function.outer',
--           ['[]'] = '@class.outer',
--         },
--       },
--       swap = {
--         enable = true,
--         swap_next = {
--           ['<leader>a'] = '@parameter.inner',
--         },
--         swap_previous = {
--           ['<leader>A'] = '@parameter.inner',
--         },
--       },
--     },
--   }
-- end, 0)
--
--[[ noise setup ]]
-- require('noise_setup')
-- vim: ts=2 sts=2 sw=2 et
