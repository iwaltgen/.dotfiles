return {
  n = {
    ["<C-p>"] = { function() require("telescope.builtin").find_files() end },
    ["<C-S-p>"] = { function() require("telescope.builtin").commands() end },
    ["<C-S-f>"] = { function() require("telescope.builtin").live_grep() end },

    ["<S-k>"] = { function() require("smart-splits").move_cursor_up() end },
    ["<S-j>"] = { function() require("smart-splits").move_cursor_down() end },
    ["<S-h>"] = { function() require("smart-splits").move_cursor_left() end },
    ["<S-l>"] = { function() require("smart-splits").move_cursor_right() end },

    ["<S-Up>"] = { function() require("smart-splits").resize_up() end },
    ["<S-Down>"] = { function() require("smart-splits").resize_down() end },
    ["<S-Left>"] = { function() require("smart-splits").resize_left() end },
    ["<S-Right>"] = { function() require("smart-splits").resize_right() end },
  },
}
