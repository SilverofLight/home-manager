-- cmp
local cmp = require("cmp")
local lspkind = require('lspkind')

local has_words_before = function()
  local col = vim.fn.col('.') - 1
  return col > 0 and vim.fn.getline('.'):sub(col, col):match('%s') == nil
end
cmp.setup({
  view = {
    entries = "custom"
  },
  formatting = {
    format = lspkind.cmp_format(),
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = "snippets" },
    { name = "buffer" },
    { name = "path" },
    -- { name = "cmdline"},
    { name = "spell" },
    {
      name = "latex_symbols",
      entry_filter = function()
        return vim.bo.filetype == "markdown"
      end
    }
  }),
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
        cmp.select_next_item()
      elseif vim.snippet.active({ direction = 1 }) then
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.snippet.active({ direction = -1 }) then
        vim.schedule(function()
          vim.snippet.jump(-1)
        end)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  experimental = {
    ghost_text = false,
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- setup lsp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig")['gopls'].setup {
  capabilities = capabilities
}
require("lspconfig")['lua_ls'].setup {
  capabilities = capabilities
}
require("lspconfig")['ruff'].setup {
  capabilities = capabilities
}
require("lspconfig")['vtsls'].setup {
  capabilities = capabilities
}

local clangd_capabilities = require("cmp_nvim_lsp").default_capabilities()
clangd_capabilities.offsetEncoding = { "utf-16" }
require("lspconfig")['clangd'].setup {
  capabilities = clangd_capabilities
}
