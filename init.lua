vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',

  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    init = function ()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  { 'numToStr/Comment.nvim', opts = {}, lazy = false },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '-' },
        changedelete = { text = '~' },
      },
    },
  },

  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  {
    'nvim-telescope/telescope.nvim',
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
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },

  { 'natecraddock/workspaces.nvim', opts = {} },
}, {
  install = {
    colorscheme = { 'catppuccin-late' }
  }
});

vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      }
    }
  }
})

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'workspaces')

vim.defer_fn(function()
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'lua', 'rust', 'tsx', 'javascript', 'typescript', 'vim' },
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
  })
end, 0)

local on_attach = function(_, bufnr)
  require('which-key').register({
    i = { require('telescope.builtin').lsp_implementations, "Goto implementation" },
    r = { require('telescope.builtin').lsp_references, "Goto references" },
    d = { vim.lsp.buf.definition, "Goto definition" },
    t = { vim.lsp.buf.type_definition, "Type definition" },
  }, {
    prefix = "<leader>c",
    buffer = bufnr,
    name = "code",
  })

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

require('which-key').register({
  ["<space>"] = { "<cmd>Telescope buffers<cr>", "List buffers" },
  ["/"] = {
    function ()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end,
    "Fuzzy search in current buffer"
  },
  f = {
    name = "file",
    f = { "<cmd>Telescope find_files<cr>", "Find file" },
    r = { "<cmd>Telescope oldfiles<cr>", "Find recent files", noremap = false },
    n = { "<cmd>enew<cr>", "New File" },
    s = { "<cmd>w<cr>", "Save file" },
  },
  c = {
    name = "code",
    a = { vim.lsp.buf.code_action, "Code Action" },
    r = { vim.lsp.buf.rename, "Rename" },
    s = {
      name = "symbols",
      d = { require('telescope.builtin').lsp_document_symbols, "Document symbols" },
      w = { require('telescope.builtin').lsp_dynamic_workspace_symbols, "Workspace symbols" },
    },
  },
  q = {
    name = "quit",
    q = { "<cmd>qa!<CR>", "Quit all (will lose everything)", noremap = false },
    a = { "<cmd>qa<CR>", "Quit all", noremap = false  }
  },
  h = {
    name = "help",
    c = {
      function()
        local config_file = vim.fn.expand("$HOME/.config/nvim/init.lua")
        vim.cmd.edit(config_file)
      end,
      "Open config file"
    },
  }
}, { prefix = "<leader>" })

-- TODO: Fix this to use the Option macOS key
local modes = {
  n = { pre = "", op = { up = ".", down = "." }, pos = "==" },
  i = { pre = "<Esc>", op = { up = ".", down = "." }, pos = "==gi" },
  v = { pre = "", op = { up = "'>", down = "'<" }, pos = "gv=gv" },
}
for mode, opts in pairs(modes) do
  vim.keymap.set(mode, '<S-j>', opts.pre .. ":m " .. opts.op.down .. "+1<CR>" .. opts.pos, { silent = true, noremap = true })
  vim.keymap.set(mode, '<S-Down>', opts.pre .. ":m " .. opts.op.down .. "+1<CR>" .. opts.pos, { silent = true, noremap = true })
  vim.keymap.set(mode, '<S-k>', opts.pre .. ":m " .. opts.op.up .. "-2<CR>" .. opts.pos, { silent = true, noremap = true })
  vim.keymap.set(mode, '<S-Up>', opts.pre .. ":m " .. opts.op.up .. "-2<CR>" .. opts.pos, { silent = true, noremap = true })
end

require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

require('catppuccin').setup({
  flavour = "latte",
  integrations = {
    neotree = true,
    gitsigns = true,
    mason = true,
    treesitter = true,
    telescope = true,
  },
})

vim.cmd [[colorscheme catppuccin]]

require('workspaces').setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et:
