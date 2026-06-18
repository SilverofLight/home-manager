local M = {}

local function is_in_mermaid_block()
  local filetype = vim.bo.filetype
  if filetype ~= "markdown" then
    vim.notify("Not a markdown file")
    return false
  end

  local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
  if node:type() ~= "code_fence_content" then
    vim.notify("Not a code block")
    return false
  end

  local parent = node:parent()
  while parent and parent:type() ~= "fenced_code_block" do
    parent = parent:parent()
  end
  for child in parent:iter_children() do
    if child:type() == "info_string" then
      local lang = vim.treesitter.get_node_text(child, 0)
      if lang:match("^%s*mermaid") then
        return vim.treesitter.get_node_text(node, 0)
      else
        vim.notify("Not a mermaid block")
        return false
      end
    end
  end

  return false
end

local function GetTerm()
  if os.getenv('KITTY_PID') ~= nil then
    return 'kitty'
  elseif os.getenv('WEZTERM_PANE') ~= nil then
    return 'wezterm'
  else
    return nil
  end
end

local function PreviewImage(absolutePath)
  local term = GetTerm()

  local command = ""

  if term == 'wezterm' then
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      command = "silent !wezterm cli split-pane -- powershell wezterm imgcat "
          .. "'" .. absolutePath .. "'"
          .. " ; pause"
    else
      command = "silent !wezterm cli split-pane -- bash -c 'wezterm imgcat \"" .. absolutePath .. "\" ; read'"
    end
  elseif term == 'kitty' then
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      print('Kitty not supported on windows')
    else
      command = 'silent !kitten @ launch --type=window kitten icat --hold "' .. absolutePath .. '"'
    end
  else
    print('No support for this terminal.')
  end

  vim.api.nvim_command(command)
end

function M.preview_mermaid()
  local code = is_in_mermaid_block()
  if not code then return end

  vim.notify("all right")

  local tmpdir = vim.fn.stdpath("cache") .. "/mermaid_preview"
  vim.fn.mkdir(tmpdir, "p")
  local input_file = tmpdir .. "/diagram.mmd"
  local output_file = tmpdir .. "/diagram.svg"

  -- 写入 mermaid 文件
  local f = io.open(input_file, "w")
  f:write(code)
  f:close()

  -- 调用 mmdc 渲染
  local cmd = string.format("mmdc -i %s -o %s -t dark -b transparent", input_file, output_file)
  vim.api.nvim_command(cmd)
  PreviewImage(output_file)
end

vim.keymap.set("n", "<leader>mm", M.preview_mermaid, { desc = "Toggle mermaid preview" })

return M
