return {
  "arnamak/stay-centered.nvim",
  config = function(_, opts)
    local sc = require("stay-centered")
    sc.setup(opts)
    sc.toggle() -- disable on startup
    _G.stay_centered_on = false
  end,
  keys = {
    {
      "<leader>zz",
      function()
        require("stay-centered").toggle()
        _G.stay_centered_on = not _G.stay_centered_on
        if _G.stay_centered_on then
          _G.stay_centered_scrolloff = vim.o.scrolloff
          vim.o.scrolloff = 0
        else
          vim.o.scrolloff = _G.stay_centered_scrolloff
        end
        vim.notify(_G.stay_centered_on and "  zz mode ON" or "  zz mode OFF", vim.log.levels.INFO)
      end,
      desc = "Toggle stay-centered",
    },
  },
}
