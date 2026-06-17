return {
  "folke/snacks.nvim",
  opts = {
    zen = {
      enabled = true,
      dim = false,
    },
    dim = { enabled = false },
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
