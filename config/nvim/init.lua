-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  Neovim — Cyberpunk Glassmorphic Configuration              ║
-- ║  Optimized for blazing fast developer experience            ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ═══════════════════════════════════════════════════════════════
-- Performance: Disable unused providers
-- ═══════════════════════════════════════════════════════════════
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_pack = 1

-- ═══════════════════════════════════════════════════════════════
-- Filetype detection for subtypes
-- ═══════════════════════════════════════════════════════════════
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    ["%.helm%-values%.ya?ml$"] = "yaml.helm-values",
    ["%.gitlab%-ci%.ya?ml$"] = "yaml.gitlab",
  },
})

-- ═══════════════════════════════════════════════════════════════
-- Settings: Blazing fast + Modern
-- ═══════════════════════════════════════════════════════════════
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs/Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 10
opt.wrap = false
opt.showmode = false
opt.fillchars = { eob = " " }
opt.shortmess:append("I")
opt.conceallevel = 2

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Clipboard
opt.clipboard = "unnamedplus"

-- Mouse
opt.mouse = "a"

-- Files
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Complete
opt.completeopt = "menu,menuone,noselect"

-- ═══════════════════════════════════════════════════════════════
-- Keymaps: Blazing Fast Workflows
-- ═══════════════════════════════════════════════════════════════
local map = vim.keymap.set

