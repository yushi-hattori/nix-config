-- Disable spell checking
vim.opt.spell = false
vim.opt.spelllang = { "en" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex = {
          enabled = false,
          filetypes = { "markdown", "text" },
        },
      },
    },
  },
}

