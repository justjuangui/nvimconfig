return {
  'folke/tokyonight.nvim',
  priotity = 1000,
  init = function()
    vim.cmd.colorscheme 'tokyonight-night'
    vim.cmd.hi 'Comment gui=none'
  end
}
