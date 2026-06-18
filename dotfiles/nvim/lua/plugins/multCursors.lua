return {
	--   "mg979/vim-visual-multi",
	--   event = "VeryLazy",
	--   init = function()
	--     vim.cmd([[
	-- let g:VM_leader                     = {'default': ',', 'visual': ',', 'buffer': ','}
	-- let g:VM_maps                       = {}
	-- let g:VM_custom_motions             = {'h': 'h', 'i': 'l', 'e': 'k', 'n': 'j'}
	-- let g:VM_maps['i']                  = 'u'
	-- let g:VM_maps['I']                  = 'U'
	-- let g:VM_maps['Find Under']         = '<C-k>'
	-- let g:VM_maps['Find Subword Under'] = '<C-k>'
	-- let g:VM_maps['Find Next']          = ''
	-- let g:VM_maps['Find Prev']          = ''
	-- let g:VM_maps['Remove Region']      = 'q'
	-- let g:VM_maps['Skip Region']        = '<c-n>'
	-- let g:VM_maps["Undo"]               = 'l'
	-- let g:VM_maps["Redo"]               = '<C-r>'
	-- let g:VM_maps["Add Cursor Down"]    = '<S-Down>'
	-- let g:VM_maps["Add Cursor Up"]      = '<S-Up>'
	-- "noremap <leader>sa <Plug>(VM-Select-All)
	-- ]])
	--   end
	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		event = "VeryLazy",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set

			-- Add or skip cursor above/below the main cursor.
			set({ "n", "x" }, "<C-up>", function()
				mc.lineAddCursor(-1)
			end)
			set({ "n", "x" }, "<C-down>", function()
				mc.lineAddCursor(1)
			end)
			set({ "n", "x" }, "<leader><up>", function()
				mc.lineSkipCursor(-1)
			end, { desc = "Multcursor ignore line" })
			set({ "n", "x" }, "<leader><down>", function()
				mc.lineSkipCursor(1)
			end, { desc = "Multcursor ignore line" })

			-- Add or skip adding a new cursor by matching word/selection
			set({ "n", "x" }, "<leader>k", function()
				mc.matchAddCursor(1)
			end, { desc = "Multcursor next" })
			set({ "n", "x" }, "<leader>m", function()
				mc.matchSkipCursor(1)
			end, { desc = "Multcursor pre" })
			set({ "n", "x" }, "<leader>K", function()
				mc.matchAddCursor(-1)
			end, { desc = "Multcursor ignore next" })
			set({ "n", "x" }, "<leader>M", function()
				mc.matchSkipCursor(-1)
			end, { desc = "Multcursor ignore pre" })

			-- Add and remove cursors with control + left click.
			set("n", "<c-leftmouse>", mc.handleMouse)
			set("n", "<c-leftdrag>", mc.handleMouseDrag)
			set("n", "<c-leftrelease>", mc.handleMouseRelease)

			-- Disable and enable cursors.
			set({ "n", "x" }, "<c-q>", mc.toggleCursor)

			-- Mappings defined in a keymap layer only apply when there are
			-- multiple cursors. This lets you have overlapping mappings.
			mc.addKeymapLayer(function(layerSet)
				-- Select a different cursor as the main one.
				layerSet({ "n", "x" }, "<left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<right>", mc.nextCursor)

				-- Delete the main cursor.
				layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

				-- Enable and clear cursors using escape.
				layerSet("n", "<esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)

			-- Customize how cursors look.
			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { reverse = true })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorMatchPreview", { link = "Search" })
			hl(0, "MultiCursorDisabledCursor", { reverse = true })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},
}
