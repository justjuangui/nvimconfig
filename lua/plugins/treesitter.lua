return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
  opts = {
    ensure_installed = {
      'c',
      'cpp',
      'go',
      'lua',
      'python',
      'rust',
      'vim',
      'bash',
      'vimdoc',
      'php',
      'sql',
      'terraform',
      'javascript',
      'typescript',
      'tsx',
      'html',
      'css',
      'json',
      'toml',
      'svelte'
    },
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = false, disabled = 'ruby' },
  }
}
