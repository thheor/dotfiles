return {
  -- 1. Disable native LSP servers (TypeScript & Astro) so they don't clash with CoC
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Native TypeScript servers
        vtsls = { enabled = false },
        tsserver = { enabled = false },
        typescript = { enabled = false },
        tsgo = { enabled = false },
        -- Native Astro server
        astro = { enabled = false },
      },
    },
  },

  -- 2. Disable blink.cmp in JS, TS, and Astro files
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      enabled = function()
        local disabled_fts = {
          javascript = true,
          typescript = true,
          typescriptreact = true,
          astro = true,
        }
        return not disabled_fts[vim.bo.filetype]
      end,
    },
  },

  -- 3. Disable nvim-cmp in JS, TS, and Astro files
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local original_enabled = opts.enabled
      local disabled_fts = {
        javascript = true,
        typescript = true,
        typescriptreact = true,
        astro = true,
      }
      opts.enabled = function()
        if disabled_fts[vim.bo.filetype] then
          return false
        end
        if type(original_enabled) == "function" then
          return original_enabled()
        elseif original_enabled ~= nil then
          return original_enabled
        end
        return true
      end
    end,
  },

  -- 4. Load coc.nvim for JS/TS/Astro buffers and apply keymaps
  {
    "neoclide/coc.nvim",
    branch = "release",
    ft = { "javascript", "typescript", "typescriptreact", "astro" },
    init = function()
      -- Automatically install necessary CoC extensions if not already present
      vim.g.coc_global_extensions = vim.list_extend(vim.g.coc_global_extensions or {}, {
        "@yaegassy/coc-astro",
        "@yaegassy/coc-tailwindcss3",
        "coc-tsserver",
      })
    end,
    config = function()
      local target_fts = { "javascript", "typescript", "typescriptreact", "astro" }

      local function setup_buffer(bufnr)
        local opts = { silent = true, noremap = true, expr = true, buffer = bufnr }
        local keymap = vim.keymap.set

        -- CoC completion keymaps
        keymap("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<TAB>"', opts)
        keymap("i", "<S-TAB>", 'coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"', opts)
        keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

        -- Navigation keymaps
        local normal_opts = { silent = true, buffer = bufnr }
        keymap("n", "gd", "<Plug>(coc-definition)", normal_opts)
        keymap("n", "gy", "<Plug>(coc-type-definition)", normal_opts)
        keymap("n", "gi", "<Plug>(coc-implementation)", normal_opts)
        keymap("n", "gr", "<Plug>(coc-references)", normal_opts)

        -- Documentation hover
        _G.show_docs = function()
          local cw = vim.fn.expand("<cword>")
          if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
            vim.api.nvim_command("h " .. cw)
          elseif vim.fn["coc#rpc#ready"]() then
            vim.fn.CocActionAsync("doHover")
          else
            vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
          end
        end
        keymap("n", "K", "<CMD>lua _G.show_docs()<CR>", normal_opts)
      end

      -- Attach keymaps when entering an Astro/TS/JS buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = target_fts,
        callback = function(args)
          setup_buffer(args.buf)
        end,
      })

      -- Attach to current buffer if already loaded on one of these filetypes
      local current_buf = vim.api.nvim_get_current_buf()
      if vim.tbl_contains(target_fts, vim.bo[current_buf].filetype) then
        setup_buffer(current_buf)
      end
    end,
  },
}
