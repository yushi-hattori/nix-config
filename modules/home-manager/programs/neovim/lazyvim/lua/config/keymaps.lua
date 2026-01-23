-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github. LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local NS = { noremap = true, silent = true } -- Define NS for keymaps

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
