return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true, -- for hidden files
        ignored = true, -- for .gitignore files
      },
      image = {
        enabled = true,
        -- `.icon` is commonly used for image assets even though it is not one
        -- of Snacks' default filename extensions. ImageMagick detects the
        -- actual image format and converts it for Kitty.
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
          "mp4",
          "mov",
          "avi",
          "mkv",
          "webm",
          "pdf",
          "icns",
          "ico",
          "icon",
        },
      },
    },
  },
}
