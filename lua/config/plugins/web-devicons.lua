---Web devicons setup.
local M = {}

---Enable filetype icons for plugins that support them.
---@return nil
function M.setup()
  require('nvim-web-devicons').setup {}
end

return M
