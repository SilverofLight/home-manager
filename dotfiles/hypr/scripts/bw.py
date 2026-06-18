#!/bin/env python
import subprocess
import os
import csv

home = os.getenv('HOME')
path = os.path.join(home, 'Documents/keys/passwords.csv')

bw_type = subprocess.run(
    "echo -e \"Login\\nNote\" | wofi --dmenu --prompt 'Select Type'",
    shell=True,
    text=True,
    capture_output=True
)

# 0: folder, 1: favorite, 2: type, 3: name, 4: notes, 5: fields, 6: reprompt,
# 7: login_uri, 8: login_username, 9: login_password, 10: login_totp
FIELDS = [
    "folder",
    "favorite",
    "type",
    "name",
    "notes",
    "fields",
    "reprompt",
    "login_uri",
    "login_username",
    "login_password",
    "login_totp",
]

def format_item(row):
    lines = []
    for key, value in zip(FIELDS, row):
        if value not in ("", None):
            lines.append(f"{key}: {value}\n")
    return "".join(lines)

items = []
with open(path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file)
    if bw_type.stdout.strip() == "Login":
        for row in csv_reader:
            if row[2] == "login":
                # print(row)
                items.append(row)
    elif bw_type.stdout.strip() == "Note":
        for row in csv_reader:
            if row[2] == "note":
                items.append(row)

if bw_type.stdout.strip() == "Login":
    show_msg = ""
    index = 0

    for i in items:
        show_msg += f"{index} | {i[3]} | {i[7]}\n"
        index = index + 1

    selection = subprocess.run(
        f"echo \"{show_msg}\" | wofi --dmenu --prompt 'Select Login'",
        shell=True,
        text=True,
        capture_output=True
    ).stdout.strip().split(" ")[0]

    item = items[int(selection)]
elif bw_type.stdout.strip() == "Note":
    show_msg = ""
    index = 0

    for i in items:
        show_msg += f"{index} | {i[3]}\n"
        index = index + 1

    selection = subprocess.run(
        f"echo \"{show_msg}\" | wofi --dmenu --prompt 'Select Note'",
        shell=True,
        text=True,
        capture_output=True
    ).stdout.strip().split(" ")[0]

    item = items[int(selection)]

temp_file = "/tmp/bw.tmp.md"
with open(temp_file, "w") as f:
    if bw_type.stdout.strip() == "Login":
        f.write(format_item(item))
    elif bw_type.stdout.strip() == "Note":
        f.write(item[4])
    else:
        exit(1)
subprocess.run(
    f"kitty -T nvimAnywhere fish -c 'nvim {temp_file}'",
    shell=True
)
os.remove(temp_file)
