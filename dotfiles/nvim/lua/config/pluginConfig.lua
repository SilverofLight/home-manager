-----@diagnostic disable: undefined-global
-- hop
local hop = require("hop")
local directions = require("hop.hint").HintDirection
vim.keymap.set("", "f", function()
	hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { silent = true })
vim.keymap.set("", "F", function()
	hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, { silent = true })

vim.keymap.set("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", { desc = "Lsp format" })
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Goto Definition" })
vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code action" })
vim.keymap.set("n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Lsp Rename" })
-- vim.keymap.set('n', 'gh', "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Lsp Hover" })
vim.keymap.set("n", "gh", function()
	vim.lsp.buf.hover({
		border = "rounded",
	})
end, { desc = "Lsp Hover" })

vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic" })
vim.diagnostic.config({
	float = {
		border = "rounded",
	},
})

-- if not vim.g.vscode then
--   -- blink.cmp ghost color
--   vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { fg = '#5E81AC' })
--
--   -- lsp
--   local capabilities = require('blink.cmp').get_lsp_capabilities()
--   local lspconfig = require('lspconfig')
--
--   lspconfig['lua_ls'].setup({ capabilities = capabilities })
--   lspconfig['gopls'].setup({ capabilities = capabilities })
--   lspconfig['ruff'].setup({ capabilities = capabilities })
--   lspconfig['vtsls'].setup({ capabilities = capabilities })
--   lspconfig['bashls'].setup({ capabilities = capabilities })
--
--   local clangd_capabilities = require("blink.cmp").get_lsp_capabilities()
--   clangd_capabilities.offsetEncoding = { "utf-16" }
--   require("lspconfig")['clangd'].setup {
--     capabilities = clangd_capabilities
--   }
-- end

-- copilot
-- vim.keymap.set('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
--   expr = true,
--   replace_keycodes = false
-- })
-- vim.g.copilot_no_tab_map = true

--- buffer line
vim.opt.termguicolors = true

