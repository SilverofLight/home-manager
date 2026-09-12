#!/bin/env python

import subprocess

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

def get_all_windows() -> list:
    windows = niri_msg(["windows"])
    # Split the output by blank lines (double newlines) to separate each window
    return [window.strip() for window in windows.split('\n\n') if window.strip()]

def get_current_window() -> str:
    return niri_msg(["focused-window"])

def get_workspace_id(window_info: str) -> str:
    """Extract Workspace ID from window information string."""
    for line in window_info.split('\n'):
        if "Workspace ID:" in line:
            return line.split(':')[1].strip()
    return ""

def filter_windows_by_workspace(windows: list, target_workspace: str) -> list:
    """Filter windows to keep only those in the target workspace."""
    filtered_windows = []
    for window in windows:
        workspace_id = get_workspace_id(window)
        if workspace_id == target_workspace:
            filtered_windows.append(window)
    return filtered_windows

def get_window_to_the_right(filtered_windows: list, window_info: str) -> str:
    """Get the window to the right of the current window. Returns the window ID."""
    current_column = ""
    # Look for "Scrolling position: column" in the window info
    for line in window_info.split('\n'):
        if "Scrolling position: column" in line:
            # Extract the column number - the 4th element after splitting
            parts = line.split()
            if len(parts) >= 4:
                # Extract the column number from "column X, tile Y" format
                current_column = parts[3].rstrip(',tile')
                break

    if not current_column:
        return "ERROR: cannot get current window"

    # Find the window that is one column to the right
    for window in filtered_windows:
        for line in window.split('\n'):
            if "Scrolling position: column" in line:
                parts = line.split()
                if len(parts) >= 4:
                    window_column = parts[3].rstrip(',tile')
                    if window_column.isdigit() and current_column.isdigit():
                        if int(window_column) == int(current_column) + 1:
                            # Extract the window ID from the window info
                            for wline in window.split('\n'):
                                if wline.startswith("Window ID"):
                                    return wline.split()[2].rstrip(':')
    
    return "0"

def main():
    window_list = get_all_windows()
    current_window = get_current_window()

    # Get the workspace ID of the current/focused window
    current_workspace = get_workspace_id(current_window)

    # Filter windows to keep only those in the same workspace
    filtered_windows = filter_windows_by_workspace(window_list, current_workspace)

    # Find the window to the right of the current window
    right_window_ID = get_window_to_the_right(filtered_windows, current_window)

    if right_window_ID == "0":
        return False

    # Get current window's ID
    current_window_ID = ""
    for wline in current_window.split('\n'):            
        if wline.startswith("Window ID"):       
            current_window_ID = wline.split()[2].rstrip(':')

    if not current_window_ID:
        return False

    # print("right window:", right_window_ID)
    # print("current_window:", current_window_ID)

    niri_cmd(["set-window-width", "55%"])
    niri_cmd(["focus-window", "--id", right_window_ID])
    niri_cmd(["set-window-width", "45%"])
    niri_cmd(["focus-window", "--id", current_window_ID])

if __name__ == "__main__":
    main()
