---Completion, documentation popup, and signature-help setup.
local M = {}

---Configure `blink.cmp` for LSP, snippets, paths, buffers, and cmdline.
---@return nil
function M.setup()
  require('blink.cmp').setup {
    appearance = { nerd_font_variant = 'normal' },
    completion = {
      documentation = { auto_show = true },
      ghost_text = { enabled = true },
      menu = { auto_show = true },
      trigger = { prefetch_on_insert = true },
    },
    cmdline = {
      enabled = true,
      sources = { 'buffer', 'cmdline' },
      completion = {
        ghost_text = { enabled = true },
        menu = { auto_show = true },
      },
    },
    signature = { enabled = true },
  }
end

return M
