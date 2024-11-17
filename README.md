
# Featues
- Load any provider in order of your priority

- Display active provider in the status line


# Installation and Basic usage
you add following setting in your `avante.nvim` config file.

In this example, the chat providers are limited to azure, openai, and claude, and the first provider in the list for which the environment variable is found will be returned.

For example, if an environment variable for azure is found, azure will be returned, and if azure is not found but there is an environment variable for claude, claude will be returned.

If none of the providers specified in the list exist, an error output and an empty string will be returned.

If you want to temporarily use Claude instead of Azure, just swap the list, and remove any providers you don't want to use from the list.

lazy.nvim
```diff
{
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
-    provider = "claude",
+    provider = reuqire("avante-status").get_chat_provider({
+        "azure",
+        "openai",
+        "claude",
+    }),
-    auto_suggestions_provider = "copilot"
+    auto_suggestions_provider = require("avante-status").get_suggestion_provider({
+        "azure",
+        "copilot",
+        "claude",
+    })
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
+   "takeshid/avante-status.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
```

## Priority provider setting
`avante-status.nvim` provides default following providers data.

```lua
require("avante-status").provider_value_map.default = {
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
```

You can change the following settings to your liking.
The following example changes the Azure icon:
```diff
{
    "takeshid/avante-status.nvim",
    event = "VeryLazy",
    opts = {
        provider_value_map = {
            azure = {
-               icon = " ",
+               icon = "󰠅 ",
            },
        }
    }
}
```

# Display Provider in Statusline

![avante-status with lualine](res/avante-status_statusline.png)

`avante-status.nvim` provides function getting current provider status and.
in example for lualine, following setting.

lualine.nvim
```diff
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "takeshid/avante-status.nvim",
    },
    config = function()
        local lualine = require("lualine")
        local lsp_component = {
            function()
                local msg = ""
                local ft = vim.bo.filetype
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then
                    return msg
                end
                for _, client in ipairs(clients) do
                    local filetypes = client.config.filetypes
                    if filetypes and vim.fn.index(filetypes, ft) ~= -1 then
                        return client.name
                    end
                end
                return msg
            end,
            icon = " ",
            color = { fg = "#FF8800" },
        }
+       local avante_chat_component = {
+           function()
+               local avante_status = require("avante-status")
+               local chat = avante_status.current_chat_provider
+               -- local msg_chat = "%#" .. chat.highlight .. "#" .. chat.icon .. " " .. chat.name .. "%#StatusLine#"
+               local msg_chat = chat.icon .. " " .. chat.name
+               return msg_chat
+           end,
+           color = require("avante-status").current_chat_provider.highlight
+       }
+       local avante_suggestions_component = {
+           function()
+               local avante_status = require("avante-status")
+               local suggest = avante_status.current_suggestions_provider
+               -- local msg_suggest = "%#" .. suggest.highlight .. "#" .. suggest.icon .. " " .. suggest.name .. "%#StatusLine#"
+               local msg_suggest = suggest.icon .. " " .. suggest.name
+               return msg_suggest
+           end,
+           color = require("avante-status").current_suggestions_provider.highlight
+       }
        local config = {
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = '',
                section_separators = { left = '', right = '' },
                globalstatus = true,
                refresh = {
                    statusline = 500,
                    tabline = 500,
                    winbar = 500,
                }
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
-               lualine_x = { 'encoding', 'fileformat', 'filetype', lsp_component},
+               lualine_x = { 'encoding', 'fileformat', 'filetype', lsp_component, avante_chat_component, avante_suggestions_component},
                lualine_y = { 'progress', },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
        }
        lualine.setup(config)
    end,
}
```


# Who is `avante-status.nvim` for?
The most notable feature of `avante-status.nvim` is that it can set providers in order of priority.

`avante.nvim` is wonderfully compatible with many providers. However, there are times when you want to separate providers for private use and for groups you belong to.

- Use Claude, which you have personally contracted, in your private environment

- Use AzureOpenAI in your company

- Use LocalLLM server in another organization

In many cases, source code is confidential information, and sending it to a provider itself is a leak of information.

`avante-status.nvim` provides the functionality to set the appropriate provider while ensuring confidentiality.

# License
This project is licensed under the MIT License.
see [LICENSE](./LICENSE)
