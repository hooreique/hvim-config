---Snacks.nvim feature setup.
local M = {}

---Build keymap options for Snacks actions.
---@param desc string Action label shown in keymap pickers.
---@return vim.keymap.set.Opts
local function o(desc)
  return {
    noremap = true,
    nowait = true,
    desc = 'hoo: snacks: ' .. desc,
  }
end

---Hide health checks for intentionally unused Snacks components.
---@return nil
local function suppress_unused_health()
  ---@type table<string, true>
  local unused = {
    bigfile = true,
    dashboard = true,
    explorer = true,
    image = true,
    input = true,
    notifier = true,
    picker = true,
    quickfile = true,
    scope = true,
    scroll = true,
    statuscolumn = true,
    toggle = true,
  }

  local meta = require 'snacks.meta'
  if rawget(meta, '_hvim_health_filter') then
    return
  end
  rawset(meta, '_hvim_health_filter', true)

  local get = meta.get

  ---@return { name: string, meta: { health: boolean } }[] plugins Snacks metadata list.
  meta.get = function()
    local plugins = get()
    for _, plugin in ipairs(plugins) do
      if unused[plugin.name] then
        plugin.meta.health = false
      end
    end
    return plugins
  end
end

---Configure word jumps, lazygit, and Snacks health filtering.
---@return nil
function M.setup()
  require 'snacks'.setup {
    words = { enabled = true },
    lazygit = {},
  }

  suppress_unused_health()

  local jump = require('snacks.words').jump

  vim.keymap.set('n', 'a', function()
    jump(1, true)
  end, o 'words: Jump Forward')
  vim.keymap.set('n', 'A', function()
    jump(-1, true)
  end, o 'words: Jump Backward')

  vim.keymap.set('n', ',g', function()
    require('snacks.lazygit').open()
  end, o 'lazygit: Open')
end

return M
