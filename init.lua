-- -- -- -- -- -- -- --
-- Basic vim options --
vim.g.have_nerd_font = true

vim.opt.scrolloff = 10
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.opt.mouse = "a"

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "┆ ", trail = "·", nbsp = "␣" }
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.opt.cursorline = true
vim.opt.colorcolumn = "120"
vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes"

-- -- -- -- -- -- -- --
-- Basic vim keymaps --
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<M-k>", "[c", { desc = "Goto next diff" })
vim.keymap.set("n", "<M-j>", "]c", { desc = "Goto prev diff" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-f>", ":%s/", { desc = "Find & replace" })

vim.keymap.set("n", "<space>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "[T]oggle [W]rap" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


-- Autocmd to highlight after yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- -- -- -- -- -- --
-- Plugins & Lazy --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Colorscheme:
    {
        'Tsuzat/NeoSolarized.nvim',
        config = function()
            local ok_status, NeoSolarized = pcall(require, "NeoSolarized")
            if not ok_status then
              return
            end

            NeoSolarized.setup {
                style = "dark",
                transparent = false,
                terminal_colors = true,
                enable_italics = true,
                styles = {
                    comments = { italic = true },
                    keywords = { bold = true },
                    functions = { bold = true },
                    variables = {},
                    string = { italic = true },
                },
            }
            vim.cmd.colorscheme("NeoSolarized")
        end
    },
    -- Treesitter:
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = { 'bash', 'c', 'odin', 'diff', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
    -- LSP:
    {
        'neovim/nvim-lspconfig',
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('nvim-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
                    end

                    map('gd', require('telescope.builtin').lsp_definitions,     'LSP: [G]oto [D]efinition')
                    map('gr', require('telescope.builtin').lsp_references,      'LSP: [G]oto [R]eferences')
                    map('gI', require('telescope.builtin').lsp_implementations, 'LSP: [G]oto [I]mplementation')
                    map('gD', vim.lsp.buf.declaration,                          'LSP: [G]oto [D]eclaration')
                    map('<space>r', vim.lsp.buf.rename,                         'LSP: [R]ename')

                    map('<space>sD', require('telescope.builtin').diagnostics,                   '[S]earch [D]iagnostics')
                    map('<space>sd', require('telescope.builtin').lsp_document_symbols,          '[S]earch [D]ocument symbols')
                    map('<space>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace symbols')
                end
            })

            if vim.g.have_nerd_font then
                local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local diag_signs = {}
                for type, icon in pairs(signs) do
                    diag_signs[vim.diagnostic.severity[type]] = icon
                end

                vim.diagnostic.config { signs = { text = diag_signs } }
            end
        end
    },
    { 'williamboman/mason.nvim', opts = {} },
    {
        'williamboman/mason-lspconfig',
        config = function()
            local servers = {
                clangd = {},
                ols = {},
                lua_ls = {},
            }

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                      local server = servers[server_name] or {}

                        require('lspconfig')[server_name].setup(server)
                    end,
                },
                automatic_installation = {},
                ensure_installed = {},
            }
        end
    },
    {
        'folke/lazydev.nvim',
        ft = "lua",
        opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
    },
    -- Git shtuff:
    {
        'lewis6991/gitsigns.nvim',
        opts = {
        signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = 'x' } },
        signs_staged = { add = { text = '┃' }, change = { text = '┃' }, delete = { text = '┃' } },
        },
    },
    { 'sindrets/diffview.nvim' },
    -- Navigation:
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        opts = {},
        keys = {
            { "<space>f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "[F]lash: Jump on screen" },
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-telescope/telescope-fzf-native.nvim' },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            require('telescope').setup {}

            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<space>sf', builtin.find_files,    { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<space>st', builtin.live_grep,     { desc = '[S]earch [T]ext' })
            vim.keymap.set('n', '<space>sr', builtin.resume,        { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<space>sb', builtin.buffers,       { desc = '[S]earch [B]uffers' })
            vim.keymap.set('n', '<space>sh', builtin.help_tags,     { desc = "[S]earch [H]elp"})

            vim.keymap.set('n', '<space>/', function()
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {})
            end, { desc = 'Search in current buffer' })
        end
    },
    -- Good to have:
    { 'tpope/vim-sleuth' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.surround').setup()
            require('mini.statusline').setup { use_icons = vim.g.have_nerd_font }

            vim.schedule(function()
                vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { link = 'Directory' })
                vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { link = 'Directory' })
                vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { link = 'Directory' })
            end)
        end
    },
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        opts = {
            delay = 150,
            icons = { mappings = vim.g.have_nerd_font },
            keys = {},
            spec = {
                { '<space>s', group = '[S]earch'},
                { '<space>t', group = '[T]oggle'},
            }
        },
    },

})
