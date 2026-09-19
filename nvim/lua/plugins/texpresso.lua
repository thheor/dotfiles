-- return {
--   {
--     "let-def/texpresso.vim",
--     ft = { "tex" }, -- Lazy-load the plugin only when opening TeX files
--     cmd = { "Texpresso" }, -- Lazy-load when running the :Texpresso command
--     config = function()
--       -- Optional: You can configure keymaps here
--       vim.keymap.set("n", "<leader>tp", "<cmd>Texpresso<cr>", { desc = "Start Texpresso" })
--     end,
--   },
-- }
return {
  {
    "let-def/texpresso.vim",
    ft = { "tex" },
    config = function()
      -- Force Texpresso to use paper colors (White background, Black text)
      vim.g.texpresso_bg = "#ffffff"
      vim.g.texpresso_fg = "#000000"

      -- Optional: Map a key to launch it
      vim.keymap.set("n", "<leader>tp", "<cmd>Texpresso %<cr>", { desc = "Start Texpresso" })
    end,
  },
}
