return {
	"folke/todo-comments.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		keywords = {
			MARK = { icon = "", color = "info" },
		},
		-- highlight = {
		--   keyword = "bg",
		--   pattern = [[.*<(KEYWORDS)\s*]],
		--   comments_only = false,
		-- },
		-- INFO:
	},
	vim.keymap.set("n", "gt", function()
		Snacks.picker.todo_comments()
	end, { desc = "Telescope TODO" }),
}
