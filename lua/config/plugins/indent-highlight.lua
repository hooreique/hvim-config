---Indent guide setup.
local M = {}

---Configure indentation guides with a thin vertical marker.
---@return nil
function M.setup()
  require('ibl').setup {
    indent = { char = '▏' },
  }
end

return M
