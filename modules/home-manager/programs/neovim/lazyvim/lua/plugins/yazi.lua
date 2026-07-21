return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>o",
      "<cmd>Yazi<cr>",
      desc = "Open yazi (Directory of Current File)",
    },
    {
      "<leader>O",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi (cwd)",
    },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      -- match the "S"/"V" split keybindings previously used with mini.files
      open_file_in_horizontal_split = "S",
      open_file_in_vertical_split = "V",
    },
  },
}
