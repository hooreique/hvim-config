---Todo-comments setup.
local M = {}

---Enable todo-comments and its Telescope integration keymap.
---@return nil
function M.setup()
  require('todo-comments').setup {}

  vim.keymap.set('n', '<Space>"t', ':<C-U>TodoTelescope<CR>', {
    noremap = true,
    nowait = true,
    desc = 'hoo: todo-comments: Telescope',
  })
end

return M
