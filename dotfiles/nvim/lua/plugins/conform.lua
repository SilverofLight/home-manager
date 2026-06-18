return {
	"stevearc/conform.nvim",
	dependencies = { "mason.nvim" },
	lazy = true,
	cmd = "ConformInfo",
	init = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname and bufname ~= "" and bufname:match("nvimAnywhere") then
			vim.g.autoformat_enabled = false
		else
			vim.g.autoformat_enabled = true
		end

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				if vim.g.autoformat_enabled then
					require("conform").format({
						bufnr = args.buf,
						timeout_ms = 3000,
						lsp_format = "fallback",
					})
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "v" },
			desc = "Format Injected Langs",
		},
	},
	opts = function()
		---@type conform.setupOpts
		local opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false, -- not recommended to change
				quiet = false, -- not recommended to change
				lsp_format = "fallback", -- not recommended to change
			},
			formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },
				["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
			},
			-- The options you set here will be merged with the builtin formatters.
			-- You can also define any custom formatters here.
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
		}
		return opts
	end,
}