-- which key
local wk = require("which-key")
wk.add({
	{ "<leader>b", group = "Buffer" },
	{ "<leader>x", group = "Trouble", icon = "󱪊 " },
	{ "<leader>w", group = "Warp & Save", icon = " " },
	{ "<leader>u", group = "Spell", icon = " " },
	{ "<leader>f", group = "Search, Aerial & format" },
	{ "<leader>c", group = "Lsp", icon = " " },
	{ "<leader>g", group = "Terminal & gitsigns" },
	{ "<leader>q", group = "Quit" },
	{ "<leader>l", "<cmd>Lazy<cr>", icon = "󰒲 " },
	{ "t", group = "Tab" },
	{ "gr", group = "Lsp", icon = " ", mode = { "n", "v" } },
	{ "gT", hidden = true, mode = { "n", "v" } },
	{ "ge", hidden = true, mode = { "n", "v" } },
	{ "gg", hidden = true, mode = { "n", "v" } },
	{ "g,", hidden = true, mode = { "n", "v" } },
	{ "g;", hidden = true, mode = { "n", "v" } },
	{ "g%", hidden = true, mode = { "n", "v" } },
	{ "gu", hidden = true, mode = { "n", "v" } },
	{ "gU", hidden = true, mode = { "n", "v" } },
	{ "gS", hidden = true, mode = { "v" } },
	{ "<leader>gs", "<cmd>GrugFar<cr>", desc = "grug-far", icon = " " },

	{ "<leader>a", icon = " " },
	{ "<leader>o", icon = "󰛔 " },
	{ "<leader>p", icon = " " },
	{ "<leader>r", icon = "󰘵 " },
	{ "<leader>s", icon = " " },
	{ "<leader>t", icon = "󰊿 " },
	{ "gd", icon = " " },
	{ "gh", icon = " " },
	{ "gO", icon = " " },
	{ "gw", icon = " " },
	{ "gi", icon = " ", desc = "Last insert position" },
	{ "gv", icon = "󰒅 ", desc = "Last visual position" },
	{ "<leader>wc", icon = " ", mode = { "n", "v" } },

	-- gitsigns
	{ "tg", group = "git", icon = " " },
	{ "tgw", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle word diff", mode = "n" },
	{ "tgl", "<cmd>Gitsigns toggle_linehl<cr>", desc = "Toggle line highlight", mode = "n" },
	{ "<leader>gh", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview git hunk", mode = "n", icon = " " },

	-- fold
	{ "zm", require("ufo").closeAllFolds, mode = { "n" }, desc = "Fold all", icon = " " },
	{ "zr", require("ufo").openAllFolds, mode = { "n" }, desc = "Unfold all", icon = " " },
	{ "za", mode = { "n", "v" }, desc = "Fold block", icon = " " },
	{ "zd", mode = { "n", "v" }, desc = "Unfold block", icon = " " },

	-- multicursor
	{ "<leader><up>", desc = "Multcursor ignore line", icon = "󰇀 " },
	{ "<leader><down>", desc = "Multcursor ignore line", icon = "󰇀 " },
	{ "<leader>k", desc = "Multcursor next", icon = "󰇀 " },
	{ "<leader>m", desc = "Multcursor ignore next", icon = "󰇀 " },
	{ "<leader>K", desc = "Multcursor pre", icon = "󰇀 " },
	{ "<leader>M", desc = "Multcursor ignore pre", icon = "󰇀 " },

	--- mpv
	{ "<leader>v", group = "MpvNote", icon = " " },

	-- Avante
	-- { "ta", "<cmd>AvanteToggle<cr>", desc = "Toggle Avante", mode = { "n" } },
})

local Snacks = require("snacks")
Snacks.toggle.zen():map("tz")
Snacks.toggle.dim():map("td")
Snacks.toggle.zoom():map("tf")

-- colorizea
-- { "tc", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizea" },
Snacks.toggle({
	name = "Colorizer",
	get = function()
		return require("colorizer").is_buffer_attached(0)
	end,
	set = function(state)
		local c = require("colorizer")
		if c.is_buffer_attached(0) then
			c.detach_from_buffer(0)
		else
			c.attach_to_buffer(0)
		end
	end,
}):map("tc")

Snacks.toggle({
	name = "Wrap",
	get = function()
		return vim.opt.wrap:get()
	end,
	set = function(state)
		if vim.opt.wrap:get() then
			vim.opt.wrap = false
		else
			vim.opt.wrap = true
		end
	end,
}):map("tw")

Snacks.toggle({
	name = "Spell",
	get = function()
		return vim.opt.spell:get()
	end,
	set = function(state)
		if vim.opt.spell:get() then
			vim.opt.spell = false
		else
			vim.opt.spell = true
		end
	end,
}):map("ts")

Snacks.toggle({
	name = "Auto Format",
	get = function()
		return vim.g.autoformat_enabled
	end,
	set = function(state)
		if vim.g.autoformat_enabled then
			vim.g.autoformat_enabled = false
		else
			vim.g.autoformat_enabled = true
		end
	end,
}):map("tF")

-- list: weather display space and tab
Snacks.toggle({
	name = "List",
	get = function()
		return vim.opt.list:get()
	end,

	set = function(state)
		if vim.opt.list:get() then
			vim.opt.list = false
		else
			vim.opt.list = true
		end
	end,
}):map("tl")

-- render
Snacks.toggle({
	name = "Render Markdown",
	get = function()
		return require("render-markdown").get()
	end,

	set = function(state)
		require("render-markdown").toggle()
	end,
}):map("tm")

-- render color
vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#400E95" })
vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#125564" })
vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#3B4206" })
vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#057022" })
vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#663C0F" })
vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#606C09" })

-- pyright conf
vim.lsp.config("pyright", {
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",
				reportMissingTypeStubs = "warning",
				reportUnusedVariable = "warning",
				reportGeneraltypeIssues = "warning",
			},
		},
	},
})

vim.lsp.config("gdscript", {
    cmd = vim.lsp.rpc.connect( "127.0.0.1", 6005 ),
    filetypes = { "gd", "gdscript" },
    root_markers = { "project.godot" },
})
vim.lsp.enable( "gdscript" )
