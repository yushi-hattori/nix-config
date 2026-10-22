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
    -- Render real image previews over yazi's preview column via
    -- snacks.image.placement (see lua/yazi_image.lua). Neovim's embedded
    -- terminal can't forward a graphics protocol, so yazi alone is stuck with
    -- chafa; these hooks overlay the actual image instead.
    hooks = {
      on_yazi_ready = function(yazi_buf, _, process_api)
        -- Deferred inside setup to avoid E5560 (fast event context).
        require("yazi_image").setup(yazi_buf, _, process_api)
      end,
      yazi_opened = function(path, content_buffer, _)
        require("yazi_image").opened(path, content_buffer)
      end,
    },
  },
}
