#!/bin/env python

# requires mpv
# 需要在 mpv 中设置 save-watch-history

import json
import os
import sys
import curses
import subprocess

# 文件路径，假设数据存储在 input.json 文件中
home = os.getenv("HOME")
file_path = os.path.join(home, ".local", "state", "mpv", "watch_history.jsonl")

# 读取文件中的 JSON 行数据
data = []
if os.path.exists(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            try:
                item = json.loads(line.strip())
                data.append(item)
            except json.JSONDecodeError:
                print(f"Skipping invalid JSON line: {line.strip()}")
else:
    print(f"File not found: {file_path}")
    exit(1)

# 去重并倒序处理数据，同时保留路径信息
seen = set()
unique_items = []
for item in reversed(data):
    output = item.get("title", os.path.basename(item["path"]))
    if output not in seen:
        seen.add(output)
        # 保存显示名称和实际路径
        unique_items.append({
            "display": output,
            "path": item["path"]
        })

# 终端界面函数
def main(stdscr):
    # 设置 curses
    curses.curs_set(0)  # 隐藏光标
    stdscr.timeout(100)  # 刷新频率
    current_row = 0  # 当前选中行
    scroll_pos = 0   # 滚动位置
    
    # 获取终端尺寸
    height, width = stdscr.getmaxyx()
    
    # 确保有足够的空间显示
    if height < 3 or width < 10:
        return None

    while True:
        stdscr.clear()
        
        # 计算可见区域
        visible_height = height - 3  # 减去标题行和状态行
        
        # 调整滚动位置，确保当前行可见
        if current_row < scroll_pos:
            scroll_pos = current_row
        elif current_row >= scroll_pos + visible_height:
            scroll_pos = current_row - visible_height + 1
            
        # 显示标题
        title = "Select an item (UP/e=上移, DOWN/n=下移, ENTER=播放, Q=退出):"
        try:
            stdscr.addstr(0, 0, title[:width-1], curses.A_BOLD)
        except:
            pass

        # 显示列表并高亮选中项
        for i in range(visible_height):
            idx = i + scroll_pos
            if idx >= len(unique_items):
                break
                
            # 截断过长的字符串
            display_text = unique_items[idx]['display']
            if len(display_text) > width - 2:
                display_text = display_text[:width-5] + "..."
                
            try:
                if idx == current_row:
                    stdscr.addstr(i + 1, 0, f"> {display_text}", curses.A_REVERSE)
                else:
                    stdscr.addstr(i + 1, 0, f"  {display_text}")
            except:
                # 如果写入失败，跳过此项
                continue

        # 显示滚动状态
        status_line = f" 项目 {current_row + 1}/{len(unique_items)} "
        if len(unique_items) > visible_height:
            status_line += f" [滚动: {scroll_pos + 1}-{min(scroll_pos + visible_height, len(unique_items))}]"
        try:
            stdscr.addstr(height-1, 0, status_line[:width-1], curses.A_REVERSE)
        except:
            pass

        stdscr.refresh()

        # 获取用户输入
        try:
            key = stdscr.getch()
        except:
            continue

        # 处理按键
        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == ord('e') and current_row > 0:  # e 键上移
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(unique_items) - 1:
            current_row += 1
        elif key == ord('n') and current_row < len(unique_items) - 1:  # n 键下移
            current_row += 1
        elif key == curses.KEY_HOME or key == ord('g'):  # Home
            current_row = 0
        elif key == curses.KEY_END or key == ord('G'):  # End
            current_row = len(unique_items) - 1
        elif key == ord('n')-96: # C-n
            current_row += 5
        elif key == ord('e')-96: # C-e
            current_row -= 5
        elif key in [10, curses.KEY_ENTER]:
            selected_item = unique_items[current_row]
            return selected_item["path"]
        elif key == ord('q') or key == ord('Q'):
            return None

# 运行 curses 程序
if __name__ == "__main__":
    selected_path = None
    
    if len(sys.argv) < 2:
        if unique_items:
            selected_path = unique_items[0]["path"]
        else:
            print("没有找到历史记录")
            exit(1)
    elif sys.argv[1] == "-l":
        if not unique_items:
            print("没有找到历史记录")
            exit(0)
        selected_path = curses.wrapper(main)
    else:
        print("使用方法：")
        print("mpvh.py -l == 查看历史记录列表")
        print("mpvh.py    == 打开最后播放的视频")
        exit(1)
    
    if selected_path:
        print(f"正在使用 mpv 播放: {selected_path}")
        # 使用 mpv 播放选中的文件
        try:
            subprocess.run(["mpv", selected_path])
        except FileNotFoundError:
            print("错误: 未找到 mpv 播放器，请确保已安装 mpv")
        except Exception as e:
            print(f"播放时出错: {str(e)}")
