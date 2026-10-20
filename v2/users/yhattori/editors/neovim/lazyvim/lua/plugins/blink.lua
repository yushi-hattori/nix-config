return {
  {
    "Kaiser-Yang/blink-cmp-dictionary",
    dependencies = { "saghen/blink.cmp" },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<S-CR>"] = { "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          markdown = { "dictionary", "buffer", "path", "lsp" },
        },
        providers = {
          dictionary = {
            name = "Dict",
            module = "blink-cmp-dictionary",
            score_offset = -3,
            opts = {
              dictionary_files = { vim.fn.expand("~/.local/share/nvim/dict/words") },
            },
          },
        },
      },
    },
  },
}
