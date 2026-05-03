---Custom Telescope picker for live grep plus an optional glob filter.

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local grep_previewer = require('telescope.config').values.grep_previewer
local no_sort = require('telescope.sorters').empty()

local M = {}

---Open a Telescope picker where two spaces split query and glob.
---
---Prompt format: `<ripgrep pattern>  <glob>`.
---@param opts? { cwd?: string } Telescope picker options.
---@return nil
function M.live_multigrep(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    cwd = opts.cwd,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    ---@param prompt? string Current Telescope prompt.
    ---@return string[]? command Ripgrep argv, or `nil` for an empty prompt.
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local pieces = vim.split(prompt, '  ')
      local args = { 'rg' }

      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end

      return vim.iter({ args, {
        '--color=never', '--no-heading', '--with-filename', '--line-number',
        '--column', '--smart-case'
      } }):flatten():totable()
    end,
  }

  pickers.new(opts, {
    debounce = 100,
    prompt_title = 'Live Multi Grep',
    finder = finder,
    previewer = grep_previewer(opts),
    sorter = no_sort,
  }):find()
end

return M
