#!/home/silver/.conda/envs/main/bin/python

from sqlcipher3 import dbapi2 as sqlite
import os
import subprocess
import sys

# require: python-sqlcipher3
# 密码在 bw 中

home = os.getenv('HOME')
database = os.path.join(home, '.config/hypr/scripts/bookmarks.db')

# 连接数据库（文件不存在则创建）
try:
    with sqlite.connect(database) as conn:
        cursor = conn.cursor()

        # 设置加密密钥
        # key = os.getenv('BOOKMARKS_KEY')
        path = os.path.join(home, 'Documents/keys/bookmarks_key')
        with open(path, 'r', encoding='utf-8') as file:
            key = file.read().strip()
        if not key:
            subprocess.run(['notify-send', '错误', '环境变量 BOOKMARKS_KEY 未设置'])
            raise ValueError("环境变量 BOOKMARKS_KEY 未设置")
        cursor.execute(f"PRAGMA key = '{key}'")

        # 验证 SQLCipher 是否正常工作
        # cursor.execute("PRAGMA cipher_version")
        # print("SQLCipher version:", cursor.fetchone())

        # 确保表存在
        cursor.execute(
            "CREATE TABLE IF NOT EXISTS bookmarks (name TEXT, desc TEXT, url TEXT)")

        # 查询数据
        cursor.execute("SELECT * FROM bookmarks")
        rows = cursor.fetchall()

        # for row in rows:
        #     print(f"{row[0]} | {row[1]} | {row[2]}")
        if not rows:
            # print("No bookmarks found.")
            exit(0)
        else:
            formatted_rows = [f"{row[0]} | {row[1]} | {row[2]}" for row in rows]

            # 分类：tol, med, prn, vps, ai, doc, dev
            # sort: med, ai, dev, prn, tol, vps, doc
            category_order = {'med': 0, 'ai': 1, 'dev': 2, 'prn': 3, 'tol': 4, 'vps': 5, 'doc': 6}
            def get_category_priority(row):
                # Extract first 3 characters and strip whitespace
                prefix = row[:3].strip()
                # Handle 'ai ' case (with space) by checking for 'ai' substring
                if prefix == 'ai':
                    return category_order.get('ai', 6)
                else:
                    return category_order.get(prefix, 6)
            
            # Sort formatted_rows by category priority, maintaining original order within categories
            formatted_rows.sort(key=get_category_priority)

            process = subprocess.Popen(
                ['wofi', '--show', 'dmenu', '--prompt', 'Bookmarks'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            selected, _ = process.communicate(input='\n'.join(formatted_rows))
            if selected:
                selected = selected.strip()
                # print(selected)
                selected_url = selected.split(' | ')[2]
                # print(selected_url)
                # subprocess.run(['xdg-open', selected_url])
                if len(sys.argv) <= 1:
                    # os.environ['QT_QPA_PLATFORM'] = 'xcb'
                    subprocess.run(['qutebrowser', selected_url])

                elif sys.argv[1] == 'open':
                    print(selected_url)
                else:
                    # os.environ['QT_QPA_PLATFORM'] = 'xcb'
                    subprocess.run(['qutebrowser', selected_url])
            else:
                exit(0)

except sqlite.DatabaseError as e:
    # 捕获数据库相关错误（如密码错误）
    error_msg = f"数据库错误: {str(e)}"
    subprocess.run(['notify-send', '错误', '数据库密码错误或文件损坏'])
    exit(1)
except Exception as e:
    # 捕获其他异常
    error_msg = f"错误: {str(e)}"
    subprocess.run(['notify-send', '错误', error_msg])
    exit(1)
