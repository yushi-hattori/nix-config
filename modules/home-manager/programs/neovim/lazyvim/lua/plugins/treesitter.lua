return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
    },
    indent = {
      enable = true,
    },
    ensure_installed = {
      "bash",
      "c",
      "dockerfile",
      "go",
      "hcl",
      "helm",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "nix",
      "python",
      "regex",
      "terraform",
      "vim",
      "vimdoc",
      "yaml",
    },
    textobjects = {
      move = {
        enable = true,
        set_jumps = false, -- you can change this if you want.
        goto_next_start = {
          ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
        },
        goto_previous_start = {
          ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
        },
      },
      select = {
        enable = true,
        lookahead = true, -- you can change this if you want
        keymaps = {
          ["ib"] = { query = "@code_cell.inner", desc = "in block" },
          ["ab"] = { query = "@code_cell.outer", desc = "around block" },
        },
      },
      swap = { -- Swap only works with code blocks that are under the same
               -- markdown header
        enable = true,
        swap_next = {
          ["<leader>sbl"] = "@code_cell.outer",
        },
        swap_previous = {
          ["<leader>sbh"] = "@code_cell.outer",
        },
      },
    },
  },
}
