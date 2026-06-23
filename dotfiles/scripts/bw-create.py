#!/bin/env python
import json, os, argparse, subprocess

class Login:
    def __init__(self, name, note, uri, username, password):
        self.name = name
        self.note = note
        self.uri = uri
        self.username = username
        self.password = password
    def __repr__(self):
        return f"Login(name={self.name}\nnote={self.note}\nuri={self.uri}\nusername={self.username}\npassword={self.password})"

class Note:
    def __init__(self, name, note):
        self.name = name
        self.note = note
    def __repr__(self):
        return f"Note(name={self.name}, note={self.note})"

def main():
    parser = argparse.ArgumentParser(
        description="Add Bitwarden item. (set type to 'none' to cancel)"
    )
    parser.add_argument("-t", "--type", default="", help="Bitwarden item type", choices=["login", "note"], required=False)
    parser.add_argument("-n", "--name", default="", help="Bitwarden item name", required=False)
    parser.add_argument("-N", "--note", default="", help="Bitwarden item note", required=False)
    parser.add_argument("-i", "--uri", default="", help="Bitwarden item URI", required=False)
    parser.add_argument("-u", "--username", default="", help="Bitwarden item username", required=False)
    parser.add_argument("-p", "--password", default="", help="Bitwarden item password", required=False)

    args = parser.parse_args()

    if args.type == "":
        args.type = subprocess.run(
            "echo \"login\nnote\" | wofi --dmenu -p \"Select item type\"",
            capture_output=True,
            shell=True,
            text=True
        ).stdout.strip()
    if args.type == "":
        exit(1)

    notify("bw_create", f"正在创建 {args.type}", "low")

    # ===========
    # ===== LOGIN
    # ===========
    if args.type == "login":
        temp_file = "/tmp/bw_create.tmp.md"
        with open(temp_file, "w") as f:
            f.write(f"type: login\nname: {args.name}\nnote: {args.note}\nuri: {args.uri}\nusername: {args.username}\npassword: {args.password}")

        subprocess.run(
            f"kitty -T Floating_Term fish -c 'nvim {temp_file}'",
            shell=True
        )

        with open(temp_file, "r") as f:
            # Parse temp_file and create Login/Note object
            lines = f.readlines()
            data = {}
            for line in lines:
                if ":" in line:
                    key, value = line.strip().split(":", 1)
                    data[key.strip()] = value.strip()

            if data.get("type") == "none":
                notify("bw_create", "取消创建", "low")
                exit(1)
            login = Login(
                name=data.get("name", ""),
                note=data.get("note", ""),
                uri=data.get("uri", ""),
                username=data.get("username", ""),
                password=data.get("password", "")
            )
            print(login)
        os.remove(temp_file)
        data = generate("login", login)

    # ===========
    # ===== NOTE
    # ===========
    else:
        temp_file = "/tmp/bw_create.tmp.md"
        with open(temp_file, "w") as f:
            f.write(f"type: note\nname:\n{args.name}\nnote:\n{args.note}")
        subprocess.run(
            f"kitty -T Floating_Term fish -c 'nvim {temp_file}'",
            shell=True
        )

        with open(temp_file, "r") as f:
            lines = f.readlines()
            # Parse note format: line 2 is name, lines 4 to end are content
            if len(lines) >= 2:
                ty = lines[0].split(" ")[1].strip()
                if ty == "none":
                    notify("bw_create", "取消创建", "low")
                    exit(1)
                name = lines[2].strip() if len(lines) > 2 else ""
                # Get content from line 4 to end (index 3 to end)
                content_lines = lines[4:] if len(lines) > 4 else []
                note_content = "".join(content_lines).strip()

                note = Note(
                    name=name,
                    note=note_content
                )
                print(note)

        # Clean up temp file
        os.remove(temp_file)
        data = generate("note", note)

    proc = subprocess.run(
        ["bw", "encode"],
        input=json.dumps(data),
        text=True,
        capture_output=True,
        check=True
    )
    
    try:
        subprocess.run(
            ["bw", "create", "item"],
            input=proc.stdout,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
    except subprocess.CalledProcessError as e:
        err = e.stderr.strip() if e.stderr else "unknown error"
        notify("创建新 bw 项目失败：", err)
        exit(1)

    notify("创建新 bw 项目成功：", f"{data['name']}")

def notify(title, message, urgency="critical"):
    subprocess.run(
        [
            "notify-send",
            "-u", urgency,
            "-a", "bw-create",
            title,
            message
        ],
        check=False
    )

def generate(type, content):
    if type == "login":
        item = json.loads(
            subprocess.check_output(["bw", "get", "template", "item"])
        )
        login = json.loads(
            subprocess.check_output(["bw", "get", "template", "item.login"])
        )

        item["type"] = 1
        item["name"] = content.name
        item["notes"] = content.note
        item["favorite"] = False
        item["reprompt"] = 0

        login["username"] = content.username
        login["password"] = content.password

        if content.uri:
            login["uris"] = [{
                "uri": content.uri,
                "match": None
            }]

        item["login"] = login
        return item
    else:
        item = json.loads(
            subprocess.check_output(["bw", "get", "template", "item"])
        )

        item["type"] = 2
        item["name"] = content.name
        item["notes"] = content.note
        item["secureNote"] = {"type": 0}
        item["favorite"] = False
        item["reprompt"] = 0

        return item

if __name__ == "__main__":
    main()
