---Sonokai colorscheme setup.
local M = {}

---Apply the Sonokai variant and diagnostic highlight preferences.
---@return nil
function M.setup()
  vim.g.sonokai_style = 'atlantis'
  vim.g.sonokai_transparent_background = 1
  vim.g.sonokai_enable_italic = true
  vim.g.sonokai_diagnostic_line_highlight = 1
  vim.g.sonokai_diagnostic_virtual_text = 'highlighted'
  vim.cmd.colorscheme 'sonokai'
end

return M
