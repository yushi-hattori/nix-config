return {
  "arnamak/stay-centered.nvim",
  config = function(_, opts)
    require("stay-centered").setup(opts)
    _G.stay_centered_on = true -- enabled by default on load
  end,
  keys = {
    {
      "<leader>zz",
      function()
        require("stay-centered").toggle()
        _G.stay_centered_on = not _G.stay_centered_on
        vim.notify(_G.stay_centered_on and "  zz mode ON" or "  zz mode OFF", vim.log.levels.INFO)
      end,
      desc = "Toggle stay-centered",
    },
  },
}
