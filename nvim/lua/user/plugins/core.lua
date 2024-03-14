return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			window = {
				width = 40,
			},
			filesystem = {
				filtered_items = {
					--visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						".git",
					},
				},
			},
		},
	},
	-- https://docs.astronvim.com/recipes/status
	{
		"rebelot/heirline.nvim",
		opts = function(_, opts)
			local status = require("astronvim.utils.status")
			opts.statusline = {
				hl = { fg = "fg", bg = "bg" },
				status.component.mode({ mode_text = { padding = { left = 1, right = 1 } } }), -- add the mode text
				status.component.git_branch(),
				status.component.file_info({ filetype = {}, filename = false, file_modified = false }),
				status.component.git_diff(),
				status.component.diagnostics(),
				status.component.fill(),
				status.component.cmd_info(),
				status.component.fill(),
				status.component.lsp(),
				status.component.treesitter(),
				status.component.nav(),
				-- remove the 2nd mode indicator on the right
				-- status.component.mode({ surround = { separator = "right" } }),
			}

			return opts
		end,
	},
}
