-- Zen mode state
local zen_mode_enabled = false

-- Toggle zen mode (center cursor)
vim.keymap.set("n", "<leader>zz", function()
  zen_mode_enabled = not zen_mode_enabled
  if zen_mode_enabled then
    vim.opt.scrolloff = 999
    vim.notify("Zen mode enabled - cursor centered", vim.log.levels.INFO)
  else
    vim.opt.scrolloff = 0
    vim.notify("Zen mode disabled", vim.log.levels.INFO)
  end
end, { noremap = true, silent = false, desc = "Toggle zen mode (center cursor)" })
