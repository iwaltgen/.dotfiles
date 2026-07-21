-- Docs: https://docs.astronvim.com/configuration/core_plugins/

return {
  "AstroNvim/astroui",
  ---@param opts AstroUIOpts
  opts = function(_, opts)
    opts.highlights = opts.highlights or {}
    local original_init = opts.highlights.init
    local init_function = type(original_init) == "table" and function() return original_init end or original_init

    opts.highlights.init = require("astrocore").patch_func(init_function, function(orig, colors_name)
      local highlights = orig(colors_name) or {}
      for _, group in ipairs { "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" } do
        highlights[group] = vim.tbl_extend("force", highlights[group] or {}, { bg = "NONE" })
      end
      return highlights
    end)
  end,
}
