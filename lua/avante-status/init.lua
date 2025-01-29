local Utils = require('avante-status.utils')
local Config = require('avante-status.config')


local M = {}

---If the environment variable envname exists, returns the value stored in it.
---If it does not exist, returns F.
---@param envname string
---@param F string | nil
---@return string
M.getenv_if = function(envname, F)
    F = F or nil
    return Utils.ternary(
        Utils.exist_envname(envname),
        vim.fn.getenv(envname),
        F
    )
end


---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
local get_provider = function(providers)
    for _, provider in ipairs(providers) do
        local p = Config.providers_map[provider]
        if p == nil then
            Utils.Warn("'%s' is undefined provider.", provider)
        else
            if p.type == "envvar" then
                provider = Utils.ternary(
                    Utils.exist_envname(p.value),
                    provider,
                    nil
                )
            elseif p.type == "path" then
                provider = Utils.ternary(
                    Utils.exist_path(p.value),
                    provider,
                    nil
                )
            elseif p.type == "endpoint" then
                provider = Utils.ternary(
                    Utils.available_endpoint(p.value, p.model),
                    provider,
                    nil
                )
            end
            if provider ~= nil then
                return tostring(provider)
            end
        end
    end
    local unavailable_providers = vim.iter(providers):fold("", function(p1, p2) return p1 .. ", " .. p2 end)
    -- vim.notify("[avante-status.nvim] '" .. unavailable_providers .. "' for which the api-key is set cannot be obtained.")
    Utils.Error("'%s' are unavailable.", unavailable_providers)
    return "none"
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
M.get_chat_provider = function(providers)
    local provider = get_provider(providers)
    Config.chat_provider = Config.providers_map[provider]
    return provider
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
M.get_suggestions_provider = function(providers)
    local provider = get_provider(providers)
    Config.suggestions_provider = Config.providers_map[provider]
    return provider
end

M.setup = function(opts)
    Config.setup(opts)
end

return M
