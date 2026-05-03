---Hvim entrypoint: editor options, core keymaps, diagnostics, terminal helpers,
---and plugin bootstrap.

if vim.env.SSH_TTY or vim.env.NODE_PTY then
  local copy      = require('vim.ui.clipboard.osc52').copy
  local paste     = require('vim.ui.clipboard.osc52').paste
  vim.g.clipboard = {
    name  = 'OSC 52',
    copy  = { ['+'] = copy '+', ['*'] = copy '*' },
    paste = { ['+'] = paste '+', ['*'] = paste '*' },
  }
end

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.scrolloff = 3
vim.opt.updatetime = 250
vim.opt.spelllang = { 'en_us', 'cjk' }

-- Disable default mappings by _matchit_ built-in package
vim.g.no_plugin_maps = true

-- Disable default diagnostics navigation mappings
pcall(vim.keymap.del, 'n', '[d')
pcall(vim.keymap.del, 'n', ']d')

---@type string[]
local keys = {
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  -- 'm', 'M',

  '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '=',
  '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+',
  '[', ']', '{', '}', '|', '\\', "'", '"', ',', '<', '>', '/', '?',
  -- '0', '.', ';', ':',

  '<F1>', '<F2>', '<F3>', '<F4>', '<F5>', '<F6>', '<F7>', '<F8>',
  '<F9>', '<F10>', '<F11>', '<F12>',

  '<Up>', '<Down>', '<Left>', '<Right>',
  '<Home>', '<End>', '<PageUp>', '<PageDown>',

  '<Space>', '<Tab>', '<BS>', '<Delete>', '<Insert>',
  -- '<CR>', '<ESC>',
}

---Build a consistent keymap option table for Hvim mappings.
---@param desc string Human-readable action label shown by keymap pickers.
---@return vim.keymap.set.Opts
local function o(desc)
  return { noremap = true, nowait = true, desc = 'hoo: ' .. desc }
end

for _, key in ipairs(keys) do
  vim.keymap.set({ 'n', 'v', 'o' }, key, '<Nop>', o 'Plain -> NOP')
end

---@type { [1]: string, [2]: string|function, [3]: string }[]
local nv_maps = {
  { '<Up>',           'k',      'Muggle Up' },
  { '<Down>',         'j',      'Muggle Down' },
  { '<Left>',         'h',      'Muggle Left' },
  { '<Right>',        'l',      'Muggle Right' },

  { 'u',              'gk',     'Up (Vari Cell)' },
  { 'e',              'gj',     'Down (Vari Cell)' },
  { 'n',              'h',      'Left' },
  { 'i',              'l',      'Right' },
  { 'U',              '{',      'Prev Block' },
  { 'E',              '}',      'Next Block' },
  { 'N',              'ge',     'Prev Word' },
  { 'I',              'w',      'Next Word' },

  { '<Home>',         '^',      'Muggle Home' },
  { '<End>',          '$',      'Muggle End' },

  { 'h',              'g0',     'Home (Vari Cell)' },
  { 'o',              'g$',     'End (Vari Cell)' },
  { 'H',              'gg0',    'Top Home' },
  { 'O',              'G$',     'Bot End' },

  { 'l',              'f',      'Next by Letter' },
  { 'L',              'F',      'Prev by Letter' },

  { 'y',              '<C-O>',  'Jump Backward' },
  { 'Y',              '<C-I>',  'Jump Forward' },

  { 'f',              '3<C-Y>', 'Scroll 3 Up' },
  { 's',              '3<C-E>', 'Scroll 3 Down' },
  { 'F',              '<C-U>',  'Scroll 1/2 Pg Up' },
  { 'S',              '<C-D>',  'Scroll 1/2 Pg Down' },

  { '<PageUp>',       '<C-B>',  'Muggle PageUp' },
  { '<PageDown>',     '<C-F>',  'Muggle PageDown' },

  { '<Space><Space>', 'zz',     'Scroll for Pos Center' },
  { '<Space>-',       'zc',     'Fold Close' },
  { '<Space>=',       'zo',     'Fold Open' },

  { 'v',              '"zp',    'Paste from Prime' },
  { 'V',              '"+p',    'Paste from System' },

  { 'x',              'x',      'Delete a Char' },
}

for _, map in ipairs(nv_maps) do
  vim.keymap.set({ 'n', 'v' }, map[1], map[2], o(map[3]))
end

