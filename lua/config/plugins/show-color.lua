---Inline color-highlighting setup.
local M = {}

---Enable inline color previews.
---@return nil
function M.setup()
  require('nvim-highlight-colors').setup {}
end

return M
