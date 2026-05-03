---Fold provider setup.
local M = {}

---Enable UFO and keep folds open by default.
---@return nil
function M.setup()
  require('ufo').setup {}
  vim.opt.foldlevel = 99
end

return M
