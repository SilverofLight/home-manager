local key = vim.keymap
vim.g.mapleader = " "

key.set("i", "<C-q>", "<++>")
local function esc_fcitx()
	if vim.fn.executable("fcitx5-remote") == 1 then
		local corrent = vim.fn.system("fcitx5-remote -n")
		if not corrent:match("keyboard-us") then
			vim.fn.system('fcitx5-remote -c "keyboard-us"')
		end
	end
	return "<esc>"
end
-- key.set("i", "<esc>", esc_fcitx, { expr = true })
key.set("n", "<esc>", "<cmd>nohl<CR>")
-- key.set("n", "S", "<cmd>w<CR>")
key.set("n", "<C-s>", "<cmd>w<CR>")
key.set("i", "<C-s>", "<cmd>w<CR>")

-- disable q
key.set("n", "Q", "q")
key.set("n", "q", "<nop>")

-- use j as e
key.set("n", "j", "e")

function replace_next_placeholder()
	local original_state = vim.g.minianimate_disable

	vim.g.minianimate_disable = true

	local found_line = vim.fn.search("<++>")
	if found_line > 0 then
		vim.cmd("nohlsearch")
		vim.api.nvim_feedkeys('zz"vc4l', "n", false)
	else
		vim.fn.setpos(".", save_cursor)
		vim.notify("No placeholder found", vim.log.levels.INFO)
	end

	vim.defer_fn(function()
		vim.g.minianimate_disable = original_state
	end, 50)
end

key.set("n", "<leader>o", replace_next_placeholder, { desc = "replace next <++>" })

-- quick quit
key.set("n", "<leader>qq", "<cmd>quitall<cr>", { desc = "Quitall" })
key.set("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })

-- easy way to go to the end of a line
key.set("n", "<leader>s", "$", { desc = "End of line" })
key.set("v", "<leader>s", "$", { desc = "End of line" })
key.set("n", "<leader>a", "0", { desc = "Begin of line" })
key.set("v", "<leader>a", "0", { desc = "Begin of line" })

-- 窗口切换
key.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
key.set("n", "<leader>n", "<C-w>j", { desc = "Window down" })
key.set("n", "<leader>e", "<C-w>k", { desc = "Window up" })
key.set("n", "<leader>i", "<C-w>l", { desc = "Window right" })

-- window resize
key.set("n", "<C-up>", "<cmd>res +2<CR>")
key.set("n", "<C-down>", "<cmd>res -2<CR>")
key.set("n", "<C-left>", "<cmd>vertical resize -2<CR>")
key.set("n", "<C-right>", "<cmd>vertical resize +2<CR>")

-- move lines
-- key.set("v", "J", "<cmd>m '>+1<CR>gv=gv")
-- key.set("v", "K", "<cmd>m '<-2<CR>gv=gv")

-- exit v mode
-- key.set("v", "io", "<ESC>")

-- add split
key.set("n", "<leader>|", "<C-w>v", { desc = "Split window right" })
key.set("n", "<leader>-", "<C-w>s", { desc = "Split window down" })

-- ; -> :
key.set("n", ";", ":")

-- better J K
key.set("n", "<C-n>", "5gj")
key.set("n", "<C-e>", "5gk")
key.set("v", "<C-n>", "5gj")
key.set("v", "<C-e>", "5gk")
key.set("n", "<C-h>", "8h")
key.set("n", "<C-i>", "8l")
key.set("v", "<C-h>", "8h")
key.set("v", "<C-i>", "8l")

key.set("v", "n", "gj")
key.set("v", "e", "gk")

-- better jk
key.set({ "n", "x" }, "n", function()
	local count = vim.v.count
	local prev_line = vim.fn.line(".")
	local prev_winline = vim.fn.winline()

	-- schedule make this function run after the parent function ended
	vim.schedule(function()
		if vim.fn.line(".") == prev_line and vim.fn.winline() == prev_winline then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", true)
		end
	end)
	return (count == 0) and "gj" or "j"
end, { desc = "Down (scroll if stuck)", expr = true, silent = true })

key.set({ "n", "x" }, "e", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

key.set("n", "i", "l")
key.set("v", "i", "l")

key.set("n", "k", "n")
key.set("v", "k", "n")
key.set("n", "K", "N")
key.set("v", "K", "N")

key.set("n", "<C-p>", "<C-e>")

-- d c y comboo
key.set("n", "di", "dl")
key.set("n", "dn", "dj")
key.set("n", "de", "dk")
key.set("n", "d2n", "d2j")
key.set("n", "d2e", "d2k")

key.set("n", "ci", "cl")
key.set("n", "cn", "cj")
key.set("n", "ce", "ck")
key.set("n", "c2n", "c2j")
key.set("n", "c2e", "c2k")

key.set("n", "yi", "yl")
key.set("n", "yn", "yj")
key.set("n", "ye", "yk")
key.set("n", "y2n", "y2j")
key.set("n", "y2e", "y2k")

key.set("n", "u", "i")
key.set("n", "U", "I")
key.set("n", "l", "u")

key.set("n", "<C-t>", "e")
key.set("v", "<C-t>", "e")

key.set("n", "<C-l>", "<C-u>")
key.set("v", "<C-l>", "<C-u>")

key.set("n", "<leader>j", "<C-i>", { desc = "JumpList next" })

-- arround & in
key.set("n", "c;", "ci")
key.set("n", "d;", "di")

-- tab
key.set("n", "tu", "<cmd>tabnew<cr>", { desc = "Tabnew" })
key.set("n", "N", "<cmd>tabprevious<cr>")
key.set("n", "E", "<cmd>tabnext<cr>")

-- hop config
key.set("n", "s", "<cmd>HopWord<CR>")
key.set("v", "s", "<cmd>HopWord<CR>")
key.set("n", "S", "<cmd>HopFlypy1<CR>")
key.set("v", "S", "<cmd>HopFlypy1<CR>")

-- terminal
-- key.set("n", "<leader>gt", "<cmd>vsplit term://fish<CR>", { desc = "Terminal" })
-- key.set("t", "<C-s>", "<C-\\><C-n>")

-- markdown preview
-- key.set("n", "<leader>p", "<cmd>MarkdownPreview<CR>", { desc = "MarkdownPreview" })

-- buffer
key.set("n", "H", "<cmd>BufferLineCyclePrev<CR>")
key.set("n", "I", "<cmd>BufferLineCycleNext<CR>")
key.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "Buffer pick close" })
key.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Buffer pick" })
key.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Buffer delete" })

-- lean
-- vim.keymap.set('i', '<C-o>', '<ESC>o(<ESC>klywjp<C-a>a: )<ESC>i')
-- notify history
key.set("n", "<leader>,", "<cmd>lua Snacks.notifier.show_history()<cr>", { desc = "Notifier history" })

-- del in
key.del("x", "in")
