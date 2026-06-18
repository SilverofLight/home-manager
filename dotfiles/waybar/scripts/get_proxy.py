#!/bin/env python
from urllib.parse import quote
import requests
import os

PASSWORD = os.getenv("CLASH_PASSWORD", "your_default_password")
group = quote("辉夜Proxy", safe='')
PROXIES_URL = f"http://127.0.0.1:9097/proxies/{group}"

headers = {"Authorization": f"Bearer {PASSWORD}"}
response = requests.get(PROXIES_URL, headers=headers, timeout=3)
data = response.json()

if "now" in data:
    current_node = f"{data['now']}"

print(current_node)
