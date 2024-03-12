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

map('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
map('n', '<Leader>f', ':Files<CR>', {noremap = true})
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
        'nvim-lualine/lualine.nvim',
        'ryanoasis/vim-devicons',

				"junegunn/fzf",
				"junegunn/fzf.vim",

				"mattn/emmet-vim",
        { "nvim-treesitter/nvim-treesitter",  cmd = {"TSUpdate"}},

				"tpope/vim-surround",
				"mhinz/vim-startify",
				"tpope/vim-commentary",
				"jiangmiao/auto-pairs",

				"APZelos/blamer.nvim",

				"jbyuki/instant.nvim",

        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        "folke/neodev.nvim",
        "neovim/nvim-lspconfig",
        "hinell/lsp-timeout.nvim",
        
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/nvim-cmp',

        'L3MON4D3/LuaSnip',

        'VonHeikemen/lsp-zero.nvim'
}


require("lazy").setup(plugins)

-- Blamer

vim.g.blamer_enabled = 1
vim.g.blamer_delay = 2000


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
            { name = 'luasnip' },
        }), {
            {name = 'buffer'}
        }
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


-- catppuccin

vim.cmd.colorscheme "catppuccin"

-- Lua Line

require('lualine').setup(
    {
        options = {theme = 'horizon'},
    }
)
