return {
  "folke/snacks.nvim",
  opts = {
    zen = { enabled = true },
    scroll = { enabled = true },
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
