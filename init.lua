vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.cursorline = true
vim.o.termguicolors = true

vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- mappings

local map = vim.api.nvim_set_keymap

vim.g.mapleader = ','

-- map('n', '<C-U>j', 'v:count1<Down> zz', {noremap = true})

map('n', '<Leader>f', ':Telescope find_files<CR>', {noremap = true})
map('n', '<Leader>o', ':Telescope oldfiles<CR>', {noremap = true})
map('n', '<Leader>g', ':Telescope live_grep<CR>', {noremap = true})
map('n', '<Leader>s', ':Telescope git_status<CR>', {noremap = true})

map('n', '<Leader>e', ':TroubleToggle<CR>', {noremap = true})

map('n', '<Leader>q', ":NERDTreeToggle<CR>", {noremap = true})

map('n', '<Space>', 'za', {noremap = true, silent = true})
map('n', '<Esc>', ':nohlsearch<CR>', {noremap = true, silent = true})


-- Plugins:

-- Lazy

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {

				{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
        { "rebelot/kanagawa.nvim" },
        'nvim-lualine/lualine.nvim',
        "nvim-tree/nvim-web-devicons",
        'MunifTanjim/nui.nvim',

        {"folke/which-key.nvim", event = "VeryLazy",
          init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
          end, opts = {}
        },

        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',

				"mattn/emmet-vim",
        { "nvim-treesitter/nvim-treesitter",  cmd = {"TSUpdate"}},
        "folke/trouble.nvim",
        "nvimtools/none-ls.nvim",
        "preservim/nerdtree",

				"tpope/vim-surround",
				"mhinz/vim-startify",
				"tpope/vim-commentary",

				"APZelos/blamer.nvim",

				"jbyuki/instant.nvim",

        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        { "adalessa/laravel.nvim",
            cmd = {"Sail", "Artisan", "Composer", "Npm", "Laravel"},
            event = { "VeryLazy" },
            config = true

        },
        "mfussenegger/nvim-dap",

        "folke/neodev.nvim",
        "neovim/nvim-lspconfig",
        "hinell/lsp-timeout.nvim",
        "tpope/vim-dotenv",

        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',

        'L3MON4D3/LuaSnip',

        'VonHeikemen/lsp-zero.nvim',

        "alexghergh/nvim-tmux-navigation",

        "jbyuki/instant.nvim",

        -- Mine:
        {dir = "~/Documents/Reps/todo_neovim/"},
        -- {dir = "~/Documentos/win_dev_nvim"},
}


require("lazy").setup(plugins)

-- Blamer

vim.g.blamer_enabled = 1
vim.g.blamer_delay = 2000


-- trouble

require("trouble").setup( {
    signs = {
      -- icons / text used for a diagnostic
      error = " ",
      warning = " ",
      hint = " ",
      information = " ",
      other = " ",
    },

    use_diagnostic_signs = true,
})

-- tree

-- treesitter

require'nvim-treesitter.configs'.setup {

    ensure_installed = "all",
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true
    }

}

-- neodev

require("neodev").setup({})


-- lsp Zero

local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)


-- mason

local on_attach = function (_, _)
    map('n', '<leader>rn', vim.lsp.buf.rename, {noremap = true})
    map('n', '<leader>co', vim.lsp.buf.code_action, {noremap = true})

    map('n', 'gd', vim.lsp.buf.definition, {noremap = true})
    map('n', 'gi', vim.lsp.buf.implementation, {noremap = true})
    map('n', 'gr', require('telescope').lsp_reference, {noremap = true})
end

require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
        require('lspconfig').lua_ls.setup({
            on_attach = on_attach,
            settings = {
                Lua = {
                    completion = {
                        callSnippet = "Replace"
                    }
                }
            }
        })
	  end,
  }
})


vim.g.lspTimeoutConfig = {

    stopTimeout = 1000 * 60 * 5,
    startTimeout = 1000 * 10,
    silent = false,
    filetypes = {
        ignore = {

        }
    }

}



-- cmp

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup(
    {

        snippet = {

            expand = function (args)
                require('luasnip').lsp_expand(args.body)
            end
        },
        window = {

            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),

        },
        mapping = cmp.mapping.preset.insert({

            ['<CR>'] = cmp.mapping.confirm({select = true}),
            ['<C-Space>'] = cmp.mapping.complete(),

            ['<Tab>'] = cmp.mapping.select_next_item(),
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),

            ['C-u'] = cmp.mapping.scroll_docs(-4),
            ['C-d'] = cmp.mapping.scroll_docs(4),

        }),

        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'luasnip' },
            { name = 'mason' }
        }, {
            { name = 'buffer' },
            { name = 'path' },
            { name = 'luasnip' },
            { name = 'mason' }
        })
        }

)

cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
})

-- nvim-dap

local dap = require('dap')

dap.adapters = {

    c = {

        type = 'executable',
        attach = {
            pidProperty = "pid",
            pidSelect = "ask"
        },

    }

}

dap.configurations = {

    c = {

        type = 'c',
        request = 'attach',
        name = "debug",
        program = "{$file}"

    }

}


-- tmux integration

require('nvim-tmux-navigation').setup {
    disable_when_zoomed = true,
    keybindings = {
        left = "<C-h>",
        down = "<C-j>",
        up = "<C-k>",
        right = "<C-l>",
        last_active = "<C-\\>",
        next = "<C-Space>",
    }
}

-- todo.nvim

require('todo_nvim').setup()


-- catppuccin

-- require("catppuccin").setup(
--     {flavour = "mocha"}
-- )

-- vim.cmd.colorscheme "catppuccin"
require('kanagawa').load('dragon')

-- Lua Line

require('lualine').setup(
    {
        options = {theme = 'auto'},
    }
)

-- instant 

vim.g.instant_username = "ChrisArthLisboa"
