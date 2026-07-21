-- Docs: https://docs.astronvim.com/recipes/advanced_lsp/

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    config = {
      lua_ls = {
        settings = {
          Lua = {
            format = { enable = false },
          },
        },
      },
    },
  },
}
