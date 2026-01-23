return {
  "dubrayn/molten-nvim",
  version = "^1.0.0",
  dependencies = { "3rd/image.nvim" },
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_auto_init_behavior = "init"
    vim.g.molten_enter_output_behavior = "open_and_enter"
    vim.g.molten_auto_image_popup = false
    vim.g.molten_auto_open_output = false
    vim.g.molten_output_crop_border = false
    vim.g.molten_output_virt_lines = true
    vim.g.molten_output_win_max_height = 50
    vim.g.molten_output_win_style = "minimal"
    vim.g.molten_output_win_hide_on_leave = false
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
    vim.g.molten_virt_text_max_lines = 10000
    vim.g.molten_cover_empty_lines = false
    vim.g.molten_copy_output = true
    vim.g.molten_output_show_exec_time = false
  end,
}
