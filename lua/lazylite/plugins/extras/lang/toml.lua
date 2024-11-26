return {
  recommended = function()
    return LazyLite.extras.wants({
      ft = "toml",
      root = "*.toml",
    })
  end,
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      taplo = {},
    },
  },
}
