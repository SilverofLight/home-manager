return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = { theme = "dracula-nvim" },
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = {
					function()
						if vim.bo.filetype == "markdown" then
							return require("wordcounter").count_cur_buf_words()
						end
						return ""
					end,
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	-- duacula
	{ "Mofiqul/dracula.nvim" },
	{
		"norcalli/nvim-colorizer.lua",
		event = "VeryLazy",
		opts = {},
	},
}
