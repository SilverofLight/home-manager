#!/usr/bin/env python3

import re
import sys
import subprocess
from pathlib import Path

def niri_cmd(cmd_args):
    subprocess.run(["niri", "msg", "action"] + cmd_args)

def niri_msg(cmd_args):
    result = subprocess.run(
        ["niri", "msg"] + cmd_args,
        capture_output=True,
        text=True,
        check=True
    )
    return result.stdout.strip()

def get_current_workspace() -> str:
    output = niri_msg(["workspaces"])

    match = re.search(r'^\s*\*\s+(\d+)\s*(?:\"([^\"]+)\")?', output, re.MULTILINE)
    if not match:
        raise RuntimeError("无法解析当前工作区")

    workspace_id = match.group(1)
    # workspace_name = match.group(2)

    return workspace_id

def get_last_workspace() -> str:
    output = niri_msg(["workspaces"])
    # 按行分割并过滤掉空行
    lines = [line.strip() for line in output.strip().splitlines() if line.strip()]

    last_line = lines[-1]

    last_line = last_line.replace("*", "").strip()

    id = last_line.split()[0]
    return id

def circ_next():
    current_workspace = get_current_workspace()
    last_workspace = get_last_workspace()
    if current_workspace == "1" or current_workspace == "2":
        niri_cmd(["focus-workspace", "3"])
    elif current_workspace == last_workspace:
        niri_cmd(["focus-workspace", "3"])
    else:
        niri_cmd(["focus-window-or-workspace-down"])
    return

def circ_prev():
    current_workspace = get_current_workspace()
    last_workspace = get_last_workspace()
    if current_workspace == "1" or current_workspace == "2" or current_workspace == "3":
        niri_cmd(["focus-workspace", last_workspace])
    else:
        niri_cmd(["focus-window-or-workspace-up"])
    return


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("使用方法：")
        print("1. niri_circ_in_normal.py n == circ next")
        print("2. niri_circ_in_normal.py p == circ prev")
        exit(1)
    arg = sys.argv[1]

    if arg == "n":
        circ_next()
    elif arg == "p":
        circ_prev()
