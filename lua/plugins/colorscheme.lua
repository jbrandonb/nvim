return {
  "catppuccin/nvim",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
      show_end_of_buffer = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        nvimtree = true,
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}

