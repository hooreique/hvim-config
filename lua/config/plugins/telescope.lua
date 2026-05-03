---Telescope setup and picker keymaps.
local M = {}

---Build keymap options for Telescope actions.
---@param desc string Action label shown in keymap pickers.
---@return vim.keymap.set.Opts
local function o(desc)
  return {
    noremap = true,
    nowait = true,
    desc = 'hoo: telescope: ' .. desc,
  }
end

---Configure Telescope, load fzf, and register picker mappings.
---@return nil
function M.setup()
  local t = require 'telescope'
  local b = require 'telescope.builtin'

  t.setup {
    pickers = {
      find_files = { theme = 'ivy' },
      help_tags  = { theme = 'dropdown' },
      quickfix   = { theme = 'ivy' },
    },
    extensions = { fzf = {} },
  }

  t.load_extension 'fzf'

  vim.keymap.set('n', "<Space>'", '<Nop>', o 'Leading NOP')
  vim.keymap.set('n', "<Space>''", b.builtin, o 'Builtins')
  vim.keymap.set('n', "<Space>'f", b.find_files, o 'Find Files')
  vim.keymap.set('n', "<Space>'g", b.live_grep, o 'Live Grep')
  vim.keymap.set('n', "<Space>'t", b.buffers, o 'Buffers')
  vim.keymap.set('n', "<Space>'h", b.help_tags, o 'Help Tags')
  vim.keymap.set('n', "<Space>'m", b.marks, o 'Marks')
  vim.keymap.set('n', "<Space>'j", b.jumplist, o 'Jumplist')
  vim.keymap.set('n', "<Space>'k", b.keymaps, o 'Keymaps')
  vim.keymap.set('n', "<Space>'s", b.git_status, o 'Git Status')
  vim.keymap.set('n', "<Space>'c", b.git_bcommits, o 'Git Commits for Buf')
  vim.keymap.set('n', "<Space>'r", b.commands, o 'Commands')
  vim.keymap.set('n', "<Space>'q", b.quickfix, o 'Quickfix List')
  vim.keymap.set('n', "<Space>'a", b.lsp_references, o 'LSP Refs')
  vim.keymap.set('n', "<Space>'b", b.lsp_implementations, o 'LSP Impls')

  local m = require 'config.telescope.multigrep-picker'

  vim.keymap.set('n', "<Space>'l", m.live_multigrep, o 'Live Multi Grep')

  -- For external plugins that use telescope
  vim.keymap.set('n', '<Space>"', '<Nop>', o 'Leading NOP')
end

return M
