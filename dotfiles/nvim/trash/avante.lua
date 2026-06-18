return {
	{
		"yetone/avante.nvim",
		-- event = "VeryLazy",
		lazy = true,
		cmd = "AvanteToggle",
		version = false, -- set this if you want to always pull the latest change
		opts = {
			provider = "gemini",
			-- auto_suggestions_provider = "groq_llama8B", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
			providers = {
				deepseek = {
					__inherited_from = "openai",
					api_key_name = "DEEPSEEK_API_KEY",
					endpoint = "https://api.deepseek.com",
					model = "deepseek-coder",
					disable_tools = true,
				},
				gemini = {
					-- __inherited_from = "openai",
					api_key_name = "GEMINI_API_KEY",
					-- endpoint = "https://generativelanguage.googleapis.com/v1beta",
					model = "gemini-2.0-flash",
				},
				groq_qwen = {
					__inherited_from = "openai",
					api_key_name = "GROQ_API_KEY",
					endpoint = "https://api.groq.com/openai/v1/",
					model = "qwen-qwq-32b",
					disable_tools = true,
					extra_request_body = {
						max_completion_tokens = 2048,
					},
				},
				groq_llama70B = {
					__inherited_from = "openai",
					api_key_name = "GROQ_API_KEY",
					endpoint = "https://api.groq.com/openai/v1/",
					-- meta-llama/llama-4-scout-17b-16e-instruct | meta-llama/llama-4-maverick-17b-128e-instruct
					-- qwen-qwq-32b | deepseek-r1-distill-qwen-32b | deepseek-r1-distill-llama-70b
					-- llama-3.3-70b-versatile | llama-3.1-8b-instant | gemma2-9b-it
					disable_tools = true,
					model = "llama-3.3-70b-versatile",
					extra_request_body = {
						max_completion_tokens = 1024,
					},
				},
				groq_llama17B_16e = {
					__inherited_from = "openai",
					api_key_name = "GROQ_API_KEY",
					endpoint = "https://api.groq.com/openai/v1/",
					model = "meta-llama/llama-4-scout-17b-16e-instruct",
					disable_tools = true,
					extra_request_body = {
						max_completion_tokens = 4096,
					},
				},
				groq_llama8B = {
					__inherited_from = "openai",
					api_key_name = "GROQ_API_KEY",
					endpoint = "https://api.groq.com/openai/v1/",
					model = "llama-3.1-8b-instant",
					disable_tools = true,
					extra_request_body = {
						max_completion_tokens = 4096,
					},
				},
			},
			behaviour = {
				auto_suggestions = false, -- Experimental stage
				auto_set_keymaps = false,
				auto_set_highlight_group = true,
			},
			hints = { enabled = false },
			mappings = {
				--- @class AvanteConflictMappings
				diff = {
					ours = "co",
					theirs = "ct",
					all_theirs = "ca",
					both = "cb",
					cursor = "cc",
					next = "]x",
					prev = "[x",
				},
				suggestion = {
					accept = "<C-l>",
					next = "<C-]>",
					prev = "<C-[>",
					dismiss = "<C-e>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					edit_user_request = "u",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
					close_from_input = { normal = "<Esc>" }, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
				},
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- {
			--   "zbirenbaum/copilot.lua",    -- for providers='copilot'
			--   opts = {
			--     panel = {
			--       enabled = true,
			--       auto_refresh = false,
			--       keymap = {
			--         jump_prev = "[[",
			--         jump_next = "]]",
			--         accept = "<CR>",
			--         refresh = "gr",
			--         open = "<M-CR>"
			--       },
			--       layout = {
			--         position = "bottom", -- | top | left | right | horizontal | vertical
			--         ratio = 0.4
			--       },
			--     },
			--     suggestion = {
			--       enabled = true,
			--       auto_trigger = true,
			--       hide_during_completion = true,
			--       debounce = 75,
			--       keymap = {
			--         accept = false,
			--         accept_word = "<C-e>",
			--         accept_line = "<C-l>",
			--         next = "<C-]>",
			--         prev = "<C-[>",
			--         dismiss = "<C-\\>",
			--       },
			--     },
			--     filetypes = {
			--       yaml = false,
			--       markdown = false,
			--       help = false,
			--       gitcommit = false,
			--       gitrebase = false,
			--       hgcommit = false,
			--       svn = false,
			--       cvs = false,
			--       ["."] = false,
			--     },
			--     vim.keymap.set("i", "<C-i>", function()
			--       require('copilot.suggestion').accept()
			--     end),
			--     copilot_node_command = 'node', -- Node.js version must be > 18.x
			--     server_opts_overrides = {},
			--   }
			-- },
			-- {
			--   -- support for image pasting
			--   "HakonHarnes/img-clip.nvim",
			--   event = "VeryLazy",
			--   opts = {
			--     -- recommended settings
			--     default = {
			--       embed_image_as_base64 = false,
			--       prompt_for_file_name = false,
			--       drag_and_drop = {
			--         insert_mode = true,
			--       },
			--       -- required for Windows users
			--       use_absolute_path = true,
			--     },
			--   },
			-- },
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "Avante" },
				},
				ft = { "Avante" },
			},
		},
	},
}
