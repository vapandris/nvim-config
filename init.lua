-- -- -- -- -- -- -- --
-- Basic vim options --
vim.g.have_nerd_font = true

vim.opt.scrolloff = 10
vim.opt.number = true
vim.opt.relativenumber = true

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
            { "<space>f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        }
    },
    -- Good to have:
    { 'tpope/vim-sleuth' },
    {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.surround').setup()
            require('mini.statusline').setup { use_icons = vim.g.have_nerd_font }
        end
    },
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        opts = {
            delay = 150,
            mappings = vim.g.have_nerd_font,
            keys = {},
        },
        spec = {
        }
    },

})
