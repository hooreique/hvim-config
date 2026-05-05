---Treesitter parser startup, injections, and node navigation keymaps.
local M = {}

---@type table<string, boolean>
local notified_missing_parser = {}

---@type table<string, boolean>?
local installable_parsers

---Return whether nvim-treesitter can install a parser for a language.
---@param lang string Treesitter language name.
---@return boolean installable `true` when `:TSInstall {lang}` is supported.
local function can_install_parser(lang)
  if not installable_parsers then
    ---@type boolean, table<string, { tier?: integer }>
    local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
    if not ok then
      return false
    end

    installable_parsers = {}
    for parser_lang, parser in pairs(parsers) do
      if parser.tier ~= 4 then
        installable_parsers[parser_lang] = true
      end
    end
  end

  return installable_parsers[lang] == true
end

---Build keymap options for Treesitter actions.
---@param desc string Action label shown in keymap pickers.
---@return vim.keymap.set.Opts
local function o(desc)
  return {
    noremap = true,
    nowait = true,
    desc = 'hoo: treesitter: ' .. desc,
  }
end

---Return whether a buffer is too large for automatic Treesitter startup.
---@param buf integer Buffer handle.
---@return boolean skip `true` when the buffer should skip Treesitter.
local function should_skip(buf)
  local max_filesize = 100 * 1024 -- 100KB
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if not ok or not stats then
    return false
  end
  return stats.size > max_filesize
end

---Start Treesitter highlighting, or explain how to install a missing parser.
---@param buf integer Buffer handle.
---@return nil
local function start(buf)
  local ok = pcall(vim.treesitter.start, buf)
  if ok then
    return
  end

  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  if not lang or notified_missing_parser[lang] or not can_install_parser(lang) then
    return
  end

  notified_missing_parser[lang] = true
  vim.notify(
    ('Missing Treesitter parser: %s. Run :TSInstall %s'):format(lang, lang),
    vim.log.levels.INFO
  )
end

---Configure Treesitter queries, parser startup, and node-jump mappings.
---@return nil
function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    ---@param args vim.api.keyset.create_autocmd.callback_args
    ---@return nil
    callback = function(args)
      if should_skip(args.buf) then
        return
      end

      start(args.buf)
    end,
  })

  local ne = require 'config.treesitter.node-ends'

  vim.keymap.set(
    { 'n', 'v' }, '[',
    ne.compose(ne.inner, ne.goto_start),
    o 'Go to Start of Current Node')

  vim.keymap.set(
    { 'n', 'v' }, ']',
    ne.compose(ne.inner, ne.goto_end),
    o 'Go to End of Current Node')

  vim.keymap.set(
    { 'n', 'v' }, '{',
    ne.compose(ne.outer, ne.goto_start),
    o 'Go to Start of Current Node')

  vim.keymap.set(
    { 'n', 'v' }, '}',
    ne.compose(ne.outer, ne.goto_end),
    o 'Go to End of Current Node')
end

return M
