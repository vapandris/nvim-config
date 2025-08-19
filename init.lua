-- -- -- -- -- -- -- --
-- Basic vim options --
vim.g.have_nerd_font = true

vim.opt.scrolloff = 10
vim.wo.number = true
vim.wo.relativenumber = true
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
vim.keymap.set("n", "<space>tr", function()
    if vim.wo.number then
        vim.wo.relativenumber = not vim.wo.relativenumber
    end
end, { desc = "[T]oggle [R]elative numbers" })

vim.keymap.set("n", "<space>tn", function()
    if vim.wo.number == true then
        vim.wo.number = false
        vim.wo.relativenumber = true
    else
        vim.wo.number = true
        vim.wo.relativenumber = false
    end
    vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "[T]oggle [R]elative numbers" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "s", "", { noremap = true, silent = true, desc = "Disable s (substitude) key"} )
vim.keymap.set("n", "*", "*N", {noremap = true, silent = true, desc = "Don't jump to next result when searching ofr current word"})
-- vim.keymap.set("v", "*", "*N", {noremap = true, silent = true, desc = "Don't jump to next result when searching ofr current word"})

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

local servers = {
    -- clangd = {},
    ols = {},
    lua_ls = {},
}

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
    { 'nvim-treesitter/nvim-treesitter-context' },
    -- LSP:
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'saghen/blink.cmp' },

        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('nvim-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
                    end

                    local client_supports_method = function(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    map('gd', require('telescope.builtin').lsp_definitions,     'LSP: [G]oto [D]efinition')
                    map('gr', require('telescope.builtin').lsp_references,      'LSP: [G]oto [R]eferences')
                    map('gI', require('telescope.builtin').lsp_implementations, 'LSP: [G]oto [I]mplementation')
                    map('gD', vim.lsp.buf.declaration,                          'LSP: [G]oto [D]eclaration')
                    map('<space>r', vim.lsp.buf.rename,                         'LSP: [R]ename')

                    map('<space>sD', require('telescope.builtin').diagnostics,                   '[S]earch [D]iagnostics')
                    map('<space>sd', require('telescope.builtin').lsp_document_symbols,          '[S]earch [D]ocument symbols')
                    map('<space>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace symbols')

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        vim.lsp.inlay_hint.enable(true)
                        map('<space>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle (parameter) [H]ints')
                    end
                end
            })

            for server, config in pairs(servers) do
                config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
                require('lspconfig')[server].setup(config)
            end

            local signs = {}
            if vim.g.have_nerd_font then
                signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
            else
                signs = { ERROR = 'X', WARN = '!', INFO = 'i', HINT = '?' }
            end

            local diag_signs = {}
            for type, icon in pairs(signs) do
                diag_signs[vim.diagnostic.severity[type]] = icon
            end

            vim.diagnostic.config {
                signs = { text = diag_signs },
                severity_sort = true,
                float = { border = 'rounded', source = 'if_many' },
                underline = { severity = vim.diagnostic.severity.ERROR },
                virtual_text = {
                    source = 'if_many',
                    spacing = 2,
                    format = function(diag)
                        local diag_msg = {
                            [vim.diagnostic.severity.ERROR] = diag.message,
                            [vim.diagnostic.severity.WARN] = diag.message,
                            [vim.diagnostic.severity.INFO] = diag.message,
                            [vim.diagnostic.severity.HINT] = diag.message,
                        }
                        return diag_msg[diag.severity]
                    end,
                },
            }
        end
    },
    { 'williamboman/mason.nvim', opts = {} },
    {
        'williamboman/mason-lspconfig',
        config = function()
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

            local lspconfig = require 'lspconfig'
            lspconfig.clangd.setup {
                capabilities = { offsetEncoding = 'utf-8' },
                -- cmd = { "/bin/bash", "-c", "BUILD_CONFIGS=${BUILD_CONFIGS:-'Linux_x86_64.debug'} /app/epg/tools/bin/wsclangd" },
                singleFileSupport = true,
            }
        end
    },
    {
        'folke/lazydev.nvim',
        ft = "lua",
        opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
    },
    {
        'saghen/blink.cmp',
        dependencies = { 'rafamadriz/friendly-snippets' },
        version = '*',

        opts = {
            keymap = { preset = 'default' },
            appearance = {
                nerd_font_variant = 'mono',
            },
            fuzzy = { implementation = 'lua' }
        },
        opts_extend = { 'sources.default' },
    },
    -- Git shtuff:
    {
        'lewis6991/gitsigns.nvim',
        opts = {
        signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = 'x' } },
        signs_staged = { add = { text = '┃' }, change = { text = '┃' }, delete = { text = '┃' } },
        },
    },
    {
        'sindrets/diffview.nvim',
        config = function ()
            vim.keymap.set('n', '<space>do', '<cmd>DiffviewOpen<CR>',           { desc = '[D]iffview [O]pen'})
            vim.keymap.set('n', '<space>dc', '<cmd>DiffviewClose<CR>',          { desc = '[D]iffview [C]lose'})
            vim.keymap.set('n', '<space>df', '<cmd>DiffviewFileHistory<CR>',    { desc = '[D]iffview [F]ileHistory'})
            vim.keymap.set('n', '<space>dt', '<cmd>DiffviewToggleFiles<CR>',    { desc = '[D]iffview [T]oggle'})

            vim.keymap.set('n', '<space>gb', '<cmd>Gitsigns blame_line<CR>',    { desc = '[G]it [B]lame'})

            vim.keymap.set("n", "<M-b>", "<cmd>DiffviewToggleFiles<CR>",        { desc = 'Toggle the left bar in Diffview'})
        end
    },
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
            require('telescope').setup {
                extensions = { fzf = {} }
            }

            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<space>sf', builtin.find_files,    { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<space>sr', builtin.resume,        { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<space>sb', builtin.buffers,       { desc = '[S]earch [B]uffers' })
            vim.keymap.set('n', '<space>sh', builtin.help_tags,     { desc = "[S]earch [H]elp"})

            vim.keymap.set('n', '<space>/', function()
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {})
            end, { desc = 'Search in current buffer' })

            vim.keymap.set('n', '<space>sg',
                function ()
                    local opts = { cwd = vim.uv.cwd() }

                    local finder = require("telescope.finders").new_async_job {
                        command_generator = function (prompt)
                            if not prompt or prompt == "" then
                                return nil
                            end

                            local pieces = vim.split(prompt, "  ")
                            local cmd = { "rg" }
                            if pieces[1] then
                                table.insert(cmd, "-e")
                                table.insert(cmd, pieces[1])
                            end

                            if pieces[2] then
                                table.insert(cmd, "-g")
                                table.insert(cmd, pieces[2])
                            end

                            ---@diagnostic disable-next-line: deprecated
                            return vim.tbl_flatten {
                                cmd,
                                { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
                            }
                        end,
                        entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts),
                        cwd = opts.cwd,
                    }
                    require("telescope.pickers").new(opts, {
                        debaunce = 100,
                        prompt_title = "Find Text in *.file-types",
                        finder = finder,
                        previewer = require("telescope.config").values.grep_previewer(opts),
                        sorter = require("telescope.sorters").empty()
                    }):find()
                end,
                { desc = '[S]earch [G]rep' })
        end
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function ()
            require('oil').setup {
                default_file_explorer = true,
                columns = { 'icon' },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<C-y>"] = "actions.select"
                },
                view_options = {
                    show_hidden = true,
                }
            }

            vim.keymap.set('n', '-', "<cmd>Oil<CR>", { desc = 'Open parent directoy' })
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
                { '<space>d', group = '[D]iffview for Git'},
                { '<space>g', group = '[G]it'},
                { '<space>t', group = '[T]oggle'},
            }
        },
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
    }
})
