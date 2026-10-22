-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github. LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local NS = { noremap = true, silent = true } -- Define NS for keymaps

-- Copy current file path
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Copy current file path" })

vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting the default register" })
vim.keymap.set("n", "<leader>dt", "<cmd>diffthis<CR>", { desc = "Diff This" })

vim.keymap.set("n", "<C-f>", function()
  require("snipe").open_buffer_menu()
end, { desc = "Open Snipe buffer menu" })

-- Molten-nvim keybindings
vim.keymap.set("n", "<C-S-h>", "<cmd>MoltenHideOutput<cr>", NS)
vim.keymap.set("n", "<C-S-s>", "<cmd>noautocmd MoltenEnterOutput<cr>", NS)
vim.keymap.set("n", "<C-S-r>", "<cmd>MoltenReevaluateAll<cr>", NS)
vim.keymap.set("n", "<C-S-j>", "<C-e>", { desc = "Scroll page down" })
vim.keymap.set("n", "<C-S-k>", "<C-y>", { desc = "Scroll page up" })
vim.keymap.set("n", "<Tab>", "/\\(```.\\|](\\)<cr>:nohl<cr>", NS)
vim.keymap.set("n", "<S-Tab>", "?\\(```.\\|](\\)<cr>:nohl<cr>", NS)
vim.keymap.set("n", "<S-Enter>", "o<Esc>k", { noremap = true, silent = true, desc = "Insert blank line below without entering insert mode" })

local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })

-- Open media files in external applications.
-- NOTE: images are intentionally NOT listed here so image.nvim can render them
-- inline; videos/PDFs still open externally.
local media_group = vim.api.nvim_create_augroup("ExternalMedia", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
  group = media_group,
  pattern = {
    "*.mp4", "*.mkv", "*.webm", "*.mov", "*.avi", "*.m4v", "*.flv", "*.wmv", -- Videos
    "*.pdf", -- PDFs
  },
  callback = function(ev)
    local buf = ev.buf
    local file = vim.fn.expand("%:p")
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
    vim.cmd("stopinsert")
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end,
})

-- Standalone image viewer (snacks.image) in zellij.
--
-- zellij ignores the cursor position for kitty placements, so snacks' fallback
-- overlay always lands at the top of the pane (under the bufferline) and can't
-- be nudged with `set_cursor`. Instead, render the image in a centered floating
-- window (whose position *is* honored, like the yazi overlay). Any key closes it.

vim.on_key(function(key)
  if key == "" then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "image" then
    return
  end
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end)
end)

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ok, imgbuf = pcall(require, "snacks.image.buf")
    if not ok then
      return
    end

    local orig_attach = imgbuf._attach
    imgbuf._attach = function(buf, opts)
      opts = opts or {}
      local file = opts.src or vim.api.nvim_buf_get_name(buf)
      -- Unsupported files: keep snacks' markdown info page.
      if not Snacks.image.supports(file) then
        return orig_attach(buf, opts)
      end

      Snacks.image.placement.clean(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      vim.bo[buf].filetype = "image"
      vim.bo[buf].modifiable = false
      vim.bo[buf].modified = false
      vim.bo[buf].swapfile = false

      -- Open the image in a centered floating window.
      local cols, lines = vim.o.columns, vim.o.lines
      local width = math.max(1, cols - 8)
      local height = math.max(1, lines - 8)
      local row = math.max(0, math.floor((lines - height) / 2) - 1)
      local col = math.max(0, math.floor((cols - width) / 2))
      vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
      })

      opts.conceal = true
      opts.auto_resize = true
      return Snacks.image.placement.new(buf, file, opts)
    end
  end,
})
