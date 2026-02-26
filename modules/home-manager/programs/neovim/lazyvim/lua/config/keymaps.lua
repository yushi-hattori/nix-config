-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github. LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local NS = { noremap = true, silent = true } -- Define NS for keymaps

-- Zen mode state (centered cursor mode)
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

vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting the default register" })
vim.keymap.set("n", "<leader>dt", "<cmd>diffthis<CR>", { desc = "Diff This" })

vim.keymap.set("n", "<C-f>", function()
  require("snipe").open_buffer_menu()
end, { desc = "Open Snipe buffer menu" })

-- Molten-nvim keybindings
vim.keymap.set("n", "<C-S-h>", "<cmd>MoltenHideOutput<cr>", NS)
vim.keymap.set("n", "<C-S-s>", "<cmd>noautocmd MoltenEnterOutput<cr>", NS)
vim.keymap.set("n", "<C-S-r>", "<cmd>MoltenReevaluateAll<cr>", NS)
vim.keymap.set("n", "<C-S-j>", "<cmd>MoltenNext<cr>", NS)
vim.keymap.set("n", "<C-S-k>", "<cmd>MoltenPrev<cr>", NS)
vim.keymap.set("n", "<Tab>", "/\\(```.\\|](\\)<cr>:nohl<cr>", NS)
vim.keymap.set("n", "<S-Tab>", "?\\(```.\\|](\\)<cr>:nohl<cr>", NS)
vim.keymap.set({"n", "x"}, "<S-Enter>", function() require("various-textobjs").mdFencedCodeBlock("inner"); vim.cmd("MoltenEvaluateOperator"); end, NS)
vim.keymap.set("i", "<S-Enter>", function() vim.cmd("stopinsert"); require("various-textobjs").mdFencedCodeBlock("inner"); vim.cmd("MoltenEvaluateOperator"); end, NS)

local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })
