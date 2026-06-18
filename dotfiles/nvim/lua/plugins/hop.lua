return {
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("hop").setup({
				keys = "arstneiodh",
				extensions = {
					"hop-zh-by-flypy",
				},
			})
		end,
	},
	{
		"SilverofLight/hop-zh-silver",
		dependencies = {
			"phaazon/hop.nvim",
		},
		config = function()
			local hop_flypy = require("hop-zh-by-flypy")
			hop_flypy.setup({
				-- 注意: 本扩展的默认映射覆盖掉了一些常用的映射: f, F, t, T, s
				-- 设置 set_default_mappings 为 false 可关闭默认映射.
				set_default_mappings = false,
			})
		end,
	},
}
