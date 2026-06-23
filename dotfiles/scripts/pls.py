#!/home/silver/.conda/envs/main/bin/python

# 用于预生成视频预览，并使用交互式查看。可以使用 mpv 播放视频
# require: python-opencv, kitty

import argparse
import hashlib
from pathlib import Path
import cv2
import curses
import os
import subprocess
import sys

VIDEO_EXTENSIONS = {'.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ts', '.m2ts'}

cache_dir = Path.home() / '.cache' / 'pls'
cache_dir.mkdir(parents=True, exist_ok=True)

def get_frame_path(video_path):
    abs_path = video_path.resolve()
    path_hash = hashlib.md5(str(abs_path).encode()).hexdigest()[:8]
    safe_name = abs_path.name.replace(' ', '_')
    return cache_dir / f"{path_hash}_{safe_name}.jpg"

def extract_frames():
    for f in Path('.').iterdir():
        if not (f.is_file() and f.suffix.lower() in VIDEO_EXTENSIONS):
            continue
            
        output_path = get_frame_path(f)
        
        if output_path.exists():
            print(f"跳过（已存在）: {f.name}")
            continue
        
        cap = cv2.VideoCapture(str(f))
        fps = cap.get(cv2.CAP_PROP_FPS)
        frames = cap.get(cv2.CAP_PROP_FRAME_COUNT)
        
        if fps <= 0 or frames <= 0:
            cap.release()
            continue
        
        cap.set(cv2.CAP_PROP_POS_FRAMES, int(frames / 2))
        ret, frame = cap.read()
        cap.release()
        
        if not ret:
            continue
        
        cv2.imwrite(str(output_path), frame)
        print(f"提取完成: {f.name} -> {output_path.name}")

def find_missing_previews(root='.'):
    """
    递归查找 root 下所有视频文件，检查其预览截图是否已存在，
    输出缺失预览截图的文件路径（相对 root 的路径）。
    """
    root_path = Path(root).resolve()
    missing = []

    # 使用 rglob 递归匹配所有文件
    for f in root_path.rglob('*'):
        if not f.is_file():
            continue
        if f.suffix.lower() not in VIDEO_EXTENSIONS:
            continue

        preview_path = get_frame_path(f)
        if not preview_path.exists():
            # 输出相对路径，便于阅读
            rel_path = f.relative_to(Path.cwd())
            missing.append(str(rel_path))

    if missing:
        print("以下视频文件尚未生成预览截图：")
        for path in missing:
            print(path)
    else:
        print("所有视频文件均已生成预览截图。")