-- Quick actions
map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit" })
map("n", "<leader>x", ":wq<CR>", { desc = "Save & quit" })
map("n", "<leader>L", ":Lazy<CR>", { desc = "Lazy" })
map("n", "<leader>M", ":Mason<CR>", { desc = "Mason" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- Move windows
map("n", "<A-h>", "<C-w>H", { desc = "Move window left" })
map("n", "<A-j>", "<C-w>J", { desc = "Move window down" })
map("n", "<A-k>", "<C-w>K", { desc = "Move window up" })
map("n", "<A-l>", "<C-w>L", { desc = "Move window right" })

-- Buffer navigation
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bp", ":BufferLineTogglePin<CR>", { desc = "Pin buffer" })

-- Visual indent
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Clear search
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlight" })

-- Centered scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Better paste
map("x", "<leader>p", '"_dP', { desc = "Paste without yank" })
map("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- File explorer
map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>E", ":Neotree focus<CR>", { desc = "Focus file explorer" })

-- Better split
map("n", "<leader>\\", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical split" })

-- Terminal
map("n", "<leader>T", ":terminal<CR>", { desc = "Open terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Jump to start/end of line
map("n", "H", "^", { desc = "Start of line" })
map("n", "L", "$", { desc = "End of line" })

-- ═══════════════════════════════════════════════════════════════
-- Plugins
-- ═══════════════════════════════════════════════════════════════
require("lazy").setup({
  -- ── Theme ──────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          telescope = { enabled = true },
          neotree = true,
          mini = { enabled = true },
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ── File Explorer ──────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
        window = {
          width = 30,
          mappings = {
            ["<space>"] = "none",
          },
        },
      })
    end,
  },

  -- ── Treesitter ─────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "css", "dockerfile", "go", "html",
          "javascript", "json", "lua", "markdown", "markdown_inline",
          "python", "rust", "toml", "tsx", "typescript", "vim",
          "vimdoc", "yaml", "regex", "sql",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ── Telescope ──────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "target/", "dist/" },
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          path_display = { "truncate" },
        },
      })
      telescope.load_extension("fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Grep string" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
    end,
  },

  -- ── LSP ────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "ts_ls", "pyright", "rust_analyzer", "gopls",
            "html", "cssls", "jsonls", "yamlls",
            "bashls", "dockerls", "lua_ls",
          },
          automatic_installation = true,
        },
      },
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local on_attach = function(_, bufnr)
        local bmap = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end
        bmap("gd", vim.lsp.buf.definition, "Go to definition")
        bmap("gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("gi", vim.lsp.buf.implementation, "Go to implementation")
        bmap("gr", vim.lsp.buf.references, "References")
        bmap("K", vim.lsp.buf.hover, "Hover documentation")
        bmap("<C-k>", vim.lsp.buf.signature_help, "Signature help")
        bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
        bmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        bmap("<leader>D", vim.lsp.buf.type_definition, "Type definition")
        bmap("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
        bmap("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
        bmap("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
        bmap("<leader>dl", vim.diagnostic.setloclist, "Diagnostics to loclist")
      end

      local servers = {
        ts_ls = {},
        pyright = {},
        rust_analyzer = {},
        gopls = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
        dockerls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }

      for name, opts in pairs(servers) do
        vim.lsp.config(name, vim.tbl_extend("force", {
          on_attach = on_attach,
          capabilities = capabilities,
        }, opts))
      end

      vim.lsp.enable(vim.tbl_keys(servers))

      -- Completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

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
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(entry, vim_item)
            local kind_icons = {
              Text = "", Function = "", Method = "",
              Constructor = "", Field = "", Variable = "",
              Class = "", Interface = "", Module = "",
              Property = "", Unit = "", Value = "",
              Enum = "", Keyword = "", Snippet = "",
              File = "", Folder = "", EnumMember = "",
              Constant = "", Struct = "", Event = "",
              Operator = "", TypeParameter = "",
            }
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              path = "[Path]",
              buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = { prefix = "", spacing = 4, format = function(diagnostic)
          local icon = { ERROR = "", WARN = "", HINT = "", INFO = "" }
          return icon[diagnostic.severity] .. " " .. diagnostic.message
        end },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  -- ── Git ────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
          map("n", "[c", function() gs.nav_hunk("prev") end, "Prev hunk")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gB", gs.blame_line, "Blame line")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
          map("n", "<leader>gq", function() gs.setqflist("live") end, "Quickfix list")
        end,
      })
    end,
  },

  -- ── Statusline ─────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin-mocha",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Autopairs ──────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = { lua = { "string" }, javascript = { "template_string" } },
      })
      local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok then
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- ── Comments ───────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },

  -- ── Surround ───────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- ── Which-Key ──────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = { enabled = true } },
    },
  },

  -- ── Indent Guides ──────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })
    end,
  },

  -- ── Trouble (Diagnostics) ──────────────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({})
      vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Trouble" })
      vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = "Workspace diagnostics" })
      vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = "Document diagnostics" })
      vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "Quickfix" })
    end,
  },

  -- ── Todo Comments ──────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      require("todo-comments").setup({})
      vim.keymap.set("n", "<leader>ft", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
      vim.keymap.set("n", "<leader>Ft", function() require("todo-comments").jump_prev() end, { desc = "Prev TODO" })
    end,
  },

  -- ── Hop (Better Motion) ────────────────────────────────
  {
    "smoka7/hop.nvim",
    event = "VeryLazy",
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
      vim.keymap.set("n", "<leader>hw", function() require("hop").hint_words() end, { desc = "Hop word" })
      vim.keymap.set("n", "<leader>hl", function() require("hop").hint_lines() end, { desc = "Hop line" })
      vim.keymap.set("n", "<leader>hp", function() require("hop").hint_patterns() end, { desc = "Hop pattern" })
    end,
  },

  -- ── Illuminator (Word Highlight) ───────────────────────
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 200,
        under_cursor = true,
      })
    end,
  },

  -- ── Dashboard ──────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                                     ",
        "            ⚡ Cyberpunk Developer Environment ⚡     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live grep", ":Telescope live_grep<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "  Lazy", ":Lazy<CR>"),
        dashboard.button("m", "  Mason", ":Mason<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"

      alpha.setup(dashboard.config)
    end,
  },

  -- ── Noice (Better Notifications) ───────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- ── Navic (Code Context) ──────────────────────────────
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      require("nvim-navic").setup({
        lsp = { auto_attach = true },
        icons = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
      })
    end,
  },
}, {
  rocks = { enabled = false, hererocks = false },
})

-- ═══════════════════════════════════════════════════════════════
-- Autocommands
-- ═══════════════════════════════════════════════════════════════
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or vim.bo.buftype ~= "" then return end
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Auto resize splits on window resize
autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Disable auto comment on new line
autocmd("BufEnter", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Auto save
autocmd({ "FocusLost", "BufLeave" }, {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})
