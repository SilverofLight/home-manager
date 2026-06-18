return {
	"stevearc/aerial.nvim",
	lazy = true,
	cmd = { "AerialPrev", "AerialNext", "AerialToggle" },
	opts = {
		on_attach = function(bufnr)
			-- Jump forwards/backwards with '{' and '}'
			vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
			vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
		end,
	},
	vim.keymap.set("n", "<leader>fa", "<cmd>AerialToggle! left<CR>"),
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
}
