return {
	"mikesmithgh/kitty-scrollback.nvim",
	enabled = true,
	cmd = {
		"KittyScrollbackGenerateKittens",
		"KittyScrollbackCheckHealth",
		"KittyScrollbackGenerateCommandLineEditing",
	},
	event = { "User KittyScrollbackLaunch" },
	-- version = '*', -- latest stable version, may have breaking changes if major version changed
	-- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
	-- vim.keymap.set({ 'v' }, 'Y', '<Plug>(KsbVisualYankLine)', {}),
	-- vim.keymap.set({ 'v' }, 'y', '<Plug>(KsbVisualYank)', {}),
	-- vim.keymap.set({ 'n' }, 'Y', '<Plug>(KsbNormalYankEnd)', {}),
	-- vim.keymap.set({ 'n' }, 'y', '<Plug>(KsbNormalYank)', {}),
	-- vim.keymap.set({ 'n' }, 'yy', '<Plug>(KsbYankLine)', {}),
	--
	-- vim.keymap.set({ 'n' }, 'q', '<Plug>(KsbCloseOrQuitAll)', {}),
	-- vim.keymap.set({ 'n', 't', 'i' }, 'ZZ', '<Plug>(KsbQuitAll)', {}),
	--
	-- vim.keymap.set({ 'n' }, '<tab>', '<Plug>(KsbToggleFooter)', {}),
	-- vim.keymap.set({ 'n', 'i' }, '<cr>', '<Plug>(KsbExecuteCmd)', {}),
	-- vim.keymap.set({ 'n', 'i' }, '<c-v>', '<Plug>(KsbPasteCmd)', {})
	config = function()
		vim.keymap.set({ "v" }, "Y", "<Plug>(KsbVisualYankLine)", {})
		vim.keymap.set({ "v" }, "y", "<Plug>(KsbVisualYank)", {})
		vim.keymap.set({ "n" }, "Y", "<Plug>(KsbNormalYankEnd)", {})
		vim.keymap.set({ "n" }, "y", "<Plug>(KsbNormalYank)", {})
		vim.keymap.set({ "n" }, "yy", "<Plug>(KsbYankLine)", {})
		vim.keymap.set({ "v" }, "<leader>y", "y", {})
		vim.keymap.set({ "v" }, "<leader>Y", "Y", {})
		vim.keymap.set({ "n" }, "<leader>y", "y", {})
		vim.keymap.set({ "n" }, "<leader>yy", "yy", {})
		vim.keymap.set({ "n" }, "<leader>Y", "Y", {})
		require("kitty-scrollback").setup()
	end,
}
