-- lazy.nvim
return {
	"folke/snacks.nvim",
	---@type snacks.Config
	-- event = "VimEnter", -- if Verylazy then cannt open kitty-scrollback end
	opts = {
		image = {
			-- your image configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			doc = {
				inline = false,
			},
		},
		styles = {
			snacks_image = {
				position = "float",
				relative = "editor",
				backdrop = false,
				row = 1,
				col = 200,
			},
			zen = {
				backdrop = { transparent = false },
			},
		},
		indent = {
			-- your indent configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		quickfile = {},
		dashboard = {
			-- your dashboard configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		notifier = {
			top_down = false,
			margin = { top = 0, right = 1, bottom = 2 },
		},
		terminal = {
			win = {
				-- style = "terminal",
				position = "float",
				width = 0.4,
				height = 0.85,
				col = 0.55,
				row = 0.1,
				border = "rounded",
			},
			wo = {},
			vim.keymap.set("n", "<leader>gt", function()
				Snacks.terminal.toggle()
			end, { desc = "Terminal" }),
			vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" }),
			vim.keymap.set("n", "<C-/>", "<cmd>lua Snacks.terminal.toggle()<cr>", { desc = "Toggle Terminal" }),
		},
		words = {
			vim.keymap.set("n", "gw", "<cmd>lua Snacks.words.jump()<cr>", { desc = "Next Reference" }),
		},
		statuscolumn = {
			left = { "mark", "sign" }, -- priority of signs on the left (high to low)
			right = { "fold", "git" }, -- priority of signs on the right (high to low)
			folds = {
				open = false, -- show open fold icons
				git_hl = false, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
		},
		zen = {},
		dim = {},
		bigfile = {},
		picker = {},
	},
	keys = {
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
	},
}
