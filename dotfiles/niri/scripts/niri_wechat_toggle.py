#!/usr/bin/env python3

import re
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
    workspace_name = match.group(2)
    
    return workspace_name or workspace_id

def main():
    temp_file = Path.home() / "Templates" / "niri_wechat.tmp"
    temp_file.touch(exist_ok=True)

    current_workspace = get_current_workspace()
    if current_workspace != "wechat":
        temp_file.write_text(str(current_workspace))
        niri_cmd(["focus-workspace", "wechat"])

    else:
        last_workspace = temp_file.read_text()
        niri_cmd(["focus-workspace", last_workspace])


if __name__ == "__main__":
    main()
