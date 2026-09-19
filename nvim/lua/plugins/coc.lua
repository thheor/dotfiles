return {
  -- 1. Disable native TypeScript LSP servers so they don't clash with CoC
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable standard TypeScript servers in the native LSP
        vtsls = { enabled = false },
        tsserver = { enabled = false },
        typescript = { enabled = false },
        tsgo = { enabled = false },
      },
    },
  },

  -- 2. Disable blink.cmp (LazyVim's default completion engine) in TypeScript files
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      enabled = function()
        local ft = vim.bo.filetype
        return not (ft == "javascript" or ft == "typescript" or ft == "typescriptreact")
      end,
    },
  },

  -- 3. Disable nvim-cmp (if you are using the cmp extra instead of blink) in TypeScript files
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local original_enabled = opts.enabled
      opts.enabled = function()
        local ft = vim.bo.filetype
        if ft == "typescript" or ft == "typescriptreact" then
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

  -- 4. Load coc.nvim for JS/TS buffers and apply buffer-local keymaps
  {
    "neoclide/coc.nvim",
    branch = "release",
    ft = { "javascript", "typescript", "typescriptreact" }, -- Only load for these filetypes
    config = function()
      local function setup_buffer(bufnr)
        local opts = { silent = true, noremap = true, expr = true, buffer = bufnr }
        local keymap = vim.keymap.set

        -- CoC completion keymaps
        keymap("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<TAB>"', opts)
        keymap("i", "<S-TAB>", 'coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"', opts)
        keymap(
          "i",
          "<CR>",
          [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
          opts
        )

        -- Navigation keymaps
        local normal_opts = { silent = true, buffer = bufnr }
        keymap("n", "gd", "<Plug>(coc-definition)", normal_opts)
        keymap("n", "gy", "<Plug>(coc-type-definition)", normal_opts)
        keymap("n", "gi", "<Plug>(coc-implementation)", normal_opts)
        keymap("n", "gr", "<Plug>(coc-references)", normal_opts)

        -- Use K to show documentation
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "typescriptreact" },
        callback = function(args)
          setup_buffer(args.buf)
        end,
      })

      -- CoC is lazy-loaded by filetype, which happens after this buffer's
      -- FileType event. Configure the buffer that caused the plugin to load.
      local current_buf = vim.api.nvim_get_current_buf()
      if vim.tbl_contains({ "javascript", "typescript", "typescriptreact" }, vim.bo[current_buf].filetype) then
        setup_buffer(current_buf)
      end
    end,
  },
}
