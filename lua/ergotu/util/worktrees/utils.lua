local M = {}

---@param ... table
---@return table
function M.merge(...)
  local insert = table.insert
  local res = {}
  for _, tbl in ipairs({ ... }) do
    for _, item in ipairs(tbl) do
      insert(res, item)
    end
  end
  return res
end

---@generic T: any
---@generic U: any
---@param tbl T[]
---@param f fun(v: T): U
---@return U[]
function M.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

return M
