---Language-server setup and filetype registration.
local M = {}

---Register a virtual-buffer loader for Deno's `deno:` document scheme.
---See https://github.com/neovim/neovim/issues/30908#issuecomment-2657220629
---@return nil
local function denols_workaround()
  vim.api.nvim_create_autocmd({ 'BufReadCmd' }, {
    pattern = { 'deno:/*' },
    ---@param params vim.api.keyset.create_autocmd.callback_args
    ---@return nil
    callback = function(params)
      local bufnr = params.buf
      local actual_path = params.match:sub(1)

      local clients = vim.lsp.get_clients { name = 'denols' }
      if #clients == 0 then
        return
      end

      local client = clients[1]
      local method = 'deno/virtualTextDocument'
      local req_params = { textDocument = { uri = actual_path } }
      ---@diagnostic disable-next-line: param-type-mismatch
      local response = client:request_sync(method, req_params, 2000, 0)
      if not response or type(response.result) ~= 'string' then
        return
      end

      local lines = vim.split(response.result, '\n')
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
      vim.api.nvim_set_option_value('modified', false, { buf = bufnr })
      vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
      vim.api.nvim_buf_set_name(bufnr, actual_path)
      vim.lsp.buf_attach_client(bufnr, client.id)

      local filetype = 'typescript'
      if actual_path:sub(-3) == '.md' then
        filetype = 'markdown'
      end
      vim.api.nvim_set_option_value('filetype', filetype, { buf = bufnr })
    end,
  })
end

---Register project-specific filetype aliases before LSP attachment.
---@return nil
local function register_filetypes()
  vim.filetype.add {
    filename = {
      ['.gitlab-ci.yaml'] = 'yaml.gitlab',
      ['.gitlab-ci.yml'] = 'yaml.gitlab',
      ['compose.yaml'] = 'yaml.docker-compose',
      ['compose.yml'] = 'yaml.docker-compose',
      ['docker-compose.yaml'] = 'yaml.docker-compose',
      ['docker-compose.yml'] = 'yaml.docker-compose',
    },
    pattern = {
      ['.*/values%.yaml'] = 'yaml.helm-values',
      ['.*/values%.yml'] = 'yaml.helm-values',
    },
  }
end

---Enable every configured server whose executable is available.
---@return nil
function M.setup()
  register_filetypes()

  local vue_ls_executable = vim.fn.executable 'vue-language-server' == 1
  local ts_ls_executable = vim.fn.executable 'typescript-language-server' == 1

  if vue_ls_executable then
    vim.lsp.enable 'vue_ls'
  end

  if ts_ls_executable then
    if vue_ls_executable then
      local vue_ls_path = vim.fn.exepath 'vue-language-server'
      local vue_ls_root = vim.fs.dirname(vim.fs.dirname(vue_ls_path))

      vim.lsp.config('ts_ls', {
        init_options = {
          plugins = {
            {
              name = '@vue/typescript-plugin',
              location = vue_ls_root ..
                  '/lib/language-tools/packages/language-server',
              languages = { 'vue' },
            },
          },
        },
        filetypes = {
          'javascript', 'javascriptreact',
          'typescript', 'typescriptreact',
          'vue',
        },
      })
    end

    vim.lsp.enable 'ts_ls'
  end

  if vim.fn.executable 'deno' == 1 and
      vim.fn.executable 'typescript-language-server' == 0 then
    vim.lsp.enable 'denols'
  end

  -- pkgs.svelte-language-server
  if vim.fn.executable 'svelteserver' == 1 then
    if vim.fn.executable 'typescript-language-server' == 1 then
      vim.lsp.enable 'ts_ls'
      vim.lsp.enable 'svelte'
    else
      vim.notify 'svelteserver is executable but typescript-language-server is not.'
    end
  end

  if vim.fn.executable 'ruff' == 1 then
    vim.lsp.config('ruff', {
      capabilities = { general = { positionEncodings = { 'utf-16' } } },
    })
    vim.lsp.enable 'ruff'
  end

  if vim.fn.executable 'lemminx' == 1 then
    vim.lsp.config('lemminx', { filetypes = { 'xml', 'xsd', 'xslt', 'svg' } })
    vim.lsp.enable 'lemminx'
  end

  ---@type { [1]: string, [2]: string }[]
  local servers = {
    { 'kotlin_lsp',    'intellij-server' },

    { 'pyrefly',       'pyrefly' },

    { 'rust_analyzer', 'rust-analyzer' },

    { 'nil_ls',        'nil' },

    { 'lua_ls',        'lua-language-server' },

    { 'zk',            'zk' },

    -- pkgs.vscode-langservers-extracted
    { 'html',          'vscode-html-language-server' },
    { 'cssls',         'vscode-css-language-server' },
    { 'jsonls',        'vscode-json-language-server' },

    { 'yamlls',        'yaml-language-server' },

    -- pkgs.dockerfile-language-server-nodejs
    { 'dockerls',      'docker-langserver' },

    { 'tailwindcss',   'tailwindcss-language-server' },

    { 'unocss',        'unocss-language-server' },
  }

  for _, pair in ipairs(servers) do
    if vim.fn.executable(pair[2]) == 1 then
      vim.lsp.enable(pair[1])
    end
  end

  denols_workaround()
end

return M
