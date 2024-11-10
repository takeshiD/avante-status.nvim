
# Featues
- Load any provider in order of your priority
- Display active provider in the status line

# Who is `avante-status.nvim` for?
The most notable feature of `avante-status.nvim` is that it can set providers in order of priority.

`avante.nvim` is wonderfully compatible with many providers. However, there are times when you want to separate providers for private use and for groups you belong to.

- Use Claude, which you have personally contracted, in your private environment

- Use AzureOpenAI in your company

- Use LocalLLM server in another organization

In many cases, source code is confidential information, and sending it to a provider itself is a leak of information.

`avante-status.nvim` provides the functionality to set the appropriate provider while ensuring confidentiality.


# Installation and Basic usage
you add following setting in your `avante.nvim` config file.

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

# Displat Provider Status in statusline
`avante-status.nvim` provides function getting current provider status and.
in example for lualine, following setting.

lualine.nvim
```lua
return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")
        local avante_component = {
            function()
                local chat = require("avante-status").provider_status.chat
                local suggestion = require("avante-status").provider_status.suggestions
                return chat .. " | " .. suggestions
            end,
            icon = "󰭻 "
        }
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
                lualine_x = { 'encoding', 'fileformat', 'filetype', avante_component },
                lualine_y = { 'progress' },
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

