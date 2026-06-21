-- ======================
-- General
-- ======================
swayimg.on_initialized(function()
	swayimg.set_mode("viewer")
	swayimg.viewer.reload()
end)

-- 信号绑定
swayimg.viewer.on_signal("USR1", function()
	swayimg.viewer.reload()
end)

swayimg.viewer.on_signal("USR2", function()
	swayimg.viewer.switch_image("next")
end)

-- ======================
-- Viewer
-- ======================
-- 背景色（#1e1e2eee → ARGB）
swayimg.viewer.set_window_background(0xee1e1e2e)
swayimg.viewer.set_image_background(0xff282a36)

-- scale = optimal
swayimg.viewer.set_default_scale("fit")

-- history / preload
swayimg.viewer.limit_history(1)
swayimg.viewer.limit_preload(1)

-- ======================
-- Gallery
-- ======================
swayimg.gallery.set_thumb_size(200)
swayimg.gallery.limit_cache(100)

-- border_color = #bd93faff
swayimg.gallery.set_border_color(0xffbd93fa)

-- window/background
swayimg.gallery.set_window_color(0xee1e1e2e)
swayimg.gallery.set_unselected_color(0xee1e1e2e)

-- select = #cba6f7ff
swayimg.gallery.set_selected_color(0xffcba6f7)

-- ======================
-- Image list
-- ======================
swayimg.imagelist.set_order("alpha")
swayimg.imagelist.enable_recursive(false)

-- all = yes → adjacent
swayimg.imagelist.enable_adjacent(true)

-- ======================
-- Font / Text
-- ======================
swayimg.text.set_font("Sarasa Term SC")
swayimg.text.set_size(14)
swayimg.text.set_foreground(0xffffffff)
swayimg.text.set_shadow(0xff000000)

-- info 超时
swayimg.text.set_timeout(0)
swayimg.text.set_status_timeout(0)

-- 默认隐藏
swayimg.text.hide()

-- ======================
-- Info (viewer)
-- ======================
swayimg.viewer.set_text("topleft", {
	"{name}",
	"{format}",
	"{sizehr}",
	"{frame.width}x{frame.height}",
	"{meta.*}",
})

swayimg.viewer.set_text("topright", {
	"{list.index}/{list.total}",
})

swayimg.viewer.set_text("bottomleft", {
	"{scale}%",
	"{frame.index}/{frame.total}",
})

swayimg.viewer.set_text("bottomright", {
	"{status}",
})

-- ======================
-- Info (gallery)
-- ======================
swayimg.gallery.set_text("bottomright", {
	"{name}",
	"{status}",
})

-- ======================
-- Keybindings (viewer)
-- ======================
local v = swayimg.viewer

v.bind_reset()

v.on_key("g", function()
	v.switch_image("first")
end)
v.on_key("Shift-g", function()
	v.switch_image("last")
end)
v.on_key("p", function()
	v.switch_image("prev")
end)
v.on_key("k", function()
	v.switch_image("next")
end)
v.on_key("Shift-k", function()
	v.switch_image("next_dir")
end)

v.on_key("c", function()
	v.switch_image("next")
end)

-- 模式切换
v.on_key("o", function()
	swayimg.set_mode("gallery")
end)

-- 移动
local function move(dx, dy)
	local pos = v.get_position()
	v.set_abs_position(pos.x + dx, pos.y + dy)
end

v.on_key("i", function()
	move(-20, 0)
end)
v.on_key("h", function()
	move(20, 0)
end)
v.on_key("n", function()
	move(0, -20)
end)
v.on_key("e", function()
	move(0, 20)
end)

v.on_key("Shift-h", function()
	move(-1, 0)
end)
v.on_key("Shift-i", function()
	move(1, 0)
end)
v.on_key("Shift-e", function()
	move(0, -1)
end)
v.on_key("Shift-n", function()
	move(0, 1)
end)

-- 缩放
local function zoom(factor)
	local s = v.get_scale()
	v.set_abs_scale(s * factor)
end

v.on_key("equal", function()
	zoom(1.1)
end)
v.on_key("minus", function()
	zoom(0.9)
end)

v.on_key("w", function()
	v.set_fix_scale("width")
end)
v.on_key("z", function()
	v.set_fix_scale("fit")
end)
v.on_key("f", function()
	v.set_fix_scale("fill")
end)
v.on_key("0", function()
	v.set_fix_scale("real")
end)
v.on_key("BackSpace", function()
	v.set_fix_scale("optimal")
end)

-- 旋转/翻转
v.on_key("r", function()
	v.rotate(270)
end)
v.on_key("Ctrl-r", function()
	v.rotate(90)
end)
v.on_key("v", function()
	v.flip_vertical()
end)
v.on_key("x", function()
	v.flip_horizontal()
end)

-- 动画
v.on_key("a", function()
	v.set_animation(not v.get_animation())
end)

-- reload
v.on_key("Shift-r", function()
	v.reload()
end)

-- info toggle
v.on_key("m", function()
	if swayimg.text.visible() then
		swayimg.text.hide()
	else
		swayimg.text.show()
	end
end)

-- exec
v.on_key("Shift-w", function()
	local img = v.get_image()
	os.execute('awww img "' .. img.path .. '" -t random')
end)

v.on_key("Shift-y", function()
	local img = v.get_image()
	os.execute('cp "' .. img.path .. '" ~/Public/')
end)

-- exit
v.on_key("Escape", function()
	swayimg.exit()
end)
v.on_key("q", function()
	swayimg.exit()
end)

-- ======================
-- Keybindings (gallery)
-- ======================
local g = swayimg.gallery

g.bind_reset()

g.on_key("g", function()
	g.switch_image("first")
end)
g.on_key("Shift-g", function()
	g.switch_image("last")
end)

g.on_key("h", function()
	g.switch_image("left")
end)
g.on_key("i", function()
	g.switch_image("right")
end)
g.on_key("e", function()
	g.switch_image("up")
end)
g.on_key("n", function()
	g.switch_image("down")
end)

g.on_key("p", function()
	g.switch_image("pgup")
end)
g.on_key("k", function()
	g.switch_image("pgdown")
end)

g.on_key("Return", function()
	swayimg.set_mode("viewer")
end)
g.on_key("o", function()
	swayimg.set_mode("viewer")
end)

g.on_key("r", function()
	swayimg.viewer.reload()
end)

g.on_key("m", function()
	if swayimg.text.visible() then
		swayimg.text.hide()
	else
		swayimg.text.show()
	end
end)

g.on_key("Shift-w", function()
	local img = g.get_image()
	os.execute('awww img "' .. img.path .. '" -t random')
end)

g.on_key("Shift-y", function()
	local img = g.get_image()
	os.execute('cp "' .. img.path .. '" ~/Public/')
end)

g.on_key("Escape", function()
	swayimg.exit()
end)
g.on_key("q", function()
	swayimg.exit()
end)
