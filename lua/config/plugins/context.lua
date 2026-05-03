---Treesitter context window setup.
local M = {}

---Limit context lines so the sticky header stays compact.
---@return nil
function M.setup()
  require('treesitter-context').setup {
    max_lines = 3,
    min_window_height = 10,
  }
end

return M
