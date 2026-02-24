-- Enable spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex = {
          filetypes = { "markdown", "text" },
        },
      },
    },
  },
}

