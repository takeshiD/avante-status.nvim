local M = {}

---Returns true if the environment variable envname exists, false if it does not exist.
---@param envname string
---@return boolean
M.exist_envname = function(envname)
    return vim.fn.getenv(envname) ~= vim.v.null
end

---Returns true if the path exists, false if it does not exist
---@param path string
---@return boolean
M.exist_path = function(path)
    -- return Path:new(vim.fn.expand(path)):exists()
    return vim.uv.fs_stat(path) ~= nil
end

---Returns T if cond is true, returns F if cond is false
---@param cond boolean
---@param T any
---@param F any
---@return any;;
M.ternary = function(cond, T, F)
    if cond then return T else return F end
end

return M
