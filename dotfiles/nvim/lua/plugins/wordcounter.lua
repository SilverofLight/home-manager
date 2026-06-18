return {
	"SilverofLight/wordcounter.nvim",
	dependencies = "uga-rosa/utf8.nvim",
	lazy = true,
	cmd = { "WordCount", "WordSelectedCount" },
	opts = {
		allowed_filetypes = { "markdown", "text" },
	},
	vim.keymap.set("n", "<leader>wc", "<cmd>WordCount<CR>", { desc = "Word count all" }),
	vim.keymap.set("v", "<leader>wc", "<cmd>WordSelectedCount<CR>", { desc = "Word selected count" }),
}
