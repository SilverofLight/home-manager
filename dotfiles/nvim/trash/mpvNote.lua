-- MpvNote (AI Generated)
local ns = vim.api.nvim_create_namespace("MpvNote")
local hidden_ns = vim.api.nvim_create_namespace("MpvNoteHidden")
local match_list = {}
local last_hovered = nil

-- 创建专用高亮组
vim.cmd("highlight default MpvNoteHidden guifg=bg guibg=bg")

-- 解析并设置隐藏文本
local function setup_mpvnote(bufnr)
  match_list = {}
  last_hovered = nil
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    local s, e, path, time = line:find('%["([^"]+)"%s*;%s*([0-9]+%.[0-9]+)%]')
    if s then
      local full = string.format('["%s"; %s]', path, time)
      local len = e - s + 1

      -- 创建简洁显示文本
      local filename = vim.fn.fnamemodify(path, ":t")
      local display_name = filename:gsub("%.mp4$", ""):gsub("%.webm$", "")
      local short = string.format("🎞️ %s @ %s", display_name, time)

      -- 添加简洁文本显示 (最高优先级)
      local display_mark = vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, s - 1, {
        virt_text = { { short, "Comment" } },
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 1000, -- 非常高的优先级
      })

      -- 隐藏原始文本（用背景色覆盖）
      local hidden_mark = vim.api.nvim_buf_set_extmark(bufnr, hidden_ns, i - 1, s - 1, {
        virt_text = { { string.rep(" ", len), "MpvNoteHidden" } },
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 900, -- 比显示层低
      })

      table.insert(match_list, {
        row = i - 1,
        start_col = s - 1,
        end_col = e,
        short = short,
        full = full,
        hidden_mark = hidden_mark,
        display_mark = display_mark,
        length = len,
        is_visible = false -- 初始为简洁模式
      })
    end
  end
end

-- 显示原始文本（悬停时）
local function show_original_text(m, bufnr)
  -- 删除简洁显示
  pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, m.display_mark)

  -- 删除隐藏覆盖
  pcall(vim.api.nvim_buf_del_extmark, bufnr, hidden_ns, m.hidden_mark)

  m.is_visible = true
end

-- 显示简洁文本（非悬停时）
local function show_short_text(m, bufnr)
  -- 如果已经处于简洁模式，无需操作
  if not m.is_visible then return end

  -- 重新添加简洁文本显示 (先添加)
  m.display_mark = vim.api.nvim_buf_set_extmark(bufnr, ns, m.row, m.start_col, {
    virt_text = { { m.short, "Comment" } },
    virt_text_pos = "overlay",
    hl_mode = "combine",
    priority = 1000,
  })

  -- 重新添加隐藏覆盖 (后添加)
  m.hidden_mark = vim.api.nvim_buf_set_extmark(bufnr, hidden_ns, m.row, m.start_col, {
    virt_text = { { string.rep(" ", m.length), "MpvNoteHidden" } },
    virt_text_pos = "overlay",
    hl_mode = "combine",
    priority = 900,
  })

  m.is_visible = false
end

-- 光标移动事件处理
local function on_cursor_move()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local current_hover = nil

  -- 检查光标是否悬停在标记上
  for _, m in ipairs(match_list) do
    if m.row == row and col >= m.start_col and col <= m.end_col then
      current_hover = m
      break
    end
  end

  -- 处理上次悬停的标记（如果存在且需要恢复）
  if last_hovered and last_hovered ~= current_hover and last_hovered.is_visible then
    show_short_text(last_hovered, bufnr)
  end

  -- 处理当前悬停的标记
  if current_hover and not current_hover.is_visible then
    show_original_text(current_hover, bufnr)
  end

  last_hovered = current_hover
end

-- 自动命令组
local group = vim.api.nvim_create_augroup("MpvNote", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "TextChanged", "TextChangedI" }, {
  group = group,
  callback = function(args)
    setup_mpvnote(args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = group,
  callback = on_cursor_move
})

-- 离开缓冲区时恢复所有标记
vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  callback = function(args)
    for _, m in ipairs(match_list) do
      if m.is_visible then
        show_short_text(m, args.buf)
      end
    end
    last_hovered = nil
  end
})

-- 调试函数：打印所有标记状态
vim.keymap.set("n", "<leader>dd", function()
  print("--- MpvNote Debug ---")
  for i, m in ipairs(match_list) do
    print(string.format("Mark %d: row=%d, col=%d-%d, visible=%s",
      i, m.row, m.start_col, m.end_col, tostring(m.is_visible)))
  end
end, { desc = "Debug MpvNote marks" })
