-- Docs: https://github.com/m4xshen/smartcolumn.nvim

return {
  "m4xshen/smartcolumn.nvim",
  opts = function(_, opts)
    opts.colorcolumn = { "120", "160" }
    opts.disabled_filetypes = opts.disabled_filetypes or {}
    table.insert(opts.disabled_filetypes, "zsh")
  end,
}