---@type { [1]: string, [2]: string|function, [3]: string }[]
local v_maps = {
  { 'c',     '"zy',                        'Copy to Prime' },
  { 'C',     '"+y',                        'Copy to System' },
  { 'd',     '"zd',                        'Cut to Prime' },
  { 'D',     '"+d',                        'Cut to System' },

  { '<BS>',  'd',                          'Delete Selection' },
  { '<Del>', 'd',                          'Delete Selection' },

  { "'",     [[y/\<\><Left><Left><C-R>"]], 'Srch Sel Forward' },
  { '"',     [[y?\<\><Left><Left><C-R>"]], 'Srch Sel Backward' },

  { 't',     'A',                          'To Multi Insert' },
  { 'r',     'I',                          'To Multi Insert' },
}

for _, map in ipairs(v_maps) do
  vim.keymap.set('v', map[1], map[2], o(map[3]))
end

---@type { [1]: string, [2]: string|function, [3]: string }[]
local n_maps = {
  { '<Space>m',     '`',                             'Go to Mark [a-Z]' },

  { 'c',            '"zyy',                          'Copy to Prime' },
  { 'C',            '"+yy',                          'Copy to System' },
  { 'd',            '"zdd',                          'Cut to Prime' },
  { 'D',            '"+dd',                          'Cut to System' },

  { '<Space>v',     '"zP',                           'Paste from Prime (Before)' },
  { '<Space>V',     '"+P',                           'Paste from System (Before)' },

  { '<BS>',         'dhi',                           'Muggle BS' },
  { '<Del>',        'xi',                            'Muggle Del' },

  { 't',            'a',                             'To Insert' },
  { 'r',            'i',                             'To Insert' },
  { 'T',            'R',                             'To Replace' },
  { '<Space><CR>',  'o',                             'To Insert' },
  { 'R',            'O',                             'To Insert' },
  { 'g',            'v',                             'To Visual' },
  { 'G',            'V',                             'To Visual Line' },
  { '<Space>g',     '<C-V>',                         'To Visual Block' },

  { ',e',           ':setlocal fileformat=unix<CR>', 'CRLF to LF' },

  { '<',            ':cprevious<CR>',                'Qf Prev' },
  { '>',            ':cnext<CR>',                    'Qf Next' },

  { "'",            '/',                             'Srch ...' },
  { '"',            [[/\<\><Left><Left>]],           'Srch <...>' },
  { '\\',           '/<C-R><C-W>',                   'Srch it...' },
  { '|',            [[/\<\><Left><Left><C-R><C-W>]], 'Srch <it...>' },
  { ')',            'n',                             'Srch Next' },
  { '(',            'N',                             'Srch Prev' },

  { 'z',            'u',                             'Undo' },
  { 'Z',            '<C-R>',                         'Redo' },

  { 'q',            'qy',                            'Start Record' },
  { 'Q',            'q',                             'Stop Record' },
  { 'p',            '@y',                            'Play Record' },

  { '<Space>s',     ':write<CR>',                    'Save' },
  { '<Space>q',     '<Nop>',                         'Leading NOP' },
  { '<Space>q<CR>', ':quit<CR>',                     'Quit' },
  { '<Space>qa',    ':qa<CR>',                       'Quit All' },
  { '<Space>qw',    ':wq<CR>',                       'Save & Quit' },
  { '<Space>qq',    ':quit!<CR>',                    'Quit!' },
  { '<Space>r',     '<Nop>',                         'Leading NOP' },
  { '<Space>rr',    ':edit!<CR>',                    'Revert' },

  { 'w',            ':close<CR>',                    'Close' },
  { 'W',            ':only<CR>',                     'Close Others' },
  { '<Space>j',     ':wincmd s<CR>',                 '- Split' },
  { '<Space>J',     ':wincmd v<CR>',                 '| Split' },
  { 'j',            ':wincmd w<CR>',                 'Next Window' },
  { 'J',            ':wincmd W<CR>',                 'Prev Window' },
  { '=',            ':wincmd 3+<CR>',                'Win Height +' },
  { '-',            ':wincmd 3-<CR>',                'Win Height -' },
  { '+',            ':wincmd 10><CR>',               'Win Width +' },
  { '_',            ':wincmd 10<LT><CR>',            'Win Width -' },

  { '<Space>T',     '<C-W>T',                        'To New Tab' },

  { '<Space>t',     '<Nop>',                         'Leading NOP' },
  { '<Space>tt',    ':tabnew .<CR>',                 'New Tab' },
  { '<Space>tw',    ':tabonly<CR>',                  'Close Other Tabs' },
  { '<Space>ti',    ':tabnext<CR>',                  'Next Tab' },
  { '<Space>tn',    ':tabprevious<CR>',              'Prev Tab' },
  { '<Space>th',    ':tabfirst<CR>',                 'First Tab' },
  { '<Space>to',    ':tablast<CR>',                  'Last Tab' },

  { '<Space>w',     ':bdelete<CR>',                  'Delete Buffer' },
  { '<Space>i',     ':bnext<CR>',                    'Next Buffer' },
  { '<Space>n',     ':bprevious<CR>',                'Prev Buffer' },
  { '<Space>h',     ':bfirst<CR>',                   'First Buffer' },
  { '<Space>o',     ':blast<CR>',                    'Last Buffer' },
  { '1',            ':bfirst<CR>',                   '1st Buffer' },
  { '2',            ':bfirst | 1bnext<CR>',          '2nd Buffer' },
  { '3',            ':bfirst | 2bnext<CR>',          '3rd Buffer' },
  { '4',            ':bfirst | 3bnext<CR>',          '4th Buffer' },
  { '5',            ':bfirst | 4bnext<CR>',          '5th Buffer' },
  { '6',            ':bfirst | 5bnext<CR>',          '6th Buffer' },
  { '7',            ':bfirst | 6bnext<CR>',          '7th Buffer' },
  { '8',            ':bfirst | 7bnext<CR>',          '8th Buffer' },
  { '9',            ':bfirst | 8bnext<CR>',          '9th Buffer' },
}

for _, map in ipairs(n_maps) do
  vim.keymap.set('n', map[1], map[2], o(map[3]))
end

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { higroup = 'Visual', timeout = 100 }
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    local tw = vim.api.nvim_get_option_value('textwidth', { scope = 'local' })

    if tw > 0 then
      vim.api.nvim_set_option_value(
        'colorcolumn', tostring(tw + 1), { scope = 'local' })
    else
      vim.api.nvim_set_option_value('colorcolumn', '81', { scope = 'local' })
    end
  end,
})

vim.keymap.set('n', ',s', function()
  if vim.api.nvim_get_option_value('spell', { scope = 'local' }) then
    vim.cmd 'setlocal nospell | echo ":setlocal nospell"'
  else
    vim.cmd 'setlocal spell | echo ":setlocal spell"'
  end
end, o 'Toggle Spell Check')

vim.keymap.set('n', ',w', function()
  if vim.api.nvim_get_option_value('wrap', { scope = 'local' }) then
    vim.cmd 'setlocal nowrap | echo ":setlocal nowrap"'
  else
    vim.cmd 'setlocal wrap | echo ":setlocal wrap"'
  end
end, o 'Toggle Soft Wrap')

vim.keymap.set('n', ',c', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, o 'Copy Path')

-- 현재 버퍼 빼고 전부 지우기
vim.keymap.set('n', '<Space>W', function()
  local cur = vim.api.nvim_get_current_buf()
  local del = false
  local errors = { 'Error(s) During :bdelete' }

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) then
      ---@type boolean, any
      local success, result = pcall(vim.cmd.bdelete, buf)

      if success then
        del = true
      else
        table.insert(errors, result)
      end
    end
  end

  if del then
    vim.api.nvim__redraw { tabline = true }
  end

  if #errors > 1 then
    error(table.concat(errors, '\n  '))
  end
end, o 'Delete Other Buffers')

vim.keymap.set('n', '<Space>a', vim.lsp.buf.references,
  o 'vim.lsp.buf.references')
vim.keymap.set('n', 'b', vim.lsp.buf.definition, o 'vim.lsp.buf.definition')
vim.keymap.set('n', 'k', vim.lsp.buf.rename, o 'vim.lsp.buf.rename')
vim.keymap.set('n', '<Space>f', vim.lsp.buf.format, o 'vim.lsp.buf.format')
vim.keymap.set('n', ',,', vim.lsp.buf.hover, o 'vim.lsp.buf.hover')
vim.keymap.set('n', ',d', vim.diagnostic.open_float,
  o 'vim.diagnostic.open_float')

vim.diagnostic.config {
  severity_sort = true,
  signs         = { severity = { min = vim.diagnostic.severity.INFO } },
  virtual_text  = true,
  virtual_lines = {
    current_line = true,
    severity     = { min = vim.diagnostic.severity.INFO },
  },
}

-- 터미널 창 구성
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.api.nvim_set_option_value('number', false, { scope = 'local' })
  end,
})

-- 터미널 정상화
vim.api.nvim_create_user_command('MyTerminal', function()
  local shell = os.getenv 'SHELL' or '/usr/bin/bash'
  local term  = os.getenv 'TERM' or 'xterm'
  vim.cmd('term TERM=' .. term .. ' ' .. shell)
end, {})

vim.keymap.set('n', '<Space>p', '<Nop>', o 'Leading NOP')

-- 현재 창에서 터미널 열기
vim.keymap.set('n', '<Space>p<CR>', ':MyTerminal<CR>i', o 'Open Terminal Here')

-- 하단에 새 터미널 창 열기
vim.keymap.set('n', '<Space>pp', function()
  vim.cmd 'botright new'
  vim.api.nvim_win_set_height(0, 10)
  vim.cmd 'MyTerminal'
  vim.api.nvim_command 'startinsert'
end, o 'Open Terminal at Bottom')

-- 터미널 모드에서 나오기
vim.keymap.set('t', '<C-\\><C-\\>', '<C-\\><C-N>',
  o 'Exit from Terminal Mode')

-- 파일 브라우징
vim.keymap.set('n', '<Space>.', function()
  if vim.api.nvim_buf_get_name(0) == '' then
    vim.cmd.edit '.'
  else
    vim.cmd.edit '%:h'
  end
end, o 'Browse Files')

require 'config.pack'
require('config.hvim-config-luarc').run()
