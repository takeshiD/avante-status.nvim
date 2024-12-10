-- ########### Require Library #############
local M = {
    chat_provider = {
        type = "none",
        value = "none",
        icon = "",
        highlight = "",
        fg = "#ffffff",
        name = "None",
    },
    suggestions_provider = {
        type = "none",
        value = "none",
        icon = "",
        highlight = "",
        fg = "#ffffff",
        name = "None",
    }
}

---Returns true if the environment variable envname exists, false if it does not exist.
---@param envname string
---@return boolean
local exist_envname = function(envname)
    return vim.fn.getenv(envname) ~= vim.v.null
end

---Returns true if the path exists, false if it does not exist
---@param path string
---@return boolean
local exist_path = function(path)
    -- return Path:new(vim.fn.expand(path)):exists()
    return vim.uv.fs_stat(path) ~= nil
end

---Returns T if cond is true, returns F if cond is false
---@param cond boolean
---@param T any
---@param F any
---@return any;;
local ternary = function(cond, T, F)
    if cond then return T else return F end
end

---If the environment variable envname exists, returns the value stored in it.
---If it does not exist, returns F.
---@param envname string
---@param F string | nil
---@return string
M.getenv_if = function(envname, F)
    F = F or nil
    return ternary(exist_envname(envname), vim.fn.getenv(envname), F)
end

local provider_value_map = {
    none = {
        type = "none",
        value = "none",
        icon = "",
        highlight = "",
        fg = "#ffffff",
        name = "None",
    },
    azure = {
        type = "envvar",
        value = "AZURE_OPENAI_API_KEY",
        icon = "",
        highlight = "AvanteIconAzure",
        fg = "#008ad7",
        name = "Azure",
    },
    claude = {
        type = "envvar",
        value = "ANTHROPIC_API_KEY",
        icon = "󰛄",
        highlight = "AvanteIconClaude",
        fg = "#d97757",
        name = "Claude",
    },
    openai = {
        type = "envvar",
        value = "OPENAI_API_KEY",
        icon = "",
        highlight = "AvanteIconOpenAI",
        fg = "#76a89c",
        name = "OpenAI",
    },
    copilot = {
        type = "path",
        value = vim.fn.stdpath("data") .. "/avante/github-copilot.json",
        icon = "",
        highlight = "AvanteIconCopilot",
        fg = "#cccccc",
        name = "Copilot",
    },
    gemini = {
        type = "envvar",
        value = "GEMINI_API_KEY",
        icon = "󰫢",
        highlight = "AvanteIconGemini",
        fg = "#3a92db",
        name = "Gemini",
    },
    cohere = {
        type = "envvar",
        value = "CO_API_KEY",
        icon = "󰺠",
        highlight = "AvanteIconCohere",
        fg = "#d2a1de",
        name = "cohere",
    }
}

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@param provider_type string  "chat" | "suggestions"
---@return string
local get_provider = function(providers, provider_type)
    for _, provider in ipairs(providers) do
        local p = provider_value_map[provider]
        if p.type == "envvar" then
            provider = ternary(exist_envname(p.value), provider, nil)
        elseif p.type == "path" then
            provider = ternary(exist_path(p.value), provider, nil)
        end
        if provider ~= nil then
            return tostring(provider)
        end
    end
    local unavailable_providers = vim.iter(providers):fold("", function(p1, p2) return p1 .. ", " .. p2 end)
    error("'" .. unavailable_providers .. "' for which the api-key is set cannot be obtained.")
    return ""
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
function M.get_chat_provider(providers)
    local provider = get_provider(providers, "chat")
    -- M.chat_provider = provider_value_map[provider]
    M.chat_provider = provider_value_map["none"]
    return provider
end

---Returns the provider that has the first environment variable set among the providers.
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
function M.get_suggestions_provider(providers)
    local provider = get_provider(providers, "suggestions")
    -- M.suggestions_provider = provider_value_map[provider]
    M.suggestions_provider = provider_value_map["none"]
    return provider
end


function M.setup(opts)

end
return M
