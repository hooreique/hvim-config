---Generate `.luarc.json` for this hvim config repository.

local M = {}

local uv = vim.uv or vim.loop

---@param path string
---@param data string
local function write_file(path, data)
  local fd = assert(uv.fs_open(path, 'w', 420))
  assert(uv.fs_write(fd, data, 0))
  assert(uv.fs_close(fd))
end

---@param path string
---@return string path
local function normalize(path)
  return vim.fs.normalize(path)
end

---@return table
local function read_template()
  local ok, result = pcall(function()
    return vim.system({ 'hvim-luarc' }, { text = true }):wait()
  end)

  if not ok then
    error('hvim-luarc failed: ' .. tostring(result))
  end

  if result.code ~= 0 then
    error('hvim-luarc failed: ' .. ((result.stderr or ''):gsub('%s+$', '')))
  end

  return vim.json.decode(result.stdout)
end

---@param t string[]
---@param value string?
local function append_unique(t, value)
  if not value or value == '' then
    return
  end
  for _, existing in ipairs(t) do
    if existing == value then
      return
    end
  end
  table.insert(t, value)
end

---@return table
local function complete_luarc()
  local template = read_template()
  local library = vim.tbl_get(template, 'workspace', 'library') or {}

  append_unique(library, vim.env.VIMRUNTIME and vim.env.VIMRUNTIME .. '/lua')

  for _, lua_dir in ipairs(vim.api.nvim_get_runtime_file('lua', true)) do
    append_unique(library, lua_dir)
  end

  template.diagnostics = template.diagnostics or {}
  template.diagnostics.globals = template.diagnostics.globals or { 'vim' }
  template.diagnostics.neededFileStatus = template.diagnostics.neededFileStatus or {}
  template.diagnostics.neededFileStatus['no-unknown'] = 'Any'

  template.workspace = template.workspace or {}
  template.workspace.library = library

  return template
end

---@return nil
function M.run()
  local cwd = normalize(uv.cwd() or '')
  local repo = normalize(vim.fn.expand '~/.config/hvim')

  if cwd ~= repo then
    return
  end

  local luarc = cwd .. '/.luarc.json'
  if uv.fs_stat(luarc) then
    return
  end

  local result = vim.system(
    { 'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree' },
    { text = true }
  ):wait()

  if result.code ~= 0 or (result.stdout or ''):gsub('%s+$', '') ~= 'true' then
    return
  end

  write_file(luarc, vim.json.encode(complete_luarc(), {
    indent = '  ',
    sort_keys = true,
  }) .. '\n')
  vim.notify('Created .luarc.json', vim.log.levels.INFO)
end

return M
