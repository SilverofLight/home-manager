return {
	"SilverofLight/kd_translate.nvim",
	lazy = true,
	cmd = { "TranslateNormal", "TranslateVisual" },
	commit = "73929cd142f1fce71c2c94e8a1cc3a5bd95144ff",
	config = function()
		require("kd").setup({
			window = {
				title = " kd ", -- 标题
				width = 50,
			},
		})
	end,
	vim.keymap.set("n", "<leader>t", "<cmd>TranslateNormal<CR>"),
	vim.keymap.set("v", "<leader>t", "<cmd>TranslateVisual<CR>"),
}
