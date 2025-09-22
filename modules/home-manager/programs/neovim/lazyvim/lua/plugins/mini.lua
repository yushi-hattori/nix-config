return {
  "nvim-mini/mini.nvim",
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
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.jump2d").setup()

    local MiniFiles = require("mini.files")

    MiniFiles.setup({
      windows = {
        preview = true,
        width_preview = 100,
      },
      mappings = {
        go_in_plus = "<CR>",
      },
    })

    local map_split = function(buf_id, lhs, direction)
      local rhs = function()
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
          vim.cmd(direction .. " split")
          return vim.api.nvim_get_current_win()
        end)
        MiniFiles.set_target_window(new_target)
      end
      local desc = "Split " .. direction
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, "S", "belowright horizontal")
        map_split(buf_id, "V", "belowright vertical")
      end,
    })
  end,
}
