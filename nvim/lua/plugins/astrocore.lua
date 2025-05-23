---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = true, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- find
        ["<C-p>"] = {
          function()
            require("snacks").picker.files {
              hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
            }
          end,
        },
        ["<C-S-p>"] = {
          function() require("snacks").picker.commands() end,
        },
        ["<C-S-f>"] = {
          function() require("snacks").picker.grep() end,
        },

        -- move
        ["<S-h>"] = { "<C-w>h" },
        ["<S-j>"] = { "<C-w>j" },
        ["<S-k>"] = { "<C-w>k" },
        ["<S-l>"] = { "<C-w>l" },

        -- resize
        ["<S-A-h>"] = {
          function() require("smart-splits").resize_left() end,
        },
        ["<S-A-j>"] = {
          function() require("smart-splits").resize_down() end,
        },
        ["<S-A-k>"] = {
          function() require("smart-splits").resize_up() end,
        },
        ["<S-A-l>"] = {
          function() require("smart-splits").resize_right() end,
        },

        -- terminal
        ["<leader>tu"] = {
          function()
            local astro = require "astrocore"
            astro.toggle_term_cmd "gdu"
          end,
          desc = "ToggleTerm gdu",
        },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        ["<esc><esc>"] = { "<C-\\><C-n>" },
      },
    },
  },
}
