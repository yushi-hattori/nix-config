-- image.nvim is disabled: it needs the `magick` rock via luarocks.nvim, whose
-- package loader can't find `dkjson` on NixOS. Use snacks.image instead (see
-- snacks.lua), which shells out to the ImageMagick CLI and needs no luarocks.
return {
  "3rd/image.nvim",
  enabled = false,
  dependencies = {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    opts = {
      rocks = { "magick" },
      enabled = false,
    },
  },
  opts = {
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
      },
    },
    max_width = 500,
    max_height = 500,
    max_height_window_percentage = math.huge,
    max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "noice", "" },
  },
}
