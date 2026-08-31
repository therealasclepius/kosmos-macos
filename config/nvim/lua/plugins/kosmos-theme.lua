local theme_file = vim.fn.expand("~/.config/kosmos/nvim.lua")

if vim.fn.filereadable(theme_file) == 1 then
  return dofile(theme_file)
end

return {
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({})
      require("bamboo").load()
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "bamboo" } },
}
