#!/bin/env python
import curses
import requests
import json
import time
import os
import logging
import threading
import queue
from datetime import datetime
from urllib.parse import quote

# 设置日志记录
logging.basicConfig(filename=os.path.expanduser('~/.cache/clash_tui.log'), level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def get_first_proxy_group_name(yaml_path):
    """从clash配置文件中获取第一个代理组的名称"""
    try:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        in_proxy_groups = False
        for line in lines:
            # Use strip() to handle potential whitespace
            if line.strip() == 'proxy-groups:':
                in_proxy_groups = True
                continue
            
            if in_proxy_groups:
                stripped_line = line.strip()
                if stripped_line.startswith('- name:'):
                    group_name = stripped_line.split(':', 1)[1].strip()
                    # Remove potential quotes
                    if group_name.startswith("'") and group_name.endswith("'"):
                        return group_name[1:-1]
                    if group_name.startswith('"') and group_name.endswith('"'):
                        return group_name[1:-1]
                    return group_name
        logging.warning("在配置文件中未找到 'proxy-groups' 或任何组.")
        return None
    except FileNotFoundError:
        logging.error(f"Clash配置文件未找到: {yaml_path}")
        return None
    except Exception as e:
        logging.error(f"读取或解析Clash配置文件时出错: {e}")
        return None

# 从环境变量获取密码
PASSWORD = os.getenv("CLASH_PASSWORD", "your_default_password")
# PROXIES_URL = "http://127.0.0.1:9090/proxies/%F0%9F%94%B0%20%E8%8A%82%E7%82%B9%E9%80%89%E6%8B%A9"

# 自动从clash-verge.yaml中查找group
CLASH_CONFIG_PATH = os.path.expanduser('~/.local/share/io.github.clash-verge-rev.clash-verge-rev/clash-verge.yaml')
group_name = get_first_proxy_group_name(CLASH_CONFIG_PATH)

if group_name:
    logging.info(f"从配置文件中找到代理组: {group_name}")
    group = quote(group_name, safe='')
else:
    logging.warning("无法从配置文件中找到代理组, 使用默认值 '辉夜Proxy'")
    group = quote("辉夜Proxy", safe='')

PROXIES_URL = f"http://127.0.0.1:9097/proxies/{group}"


def fetch_proxy_data():
    """从API获取代理节点数据"""
    headers = {"Authorization": f"Bearer {PASSWORD}"}
    try:
        response = requests.get(PROXIES_URL, headers=headers, timeout=3)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"获取节点数据失败: {str(e)}")
        return {"error": str(e)}
    except json.JSONDecodeError:
        logging.error("无效的JSON响应")
        return {"error": "Invalid JSON response"}


def switch_proxy(proxy_name):
    """切换当前代理节点"""
    headers = {
        "Authorization": f"Bearer {PASSWORD}",
        "Content-Type": "application/json"
    }
    data = json.dumps({"name": proxy_name})

    try:
        response = requests.put(
            PROXIES_URL,
            headers=headers,
            data=data,
            timeout=3
        )

        if response.status_code == 204:
            logging.info(f"成功切换到节点: {proxy_name}")
            return True
        else:
            logging.error(f"切换节点失败，状态码: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        logging.error(f"切换节点请求异常: {str(e)}")
        return False


def test_node_latency(node_name, results_queue):
    """测试单个节点的延迟"""
    # 对节点名称进行URL编码
    encoded_name = quote(node_name, safe='')

    # 构建测试URL
    # test_url = f"http://127.0.0.1:9090/providers/proxies/%F0%9F%94%B0%20%E8%8A%82%E7%82%B9%E9%80%89%E6%8B%A9/{
    # encoded_name}/healthcheck"
    test_url = f"http://127.0.0.1:9097/providers/proxies/{
        group}/{encoded_name}/healthcheck"

    params = {
        "url": "http://www.youtube.com",
        "timeout": 5000
    }

    headers = {
        "Authorization": f"Bearer {PASSWORD}"
    }

    try:
        start_time = time.time()
        response = requests.get(
            test_url, headers=headers, params=params, timeout=5)
        latency = int((time.time() - start_time) * 1000)  # 转换为毫秒

        if response.status_code == 200:
            result = response.json()
            if "delay" in result:
                results_queue.put((node_name, result["delay"]))
                return
            else:
                results_queue.put((node_name, "无延迟数据"))
        else:
            results_queue.put((node_name, f"错误 {response.status_code}"))

    except requests.exceptions.Timeout:
        results_queue.put((node_name, "超时"))
    except requests.exceptions.RequestException as e:
        results_queue.put((node_name, f"错误: {str(e)}"))
    except json.JSONDecodeError:
        results_queue.put((node_name, "无效响应"))


