return {
	"SilverofLight/MpvNote.nvim",
	lazy = true,
	cmd = {
		"MpvCopyStamp",
		"MpvPasteStamp",
		"MpvOpenStamp",
		"MpvHover",
		"MpvTogglePause",
		"MpvPasteImage",
		"MpvExtractSrt",
	},
	opts = {
		socket = "/tmp/mpvsocket",
		clipboard_cmd = "wl-copy",
		width = nil,
		height = nil,
	},

	-- set your keybindings below
	vim.keymap.set("n", "<leader>vc", "<cmd>MpvCopyStamp<CR>", { desc = "Copy Mpv Note" }),
	vim.keymap.set("n", "<leader>vp", "<cmd>MpvPasteStamp<CR>", { desc = "Paste Mpv Note" }),
	vim.keymap.set("n", "<leader>vi", "<cmd>MpvPasteImage<CR>", { desc = "Paste Detected Image" }),
	vim.keymap.set("n", "<leader>vo", "<cmd>MpvOpenStamp<CR>", { desc = "Open Mpv Note" }),
	vim.keymap.set("n", "<leader>vh", "<cmd>MpvHover<CR>", { desc = "Mpv Hover" }),
	vim.keymap.set({ "n", "i" }, "<C-j>", "<cmd>MpvTogglePause<CR>", { desc = "Mpv Toggle Pause" }),
}

