return {
  "benlubas/molten-nvim",
  -- version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = false
    vim.g.molten_enter_output_behavior = "open_then_enter"
  end,
  config = function()
    -- Style molten output highlights
    -- Set after colorscheme loads so they aren't overwritten
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "MoltenVirtualText",          { italic = true, fg = "#e0af68", bg = "#16161e" })
        vim.api.nvim_set_hl(0, "MoltenOutputBorderActive",   { fg = "#e0af68", bold = true })
        vim.api.nvim_set_hl(0, "MoltenOutputBorderInactive", { fg = "#4a3f2f" })
        vim.api.nvim_set_hl(0, "MoltenOutputWin",            { bg = "#16161e" })
      end,
    })
    -- Also apply immediately for the current session
    vim.api.nvim_set_hl(0, "MoltenVirtualText",          { italic = true, fg = "#c0caf5", bg = "#1a1b2e" })
    vim.api.nvim_set_hl(0, "MoltenOutputBorderActive",   { fg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "MoltenOutputBorderInactive", { fg = "#3b4261" })
    vim.api.nvim_set_hl(0, "MoltenOutputWin",            { bg = "#1a1b2e" })

    -- Find the range of the current # %% cell under the cursor
    local function cell_range()
      local buf = vim.api.nvim_get_current_buf()
      local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local total = #lines

      local cell_start = 1
      for i = row, 1, -1 do
        if lines[i]:match("^# %%%%") then
          cell_start = i + 1 -- skip the marker line
          break
        end
      end

      local cell_end = total
      for i = row + 1, total do
        if lines[i]:match("^# %%%%") then
          cell_end = i - 1
          break
        end
      end

      return cell_start, cell_end
    end

    -- Actually enter visual line mode over [s, e] and call MoltenEvaluateVisual.
    -- We pass the kernel name directly to avoid kernel_check's async re-dispatch,
    -- which would read the marks AFTER we've already moved them to the next cell.
    local function eval_range(s, e)
      local kernels = vim.fn.MoltenRunningKernels()
      if not kernels or #kernels == 0 then
        vim.notify("Molten: no running kernels", vim.log.levels.WARN)
        return
      end
      local kernel = kernels[1]
      vim.api.nvim_win_set_cursor(0, { s, 0 })
      local motion = e > s and ("V" .. (e - s) .. "j") or "V"
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(motion .. ":<C-u>MoltenEvaluateVisual " .. kernel .. "<CR>", true, false, true),
        "x", false
      )
    end

    -- Evaluate the current # %% cell
    local function eval_cell()
      local s, e = cell_range()
      eval_range(s, e)
    end

    -- Jump to the next/prev # %% marker
    local function next_cell() vim.fn.search("^# %%%%", "W") end
    local function prev_cell() vim.fn.search("^# %%%%", "bW") end

    -- Evaluate all # %% cells in the buffer top to bottom
    local function eval_all()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local total = #lines
      local markers = { 0 }
      for i, line in ipairs(lines) do
        if line:match("^# %%%%") then table.insert(markers, i) end
      end
      table.insert(markers, total + 1)

      local saved = vim.api.nvim_win_get_cursor(0)
      for i = 1, #markers - 1 do
        local s, e = markers[i] + 1, markers[i + 1] - 1
        if s <= e then eval_range(s, e) end
      end
      vim.api.nvim_win_set_cursor(0, saved)
    end

    vim.keymap.set("n", "<leader>mi", "<cmd>MoltenInit<CR>",             { desc = "Molten Init" })
    vim.keymap.set("n", "<leader>me", "<cmd>MoltenEvaluateOperator<CR>", { desc = "Evaluate Operator", expr = true })
    vim.keymap.set("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>",     { desc = "Evaluate Line" })
    vim.keymap.set("n", "<leader>mE", eval_cell,                         { desc = "Evaluate Cell (# %%)" })
    vim.keymap.set("n", "<leader>mc", "<cmd>MoltenReevaluateCell<CR>",   { desc = "Re-evaluate Cell" })
    vim.keymap.set("v", "<leader>mv", "<cmd>MoltenEvaluateVisual<CR>",   { desc = "Evaluate Visual" })
    vim.keymap.set("n", "<leader>md", "<cmd>MoltenDelete<CR>",           { desc = "Delete Cell" })
    vim.keymap.set("n", "<leader>mo", "<cmd>noautocmd MoltenEnterOutput<CR>", { desc = "Enter Output (scroll)" })
    vim.keymap.set("n", "<leader>mO", "<cmd>MoltenShowOutput<CR>",       { desc = "Show Output" })
    vim.keymap.set("n", "<leader>mh", "<cmd>MoltenHideOutput<CR>",       { desc = "Hide Output" })
    vim.keymap.set("n", "<leader>mr", "<cmd>MoltenRestart!<CR>",         { desc = "Restart Kernel" })
    vim.keymap.set("n", "<leader>ms", "<cmd>MoltenInterrupt<CR>",        { desc = "Interrupt Kernel" })
    vim.keymap.set("n", "<leader>mk", prev_cell,                         { desc = "Prev Cell (# %%)" })
    vim.keymap.set("n", "<leader>mj", next_cell,                         { desc = "Next Cell (# %%)" })
    vim.keymap.set("n", "<leader>mA", eval_all,                          { desc = "Evaluate All Cells" })
    vim.keymap.set("n", "<leader>mI", "<cmd>MoltenInfo<CR>",             { desc = "Kernel Info" })
  end,
}
