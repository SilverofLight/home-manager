return {
	"yetone/avante.nvim",
	-- 如果您想从源代码构建，请执行 `make BUILD_FROM_SOURCE=true`
	-- ⚠️ 一定要加上这一行配置！！！！！
	build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
	event = "VeryLazy",
	version = false, -- 永远不要将此值设置为 "*"！永远不要！
	---@module 'avante'
	---@type avante.Config
	opts = {
		-- 在此处添加任何选项
		-- 例如
		provider = "qwen",
		providers = {
			moonshot = {
				endpoint = "https://api.moonshot.ai/v1",
				model = "kimi-k2-0711-preview",
				timeout = 30000, -- 超时时间（毫秒）
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 32768,
				},
			},
			qwen = {
				__inherited_from = "openai",
				api_key_name = "QWEN_API_KEY",
				endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
				-- model = "qwen3-coder-plus",
				model = "qwen-plus",
			},
		},
		behaviour = {
			auto_set_keymaps = false,
			auto_apply_diff_after_generation = false,
		},
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			cancel = {
				normal = { "<C-c>", "<Esc>", "q" },
				insert = { "<C-c>" },
			},
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				retry_user_request = "r",
				edit_user_request = "e",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
				remove_file = "d",
				add_file = "@",
				close = { "<Esc>", "q" },
				close_from_input = nil, -- 例如，{ normal = "<Esc>", insert = "<C-d>" }
			},
		},
		selection = {
			enabled = true,
			hint_display = "delayed",
		},
		windows = {
			---@type "right" | "left" | "top" | "bottom"
			position = "right", -- 侧边栏的位置
			wrap = true, -- 类似于 vim.o.wrap
			width = 45, -- 默认基于可用宽度的百分比
			border = {
				side = "left",
				style = "single", -- 可以是 "single", "double", "rounded", "solid", "shadow"
			},
			sidebar_header = {
				enabled = true, -- true, false 启用/禁用标题
				align = "center", -- left, center, right 用于标题
				rounded = true,
			},
			spinner = {
				editing = {
					"⡀",
					"⠄",
					"⠂",
					"⠁",
					"⠈",
					"⠐",
					"⠠",
					"⢀",
					"⣀",
					"⢄",
					"⢂",
					"⢁",
					"⢈",
					"⢐",
					"⢠",
					"⣠",
					"⢤",
					"⢢",
					"⢡",
					"⢨",
					"⢰",
					"⣰",
					"⢴",
					"⢲",
					"⢱",
					"⢸",
					"⣸",
					"⢼",
					"⢺",
					"⢹",
					"⣹",
					"⢽",
					"⢻",
					"⣻",
					"⢿",
					"⣿",
				},
				generating = { "·", "✢", "✳", "∗", "✻", "✽" }, -- '生成中' 状态的旋转字符
				thinking = { "🤯", "🙄" }, -- '思考中' 状态的旋转字符
			},
			input = {
				prefix = "> ",
				height = 8, -- 垂直布局中输入窗口的高度
			},
			edit = {
				border = "rounded",
				start_insert = true, -- 打开编辑窗口时开始插入模式
			},
			ask = {
				floating = false, -- 在浮动窗口中打开 'AvanteAsk' 提示
				start_insert = true, -- 打开询问窗口时开始插入模式
				border = "rounded",
				---@type "ours" | "theirs"
				focus_on_apply = "ours", -- 应用后聚焦的差异
			},
		},
		highlights = {
			---@type AvanteConflictHighlights
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},
		--- @class AvanteConflictUserConfig
		diff = {
			autojump = true,
			---@type string | fun(): any
			list_opener = "copen",
			--- 覆盖悬停在差异上时的 'timeoutlen' 设置（请参阅 :help timeoutlen）。
			--- 有助于避免进入以 `c` 开头的差异映射的操作员挂起模式。
			--- 通过设置为 -1 禁用。
			override_timeoutlen = 500,
		},
		suggestion = {
			debounce = 600,
			throttle = 600,
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- 以下依赖项是可选的，
		-- "echasnovski/mini.pick", -- 用于文件选择器提供者 mini.pick
		-- "nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
		-- "hrsh7th/nvim-cmp", -- avante 命令和提及的自动完成
		-- "ibhagwan/fzf-lua", -- 用于文件选择器提供者 fzf
		"nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
		-- "zbirenbaum/copilot.lua", -- 用于 providers='copilot'
		{
			-- 如果您有 lazy=true，请确保正确设置
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
