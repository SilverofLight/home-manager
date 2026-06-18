return {
	{
		"saghen/blink.cmp",
		cond = not vim.g.vscode,
		lazy = true,
		-- optional: provides snippets for the snippet source
		-- dependencies = 'rafamadriz/friendly-snippets',
		dependencies = {},

		-- use a release tag to download pre-built binaries
		version = "*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "super-tab",
				["<C-r>"] = { "show", "fallback" },
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
				["<C-k>"] = { "select_next", "fallback" },
			},
			sources = {
				default = { "lsp", "snippets", "path", "buffer", "codeium" },
				providers = {
					codeium = {
						name = "Codeium",
						module = "codeium.blink",
						async = true,
						enabled = function()
							return vim.bo.filetype ~= "markdown" and vim.bo.filetype ~= "AvanteInput"
						end,
					},
				},
			},

			appearance = {
				use_nvim_cmp_as_default = false,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				nerd_font_variant = "mono",
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				-- list = {
				--   selection = "auto_insert"
				-- },
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
					border = "rounded",
					winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = {
						border = "rounded",
					},
				},
				ghost_text = {
					enabled = true,
				},
			},
			cmdline = {
				enabled = true,
				keymap = {
					["<Tab>"] = { "select_and_accept", "fallback" },
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-p>"] = { "select_prev", "fallback" },
					["<C-k>"] = { "select_next", "fallback" },
				},
				completion = { menu = { auto_show = true } },
				sources = function()
					local type = vim.fn.getcmdtype()
					-- Search forward and backward
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					-- Commands
					if type == ":" or type == "@" then
						return { "cmdline", "buffer" }
					end
					return {}
				end,
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
		},
	},

	-- auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		opts = {},
	},
}
