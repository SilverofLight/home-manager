return {
	"olimorris/codecompanion.nvim",
	lazy = true,
	cmd = { "CodeCompanion", "CodeCompanionAction", "CodeCompanionChat" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/mcphub.nvim",
	},
	opts = {
		strategies = {
			chat = {
				adapter = "gemini",
				keymaps = {
					close = {
						modes = { n = "<C-c>", i = "<C-c>" },
						opts = {},
					},
				},
			},
		},

		adapters = {
			http = {
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						env = {
							api_key = "GEMINI_API_KEY",
						},
					})
				end,
				qwen = function()
					return function()
						return {
							url = "https://dashscope.aliyuncs.com/compatible-mode/v1",
							env = {
								api_key = "QWEN_API_KEY",
								model = "qwen-plus",
							},
						}
					end
				end,
			},
		},

		display = {
			action_palette = {
				width = 95,
				height = 10,
				provider = "snacks",
			},
		},
	},
}
