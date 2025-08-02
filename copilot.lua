return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>", -- or whatever key you want to accept
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<C-/>",
        },
      },
      panel = { enabled = false },
    })
  end,
}

