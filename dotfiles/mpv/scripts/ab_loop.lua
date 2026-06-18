local mp = require("mp")

-- 设置 ab-loop-a
local function set_a()
	local current_pos = mp.get_property_number("time-pos")
	mp.set_property_number("ab-loop-a", current_pos)
	mp.osd_message(string.format("Set ab-loop-a to %.2f", current_pos))
end

-- 设置 ab-loop-b
local function set_b()
	local current_pos = mp.get_property_number("time-pos")
	mp.set_property_number("ab-loop-b", current_pos)
	mp.osd_message(string.format("Set ab-loop-b to %.2f", current_pos))
end

-- 清除 ab-loop-a
local function clear_a()
	local pos = mp.get_property_number("ab-loop-a")
	if pos then
		mp.set_property("ab-loop-a", "no")
		mp.osd_message("Cleared ab-loop-a")
	else
		mp.osd_message("No ab-loop-a set")
	end
end

-- 清除 ab-loop-b
local function clear_b()
	local pos = mp.get_property_number("ab-loop-b")
	if pos then
		mp.set_property("ab-loop-b", "no")
		mp.osd_message("Cleared ab-loop-b")
	else
		mp.osd_message("No ab-loop-b set")
	end
end

-- 回到 ab-loop-a 的位置
local function seek_to_a()
	local pos = mp.get_property_number("ab-loop-a")
	if pos then
		mp.set_property_number("time-pos", pos)
		mp.osd_message(string.format("Seek to ab-loop-a: %.2f", pos))
	else
		mp.osd_message("No ab-loop-a set")
	end
end

-- 绑定按键
mp.add_key_binding("BS", "seek-to-a", seek_to_a)
mp.add_key_binding("[", "set-a", set_a)
mp.add_key_binding("{", "clear-a", clear_a)
mp.add_key_binding("]", "set-b", set_b)
mp.add_key_binding("}", "clear-b", clear_b)
