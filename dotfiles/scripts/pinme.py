#!/bin/env python

# require: pinme
# pin 一个文件，并将链接复制到剪切版

import os
import subprocess
import sys


def send_notification(title, message):
    """Sends a system notification."""
    try:
        # Check if notify-send is available (common on Linux/GNOME/KDE)
        subprocess.run(["notify-send", title, message], check=True, capture_output=True)
    except FileNotFoundError:
        print(f"Warning: 'notify-send' command not found. Cannot send desktop notification.")
        print(f"Notification: {title} - {message}")
    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to send notification: {e}")
        print(f"Stderr: {e.stderr}")
        print(f"Stdout: {e.stdout}")
    except Exception as e:
        print(f"An unexpected error occurred while sending notification: {e}")


def get_ens_url_from_pinme_ls_output(output, item_number=1):
    """
    Parses the output of 'pinme ls' and extracts the ENS URL for a specific item number.
    """
    lines = output.split('\n')
    target_url = None
    in_target_block = False
    item_start_pattern = f"{item_number}."

    for line in lines:
        stripped_line = line.strip()

        if stripped_line.startswith(item_start_pattern):
            in_target_block = True
            continue

        if in_target_block:
            if stripped_line.startswith("ENS URL:"):
                target_url = stripped_line.split("ENS URL:", 1)[1].strip()
                break # Found it, exit loop
            elif stripped_line.startswith("----------------") or \
                 (stripped_line and stripped_line[0].isdigit() and stripped_line.find(".") == 1):
                # Next entry or separator, so we are past the target block
                in_target_block = False
                break
    return target_url


def pin(path):
    if os.path.isfile(path):
        send_notification("Pinme", f"Pinning {os.path.basename(path)}...")

        try:
            result = subprocess.run(["pinme", "upload", path], check=True,
                    capture_output=True, text=True)
            if result.stderr:
                print("Command errors (if any):")
                print(result.stderr)

            list_result = subprocess.run(["pinme", "ls"], check=True,
                    capture_output=True, text=True)

            if list_result.returncode == 0:
                ens_url = get_ens_url_from_pinme_ls_output(list_result.stdout, 1)
                if ens_url:
                    print(f"ENS URL for the most recent upload (item 1): {ens_url}")
                    # Optionally, copy to clipboard
                    try:
                        # subprocess.run(["wl-copy", ens_url], check=True, capture_output=True)
                        if os.path.exists("/usr/bin/wl-copy"):
                            subprocess.run(["wl-copy", ens_url])
                        elif os.path.exists("/usr/bin/xclip"):
                            subprocess.run(["xclip", "-selection", "clipboard", ens_url])
                        else:
                            send_notification("Pinme Error", "Clipboard Tool not found")
                        send_notification("Pinme Success", f"Pinned {os.path.basename(path)}. ENS URL copied!")
                    except FileNotFoundError:
                        send_notification("Pinme Success", f"Pinned {os.path.basename(path)}. ENS URL: {ens_url}")
                        print("Warning: 'wl-copy' not found. ENS URL was not copied to clipboard.")
                    except subprocess.CalledProcessError as e:
                        send_notification("Pinme Success", f"Pinned {os.path.basename(path)}. ENS URL: {ens_url}")
                        print(f"Warning: Failed to copy to clipboard with wl-copy: {e.stderr}")
                else:
                    send_notification("Pinme Success", f"Pinned {os.path.basename(path)}. Could not find ENS URL.")
                    print("Could not find ENS URL for item 1 in 'pinme ls' output.")
            else:
                send_notification("Pinme Error", f"Failed to list pinned items after upload.")
                print(f"Error listing pinme items: {list_result.stderr}")

        except Exception as e:
            raise e
    else:
        print(f"Error: {path} is not a file")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: pinme.py <path>")
        print("Requirement:")
        print("    1. nmp install -g pinme")
        print("    2. wl-copy")
    else:
        path = sys.argv[1]
        path = os.path.abspath(path)
        pin(path)
