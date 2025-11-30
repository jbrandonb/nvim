return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000,
  config = function()
    require("monokai-pro").setup({
      transparent_background = true,
      show_end_of_buffer = true,
      integrations = {
        cmp = true,
        treesitter = true,
        nvimtree = true,
      },
      filter = "pro",
      background_clear = {
        "neo-tree"
      }
    })
    vim.cmd.colorscheme("monokai-pro")
  end,
}

