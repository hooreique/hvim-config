---Node-range navigation helpers for Treesitter keymaps.
local M = {}

---주어진 임의의 기준 노드부터 상위로 가면서
---범위가 동일한 노드 중 가장 상위 노드를 찾아 반환합니다.
---기준 노드 자기 자신 포함
---@param node? TSNode 기준 노드
---@return TSNode? node 범위가 동일한 가장 상위 노드
local function flatten_by_range(node)
  if not node then
    return
  end

  local ok, csr, csc, cer, cec = pcall(node.range or function()
    error()
  end, node)
  if not (ok and csr and csc and cer and cec) then
    return
  end

  local parent = node:parent()
  if not parent then
    return node
  end

  local psr, psc, per, pec = parent:range()
  if csr == psr and csc == psc and cer == per and cec == pec then
    return flatten_by_range(parent)
  else
    return node
  end
end

---주어진 노드의 범위의 시작으로 커서를 이동시킵니다.
---@param node TSNode
---@return nil
function M.goto_start(node)
  local sr, sc = node:range()

  local maxr = vim.api.nvim_buf_line_count(0) - 1

  -- TODO: 비주얼 모드에서도 이동 전에 마크하고 싶음
  local state = vim.api.nvim_get_mode()
  if not state.blocking and state.mode == 'n' then
    vim.cmd "normal! m'"
  end

  vim.api.nvim_win_set_cursor(0, { math.min(maxr, sr) + 1, sc })
end

---주어진 노드의 범위의 끝으로 커서를 이동시킵니다.
---@param node TSNode
---@return nil
function M.goto_end(node)
  local _, _, er, ec = node:range()

  local maxr = vim.api.nvim_buf_line_count(0) - 1
  if er > maxr then
    er = maxr
    ec = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1]:len()
  end

  local state = vim.api.nvim_get_mode()
  if not state.blocking and state.mode == 'n' then
    vim.cmd "normal! m'"
  end

  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
end

---@return TSNode? node 현재 커서와 같은 범위의 최상위 노드
function M.inner()
  return flatten_by_range(vim.treesitter.get_node())
end

---Returns
---1. _node_: 현재 커서 상의 노드 범위보다 큰 범위를 갖는 가장 하위 노드
---2. _fallback_: _node_ 가 없을 때 쓰일 노드
---@return TSNode? node, TSNode? fallback
function M.outer()
  local i = M.inner()
  if i then return i:parent(), i end
end

---@param supply fun(): TSNode?, TSNode? 노드를 반환하는 함수
---@param consume fun(node: TSNode): nil 주어진 노드를 기준으로 커서를 이동시키는 함수
---@return fun(): nil rhs 노드가 있으면 `consume`을 실행하는 함수
function M.compose(supply, consume)
  return function()
    local ok, node, fallback = pcall(supply)

    if not ok then return end

    node = node or fallback

    if node then consume(node) end
  end
end

return M