class FileBrowser:
    """终端文件浏览器，左侧单列文件列表，右侧视频预览（修复重叠版）"""

    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.path = os.getcwd()
        self.files = []
        self.selected = 0
        self.last_selected = -1

        self.video_exts = {
            '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm',
            '.m4v', '.mpg', '.mpeg', '.3gp', '.ogv', '.ts', '.m2ts'
        }

        self.cache_dir = Path.home() / '.cache' / 'pls'
        self.cache_dir.mkdir(parents=True, exist_ok=True)

        self.BG_COLOR = 16
        self.VIDEO_FG = 17

        self.list_win = None
        self.preview_width = 80
        self.left_width = 0

        self.init_colors()
        self.load_files()
        self.create_list_window()

    def init_colors(self):
        curses.start_color()
        curses.use_default_colors()

        can_change = False
        try:
            can_change = curses.can_change_color() and curses.COLORS >= 256
        except:
            pass

        if can_change:
            try:
                curses.init_color(self.BG_COLOR, 30*1000//255, 30*1000//255, 46*1000//255)
                curses.init_color(self.VIDEO_FG, 245*1000//255, 194*1000//255, 231*1000//255)
                bg_color = self.BG_COLOR
                video_fg = self.VIDEO_FG
            except:
                can_change = False

        if not can_change:
            bg_color = curses.COLOR_BLACK
            video_fg = 13

        curses.init_pair(1, curses.COLOR_GREEN, bg_color)
        curses.init_pair(2, curses.COLOR_WHITE, bg_color)
        curses.init_pair(3, video_fg, bg_color)
        curses.init_pair(4, bg_color, bg_color)

        self.stdscr.bkgd(' ', curses.color_pair(4))

    def create_list_window(self):
        height, width = self.stdscr.getmaxyx()
        self.preview_width = min(self.preview_width, width - 10)
        self.left_width = width - self.preview_width - 1
        if self.left_width < 10:
            self.left_width = 10
            self.preview_width = width - self.left_width - 1
        win_height = height - 2
        self.list_win = curses.newwin(win_height, self.left_width, 1, 0)

    def load_files(self):
        try:
            entries = os.listdir(self.path)
        except PermissionError:
            entries = []

        file_list = []
        for name in entries:
            full = os.path.join(self.path, name)
            try:
                is_dir = os.path.isdir(full)
            except PermissionError:
                is_dir = False
            file_list.append((name, is_dir))

        def sort_key(item):
            name, is_dir = item
            if is_dir:
                weight = 0
            else:
                ext = os.path.splitext(name)[1].lower()
                weight = 2 if ext in self.video_exts else 1
            return (weight, name.lower())

        file_list.sort(key=sort_key)

        parent = os.path.dirname(self.path)
        if parent != self.path:
            self.files = [("..", True)] + file_list
        else:
            self.files = file_list

    def is_video(self, filename):
        return Path(filename).suffix.lower() in self.video_exts

    def get_cache_path(self, filename):
        video_path = Path(self.path) / filename
        abs_path = video_path.resolve()
        path_hash = hashlib.md5(str(abs_path).encode()).hexdigest()[:8]
        safe_name = abs_path.name.replace(' ', '_')
        return self.cache_dir / f"{path_hash}_{safe_name}.jpg"

    def update_preview(self):
        if self.selected == self.last_selected:
            return
        self.last_selected = self.selected

        name, is_dir = self.files[self.selected]

        # 关键修复1：先确保curses的所有更新都刷到屏幕
        # 这样在icat操作前，curses的虚拟屏幕和物理屏幕是一致的
        curses.doupdate()

        # 关键修复2：使用redrawwin强制重绘列表窗口，避免差异更新问题
        # 这确保列表区域被完全重绘，不会留下旧的高亮痕迹
        self.list_win.redrawwin()
        self.list_win.noutrefresh()
        curses.doupdate()

        # 关键修复3：清除预览区域（使用icat --clear）
        try:
            clear_proc = subprocess.run(['kitty', '+kitten', 'icat', '--clear'],
                                        capture_output=True, check=False)
            if clear_proc.stdout:
                sys.stdout.buffer.write(clear_proc.stdout)
                sys.stdout.flush()  # 确保clear立即执行
        except Exception:
            pass

        # 关键修复4：如果是视频，显示预览图
        if not is_dir and self.is_video(name):
            img_path = self.get_cache_path(name)
            if img_path.exists():
                height, width = self.stdscr.getmaxyx()
                start_x = self.left_width + 1
                start_y = 1
                preview_height = height - 2
                try:
                    display_proc = subprocess.run([
                        'kitty', '+kitten', 'icat',
                        '--place', f'{self.preview_width}x{preview_height}@{start_x}x{start_y}',
                        str(img_path)
                    ], capture_output=True, check=False)
                    if display_proc.stdout:
                        sys.stdout.buffer.write(display_proc.stdout)
                        sys.stdout.flush()  # 确保图片立即显示
                except Exception:
                    pass
            else:
                # self.show_message("Preview not found. Run: extract_frames.py -g")
                self.draw_preview_notice("Preview not found.", "Run pls -g first.")

        # 关键修复5：刷新列表窗口到物理屏幕，确保高亮状态正确
        # 使用redrawwin而不是普通的noutrefresh，强制完整重绘
        self.list_win.redrawwin()
        self.list_win.noutrefresh()
        curses.doupdate()

    def draw_preview_notice(self, line1, line2):
        """在右侧预览区域绘制带边框的提示信息（使用 curses）"""
        height, width = self.stdscr.getmaxyx()
        start_x = self.left_width + 1
        start_y = 1
        preview_height = height - 2
        preview_width = self.preview_width

        # 区域太小则忽略
        if preview_height < 3 or preview_width < 6:
            return

        try:
            # 使用颜色对 2（白色前景）
            self.stdscr.attron(curses.color_pair(2))
    
            # 画边框（使用 ASCII 字符，保证兼容性）
            # 上边框
            self.stdscr.addstr(start_y, start_x, '+' + '-' * (preview_width - 2) + '+')
            # 下边框
            self.stdscr.addstr(start_y + preview_height - 1, start_x, '+' + '-' * (preview_width - 2) + '+')
            # 左右边框
            for y in range(start_y + 1, start_y + preview_height - 1):
                self.stdscr.addstr(y, start_x, '|')
                self.stdscr.addstr(y, start_x + preview_width - 1, '|')

            # 居中显示文本
            x1 = start_x + (preview_width - len(line1)) // 2
            y1 = start_y + preview_height // 2 - 1
            self.stdscr.addstr(y1, x1, line1)

            x2 = start_x + (preview_width - len(line2)) // 2
            self.stdscr.addstr(y1 + 1, x2, line2)

            self.stdscr.attroff(curses.color_pair(2))
        except curses.error:
            # 忽略绘制超出边界的错误（例如终端太小）
            pass

        # 标记 stdscr 需要刷新
        self.stdscr.noutrefresh()

    def draw(self):
        # 关键修复6：使用redrawwin强制完整重绘，避免差异更新导致的残影
        self.stdscr.redrawwin()
        self.stdscr.erase()
        height, width = self.stdscr.getmaxyx()

        # 标题
        title = f"Path: {self.path}"
        self.stdscr.addstr(0, 0, title[:width-1], curses.color_pair(2))

        # 底部提示行
        hint = "n/e: move, h: back, Enter/i: open, g/G: goto top/bottom, q: quit"
        self.stdscr.addstr(height-1, 0, hint[:width-1], curses.color_pair(2))

        self.stdscr.noutrefresh()

        if not self.files:
            self.list_win.erase()
            self.list_win.addstr(0, 0, "(empty)", curses.color_pair(2))
            self.list_win.noutrefresh()
            curses.doupdate()
            return

        # 关键修复7：使用redrawwin强制列表窗口完整重绘
        self.list_win.redrawwin()
        self.list_win.erase()

        visible_rows = self.list_win.getmaxyx()[0]
        total_rows = len(self.files)

        # 计算起始行（使选中行居中）
        if total_rows > visible_rows:
            start_row = self.selected - visible_rows // 2
            start_row = max(0, min(start_row, total_rows - visible_rows))
        else:
            start_row = 0

        for r in range(visible_rows):
            idx = start_row + r
            if idx >= total_rows:
                break
            name, is_dir = self.files[idx]
            display = name[:self.left_width-2]
            fmt = f"{display:<{self.left_width-2}}"

            if is_dir:
                color_pair = 1
            else:
                color_pair = 3 if self.is_video(name) else 2

            attr = curses.A_REVERSE if idx == self.selected else 0

            # 先移动到行首并清除整行，防止残留属性
            self.list_win.move(r, 0)
            self.list_win.clrtoeol()
            try:
                self.list_win.addstr(r, 0, fmt, curses.color_pair(color_pair) | attr)
            except curses.error:
                pass

        self.list_win.noutrefresh()
        # 注意：这里不调用doupdate()，让update_preview()或run()统一处理

    def move(self, steps):
        new_idx = self.selected + steps
        if 0 <= new_idx < len(self.files):
            self.selected = new_idx
            self.draw()
            self.update_preview()
        elif 0 > new_idx:
            self.go_top()
        else:
            self.go_bottom()

    def handle_enter(self):
        if not self.files:
            return
        name, is_dir = self.files[self.selected]
        
        if not is_dir and self.is_video(name):
            full_path = os.path.join(self.path, name)
            self.play_video(full_path)
            return

        if name == "..":
            new_path = os.path.dirname(self.path)
        else:
            new_path = os.path.join(self.path, name)

        if is_dir:
            try:
                os.chdir(new_path)
                self.path = os.getcwd()
                self.load_files()
                self.selected = 0
                self.last_selected = -1
                self.create_list_window()
                self.draw()
                self.update_preview()
            except PermissionError:
                self.show_message("Permission denied")
        else:
            self.show_message("Not a directory")

    def go_up(self):
        parent = os.path.dirname(self.path)
        if parent != self.path:
            current_dir_name = os.path.basename(self.path)
            try:
                os.chdir(parent)
                self.path = os.getcwd()
                self.load_files()
                # 查找返回之前的目录
                new_selected = 0
                for idx, (name, is_dir) in enumerate(self.files):
                    if is_dir and name == current_dir_name:
                        new_selected = idx
                        break
                self.selected = new_selected
                self.last_selected = -1
                self.create_list_window()
                self.draw()
                self.update_preview()
            except PermissionError:
                self.show_message("Permission denied")
        else:
            self.show_message("Already at root")

    def show_message(self, msg):
        height, width = self.stdscr.getmaxyx()
        self.stdscr.addstr(height-1, 0, msg[:width-1], curses.color_pair(2))
        self.stdscr.refresh()
        curses.napms(1000)

    def play_video(self, filepath):
        """使用 mpv 播放视频文件"""
        try:
            # 先清除 icat 预览，避免画面残留
            subprocess.run(['kitty', '+kitten', 'icat', '--clear'],
                           capture_output=True, check=False)
            # 运行 mpv，阻塞直到退出
            subprocess.run(['mpv', '--save-position-on-quit=no', filepath], check=True)
        except FileNotFoundError:
            self.show_message("mpv not found. Please install mpv.")
        except subprocess.CalledProcessError:
            self.show_message("mpv failed to play the file.")
        except Exception as e:
            self.show_message(f"Error: {str(e)[:20]}")
        finally:
            # 播放结束后刷新界面
            self.draw()
            self.update_preview()

    def go_top(self):
        """跳转到列表最上"""
        if not self.files:
            return
        self.selected = 0
        self.last_selected = -1  # 强制预览刷新
        self.draw()
        self.update_preview()

    def go_bottom(self):
        """跳转到列表最下"""
        if not self.files:
            return
        self.selected = len(self.files) - 1
        self.last_selected = -1  # 强制预览刷新
        self.draw()
        self.update_preview()

    def run(self):
        # 初始绘制
        self.draw()
        self.update_preview()
        
        while True:
            # 关键修复9：每次循环确保屏幕状态一致
            curses.doupdate()
            
            key = self.stdscr.getch()

            if key == ord('q'):
                try:
                    clear_proc = subprocess.run(['kitty', '+kitten', 'icat', '--clear'],
                                                capture_output=True, check=False)
                    if clear_proc.stdout:
                        sys.stdout.buffer.write(clear_proc.stdout)
                        sys.stdout.flush()
                except Exception:
                    pass
                break
            elif key == ord('n'):
                self.move(1)
            elif key == ord('e'):
                self.move(-1)
            elif key == 14: # Ctrl+n
                self.move(5)
            elif key == 5: # Ctrl+e
                self.move(-5)
            elif key == 4: # Ctrl+d
                self.move(20)
            elif key == 12: # Ctrl+l
                self.move(-20)
            elif key == ord('h'):
                self.go_up()
            elif key == ord('i') or key == ord('o'):
                self.handle_enter()
            elif key == ord('\n'):
                self.handle_enter()
            elif key == ord('g'):
                self.go_top()
            elif key == ord('G'):
                self.go_bottom()
            elif key == curses.KEY_RESIZE:
                self.create_list_window()
                self.draw()
                self.update_preview()


def tui():
    stdscr = curses.initscr()
    curses.cbreak()
    curses.noecho()
    curses.curs_set(0)
    stdscr.keypad(True)

    try:
        browser = FileBrowser(stdscr)
        browser.run()
    finally:
        curses.nocbreak()
        stdscr.keypad(False)
        curses.echo()
        curses.curs_set(1)
        curses.endwin()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='视频中间帧提取与预览工具',
        epilog='如果没有指定任何参数，默认进入交互模式。'
    )
    parser.add_argument('-g', '--generate', action='store_true', help='执行帧提取（仅当前目录）')
    parser.add_argument('-i', '--interaction', action='store_true', help='交互模式（显式指定）')
    parser.add_argument('-s', '--search', action='store_true', help='递归查找当前目录下所有未生成预览截图的视频文件')
    args = parser.parse_args()
    
    # 如果指定了多个操作，按优先级处理（search > generate > interaction）
    if args.search:
        find_missing_previews()
    elif args.generate:
        extract_frames()
    elif args.interaction:
        tui()
    else:
        # 无任何参数，默认进入交互模式
        tui()
