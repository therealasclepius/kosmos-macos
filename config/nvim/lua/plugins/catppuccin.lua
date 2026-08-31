return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato",
      transparent_background = true,
      integrations = {
        gitsigns = true,
        native_lsp = { enabled = true },
        snacks = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-macchiato" } },
}
