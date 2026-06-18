local mp = require("mp")

-- 配置参数
local i_short_press_seek = 1 -- i 键短按前进 5 秒
local long_press_speed = 3.0 -- 长按设置为 3 倍速
local long_press_threshold = 0.5 -- 长按阈值（秒）

-- 内部状态
local is_holding = false
local press_start_time = 0
-- local original_speed = 1.0
local active_key = nil

-- 按下时触发
function on_key_press(key)
	is_holding = true
	active_key = key
	press_start_time = mp.get_time()
	-- 启动定时器检查长按
	mp.add_timeout(long_press_threshold, function()
		check_long_press(key)
	end)
end

-- 检查是否为长按
function check_long_press(key)
	if is_holding and active_key == key then
		-- 长按：设置播放速度为 3 倍
		original_speed = mp.get_property_number("speed")
		mp.set_property_number("speed", long_press_speed)
		mp.osd_message("Speed set to " .. long_press_speed .. "x")
	end
end

-- 释放按键时触发
function on_key_release(key)
	if is_holding and active_key == key then
		local press_duration = mp.get_time() - press_start_time
		if press_duration < long_press_threshold then
			-- 短按：根据按键执行 seek
			if key == "RIGHT" then
				mp.commandv("seek", i_short_press_seek, "relative", "exact")
			end
		else
			-- 长按后松开：恢复速度为 1
			mp.set_property_number("speed", 1.0)
			mp.osd_message("Speed restored to 1x")
		end
		is_holding = false
		active_key = nil
	end
end

-- 绑定 i 键的按下和释放
mp.add_key_binding("RIGHT", "seek-forward-speed", function(event)
	if event.event == "down" then
		on_key_press("RIGHT")
	elseif event.event == "up" then
		on_key_release("RIGHT")
	end
end, { complex = true })
