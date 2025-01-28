local Config = require('avante-status.config')

local M = {}

M.chat_component = {
    function()
        return Config.chat_provider.name
    end,
    icon = Config.chat_provider.icon,
    color = { fg = Config.chat_provider.fg }
}

M.suggestions_component = {
    function()
        return Config.suggestions_provider.name
    end,
    icon = Config.suggestions_provider.icon,
    color = { fg = Config.suggestions_provider.fg }
}

return M
