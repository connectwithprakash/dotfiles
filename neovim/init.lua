-- Bootstrap lazy.nvim (auto-installs on first run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Plugins
-- ============================================================================
require("lazy").setup({
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- Treesitter (syntax highlighting, indentation, text objects)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "css", "dockerfile", "go", "html", "javascript",
          "json", "lua", "markdown", "markdown_inline", "python", "rust",
          "toml", "typescript", "vim", "vimdoc", "yaml",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls", "bashls", "jsonls",
        },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Neovim 0.11+ native LSP configuration. mason-lspconfig v2 enables
      -- installed servers automatically via vim.lsp.enable().
      vim.lsp.config("*", {
        capabilities = capabilities,
      })
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- LSP keybindings (only active when LSP attaches)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", vim.lsp.buf.references, "Find references")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      -- Disable netrw (recommended by nvim-tree)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 35 },
        filters = { dotfiles = false },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = require("catppuccin.utils.lualine")("mocha") },
      })
    end,
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]c", gs.next_hunk, opts)
          vim.keymap.set("n", "[c", gs.prev_hunk, opts)
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
          vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
        end,
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc", mode = "v", desc = "Comment selection" },
    },
    config = true,
  },

  -- Which-key (shows available keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>c", group = "code" },
        { "<leader>e", desc = "Show diagnostic" },
        { "<leader>f", group = "find" },
        { "<leader>h", group = "hunks" },
        { "<leader>r", group = "run/rename" },
      })
    end,
  },
})

-- ============================================================================
-- General Settings
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.completeopt = "menu,menuone,noselect"

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Resize splits with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Open an interactive terminal without leaving Neovim.
vim.keymap.set("n", "<leader>rt", "<cmd>belowright split | resize 15 | terminal<CR>", { desc = "Open terminal" })

-- Run the current file in a split terminal. Saves first, then chooses a runner
-- from the buffer filetype. Press i/a in the terminal to interact, and
-- Ctrl-\\ Ctrl-n to return to normal mode.
local run_current_file = function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Save the buffer to a file before running it", vim.log.levels.WARN)
    return
  end

  vim.cmd.write()

  local escaped_file = vim.fn.shellescape(file)
  local runners = {
    python = "python3 " .. escaped_file,
    javascript = "node " .. escaped_file,
    typescript = "tsx " .. escaped_file,
    sh = "bash " .. escaped_file,
    bash = "bash " .. escaped_file,
    zsh = "zsh " .. escaped_file,
    lua = "lua " .. escaped_file,
    go = "go run " .. escaped_file,
    rust = "cargo run",
    ruby = "ruby " .. escaped_file,
  }

  local command = runners[vim.bo.filetype]
  if not command then
    vim.notify("No runner configured for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  vim.cmd("belowright split")
  vim.cmd("resize 15")
  vim.cmd("terminal " .. command)
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>rr", run_current_file, { desc = "Run current file" })

-- Easier exit from terminal mode.
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
