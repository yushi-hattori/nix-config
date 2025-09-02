return {
  "echasnovski/mini.nvim",
  version = false,
  keys = {
    { "<leader>fm", false },
    {
      "<leader>o",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>O",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
  config = function()
    require("mini.files").setup({})
  end,
}
