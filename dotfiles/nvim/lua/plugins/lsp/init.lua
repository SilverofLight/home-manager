return {
	-- lspconfig
	-- {
	--   "neovim/nvim-lspconfig",
	--   dependencies = {
	--     "mason.nvim",
	--     { "williamboman/mason-lspconfig.nvim", config = function() end },
	--     "saghen/blink.cmp"
	--   },
	--   config = function()
	--     local lspconfig = require("lspconfig")
	--   end
	-- },
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"mason.nvim",
			{ "williamboman/mason-lspconfig.nvim", config = function() end },
		},

		-- example using `opts` for defining servers
		opts = {
			servers = {
				-- lua_ls = {}
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				-- passing config.capabilities to blink.cmp merges with the capabilities in your
				-- `opts[server].capabilities, if you've defined it
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},

	-- mason
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>" } },
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "UIEnter" },
		config = function()
			require("mason-lspconfig").setup()
		end,
	},
}
