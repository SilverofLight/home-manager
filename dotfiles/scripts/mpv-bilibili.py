#!/bin/env python
import http.server
import socketserver
import urllib.parse
import subprocess

PORT = 15612


class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/play":
            query = urllib.parse.parse_qs(parsed.query)
            url = query.get("url", [""])[0]
            if url:
                print("Playing:", url)
                subprocess.Popen(["mpv", "--quiet", "--no-terminal",
                                 "--input-ipc-server=/tmp/mpv_bilibili", "--title=mpv-bilibili", url])
            self.send_response(200)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()


Handler = CORSRequestHandler
httpd = socketserver.TCPServer(("", PORT), Handler)

print(f"Serving on port {PORT}")
httpd.serve_forever()
