return {
  "folke/snacks.nvim",
  opts = {
    -- Minified/single-line JSON files trip the average-line-length heuristic
    -- (default line_length = 1000) even when they're tiny, disabling LSP/treesitter/
    -- formatting. Rely on the total-size cap instead.
    bigfile = { line_length = math.huge },
    -- Inline image rendering (markdown, etc.). Uses the ImageMagick CLI and the
    -- terminal's kitty graphics protocol; no luarocks needed (unlike image.nvim).
    -- In ghostty this is inline; inside zellij (no unicode placeholders) snacks
    -- needs `force` to render via its floating/placement fallback.
    image = { enabled = true, force = true },
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
