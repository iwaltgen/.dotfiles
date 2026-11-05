-- Docs: https://docs.astronvim.com/configuration/core_plugins/

return {
  "AstroNvim/astroui",
  ---@param opts AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = "catppuccin"
    opts.highlights = opts.highlights or {}
    local original_init = opts.highlights.init
    local init_function = type(original_init) == "table" and function() return original_init end or original_init

    opts.highlights.init = require("astrocore").patch_func(init_function, function(orig, colors_name)
      local highlights = orig(colors_name) or {}
      for _, group in ipairs { "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" } do
        highlights[group] = vim.tbl_extend("force", highlights[group] or {}, { bg = "NONE" })
      end
      if colors_name == "catppuccin" then
        local colors = vim.o.background == "light"
            and { "#209fb5", "#1e66f5", "#179299", "#40a02b", "#4c4f69", "#fe640b", "#8839ef", "#d20f39", "#df8e1d" }
          or { "#74c7ec", "#89b4fa", "#94e2d5", "#a6e3a1", "#cdd6f4", "#fab387", "#cba6f7", "#f38ba8", "#f9e2af" }
        for i, name in ipairs { "Azure", "Blue", "Cyan", "Green", "Grey", "Orange", "Purple", "Red", "Yellow" } do
          highlights["MiniIcons" .. name] = { fg = colors[i] }
        end
        highlights.DiagnosticError = { fg = colors[8] }
        highlights.DiagnosticWarn = { fg = colors[9] }
        highlights.DiagnosticInfo = { fg = colors[2] }
        highlights.DiagnosticHint = { fg = colors[3] }
      end
      return highlights
    end)
  end,
}
