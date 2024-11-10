-- ########### Require Library #############
local Path = require("plenary.path")

local M = {}
M.curret_chat_provier = {
    type = "envvar",
    value = "ANTHROPIC_API_KEY",
    icon = "󰛄 ",
    highlight = "AvanteIconClaude",
    name = "Claude",
}

M.current_suggestions_provier = {
    type = "path",
    value = vim.fn.stdpath("data") .. "/avante/github-copilot.json",
    icon = " ",
    highlight = "AvanteIconCopilot",
    name = "Copilot",
}

---Returns true if the environment variable envname exists, false if it does not exist.
---@param envname string
---@return boolean
local exist_envname = function(envname)
    return vim.fn.getenv(envname) ~= vim.NIL
end

---Returns true if the path exists, false if it does not exist
---@param path string
---@return boolean
local exist_path = function(path)
    return Path:new(vim.fn.expand(path)):exists()
end

---Returns T if cond is true, returns F if cond is false
---@param cond boolean
---@param T any
---@param F any
---@return any
local ternary = function(cond, T, F)
    if cond then return T else return F end
end

---If the environment variable envname exists, returns the value stored in it.
---If it does not exist, returns F.
---@param envname string
---@param F string | nil
---@return string
local getenv_if = function(envname, F)
    F = F or nil
    return ternary(exist_envname(envname), vim.fn.getenv(envname), F)
end

local Highlights = {
    AZURE   = { name = "AvanteIconAzure", fg = "#008ad7" },
    CLAUDE = { name = "AvanteIconClaude", fg = "#d97757" },
    OPENAI = { name = "AvanteIconOpenAI", fg = "#76a89c" },
    COPILOT = { name = "AvanteIconCopilot", link = "Normal" },
    GEMINI = { name = "AvanteIconGemini", fg = "#3a92db" },
    COHERE = { name = "AvanteIconCohere", fg = "#d2a1de" },
}

local function has_set_colors(hl_group)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })
  return next(hl) ~= nil
end

local setup_highlight = function()
    vim
      .iter(Highlights)
      :filter(function(k, _)
        return k:match("^%u+_") or k:match("^%u+$")
      end)
      :each(function(_, hl)
        if not has_set_colors(hl.name) then
          vim.api.nvim_set_hl(0, hl.name, { fg = hl.fg or nil, bg = hl.bg or nil, link = hl.link or nil })
        end
      end)
end

local provider_value_map = {
    azure = {
        type = "envvar",
        value = "AZURE_OPENAI_API_KEY",
        icon = " ",
        highlight = "AvanteIconAzure",
        name = "Azure",
    },
    claude = {
        type = "envvar",
        value = "ANTHROPIC_API_KEY",
        icon = "󰛄 ",
        highlight = "AvanteIconClaude",
        name = "Claude",
    },
    openai = {
        type = "envvar",
        value = "OPENAI_API_KEY",
        icon = " ",
        highlight = "AvanteIconOpenAI",
        name = "OpenAI",
    },
    copilot = {
        type = "path",
        value = vim.fn.stdpath("data") .. "/avante/github-copilot.json",
        icon = " ",
        highlight = "AvanteIconCopilot",
        name = "Copilot",
    },
    gemini = {
        type = "envvar",
        value = "GEMINI_API_KEY",
        icon = "󰫢 ",
        highlight = "AvanteIconGemini",
        name = "Gemini",
    },
    cohere = {
        type = "envvar",
        value = "CO_API_KEY",
        icon = "󰺠 ",
        highlight = "AvanteIconCohere",
        name = "Cohere",
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
            local msg_head = "[avante.nvim] not set provider-type: "
            if provider_type == "chat" then
                msg_head = "[avante.nvim] chat provider: "
                M.curret_chat_provier = p
            elseif provider_type == "suggestions" then
                msg_head = "[avante.nvim] suggestions provider: "
                M.current_suggestions_provier = p
            end
            local msg_icon = p.icon
            local msg_provider = p.name
            vim.api.nvim_echo({
                {msg_head, nil},
                {msg_icon, p.highlight},
                {msg_provider, p.highlight},
            }, true, {})
            return tostring(provider)
        end
    end
    error("The provider for which the api-key is set cannot be obtained.")
    return ""
end

---Returns the provider that has the first environment variable set among the providers. 
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
local get_chat_provider = function(providers)
    setup_highlight()
    return get_provider(providers, "chat")
end

---Returns the provider that has the first environment variable set among the providers. 
---The provider that is set at the top has priority, so the list is sorted to set the priority.
---@param providers string[]
---@return string
local get_suggestions_provider = function(providers)
    return get_provider(providers, "suggestions")
end


M.setup = function(opts)
end

M.get_chat_provider = get_chat_provider
M.get_suggestions_provider = get_suggestions_provider
M.getenv_if = getenv_if

return M
