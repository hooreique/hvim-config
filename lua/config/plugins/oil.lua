---Oil file-manager setup.
local M = {}

---Show hidden files in Oil directory buffers.
---@return nil
function M.setup()
  require('oil').setup {
    view_options = { show_hidden = true },
  }
end

return M
