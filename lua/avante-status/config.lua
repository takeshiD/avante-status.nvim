local M = {}

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
        highlight = "AvanteStatusCohere",
        fg = "#d2a1de",
        name = "Cohere",
    },
}

local default_config = {
    providers_map = providers_map,
    chat_provider = providers_map["none"],
    suggestions_provider = providers_map["none"],
}

function M.setup(opts)
    local config = vim.tbl_deep_extend('force', default_config, opts or {})
    M.providers_map = config.providers_map
    M.chat_provider = config.chat_provider
    M.suggestions_provider = config.suggestions_provider
end

return M
