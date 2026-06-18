return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = 'xelatex'
    vim.g.vimtex_mappings_enabled = false
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = '-xelatex'
    }
    vim.g.vimtex_toc_config = {
      layer_status = {
        content = 1,
        label = 0,
        todo = 1,
        include = 1
      },
      show_help = 0,
      split_width = 30,
    }
    vim.keymap.set('n', '<leader>ll', '<plug>(vimtex-compile)')
    vim.keymap.set('n', '<leader>j', '<plug>(vimtex-toc-toggle)')
  end
}
