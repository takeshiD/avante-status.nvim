local curl = require('plenary.curl')
local M = {}

M.Error = function(msg, ...)
    vim.notify('[avante-status.nvim] ' .. string.format(msg, ...), vim.log.levels.ERROR)
end

M.Warn = function(msg, ...)
    vim.notify('[avante-status.nvim] ' .. string.format(msg, ...), vim.log.levels.WARN)
end

M.Info = function(msg, ...)
    vim.notify('[avante-status.nvim] ' .. string.format(msg, ...), vim.log.levels.INFO)
end


M.Debug = function(msg, ...)
    vim.notify('[avante-status.nvim] ' .. string.format(msg, ...), vim.log.levels.DEBUG)
end

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

---Returns true if endpoint is connectable and response correct data, false if endpoint is invalid.
---@param url string
---@param model string
---@return boolean
M.available_endpoint = function(url, model)
    local data = string.format('{"model": "%s", "messages": [{"role":"user", "content":"hello"}]}', model)
    local curl_command = {'curl', url, '-d', data}
    local job = vim.system(curl_command, { text=false, timeout=3000}):wait()
    if job.code == 0 then
        local response = vim.json.decode(job.stdout)
        if response.error ~= nil then
            -- BadRequest
            M.Error("BadRequest: %s", response.error.message)
            return false
        else
            -- Success
            return true
        end
    else
        -- ConnectionFailed
        M.Error("ConnectionFailed(%d): %s, Model '%s'", job.code, url, model)
        return false
    end
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
