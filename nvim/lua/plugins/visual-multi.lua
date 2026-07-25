-- Docs: https://github.com/mg979/vim-visual-multi

return {
  "mg979/vim-visual-multi",
  branch = "master",
  keys = {
    { "<C-d>", mode = { "n", "x" }, desc = "Visual Multi: find under cursor" },
  },
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<C-d>",
      ["Find Subword Under"] = "<C-d>",
    }
  end,
}
