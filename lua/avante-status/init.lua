local utils = require('avante-status.utils')

local providers_map = {
    none = {
        type = "none",
        value = "none",
        icon = "",
        highlight = "AvanteStatusNone",
        fg = "#ffffff",
        name = "None",
    },
    azure = {
        type = "envvar",
        value = "AZURE_OPENAI_API_KEY",
        icon = "",
        highlight = "AvanteStatusAzure",
        fg = "#008ad7",
        name = "Azure",
    },
    claude = {
        type = "envvar",
        value = "ANTHROPIC_API_KEY",
        icon = "󰛄",
        highlight = "AvanteStatusClaude",
        fg = "#d97757",
        name = "Claude",
    },
    ['claude-haiku'] = {
        type = "envvar",
        value = "ANTHROPIC_API_KEY",
        icon = "󰛄",
        highlight = "AvanteStatusClaude",
        fg = "#d97757",
        name = "Haiku",
    },
    ['claude-opus'] = {
        type = "envvar",
        value = "ANTHROPIC_API_KEY",
        icon = "󰛄",
        highlight = "AvanteStatusClaude",
        fg = "#d97757",
        name = "Opus",
    },
    openai = {
        type = "envvar",
        value = "OPENAI_API_KEY",
        icon = "",
        highlight = "AvanteStatusOpenAI",
        fg = "#76a89c",
        name = "OpenAI",
    },
    copilot = {
        type = "path",
        value = vim.fn.stdpath("data") .. "/avante/github-copilot.json",
        icon = "",
        highlight = "AvanteStatusCopilot",
        fg = "#cccccc",
        name = "Copilot",
    },
    gemini = {
        type = "envvar",
        value = "GEMINI_API_KEY",
        icon = "󰫢",
        highlight = "AvanteStatusGemini",
        fg = "#3a92db",
        name = "Gemini",
    },
    cohere = {
        type = "envvar",
        value = "CO_API_KEY",
        icon = "󰺠",
        highlight = "AvanteStatusohere",
        fg = "#d2a1de",
        name = "Cohere",
    },
}

local default_config = {
    chat_provider = providers_map["none"],
    suggestions_provider = providers_map["none"],
    providers_map = providers_map,
}

local M = {}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', default_config, opts or {})
    M.chat_provider = M.config.chat_provider
    M.suggestions_provider = M.config.suggestions_provider
end


---If the environment variable envname exists, returns the value stored in it.
---If it does not exist, returns F.
---@param envname string
---@param F string | nil
---@return string
M.getenv_if = function(envname, F)
    F = F or nil
    return utils.ternary(
        utils.exist_envname(envname),
        vim.fn.getenv(envname),
        F
    )
end


---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@param provider_type string  "chat" | "suggestions"
---@return string
local get_provider = function(providers, provider_type)
    for _, provider in ipairs(providers) do
        local p = M.config.providers_map[provider]
        if p.type == "envvar" then
            provider = utils.ternary(
                utils.exist_envname(p.value),
                provider,
                nil
            )
        elseif p.type == "path" then
            provider = utils.ternary(
                utils.exist_path(p.value),
                provider,
                nil
            )
        end
        if provider ~= nil then
            return tostring(provider)
        end
    end
    local unavailable_providers = vim.iter(providers):fold("", function(p1, p2) return p1 .. ", " .. p2 end)
    error("'" .. unavailable_providers .. "' for which the api-key is set cannot be obtained.")
    return "none"
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
M.get_chat_provider = function(providers)
    local provider = get_provider(providers, "chat")
    M.chat_provider = M.config.providers_map[provider]
    return provider
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
M.get_suggestions_provider = function(providers)
    local provider = get_provider(providers, "suggestions")
    M.suggestions_provider = M.config.providers_map[provider]
    return provider
end

return M
