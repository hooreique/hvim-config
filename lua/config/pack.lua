---Plugin bootstrap and post-install hooks for `vim.pack`.

---Build a GitHub repository URL for a `vim.pack` source spec.
---@param repo string Repository in `owner/name` form.
---@return string url Full GitHub repository URL.
local gh = function(repo)
  return 'https://github.com/' .. repo
end

---Run package-specific post-install/update hooks.
---@param ev { data?: { kind?: string, path?: string, active?: boolean, spec?: { name?: string } } } PackChanged autocmd event.
---@return nil
local function on_pack_changed(ev)
  local data = ev.data or {}
  local spec = data.spec or {}
  local name = spec.name
  local kind = data.kind

  if kind ~= 'install' and kind ~= 'update' then
    return
  end

  if name == 'telescope-fzf-native.nvim' and data.path then
    local result = vim.system({ 'make' }, {
      cwd = data.path,
      text = true,
    }):wait()

    if result.code ~= 0 then
      vim.notify(
        ('Failed to build telescope-fzf-native.nvim:\n%s%s'):format(
          result.stdout or '',
          result.stderr or ''
        ),
        vim.log.levels.ERROR
      )
    end
  end

  if name == 'nvim-treesitter' then
    if not data.active then
      pcall(vim.cmd.packadd, name)
    end

    ---@type boolean, any
    local ok, err = pcall(vim.cmd.TSUpdate)
    if not ok then
      vim.notify('Failed to run TSUpdate: ' .. tostring(err), vim.log.levels.WARN)
    end
  end
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = on_pack_changed,
})

vim.pack.add({
  { src = gh 'sainnhe/sonokai' },

  { src = gh 'rafamadriz/friendly-snippets' },
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },

  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = gh 'nvim-treesitter/nvim-treesitter-context' },

  { src = gh 'nvim-lua/plenary.nvim' },
  { src = gh 'nvim-telescope/telescope-fzf-native.nvim' },
  { src = gh 'nvim-telescope/telescope.nvim', version = 'v0.2.2' },
  { src = gh 'folke/todo-comments.nvim' },

  { src = gh 'folke/snacks.nvim' },

  { src = gh 'nvim-tree/nvim-web-devicons' },
  { src = gh 'echasnovski/mini.nvim' },
  { src = gh 'nvim-tree/nvim-tree.lua' },
  { src = gh 'stevearc/oil.nvim' },

  { src = gh 'lewis6991/gitsigns.nvim' },
  { src = gh 'lukas-reineke/indent-blankline.nvim' },
  { src = gh 'brenoprata10/nvim-highlight-colors' },

  { src = gh 'kevinhwang91/promise-async' },
  { src = gh 'kevinhwang91/nvim-ufo' },

  { src = gh 'neovim/nvim-lspconfig' },
}, { confirm = false, load = true })

for _, plugin in ipairs {
  'colorscheme',
  'web-devicons',
  'mini',
  'completion',
  'treesitter',
  'context',
  'telescope',
  'todo-comments',
  'snacks',
  'nvim-tree',
  'oil',
  'gitsigns',
  'indent-highlight',
  'show-color',
  'ufo',
  'lsp',
} do
  require('config.plugins.' .. plugin).setup()
end
