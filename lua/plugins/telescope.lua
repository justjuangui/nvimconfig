return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    local config = require('telescope.config')
    local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }

    -- default show hidden
    table.insert(vimgrep_arguments, "--hidden")

    -- ignore common folders web development
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!{.git/*,.svelte-kit/*,target/*,node_modules/*,.venv/*}")

    -- use defaul linux separator
    table.insert(vimgrep_arguments, "--path-separator")
    table.insert(vimgrep_arguments, "/")

    require('telescope').setup {
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        mappings = {
          i = {
            ['<C-u'] = false,
            ['<C-d'] = false,
          }
        },
        layout_strategy = 'vertical',
        layout_config = {
          vertical = { width = 0.8 }
        }
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = {
            "rg",
            "--files",
            "--glob",
            "!{.git/*,.svelte-kit/*,target/*,node_modules/*,.venv/*}",
            "--path-separator",
            "/"
          }
        }
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown()
        }
      }
    }

    local builtin = require('telescope.builtin')

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
      desc = '[ ] Find existing buffers'
    })

    vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
      desc = '[S]earch [K]eymaps'
    })

    vim.keymap.set('n', '<leader>ss', builtin.builtin, {
      desc = '[S]earch [S]elect telescope'
    })

    vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
      desc = '[S]earch [H]elp'
    })

    vim.keymap.set('n', '<leader>sf', builtin.find_files, {
      desc = '[S]earch [F]iles'
    })

    vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
      desc = '[S]earch by [G]rep'
    })

    vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
      desc = '[S]earch current [W]ord'
    })

    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
      desc = '[S]earch [D]iagnostics'
    })

    vim.keymap.set('n', '<leader>sr', builtin.resume, {
      desc = '[S]earch [R]esume'
    })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        preview = false,
      })
    end, { desc = "[/] Fuzzily search in current buffer" })

    vim.keymap.set('n', '<leader>?', builtin.oldfiles, {
      desc = '[?] Find recently opened files'
    })

    vim.keymap.set('n', '<leader>gs', builtin.git_files, {
      desc = 'Search [G]it [f]iles'
    })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch for [N]eovim files' })

    -- find in root git folder
    local function find_git_root()
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_dir
      local cwd = vim.fn.getcwd()

      if current_file == "" then
        current_dir = cwd
      else
        current_dir = vim.fn.fnamemodify(current_file, ":h")
      end

      local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")
      [1]

      if vim.v.shell_error ~= 0 then
        print("not a git repository. Searching on current working directory")
        return cwd
      end
      print(git_root)
      return git_root
    end

    local function live_grep_git_root()
      local git_root = find_git_root()
      if git_root then
        builtin.live_grep({
          search_dirs = { git_root },
        })
      end
    end

    vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

    vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', {
      desc = '[S]earch on [G]it root'
    })
  end
}