def test_all_nodes_latency(proxies):
    """测试所有节点的延迟（多线程）"""
    results = {}
    results_queue = queue.Queue()
    threads = []

    # 为每个节点创建测试线程
    for node in proxies:
        thread = threading.Thread(
            target=test_node_latency, args=(node, results_queue))
        thread.daemon = True
        thread.start()
        threads.append(thread)
        time.sleep(0.05)  # 避免一次性创建太多线程

    # 等待所有线程完成
    for thread in threads:
        thread.join(timeout=10)

    # 收集结果
    while not results_queue.empty():
        node, latency = results_queue.get()
        results[node] = latency

    return results


def show_message(win, message, color_pair=0, duration=1.5):
    """在屏幕底部显示临时消息"""
    height, width = win.getmaxyx()
    win.addstr(height - 3, (width - len(message)) // 2,
               message, curses.color_pair(color_pair))
    win.refresh()
    time.sleep(duration)


def main(stdscr):
    # 初始化curses
    curses.curs_set(0)
    stdscr.nodelay(0)
    stdscr.keypad(True)

    # 初始化颜色
    curses.start_color()
    curses.init_pair(1, curses.COLOR_CYAN, curses.COLOR_BLACK)  # 选中项
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)  # 当前使用节点
    curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # 标题
    curses.init_pair(4, curses.COLOR_RED, curses.COLOR_BLACK)    # 错误信息
    curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)  # 成功信息
    curses.init_pair(6, curses.COLOR_BLUE, curses.COLOR_BLACK)   # 延迟信息

    # 主循环变量
    selected_idx = 0
    scroll_offset = 0
    last_update = time.time()
    data = {}
    latency_results = {}  # 存储延迟测试结果
    is_testing = False    # 是否正在测试延迟
    last_status_message = ""
    test_progress = 0     # 测试进度
    test_total_nodes = 0

    # 定义更新进度的函数
    def update_progress(total_nodes):
        nonlocal test_progress, is_testing
        while is_testing:
            # 当前完成的节点数
            done = len(latency_results)
            test_progress = done
            # 如果已经完成了所有节点的测试，退出
            if done >= total_nodes:
                break
            time.sleep(0.5)

    # 初始数据加载
    data = fetch_proxy_data()
    if "error" not in data:
        logging.info("初始节点数据加载成功")
    else:
        logging.error("初始节点数据加载失败")

    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()

        # 每5秒更新一次数据
        current_time = time.time()
        if current_time - last_update > 5 and not is_testing:
            new_data = fetch_proxy_data()
            if "error" not in new_data:
                data = new_data
                last_update = current_time
                logging.info("节点数据已刷新")

        # 显示标题
        title = "Clash 代理节点管理"
        stdscr.addstr(0, (width - len(title)) // 2, title,
                      curses.color_pair(3) | curses.A_BOLD)

        # 显示当前时间
        time_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        stdscr.addstr(1, width - len(time_str) - 2, time_str)

        # 处理错误情况
        if "error" in data:
            error_msg = f"错误: {data['error']}"
            stdscr.addstr(height // 2, (width - len(error_msg)) // 2,
                          error_msg, curses.color_pair(4))
            stdscr.addstr(height // 2 + 2, (width - 20) // 2, "按任意键重试...")
            stdscr.refresh()
            stdscr.getch()
            data = fetch_proxy_data()
            last_update = time.time()
            continue

        # 显示当前选择的节点
        if "now" in data:
            current_node = f"当前节点: {data['now']}"
            stdscr.addstr(2, 2, current_node,
                          curses.color_pair(2) | curses.A_BOLD)

        # 显示节点列表标题
        header = "可用节点 (↑/↓ n/e:选择, Enter:切换, o:跳转当前, p/P:测试)"
        stdscr.addstr(4, 2, header, curses.A_UNDERLINE)

        # 显示节点列表
        max_visible = height - 8  # 为状态消息留出空间
        proxies = data.get("all", [])

        # 处理滚动
        if selected_idx < scroll_offset:
            scroll_offset = selected_idx
        elif selected_idx >= scroll_offset + max_visible:
            scroll_offset = selected_idx - max_visible + 1

        for i in range(scroll_offset, min(len(proxies), scroll_offset + max_visible)):
            idx = i - scroll_offset
            proxy = proxies[i]

            # 如果有延迟测试结果，显示延迟信息
            latency_info = ""
            if proxy in latency_results:
                latency = latency_results[proxy]
                if isinstance(latency, int):
                    latency_info = f" ({latency}ms)"
                else:
                    latency_info = f" ({latency})"

            line = f"{i+1}. {proxy}{latency_info}"

            # 高亮当前选中的节点
            if i == selected_idx:
                stdscr.addstr(6 + idx, 2, line,
                              curses.color_pair(1) | curses.A_BOLD)
            # 标记当前使用的节点
            elif proxy == data.get("now", ""):
                stdscr.addstr(6 + idx, 2, line, curses.color_pair(2))
            # 标记有延迟结果的节点
            elif proxy in latency_results:
                stdscr.addstr(6 + idx, 2, line, curses.color_pair(6))
            else:
                stdscr.addstr(6 + idx, 2, line)

        # 显示滚动提示
        if len(proxies) > max_visible:
            scroll_info = f"节点 {
                scroll_offset+1}-{min(len(proxies), scroll_offset+max_visible)} / {len(proxies)}"
            stdscr.addstr(height - 2, width -
                          len(scroll_info) - 2, scroll_info)

        # 状态栏
        status_bar = "Q:退出 | R:刷新 | o:跳转当前 | p/P:测试"
        stdscr.addstr(height - 1, (width - len(status_bar)) // 2,
                      status_bar, curses.A_REVERSE)

        # 显示上次操作状态
        if last_status_message:
            stdscr.addstr(height - 3, (width - len(last_status_message)) // 2,
                          last_status_message, curses.color_pair(5))

        # 显示测试进度
        if is_testing:
            progress_msg = f"🔄 测试节点延迟中... ({test_progress}/{test_total_nodes})"
            stdscr.addstr(height - 4, (width - len(progress_msg)) // 2,
                          progress_msg, curses.color_pair(6) | curses.A_BOLD)
            stdscr.refresh()

        # 处理用户输入
        try:
            key = stdscr.getch()
        except:
            key = -1

        if key == curses.KEY_UP or key == ord("e"):
            selected_idx = max(0, selected_idx - 1)
            last_status_message = ""
        elif key == curses.KEY_DOWN or key == ord("n"):
            selected_idx = min(len(proxies) - 1, selected_idx + 1)
            last_status_message = ""
        elif key == ord('o'):
            if proxies and "now" in data:
                try:
                    current_node_name = data.get("now", "")
                    if current_node_name in proxies:
                        selected_idx = proxies.index(current_node_name)
                        last_status_message = f"🔍 已跳转到当前节点"
                except ValueError:
                    last_status_message = "❌ 未在列表中找到当前节点"
        elif key == ord('\n') or key == curses.KEY_ENTER:
            if proxies and selected_idx < len(proxies):
                proxy_name = proxies[selected_idx]
                if switch_proxy(proxy_name):
                    last_status_message = f"✅ 已切换到节点: {proxy_name}"
                    data["now"] = proxy_name  # 更新本地数据
                else:
                    last_status_message = "❌ 切换节点失败!"
        elif key == ord('r') or key == ord('R'):
            new_data = fetch_proxy_data()
            if "error" not in new_data:
                data = new_data
                last_update = time.time()
                last_status_message = "🔄 节点数据已刷新"
            else:
                last_status_message = "❌ 刷新数据失败"
        elif key == ord('p'):  # 测试当前节点
            if proxies and not is_testing and selected_idx < len(proxies):
                proxy_name = proxies[selected_idx]
                is_testing = True
                test_progress = 0
                test_total_nodes = 1
                last_status_message = f"⏳ 开始测试节点: {proxy_name}"

                def run_single_latency_test():
                    nonlocal latency_results, is_testing, last_status_message
                    try:
                        q = queue.Queue()
                        test_node_latency(proxy_name, q)
                        if not q.empty():
                            node, latency = q.get()
                            latency_results[node] = latency
                        last_status_message = f"✅ 节点 {proxy_name} 测试完成!"
                    except Exception as e:
                        last_status_message = f"❌ 测试失败: {str(e)}"
                        logging.error(f"测试节点 {proxy_name} 失败: {str(e)}")
                    finally:
                        is_testing = False

                test_thread = threading.Thread(target=run_single_latency_test)
                test_thread.daemon = True
                test_thread.start()

                progress_thread = threading.Thread(
                    target=update_progress, args=(1,))
                progress_thread.daemon = True
                progress_thread.start()
        elif key == ord('P'):  # 测试所有节点
            if proxies and not is_testing:
                is_testing = True
                test_progress = 0
                test_total_nodes = len(proxies)
                last_status_message = "⏳ 开始测试所有节点延迟..."
                latency_results.clear()

                def run_latency_test():
                    nonlocal latency_results, is_testing, last_status_message
                    try:
                        test_results = test_all_nodes_latency(proxies)
                        latency_results.update(test_results)
                        last_status_message = "✅ 延迟测试完成!"
                    except Exception as e:
                        last_status_message = f"❌ 测试失败: {str(e)}"
                        logging.error(f"延迟测试失败: {str(e)}")
                    finally:
                        is_testing = False

                test_thread = threading.Thread(target=run_latency_test)
                test_thread.daemon = True
                test_thread.start()

                progress_thread = threading.Thread(
                    target=update_progress, args=(len(proxies),))
                progress_thread.daemon = True
                progress_thread.start()
        elif key == ord('q') or key == ord('Q'):
            break

    # 退出清理
    stdscr.clear()
    stdscr.refresh()


if __name__ == "__main__":
    print("启动Clash代理节点管理TUI...")
    print(f"API端点: {PROXIES_URL}")

    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        print("\n程序已退出")
    except Exception as e:
        logging.exception("程序发生异常")
        print(f"程序发生错误: {str(e)}")
        print("详细信息请查看日志文件: clash_tui.log")
