return {
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim", -- Optional for enhanced terminal
  },
  opts = {
    -- Terminal options
    terminal = {
      split_side = "right",
      split_width_percentage = 0.3,
      provider = "snacks", -- or "native"
    },
  },
  config = true,
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  },
}
