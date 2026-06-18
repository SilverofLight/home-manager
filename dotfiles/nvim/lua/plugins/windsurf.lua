return {
	"Exafunction/windsurf.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"saghen/blink.cmp",
	},
	event = "VeryLazy",
	config = function()
		require("codeium").setup({
			enable_cmp_source = false,
			virtual_text = {
				enable = true,
				manual = false,
				filetyles = {},
				default_filetype_enabled = true,
				virtual_text_priority = 65535,
				map_keys = true,
				accept_fallback = nil,
				key_bindings = {
					accept = "<C-I>",
					accept_word = "<C-E>",
					accept_line = false,
				},
			},
		})
	end,
}
