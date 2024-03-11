return {
  n = {
    ["<C-p>"] = {
      function() require("telescope.builtin").find_files() end,
    },
  },
}
