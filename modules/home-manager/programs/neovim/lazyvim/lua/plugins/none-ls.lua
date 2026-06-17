return {
  "nvimtools/none-ls.nvim",
  opts = function()
    local nls = require("null-ls")
    return {
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
      sources = {
        -- code actions
        -- formatters
        nls.builtins.formatting.black.with({
          extra_args = { "--line-length", "120" },
        }),
        nls.builtins.formatting.prettier.with({
          filetypes = {
            "css",
            "markdown",
            "yaml.docker-compose",
            "yaml.kubernetes",
            "yaml",
          },
        }),
        nls.builtins.formatting.goimports,
        nls.builtins.formatting.isort,
        nls.builtins.formatting.markdownlint,
        nls.builtins.formatting.nixfmt,
        nls.builtins.formatting.shfmt,
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.terraform_fmt,
        -- linters
        nls.builtins.diagnostics.golangci_lint,
        nls.builtins.diagnostics.hadolint,
        nls.builtins.diagnostics.markdownlint.with({
          extra_args = {
            "--disable",
            "MD013", -- Line length
            "MD033", -- Inline HTML
            "MD041", -- First line should be a top-level header
            "MD024", -- Multiple headers with the same content
            "MD025", -- Multiple top-level headers in the same document
            "MD036", -- Emphasis used instead of a header
            "MD045", -- Images should have alternate text
            "MD007", -- Unordered list indentation
            "MD012", -- Multiple consecutive blank lines
            "MD029", -- Ordered list item prefix
            "MD034", -- Bare URL used
            "MD031", -- Fenced code blocks should be surrounded by blank lines
            "MD040", -- Fenced code blocks should have a language specified
            "MD046", -- Code block style
            "MD048", -- Code fence style
          },
        }),

      },
      on_attach = function(client, bufnr)
        -- Disable diagnostics for non-file buffers (like terminals)
        if vim.bo[bufnr].buftype ~= "" then
          vim.diagnostic.enable(false, bufnr)
        end
      end,
    }
  end,
}
